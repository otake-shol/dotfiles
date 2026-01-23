#!/bin/bash
# bootstrap.sh - 新しいMacの自動セットアップスクリプト
# 使用方法: bash bootstrap.sh

set -e  # エラーで停止

# カラー出力
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  dotfiles セットアップスクリプト${NC}"
echo -e "${BLUE}========================================${NC}"

# ========================================
# 1. Homebrewのインストール確認
# ========================================
echo -e "\n${YELLOW}[1/5] Homebrewの確認...${NC}"
if ! command -v brew &> /dev/null; then
    echo -e "${RED}Homebrewがインストールされていません。${NC}"
    echo -e "${YELLOW}Homebrewをインストールしますか? (y/n)${NC}"
    read -r answer
    if [ "$answer" = "y" ]; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        # Homebrew PATH設定 (Apple Silicon / Intel 両対応)
        if [[ $(uname -m) == "arm64" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            eval "$(/usr/local/bin/brew shellenv)"
        fi
        echo -e "${GREEN}Homebrewのインストールが完了しました。${NC}"
    else
        echo -e "${RED}Homebrewが必要です。終了します。${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✓ Homebrewはインストール済みです${NC}"
    # 既存のHomebrew PATH設定を確認 (Apple Silicon / Intel 両対応)
    if [[ $(uname -m) == "arm64" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        eval "$(/usr/local/bin/brew shellenv)"
    fi
fi

# ========================================
# 2. アプリケーションのインストール
# ========================================
echo -e "\n${YELLOW}[2/5] アプリケーションのインストール...${NC}"
echo -e "${YELLOW}どのBrewfileを使用しますか?${NC}"
echo -e "  1) Brewfile (必須ツールのみ - 推奨)"
echo -e "  2) Brewfile.full (全ツール)"
read -r brewfile_choice

case $brewfile_choice in
    1)
        BREWFILE="Brewfile"
        echo -e "${GREEN}必須ツールをインストールします${NC}"
        ;;
    2)
        BREWFILE="Brewfile.full"
        echo -e "${YELLOW}全ツールをインストールします（時間がかかります）${NC}"
        ;;
    *)
        BREWFILE="Brewfile"
        echo -e "${GREEN}デフォルト: 必須ツールをインストールします${NC}"
        ;;
esac

if [ -f "$BREWFILE" ]; then
    brew bundle --file="$BREWFILE"
    echo -e "${GREEN}✓ アプリケーションのインストールが完了しました${NC}"
else
    echo -e "${RED}$BREWFILE が見つかりません${NC}"
    exit 1
fi

# ========================================
# 3. dotfilesのシンボリックリンク作成
# ========================================
echo -e "\n${YELLOW}[3/5] dotfilesのシンボリックリンク作成...${NC}"

# zsh
ln -sf ~/dotfiles/.zshrc ~/.zshrc
ln -sf ~/dotfiles/.aliases ~/.aliases
echo -e "${GREEN}✓ zsh設定をリンクしました${NC}"

# editorconfig / tool-versions
ln -sf ~/dotfiles/.editorconfig ~/.editorconfig
ln -sf ~/dotfiles/.tool-versions ~/.tool-versions
echo -e "${GREEN}✓ editorconfig/tool-versionsをリンクしました${NC}"

# git
ln -sf ~/dotfiles/git/.gitconfig ~/.gitconfig
ln -sf ~/dotfiles/git/.gitignore_global ~/.gitignore_global
echo -e "${GREEN}✓ git設定をリンクしました${NC}"

# ssh
mkdir -p ~/.ssh/sockets
chmod 700 ~/.ssh
if [ ! -f ~/.ssh/config ]; then
    ln -sf ~/dotfiles/ssh/config ~/.ssh/config
    chmod 600 ~/.ssh/config
    echo -e "${GREEN}✓ ssh設定をリンクしました${NC}"
else
    echo -e "${YELLOW}⚠ ssh設定は既存のため、スキップしました${NC}"
fi

# ghostty
mkdir -p ~/.config/ghostty
ln -sf ~/dotfiles/ghostty/config ~/.config/ghostty/config
ln -sf ~/dotfiles/ghostty/shaders ~/.config/ghostty/shaders
echo -e "${GREEN}✓ ghostty設定をリンクしました${NC}"

# claude
mkdir -p ~/.claude
ln -sf ~/dotfiles/.claude/CLAUDE.md ~/.claude/CLAUDE.md
ln -sf ~/dotfiles/.claude/settings.json ~/.claude/settings.json
ln -sf ~/dotfiles/.claude/agents ~/.claude/agents
ln -sf ~/dotfiles/.claude/plugins ~/.claude/plugins
ln -sf ~/dotfiles/.claude/hooks ~/.claude/hooks
ln -sf ~/dotfiles/.claude/commands ~/.claude/commands
echo -e "${GREEN}✓ Claude Code設定をリンクしました${NC}"

# gh (GitHub CLI)
mkdir -p ~/.config/gh
ln -sf ~/dotfiles/gh/config.yml ~/.config/gh/config.yml
echo -e "${GREEN}✓ GitHub CLI設定をリンクしました${NC}"

# nvim
mkdir -p ~/.config/nvim
ln -sf ~/dotfiles/nvim/.config/nvim/init.lua ~/.config/nvim/init.lua
echo -e "${GREEN}✓ Neovim設定をリンクしました${NC}"

# tmux
ln -sf ~/dotfiles/tmux/.tmux.conf ~/.tmux.conf
echo -e "${GREEN}✓ tmux設定をリンクしました${NC}"

# bat
mkdir -p ~/.config/bat
ln -sf ~/dotfiles/bat/.config/bat/config ~/.config/bat/config
echo -e "${GREEN}✓ bat設定をリンクしました${NC}"

# espanso
ESPANSO_CONFIG_DIR="$HOME/Library/Application Support/espanso"
if command -v espanso &> /dev/null || [ -d "$ESPANSO_CONFIG_DIR" ]; then
    mkdir -p "$ESPANSO_CONFIG_DIR/match"
    ln -sf ~/dotfiles/espanso/match/ai-prompts.yml "$ESPANSO_CONFIG_DIR/match/ai-prompts.yml"
    echo -e "${GREEN}✓ espanso設定をリンクしました${NC}"
else
    echo -e "${YELLOW}⚠ espansoがインストールされていません。スキップします${NC}"
fi

# antigravity
ANTIGRAVITY_USER_DIR="$HOME/Library/Application Support/Antigravity/User"
if [ -d "$HOME/Library/Application Support/Antigravity" ]; then
    mkdir -p "$ANTIGRAVITY_USER_DIR"
    ln -sf ~/dotfiles/antigravity/settings.json "$ANTIGRAVITY_USER_DIR/settings.json"
    ln -sf ~/dotfiles/antigravity/keybindings.json "$ANTIGRAVITY_USER_DIR/keybindings.json"
    echo -e "${GREEN}✓ Antigravity設定をリンクしました${NC}"
else
    echo -e "${YELLOW}⚠ Antigravityがインストールされていません。スキップします${NC}"
fi

# ========================================
# 4. Oh My Zshのセットアップ
# ========================================
echo -e "\n${YELLOW}[4/5] Oh My Zshのセットアップ...${NC}"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo -e "${YELLOW}Oh My Zshをインストールしますか? (y/n)${NC}"
    read -r answer
    if [ "$answer" = "y" ]; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

        # Powerlevel10k
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
            ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

        # zsh-autosuggestions
        git clone https://github.com/zsh-users/zsh-autosuggestions \
            ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

        # zsh-syntax-highlighting
        git clone https://github.com/zsh-users/zsh-syntax-highlighting \
            ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

        echo -e "${GREEN}✓ Oh My Zshのセットアップが完了しました${NC}"
    fi
else
    echo -e "${GREEN}✓ Oh My Zshはインストール済みです${NC}"
fi

# ========================================
# 5. 追加設定
# ========================================
echo -e "\n${YELLOW}[5/5] 追加設定...${NC}"

# macOS defaults設定
if [ -f ~/dotfiles/scripts/macos-defaults.sh ]; then
    bash ~/dotfiles/scripts/macos-defaults.sh
fi

# git-secrets設定
if command -v git-secrets &> /dev/null; then
    git secrets --install ~/.git-templates/git-secrets 2>/dev/null || true
    git secrets --register-aws --global 2>/dev/null || true
    echo -e "${GREEN}✓ git-secretsを設定しました${NC}"
fi

# asdf プラグイン・バージョンインストール
if command -v asdf &> /dev/null; then
    echo -e "${YELLOW}asdfプラグインをセットアップ中...${NC}"
    asdf plugin add nodejs 2>/dev/null || true
    asdf plugin add python 2>/dev/null || true

    if [ -f ~/.tool-versions ]; then
        asdf install
        echo -e "${GREEN}✓ asdfバージョンをインストールしました${NC}"
    fi
fi

# Neovim TokyoNightテーマ
TOKYONIGHT_DIR="$HOME/.local/share/nvim/site/pack/colors/start/tokyonight.nvim"
if [ ! -d "$TOKYONIGHT_DIR" ]; then
    mkdir -p "$(dirname "$TOKYONIGHT_DIR")"
    git clone --depth=1 https://github.com/folke/tokyonight.nvim "$TOKYONIGHT_DIR"
    echo -e "${GREEN}✓ Neovim TokyoNightテーマをインストールしました${NC}"
else
    echo -e "${GREEN}✓ Neovim TokyoNightテーマはインストール済みです${NC}"
fi

# TPM（tmuxプラグインマネージャー）
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [ ! -d "$TPM_DIR" ]; then
    git clone --depth=1 https://github.com/tmux-plugins/tpm "$TPM_DIR"
    echo -e "${GREEN}✓ TPM（tmuxプラグインマネージャー）をインストールしました${NC}"
    echo -e "${YELLOW}  ※ tmux起動後に prefix + I でプラグインをインストールしてください${NC}"
else
    echo -e "${GREEN}✓ TPMはインストール済みです${NC}"
fi

# ローカル設定ファイルのセットアップ
echo -e "\n${YELLOW}ローカル設定ファイルのセットアップ...${NC}"

# .gitconfig.local
if [ ! -f ~/.gitconfig.local ]; then
    echo -e "${YELLOW}Git ユーザー情報を設定します${NC}"
    read -p "Git ユーザー名: " git_name
    read -p "Git メールアドレス: " git_email
    cat > ~/.gitconfig.local << EOF
[user]
	name = $git_name
	email = $git_email
EOF
    echo -e "${GREEN}✓ ~/.gitconfig.local を作成しました${NC}"
else
    echo -e "${GREEN}✓ ~/.gitconfig.local は既存です${NC}"
fi

# .zshrc.local
if [ ! -f ~/.zshrc.local ]; then
    cp ~/dotfiles/.zshrc.local.template ~/.zshrc.local
    echo -e "${GREEN}✓ ~/.zshrc.local を作成しました（テンプレートからコピー）${NC}"
    echo -e "${YELLOW}  ※ 必要に応じて ~/.zshrc.local を編集してください${NC}"
else
    echo -e "${GREEN}✓ ~/.zshrc.local は既存です${NC}"
fi

# ========================================
# 完了
# ========================================
echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}  セットアップが完了しました！${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "\n${YELLOW}次のステップ:${NC}"
echo -e "  1. ターミナルを再起動するか、'source ~/.zshrc' を実行"
echo -e "  2. Powerlevel10kの設定: 'p10k configure'"
echo -e "  3. Nerd Fontをターミナルに設定"
echo -e "\n${BLUE}追加のアプリケーションは docs/APPS.md を参照してください${NC}"
