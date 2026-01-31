---
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*)
description: Create a git commit with Gitmoji
---

## Context

- Current git status: !`git status`
- Current git diff (staged and unstaged): !`git diff HEAD`
- Current branch: !`git branch --show-current`
- Recent commits: !`git log --oneline -10`

## Your task

Based on the above changes, create a single git commit.

1. Stage all changes if nothing is staged
2. Create a commit following this convention:
   - First line: Gitmoji + short description (< 50 chars)
   - Blank line
   - Detailed description listing significant changes
   - Write concisely using an informal tone
   - Do not use specific names or files from the code
   - Do not use phrases like "this commit", "this change", etc.

Common Gitmojis (see https://gitmoji.dev for full list):
- ✨ New feature
- 🐛 Bug fix
- 📝 Documentation
- 🎨 Style/format
- ♻️ Refactor
- ✅ Tests
- 🔧 Configuration
- ⚡ Performance
- 🚀 Deploy
- 🔥 Remove code/files
- 🚧 Work in progress
- 💥 Breaking change
- ⏪️ Revert

Example:
```
✨ Add user authentication

- Implement OAuth2 flow
- Add session management
- Handle token refresh
```

You have the capability to call multiple tools in a single response. Stage and create the commit using a single message. Do not use any other tools or do anything else.
