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
#   --skip-claude      Claude Codeセットアップをスキップ
#   --claude-only      Claude Codeセットアップのみ

set -euo pipefail

# ========================================
# 設定・初期化
# ========================================
DRY_RUN=false
VERBOSE=false
SKIP_APPS=false
SKIP_CLAUDE=false
CLAUDE_ONLY=false
ASSUME_YES=false
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CURRENT_STEP=""

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
        --skip-claude)  SKIP_CLAUDE=true ;;
        --claude-only)  CLAUDE_ONLY=true ;;
        -h|--help)
            sed -n '2,16p' "$0" | sed 's/^# \?//'
            exit 0 ;;
        *) echo -e "${RED}不明なオプション: $1${NC}"; exit 1 ;;
    esac
    shift
done

# ========================================
# ユーティリティ関数
# ========================================
LOG_DIR="$HOME/.local/share/dotfiles/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/bootstrap-$(date '+%Y%m%d-%H%M%S').log"
ln -sf "$LOG_FILE" "$LOG_DIR/bootstrap-latest.log"
find "$LOG_DIR" -name 'bootstrap-*.log' -mtime +30 -delete 2>/dev/null || true

show_step() {
    CURRENT_STEP="[$1/$2] $3"
    echo -e "\n${YELLOW}${CURRENT_STEP}${NC}"
}

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
    [[ "$VERBOSE" = true ]] && echo -e "${CYAN}[LOG] $1${NC}"
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
        git -C "$dest" pull --quiet 2>/dev/null && echo -e "  ${GREEN}✓${NC} $name" || echo -e "  ${YELLOW}⚠${NC} $name"
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

# Brewfileパッケージを個別インストール
install_brew_item() {
    local type="$1" name="$2" current="$3" total="$4"
    local check_cmd install_cmd

    case "$type" in
        tap)
            check_cmd="brew tap | grep -q ^${name}$"
            install_cmd="brew tap $name" ;;
        brew)
            check_cmd="brew list --formula $name"
            install_cmd="brew install $name" ;;
        cask)
            check_cmd="brew list --cask $name"
            install_cmd="brew install --cask $name" ;;
    esac

    # 戻り値: 0=スキップ（既存）, 1=新規成功, 2=失敗
    if eval "$check_cmd" &>/dev/null; then
        printf "  [%d/%d] %-40s ${GREEN}✓${NC}\n" "$current" "$total" "$name"
        return 0
    fi

    printf "  [%d/%d] %-40s " "$current" "$total" "$name"
    if eval "$install_cmd" &>/dev/null; then
        echo -e "${GREEN}✓${NC}"
        return 1
    else
        echo -e "${RED}✗${NC}"
        return 2
    fi
}

install_brewfile_packages() {
    local brewfile="$1"
    local success=0 failed=0 skipped=0 current=0
    local failed_packages=()
    local types=() names=()

    while IFS= read -r line; do
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ -z "${line// }" ]] && continue
        if [[ "$line" =~ ^(tap|brew|cask)[[:space:]]+\"([^\"]+)\" ]]; then
            types+=("${BASH_REMATCH[1]}")
            names+=("${BASH_REMATCH[2]}")
        fi
    done < "$brewfile"

    local total=${#names[@]}
    echo -e "パッケージ: ${CYAN}$total${NC}"

    for i in "${!names[@]}"; do
        ((current++))
        local rc=0
        install_brew_item "${types[$i]}" "${names[$i]}" "$current" "$total" || rc=$?
        case $rc in
            0) ((skipped++)) ;;
            1) ((success++)) ;;
            2) ((failed++)); failed_packages+=("${types[$i]}: ${names[$i]}") ;;
        esac
    done

    echo -e "\n結果: 新規=${GREEN}$success${NC} スキップ=${CYAN}$skipped${NC} 失敗=${RED}$failed${NC}"

    if [ $failed -gt 0 ]; then
        echo -e "${YELLOW}失敗:${NC}"
        for pkg in "${failed_packages[@]}"; do
            echo -e "  ${RED}- $pkg${NC}"
        done
        log "Failed packages: ${failed_packages[*]}"
        return 1
    fi
}

# エラー時のクリーンアップ
cleanup() {
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        echo -e "\n${RED}エラー発生${NC} (code: $exit_code, step: ${CURRENT_STEP:-初期化中})"
        echo -e "ログ: $LOG_FILE"
        log "ERROR: Setup failed with exit code $exit_code"
    fi
}
trap cleanup EXIT

