# /git-why

Investigate git history to explain why code exists.

```
+-------------------------------------------------------------+
|                       /git-why                              |
+-------------------------------------------------------------+
                            |
                            v
+-------------------------------------------------------------+
| 1. UNDERSTAND QUESTION                                      |
|    - What to understand? (complexity, workaround, bug)      |
|    - Which file/function/lines?                             |
+-------------------------------------------------------------+
                            |
                            v
+-------------------------------------------------------------+
| 2. INVESTIGATE                                              |
|    - git blame <file>                                       |
|    - git log -p --follow -- <file>                          |
|    - git log -S "<code>" (pickaxe)                          |
|    - git log -L <start>,<end>:<file>                        |
|    - git show <commit>                                      |
+-------------------------------------------------------------+
                            |
                            v
+-------------------------------------------------------------+
| 3. REASON & CONNECT                                         |
|    - Find patterns in evolution                             |
|    - Identify root causes                                   |
|    - Understand intent from messages                        |
|    - Connect related changes                                |
+-------------------------------------------------------------+
                            |
                            v
+-------------------------------------------------------------+
| 4. TELL THE STORY                                           |
|    +-----------------------------------------------------+  |
|    | "This regex evolved over 8 months:"                 |  |
|    |                                                     |  |
|    | 1. a1b2c3 (Alice, March) - Initial \d+ pattern      |  |
|    | 2. d4e5f6 (Bob, May) - Added UUID support           |  |
|    | 3. g7h8i9 (Alice, July) - Bug #234 fix              |  |
|    | 4. j0k1l2 (Charlie, Oct) - Production incident      |  |
|    |                                                     |  |
|    | Complexity = backwards compatibility with 3 formats |  |
|    +-----------------------------------------------------+  |
+-------------------------------------------------------------+
```

## Steps

1. **Understand question** - What does user want to know?
2. **Investigate** - Use git blame, log, pickaxe search
3. **Reason & connect** - Find patterns, root causes, intent
4. **Tell the story** - Explain the evolution as a narrative
