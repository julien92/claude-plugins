# /git-clean-branches

Clean up stale local branches.

```
+-------------------------------------------------------------+
|                  /git-clean-branches                        |
+-------------------------------------------------------------+
                            |
                            v
+-------------------------------------------------------------+
| 1. LIST BRANCHES                                            |
|    git branch -v                                            |
|    Identify branches marked [gone]                          |
+-------------------------------------------------------------+
                            |
                            v
+-------------------------------------------------------------+
| 2. CHECK WORKTREES                                          |
|    git worktree list                                        |
|    Identify associated worktrees                            |
+-------------------------------------------------------------+
                            |
                            v
+-------------------------------------------------------------+
| 3. CLEANUP (for each [gone] branch)                         |
|    - Remove worktree if exists                              |
|    - git branch -D <branch>                                 |
+-------------------------------------------------------------+
```

## Steps

1. **List branches** - Find branches marked as [gone]
2. **Check worktrees** - Identify associated worktrees
3. **Cleanup** - Remove worktrees and delete branches
