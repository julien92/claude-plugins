---
allowed-tools: Bash(git checkout -b:*), Bash(git add:*), Bash(git status:*), Bash(git diff:*), Bash(git push:*), Bash(git commit:*), Bash(git remote:*), Bash(git branch:*), Bash(git log:*), Bash(git ls-remote:*), Bash(gh pr create:*), Bash(glab mr create:*), Bash(curl:*)
description: Commit, push and create a Pull Request (GitHub/GitLab/Bitbucket)
---

## Context

- Current git status: !`git status`
- Current git diff (staged and unstaged): !`git diff HEAD`
- Current branch: !`git branch --show-current`
- Remote URL: !`git remote get-url origin`

## Your task

Based on the above changes:

1. Create a new branch if on main/master/develop
2. Create a single commit using Gitmoji format (see /git-commit for conventions)
3. Push the branch to origin
4. Create a pull request

## Detect provider

Detect from remote URL first:
- Contains `github.com` → GitHub
- Contains `gitlab.com` → GitLab
- Contains `bitbucket.org` → Bitbucket

If URL doesn't match (self-hosted), fall back to `$GIT_PROVIDER` env var.

## GitHub PR

```bash
gh pr create --title "$(git log -1 --pretty=%s)" --fill
```

## GitLab MR

```bash
glab mr create --title "$(git log -1 --pretty=%s)" --fill
```

## Bitbucket PR

Extract workspace and repo from remote URL:
- `git@bitbucket.org:workspace/repo.git` → workspace, repo
- `https://bitbucket.org/workspace/repo.git` → workspace, repo
- `https://user@bitbucket.org/workspace/repo.git` → workspace, repo

Determine destination branch (use `develop` if exists, otherwise `main`):
```bash
git ls-remote --heads origin develop | grep -q develop && echo develop || echo main
```

Create PR with curl (Basic Auth with BITBUCKET_EMAIL:BITBUCKET_API_TOKEN):
```bash
curl --silent --request POST \
  --url "https://api.bitbucket.org/2.0/repositories/{workspace}/{repo}/pullrequests" \
  --user "${BITBUCKET_EMAIL}:${BITBUCKET_API_TOKEN}" \
  --header 'Content-Type: application/json' \
  --data '{
    "title": "<first line of commit message>",
    "source": {"branch": {"name": "<current-branch>"}},
    "destination": {"branch": {"name": "<main or develop>"}},
    "close_source_branch": true
  }'
```

The PR URL is in the response at `.links.html.href`

You have the capability to call multiple tools in a single response. You MUST do all of the above in a single message. Do not use any other tools or do anything else.
