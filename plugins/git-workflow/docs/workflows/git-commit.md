# /git-commit

Create a commit with Gitmoji conventions.

```
+-------------------------------------+
|           /git-commit               |
+-------------------------------------+
                  |
                  v
+-------------------------------------+
| 1. STAGE                            |
|    git add (if nothing staged)      |
+-------------------------------------+
                  |
                  v
+-------------------------------------+
| 2. COMMIT                           |
|    - Gitmoji + message              |
|    - Detailed description           |
|    - Refs: TICKET-123 (from branch) |
+-------------------------------------+
```

## Steps

1. **Stage** - Add all changes if nothing is staged
2. **Commit** - Create commit with Gitmoji conventions
   - First line: emoji + short description
   - Body: detailed changes
   - Footer: ticket reference if found in branch name
