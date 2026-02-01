---
allowed-tools: Bash(git bisect:*), Bash(git log:*), Bash(git show:*), Bash(git status:*), Bash(git checkout:*), Bash(git rev-parse:*), Bash(git tag:*), Bash(npm:*), Bash(yarn:*), Bash(pnpm:*), Bash(make:*), Bash(cargo:*), Bash(go:*), Bash(python:*), Bash(pytest:*), Bash(jest:*), Bash(vitest:*), Bash(mvn:*), Bash(gradle:*), Read, Grep, Glob
description: Find the commit that introduced a bug using AI-powered binary search
argument-hint: "[bad-commit] [good-commit]"
---

## Context

- Current branch: !`git branch --show-current`
- Current status: !`git status --short`
- Recent commits: !`git log --oneline -20`
- Available tags: !`git tag --sort=-version:refname | head -10`

## Your task

Help the user find the commit that introduced a bug using `git bisect`. **You will test each commit yourself** by reading code, running tests, or executing verification commands.

### Step 1: Understand the bug

Ask the user:
1. **What's the bug?** - Detailed description of the issue
2. **How can you verify it?** - Ask for ONE of these:
   - A test command that fails when bug is present (e.g., `npm test -- --grep "login"`)
   - A file + condition to check (e.g., "function X should not call Y")
   - A code pattern that shouldn't exist (e.g., "there should be no `eval()` in auth.js")
   - A runtime check (e.g., "the server should return 200 on /health")

3. **Bad commit** - Where the bug exists (default: HEAD)
4. **Good commit** - Where the bug didn't exist (suggest recent tags or commits)

### Step 2: Define your test strategy

Based on user input, define how YOU will test each commit:

**Strategy A: Test Command**
```
I'll run: <command>
- Exit 0 (pass) → commit is GOOD
- Exit non-zero (fail) → commit is BAD
```

**Strategy B: Code Inspection**
```
I'll check: <file(s)>
- Condition: <what to look for>
- If condition met → commit is BAD
- If condition not met → commit is GOOD
```

**Strategy C: Pattern Search**
```
I'll search for: <pattern>
- Found → commit is BAD
- Not found → commit is GOOD
```

**Strategy D: Combined**
```
I'll run <command> AND check <file> for <condition>
```

Confirm the strategy with the user before starting.

### Step 3: Start bisect

```bash
git bisect start
git bisect bad <bad-commit>
git bisect good <good-commit>
```

Note the total number of commits and estimated steps.

### Step 4: Automated testing loop

For each commit git checks out, **YOU test it**:

1. **Show progress**:
```
🔍 Bisect Progress [Step N/~M]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📍 Commit: <short-hash>
📝 Message: <commit message>
👤 Author: <author> (<relative date>)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🧪 Testing...
```

2. **Execute your test strategy**:
   - Run the test command, OR
   - Read the file(s) and check the condition, OR
   - Search for the pattern

3. **Show result and reasoning**:
```
✅ GOOD - <brief explanation>
   → Bug not present: <why>
```
or
```
❌ BAD - <brief explanation>
   → Bug present: <why>
```
or
```
⏭️ SKIP - <brief explanation>
   → Cannot test: <why>
```

4. **Mark the commit**:
```bash
git bisect good   # or bad, or skip
```

5. **Repeat** until bisect completes

### Step 5: Present the culprit

When found:

```
🎯 Found the culprit!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📍 Commit: <full-hash>
📝 Message: <commit message>
👤 Author: <author>
📅 Date: <date>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📄 Files changed:
<list files with +/- lines>

🔬 Analysis:
<Explain what this commit changed that likely introduced the bug>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Show the diff:
```bash
git show <culprit-hash> --stat
```

### Step 6: Suggest next steps

Ask the user:
- **"show diff"** → Full diff of the bad commit
- **"explain"** → Detailed analysis of what went wrong
- **"fix"** → Help create a fix
- **"revert"** → Help revert the commit
- **"done"** → End bisect

### Step 7: Clean up

```bash
git bisect reset
```

Return to original branch.

---

## Test Strategy Examples

### Example 1: Unit test failure
```
User: "The login test started failing"
Strategy: Run `npm test -- --grep "login"`
- Pass → GOOD
- Fail → BAD
```

### Example 2: Code pattern introduced
```
User: "Someone added console.log in production code"
Strategy: Search for `console\.log` in `src/`
- Found → BAD
- Not found → GOOD
```

### Example 3: Function behavior changed
```
User: "validateEmail() used to reject emails without TLD"
Strategy: Read `src/validators.ts`, check if validateEmail rejects "user@localhost"
- Rejects → GOOD
- Accepts → BAD
```

### Example 4: Build breakage
```
User: "The TypeScript build started failing"
Strategy: Run `npm run build`
- Exit 0 → GOOD
- Exit non-zero → BAD
```

### Example 5: File should exist
```
User: "The migration file got deleted somehow"
Strategy: Check if `db/migrations/001_init.sql` exists
- Exists → GOOD
- Missing → BAD
```

---

## Important notes

- Always test commits yourself - don't ask the user to test
- If a commit can't be tested (missing dependencies, won't compile), use `git bisect skip`
- Keep the user informed of progress but don't wait for input between tests
- If test strategy is ambiguous, clarify with user before starting
- For very long bisects (>10 steps), give periodic summaries
