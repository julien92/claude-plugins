---
allowed-tools: Bash(git stash:*), Bash(git checkout:*), Bash(git fetch:*), Bash(git diff:*), Bash(git log:*), Bash(git remote:*), Bash(git branch:*), Bash(git status:*), Bash(gh pr list:*), Bash(gh pr view:*), Bash(gh pr checkout:*), Bash(gh pr review:*), Bash(gh repo view:*), Bash(gh api:*), Bash(glab mr list:*), Bash(glab mr view:*), Bash(glab mr checkout:*), Bash(glab mr approve:*), Bash(glab mr note:*), Bash(glab api:*), Bash(curl:*), Bash(jq:*)
description: Review any Pull Request with AI-assisted analysis and inline comments (GitHub/GitLab/Bitbucket)
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

## Step 1: Save context

Store the current branch name for later restoration.

If there are uncommitted changes (git status --porcelain is not empty):
```bash
git stash push -m "git-review-context-$(date +%s)"
```

## Step 2: Detect provider

Detect from remote URL:
- Contains `github.com` → GitHub
- Contains `gitlab.com` → GitLab
- Contains `bitbucket.org` → Bitbucket

If URL doesn't match (self-hosted), fall back to `$GIT_PROVIDER` env var.

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
Extract workspace and repo from remote URL, then:
```bash
curl -s -u "${BITBUCKET_EMAIL}:${BITBUCKET_API_TOKEN}" \
  "https://api.bitbucket.org/2.0/repositories/{workspace}/{repo}/pullrequests?state=OPEN&pagelen=20"
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
PR_INFO=$(curl -s -u "${BITBUCKET_EMAIL}:${BITBUCKET_API_TOKEN}" \
  "https://api.bitbucket.org/2.0/repositories/{workspace}/{repo}/pullrequests/{pr_id}")
BASE_BRANCH=$(echo "$PR_INFO" | jq -r '.destination.branch.name')
```

## Step 6: Get the list of changed files

Fetch the base branch and get changed files:
```bash
git fetch origin $BASE_BRANCH
git diff origin/$BASE_BRANCH...HEAD --name-only
```

## Step 7: Review each file with AI assistance

For each changed file:

1. **Show the diff:**
```bash
git diff origin/$BASE_BRANCH...HEAD -- <file>
```

2. **Analyze the code and provide:**
   - Brief summary of what the changes do
   - Detected issues (bugs, security, logic problems)
   - Suggested comments ready to post

3. **Present to user:**
```
📄 File X/Y: <filepath> (+N/-M lines)

🔍 Analysis:
<Brief explanation of what this code does>

⚠️ Issues detected:
- L:<line> → <description of issue>
- L:<line> → <description of issue>

💡 Suggested comments:
1. "L:<line> - <suggested comment text>"
2. "L:<line> - <suggested comment text>"

Actions:
- "1" → post suggestion 1
- "2" → post suggestion 2
- "edit 1 <your text>" → modify and post
- "add L:<line> <message>" → custom comment
- "next" → next file
- "done" → finish review
```

4. **Wait for user input before proceeding**

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
  "https://api.bitbucket.org/2.0/repositories/{workspace}/{repo}/pullrequests/{pr_id}/comments" \
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
  "https://api.bitbucket.org/2.0/repositories/{workspace}/{repo}/pullrequests/{pr_id}/approve"
# or Request changes (post comment)
curl -X POST -u "${BITBUCKET_EMAIL}:${BITBUCKET_API_TOKEN}" \
  "https://api.bitbucket.org/2.0/repositories/{workspace}/{repo}/pullrequests/{pr_id}/comments" \
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

Confirm to the user that their context has been restored.

## Important notes

- Always wait for user input between files
- Keep track of all comments posted for final summary
- If user says "done" at any point, skip to Step 9
- Handle errors gracefully (network issues, auth problems)
- For self-hosted GitLab/GitHub, the API endpoints remain the same but authentication must be configured

Do not use any other tools or do anything else beyond the PR review workflow described above.
