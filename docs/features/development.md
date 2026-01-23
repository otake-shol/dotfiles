# Development Environment

A complete development setup with modern tools.

## Editor: Neovim

LSP-powered editing with:

- Syntax highlighting (Treesitter)
- Code completion (nvim-cmp)
- Diagnostics and linting
- Formatting on save
- Git integration

### Key Mappings

| Key | Action |
|-----|--------|
| `<Space>` | Leader key |
| `gd` | Go to definition |
| `gr` | Find references |
| `K` | Show hover docs |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code actions |
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |

### Installed Plugins

- **lazy.nvim** - Plugin manager
- **nvim-lspconfig** - LSP configuration
- **nvim-treesitter** - Syntax highlighting
- **nvim-cmp** - Completion
- **telescope.nvim** - Fuzzy finder
- **gitsigns.nvim** - Git decorations
- **tokyonight.nvim** - Color scheme

## Terminal Multiplexer: tmux

Session management with:

- Multiple windows and panes
- Session persistence
- Mouse support
- Vi-mode navigation

### Key Bindings

| Key | Action |
|-----|--------|
| `Ctrl+a` | Prefix key |
| `Prefix + c` | New window |
| `Prefix + \|` | Vertical split |
| `Prefix + -` | Horizontal split |
| `Prefix + h/j/k/l` | Navigate panes |
| `Prefix + d` | Detach session |

### Session Management

```bash
# Create named session
tmux new -s project

# List sessions
tmux ls

# Attach to session
tmux attach -t project

# Kill session
tmux kill-session -t project
```

## Terminal: Ghostty

Fast, GPU-accelerated terminal with:

- Native performance
- True color support
- Ligature support
- TokyoNight theme

### Configuration

Located at `ghostty/config`:

```ini
font-family = JetBrains Mono
font-size = 14
theme = tokyonight
```

## Git

Enhanced Git workflow with:

- **delta** - Beautiful diffs
- **git-secrets** - Prevent committing secrets
- **commit template** - Conventional commits

### Useful Aliases

```bash
gs     # git status
gco    # git checkout
gp     # git push
gl     # git pull
glog   # git log --oneline --graph
gwip   # Work in progress commit
gunwip # Undo WIP commit
```

### Commit Template

Following Conventional Commits:

```
<type>: <subject>

# Types:
# feat: New feature
# fix: Bug fix
# docs: Documentation
# style: Formatting
# refactor: Code restructuring
# perf: Performance improvement
# test: Adding tests
# chore: Maintenance
```

## Version Manager: asdf

Manage multiple language versions:

```bash
# Install plugin
asdf plugin add nodejs

# Install version
asdf install nodejs latest

# Set global version
asdf global nodejs latest

# Set local version (per project)
asdf local nodejs 18.17.0
```

### Supported Languages

Configured in `.tool-versions`:

- Node.js
- Python
- Ruby
- Go
- Rust
- Java

## Package Managers

### Homebrew

```bash
# Install package
brew install <package>

# Update all
brew update && brew upgrade

# Check Brewfile sync
brewsync
```

### npm/yarn/pnpm

```bash
# npm
npm install

# yarn
yarn

# pnpm (faster)
pnpm install
```

## Debugging

### Shell Debugging

```bash
# Zsh startup profiling
zshbench --profile

# Check shell startup
time zsh -i -c exit
```

### Git Debugging

```bash
# Verbose output
GIT_TRACE=1 git push

# Check configuration
git config --list --show-origin
```
