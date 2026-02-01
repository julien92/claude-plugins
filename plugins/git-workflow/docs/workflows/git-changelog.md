# /git-changelog

Generate a changelog from commits.

```
+-------------------------------------------------------------+
|                    /git-changelog                           |
+-------------------------------------------------------------+
                            |
                            v
+-------------------------------------------------------------+
| 1. DETERMINE RANGE                                          |
|    - From arguments: v1.0.0..v1.1.0                         |
|    - Or use last two tags                                   |
+-------------------------------------------------------------+
                            |
                            v
+-------------------------------------------------------------+
| 2. GET & GROUP COMMITS                                      |
|    git log <range> --pretty=format:"%h|%s|%an"              |
|                                                             |
|    Group by Gitmoji:                                        |
|      Features                                               |
|      Bug Fixes                                              |
|      Documentation                                          |
|      Refactoring                                            |
|      ...                                                    |
|                                                             |
|    Extract contributors                                     |
+-------------------------------------------------------------+
                            |
                            v
+-------------------------------------------------------------+
| 3. OUTPUT                                                   |
|    - Print to console (default)                             |
|    - Prepend to CHANGELOG.md                                |
|    - Copy to clipboard                                      |
+-------------------------------------------------------------+
```

## Steps

1. **Determine range** - From arguments or last two tags
2. **Get & group commits** - Fetch commits and group by type
3. **Output** - Print, save to file, or copy to clipboard
