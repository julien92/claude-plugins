---
allowed-tools: Bash(git bisect:*), Bash(git log:*), Bash(git show:*), Bash(git status:*), Bash(git checkout:*), Bash(git rev-parse:*), Bash(git tag:*), Bash(npm:*), Bash(yarn:*), Bash(pnpm:*), Bash(make:*), Bash(cargo:*), Bash(go:*), Bash(python:*), Bash(pytest:*), Bash(jest:*), Bash(vitest:*), Bash(mvn:*), Bash(gradle:*), Bash(curl:*), Bash(node:*), Bash(bash:*), Bash(sh:*), Bash(chmod:*), Bash(cat:*), Bash(rm:*), Bash(kill:*), Bash(lsof:*), Bash(sleep:*), Bash(timeout:*), Read, Grep, Glob, Write
description: Find the commit that introduced a bug using AI-powered binary search
argument-hint: "[bad-commit] [good-commit]"
---

## Context

- Current branch: !`git branch --show-current`
- Current status: !`git status --short`
- Recent commits: !`git log --oneline -20`
- Available tags: !`git tag --sort=-version:refname | head -10`

## Your task

Help the user find the commit that introduced a bug using `git bisect`. **You will test each commit yourself** by creating test scripts, running commands, calling APIs, or inspecting code.

### Step 1: Understand the bug

Ask the user:
1. **What's the bug?** - Detailed description of the issue
2. **How to reproduce it?** - Get the complete reproduction scenario:
   - What commands to run?
   - What API endpoints to call?
   - What input data triggers the bug?
   - What's the expected vs actual behavior?

3. **Bad commit** - Where the bug exists (default: HEAD)
4. **Good commit** - Where the bug didn't exist (suggest recent tags or commits)

### Step 2: Create your test script

Based on the reproduction scenario, **create a temporary test script** at `/tmp/bisect-test.sh` that:
- Returns exit code 0 if bug is **NOT present** (good)
- Returns exit code 1 if bug **IS present** (bad)
- Returns exit code 125 if **cannot test** (skip)

```bash
#!/bin/bash
# /tmp/bisect-test.sh - Auto-generated bisect test

# Setup (install deps, build, start server, etc.)
<setup commands>

# Test the bug
<test commands>

# Cleanup
<cleanup commands>

# Exit based on result
```

Make the script executable:
```bash
chmod +x /tmp/bisect-test.sh
```

**Always show the script to the user and ask for confirmation before starting.**

### Step 3: Start bisect

```bash
git bisect start
git bisect bad <bad-commit>
git bisect good <good-commit>
```

Note the total number of commits and estimated steps.

### Step 4: Automated testing loop

For each commit git checks out, **run your test script**:

1. **Show progress**:
```
🔍 Bisect Progress [Step N/~M]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📍 Commit: <short-hash>
📝 Message: <commit message>
👤 Author: <author> (<relative date>)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🧪 Running test script...
```

2. **Execute the test**:
```bash
/tmp/bisect-test.sh
```

3. **Show result and output**:
```
✅ GOOD (exit 0) - Bug not present
   → <relevant output snippet>
```
or
```
❌ BAD (exit 1) - Bug is present
   → <relevant output snippet>
```
or
```
⏭️ SKIP (exit 125) - Cannot test
   → <reason from script>
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
rm -f /tmp/bisect-test.sh
```

Return to original branch and remove temporary files.

---

## Test Script Examples

### Example 1: API endpoint returns wrong status code

**Bug:** "POST /api/users returns 500 instead of 201"

```bash
#!/bin/bash
# /tmp/bisect-test.sh

# Setup: install deps and start server
npm install --silent 2>/dev/null
npm run build --silent 2>/dev/null
npm start &>/dev/null &
SERVER_PID=$!
sleep 3

# Test: check API response
STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
  -X POST http://localhost:3000/api/users \
  -H "Content-Type: application/json" \
  -d '{"name": "test", "email": "test@example.com"}')

# Cleanup
kill $SERVER_PID 2>/dev/null

# Evaluate
if [ "$STATUS" = "201" ]; then
  echo "✓ API returns 201 as expected"
  exit 0  # GOOD
elif [ "$STATUS" = "500" ]; then
  echo "✗ API returns 500 - bug present"
  exit 1  # BAD
else
  echo "? Unexpected status: $STATUS"
  exit 125  # SKIP
fi
```

### Example 2: Function returns incorrect value

**Bug:** "calculateTax(100) should return 20, but returns 15"

```bash
#!/bin/bash
# /tmp/bisect-test.sh

# Create a test file
cat > /tmp/bisect-runner.js << 'EOF'
const { calculateTax } = require('./src/utils/tax');
const result = calculateTax(100);
console.log(`calculateTax(100) = ${result}`);
process.exit(result === 20 ? 0 : 1);
EOF

# Run the test
node /tmp/bisect-runner.js
EXIT_CODE=$?

# Cleanup
rm /tmp/bisect-runner.js

exit $EXIT_CODE
```

