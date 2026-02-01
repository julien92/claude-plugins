# git-workflow

Leverage AI in your daily Git workflows. Compatible with all major providers: GitHub, GitLab, Bitbucket (cloud & self-hosted).

## Requirements

| Tool | Git provider | Install |
|------|--------------|---------|
| **git** | All | — |
| **gh** | GitHub | [cli.github.com](https://cli.github.com/) |
| **glab** | GitLab | [gitlab.com/gitlab-org/cli](https://gitlab.com/gitlab-org/cli) |
| **curl** + **jq** | Bitbucket | (no official CLI) |

## Installation

```bash
claude plugin install git-workflow@julien92-plugins
```

## Skills

Skills are automatically loaded when relevant to provide Claude with domain-specific knowledge.

### commit-message

Provides conventions for writing git commit messages with Gitmoji emojis.

**Triggers:** "commit changes", "create a commit", "push my code", "commit and push"

**Coverage:**
- Gitmoji emoji conventions (✨ features, 🐛 bugs, 📝 docs, etc.)
- Commit message format and structure
- Ticket reference extraction from branch names

**Resources:**
| File | Description |
|------|-------------|
| `skills/commit-message/SKILL.md` | Core conventions (~60 lines) |

## Commands

| Command | Description |
|---------|-------------|
| `/git-bisect` | Find the commit that introduced a bug using AI-powered binary search |
| `/git-changelog` | Generate changelog between two tags |
| `/git-clean-branches` | Delete merged branches and branches with deleted remotes |
| `/git-commit` | Analyze changes and generate meaningful commits |
| `/git-commit-push` | Commit with Gitmoji conventions then push to remote |
| `/git-commit-push-pr` | Commit + push + create PR targeting parent branch |
| `/git-help-rebase` | Interactive assistant to resolve rebase conflicts |
| `/git-pr-review` | AI-assisted PR review with inline comments |
| `/git-why` | AI-powered git archaeology — understand WHY code exists |

## Usage Examples

### Smart Commit
```
/git-commit
```
Claude reviews your staged changes and suggests a Gitmoji commit message. If your branch contains a ticket reference (e.g. `feature/JIRA-123-login`), it's automatically added as a footer (`Refs: JIRA-123`).

### Full Workflow
```
/git-commit-push-pr
```
Commits your changes, pushes to remote, and creates a PR on GitHub/GitLab/Bitbucket.

- Creates a new branch if on main/master/develop
- Uses `/git-commit` conventions
- Auto-detects provider from remote URL (github.com, gitlab.com, bitbucket.org)
- **Targets the parent branch**: automatically detects the branch from which your feature branch was created (e.g., if you branched from `develop`, the PR targets `develop`)

### Generate Changelog
```
/git-changelog v1.0.0..v1.1.0
```
Generates a grouped changelog from commits between two versions.

### Find Bug with Bisect
```
/git-bisect
```
Claude creates a test script and uses `git bisect run` to automatically find the culprit commit:

```
You: "The login test started failing"
Claude: I'll create bisect-test.sh and run it on each commit.

🎯 Found: d4e5f6g "Refactor auth middleware"

Claude: Want me to fix this and create a PR?
```

After finding the culprit, Claude can implement a fix and open a PR automatically.

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
