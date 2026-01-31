# git-workflow

A set of workflows that leverage AI to help developers in their daily tasks, powered by Git and Claude Code.

## Requirements

- **git** — Version control
- **jq** — JSON parser ([jqlang.github.io/jq](https://jqlang.github.io/jq/)) — for Bitbucket
- **curl** — HTTP client — for Bitbucket
- **gh** — GitHub CLI ([cli.github.com](https://cli.github.com/)) — for GitHub
- **glab** — GitLab CLI ([gitlab.com/gitlab-org/cli](https://gitlab.com/gitlab-org/cli)) — for GitLab

## Installation

```bash
claude plugin install git-workflow@julien92-plugins
```

## Commands

| Command | Description |
|---------|-------------|
| `/git-commit` | Review diff + generate Gitmoji commit message |
| `/git-commit-push` | Commit with Gitmoji + push to remote |
| `/git-commit-push-pr` | Commit + push + create PR targeting parent branch (GitHub/GitLab/Bitbucket) |
| `/git-changelog` | Generate changelog between two tags |
| `/git-help-rebase` | Interactive assistant to resolve rebase conflicts |
| `/git-pr-review` | AI-assisted PR review with inline comments (GitHub/GitLab/Bitbucket) |
| `/git-clean-branches` | Delete merged branches and branches with deleted remotes |
| `/git-why` | AI-powered git archaeology — understand WHY code exists |

## Usage Examples

### Smart Commit
```
/git-commit
```
Claude reviews your staged changes and suggests a Gitmoji commit message.

### Full Workflow
```
/git-commit-push-pr
```
Commits your changes, pushes to remote, and creates a PR on GitHub/GitLab/Bitbucket.

- Creates a new branch if on main/master/develop
- Uses Gitmoji commit format:
  ```
  ✨ Add user authentication

  - Implement OAuth2 flow
  - Add session management
  ```
- Auto-detects provider from remote URL (github.com, gitlab.com, bitbucket.org)
- **Targets the parent branch**: automatically detects the branch from which your feature branch was created (e.g., if you branched from `develop`, the PR targets `develop`)

### Generate Changelog
```
/git-changelog v1.0.0..v1.1.0
```
Generates a grouped changelog from commits between two versions.

### Resolve Rebase Conflicts
```
/git-help-rebase
```
Claude guides you through each conflict, explains both versions, and suggests resolutions.

### Review a Pull Request
```
/git-pr-review
```
Claude lists open PRs, checks out the one you choose, and reviews each file:

```
📄 [1/5] src/auth/login.ts:42 (+15/-3 lines)
🎯 PR: Add OAuth2 authentication

📝 Changes:
<diff content>

🔍 Analysis:
Adds OAuth2 flow but token isn't validated before storage.

💬 Review comments:
1. L:47 [security] Token stored without validation
   → "Consider validating the token signature before storing"

Actions: "1" to post, "next" to skip, "done" to finish
```

Supports GitHub, GitLab, and Bitbucket with inline comments.

### Clean Branches
```
/git-clean-branches
```
Lists and deletes local branches that have been merged or whose remote was deleted.

### Understand Code History
```
/git-why
```
Ask Claude why code exists the way it does. Claude investigates git history (blame, log, pickaxe search) and tells the story of the code:

> **You**: "Why is this regex so complex?"
>
> **Claude**: This regex evolved over 8 months through 4 commits:
> 1. **Initial version (a1b2c3, Alice, March)** — Simple `\d+` for numeric IDs
> 2. **UUID support (d4e5f6, Bob, May)** — Product team migrated to UUIDs
> 3. **Legacy fix (g7h8i9, Alice, July)** — Bug #234: old records had dashes
> 4. **Edge case (j0k1l2, Charlie, October)** — Production incident with underscores
>
> The complexity comes from backwards compatibility with 3 ID formats.

## Configuration

### GitHub / GitLab

```bash
gh auth login    # GitHub
glab auth login  # GitLab
```

### Bitbucket

Add to `.claude/settings.local.json`:

```json
{
  "env": {
    "BITBUCKET_EMAIL": "your-email@example.com",
    "BITBUCKET_API_TOKEN": "your-app-password"
  }
}
```

Or in your shell config (`.bashrc`/`.zshrc`):

```bash
export BITBUCKET_EMAIL="your-email@example.com"
export BITBUCKET_API_TOKEN="your-app-password"
```

### Self-hosted (GitHub Enterprise / GitLab)

Provider is auto-detected from remote URL. Only set `$GIT_PROVIDER` for self-hosted instances:

```json
{
  "env": {
    "GIT_PROVIDER": "github"
  }
}
```

## Credits

Inspired by [Anthropic's commit-commands plugin](https://github.com/anthropics/claude-code/tree/main/plugins/commit-commands)

## License

MIT
