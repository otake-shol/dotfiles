#!/bin/bash
# bootstrap.sh - 新しいMacの自動セットアップスクリプト
#
# Usage:
#   bash bootstrap.sh           # 通常実行
#   bash bootstrap.sh -n        # ドライラン
#   bash bootstrap.sh -y        # 完全自動（対話なし）
#   bash bootstrap.sh -n -v     # ドライラン + 詳細出力
#
# Options:
#   -n, --dry-run      シミュレーション実行
#   -y, --yes          対話プロンプトを自動応答
#   -v, --verbose      詳細出力
#   --skip-apps        アプリインストールをスキップ

set -euo pipefail

# ========================================
# 設定・初期化
# ========================================
DRY_RUN=false
VERBOSE=false
SKIP_APPS=false
ASSUME_YES=false
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CURRENT_STEP=""

# Zshプラグインバージョン（更新時はここを変更）
POWERLEVEL10K_TAG="v1.20.0"
ZSH_AUTOSUGGESTIONS_TAG="v0.7.1"
ZSH_SYNTAX_HIGHLIGHTING_TAG="0.8.0"
ZSH_COMPLETIONS_TAG="0.35.0"

# 色定義
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; NC='\033[0m'

# Homebrew prefix（Apple Silicon / Intel）
detect_homebrew_prefix() {
    [[ "$(uname -m)" == "arm64" ]] && echo "/opt/homebrew" || echo "/usr/local"
}

# ========================================
# 引数解析
# ========================================
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -n|--dry-run)   DRY_RUN=true ;;
        -y|--yes)       ASSUME_YES=true ;;
        -v|--verbose)   VERBOSE=true ;;
        --skip-apps)    SKIP_APPS=true ;;
        -h|--help)
            sed -n '2,14p' "$0" | sed 's/^# \?//'
            exit 0 ;;
        *) echo -e "${RED}不明なオプション: $1${NC}"; exit 1 ;;
    esac
    shift
done

# ========================================
# ユーティリティ関数
# ========================================
show_step() {
    CURRENT_STEP="[$1/$2] $3"
    echo -e "\n${YELLOW}${CURRENT_STEP}${NC}"
}

ask() {
    [[ "$ASSUME_YES" = true ]] && return 0
    echo -e "${YELLOW}$1 (y/n)${NC}"
    read -r answer
    [[ "$answer" = "y" ]]
}

# Zshプラグイン冪等インストール（タグ指定で再現性確保）
ensure_zsh_plugin() {
    local name="$1" repo_url="$2" dest="$3" tag="${4:-}"
    if [ -d "$dest/.git" ]; then
        # タグ指定時は固定バージョンを維持（pullしない）
        if [ -n "$tag" ]; then
            echo -e "  ${GREEN}✓${NC} $name (${tag})"
        else
            git -C "$dest" pull --quiet 2>/dev/null && echo -e "  ${GREEN}✓${NC} $name" || echo -e "  ${YELLOW}⚠${NC} $name"
        fi
    else
        [ -d "$dest" ] && rm -rf "$dest"
        if [ -n "$tag" ]; then
            git clone --depth=1 --branch "$tag" "$repo_url" "$dest" 2>/dev/null
        else
            git clone --depth=1 "$repo_url" "$dest" 2>/dev/null
        fi
        echo -e "  ${GREEN}✓${NC} $name"
    fi
}

# エラー時のクリーンアップ
cleanup() {
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        echo -e "\n${RED}エラー発生${NC} (code: $exit_code, step: ${CURRENT_STEP:-初期化中})"
    fi
}
trap cleanup EXIT

# ========================================
# 前提チェック
# ========================================
if [[ "$(uname -s)" != "Darwin" ]]; then
    echo -e "${RED}macOS専用です${NC}"; exit 1
fi

for cmd in git curl; do
    if ! command -v "$cmd" &>/dev/null; then
        echo -e "${RED}${cmd} が見つかりません → xcode-select --install${NC}"; exit 1
    fi
done

HOMEBREW_PREFIX=$(detect_homebrew_prefix)

echo -e "${CYAN}dotfiles セットアップ${NC}"
[[ "$DRY_RUN" = true ]] && echo -e "${CYAN}[ドライランモード]${NC}"

# ========================================
# 1. Homebrew
# ========================================
show_step 1 6 "Homebrewの確認"
if ! command -v brew &>/dev/null; then
    if ask "Homebrewをインストールしますか?"; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        eval "$("${HOMEBREW_PREFIX}/bin/brew" shellenv)"
        echo -e "${GREEN}✓ Homebrewをインストールしました${NC}"
    else
        echo -e "${RED}Homebrewが必要です${NC}"; exit 1
    fi
else
    echo -e "${GREEN}✓ Homebrewはインストール済み${NC}"
    eval "$("${HOMEBREW_PREFIX}/bin/brew" shellenv)" 2>/dev/null || true
fi

