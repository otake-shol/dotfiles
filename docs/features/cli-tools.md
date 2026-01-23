# Modern CLI Tools

Replace legacy tools with modern, user-friendly alternatives.

## Tool Comparison

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
| `top` | `btop` | Beautiful resource monitor |

## bat

Syntax highlighting for `cat`:

```bash
# Basic usage
bat file.py

# Show line numbers
bat -n file.py

# Show diff
bat --diff file.py

# Custom theme
bat --theme="TokyoNight" file.py
```

Aliases:

```bash
cat   # → bat
less  # → bat --paging=always
```

## eza

Modern replacement for `ls`:

```bash
# List with icons
eza --icons

# Long format with Git status
eza -la --git

# Tree view
eza --tree --level=2

# Sort by modification time
eza -la --sort=modified
```

Aliases:

```bash
ls    # → eza
ll    # → eza -la --icons --git
lt    # → eza --tree --level=2
```

## ripgrep

Blazingly fast search:

```bash
# Search pattern
rg "function"

# Search specific file type
rg -t py "import"

# Search with context
rg -C 3 "error"

# Search hidden files
rg --hidden "config"

# Count matches
rg -c "TODO"
```

Aliases:

```bash
grep  # → rg
```

## fd

User-friendly `find`:

```bash
# Find by name
fd "config"

# Find by extension
fd -e js

# Find hidden files
fd -H ".env"

# Execute command
fd -e py -x python {}
```

## zoxide

Smarter `cd`:

```bash
# Jump to directory (learned from history)
z projects

# Interactive selection
zi

# Add directory to database
zoxide add ~/important/path
```

## fzf

Fuzzy finder for everything:

```bash
# File selection
fzf

# With preview
fzf --preview 'bat --color=always {}'

# Command history
Ctrl+R

# Directory navigation
Ctrl+T

# Integration with vim
vim $(fzf)
```

## delta

Beautiful Git diffs:

```bash
# Configured automatically in .gitconfig
git diff
git show
git log -p
```

Features:

- Syntax highlighting
- Line numbers
- Side-by-side view
- Word-level diff

## dust

Disk usage visualization:

```bash
# Current directory
dust

# Specific directory
dust ~/Downloads

# Limit depth
dust -d 2

# Show only top N
dust -n 10
```

## procs

Modern `ps`:

```bash
# All processes
procs

# Filter by name
procs node

# Tree view
procs --tree

# Watch mode
procs --watch
```

## btop

Beautiful resource monitor:

```bash
# Launch
btop

# Features:
# - CPU, memory, disk, network
# - Process management
# - Customizable themes
```
