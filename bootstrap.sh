#!/bin/bash
# bootstrap.sh - 新しいMac/Linuxの自動セットアップスクリプト
# 使用方法: bash bootstrap.sh
# オプション:
#   -n, --dry-run    実際の変更を行わずシミュレーション
#   -h, --help       ヘルプを表示
#   -v, --verbose    詳細出力
#   --linux-only     Linuxセットアップのみ実行
#   --skip-apps      アプリケーションインストールをスキップ

set -e  # エラーで停止

# ========================================
# 設定
# ========================================
DRY_RUN=false
VERBOSE=false
# shellcheck disable=SC2034  # 将来の拡張用
LINUX_ONLY=false
SKIP_APPS=false
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 共通ライブラリ読み込み
# shellcheck source=scripts/lib/common.sh
if [[ -f "${SCRIPT_DIR}/scripts/lib/common.sh" ]]; then
    source "${SCRIPT_DIR}/scripts/lib/common.sh"
else
    # フォールバック: common.shが無い場合の最小限の色定義
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    CYAN='\033[0;36m'
    NC='\033[0m'
fi

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
        --linux-only)
            # shellcheck disable=SC2034  # 将来の拡張用
            LINUX_ONLY=true
            ;;
        --skip-apps)
            SKIP_APPS=true
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

# プログレスバー表示
# 使用例: show_progress 3 7 "シンボリックリンク作成"
TOTAL_STEPS=7
show_progress() {
    local current=$1
    local total=${2:-$TOTAL_STEPS}
    local message="${3:-処理中}"
    local width=40
    local percent=$((current * 100 / total))
    local filled=$((width * current / total))
    local empty=$((width - filled))

    # プログレスバーの描画
    printf "\r${BLUE}["
    printf "%${filled}s" | tr ' ' '█'
    printf "%${empty}s" | tr ' ' '░'
    printf "] %3d%% ${NC}${message}" "$percent"

    # 完了時は改行
    if [ "$current" -eq "$total" ]; then
        echo ""
    fi
}

# ステップ表示（番号付き）
show_step() {
    local step=$1
    local total=$2
    local title=$3
    echo -e "\n${YELLOW}[$step/$total] ${title}${NC}"
    show_progress "$step" "$total" "$title"
}

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

    case "$OS" in
        Darwin)
            IS_MACOS=true
            IS_LINUX=false
            if [ "$ARCH" = "arm64" ]; then
                HOMEBREW_PREFIX="/opt/homebrew"
            else
                HOMEBREW_PREFIX="/usr/local"
            fi
            ;;
        Linux)
            IS_MACOS=false
            IS_LINUX=true
            HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
            # WSL検出
            if grep -qEi "(Microsoft|WSL)" /proc/version 2>/dev/null; then
                IS_WSL=true
                echo -e "${CYAN}WSL環境を検出しました${NC}"
            else
                IS_WSL=false
            fi
            ;;
        *)
            echo -e "${RED}未対応のOS: $OS${NC}"
            exit 1
            ;;
    esac

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
echo -e "\n${YELLOW}[1/7] Homebrewの確認...${NC}"
if ! command -v brew &> /dev/null; then
    echo -e "${RED}Homebrewがインストールされていません。${NC}"
    if [ "$IS_LINUX" = true ]; then
        echo -e "${YELLOW}Linuxbrew (Homebrew for Linux) をインストールしますか? (y/n)${NC}"
        echo -e "${CYAN}※ LinuxbrewなしでもLinux固有のパッケージマネージャーで続行可能です${NC}"
    else
        echo -e "${YELLOW}Homebrewをインストールしますか? (y/n)${NC}"
    fi
    read -r answer
    if [ "$answer" = "y" ]; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        # Homebrew PATH設定
        if [ "$IS_MACOS" = true ]; then
            if [[ $(uname -m) == "arm64" ]]; then
                eval "$(/opt/homebrew/bin/brew shellenv)"
            else
                eval "$(/usr/local/bin/brew shellenv)"
            fi
        else
            eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        fi
        echo -e "${GREEN}Homebrewのインストールが完了しました。${NC}"
    else
        if [ "$IS_MACOS" = true ]; then
            echo -e "${RED}macOSではHomebrewが必要です。終了します。${NC}"
            exit 1
        else
            echo -e "${YELLOW}⚠ Homebrew未インストール。Linux固有パッケージマネージャーを使用します${NC}"
            USE_SYSTEM_PKG=true
        fi
    fi