# ========================================
# 2. アプリケーション
# ========================================
show_step 2 6 "アプリケーションのインストール"
if [ "$SKIP_APPS" = true ]; then
    echo -e "${CYAN}スキップ${NC}"
elif [ -f "$SCRIPT_DIR/Brewfile" ]; then
    BUNDLE_ARGS=(--file="$SCRIPT_DIR/Brewfile" --no-upgrade)
    [[ "$VERBOSE" = true ]] && BUNDLE_ARGS+=(--verbose)
    if ! brew bundle "${BUNDLE_ARGS[@]}"; then
        echo -e "${YELLOW}⚠ 一部パッケージのインストールに失敗しました${NC}"
        ask "失敗がありますが続行しますか?" || exit 1
    fi
else
    echo -e "${RED}Brewfileが見つかりません${NC}"; exit 1
fi

# ========================================
# 3. dotfiles シンボリックリンク (GNU Stow)
# ========================================
show_step 3 6 "dotfilesのシンボリックリンク作成"

if ! command -v stow &>/dev/null; then
    echo -e "${RED}GNU Stowがインストールされていません${NC}"; exit 1
fi

read -r -a STOW_PACKAGES <<< "$(make -C "$SCRIPT_DIR" -s packages)"
for pkg in "${STOW_PACKAGES[@]}"; do
    if [ ! -d "$SCRIPT_DIR/stow/$pkg" ]; then
        echo -e "${YELLOW}⚠ $pkg が見つかりません${NC}"; continue
    fi
    if [ "$DRY_RUN" = true ]; then
        echo -e "${CYAN}[DRY RUN] $pkg${NC}"
        stow --simulate -v --target="$HOME" --dir="$SCRIPT_DIR/stow" --restow "$pkg" 2>&1 || true
    else
        # --adopt: HOMEの既存ファイルをstow/に取り込んで競合解消（初回セットアップ用）
        # 注意: 既存ファイルがstowディレクトリに移動されるため、git diffで差分を確認すること
        stow -v --target="$HOME" --dir="$SCRIPT_DIR/stow" --restow --adopt "$pkg" 2>/dev/null || \
        stow -v --target="$HOME" --dir="$SCRIPT_DIR/stow" --restow "$pkg"
    fi
done
echo -e "${GREEN}✓ Stowパッケージ完了 (${STOW_PACKAGES[*]})${NC}"

# SSH ディレクトリ
if [ "$DRY_RUN" != true ]; then
    mkdir -p ~/.ssh/sockets && chmod 700 ~/.ssh
fi

# ========================================
# 4. Oh My Zsh + プラグイン
# ========================================
show_step 4 6 "Oh My Zshのセットアップ"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    if [ "$DRY_RUN" = true ] || [ "${CI:-}" = "true" ]; then
        echo -e "${CYAN}[DRY RUN/CI] スキップ${NC}"
    elif ask "Oh My Zshをインストールしますか?"; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        echo -e "${GREEN}✓ Oh My Zsh${NC}"
    fi
else
    echo -e "${GREEN}✓ Oh My Zshはインストール済み${NC}"
fi

if [ -d "$HOME/.oh-my-zsh" ] && [ "$DRY_RUN" != true ] && [ "${CI:-}" != "true" ]; then
    ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    ensure_zsh_plugin "powerlevel10k" "https://github.com/romkatv/powerlevel10k.git" "$ZSH_CUSTOM/themes/powerlevel10k" "$POWERLEVEL10K_TAG"
    ensure_zsh_plugin "zsh-autosuggestions" "https://github.com/zsh-users/zsh-autosuggestions" "$ZSH_CUSTOM/plugins/zsh-autosuggestions" "$ZSH_AUTOSUGGESTIONS_TAG"
    ensure_zsh_plugin "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting" "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" "$ZSH_SYNTAX_HIGHLIGHTING_TAG"
    ensure_zsh_plugin "zsh-completions" "https://github.com/zsh-users/zsh-completions" "$ZSH_CUSTOM/plugins/zsh-completions" "$ZSH_COMPLETIONS_TAG"
    echo -e "${GREEN}✓ プラグイン完了${NC}"
fi

# ========================================
# 5. 追加設定
# ========================================
show_step 5 6 "追加設定"

if [ "$DRY_RUN" = true ]; then
    echo -e "${CYAN}[DRY RUN] macOS defaults・追加設定をスキップ${NC}"
