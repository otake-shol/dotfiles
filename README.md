<h1 align="center">dotfiles</h1>

<p align="center">
  <strong>A modern, cross-platform dotfiles repository with AI-driven development integration</strong>
</p>

<p align="center">
  <a href="https://github.com/otake-shol/dotfiles/actions/workflows/lint.yml">
    <img src="https://github.com/otake-shol/dotfiles/actions/workflows/lint.yml/badge.svg" alt="Lint">
  </a>
  <a href="https://github.com/otake-shol/dotfiles/commits/master">
    <img src="https://img.shields.io/github/last-commit/otake-shol/dotfiles" alt="Last Commit">
  </a>
  <img src="https://img.shields.io/badge/platform-macOS%20%7C%20Linux%20%7C%20WSL-blue" alt="Platform">
</p>

<p align="center">
  <a href="docs/README.ja.md">🇯🇵 日本語</a> •
  <a href="#features">Features</a> •
  <a href="#quick-start">Quick Start</a> •
  <a href="#whats-included">What's Included</a> •
  <a href="#documentation">Documentation</a>
</p>

---

## Features

- **Cross-Platform** - Works on macOS, Linux, and WSL
- **AI-Driven Development** - Pre-configured Claude Code with MCP servers
- **Modern CLI Tools** - bat, eza, fzf, ripgrep, zoxide, and more
- **One-Command Setup** - Fully automated bootstrap script
- **Idempotent** - Safe to run multiple times
- **Theme Unified** - TokyoNight theme across all tools
- **Well Documented** - Comprehensive guides for everything

## Quick Start

### macOS / Linux

```bash
# Clone the repository
git clone https://github.com/otake-shol/dotfiles.git ~/dotfiles

# Run the bootstrap script
cd ~/dotfiles && bash bootstrap.sh
```

### WSL (Windows Subsystem for Linux)

```bash
# Clone the repository
git clone https://github.com/otake-shol/dotfiles.git ~/dotfiles

# Run with WSL support
cd ~/dotfiles && bash bootstrap.sh
```

### Options

```bash
bash bootstrap.sh --help        # Show help
bash bootstrap.sh --dry-run     # Preview changes without applying
bash bootstrap.sh --skip-apps   # Skip application installation
bash bootstrap.sh --linux-only  # Linux-specific setup only
```

## What's Included

### Shell Configuration

| Component | Description |
|-----------|-------------|
| **Zsh** | Oh My Zsh + Powerlevel10k theme |
| **Plugins** | autosuggestions, syntax-highlighting, completions |
| **Aliases** | Modular aliases (git, docker, k8s, etc.) |
| **Functions** | fzf integrations (fbr, fshow, fvim, etc.) |

### Modern CLI Tools

| Legacy | Modern | Description |
|--------|--------|-------------|
| `cat` | `bat` | Syntax highlighting, line numbers |
| `ls` | `eza` | Icons, Git integration, tree view |
| `grep` | `rg` | ripgrep - blazingly fast search |
| `find` | `fd` | User-friendly, fast file finder |
| `du` | `dust` | Intuitive disk usage visualization |
| `ps` | `procs` | Modern process viewer |
| `cd` | `zoxide` | Smart directory jumping |
| `diff` | `delta` | Beautiful side-by-side diffs |
| `sed` | `sd` | Intuitive find & replace |

### Development Environment

| Tool | Purpose |
|------|---------|
| **Neovim** | LSP, completion, formatters, linters |
| **tmux** | Terminal multiplexer with TokyoNight theme |
| **Ghostty** | Fast, GPU-accelerated terminal |
| **Git** | Enhanced with delta, git-secrets, hooks |
| **asdf** | Multi-language version manager |

### AI-Driven Development

| Component | Description |
|-----------|-------------|
| **Claude Code** | CLI AI assistant with custom agents |
| **MCP Servers** | 13 pre-configured servers (Context7, Serena, Playwright, etc.) |
| **Custom Commands** | `/commit-push`, `/review`, `/test`, `/spec`, etc. |
| **Hooks** | Auto Brewfile update, completion notifications |

