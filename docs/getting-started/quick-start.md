# Quick Start

Get up and running in minutes with this quick start guide.

## Prerequisites

=== "macOS"

    - macOS 12.0+ (Monterey or later)
    - Xcode Command Line Tools

    ```bash
    xcode-select --install
    ```

=== "Linux"

    - Ubuntu 20.04+ / Debian 11+ / Fedora 35+ / Arch Linux
    - curl, git

    ```bash
    # Ubuntu/Debian
    sudo apt update && sudo apt install -y curl git

    # Fedora
    sudo dnf install -y curl git

    # Arch
    sudo pacman -S curl git
    ```

=== "WSL"

    - Windows 10/11 with WSL2
    - Ubuntu or Debian distribution recommended

    ```powershell
    # Install WSL2 (PowerShell as Admin)
    wsl --install -d Ubuntu
    ```

## Installation

### Step 1: Clone the Repository

```bash
git clone https://github.com/otake-shol/dotfiles.git ~/dotfiles
```

### Step 2: Run Bootstrap

```bash
cd ~/dotfiles && bash bootstrap.sh
```

!!! tip "Preview Changes First"
    Use `--dry-run` to see what will happen without making changes:
    ```bash
    bash bootstrap.sh --dry-run
    ```

### Step 3: Restart Your Shell

```bash
exec zsh
```

## What Gets Installed

The bootstrap script will:

1. **Install Homebrew** (macOS/Linux) or system packages
2. **Install CLI tools** from Brewfile
3. **Create symlinks** for all configuration files
4. **Install Oh My Zsh** with plugins
5. **Configure Git** with useful defaults
6. **Set up Neovim** with LSP support

## Verify Installation

Run the verification script:

```bash
dotverify
```

This will check:

- ✅ All symlinks are correct
- ✅ Required tools are installed
- ✅ Configurations are valid

## Next Steps

- [Customize your shell](configuration.md)
- [Explore modern CLI tools](../features/cli-tools.md)
- [Set up AI-driven development](../features/ai-driven-dev.md)