# ========================================
# --claude-only: 早期リターン
# ========================================
if [ "$CLAUDE_ONLY" = true ]; then
    echo -e "${GREEN}Claude Code セットアップのみ実行${NC}"
    if [ -x "$HOME/.claude/setup.sh" ] && command -v claude &>/dev/null; then
        "$HOME/.claude/setup.sh"
    else
        echo -e "${RED}Claude Code または ~/.claude/setup.sh が見つかりません${NC}"
        exit 1
    fi
    exit 0
fi

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

ARCH="$(uname -m)"
HOMEBREW_PREFIX=$(detect_homebrew_prefix)
log "=== Setup started === $(uname -s) ($ARCH), Homebrew: $HOMEBREW_PREFIX"

echo -e "${CYAN}dotfiles セットアップ${NC}"
[[ "$DRY_RUN" = true ]] && echo -e "${CYAN}[ドライランモード]${NC}"

# Rosetta 2（Apple Silicon のみ、ステップ外で処理）
if [[ "$ARCH" == "arm64" ]] && ! /usr/bin/pgrep -q oahd; then
    if ask "Rosetta 2をインストールしますか?"; then
        softwareupdate --install-rosetta --agree-to-license
        echo -e "${GREEN}✓ Rosetta 2${NC}"
    fi
fi

# ========================================
# 1. Homebrew
# ========================================
show_step 1 5 "Homebrewの確認"
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
show_step 2 5 "アプリケーションのインストール"
if [ "$SKIP_APPS" = true ]; then
    echo -e "${CYAN}スキップ${NC}"
elif [ -f "$SCRIPT_DIR/Brewfile" ]; then
    if ! install_brewfile_packages "$SCRIPT_DIR/Brewfile"; then
        echo -e "${YELLOW}⚠ 一部パッケージのインストールに失敗しました${NC}"
        ask "失敗がありますが続行しますか?" || exit 1
    fi
else
    echo -e "${RED}Brewfileが見つかりません${NC}"; exit 1
fi

# ========================================
# 3. dotfiles シンボリックリンク (GNU Stow)
# ========================================
show_step 3 5 "dotfilesのシンボリックリンク作成"

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
show_step 4 5 "Oh My Zshのセットアップ"
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
    # タグはリリースページで最新を確認して更新
    ensure_zsh_plugin "powerlevel10k" "https://github.com/romkatv/powerlevel10k.git" "$ZSH_CUSTOM/themes/powerlevel10k" "v1.20.0"
    ensure_zsh_plugin "zsh-autosuggestions" "https://github.com/zsh-users/zsh-autosuggestions" "$ZSH_CUSTOM/plugins/zsh-autosuggestions" "v0.7.1"
    ensure_zsh_plugin "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting" "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" "0.8.0"
    ensure_zsh_plugin "zsh-completions" "https://github.com/zsh-users/zsh-completions" "$ZSH_CUSTOM/plugins/zsh-completions" "0.35.0"
    echo -e "${GREEN}✓ プラグイン完了${NC}"
fi

# ========================================
# 5. 追加設定
# ========================================
show_step 5 5 "追加設定"

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

    # --- asdf ---
    if command -v asdf &>/dev/null; then
        asdf plugin add nodejs 2>/dev/null || true
        asdf plugin add python 2>/dev/null || true
        asdf plugin add terraform 2>/dev/null || true
        [ -f ~/.tool-versions ] && asdf install
        echo -e "${GREEN}✓ asdf${NC}"
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

# --- Claude Code ---
if [ "$SKIP_CLAUDE" = false ] && [ -x "$HOME/.claude/setup.sh" ]; then
    if command -v claude &>/dev/null; then
        [ "$DRY_RUN" = true ] && echo -e "${CYAN}[DRY RUN] Claude Code${NC}" || "$HOME/.claude/setup.sh"
    else
        echo -e "${YELLOW}⚠ Claude Code未インストール → Brewfileのcask \"claude\"で自動インストールされます${NC}"
    fi
fi

# --- ローカル設定ファイル ---
if [ ! -f ~/.gitconfig.local ]; then
    if [ "$ASSUME_YES" = true ]; then
        cp "$SCRIPT_DIR/stow/git/.gitconfig.local.template" ~/.gitconfig.local
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
    cp "$SCRIPT_DIR/stow/zsh/.zshrc.local.template" ~/.zshrc.local 2>/dev/null || true
    echo -e "${GREEN}✓ ~/.zshrc.local${NC}"
fi

# ========================================
# 完了
# ========================================
log "=== Setup completed ==="
echo -e "\n${GREEN}セットアップ完了！${NC}"
echo -e "  1. ターミナルを再起動（または ${CYAN}exec zsh${NC}）"
echo -e "  2. Powerlevel10kカスタマイズ: ${CYAN}p10k configure${NC}"
