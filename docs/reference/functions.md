# Functions Reference

Custom shell functions for enhanced productivity.

## fzf Integration

### fvim

Select file and open in Neovim:

```bash
fvim
```

Usage:

1. Run `fvim`
2. Type to filter files
3. Press Enter to open in nvim

### fbr

Fuzzy branch selection:

```bash
fbr
```

Usage:

1. Run `fbr`
2. Select branch
3. Automatically checks out

### fshow

Browse Git history with preview:

```bash
fshow
```

Features:

- Commit list with graph
- Preview shows diff
- Enter to view full commit

### fkill

Select and kill process:

```bash
fkill
```

Usage:

1. Run `fkill`
2. Select process
3. Confirm kill

### fcd

Fuzzy directory navigation:

```bash
fcd
```

Usage:

1. Run `fcd`
2. Type to filter directories
3. Enter to navigate

### fstash

Manage Git stashes:

```bash
fstash
```

Usage:

1. Run `fstash`
2. Select stash
3. Apply selected stash

## Utility Functions

### mkcd

Create directory and navigate to it:

```bash
mkcd my-project
# Creates my-project/ and cd into it
```

### extract

Extract any archive format:

```bash
extract archive.tar.gz
extract file.zip
extract package.7z
```

Supported formats:

- `.tar.gz`, `.tgz`
- `.tar.bz2`, `.tbz2`
- `.tar.xz`
- `.zip`
- `.rar`
- `.7z`
- `.gz`, `.bz2`, `.xz`

### backup

Create timestamped backup:

```bash
backup important-file.txt
# Creates important-file.txt.2024-01-15-143052.bak
```

### weather

Show weather forecast:

```bash
weather          # Current location
weather Tokyo    # Specific city
```

### cheat

Show command cheatsheet:

```bash
cheat tar
cheat git
cheat curl
```

Uses [cheat.sh](https://cheat.sh) for quick reference.

## Git Functions

### gbc

Git branch cleanup (delete merged branches):

```bash
gbc
# Deletes all local branches merged into main/master
```

### gundo

Undo last commit (keep changes):

```bash
gundo
# Equivalent to git reset --soft HEAD~1
```

### gsync

Sync fork with upstream:

```bash
gsync
# Fetches upstream and rebases
```

## Development Functions

### ports

Show processes using specific port:

```bash
ports 3000
# Shows process using port 3000
```

### killport

Kill process on specific port:

```bash
killport 3000
# Kills process on port 3000
```

### serve

Start HTTP server:

```bash
serve           # Port 8000
serve 3000      # Custom port
```

### jsonformat

Format JSON from clipboard:

```bash
pbpaste | jsonformat
# Pretty prints JSON
```

## System Functions

### cleanup

System cleanup:

```bash
cleanup
```

Actions:

- Empty trash
- Clear system caches
- Remove old logs
- Clean Homebrew cache

### diskusage

Show disk usage summary:

```bash
diskusage
# Shows usage by directory
```

### sysinfo

Display system information:

```bash
sysinfo
# CPU, memory, disk, network info
```

## Docker Functions

### dsh

Shell into Docker container:

```bash
dsh container_name
# Opens bash/sh in container
```

### dclear

Clean up Docker resources:

```bash
dclear
# Removes stopped containers, unused images
```

### dbuild

Build and tag Docker image:

```bash
dbuild my-app
# Builds with tag my-app:latest
```

## Adding Custom Functions

Create a file in your dotfiles:

```bash
# ~/.functions.local

my_function() {
    echo "Hello, $1!"
}
```

Source it in `.zshrc.local`:

```bash
source ~/.functions.local
```
