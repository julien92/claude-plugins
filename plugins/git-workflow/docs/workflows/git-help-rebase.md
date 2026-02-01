# /git-help-rebase

Interactive assistant to resolve rebase conflicts.

```
+-------------------------------------------------------------+
|                   /git-help-rebase                          |
+-------------------------------------------------------------+
                            |
                            v
+-------------------------------------------------------------+
| 1. ANALYZE CURRENT STATE                                    |
|    - git status                                             |
|    - Identify conflicted files                              |
|    - Understand rebase progress                             |
+-------------------------------------------------------------+
                            |
                            v
+-------------------------------------------------------------+
| 2. FOR EACH CONFLICT (loop)                                 |
|    +-----------------------------------------------------+  |
|    | Show both versions:                                 |  |
|    |   OURS   (current branch)                           |  |
|    |   THEIRS (incoming changes)                         |  |
|    |                                                     |  |
|    | Explain what each version does                      |  |
|    | Suggest resolution                                  |  |
|    +-----------------------------------------------------+  |
|                                                             |
|    User chooses -> Apply resolution -> git add              |
+-------------------------------------------------------------+
                            |
                            v
+-------------------------------------------------------------+
| 3. CONTINUE REBASE                                          |
|    git rebase --continue                                    |
|                                                             |
|    If more conflicts -> back to step 2                      |
+-------------------------------------------------------------+
                            |
                            v
+-------------------------------------------------------------+
| 4. COMPLETE                                                 |
|    Rebase finished successfully                             |
+-------------------------------------------------------------+
```

## Steps

1. **Analyze** - Check git status and identify conflicts
2. **Resolve conflicts** - For each conflict:
   - Show OURS vs THEIRS
   - Explain both versions
   - Suggest resolution
   - Apply chosen resolution
3. **Continue rebase** - Run `git rebase --continue`
4. **Complete** - Rebase finished
