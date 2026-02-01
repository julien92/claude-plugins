---
allowed-tools: Bash(git:*), Bash(chmod +x ./bisect-test.sh), Bash(rm ./bisect-test.sh), Bash(./bisect-test.sh), Read, Write
description: Find the commit that introduced a bug using AI-powered binary search
argument-hint: "[bad-commit] [good-commit]"
---

## Context

- Current branch: !`git branch --show-current`
- Recent commits: !`git log --oneline -15`
- Tags: !`git tag --sort=-version:refname | head -5`

## Your task

Find the commit that introduced a bug using `git bisect run` with a test script.

### Step 1: Get info from user

Ask:
1. **What's the bug?**
2. **Bad commit** (default: HEAD)
3. **Good commit** (a tag or older commit where it worked)

### Step 2: Create test script

Create `./bisect-test.sh` at repo root:
- Exit 0 → bug **NOT present** (good commit)
- Exit 1 → bug **IS present** (bad commit)
- Exit 125 → can't test (skip)

```bash
#!/bin/bash
# bisect-test.sh - Returns 0 if bug is ABSENT, 1 if PRESENT

<commands to reproduce and check the bug>
```

```bash
chmod +x ./bisect-test.sh
```

**Show the script and confirm with user before continuing.**

### Step 3: Run bisect

```bash
git bisect start <bad> <good>
git bisect run ./bisect-test.sh
```

### Step 4: Show result

Display the culprit commit with `git show` and explain what likely caused the bug.

### Step 5: Cleanup

```bash
git bisect reset
rm ./bisect-test.sh
```

---

## Examples

**API returns 500:**
```bash
#!/bin/bash
npm start &>/dev/null & sleep 2
status=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/api/users)
pkill -f "node.*server" 2>/dev/null
[ "$status" = "200" ]
```

**Test fails:**
```bash
#!/bin/bash
npm test -- --grep "login" --silent
```

**Pattern in code:**
```bash
#!/bin/bash
! grep -r "console.log" src/  # exit 0 if NOT found
```

**Function returns wrong value:**
```bash
#!/bin/bash
node -e "process.exit(require('./src/tax').calc(100) === 20 ? 0 : 1)"
```
