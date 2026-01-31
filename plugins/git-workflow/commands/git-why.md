---
allowed-tools: Bash(git blame:*), Bash(git log:*), Bash(git show:*), Read, Grep, Glob
description: Understand WHY code exists - AI-powered git archaeology
---

## Context

- Current branch: !`git branch --show-current`
- Repo root: !`git rev-parse --show-toplevel`

## Your task

Help the user understand **WHY** code exists, not just WHO wrote it.

You are a code archaeologist. Your job is to investigate git history and tell the story of the code.

### Step 1: Understand the question

Ask the user:
- What do they want to understand? (why this complexity, why this workaround, why this bug, etc.)
- Which file/function/lines are concerned?

If the user already provided context, skip to investigation.

### Step 2: Investigate

Use git commands to collect history. Choose what's relevant:

```bash
# Who touched which lines and when
git blame <file>

# Full history of a file with diffs (limit to avoid noise)
git log -n 30 -p --follow -- <file>

# Search commits by keyword (function name, bug description, etc.)
git log --all --grep="<keyword>"

# Find when specific code was added or removed (pickaxe search)
git log -S "<code_snippet>" --oneline -- <file>

# Inspect a specific commit in detail
git show <commit>

# History of specific lines
git log -L <start>,<end>:<file>
```

Read the file content if needed to understand the current state.

### Step 3: Reason and connect

This is where you add real value:

- **Don't just list commits** - EXPLAIN the evolution
- **Find patterns**: initial implementation → bug fix → broke something else → fixed again
- **Identify the ROOT CAUSE**, not just symptoms
- **Understand the INTENT** behind each change from commit messages
- **Connect the dots** between seemingly unrelated changes

### Step 4: Tell the story

Explain clearly:
- **WHY** the code is the way it is today
- **The journey** from original to current state
- **Key decisions** and their context
- **The people** involved and their reasoning (from commit messages)

Format your response as a narrative, not a list. Help the user truly understand the history.

If you discover potential improvements or issues during your investigation, mention them at the end.

### Example

**User**: "Why is this regex so complex?" (pointing to a validation function)

**Good response**:
> This regex evolved over 8 months through 4 commits:
>
> 1. **Initial version (a1b2c3, Alice, March)** - Simple `\d+` pattern for numeric IDs
> 2. **UUID support (d4e5f6, Bob, May)** - Product team migrated to UUIDs, pattern extended
> 3. **Legacy fix (g7h8i9, Alice, July)** - Bug #234: old records had dashes, added optional group
> 4. **Edge case (j0k1l2, Charlie, October)** - Production incident: some IDs had underscores
>
> The complexity comes from **backwards compatibility** with 3 different ID formats.
> Consider: split into separate validators or document the supported formats.
