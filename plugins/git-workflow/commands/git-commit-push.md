---
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*), Bash(git push:*), Read
description: Create a git commit with Gitmoji and push
disable-model-invocation: true
---

## Context

- Current git status: !`git status`
- Current git diff (staged and unstaged): !`git diff HEAD`
- Current branch: !`git branch --show-current`
- Recent commits: !`git log --oneline -10`

## Your task

Based on the above changes:

1. Read the Gitmoji conventions from `commands/_shared/gitmoji-conventions.md` (relative to the plugin root)
2. Stage all changes if nothing is staged
3. Create a single commit following the Gitmoji conventions
4. Push to remote

You have the capability to call multiple tools in a single response. You MUST do all of the above in a single message. Do not use any other tools or do anything else.
