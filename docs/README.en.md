# dotfiles

Personal configuration files for macOS.

[🇯🇵 日本語版](../README.md)

## Features

- **Claude Code Integration** - Pre-configured with 13 MCP servers
- **Modern CLI Tools** - bat, eza, fzf, ripgrep, and more
- **One-Command Setup** - Build entire environment with bootstrap.sh
- **Profile Support** - personal/work/minimal profiles

## Quick Start

```bash
git clone https://github.com/otake-shol/dotfiles.git ~/dotfiles
cd ~/dotfiles && bash bootstrap.sh
```

### Dry Run Mode

Preview changes without making modifications:
```bash
bash bootstrap.sh --dry-run
```

## Directory Structure

| Directory | Contents |
|-----------|----------|
| `.zshrc`, `aliases/` | Shell configuration (modular aliases) |
| `Brewfile` / `Brewfile.full` | Essential / Full application list |
| `.claude/` | Claude Code (MCP servers, commands) |
| `nvim/` | Neovim config (LSP, completion, formatters, linters) |
| `tmux/` | tmux config with TPM |
| `ghostty/` | Ghostty terminal |
| `git/`, `gh/` | Git/GitHub CLI settings, commit/PR templates |
| `ssh/` | SSH configuration |
| `profiles/` | Environment-specific profiles |
| `scripts/` | Utility scripts |
| `espanso/` | Text expansion (AI prompt snippets) |

## Theme

All tools use the **TokyoNight** theme:
- Neovim, tmux, Ghostty, bat, fzf

## Modern CLI Tools

| Legacy | Modern | Description |
|--------|--------|-------------|
| `cat` | `bat` | Syntax highlighting |
| `ls` | `eza` | Icons, Git integration |
| `grep` | `rg` | ripgrep (fast search) |
| `find` | `fd` | Fast file finder |
| `du` | `dust` | Disk usage visualization |
| `ps` | `procs` | Process viewer |
| `cd` | `zoxide` | Smart directory jump |
| `diff` | `delta` | Beautiful diffs |

## Useful Commands

```bash
# Help and documentation
dothelp           # Show all aliases and functions
dothelp git       # Show Git-related aliases
dothelp fzf       # Show fzf integration functions

# Maintenance
dotverify         # Verify setup (symlinks, tools, configs)
dotup             # Check for updates
dotupdate         # Update all

# fzf Integration
fvim              # Select file → open in nvim
fbr               # Select branch → checkout
fshow             # Browse commit history
fkill             # Select process → kill
```

## Profiles

Set `DOTFILES_PROFILE` in `~/.zshrc.local`:

| Profile | Use Case |
|---------|----------|
| `personal` | Default, personal development |
| `work` | Work environment with proxy settings |
| `minimal` | Fast startup, troubleshooting |

```bash
# Example: ~/.zshrc.local
export DOTFILES_PROFILE=work
```

## Git Hooks (lefthook)

Pre-commit hooks for code quality:

```bash
# Install hooks
lefthook install

# Hooks include:
# - ShellCheck for shell scripts
# - YAML validation
# - Markdown linting
# - Trailing whitespace check
# - Secret scanning (git-secrets)
# - Conventional Commits validation
```

## Backup

### Raycast Settings
1. Raycast → Settings → Advanced → Export
2. Save to `~/dotfiles/raycast/`

### 1Password SSH Agent
Uncomment settings in `ssh/config` to use 1Password for SSH key management.

## Documentation

### AI-Driven Development
| File | Contents |
|------|----------|
| [AI-DRIVEN-DEV-GUIDE.md](ai-workflow/AI-DRIVEN-DEV-GUIDE.md) | Complete AI development guide |
| [SPEC-DRIVEN-DEV.md](ai-workflow/SPEC-DRIVEN-DEV.md) | Spec-driven development |
| [AI-PROMPTS.md](ai-workflow/AI-PROMPTS.md) | AI prompt templates |

### Tool Integration
| File | Contents |
|------|----------|
| [mcp-servers-guide.md](integrations/mcp-servers-guide.md) | MCP servers setup |
| [claude-code-jira-guide.md](integrations/claude-code-jira-guide.md) | Claude Code × Jira |
| [confluence-requirements-doc-automation.md](integrations/confluence-requirements-doc-automation.md) | Confluence automation |

### Setup
| File | Contents |
|------|----------|
| [SETUP.md](setup/SETUP.md) | Detailed setup instructions |
| [APPS.md](setup/APPS.md) | Application list |

## References

- [GitHub does dotfiles](https://dotfiles.github.io/)
- [Awesome dotfiles](https://github.com/webpro/awesome-dotfiles)

## License

MIT
