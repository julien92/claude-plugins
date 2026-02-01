---
allowed-tools: Bash(git:*), Bash(chmod +x ./bisect-test.sh), Bash(rm ./bisect-test.sh), Bash(./bisect-test.sh), Read, Write, Edit
description: Find the commit that introduced a bug using AI-powered binary search
argument-hint: "[bad-commit] [good-commit]"
---

## Context

- Current branch: !`git branch --show-current`
- Recent commits: !`git log --oneline -15`
- Tags: !`git tag --sort=-version:refname | head -5`

## Instructions

Find the commit that introduced a bug using `git bisect run` with a test script.

### 1. Gather information

Ask the user:
1. What's the bug?
2. Bad commit (default: HEAD)
3. Good commit (a tag or older commit where it worked)

### 2. Create test script

Create `./bisect-test.sh` at repo root:
- Exit 0 → bug **NOT present** (good commit)
- Exit 1 → bug **IS present** (bad commit)
- Exit 125 → can't test (skip)

Show the script to user and get confirmation before continuing.

### 3. Run bisect

```bash
chmod +x ./bisect-test.sh
git bisect start <bad> <good>
git bisect run ./bisect-test.sh
```

### 4. Show result

Display the culprit commit with this format:

```
🎯 Culprit Found
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📍 Commit:  <short-hash> (<full-hash>)
📝 Message: <commit message>
👤 Author:  <name> <<email>>
📅 Date:    <date> (<relative>)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📁 Files changed:
   <list with +/- lines>

🔬 Analysis:
   <explain what likely caused the bug based on the diff>

🔗 <link to commit>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Use `git show <hash> --stat` and `git remote get-url origin` to build the link.

### 5. Propose fix

Ask user: "Do you want me to fix this bug and create a PR?"

If yes:
1. Reset bisect and cleanup: `git bisect reset && rm ./bisect-test.sh`
2. Create fix branch: `git checkout -b fix/<short-description>`
3. Implement the fix
4. Run the test script to verify fix works
5. Use `/git-commit-push-pr` to commit, push and create PR

### 6. Cleanup (if user declined fix)

```bash
git bisect reset
rm ./bisect-test.sh
```

---

## Script examples

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