else
    # --- macOS defaults: Dock ---
    defaults write com.apple.dock autohide -bool true
    defaults write com.apple.dock autohide-delay -float 0
    defaults write com.apple.dock autohide-time-modifier -float 0.3
    defaults write com.apple.dock tilesize -int 48
    defaults write com.apple.dock show-recents -bool false

    # --- macOS defaults: Finder ---
    defaults write com.apple.finder AppleShowAllFiles -bool true
    defaults write com.apple.finder ShowPathbar -bool true
    defaults write com.apple.finder ShowStatusBar -bool true
    defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
    defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
    defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true

    # --- macOS defaults: キーボード・入力 ---
    defaults write NSGlobalDomain KeyRepeat -int 1
    defaults write NSGlobalDomain InitialKeyRepeat -int 15
    defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
    defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
    defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
    defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
    defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

    # --- macOS defaults: トラックパッド・マウス ---
    defaults write -g com.apple.mouse.scaling -float 5.0
    defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true

    # --- macOS defaults: UI ---
    defaults write -g AppleShowScrollBars -string "Always"
    defaults write -g AppleActionOnDoubleClick -string "Maximize"

    # --- macOS defaults: セキュリティ・プライバシー ---
    defaults write com.apple.screensaver askForPassword -int 1
    defaults write com.apple.screensaver askForPasswordDelay -int 0
    defaults write com.apple.AdLib forceLimitAdTracking -bool true
    defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
    defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

    killall Dock 2>/dev/null || true
    killall Finder 2>/dev/null || true
    echo -e "${GREEN}✓ macOS defaults${NC}"

    # --- git-secrets ---
    if command -v git-secrets &>/dev/null; then
        git secrets --install ~/.git-templates/git-secrets 2>/dev/null || true
        git secrets --register-aws --global 2>/dev/null || true
        echo -e "${GREEN}✓ git-secrets${NC}"
    fi

    # --- Neovim TokyoNight ---
    TOKYONIGHT_DIR="$HOME/.local/share/nvim/site/pack/colors/start/tokyonight.nvim"
    if [ ! -d "$TOKYONIGHT_DIR" ]; then
        mkdir -p "$(dirname "$TOKYONIGHT_DIR")"
        git clone --depth=1 https://github.com/folke/tokyonight.nvim "$TOKYONIGHT_DIR"
        echo -e "${GREEN}✓ Neovim TokyoNight${NC}"
    fi

    # --- bat テーマキャッシュ構築（テーマ自体はStowで展開済み） ---
    bat cache --build 2>/dev/null || true
fi

# --- ローカル設定ファイル ---
if [ ! -f ~/.gitconfig.local ]; then
    if [ "$ASSUME_YES" = true ]; then
        cp "$SCRIPT_DIR/templates/gitconfig.local.template" ~/.gitconfig.local
        echo -e "${GREEN}✓ ~/.gitconfig.local（要編集）${NC}"
    else
        echo -e "${YELLOW}Git ユーザー情報を設定します${NC}"
        read -rp "ユーザー名: " git_name
        read -rp "メールアドレス: " git_email
        printf "[user]\n\tname = %s\n\temail = %s\n" "$git_name" "$git_email" > ~/.gitconfig.local
        echo -e "${GREEN}✓ ~/.gitconfig.local${NC}"
    fi
fi

if [ ! -f ~/.zshrc.local ]; then
    cp "$SCRIPT_DIR/templates/zshrc.local.template" ~/.zshrc.local 2>/dev/null || true
    echo -e "${GREEN}✓ ~/.zshrc.local${NC}"
fi

# ========================================
# 6. Claude Code（オプション）
# ========================================
show_step 6 6 "Claude Codeのセットアップ"

if command -v claude &>/dev/null; then
    if [ "$DRY_RUN" = true ]; then
        echo -e "${CYAN}[DRY RUN] MCPサーバー・プラグイン設定をスキップ${NC}"
    elif ask "Claude Code MCPサーバーを設定しますか?"; then
        # MCPサーバー
        claude mcp add context7 --scope user -- npx -y @upstash/context7-mcp@latest 2>/dev/null || true
        claude mcp add playwright --scope user -- npx -y @playwright/mcp@latest 2>/dev/null || true
        claude mcp add github --scope user --transport http https://api.githubcopilot.com/mcp/ 2>/dev/null || true
        claude mcp add hourei --scope user -- npx -y hourei-mcp-server 2>/dev/null || true
        claude mcp add tax-law --scope user -- npx -y tax-law-mcp 2>/dev/null || true
        if command -v gws &>/dev/null; then
            claude mcp add gws --scope user -- gws mcp -s all 2>/dev/null || true
        fi
        echo -e "${GREEN}✓ MCPサーバー${NC}"

        # プラグイン
        claude /plugin marketplace add obra/superpowers-marketplace 2>/dev/null || true
        claude /plugin install superpowers@superpowers-marketplace 2>/dev/null || true
        echo -e "${GREEN}✓ プラグイン${NC}"
    fi
else
    echo -e "${CYAN}スキップ（Claude Code未インストール）${NC}"
fi

# ========================================
# 完了
# ========================================
echo -e "\n${GREEN}セットアップ完了！${NC}"
echo -e "  1. ターミナルを再起動（または ${CYAN}exec zsh${NC}）"
echo -e "  2. Powerlevel10kカスタマイズ: ${CYAN}p10k configure${NC}"
