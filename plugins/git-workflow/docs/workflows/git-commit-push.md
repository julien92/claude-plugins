# /git-commit-push

Commit and push in one command.

```
+-------------------------------------+
|        /git-commit-push             |
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
|    Gitmoji conventions              |
+-------------------------------------+
                  |
                  v
+-------------------------------------+
| 3. PUSH                             |
|    git push origin <branch>         |
+-------------------------------------+
```

## Steps

1. **Stage** - Add all changes if nothing is staged
2. **Commit** - Create commit with Gitmoji conventions
3. **Push** - Push to remote origin
