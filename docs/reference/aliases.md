# Aliases Reference

Complete list of all aliases organized by category.

## Core Aliases

### Navigation

| Alias | Command | Description |
|-------|---------|-------------|
| `..` | `cd ..` | Go up one directory |
| `...` | `cd ../..` | Go up two directories |
| `....` | `cd ../../..` | Go up three directories |
| `~` | `cd ~` | Go to home directory |
| `-` | `cd -` | Go to previous directory |

### File Operations

| Alias | Command | Description |
|-------|---------|-------------|
| `ls` | `eza` | List files (modern) |
| `ll` | `eza -la --icons --git` | Long format with icons |
| `la` | `eza -a` | Show hidden files |
| `lt` | `eza --tree --level=2` | Tree view |
| `cat` | `bat` | View files with syntax highlighting |
| `less` | `bat --paging=always` | Page through files |

### Search

| Alias | Command | Description |
|-------|---------|-------------|
| `grep` | `rg` | Search with ripgrep |
| `find` | `fd` | Find files |

### System

| Alias | Command | Description |
|-------|---------|-------------|
| `top` | `btop` | System monitor |
| `ps` | `procs` | Process list |
| `du` | `dust` | Disk usage |
| `df` | `duf` | Filesystem usage |

## Git Aliases

### Basic Operations

| Alias | Command | Description |
|-------|---------|-------------|
| `g` | `git` | Git shorthand |
| `gs` | `git status` | Status |
| `ga` | `git add` | Stage files |
| `gaa` | `git add --all` | Stage all |
| `gc` | `git commit` | Commit |
| `gcm` | `git commit -m` | Commit with message |
| `gp` | `git push` | Push |
| `gl` | `git pull` | Pull |

### Branching

| Alias | Command | Description |
|-------|---------|-------------|
| `gco` | `git checkout` | Checkout |
| `gcb` | `git checkout -b` | Create and checkout branch |
| `gb` | `git branch` | List branches |
| `gbd` | `git branch -d` | Delete branch |
| `gbD` | `git branch -D` | Force delete branch |

### History

| Alias | Command | Description |
|-------|---------|-------------|
| `glog` | `git log --oneline --graph --decorate` | Pretty log |
| `gloga` | `git log --oneline --graph --decorate --all` | Log all branches |
| `gd` | `git diff` | Diff |
| `gds` | `git diff --staged` | Diff staged |
| `gshow` | `git show` | Show commit |

### Stash

| Alias | Command | Description |
|-------|---------|-------------|
| `gst` | `git stash` | Stash changes |
| `gstp` | `git stash pop` | Pop stash |
| `gstl` | `git stash list` | List stashes |
| `gstd` | `git stash drop` | Drop stash |

### Advanced

| Alias | Command | Description |
|-------|---------|-------------|
| `gwip` | `git add -A && git commit -m "WIP"` | Work in progress |
| `gunwip` | `git log -1 --format="%s" \| grep -q "WIP" && git reset HEAD~1` | Undo WIP |
| `gclean` | `git clean -fd` | Clean untracked |
| `greset` | `git reset --hard HEAD` | Reset to HEAD |

## Docker Aliases

| Alias | Command | Description |
|-------|---------|-------------|
| `d` | `docker` | Docker shorthand |
| `dc` | `docker compose` | Docker Compose |
| `dps` | `docker ps` | List containers |
| `dpsa` | `docker ps -a` | List all containers |
| `di` | `docker images` | List images |
| `drm` | `docker rm` | Remove container |
| `drmi` | `docker rmi` | Remove image |
| `dprune` | `docker system prune -af` | Prune all |
| `dlogs` | `docker logs -f` | Follow logs |
| `dexec` | `docker exec -it` | Execute in container |

## Kubernetes Aliases

| Alias | Command | Description |
|-------|---------|-------------|
| `k` | `kubectl` | kubectl shorthand |
| `kgp` | `kubectl get pods` | Get pods |
| `kgs` | `kubectl get services` | Get services |
| `kgd` | `kubectl get deployments` | Get deployments |
| `kga` | `kubectl get all` | Get all resources |
| `kd` | `kubectl describe` | Describe resource |
| `kl` | `kubectl logs` | View logs |
| `klf` | `kubectl logs -f` | Follow logs |
| `kex` | `kubectl exec -it` | Execute in pod |
| `kctx` | `kubectx` | Switch context |
| `kns` | `kubens` | Switch namespace |

## Utility Aliases

### Network

| Alias | Command | Description |
|-------|---------|-------------|
| `ip` | `curl -s ifconfig.me` | Public IP |
| `localip` | `ipconfig getifaddr en0` | Local IP |
| `ports` | `lsof -i -P -n \| grep LISTEN` | Listening ports |

### Development

| Alias | Command | Description |
|-------|---------|-------------|
| `serve` | `python -m http.server 8000` | Simple HTTP server |
| `json` | `python -m json.tool` | Pretty print JSON |
| `urldecode` | `python -c "import sys, urllib.parse as ul; print(ul.unquote(sys.argv[1]))"` | URL decode |
| `urlencode` | `python -c "import sys, urllib.parse as ul; print(ul.quote(sys.argv[1]))"` | URL encode |

### Dotfiles

| Alias | Command | Description |
|-------|---------|-------------|
| `dotfiles` | `cd ~/dotfiles` | Go to dotfiles |
| `dothelp` | Show aliases/functions | Help system |
| `dotverify` | Verify setup | Verification |
| `dotup` | Check updates | Update check |
| `dotupdate` | Update all | Full update |
