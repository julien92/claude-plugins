---
allowed-tools: Bash(git:*), Bash(gh:*), Bash(glab:*), Bash(curl:*), Bash(jq:*), Bash(PROVIDER=*), Bash(eval:*), Read
description: Review any Pull Request with AI-assisted analysis and inline comments (GitHub/GitLab/Bitbucket)
argument-hint: "[PR number]"
disable-model-invocation: true
---

## Context

- Current branch: !`git branch --show-current`
- Uncommitted changes: !`git status --porcelain`
- Remote URL: !`git remote get-url origin`

## Your task

Help the user review a Pull Request with AI-assisted analysis. You will:
1. Save current context (stash)
2. List and checkout the PR
3. Analyze each file and suggest comments
4. Post inline comments
5. Restore context
6. Show final summary with PR link

## Step 1: Save context

Store the current branch name for later restoration.

If there are uncommitted changes (git status --porcelain is not empty):
```bash
git stash push -m "git-review-context-$(date +%s)"
```

## Step 2: Detect provider

Use the shared detection script:
```bash
PROVIDER=$(bash ${CLAUDE_PLUGIN_ROOT}/scripts/detect-provider.sh)
```

Returns: `github`, `gitlab`, `bitbucket`, or `unknown`

For self-hosted instances, set `$GIT_PROVIDER` env var.

For Bitbucket, also extract workspace and repo:
```bash
eval $(bash ${CLAUDE_PLUGIN_ROOT}/scripts/parse-bitbucket-url.sh)
# Sets: BB_WORKSPACE, BB_REPO
```

## Step 3: List open PRs

**GitHub:**
```bash
gh pr list --state open --limit 20 --json number,title,author,headRefName,additions,deletions
```

**GitLab:**
```bash
glab mr list --state opened --per-page 20
```

**Bitbucket:**
```bash
curl -sN -u "${BITBUCKET_EMAIL}:${BITBUCKET_API_TOKEN}" \
  "https://api.bitbucket.org/2.0/repositories/${BB_WORKSPACE}/${BB_REPO}/pullrequests?state=OPEN&pagelen=20" \
  > /tmp/bitbucket_prs.json && \
  jq -r '.values[] | "PR #\(.id) | \(.source.branch.name) -> \(.destination.branch.name) | \(.title) | by \(.author.display_name)"' /tmp/bitbucket_prs.json
```

Display the list and ask the user which PR they want to review.

## Step 4: Checkout the PR

**GitHub:**
```bash
gh pr checkout <pr-number>
```

**GitLab:**
```bash
glab mr checkout <mr-iid>
```

**Bitbucket:**
Get the source branch from the PR, then:
```bash
git fetch origin <source-branch>
git checkout <source-branch>
```

## Step 5: Get PR metadata for inline comments

**GitHub:**
```bash
COMMIT_ID=$(gh pr view <pr-number> --json headRefOid -q .headRefOid)
BASE_BRANCH=$(gh pr view <pr-number> --json baseRefName -q .baseRefName)
REPO_OWNER=$(gh repo view --json owner -q .owner.login)
REPO_NAME=$(gh repo view --json name -q .name)
```

**GitLab:**
```bash
PROJECT_ID=$(glab api projects/:fullpath -q .id)
BASE_SHA=$(glab api projects/:fullpath/merge_requests/<mr-iid> -q .diff_refs.base_sha)
HEAD_SHA=$(glab api projects/:fullpath/merge_requests/<mr-iid> -q .diff_refs.head_sha)
START_SHA=$(glab api projects/:fullpath/merge_requests/<mr-iid> -q .diff_refs.start_sha)
BASE_BRANCH=$(glab api projects/:fullpath/merge_requests/<mr-iid> -q .target_branch)
```

**Bitbucket:**
```bash
curl -sN -u "${BITBUCKET_EMAIL}:${BITBUCKET_API_TOKEN}" \
  "https://api.bitbucket.org/2.0/repositories/${BB_WORKSPACE}/${BB_REPO}/pullrequests/{pr_id}" > /tmp/pr_info.json
BASE_BRANCH=$(jq -r '.destination.branch.name' /tmp/pr_info.json)
```

## Step 6: Get the list of changed files

Get the absolute path of the repository root and fetch the changed files:
```bash
REPO_ROOT=$(git rev-parse --show-toplevel)
git fetch origin $BASE_BRANCH
git diff origin/$BASE_BRANCH...HEAD --name-only
```

## Step 6.5: Read full diff for global context

Before analyzing files individually, read the complete diff to understand the overall changes:
```bash
git diff origin/$BASE_BRANCH...HEAD
```

This gives you the full picture of all modifications. Use this context to provide better, more coherent suggestions during the file-by-file review (e.g., understanding how a new field flows through layers, spotting inconsistencies across files).

## Step 7: Review each file with AI assistance

For each changed file:

1. **Read the full file and explore related files if needed**: Read the changed file to understand the context. If understanding the changes requires additional context (imported modules, interfaces, base classes, called functions, etc.), read those files too. Use your judgment to determine what's relevant.

2. **Get the diff** (you will display it to the user in step 4):
```bash
git diff origin/$BASE_BRANCH...HEAD -- <file>
```
Also extract `FIRST_LINE` from the first `@@` hunk header (e.g. `@@ -97,6 +97,7 @@` → line 97).

