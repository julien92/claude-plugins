---
name: plugin-cache
description: Git-workflow plugin cache management. Use when Provider cache shows "not cached" to detect and cache the git provider. Also use to understand cache format or refresh cached values.
---

# Git-workflow Plugin Cache

This skill manages the provider cache for git-workflow commands. The cache stores auto-detected provider information to avoid re-detection on each command.

## When to use this skill

- Provider cache shows "not cached" in a command's Context
- User asks to refresh or reset the git provider detection
- User switches remote or needs to change the cached provider
- Understanding cache format for debugging

## Cache location

The cache file is stored **in the current repository**, not in the user's home directory:

```
<repository-root>/.claude/jc-marketplace/git-workflow/cache.md
```

**IMPORTANT:** This is a project-local file (`.claude/` relative to the git repository root), NOT `~/.claude/` in the home directory.

## Cache format

```yaml
---
provider: github|gitlab|bitbucket
bitbucket_workspace: <workspace>  # Bitbucket only
bitbucket_repo: <repo>            # Bitbucket only
---

# Git Workflow Cache

Auto-detected on <date>.
Provider: **<provider>**
```

## Creating the cache

### Step 1: Detect provider from Remote URL

| URL contains | Provider |
|--------------|----------|
| `github` | `github` |
| `gitlab` | `gitlab` |
| `bitbucket` | `bitbucket` |
| none of the above | Ask user to choose |

### Step 2: Extract Bitbucket info (if applicable)

For Bitbucket, extract workspace and repo from the remote URL:

| URL format | Workspace | Repo |
|------------|-----------|------|
| `git@bitbucket.org:myworkspace/myrepo.git` | `myworkspace` | `myrepo` |
| `https://bitbucket.org/myworkspace/myrepo.git` | `myworkspace` | `myrepo` |

### Step 3: Create cache directory and write file

**CRITICAL: The exact path must be `.claude/jc-marketplace/git-workflow/cache.md`**

Do NOT use:
- `~/.claude/...` (home directory)
- `.claude/cache.md` (missing subdirectories)
- `.claude/git-workflow.local.md` (wrong filename)

First, create the directory structure:

```bash
mkdir -p .claude/jc-marketplace/git-workflow
```

Then, use the Write tool to create the file at this exact path:

```
.claude/jc-marketplace/git-workflow/cache.md
```

**Example:** If repository is at `/home/user/myproject`, the cache file must be:
```
/home/user/myproject/.claude/jc-marketplace/git-workflow/cache.md
```

### Step 4: Verify cache was created correctly

After writing the file, verify it exists at the correct path:

```bash
cat .claude/jc-marketplace/git-workflow/cache.md
```

If this command fails or shows a different file, you created the cache in the wrong location. Delete the wrong file and retry Step 3.

### Step 5: Continue

After verification succeeds, continue with the original command.

## Refreshing the cache

Delete the cache file (in the repository root) and re-run any git-workflow command:

```bash
rm "$(git rev-parse --show-toplevel)/.claude/jc-marketplace/git-workflow/cache.md"
```

## Example

Remote URL: `git@bitbucket.org:myteam/my-project.git`

Cache file content:
```markdown
---
provider: bitbucket
bitbucket_workspace: myteam
bitbucket_repo: my-project
---

# Git Workflow Cache

Auto-detected on 2025-01-15.
Provider: **bitbucket**
```
