# Installation

Detailed installation instructions for all platforms.

## Installation Options

### Full Installation (Recommended)

Installs everything including GUI applications:

```bash
bash bootstrap.sh
```

### CLI Only

Skip GUI applications:

```bash
bash bootstrap.sh --skip-apps
```

### Linux/WSL Specific

For Linux-specific setup:

```bash
bash bootstrap.sh --linux-only
```

### Dry Run

Preview changes without applying:

```bash
bash bootstrap.sh --dry-run
```

## Manual Installation

If you prefer manual control:

### 1. Install Homebrew

=== "macOS"

    ```bash
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    ```

=== "Linux"

    ```bash
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add to PATH
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    ```

### 2. Install Packages

```bash
# Essential packages
brew bundle --file=Brewfile

# All packages (optional)
brew bundle --file=Brewfile.full
```

### 3. Create Symlinks

Using GNU Stow (recommended):

```bash
make install
```

Or manually:

```bash
ln -sf ~/dotfiles/.zshrc ~/.zshrc
ln -sf ~/dotfiles/.aliases ~/.aliases
# ... etc
```

### 4. Install Oh My Zsh

```bash
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### 5. Install Zsh Plugins

```bash
# zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
```

## Uninstallation

To remove all symlinks:

```bash
make uninstall
```

## Troubleshooting

### Homebrew Issues

```bash
# Update Homebrew
brew update

# Fix permissions
sudo chown -R $(whoami) $(brew --prefix)/*
```

### Symlink Conflicts

If existing files conflict:

```bash
# Backup existing files
mv ~/.zshrc ~/.zshrc.backup

# Then re-run
bash bootstrap.sh
```

### Oh My Zsh Issues

```bash
# Reinstall Oh My Zsh
rm -rf ~/.oh-my-zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```
