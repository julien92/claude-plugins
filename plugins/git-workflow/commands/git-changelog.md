---
allowed-tools: Bash(git tag:*), Bash(git log:*), Read, Write
description: Generate a changelog from commits between two tags
argument-hint: "[from..to]"
---

## Context

- Available tags: !`git tag --sort=-version:refname | head -10`
- Current branch: !`git branch --show-current`

## Your task

Generate a changelog from Git commits, grouped by type.

If arguments provided (e.g., `v1.0.0..v1.1.0`), use that range. Otherwise, use the last two tags.

Get commits in range:
```bash
git log $RANGE --pretty=format:"%h|%s|%an" --reverse
```

Group commits by Gitmoji:
- ✨ Features (✨)
- 🐛 Bug Fixes (🐛)
- 📝 Documentation (📝)
- 🔧 Configuration (🔧)
- ♻️ Refactoring (♻️)
- ✅ Tests (✅)
- 🎨 Style (🎨)
- ⚡ Performance (⚡)
- 🔥 Removed (🔥)
- 🚀 Deployment (🚀)

Generate output in this format:

```markdown
# Changelog

## [v1.1.0] - YYYY-MM-DD

### ✨ Features
- Add OAuth2 login support

### 🐛 Bug Fixes
- Fix null pointer in user service

### 👥 Contributors
- @author1
```

Ask the user:
1. Print to console (default)
2. Prepend to CHANGELOG.md
3. Copy to clipboard
