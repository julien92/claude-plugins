---
allowed-tools: Bash(git checkout -b:*), Bash(git add:*), Bash(git status:*), Bash(git diff:*), Bash(git push:*), Bash(git commit:*), Bash(git remote:*), Bash(git branch:*), Bash(git log:*), Bash(git ls-remote:*), Bash(git merge-base:*), Bash(git rev-parse:*), Bash(git reflog:*), Bash(gh pr create:*), Bash(glab mr create:*), Bash(curl:*)
description: Commit, push and create a Pull Request targeting the parent branch (GitHub/GitLab/Bitbucket)
disable-model-invocation: true
---

## Context

- Current git status: !`git status`
- Current git diff (staged and unstaged): !`git diff HEAD`
- Current branch: !`git branch --show-current`
- Remote URL: !`git remote get-url origin`
- Remote branches: !`git branch -r`

## Your task

Based on the above changes:

1. Determine the parent branch and create a new branch if needed (see below)
2. Create a single commit following the Gitmoji conventions (see commit-message skill)
3. Push the branch to origin
4. Create a pull request targeting the parent branch

## Detect provider

Detect from remote URL first:
- Contains `github.com` → GitHub
- Contains `gitlab.com` → GitLab
- Contains `bitbucket.org` → Bitbucket

If URL doesn't match (self-hosted), fall back to `$GIT_PROVIDER` env var.

## Detect parent branch

**Case 1: Currently on main/master/develop**
- Create a new feature branch
- The parent branch is the current branch (main/master/develop) — you already know it!

**Case 2: Already on a feature branch**
- No need to create a new branch
- Detect the parent branch using merge-base strategy:

```bash
PARENT_BRANCH=""
BEST_COUNT=999999

for branch in develop main master; do
  if git rev-parse --verify "origin/$branch" >/dev/null 2>&1; then
    MERGE_BASE=$(git merge-base "origin/$branch" HEAD 2>/dev/null)
    if [ -n "$MERGE_BASE" ]; then
      COUNT=$(git rev-list --count "$MERGE_BASE"..HEAD 2>/dev/null || echo 999999)
      if [ "$COUNT" -lt "$BEST_COUNT" ]; then
        BEST_COUNT=$COUNT
        PARENT_BRANCH=$branch
      fi
    fi
  fi
done

PARENT_BRANCH=${PARENT_BRANCH:-main}
```

The PR will target `origin/$PARENT_BRANCH`.

## GitHub PR

```bash
gh pr create --title "$(git log -1 --pretty=%s)" --body "$(git log -1 --pretty=%b)" --base <PARENT_BRANCH>
```

Replace `<PARENT_BRANCH>` with the detected parent branch.

## GitLab MR

```bash
glab mr create --title "$(git log -1 --pretty=%s)" --description "$(git log -1 --pretty=%b)" --target-branch <PARENT_BRANCH>
```

Replace `<PARENT_BRANCH>` with the detected parent branch.

## Bitbucket PR

Extract workspace and repo from remote URL:
- `git@bitbucket.org:workspace/repo.git` → workspace, repo
- `https://bitbucket.org/workspace/repo.git` → workspace, repo
- `https://user@bitbucket.org/workspace/repo.git` → workspace, repo

Create PR with curl (Basic Auth with BITBUCKET_EMAIL:BITBUCKET_API_TOKEN):
```bash
curl --silent --request POST \
  --url "https://api.bitbucket.org/2.0/repositories/{workspace}/{repo}/pullrequests" \
  --user "${BITBUCKET_EMAIL}:${BITBUCKET_API_TOKEN}" \
  --header 'Content-Type: application/json' \
  --data '{
    "title": "<first line of commit message>",
    "source": {"branch": {"name": "<current-branch>"}},
    "destination": {"branch": {"name": "<PARENT_BRANCH>"}},
    "close_source_branch": true
  }'
```

Replace `<PARENT_BRANCH>` with the detected parent branch.

The PR URL is in the response at `.links.html.href`

You have the capability to call multiple tools in a single response. You MUST do all of the above in a single message. Do not use any other tools or do anything else.
