# chezmoi Migration Guide

Guide for migrating from the current dotfiles setup to chezmoi.

## Why chezmoi?

| Feature | Current (GNU Stow) | chezmoi |
|---------|-------------------|---------|
| Symlink management | ✅ | ✅ |
| Templates | ❌ | ✅ |
| Secrets management | ❌ | ✅ (age encryption) |
| Multi-machine support | Manual | ✅ (templates) |
| Merge conflicts | Manual | ✅ Built-in |
| Diff before apply | Manual | ✅ `chezmoi diff` |

## Prerequisites

```bash
# Install chezmoi
brew install chezmoi

# Or with script
sh -c "$(curl -fsLS get.chezmoi.io)"
```

## Migration Steps

### Step 1: Initialize chezmoi

```bash
# Initialize with existing dotfiles
chezmoi init --source ~/dotfiles

# Or from GitHub
chezmoi init https://github.com/otake-shol/dotfiles.git
```

### Step 2: Add Files to chezmoi

```bash
# Add existing files
chezmoi add ~/.zshrc
chezmoi add ~/.aliases
chezmoi add ~/.gitconfig

# Add directory
chezmoi add ~/.config/nvim

# Add template file
chezmoi add --template ~/.zshrc
```

### Step 3: Convert to Templates

For files that need machine-specific configuration:

```bash
# Edit in chezmoi source
chezmoi edit ~/.zshrc
```

Template syntax:

```bash
# .zshrc template
export DOTFILES_PROFILE="{{ .profile }}"

{{ if eq .os "macos" -}}
export HOMEBREW_PREFIX="/opt/homebrew"
{{ else -}}
export HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
{{ end -}}

{{ if .is_wsl -}}
# WSL-specific settings
export DISPLAY=:0
{{ end -}}
```

### Step 4: Test Changes

```bash
# See what would change
chezmoi diff

# Apply to specific file
chezmoi apply ~/.zshrc

# Apply all
chezmoi apply
```

### Step 5: Verify

```bash
# Check status
chezmoi status

# Verify managed files
chezmoi managed
```

## File Structure

After migration:

```
~/dotfiles/
├── .chezmoi.toml.tmpl     # Config template
├── dot_zshrc.tmpl         # ~/.zshrc (template)
├── dot_aliases            # ~/.aliases
├── dot_config/
│   └── nvim/
│       └── init.lua       # ~/.config/nvim/init.lua
├── private_dot_ssh/
│   └── config             # ~/.ssh/config (private)
└── run_once_install.sh    # Run-once script
```

## Naming Conventions

| Prefix | Meaning |
|--------|---------|
| `dot_` | Dot file (`.`) |
| `private_` | Mode 0600 |
| `readonly_` | Mode 0444 |
| `executable_` | Mode 0755 |
| `exact_` | Exact directory |
| `.tmpl` | Template |

## Scripts

### Run Once

```bash
# run_once_install.sh
#!/bin/bash
# Runs once per machine

if ! command -v brew &> /dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
```

### Run Always

```bash
# run_after_update.sh
#!/bin/bash
# Runs after every apply

# Reload zsh
source ~/.zshrc
```

## Secrets Management

### Using age

```bash
# Generate key
age-keygen -o ~/.config/chezmoi/key.txt

# Add encrypted file
chezmoi add --encrypt ~/.env

# Edit encrypted file
chezmoi edit ~/.env
```

### Using 1Password

```bash
# In .chezmoi.toml
[onepassword]
    command = "op"

# In template
{{ onepassword "My Secret" "field" }}
```

## Common Commands

```bash
# Initialize
chezmoi init

# Add file
chezmoi add ~/.file

# Edit file
chezmoi edit ~/.file

# See diff
chezmoi diff

# Apply changes
chezmoi apply

# Update from source
chezmoi update

# Status
chezmoi status

# Managed files
chezmoi managed

# Unmanaged files
chezmoi unmanaged
```

## Rollback

If something goes wrong:

```bash
# Restore from backup
chezmoi archive | tar -xf - -C ~/

# Or manually
cp ~/.local/share/chezmoi/dot_zshrc ~/.zshrc
```

## Resources

- [chezmoi Documentation](https://www.chezmoi.io/)
- [chezmoi Quick Start](https://www.chezmoi.io/quick-start/)
- [Template Functions](https://www.chezmoi.io/reference/templates/functions/)
