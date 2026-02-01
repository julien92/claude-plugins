# CLAUDE.md — claude-code-marketplace

## Project Overview

This is a **Claude Code plugin marketplace** providing productivity plugins for developers. The primary plugin is `git-workflow`, which offers AI-powered Git workflows with Gitmoji conventions.

**Repository:** `julien92/claude-code-marketplace`
**License:** MIT
**Target:** Claude Code v2.0.12+

## Architecture

```
claude-code-marketplace/
├── .claude-plugin/
│   └── marketplace.json      # Marketplace manifest (lists all plugins)
├── plugins/
│   └── <plugin-name>/
│       ├── .claude-plugin/
│       │   └── plugin.json   # Plugin manifest
│       ├── commands/         # Slash commands (*.md)
│       ├── skills/           # Auto-loaded contextual knowledge
│       │   └── <skill-name>/
│       │       └── SKILL.md
│       ├── docs/
│       │   └── workflows/    # User-facing documentation
│       └── README.md         # Plugin documentation
└── README.md                 # Marketplace documentation
```

## Plugin Development

### Plugin Manifest (`plugin.json`)

```json
{
  "name": "plugin-name",
  "description": "Short description for marketplace listing",
  "version": "X.Y.Z",
  "author": {
    "name": "Author Name",
    "email": "email@example.com"
  }
}
```

### Marketplace Manifest (`marketplace.json`)

When adding a new plugin, update `.claude-plugin/marketplace.json`:

```json
{
  "plugins": [
    {
      "name": "plugin-name",
      "description": "Description",
      "version": "X.Y.Z",
      "source": "./plugins/plugin-name",
      "keywords": ["keyword1", "keyword2"],
      "category": "productivity",
      "tags": ["tag1", "tag2"]
    }
  ]
}
```

## Command Development

Commands are markdown files in `plugins/<plugin>/commands/`. They define slash commands that users can invoke.

### Command Frontmatter

```yaml
---
allowed-tools: Bash(git:*), Read, Write, Edit
description: Short description shown in command list
argument-hint: "[optional] <required>"           # Optional
disable-model-invocation: true                   # Optional: prevents additional LLM calls
---
```

**`allowed-tools` patterns:**
- `Bash(git:*)` — Allow bash commands starting with `git`
- `Bash(git add:*)` — More specific pattern
- `Read`, `Write`, `Edit` — File operations
- Combine with `,` separator

### Command Structure

```markdown
---
allowed-tools: ...
description: ...
---

## Context

Dynamic context using inline bash:
- Current status: !`git status`
- Current branch: !`git branch --show-current`

## Instructions / Your task

Clear, step-by-step instructions for Claude.

1. First step
2. Second step
3. ...

## Examples (optional)

Concrete examples with expected output format.
```

### Command Conventions

1. **Inline bash** (`!`backticks``) for dynamic context
2. **Structured output** with visual formatting (box-drawing chars, emojis)
3. **User confirmation** before destructive actions
4. **Chain commands** with other slash commands (e.g., "Use `/git-commit-push-pr`")
5. **Provider-agnostic** — Support GitHub, GitLab, Bitbucket
6. **Cleanup** — Always clean up temporary files/state

### Output Formatting Pattern

```
🎯 Title
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📍 Field:   value
📝 Field:   value
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Skill Development

Skills provide contextual knowledge auto-loaded when relevant. They live in `plugins/<plugin>/skills/<skill-name>/SKILL.md`.

### Skill Frontmatter

```yaml
---
name: skill-name
description: Detailed trigger description. Use when user asks to "X", "Y", or "Z".
---
```

### Skill Content

- Focus on **conventions and patterns**
- Include **trigger conditions** (when to use)
- Provide **tables** for quick reference (emojis, patterns)
- Add **examples** showing expected format

## Documentation

### Plugin README

Each plugin needs a `README.md` with:

1. **Description** — What the plugin does
2. **Requirements** — CLI tools needed (gh, glab, etc.)
3. **Installation** — `claude plugin install plugin-name@marketplace`
4. **Skills** — List with triggers and coverage
5. **Commands** — Table with description and workflow links
6. **Usage Examples** — Real-world scenarios
7. **Configuration** — Environment variables, auth setup

### Workflow Documentation

Document each command in `docs/workflows/<command>.md`:

1. **What it does**
2. **Step-by-step flow**
3. **User interaction points**
4. **Example session**

## Git Conventions

This project uses **Gitmoji** for commits. Follow the conventions in `plugins/git-workflow/skills/commit-message/SKILL.md`.

### Commit Format

```
<emoji> <short description> (< 50 chars)