### Example 3: Memory leak detection

**Bug:** "Server memory grows unbounded after 100 requests"

```bash
#!/bin/bash
# /tmp/bisect-test.sh

npm install --silent 2>/dev/null
npm start &>/dev/null &
SERVER_PID=$!
sleep 3

# Get initial memory
MEM_BEFORE=$(ps -o rss= -p $SERVER_PID)

# Make 100 requests
for i in {1..100}; do
  curl -s http://localhost:3000/api/data > /dev/null
done

# Get final memory
MEM_AFTER=$(ps -o rss= -p $SERVER_PID)
MEM_GROWTH=$((MEM_AFTER - MEM_BEFORE))

kill $SERVER_PID 2>/dev/null

echo "Memory: ${MEM_BEFORE}KB → ${MEM_AFTER}KB (+${MEM_GROWTH}KB)"

# Fail if memory grew more than 50MB
if [ $MEM_GROWTH -gt 51200 ]; then
  echo "✗ Memory leak detected"
  exit 1  # BAD
else
  echo "✓ Memory stable"
  exit 0  # GOOD
fi
```

### Example 4: Database query regression

**Bug:** "User search query takes >2s instead of <100ms"

```bash
#!/bin/bash
# /tmp/bisect-test.sh

# Setup database and app
docker-compose up -d db 2>/dev/null
npm run db:seed --silent 2>/dev/null
npm start &>/dev/null &
SERVER_PID=$!
sleep 5

# Measure query time
START=$(date +%s%N)
curl -s "http://localhost:3000/api/users/search?q=john" > /dev/null
END=$(date +%s%N)
DURATION_MS=$(( (END - START) / 1000000 ))

# Cleanup
kill $SERVER_PID 2>/dev/null
docker-compose down 2>/dev/null

echo "Query took ${DURATION_MS}ms"

if [ $DURATION_MS -lt 500 ]; then
  echo "✓ Query is fast"
  exit 0  # GOOD
else
  echo "✗ Query is slow - regression detected"
  exit 1  # BAD
fi
```

### Example 5: CLI output changed

**Bug:** "The --version flag shows 'undefined' instead of version number"

```bash
#!/bin/bash
# /tmp/bisect-test.sh

npm install --silent 2>/dev/null
OUTPUT=$(npm run cli -- --version 2>&1)

echo "Output: $OUTPUT"

if echo "$OUTPUT" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$'; then
  echo "✓ Version format correct"
  exit 0  # GOOD
elif echo "$OUTPUT" | grep -q 'undefined'; then
  echo "✗ Shows 'undefined'"
  exit 1  # BAD
else
  echo "? Unexpected output"
  exit 125  # SKIP
fi
```

### Example 6: React component rendering bug

**Bug:** "Login button is disabled even when form is valid"

```bash
#!/bin/bash
# /tmp/bisect-test.sh

npm install --silent 2>/dev/null
npm run build --silent 2>/dev/null

# Run component test
npm test -- --testPathPattern="Login" --silent 2>&1
EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
  echo "✓ Login tests pass"
  exit 0  # GOOD
else
  echo "✗ Login tests fail"
  exit 1  # BAD
fi
```

### Example 7: Python import error

**Bug:** "Importing the auth module raises ImportError"

```bash
#!/bin/bash
# /tmp/bisect-test.sh

# Try to import the module
python3 -c "from app.auth import authenticate; print('Import OK')" 2>&1
EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
  echo "✓ Import successful"
  exit 0  # GOOD
else
  echo "✗ Import failed"
  exit 1  # BAD
fi
```

### Example 8: Code pattern that shouldn't exist

**Bug:** "Someone committed AWS credentials in the code"

```bash
#!/bin/bash
# /tmp/bisect-test.sh

# Search for AWS access key pattern
if grep -rE 'AKIA[0-9A-Z]{16}' --include="*.ts" --include="*.js" src/; then
  echo "✗ AWS credentials found in code!"
  exit 1  # BAD
else
  echo "✓ No credentials found"
  exit 0  # GOOD
fi
```

---

## Important notes

- **Always create a test script** - even for simple checks, a script ensures consistency
- **Show the script to user** - get confirmation before running on potentially many commits
- **Handle setup/cleanup** - ensure servers are started/stopped, temp files removed
- **Use timeouts** - prevent hanging on broken builds: `timeout 60 npm test`
- **Exit codes matter**: 0=good, 1=bad, 125=skip (can't test this commit)
- If a commit can't be tested (missing dependencies, won't compile), return exit 125
- Keep the user informed of progress but don't wait for input between tests
- For very long bisects (>10 steps), give periodic summaries
- **Clean up at the end** - remove `/tmp/bisect-test.sh` and any other temp files
