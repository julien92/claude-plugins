---
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(git rebase:*), Bash(git checkout:*), Bash(git add:*), Read, Write, Edit
description: Help resolve git rebase conflicts interactively - use when user is stuck in a rebase or has merge conflicts
---

## Context

- Current git status: !`git status`
- Conflicting files: !`git diff --name-only --diff-filter=U 2>/dev/null || echo "No conflicts"`

## Your task

Help the user resolve Git rebase conflicts interactively.

If not in a rebase, offer to start one with `git rebase <branch>`.

If in a rebase, for each conflicting file:

1. Read the file and find conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`)

2. Explain both versions:
   - HEAD (current branch): what your changes do
   - Incoming (rebase source): what the other branch changed

3. Suggest resolution:
   - Keep ours: `git checkout --ours <file>`
   - Keep theirs: `git checkout --theirs <file>`
   - Merge both: edit the file to combine changes

4. After user decides, apply the resolution and stage:
   ```bash
   git add <file>
   ```

When all conflicts resolved:
```bash
git rebase --continue
```

If user wants to abort:
```bash
git rebase --abort
```

Be conversational and educational. Explain *why* the conflict happened and help the user understand both versions before choosing.