3. **Analyze the code in context and provide:**
   - Brief summary of what the changes do
   - How the changes fit within the existing code structure
   - Detected issues (bugs, security, logic problems, inconsistencies with existing code)
   - Suggested comments ready to post

4. **Present to user** — **IMPORTANT: Follow this exact format for IDE clickability:**
```
📄 [X/Y] (+N/-M lines)
▸ $REPO_ROOT/<filepath>:$FIRST_LINE

🎯 PR: <brief one-line description of the PR objective>

📝 Changes:
<Show the diff content here so user can see the modifications>

🔍 Analysis:
<Brief explanation of what this code does and how it fits in the existing structure>

💬 Review comments:
1. L:<line> [<type>] <issue description>
   → "<comment text to post>"

2. L:<line> [<type>] <issue description>
   → "<comment text to post>"

Types: [bug] [security] [perf] [style] [logic] [question]

Actions:
- "1" → post comment 1
- "2" → post comment 2
- "edit 1 <your text>" → modify and post
- "add L:<line> <message>" → custom comment
- "next" → next file
- "done" → finish review
```

5. **Wait for user input before proceeding**

## Step 8: Post inline comments

**GitHub:**
```bash
gh api repos/$REPO_OWNER/$REPO_NAME/pulls/<pr-number>/comments \
  -f body="<comment>" \
  -f path="<filepath>" \
  -f commit_id="$COMMIT_ID" \
  -f line=<line_number> \
  -f side=RIGHT
```

For deleted lines, use `side=LEFT`.

**GitLab:**
```bash
glab api projects/$PROJECT_ID/merge_requests/<mr-iid>/discussions -X POST \
  -f body="<comment>" \
  -f "position[base_sha]=$BASE_SHA" \
  -f "position[head_sha]=$HEAD_SHA" \
  -f "position[start_sha]=$START_SHA" \
  -f "position[new_path]=<filepath>" \
  -f "position[new_line]=<line_number>" \
  -f "position[position_type]=text"
```

For deleted lines, use `old_path` and `old_line` instead.

**Bitbucket:**
```bash
curl -X POST -u "${BITBUCKET_EMAIL}:${BITBUCKET_API_TOKEN}" \
  "https://api.bitbucket.org/2.0/repositories/${BB_WORKSPACE}/${BB_REPO}/pullrequests/{pr_id}/comments" \
  -H "Content-Type: application/json" \
  -d '{
    "content": {"raw": "<comment>"},
    "inline": {
      "path": "<filepath>",
      "to": <line_number>
    }
  }'
```

## Step 9: Finalize review

Ask the user how to finalize:
- **approve** → Approve the PR
- **request-changes** → Request changes
- **comment** → Submit as comment only
- **skip** → Skip finalization and just restore context

**GitHub:**
```bash
gh pr review <pr-number> --approve
# or
gh pr review <pr-number> --request-changes --body "<summary>"
# or
gh pr review <pr-number> --comment --body "<summary>"
```

**GitLab:**
```bash
glab mr approve <mr-iid>
# or post a summary note
glab mr note <mr-iid> --message "<summary>"
```

**Bitbucket:**
```bash
# Approve
curl -X POST -u "${BITBUCKET_EMAIL}:${BITBUCKET_API_TOKEN}" \
  "https://api.bitbucket.org/2.0/repositories/${BB_WORKSPACE}/${BB_REPO}/pullrequests/{pr_id}/approve"
# or Request changes (post comment)
curl -X POST -u "${BITBUCKET_EMAIL}:${BITBUCKET_API_TOKEN}" \
  "https://api.bitbucket.org/2.0/repositories/${BB_WORKSPACE}/${BB_REPO}/pullrequests/{pr_id}/comments" \
  -H "Content-Type: application/json" \
  -d '{"content": {"raw": "<summary>"}}'
```

## Step 10: Restore context

```bash
git checkout <original-branch>
```

If we stashed changes earlier:
```bash
git stash pop
```

## Step 11: Final summary

Present a complete summary of the review:

```
✅ PR Review Complete

📋 Summary:
- PR: #<number> - <title>
- Status: <approved ✅ | changes requested 🔄 | commented 💬 | skipped ⏭️>
- Files reviewed: X/Y
- Comments posted: N

💬 Comments posted:
1. <filepath>:L<line> - "<comment summary>"
2. <filepath>:L<line> - "<comment summary>"
...

🔗 View PR: <pr-url>
```

Get the PR URL:
- **GitHub:** `gh pr view <pr-number> --json url -q .url`
- **GitLab:** `glab mr view <mr-iid> --web` (or construct from remote URL)
- **Bitbucket:** `https://bitbucket.org/${BB_WORKSPACE}/${BB_REPO}/pull-requests/{pr_id}`

## Important notes

- Always wait for user input between files
- Keep track of all comments posted for the final summary in Step 11
- If user says "done" at any point, skip to Step 9 (finalize) then Step 10-11 (restore & summary)
- Handle errors gracefully (network issues, auth problems)
- For self-hosted GitLab/GitHub, the API endpoints remain the same but authentication must be configured
- When piping command outputs (e.g., `curl | jq`), prefer saving to a temporary file first then processing, as direct pipes may fail in some execution contexts:
  ```bash
  # Instead of: curl -s "url" | jq '...'
  # Use: curl -s "url" > /tmp/file.json && jq '...' /tmp/file.json
  ```

Do not use any other tools or do anything else beyond the PR review workflow described above.
