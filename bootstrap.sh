#!/bin/bash
# bootstrap.sh - 新しいMacの自動セットアップスクリプト
# 使用方法: bash bootstrap.sh
# オプション:
#   -n, --dry-run    実際の変更を行わずシミュレーション
#   -h, --help       ヘルプを表示
#   -v, --verbose    詳細出力

set -e  # エラーで停止

# ========================================
# 設定
# ========================================
DRY_RUN=false
VERBOSE=false
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# カラー出力
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ログファイル
LOG_FILE="$HOME/.dotfiles-setup.log"

# ========================================
# ヘルプ
# ========================================
show_help() {
    cat << EOF
使用方法: bash bootstrap.sh [オプション]

新しいMacの自動セットアップスクリプト

オプション:
  -n, --dry-run    実際の変更を行わずシミュレーション実行
  -v, --verbose    詳細な出力を表示
  -h, --help       このヘルプを表示

例:
  bash bootstrap.sh           # 通常実行
  bash bootstrap.sh --dry-run # ドライラン（変更なし）
  bash bootstrap.sh -n -v     # ドライラン + 詳細出力
EOF
    exit 0
}

# ========================================
# 引数解析
# ========================================
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -n|--dry-run)
            DRY_RUN=true
            ;;
        -v|--verbose)
            VERBOSE=true
            ;;
        -h|--help)
            show_help
            ;;
        *)
            echo -e "${RED}不明なオプション: $1${NC}"
            show_help
            ;;
    esac
    shift
done

# ========================================
# ユーティリティ関数
# ========================================

# ログ関数
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
    if [ "$VERBOSE" = true ]; then
        echo -e "${CYAN}[LOG] $1${NC}"
    fi
}

# ドライラン対応コマンド実行
run_cmd() {
    if [ "$DRY_RUN" = true ]; then
        echo -e "${CYAN}[DRY RUN] $*${NC}"
        log "[DRY RUN] $*"
    else
        "$@"
    fi
}

# クリーンアップ処理
cleanup() {
    if [ $? -ne 0 ]; then
        echo -e "${RED}エラーが発生しました。ログを確認してください: $LOG_FILE${NC}"
        log "ERROR: Setup failed"
    fi
}
trap cleanup EXIT

