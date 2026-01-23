# Scripts Reference

Utility scripts for setup and maintenance.

## Setup Scripts

### bootstrap.sh

Main setup script:

```bash
bash bootstrap.sh [OPTIONS]
```

Options:

| Option | Description |
|--------|-------------|
| `--dry-run` | Preview changes without applying |
| `--skip-apps` | Skip application installation |
| `--linux-only` | Linux-specific setup only |
| `-h, --help` | Show help |

### scripts/setup/linux.sh

Linux/WSL specific setup:

```bash
bash scripts/setup/linux.sh
```

Features:

- Distro detection (apt, dnf, yum, pacman, zypper)
- Essential package installation
- WSL-specific configuration
- Clipboard integration

## Maintenance Scripts

### scripts/maintenance/verify-setup.sh

Verify dotfiles installation:

```bash
bash scripts/maintenance/verify-setup.sh
```

Checks:

- Symlink integrity
- Required tools installation
- Configuration validity
- Git hooks

Alias: `dotverify`

### scripts/maintenance/update.sh

Update all tools:

```bash
bash scripts/maintenance/update.sh
```

Updates:

- Homebrew packages
- Oh My Zsh
- Zsh plugins
- asdf plugins
- Neovim plugins

Alias: `dotupdate`

## Utility Scripts

### scripts/utils/record-demo.sh

Record demo GIF:

```bash
bash scripts/utils/record-demo.sh [OPTIONS]
```

Options:

| Option | Description |
|--------|-------------|
| `--auto` | Run automated demo scenario |
| `--interactive` | Manual recording mode |
| `-h, --help` | Show help |

Requirements:

- asciinema + agg, or
- terminalizer

### scripts/utils/demo-scenario.sh

Automated demo script for recording:

```bash
bash scripts/utils/demo-scenario.sh
```

Shows:

- Modern CLI tools
- fzf integrations
- Git aliases
- Claude Code features

## Hook Scripts

### .claude/hooks/update-brewfile.sh

Auto-update Brewfile after `brew install`:

Triggered automatically via Claude Code hooks.

Actions:

1. Detects new package
2. Updates Brewfile
3. Notifies user

## Makefile Targets

Using GNU Stow:

```bash
# Install all symlinks
make install

# Remove all symlinks
make uninstall

# Run tests
make test

# Run linters
make lint

# Show help
make help
```

Individual packages:

```bash
# Install specific package
make install-zsh
make install-nvim
make install-tmux

# Uninstall specific package
make uninstall-zsh
```

## Creating New Scripts

### Template

```bash
#!/bin/bash
# ========================================
# script-name.sh - Description
# ========================================
# Usage: bash script-name.sh [OPTIONS]

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Main
main() {
    log_info "Starting..."
    # Your code here
    log_info "Done!"
}

main "$@"
```

### Adding to PATH

Scripts in `scripts/` are automatically available if added to PATH:

```bash
# In .zshrc.local
export PATH="$HOME/dotfiles/scripts/utils:$PATH"
```
