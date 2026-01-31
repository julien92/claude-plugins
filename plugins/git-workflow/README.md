# git-workflow

AI-powered Git workflows for Claude Code. Smart commits with Gitmoji, changelogs, and conflict resolution.

## Features

- 🤖 **AI-assisted** — Claude analyzes your changes and generates meaningful messages
- 😀 **Gitmoji commits** — Visual commit messages with emoji prefixes
- 🔀 **Conflict resolution** — Interactive help for rebase conflicts
- 🧹 **Branch cleanup** — Remove stale branches automatically

## Installation

```bash
claude plugin install git-workflow@julien92-plugins
```

## Commands

| Command | Description |
|---------|-------------|
| `/git-commit` | Review diff + generate Gitmoji commit message |
| `/git-commit-push-pr` | Commit + push + create PR (GitHub/GitLab/Bitbucket) |
| `/git-changelog` | Generate changelog between two tags |
| `/git-help-rebase` | Interactive assistant to resolve rebase conflicts |
| `/git-clean-branches` | Delete merged branches and branches with deleted remotes |

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
- For Bitbucket: targets `develop` branch if it exists, otherwise `main`

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

### Clean Branches
```
/git-clean-branches
```
Lists and deletes local branches that have been merged or whose remote was deleted.

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
