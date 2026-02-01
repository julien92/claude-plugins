# /git-commit-push-pr

Full workflow: commit, push, and create PR.

```
+-------------------------------------+
|      /git-commit-push-pr            |
+-------------------------------------+
                  |
                  v
+-------------------------------------+
| 1. DETECT PARENT BRANCH             |
|    On main/master/develop?          |
|      -> Create feature branch       |
|    On feature branch?               |
|      -> Find parent via merge-base  |
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
|    git push -u origin <branch>      |
+-------------------------------------+
                  |
                  v
+-------------------------------------+
| 4. CREATE PR                        |
|    Target: parent branch            |
|    Auto-detect git provider         |
+-------------------------------------+
```

## Steps

1. **Detect parent branch**
   - If on main/master/develop: create a new feature branch
   - If on feature branch: find parent using merge-base
2. **Commit** - Create commit with Gitmoji conventions
3. **Push** - Push branch to remote with tracking
4. **Create PR** - Open pull request targeting the parent branch
