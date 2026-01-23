# AI-Driven Development

Leverage Claude Code for AI-powered development workflows.

## Overview

This dotfiles setup includes pre-configured:

- **Claude Code CLI** - AI assistant in your terminal
- **13 MCP Servers** - Extended capabilities
- **Custom Commands** - Slash commands for common tasks
- **Hooks** - Automated workflows

## MCP Servers

### No Authentication Required

| Server | Purpose |
|--------|---------|
| Context7 | Real-time documentation lookup |
| Serena | Symbolic code analysis (LSP integration) |
| Playwright | Browser automation, E2E testing |
| Puppeteer | Lightweight browser automation |
| Sequential Thinking | Structured problem solving |

### OAuth Authentication

| Server | Purpose |
|--------|---------|
| Linear | Issue/project management |
| Supabase | BaaS (DB, Auth, Storage) |
| Notion | Documentation, knowledge base |
| Figma | Design → code conversion |
| Slack | Team communication |

### Environment Variables Required

| Server | Variable | How to Get |
|--------|----------|------------|
| GitHub | `GITHUB_PERSONAL_ACCESS_TOKEN` | GitHub Settings → Developer settings → PAT |
| Brave Search | `BRAVE_API_KEY` | [brave.com/search/api](https://brave.com/search/api/) |
| Sentry | `SENTRY_AUTH_TOKEN` | Sentry Settings → Auth Tokens |

## Custom Commands

### `/commit-push`

Stage, commit, and push in one command:

```bash
# In Claude Code
/commit-push
```

Features:

- Analyzes changes
- Generates commit message
- Follows Conventional Commits
- Pushes to remote

### `/review`

AI code review:

```bash
# Review current changes
/review

# Review specific file
/review src/app.ts
```

### `/test`

Generate test code:

```bash
# Generate tests for a file
/test src/utils.ts
```

### `/spec`

Create/review specifications:

```bash
# Create spec for new feature
/spec "user authentication"
```

## Hooks

### Auto Brewfile Update

When you run `brew install`:

1. Hook detects new package
2. Updates `Brewfile` automatically
3. Notifies you of the change

### Completion Notification

When long-running tasks complete:

- macOS notification
- Sound alert

## Workflow Examples

### Feature Development

```bash
# 1. Create spec
/spec "add dark mode toggle"

# 2. Implement (Claude helps)
# ... coding ...

# 3. Generate tests
/test src/components/DarkModeToggle.tsx

# 4. Review changes
/review

# 5. Commit and push
/commit-push
```

### Bug Fixing

```bash
# 1. Describe the bug to Claude
"Users report login fails on Safari"

# 2. Claude analyzes code
# ... investigation ...

# 3. Fix is implemented
# ... coding ...

# 4. Review and commit
/review
/commit-push
```

### Code Exploration

```bash
# Use Serena for symbolic analysis
"Find all usages of UserService.authenticate"

# Use Context7 for documentation
"Show me Next.js 14 app router docs"
```

## Configuration

### Claude Code Settings

Located at `.claude/settings.json`:

```json
{
  "permissions": {
    "allow": [
      "Bash(git *)",
      "Bash(npm *)",
      "Edit",
      "Read"
    ]
  }
}
```

### Global Instructions

Located at `.claude/CLAUDE.md`:

- Communication preferences
- Tech stack information
- Commit conventions
- Testing requirements

## Best Practices

### 1. Be Specific

```bash
# Bad
"Fix the bug"

# Good
"Fix the authentication bug where JWT tokens expire prematurely on Safari due to clock skew"
```

### 2. Provide Context

```bash
# Include relevant files
"Review the changes in src/auth/ - we're migrating from session to JWT"
```

### 3. Iterate

```bash
# Start with spec
/spec "feature"

# Review and refine
"Add error handling for network failures"

# Test and verify
/test
```

### 4. Use Appropriate Servers

- **Code questions** → Serena
- **Documentation** → Context7
- **Browser testing** → Playwright
- **Project management** → Linear/Jira