## Directory Structure

```
dotfiles/
├── stow/                      # GNU Stow packages
│   ├── zsh/                   # Zsh configuration
│   │   ├── .zshrc
│   │   ├── .aliases
│   │   ├── .p10k.zsh
│   │   ├── .tool-versions
│   │   └── .zsh/
│   │       ├── core.zsh       # Basic settings
│   │       ├── plugins.zsh    # Oh My Zsh plugins
│   │       ├── lazy.zsh       # Lazy loading (asdf, atuin)
│   │       ├── tools.zsh      # Tool configs (fzf, zoxide)
│   │       ├── aliases/       # Modular aliases
│   │       │   ├── core.zsh
│   │       │   ├── git.zsh
│   │       │   ├── node.zsh
│   │       │   └── dev.zsh
│   │       └── functions/     # fzf integrations
│   ├── git/                   # Git configuration
│   ├── claude/                # Claude Code (agents, commands)
│   ├── nvim/                  # Neovim
│   ├── tmux/                  # tmux
│   ├── ghostty/               # Ghostty terminal
│   ├── bat/                   # bat (syntax highlighting)
│   └── atuin/                 # Shell history
├── scripts/                   # Utility scripts
│   ├── setup/                 # OS-specific setup
│   ├── maintenance/           # verify-setup.sh, etc.
│   ├── utils/                 # Helper scripts
│   └── lib/                   # Shared libraries
├── docs/                      # Documentation
├── Makefile                   # GNU Stow operations
├── Brewfile                   # Homebrew packages
└── bootstrap.sh               # Main setup script
```

## Theme

All tools use the **TokyoNight** color scheme for a unified look:

- Neovim
- tmux
- Ghostty
- bat
- fzf

## Useful Commands

```bash
# Documentation
dothelp              # Show all aliases and functions
dothelp git          # Show Git-related aliases
dothelp fzf          # Show fzf integration functions

# Maintenance
dotverify            # Verify setup (symlinks, tools, configs)
dotup                # Check for updates
dotupdate            # Update all tools
brewsync             # Check Brewfile sync status

# fzf Integrations
fvim                 # Select file → open in nvim
fbr                  # Select branch → checkout
fshow                # Browse commit history with preview
fkill                # Select process → kill
fcd                  # Fuzzy directory navigation
fstash               # Select stash → apply

# Benchmarking
zshbench             # Measure zsh startup time
zshbench --profile   # Detailed profiling with zprof
```

## Documentation

| Document | Description |
|----------|-------------|
| [SETUP.md](docs/setup/SETUP.md) | Detailed setup instructions |
| [APPS.md](docs/setup/APPS.md) | Application list & descriptions |
| [mcp-servers-guide.md](docs/integrations/mcp-servers-guide.md) | MCP server setup guide |
| [atlassian-guide.md](docs/integrations/atlassian-guide.md) | Jira/Confluence integration |
| [CHANGELOG.md](CHANGELOG.md) | Release notes & change history |

### Additional Configurations

| Directory | Description |
|-----------|-------------|
| [raycast/](raycast/) | Raycast script commands (Japanese dictionary) |
| [antigravity/](antigravity/) | Antigravity editor settings & extensions |

## Requirements

### macOS

- macOS 12.0+ (Monterey or later)
- Xcode Command Line Tools

### Linux

- Ubuntu 20.04+ / Debian 11+ / Fedora 35+ / Arch Linux
- curl, git

### WSL

- Windows 10/11 with WSL2
- Ubuntu or Debian distribution recommended

## Acknowledgments

- [Oh My Zsh](https://ohmyz.sh/) - Zsh framework
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k) - Zsh theme
- [TokyoNight](https://github.com/folke/tokyonight.nvim) - Color scheme
- [Modern Unix](https://github.com/ibraheemdev/modern-unix) - Tool inspiration
- [GitHub does dotfiles](https://dotfiles.github.io/) - Community resources

---

<p align="center">
  Made with ❤️ by <a href="https://github.com/otake-shol">otake-shol</a>
</p>