else
    echo -e "${GREEN}✓ Homebrewはインストール済みです${NC}"
    # 既存のHomebrew PATH設定
    if [ "$IS_MACOS" = true ]; then
        if [[ $(uname -m) == "arm64" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    else
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" 2>/dev/null || true
    fi
fi

# ========================================
# 2. アプリケーションのインストール
# ========================================
echo -e "\n${YELLOW}[2/7] アプリケーションのインストール...${NC}"

if [ "$SKIP_APPS" = true ]; then
    echo -e "${CYAN}アプリケーションインストールをスキップします${NC}"
elif [ "$USE_SYSTEM_PKG" = true ] && [ "$IS_LINUX" = true ]; then
    # Linux固有パッケージマネージャーを使用
    echo -e "${YELLOW}Linux固有パッケージマネージャーでツールをインストール...${NC}"
    bash "$SCRIPT_DIR/scripts/setup/linux.sh"
elif command -v brew &>/dev/null; then
    # Homebrewを使用
    if [ "$IS_LINUX" = true ]; then
        # Linux用Brewfile（GUIアプリを除外）
        BREWFILE="Brewfile.linux"
        if [ ! -f "$BREWFILE" ]; then
            # LinuxにはGUIアプリなしのBrewfileを生成
            echo -e "${YELLOW}Linux用Brewfile (CLI tools only) を使用します${NC}"
            BREWFILE="Brewfile"
        fi
    else
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
                echo -e "${YELLOW}全ツールをインストールします${NC}"
                ;;
            *)
                BREWFILE="Brewfile"
                echo -e "${GREEN}デフォルト: 必須ツールをインストールします${NC}"
                ;;
        esac
    fi

    if [ -f "$BREWFILE" ]; then
        brew bundle --file="$BREWFILE"
        echo -e "${GREEN}✓ アプリケーションのインストールが完了しました${NC}"
    else
        echo -e "${RED}$BREWFILE が見つかりません${NC}"
        exit 1
    fi
else
    echo -e "${RED}Homebrewが見つかりません${NC}"
    exit 1
fi

# ========================================
# 3. dotfilesのシンボリックリンク作成（GNU Stow使用）
# ========================================
echo -e "\n${YELLOW}[3/7] dotfilesのシンボリックリンク作成...${NC}"

# GNU Stow がインストールされているか確認
if ! command -v stow &>/dev/null; then
    echo -e "${RED}GNU Stow がインストールされていません${NC}"
    echo -e "${YELLOW}brew install stow でインストールしてください${NC}"
    exit 1
fi

# Stow でパッケージをインストールする関数
stow_package() {
    local pkg="$1"
    local pkg_dir="$SCRIPT_DIR/stow/$pkg"

    if [ ! -d "$pkg_dir" ]; then
        echo -e "${YELLOW}⚠ パッケージ $pkg が見つかりません${NC}"
        return 1
    fi

    if [ "$DRY_RUN" = true ]; then
        echo -e "${CYAN}[DRY RUN] Would stow: $pkg${NC}"
        stow --simulate -v --target="$HOME" --dir="$SCRIPT_DIR/stow" --restow "$pkg" 2>&1 || true
    else
        # 既存のシンボリックリンクを削除してから再作成（--adoptで既存ファイルを取り込み）
        stow -v --target="$HOME" --dir="$SCRIPT_DIR/stow" --restow --adopt "$pkg" 2>/dev/null || \
        stow -v --target="$HOME" --dir="$SCRIPT_DIR/stow" --restow "$pkg"
    fi
}

# Stow パッケージのインストール
STOW_PACKAGES=(zsh git tmux nvim ghostty bat atuin claude)

for pkg in "${STOW_PACKAGES[@]}"; do
    stow_package "$pkg"
done
echo -e "${GREEN}✓ Stowパッケージをインストールしました (${STOW_PACKAGES[*]})${NC}"

# ssh（Stow対象外 - パーミッション設定が必要）
if [ "$DRY_RUN" != true ]; then
    mkdir -p ~/.ssh/sockets
    chmod 700 ~/.ssh
else
    echo -e "${CYAN}[DRY RUN] Would create ~/.ssh/sockets with mode 700${NC}"
fi
if [ ! -f ~/.ssh/config ] || [ -L ~/.ssh/config ]; then
    safe_link ~/dotfiles/ssh/config ~/.ssh/config
    if [ "$DRY_RUN" != true ]; then
        chmod 600 ~/.ssh/config
    fi
    echo -e "${GREEN}✓ ssh設定をリンクしました${NC}"
else
    echo -e "${YELLOW}⚠ ssh設定は既存ファイルのため、スキップしました${NC}"
fi

# gh (GitHub CLI) - Stow対象外
mkdir -p ~/.config/gh
safe_link ~/dotfiles/gh/config.yml ~/.config/gh/config.yml
echo -e "${GREEN}✓ GitHub CLI設定をリンクしました${NC}"

# espanso
if [ "$IS_MACOS" = true ]; then
    ESPANSO_CONFIG_DIR="$HOME/Library/Application Support/espanso"
else
    ESPANSO_CONFIG_DIR="$HOME/.config/espanso"
fi
if command -v espanso &> /dev/null || [ -d "$ESPANSO_CONFIG_DIR" ]; then
    mkdir -p "$ESPANSO_CONFIG_DIR/match"
    safe_link ~/dotfiles/espanso/match/ai-prompts.yml "$ESPANSO_CONFIG_DIR/match/ai-prompts.yml"
    echo -e "${GREEN}✓ espanso設定をリンクしました${NC}"
else
    echo -e "${YELLOW}⚠ espansoがインストールされていません。スキップします${NC}"
fi

# antigravity (macOS only)
if [ "$IS_MACOS" = true ]; then
    ANTIGRAVITY_USER_DIR="$HOME/Library/Application Support/Antigravity/User"
    if [ -d "$HOME/Library/Application Support/Antigravity" ]; then
        mkdir -p "$ANTIGRAVITY_USER_DIR"
        safe_link ~/dotfiles/antigravity/settings.json "$ANTIGRAVITY_USER_DIR/settings.json"
        safe_link ~/dotfiles/antigravity/keybindings.json "$ANTIGRAVITY_USER_DIR/keybindings.json"
        echo -e "${GREEN}✓ Antigravity設定をリンクしました${NC}"
    else
        echo -e "${YELLOW}⚠ Antigravityがインストールされていません。スキップします${NC}"
    fi
fi

# ========================================
# 4. Oh My Zshのセットアップ
# ========================================
echo -e "\n${YELLOW}[4/7] Oh My Zshのセットアップ...${NC}"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    # CI環境またはドライランモードではスキップ
    if [ "$DRY_RUN" = true ] || [ "$CI" = "true" ]; then
        echo -e "${CYAN}[DRY RUN/CI] Oh My Zshのインストールをスキップします${NC}"
        answer="n"
    else
        echo -e "${YELLOW}Oh My Zshをインストールしますか? (y/n)${NC}"
        read -r answer
    fi
    if [ "$answer" = "y" ]; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

        # Powerlevel10k
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
            "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/themes/powerlevel10k

        # zsh-autosuggestions
        git clone https://github.com/zsh-users/zsh-autosuggestions \
            "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/plugins/zsh-autosuggestions

        # zsh-syntax-highlighting
        git clone https://github.com/zsh-users/zsh-syntax-highlighting \
            "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/plugins/zsh-syntax-highlighting

        # zsh-completions
        git clone https://github.com/zsh-users/zsh-completions \
            "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/plugins/zsh-completions

        echo -e "${GREEN}✓ Oh My Zshのセットアップが完了しました${NC}"
    fi
else
    echo -e "${GREEN}✓ Oh My Zshはインストール済みです${NC}"
fi

# ========================================
# 5. 追加設定
# ========================================
echo -e "\n${YELLOW}[5/7] 追加設定...${NC}"

# OS固有設定
if [ "$IS_MACOS" = true ]; then
    if [ -f ~/dotfiles/scripts/setup/macos-defaults.sh ]; then
        bash ~/dotfiles/scripts/setup/macos-defaults.sh
    fi
elif [ "$IS_LINUX" = true ]; then
    if [ -f ~/dotfiles/scripts/setup/linux.sh ]; then
        # Linux固有の追加設定（パッケージインストールはスキップ、設定のみ）
        echo -e "${YELLOW}Linux固有設定を適用中...${NC}"
    fi
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

# bat TokyoNightテーマ
BAT_THEMES_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/bat/themes"
if [ ! -f "$BAT_THEMES_DIR/tokyonight_night.tmTheme" ]; then
    mkdir -p "$BAT_THEMES_DIR"
    THEME_URL="https://raw.githubusercontent.com/folke/tokyonight.nvim/main/extras/sublime/tokyonight_night.tmTheme"
    if curl -fsSL "$THEME_URL" -o "$BAT_THEMES_DIR/tokyonight_night.tmTheme" 2>/dev/null; then
        bat cache --build 2>/dev/null || true
        echo -e "${GREEN}✓ bat TokyoNightテーマをインストールしました${NC}"
    else
        echo -e "${YELLOW}⚠ batテーマのダウンロードに失敗しました（スキップ）${NC}"
    fi
else
    echo -e "${GREEN}✓ bat TokyoNightテーマはインストール済みです${NC}"
fi

# lefthookのセットアップ
if command -v lefthook &> /dev/null && [ -f ~/dotfiles/lefthook.yml ]; then
    cd ~/dotfiles && lefthook install 2>/dev/null || true
    echo -e "${GREEN}✓ lefthook Git hooksをインストールしました${NC}"
fi

# ローカル設定ファイルのセットアップ
echo -e "\n${YELLOW}ローカル設定ファイルのセットアップ...${NC}"

# .gitconfig.local
if [ ! -f ~/.gitconfig.local ]; then
    echo -e "${YELLOW}Git ユーザー情報を設定します${NC}"
    read -rp "Git ユーザー名: " git_name
    read -rp "Git メールアドレス: " git_email
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
# 6. Linux/WSL固有設定
# ========================================
if [ "$IS_LINUX" = true ]; then
    echo -e "\n${YELLOW}[6/7] Linux固有設定...${NC}"

    # デフォルトシェルをzshに変更
    if [ "$(basename "$SHELL")" != "zsh" ] && command -v zsh &>/dev/null; then
        echo -e "${YELLOW}デフォルトシェルをzshに変更しますか? (y/n)${NC}"
        read -r answer
        if [ "$answer" = "y" ]; then
            chsh -s "$(which zsh)"
            echo -e "${GREEN}✓ デフォルトシェルをzshに変更しました${NC}"
        fi
    else
        echo -e "${GREEN}✓ zshは既にデフォルトシェルです${NC}"
    fi

    # WSL固有設定
    if [ "$IS_WSL" = true ]; then
        echo -e "${YELLOW}WSL固有設定を確認中...${NC}"

        # Windows側のクリップボード連携設定
        if [ -f /mnt/c/Windows/System32/clip.exe ]; then
            echo -e "${GREEN}✓ Windowsクリップボード連携が利用可能です${NC}"
        fi

        # wsl.conf設定
        if [ ! -f /etc/wsl.conf ]; then
            echo -e "${YELLOW}wsl.confを作成しますか? (systemd有効化) (y/n)${NC}"
            read -r answer
            if [ "$answer" = "y" ]; then
                sudo tee /etc/wsl.conf > /dev/null << 'WSLEOF'
[boot]
systemd=true

[interop]
appendWindowsPath=false

[automount]
enabled=true
options="metadata,umask=22,fmask=11"
WSLEOF
                echo -e "${GREEN}✓ wsl.confを作成しました（WSL再起動が必要）${NC}"
            fi
        fi
    fi
else
    echo -e "\n${YELLOW}[6/7] macOS固有設定は適用済みです${NC}"
fi

# ========================================
# 7. 完了
# ========================================
log "=== Setup completed successfully ==="

echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}  セットアップが完了しました！${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "\n${YELLOW}次のステップ:${NC}"
echo -e "  1. ターミナルを再起動するか、'source ~/.zshrc' を実行"
echo -e "  2. Powerlevel10kの設定: 'p10k configure'"
echo -e "  3. Nerd Fontをターミナルに設定"
if [ "$IS_WSL" = true ]; then
    echo -e "  4. WSLを再起動: wsl --shutdown (PowerShellから)"
fi
echo -e "\n${BLUE}追加のアプリケーションは docs/setup/APPS.md を参照してください${NC}"
echo -e "${BLUE}ログファイル: $LOG_FILE${NC}"