- Detail 1
- Detail 2
- Detail 3

Refs: TICKET-123 (if applicable)
```

### Common Gitmojis

| Emoji | Use case |
|-------|----------|
| ✨ | New feature |
| 🐛 | Bug fix |
| 📝 | Documentation |
| ♻️ | Refactor |
| 🎨 | Style/format |
| 🔧 | Configuration |
| 🚀 | Deploy/release |
| 🔥 | Remove code/files |
| ✅ | Tests |
| 💥 | Breaking change |

## Quality Standards

### Commands

- [ ] Clear description in frontmatter
- [ ] Minimal `allowed-tools` (principle of least privilege)
- [ ] Dynamic context with inline bash
- [ ] Step-by-step instructions
- [ ] User confirmation for destructive actions
- [ ] Cleanup of temporary files/state
- [ ] Provider-agnostic (GitHub/GitLab/Bitbucket)

### Skills

- [ ] Descriptive trigger conditions in frontmatter
- [ ] Comprehensive coverage section
- [ ] Tables for quick reference
- [ ] Concrete examples

### Documentation

- [ ] README.md for each plugin
- [ ] Workflow docs for each command
- [ ] Usage examples with expected output
- [ ] Configuration instructions

## Multi-Provider Support

All Git commands must support:

| Provider | CLI | Auto-detection |
|----------|-----|----------------|
| GitHub | `gh` | `github.com` in remote |
| GitLab | `glab` | `gitlab.com` in remote |
| Bitbucket | `curl`+`jq` | `bitbucket.org` in remote |
| Self-hosted | varies | `/git-setup` asks user |

### Detection Pattern

Use the `/git-setup` command to detect and cache provider info in `.claude/jc-marketplace/git-workflow/cache.md`.

Commands read the cache via inline bash in Context:
```markdown
- Provider cache: !`cat .claude/jc-marketplace/git-workflow/cache.md 2>/dev/null || echo "not cached"`
```

Cache format (YAML frontmatter):
```yaml
---
provider: github|gitlab|bitbucket|unknown
bitbucket_workspace: <workspace>  # Bitbucket only
bitbucket_repo: <repo>            # Bitbucket only
---
```

## Testing

### Local Development

Use the `--plugin-dir` flag to test plugins during development (no installation required):

```bash
claude --plugin-dir ./plugins/git-workflow
```

For multiple plugins:

```bash
claude --plugin-dir ./plugins/git-workflow --plugin-dir ./plugins/other-plugin
```

Restart Claude Code after each modification to reload changes.

### Manual Testing

1. Launch Claude with `--plugin-dir` flag
2. Test each command with various scenarios
3. Test with different Git providers
4. Verify cleanup of temporary files

### Test Scenarios

For git-workflow commands:
- Clean working directory
- Unstaged changes
- Staged changes
- Mixed staged/unstaged
- Merge conflicts (for rebase helper)
- Different branch naming conventions

## Versioning

- **Marketplace:** `X.Y.Z` in `.claude-plugin/marketplace.json`
- **Plugins:** `X.Y.Z` in both `marketplace.json` and `plugin.json`

Bump versions when:
- **Patch (Z):** Bug fixes, documentation updates
- **Minor (Y):** New commands, new features
- **Major (X):** Breaking changes

## File Naming

- Commands: `<verb>-<noun>.md` (e.g., `git-commit.md`, `git-help-rebase.md`)
- Skills: `<topic>/SKILL.md` (e.g., `commit-message/SKILL.md`)
- Workflows: Match command name (e.g., `docs/workflows/git-commit.md`)

## Common Patterns

### User Interaction

```markdown
Ask the user:
1. Question one?
2. Question two?

Show the result and get confirmation before continuing.
```

### Chaining Commands

```markdown
Use `/git-commit-push-pr` to commit, push and create PR.
```

### Conditional Actions

```markdown
If user declined:
- Clean up state
- Return to previous state

If user accepted:
- Proceed with action
- Show success message
```

## Development Workflow

1. Create feature branch from `main`
2. Develop command/skill/docs
3. Test locally with `claude --plugin-dir ./plugins/<plugin>`
4. Commit with Gitmoji conventions
5. Create PR with clear description
6. Merge to `main`
