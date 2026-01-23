#!/bin/bash
# post-create.sh - devcontainer初期化スクリプト

set -e

echo "=== dotfiles Development Container Setup ==="

# Cargo binaries to PATH
export PATH="$HOME/.cargo/bin:$PATH"

# Install Oh My Zsh plugins
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
fi

# Setup zoxide
eval "$(zoxide init zsh)" 2>/dev/null || true

# Create symlinks (development mode - don't overwrite existing)
echo "Creating development symlinks..."
cd ~/dotfiles

# Only link if target doesn't exist
[ ! -f ~/.zshrc ] && ln -sf ~/dotfiles/.zshrc ~/.zshrc
[ ! -f ~/.aliases ] && ln -sf ~/dotfiles/.aliases ~/.aliases

# Create config directories
mkdir -p ~/.config/{nvim,bat}

echo "=== Setup Complete ==="
echo ""
echo "Available commands:"
echo "  make test     - Run tests"
echo "  make lint     - Run shellcheck"
echo "  bash bootstrap.sh --dry-run - Test bootstrap"