# ========================================
# 依存関係チェック
# ========================================
check_dependencies() {
    local missing=()

    # 必須コマンド
    command -v git &>/dev/null || missing+=("git")
    command -v curl &>/dev/null || missing+=("curl")

    if [ ${#missing[@]} -gt 0 ]; then
        echo -e "${RED}エラー: 必要なコマンドがインストールされていません${NC}"
        echo -e "${RED}不足: ${missing[*]}${NC}"
        echo -e "${YELLOW}Xcode Command Line Toolsをインストールしてください:${NC}"
        echo -e "  xcode-select --install"
        exit 1
    fi

    log "Dependencies check passed"
}

# OS/アーキテクチャ検出
detect_system() {
    OS="$(uname -s)"
    ARCH="$(uname -m)"

    if [ "$OS" != "Darwin" ]; then
        echo -e "${RED}このスクリプトはmacOS専用です${NC}"
        exit 1
    fi

    if [ "$ARCH" = "arm64" ]; then
        HOMEBREW_PREFIX="/opt/homebrew"
    else
        HOMEBREW_PREFIX="/usr/local"
    fi

    log "Detected: $OS ($ARCH), Homebrew prefix: $HOMEBREW_PREFIX"
}

# 冪等なシンボリックリンク作成関数
safe_link() {
    local src="$1"
    local dest="$2"

    if [ "$DRY_RUN" = true ]; then
        if [ -L "$dest" ]; then
            echo -e "${CYAN}[DRY RUN] Would update symlink: $dest -> $src${NC}"
        elif [ -e "$dest" ]; then
            echo -e "${CYAN}[DRY RUN] Would backup and link: $dest -> $src${NC}"
        else
            echo -e "${CYAN}[DRY RUN] Would create symlink: $dest -> $src${NC}"
        fi
        log "[DRY RUN] Link: $src -> $dest"
        return
    fi

    if [ -L "$dest" ]; then
        # 既存のシンボリックリンクを削除
        rm "$dest"
    elif [ -e "$dest" ]; then
        # 既存ファイルをバックアップ
        mv "$dest" "${dest}.backup.$(date +%Y%m%d%H%M%S)"
        echo -e "${YELLOW}  バックアップ: ${dest}.backup.*${NC}"
        log "Backed up: $dest"
    fi

    ln -sf "$src" "$dest"
    log "Linked: $src -> $dest"
}

# ========================================
# 初期化
# ========================================
check_dependencies
detect_system

log "=== Setup started ==="

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  dotfiles セットアップスクリプト${NC}"
echo -e "${BLUE}========================================${NC}"
if [ "$DRY_RUN" = true ]; then
    echo -e "${CYAN}  [ドライランモード - 実際の変更は行いません]${NC}"
fi

# ========================================
# 0. Apple Silicon: Rosetta 2確認
# ========================================
if [[ "$ARCH" == "arm64" ]]; then
    echo -e "\n${YELLOW}[0/6] Rosetta 2の確認...${NC}"
    if ! /usr/bin/pgrep -q oahd; then
        echo -e "${YELLOW}Rosetta 2をインストールしますか? (一部のx86アプリに必要) (y/n)${NC}"
        read -r answer
        if [ "$answer" = "y" ]; then
            softwareupdate --install-rosetta --agree-to-license
            echo -e "${GREEN}✓ Rosetta 2をインストールしました${NC}"
            log "Installed Rosetta 2"
        fi
    else
        echo -e "${GREEN}✓ Rosetta 2はインストール済みです${NC}"
    fi
fi

# ========================================
# 1. Homebrewのインストール確認
# ========================================
echo -e "\n${YELLOW}[1/6] Homebrewの確認...${NC}"
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
echo -e "\n${YELLOW}[2/6] アプリケーションのインストール...${NC}"
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
echo -e "\n${YELLOW}[3/6] dotfilesのシンボリックリンク作成...${NC}"

# zsh
safe_link ~/dotfiles/.zshrc ~/.zshrc
safe_link ~/dotfiles/.aliases ~/.aliases
echo -e "${GREEN}✓ zsh設定をリンクしました${NC}"

# editorconfig / tool-versions
safe_link ~/dotfiles/.editorconfig ~/.editorconfig
safe_link ~/dotfiles/.tool-versions ~/.tool-versions
echo -e "${GREEN}✓ editorconfig/tool-versionsをリンクしました${NC}"

# git
safe_link ~/dotfiles/git/.gitconfig ~/.gitconfig
safe_link ~/dotfiles/git/.gitignore_global ~/.gitignore_global
echo -e "${GREEN}✓ git設定をリンクしました${NC}"

# ssh
mkdir -p ~/.ssh/sockets
chmod 700 ~/.ssh
if [ ! -f ~/.ssh/config ] || [ -L ~/.ssh/config ]; then
    safe_link ~/dotfiles/ssh/config ~/.ssh/config
    chmod 600 ~/.ssh/config
    echo -e "${GREEN}✓ ssh設定をリンクしました${NC}"
else
    echo -e "${YELLOW}⚠ ssh設定は既存ファイルのため、スキップしました${NC}"
fi

# ghostty
mkdir -p ~/.config/ghostty
safe_link ~/dotfiles/ghostty/config ~/.config/ghostty/config
echo -e "${GREEN}✓ ghostty設定をリンクしました${NC}"

# claude
mkdir -p ~/.claude
safe_link ~/dotfiles/.claude/CLAUDE.md ~/.claude/CLAUDE.md
safe_link ~/dotfiles/.claude/settings.json ~/.claude/settings.json
safe_link ~/dotfiles/.claude/agents ~/.claude/agents
safe_link ~/dotfiles/.claude/plugins ~/.claude/plugins
safe_link ~/dotfiles/.claude/hooks ~/.claude/hooks
safe_link ~/dotfiles/.claude/commands ~/.claude/commands
echo -e "${GREEN}✓ Claude Code設定をリンクしました${NC}"

# gh (GitHub CLI)
mkdir -p ~/.config/gh
safe_link ~/dotfiles/gh/config.yml ~/.config/gh/config.yml
echo -e "${GREEN}✓ GitHub CLI設定をリンクしました${NC}"

# nvim
mkdir -p ~/.config/nvim
mkdir -p ~/.config/nvim/lua
safe_link ~/dotfiles/nvim/.config/nvim/init.lua ~/.config/nvim/init.lua
echo -e "${GREEN}✓ Neovim設定をリンクしました${NC}"

# tmux
safe_link ~/dotfiles/tmux/.tmux.conf ~/.tmux.conf
echo -e "${GREEN}✓ tmux設定をリンクしました${NC}"

# bat
mkdir -p ~/.config/bat
safe_link ~/dotfiles/bat/.config/bat/config ~/.config/bat/config
echo -e "${GREEN}✓ bat設定をリンクしました${NC}"

# atuin
mkdir -p ~/.config/atuin
safe_link ~/dotfiles/atuin/.config/atuin/config.toml ~/.config/atuin/config.toml
echo -e "${GREEN}✓ atuin設定をリンクしました${NC}"

# espanso
ESPANSO_CONFIG_DIR="$HOME/Library/Application Support/espanso"
if command -v espanso &> /dev/null || [ -d "$ESPANSO_CONFIG_DIR" ]; then
    mkdir -p "$ESPANSO_CONFIG_DIR/match"
    safe_link ~/dotfiles/espanso/match/ai-prompts.yml "$ESPANSO_CONFIG_DIR/match/ai-prompts.yml"
    echo -e "${GREEN}✓ espanso設定をリンクしました${NC}"
else
    echo -e "${YELLOW}⚠ espansoがインストールされていません。スキップします${NC}"
fi

# antigravity
ANTIGRAVITY_USER_DIR="$HOME/Library/Application Support/Antigravity/User"
if [ -d "$HOME/Library/Application Support/Antigravity" ]; then
    mkdir -p "$ANTIGRAVITY_USER_DIR"
    safe_link ~/dotfiles/antigravity/settings.json "$ANTIGRAVITY_USER_DIR/settings.json"
    safe_link ~/dotfiles/antigravity/keybindings.json "$ANTIGRAVITY_USER_DIR/keybindings.json"
    echo -e "${GREEN}✓ Antigravity設定をリンクしました${NC}"
else
    echo -e "${YELLOW}⚠ Antigravityがインストールされていません。スキップします${NC}"
fi

# ========================================
# 4. Oh My Zshのセットアップ
# ========================================
echo -e "\n${YELLOW}[4/6] Oh My Zshのセットアップ...${NC}"
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

        # zsh-completions
        git clone https://github.com/zsh-users/zsh-completions \
            ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-completions

        echo -e "${GREEN}✓ Oh My Zshのセットアップが完了しました${NC}"
    fi
else
    echo -e "${GREEN}✓ Oh My Zshはインストール済みです${NC}"
fi

# ========================================
# 5. 追加設定
# ========================================
echo -e "\n${YELLOW}[5/6] 追加設定...${NC}"

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
# 6. 完了
# ========================================
log "=== Setup completed successfully ==="

echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}  セットアップが完了しました！${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "\n${YELLOW}次のステップ:${NC}"
echo -e "  1. ターミナルを再起動するか、'source ~/.zshrc' を実行"
echo -e "  2. Powerlevel10kの設定: 'p10k configure'"
echo -e "  3. Nerd Fontをターミナルに設定"
echo -e "\n${BLUE}追加のアプリケーションは docs/APPS.md を参照してください${NC}"
echo -e "${BLUE}ログファイル: $LOG_FILE${NC}"
