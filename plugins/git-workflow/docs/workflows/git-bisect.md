# /git-bisect

Find the commit that introduced a bug using AI-powered binary search.

```
+-------------------------------------------------------------+
|                      /git-bisect                            |
+-------------------------------------------------------------+
                            |
                            v
+-------------------------------------------------------------+
| 1. GATHER INFO                                              |
|    - What's the bug?                                        |
|    - Bad commit (default: HEAD)                             |
|    - Good commit (tag or older commit)                      |
+-------------------------------------------------------------+
                            |
                            v
+-------------------------------------------------------------+
| 2. CREATE TEST SCRIPT                                       |
|    ./bisect-test.sh                                         |
|      exit 0   -> bug NOT present (good)                     |
|      exit 1   -> bug IS present (bad)                       |
|      exit 125 -> can't test (skip)                          |
|                                                             |
|    User confirms script before continuing                   |
+-------------------------------------------------------------+
                            |
                            v
+-------------------------------------------------------------+
| 3. RUN BISECT                                               |
|    git bisect start <bad> <good>                            |
|    git bisect run ./bisect-test.sh                          |
+-------------------------------------------------------------+
                            |
                            v
+-------------------------------------------------------------+
| 4. SHOW RESULT                                              |
|    +-----------------------------------------------------+  |
|    | Culprit Found                                       |  |
|    | Commit + Message + Author + Date                    |  |
|    | Files changed                                       |  |
|    | Analysis (what likely caused the bug)               |  |
|    | Link to commit                                      |  |
|    +-----------------------------------------------------+  |
+-------------------------------------------------------------+
                            |
                            v
+-------------------------------------------------------------+
| 5. PROPOSE FIX                                              |
|    "Do you want me to fix this bug and create a PR?"        |
+-------------------------------------------------------------+
                            |
              +-------------+-------------+
              |                           |
              v                           v
+-------------------------+   +---------------------------+
| YES                     |   | NO                        |
| - git bisect reset      |   | - git bisect reset        |
| - rm ./bisect-test.sh   |   | - rm ./bisect-test.sh     |
| - git checkout -b fix/  |   +---------------------------+
| - Implement fix         |
| - Verify with test      |
| - /git-commit-push-pr   |
+-------------------------+
```

## Steps

1. **Gather info** - Bug description, bad commit, good commit
2. **Create test script** - Script that returns 0 (good) or 1 (bad)
3. **Run bisect** - Automated binary search through commits
4. **Show result** - Display culprit with analysis
5. **Propose fix** - Optionally fix and create PR
6. **Cleanup** - Reset bisect and remove test script
