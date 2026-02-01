# claude-code-marketplace

Productivity plugins for [Claude Code](https://github.com/anthropics/claude-code).

> **Disclaimer:** This is an independent community project, not affiliated with, endorsed by, or sponsored by Anthropic. "Claude" is a trademark of Anthropic, PBC.

## 🚀 Quick Start

```bash
# 1. Add this marketplace
claude plugin marketplace add julien92/claude-code-marketplace

# 2. Install a plugin
claude plugin install git-workflow@claude-code-marketplace
```

Or use the community CLI (one command):
```bash
npx claude-plugins install git-workflow@claude-code-marketplace
```

## 📦 Available Plugins

### [git-workflow](./plugins/git-workflow)
AI-powered Git workflows with Gitmoji

**Commands:** `/git-commit` · `/git-commit-push-pr` · `/git-pr-review` · `/git-changelog` · `/git-help-rebase` · `/git-clean-branches`

## 🔗 Multi Git Provider Support

Works with major Git providers out of the box:

| Provider | Support | Auto-detection |
|----------|---------|----------------|
| GitHub | ✅ | ✅ |
| GitLab | ✅ | ✅ |
| Bitbucket | ✅ | ✅ |
| GitHub Enterprise | ✅ | via `$GIT_PROVIDER` |
| GitLab Self-hosted | ✅ | via `$GIT_PROVIDER` |

Provider is automatically detected from the `origin` remote URL.

For self-hosted instances, set the environment variable:

```bash
export GIT_PROVIDER=gitlab  # or github
```

## 📋 Requirements

- [Claude Code](https://claude.ai/code) v2.0.12+
- Git 2.0+

## 👤 Author

Julien Cornille — [GitHub](https://github.com/julien92)

## 📄 License

MIT
