# Shell Setup

A powerful Zsh configuration with modern plugins and tools.

## Overview

| Component | Description |
|-----------|-------------|
| Shell | Zsh with Oh My Zsh |
| Theme | Powerlevel10k |
| Plugins | autosuggestions, syntax-highlighting, completions |

## Zsh Plugins

### Core Plugins

- **git** - Git aliases and functions
- **z** - Quick directory navigation
- **fzf** - Fuzzy finder integration
- **docker** - Docker completions
- **kubectl** - Kubernetes completions

### Third-Party Plugins

- **zsh-autosuggestions** - Fish-like autosuggestions
- **zsh-syntax-highlighting** - Real-time syntax highlighting
- **zsh-completions** - Additional completions

## Powerlevel10k

A fast, flexible Zsh theme with:

- Git status in prompt
- Command execution time
- Error status indicators
- Instant prompt (no lag)

### Configuration

Run the configuration wizard:

```bash
p10k configure
```

## Aliases

Aliases are organized in modular files:

```
aliases/
├── core.zsh       # Basic commands
├── git.zsh        # Git & GitHub
├── docker.zsh     # Docker & Compose
├── kubernetes.zsh # kubectl, helm
└── ...
```

### Viewing Aliases

```bash
# Show all aliases
dothelp

# Show specific category
dothelp git
dothelp docker
```

### Common Aliases

```bash
# Navigation
..    # cd ..
...   # cd ../..
~     # cd ~

# Files
ll    # eza -la --icons
lt    # eza --tree --level=2
cat   # bat (with syntax highlighting)

# Git
gs    # git status
gco   # git checkout
gp    # git push
gl    # git pull
```

## Functions

### fzf Integration

| Function | Description |
|----------|-------------|
| `fvim` | Select file → open in nvim |
| `fbr` | Select branch → checkout |
| `fshow` | Browse commits with preview |
| `fkill` | Select process → kill |
| `fcd` | Fuzzy directory navigation |
| `fstash` | Select stash → apply |

### Utility Functions

| Function | Description |
|----------|-------------|
| `mkcd` | Create directory and cd into it |
| `extract` | Extract any archive format |
| `backup` | Create timestamped backup |
| `weather` | Show weather forecast |

## Startup Optimization

The shell is optimized for fast startup:

```bash
# Check startup time
zshbench

# Profile startup
zshbench --profile
```

### Optimization Techniques

1. **Plugin caching** - Cached plugin list
2. **Lazy loading** - Heavy tools loaded on demand
3. **Minimal plugins** - Only essential plugins enabled

## Customization

### Local Configuration

Add machine-specific settings to `~/.zshrc.local`:

```bash
# Custom aliases
alias myproject="cd ~/work/myproject"

# Custom PATH
export PATH="$HOME/custom-tools/bin:$PATH"

# Custom environment
export EDITOR="nvim"
```

### Adding New Aliases

Create a new file in `aliases/`:

```bash
# aliases/mytools.zsh
alias myalias="my-command"
```

Then source it in `.aliases`:

```bash
source "$DOTFILES_ROOT/aliases/mytools.zsh"
```
