---
allowed-tools: Bash(git bisect:*), Bash(git log:*), Bash(git show:*), Bash(git status:*), Bash(git checkout:*), Read, Grep, Glob
description: Find the commit that introduced a bug using binary search
argument-hint: "[bad-commit] [good-commit]"
---

## Context

- Current branch: !`git branch --show-current`
- Current status: !`git status --short`
- Recent commits: !`git log --oneline -20`

## Your task

Help the user find the commit that introduced a bug using `git bisect`.

Git bisect performs a binary search through commit history to efficiently locate the first bad commit.

### Step 1: Check current state

If already in a bisect session:
```bash
git bisect log
```

If in a bisect, show current state and ask user to test. Otherwise, start a new session.

### Step 2: Start bisect session

Ask the user:
1. **What's the bug?** (description of the issue to look for)
2. **Bad commit** - A commit where the bug exists (default: HEAD)
3. **Good commit** - A commit where the bug doesn't exist (show recent tags/commits to help)

Start the session:
```bash
git bisect start
git bisect bad <bad-commit>
git bisect good <good-commit>
```

Git will checkout a commit in the middle for testing.

### Step 3: Guide the testing process

For each commit git checks out:

1. **Show context**:
```
🔍 Bisect Progress
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📍 Current commit: <hash>
📝 Message: <commit message>
👤 Author: <author> (<date>)
📊 Remaining: ~<N> steps (between <X> commits)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🐛 Bug to find: <user's bug description>

Test this commit and tell me:
- "good" → bug is NOT present
- "bad" → bug IS present
- "skip" → can't test this commit
- "run <command>" → I'll run a test command for you
- "show <file>" → I'll show you a file
- "abort" → cancel bisect
```

2. **Help the user test**:
   - If they need to run a test: execute it and show results
   - If they need to see code: read relevant files
   - If they need to build: help with build commands

3. **Record the result**:
```bash
git bisect good  # or
git bisect bad   # or
git bisect skip
```

4. **Repeat** until git finds the culprit

### Step 4: Show the result

When bisect completes:

```bash
git bisect log
```

Present the findings:
```
🎯 Found the bad commit!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📍 Commit: <full-hash>
📝 Message: <commit message>
👤 Author: <author>
📅 Date: <date>

📄 Files changed:
<list of files>

💡 This commit likely introduced the bug.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Show the commit details:
```bash
git show <bad-commit> --stat
```

Ask user:
- "details" → show full diff of the bad commit
- "blame <file>" → show who changed specific lines
- "revert" → help revert the bad commit
- "done" → end bisect and return to original branch

### Step 5: Clean up

```bash
git bisect reset
```

This returns to the original branch.

### Automated mode

If user provides a test command (e.g., `npm test`, `make test`):

```bash
git bisect run <test-command>
```

The command should exit with:
- 0 = good (test passes)
- 1-124, 126-127 = bad (test fails)
- 125 = skip (can't test)

Example:
```bash
git bisect start HEAD v1.0.0
git bisect run npm test
```

### Tips to share with user

- **Finding a good commit**: Use `git log --oneline` or look at tags with `git tag`
- **Can't test?**: Use `git bisect skip` to skip untestable commits
- **Wrong answer?**: Use `git bisect log` to review, then `git bisect reset` and start over
- **Save session**: `git bisect log > bisect.log` then restore with `git bisect replay bisect.log`

Be conversational and educational. Help the user understand the binary search process and guide them through testing each commit.
