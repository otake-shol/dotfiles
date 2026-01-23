# Configuration Files Reference

Overview of all configuration files and their purposes.

## Shell Configuration

### .zshrc

Main Zsh configuration:

| Section | Purpose |
|---------|---------|
| Environment | PATH, variables |
| Oh My Zsh | Theme, plugins |
| Aliases | Load alias files |
| Functions | Shell functions |
| Completions | Tab completion |
| Key bindings | Keyboard shortcuts |

### .aliases

Alias loader that sources modular alias files.

### aliases/

Modular alias files:

| File | Contents |
|------|----------|
| `core.zsh` | Basic commands, navigation |
| `git.zsh` | Git and GitHub CLI |
| `docker.zsh` | Docker and Compose |
| `kubernetes.zsh` | kubectl, helm |

## Editor Configuration

### nvim/.config/nvim/init.lua

Neovim configuration with:

- Plugin management (lazy.nvim)
- LSP configuration
- Keymappings
- UI settings
- Colorscheme (TokyoNight)

## Terminal Configuration

### tmux/.tmux.conf

tmux configuration:

- Prefix key: `Ctrl+a`
- Mouse support
- Vi-mode navigation
- Plugin manager (TPM)
- TokyoNight theme

### ghostty/config

Ghostty terminal settings:

```ini
font-family = JetBrains Mono
font-size = 14
theme = tokyonight
cursor-style = block
```

## Git Configuration

### git/.gitconfig

Global Git settings:

| Section | Settings |
|---------|----------|
| `[user]` | Name, email |
| `[core]` | Editor, pager (delta) |
| `[alias]` | Git shortcuts |
| `[diff]` | Diff settings |
| `[merge]` | Merge settings |
| `[init]` | Default branch |

### git/.gitignore_global

Global ignore patterns:

- OS files (`.DS_Store`, `Thumbs.db`)
- Editor files (`.idea/`, `.vscode/`)
- Dependencies (`node_modules/`)
- Environment (`.env`)
- Logs (`*.log`)

### git/commit-template.txt

Conventional commit template.

## Tool Configuration

### bat/config

bat settings:

```
--theme="tokyonight"
--style="numbers,changes,header"
--italic-text=always
```

### .tool-versions

asdf version pinning:

```
nodejs 20.10.0
python 3.12.0
ruby 3.3.0
```

### .editorconfig

Editor-agnostic settings:

```ini
root = true

[*]
indent_style = space
indent_size = 2
end_of_line = lf
charset = utf-8
trim_trailing_whitespace = true
insert_final_newline = true
```

## Claude Code Configuration

### .claude/settings.json

Permissions and hooks:

```json
{
  "permissions": {
    "allow": ["Bash(git *)", "Edit", "Read"]
  },
  "hooks": {
    "post-tool-call": [...]
  }
}
```

### .claude/CLAUDE.md

Global instructions for Claude Code.

## Package Management

### Brewfile

Essential packages (new Mac setup).

### Brewfile.full

All packages (complete environment).

### Brewfile.linux

Linux-specific packages (CLI only).

## Creating Local Overrides

### ~/.zshrc.local

Machine-specific Zsh settings:

```bash
export DOTFILES_PROFILE=work
export HTTP_PROXY="http://proxy:8080"
```

### ~/.gitconfig.local

Machine-specific Git settings:

```ini
[user]
    email = work@company.com
[http]
    proxy = http://proxy:8080
```

## File Locations

After installation, files are symlinked:

| Source | Target |
|--------|--------|
| `dotfiles/.zshrc` | `~/.zshrc` |
| `dotfiles/.aliases` | `~/.aliases` |
| `dotfiles/nvim/.config/nvim` | `~/.config/nvim` |
| `dotfiles/tmux/.tmux.conf` | `~/.tmux.conf` |
| `dotfiles/git/.gitconfig` | `~/.gitconfig` |
| `dotfiles/ghostty/config` | `~/.config/ghostty/config` |
