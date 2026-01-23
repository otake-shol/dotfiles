# Configuration

Customize your dotfiles setup to match your workflow.

## Profiles

Set `DOTFILES_PROFILE` to switch between configurations:

| Profile | Use Case | Features |
|---------|----------|----------|
| `personal` | Default | Full features |
| `work` | Corporate | Proxy settings, work tools |
| `minimal` | Fast startup | Core features only |

Create `~/.zshrc.local`:

```bash
export DOTFILES_PROFILE=personal
```

## Local Overrides

### Zsh Configuration

Create `~/.zshrc.local` for machine-specific settings:

```bash
# Example: ~/.zshrc.local

# Profile
export DOTFILES_PROFILE=work

# Work-specific settings
export HTTP_PROXY="http://proxy.company.com:8080"
export HTTPS_PROXY="http://proxy.company.com:8080"

# Custom PATH additions
export PATH="$HOME/work-tools/bin:$PATH"

# Work aliases
alias vpn="sudo openconnect vpn.company.com"
```

### Git Configuration

Create `~/.gitconfig.local`:

```ini
[user]
    name = Your Name
    email = your.email@company.com

[http]
    proxy = http://proxy.company.com:8080
```

## Environment Variables

### MCP Server Authentication

For Claude Code MCP servers:

```bash
# ~/.zshrc.local

# GitHub
export GITHUB_PERSONAL_ACCESS_TOKEN="ghp_xxxxx"

# Brave Search
export BRAVE_API_KEY="BSAxxxxx"

# Sentry
export SENTRY_AUTH_TOKEN="sntrys_xxxxx"
```

### Development Tools

```bash
# Node.js
export NODE_OPTIONS="--max-old-space-size=8192"

# Python
export PYTHONDONTWRITEBYTECODE=1

# Go
export GOPATH="$HOME/go"
```

## Theme Customization

All tools use TokyoNight theme. To change:

### Neovim

Edit `nvim/.config/nvim/init.lua`:

```lua
-- Change colorscheme
vim.cmd.colorscheme("catppuccin")
```

### tmux

Edit `tmux/.tmux.conf`:

```bash
# Change theme plugin
set -g @plugin 'catppuccin/tmux'
```

### Ghostty

Edit `ghostty/config`:

```ini
theme = catppuccin-mocha
```

### bat

```bash
bat --list-themes  # See available themes
export BAT_THEME="Catppuccin-mocha"
```

## Performance Tuning

### Zsh Startup

Check startup time:

```bash
zshbench
zshbench --profile  # Detailed profiling
```

For faster startup:

1. Use `minimal` profile
2. Disable unused plugins in `.zshrc`
3. Use lazy loading for heavy tools

```bash
# Lazy load nvm (example)
nvm() {
    unset -f nvm
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm "$@"
}
```

### Git Performance

For large repositories:

```bash
# Enable filesystem monitor
git config core.fsmonitor true
git config core.untrackedcache true
```

## Backup & Restore

### Export Settings

```bash
# Backup Homebrew packages
brew bundle dump --file=~/Brewfile.backup

# Backup VS Code extensions
code --list-extensions > ~/vscode-extensions.txt
```

### Restore Settings

```bash
# Restore Homebrew packages
brew bundle --file=~/Brewfile.backup

# Restore VS Code extensions
cat ~/vscode-extensions.txt | xargs -L 1 code --install-extension
```
