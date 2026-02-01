# /git-pr-review

Review a PR with AI-assisted analysis.

```
+-------------------------------------------------------------+
|                    /git-pr-review                           |
+-------------------------------------------------------------+
                            |
                            v
+-------------------------------------------------------------+
| 1. SAVE CONTEXT                                             |
|    - Store current branch                                   |
|    - git stash (if uncommitted changes)                     |
+-------------------------------------------------------------+
                            |
                            v
+-------------------------------------------------------------+
| 2. DETECT PROVIDER                                          |
|    Auto-detect from remote URL                              |
+-------------------------------------------------------------+
                            |
                            v
+-------------------------------------------------------------+
| 3. LIST & SELECT PR                                         |
|    Show open PRs, user picks one                            |
+-------------------------------------------------------------+
                            |
                            v
+-------------------------------------------------------------+
| 4. CHECKOUT PR                                              |
|    Fetch and checkout PR branch                             |
+-------------------------------------------------------------+
                            |
                            v
+-------------------------------------------------------------+
| 5. GET CHANGED FILES                                        |
|    git diff origin/$BASE...HEAD --name-only                 |
+-------------------------------------------------------------+
                            |
                            v
+-------------------------------------------------------------+
| 6. REVIEW EACH FILE (loop)                                  |
|    +-----------------------------------------------------+  |
|    | [X/Y] file.ts:42 (+N/-M lines)                      |  |
|    | Changes: <diff>                                     |  |
|    | Analysis: <explanation>                             |  |
|    | Suggested comments:                                 |  |
|    |   1. L:47 [security] "Validate input..."            |  |
|    |   2. L:52 [perf] "Consider caching..."              |  |
|    |                                                     |  |
|    | Actions: "1" post, "next" skip, "done" finish       |  |
|    +-----------------------------------------------------+  |
|                                                             |
|    Wait for user input -> post comments -> next file        |
+-------------------------------------------------------------+
                            |
                            v
+-------------------------------------------------------------+
| 7. FINALIZE                                                 |
|    - approve         -> Approve PR                          |
|    - request-changes -> Request changes                     |
|    - comment         -> Comment only                        |
|    - skip            -> No action                           |
+-------------------------------------------------------------+
                            |
                            v
+-------------------------------------------------------------+
| 8. RESTORE CONTEXT                                          |
|    - git checkout <original-branch>                         |
|    - git stash pop (if stashed)                             |
+-------------------------------------------------------------+
                            |
                            v
+-------------------------------------------------------------+
| 9. SUMMARY                                                  |
|    - PR status (approved/changes/commented)                 |
|    - Files reviewed: X/Y                                    |
|    - Comments posted: N                                     |
|    - PR link                                                |
+-------------------------------------------------------------+
```

## Steps

1. **Save context** - Stash changes, remember current branch
2. **Detect provider** - Auto-detect from remote URL
3. **List & select PR** - Show open PRs for selection
4. **Checkout PR** - Switch to PR branch
5. **Get changed files** - List files modified in PR
6. **Review each file** - Analyze and suggest inline comments
7. **Finalize** - Approve, request changes, or comment
8. **Restore context** - Return to original branch
9. **Summary** - Show review summary with PR link
