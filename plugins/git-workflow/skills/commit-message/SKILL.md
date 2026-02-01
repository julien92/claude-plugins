---
name: commit-message
description: Conventions for writing git commit messages with Gitmoji emojis - use when creating commits
---

# Gitmoji Commit Conventions

## Commit format

1. First line: Gitmoji + short description (< 50 chars)
2. Blank line
3. Detailed description listing significant changes
4. Write concisely using an informal tone
5. Do not use specific names or files from the code
6. Do not use phrases like "this commit", "this change", etc.
7. If branch contains a ticket reference (e.g. `JIRA-123`, `PROJ-456`), add it as a footer: `Refs: JIRA-123`

## Common Gitmojis

See https://gitmoji.dev for full list.

| Emoji | Code | Description |
|-------|------|-------------|
| ✨ | `:sparkles:` | New feature |
| 🐛 | `:bug:` | Bug fix |
| 📝 | `:memo:` | Documentation |
| 🎨 | `:art:` | Style/format |
| ♻️ | `:recycle:` | Refactor |
| ✅ | `:white_check_mark:` | Tests |
| 🔧 | `:wrench:` | Configuration |
| ⚡ | `:zap:` | Performance |
| 🚀 | `:rocket:` | Deploy |
| 🔥 | `:fire:` | Remove code/files |
| 🚧 | `:construction:` | Work in progress |
| 💥 | `:boom:` | Breaking change |
| ⏪️ | `:rewind:` | Revert |

## Example

Branch: `feature/JIRA-123-auth`

```
✨ Add user authentication

- Implement OAuth2 flow
- Add session management
- Handle token refresh

Refs: JIRA-123
```
