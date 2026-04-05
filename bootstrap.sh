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
BLUE='\033[0;34m'; CYAN='\033[0;36m'; NC='\033[0m'

# OS検出
is_macos() { [[ "$(uname -s)" == "Darwin" ]]; }
detect_homebrew_prefix() {
    [[ "$(uname -m)" == "arm64" ]] && echo "/opt/homebrew" || echo "/usr/local"
}

# Zshプラグイン冪等インストール
ensure_zsh_plugin() {
    local name="$1" repo_url="$2" dest="$3"
    if [ -d "$dest/.git" ]; then
        git -C "$dest" pull --quiet 2>/dev/null && echo -e "  ${GREEN}✓${NC} $name" || echo -e "  ${YELLOW}⚠${NC} $name"
    else
        [ -d "$dest" ] && rm -rf "$dest"
        git clone --depth=1 "$repo_url" "$dest" 2>/dev/null
        echo -e "  ${GREEN}✓${NC} $name"
    fi
}

# ログ
LOG_DIR="$HOME/.local/share/dotfiles/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/bootstrap-$(date '+%Y%m%d-%H%M%S').log"
ln -sf "$LOG_FILE" "$LOG_DIR/bootstrap-latest.log"
find "$LOG_DIR" -name 'bootstrap-*.log' -mtime +30 -delete 2>/dev/null || true

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
show_step() {
    CURRENT_STEP="[$1/$2] $3"
    echo -e "\n${YELLOW}${CURRENT_STEP}${NC}"
}

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
    if [[ "$VERBOSE" = true ]]; then echo -e "${CYAN}[LOG] $1${NC}"; fi
}

ask() {
    [[ "$ASSUME_YES" = true ]] && return 0
    echo -e "${YELLOW}$1 (y/n)${NC}"
    read -r answer
    [[ "$answer" = "y" ]]
}

# Brewfileパッケージを個別インストール
install_brewfile_packages() {
    local brewfile="$1"
    local success=0 failed=0 skipped=0 current=0
    local failed_packages=()
    local taps=() brews=() casks=()

    while IFS= read -r line; do
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ -z "${line// }" ]] && continue
        if [[ "$line" =~ ^tap[[:space:]]+\"([^\"]+)\" ]]; then
            taps+=("${BASH_REMATCH[1]}")
        elif [[ "$line" =~ ^brew[[:space:]]+\"([^\"]+)\" ]]; then
            brews+=("${BASH_REMATCH[1]}")
        elif [[ "$line" =~ ^cask[[:space:]]+\"([^\"]+)\" ]]; then
            casks+=("${BASH_REMATCH[1]}")
        fi
    done < "$brewfile"

    local total=$((${#taps[@]} + ${#brews[@]} + ${#casks[@]}))
    echo -e "パッケージ: ${CYAN}$total${NC} (tap: ${#taps[@]}, brew: ${#brews[@]}, cask: ${#casks[@]})"

    # Taps
    for tap in "${taps[@]}"; do
        ((current++))
        if brew tap | grep -q "^${tap}$" 2>/dev/null; then
            printf "  [%d/%d] %-40s ${GREEN}✓${NC}\n" "$current" "$total" "$tap"
            ((skipped++))
        else
            printf "  [%d/%d] %-40s " "$current" "$total" "$tap"
            if brew tap "$tap" &>/dev/null; then
                echo -e "${GREEN}✓${NC}"; ((success++))
            else
                echo -e "${RED}✗${NC}"; ((failed++)); failed_packages+=("tap: $tap")
            fi
        fi
    done

    # Brews
    for pkg in "${brews[@]}"; do
        ((current++))
        if brew list --formula "$pkg" &>/dev/null; then
            printf "  [%d/%d] %-40s ${GREEN}✓${NC}\n" "$current" "$total" "$pkg"
            ((skipped++))
        else
            printf "  [%d/%d] %-40s " "$current" "$total" "$pkg"
            if brew install "$pkg" &>/dev/null; then
                echo -e "${GREEN}✓${NC}"; ((success++))
            else
                echo -e "${RED}✗${NC}"; ((failed++)); failed_packages+=("brew: $pkg")
            fi
        fi
    done

    # Casks
    for pkg in "${casks[@]}"; do
        ((current++))
        if brew list --cask "$pkg" &>/dev/null; then
            printf "  [%d/%d] %-40s ${GREEN}✓${NC}\n" "$current" "$total" "$pkg"
            ((skipped++))
        else
            printf "  [%d/%d] %-40s " "$current" "$total" "$pkg"
            if brew install --cask "$pkg" &>/dev/null; then
                echo -e "${GREEN}✓${NC}"; ((success++))
            else
                echo -e "${RED}✗${NC}"; ((failed++)); failed_packages+=("cask: $pkg")
            fi
        fi
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
# 依存関係チェック
# ========================================
check_dependencies() {
    local missing=()
    command -v git &>/dev/null || missing+=("git")
    command -v curl &>/dev/null || missing+=("curl")
    if [ ${#missing[@]} -gt 0 ]; then
        echo -e "${RED}不足: ${missing[*]}${NC}"
        echo -e "  xcode-select --install"
        exit 1
    fi
    log "Dependencies check passed"
}

detect_system() {
    if ! is_macos; then
        echo -e "${RED}macOS専用です${NC}"; exit 1
    fi
    ARCH="$(uname -m)"
    HOMEBREW_PREFIX=$(detect_homebrew_prefix)
    log "Detected: $(uname -s) ($ARCH), Homebrew: $HOMEBREW_PREFIX"
}

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
# メイン処理
# ========================================
check_dependencies
detect_system

log "=== Setup started ==="
echo -e "${BLUE}dotfiles セットアップ${NC}"
[[ "$DRY_RUN" = true ]] && echo -e "${CYAN}[ドライランモード]${NC}"

# --- 1. Rosetta 2 (Apple Silicon) ---
if [[ "$ARCH" == "arm64" ]]; then
    show_step 1 6 "Rosetta 2の確認"
    if ! /usr/bin/pgrep -q oahd; then
        if ask "Rosetta 2をインストールしますか?"; then
            softwareupdate --install-rosetta --agree-to-license
            echo -e "${GREEN}✓ Rosetta 2をインストールしました${NC}"
        fi
    else
        echo -e "${GREEN}✓ Rosetta 2はインストール済み${NC}"
    fi
fi

# --- 2. Homebrew ---
show_step 2 6 "Homebrewの確認"
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

# --- 3. アプリケーション ---
show_step 3 6 "アプリケーションのインストール"
if [ "$SKIP_APPS" = true ]; then
    echo -e "${CYAN}スキップ${NC}"
elif [ -f "Brewfile" ]; then
    if ! install_brewfile_packages "Brewfile"; then
        ask "失敗がありますが続行しますか?" || exit 1
    fi
else
    echo -e "${RED}Brewfileが見つかりません${NC}"; exit 1
fi

# --- 4. dotfilesシンボリックリンク (GNU Stow) ---
show_step 4 6 "dotfilesのシンボリックリンク作成"

if ! command -v stow &>/dev/null; then
    echo -e "${RED}GNU Stowがインストールされていません${NC}"; exit 1
fi

stow_package() {
    local pkg="$1"
    if [ ! -d "$SCRIPT_DIR/stow/$pkg" ]; then
        echo -e "${YELLOW}⚠ $pkg が見つかりません${NC}"; return 1
    fi
    if [ "$DRY_RUN" = true ]; then
        echo -e "${CYAN}[DRY RUN] $pkg${NC}"
        stow --simulate -v --target="$HOME" --dir="$SCRIPT_DIR/stow" --restow "$pkg" 2>&1 || true
    else
        stow -v --target="$HOME" --dir="$SCRIPT_DIR/stow" --restow --adopt "$pkg" 2>/dev/null || \
        stow -v --target="$HOME" --dir="$SCRIPT_DIR/stow" --restow "$pkg"
    fi
}

# パッケージリストはMakefileから取得（一元管理）
read -r -a STOW_PACKAGES <<< "$(make -C "$SCRIPT_DIR" -s packages)"
for pkg in "${STOW_PACKAGES[@]}"; do
    stow_package "$pkg"
done
echo -e "${GREEN}✓ Stowパッケージ完了 (${STOW_PACKAGES[*]})${NC}"

# SSH基本セットアップ
if [ "$DRY_RUN" != true ]; then
    mkdir -p ~/.ssh/sockets && chmod 700 ~/.ssh
fi

# --- 5. Oh My Zsh ---
show_step 5 6 "Oh My Zshのセットアップ"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    if [ "$DRY_RUN" = true ] || [ "${CI:-}" = "true" ]; then
        echo -e "${CYAN}[DRY RUN/CI] スキップ${NC}"
    elif ask "Oh My Zshをインストールしますか?"; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        echo -e "${GREEN}✓ Oh My Zshをインストールしました${NC}"
    fi
else
    echo -e "${GREEN}✓ Oh My Zshはインストール済み${NC}"
fi

# プラグイン
if [ -d "$HOME/.oh-my-zsh" ] && [ "$DRY_RUN" != true ] && [ "${CI:-}" != "true" ]; then
    ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    ensure_zsh_plugin "powerlevel10k" "https://github.com/romkatv/powerlevel10k.git" "$ZSH_CUSTOM/themes/powerlevel10k"
    ensure_zsh_plugin "zsh-autosuggestions" "https://github.com/zsh-users/zsh-autosuggestions" "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    ensure_zsh_plugin "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting" "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    ensure_zsh_plugin "zsh-completions" "https://github.com/zsh-users/zsh-completions" "$ZSH_CUSTOM/plugins/zsh-completions"
    echo -e "${GREEN}✓ プラグイン完了${NC}"
fi

# --- 6. 追加設定 ---
show_step 6 6 "追加設定"

# macOS defaults
if [ "$DRY_RUN" = true ]; then
    echo -e "${CYAN}[DRY RUN] macOS defaults・追加設定をスキップ${NC}"
else
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.3
defaults write com.apple.dock tilesize -int 48
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.finder AppleShowAllFiles -bool true
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 15
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
defaults write -g com.apple.mouse.scaling -float 5.0
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write -g AppleShowScrollBars -string "Always"
defaults write -g AppleActionOnDoubleClick -string "Maximize"
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0
defaults write com.apple.AdLib forceLimitAdTracking -bool true
defaults write com.cmuxterm.app sidebarMaterial -string "hudWindow"
defaults write com.cmuxterm.app sidebarBlendMode -string "behindWindow"
defaults write com.cmuxterm.app sidebarBlurOpacity -float 0.80
defaults write com.cmuxterm.app sidebarTintHex -string "#1a1b26"
defaults write com.cmuxterm.app sidebarTintOpacity -string "0.35"
defaults write com.cmuxterm.app appearanceMode -string "dark"
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
killall Dock 2>/dev/null || true; killall Finder 2>/dev/null || true
echo -e "${GREEN}✓ macOS defaults${NC}"

# git-secrets
if command -v git-secrets &>/dev/null; then
    git secrets --install ~/.git-templates/git-secrets 2>/dev/null || true
    git secrets --register-aws --global 2>/dev/null || true
    echo -e "${GREEN}✓ git-secrets${NC}"
fi

# asdf
if command -v asdf &>/dev/null; then
    asdf plugin add nodejs 2>/dev/null || true
    asdf plugin add python 2>/dev/null || true
    asdf plugin add terraform 2>/dev/null || true
    [ -f ~/.tool-versions ] && asdf install
    echo -e "${GREEN}✓ asdf${NC}"
fi

# Neovim TokyoNight
TOKYONIGHT_DIR="$HOME/.local/share/nvim/site/pack/colors/start/tokyonight.nvim"
if [ ! -d "$TOKYONIGHT_DIR" ]; then
    mkdir -p "$(dirname "$TOKYONIGHT_DIR")"
    git clone --depth=1 https://github.com/folke/tokyonight.nvim "$TOKYONIGHT_DIR"
    echo -e "${GREEN}✓ Neovim TokyoNight${NC}"
fi

# bat TokyoNight
BAT_THEMES_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/bat/themes"
if [ ! -f "$BAT_THEMES_DIR/tokyonight_night.tmTheme" ]; then
    mkdir -p "$BAT_THEMES_DIR"
    if curl -fsSL "https://raw.githubusercontent.com/folke/tokyonight.nvim/main/extras/sublime/tokyonight_night.tmTheme" \
        -o "$BAT_THEMES_DIR/tokyonight_night.tmTheme" 2>/dev/null; then
        bat cache --build 2>/dev/null || true
        echo -e "${GREEN}✓ bat TokyoNight${NC}"
    fi
fi

# GitHub CLI aliases
if command -v gh &>/dev/null; then
    gh alias set co 'pr checkout' 2>/dev/null || true
    gh alias set prc 'pr create --fill' 2>/dev/null || true
    gh alias set prv 'pr view --web' 2>/dev/null || true
    gh alias set prm 'pr merge --auto --squash' 2>/dev/null || true
    gh alias set prl 'pr list' 2>/dev/null || true
    gh alias set iss 'issue list' 2>/dev/null || true
    gh alias set issv 'issue view --web' 2>/dev/null || true
    gh alias set repo 'repo view --web' 2>/dev/null || true
    echo -e "${GREEN}✓ GitHub CLI aliases${NC}"
fi
fi # DRY_RUN guard for step 6

# pam-watchid (Apple Watch sudo認証)
if [ "$DRY_RUN" != true ]; then
    if ask "Apple Watchでsudo認証を有効にしますか?"; then
        if ! command -v swiftc &>/dev/null; then
            echo -e "${YELLOW}⚠ swiftcが必要です → xcode-select --install${NC}"
        else
            local_pam="/usr/local/lib/pam/pam_watchid.so"
            sudo_local="/etc/pam.d/sudo_local"
            if [ ! -f "$local_pam" ]; then
                build_dir="/tmp/pam-watchid-build"
                rm -rf "$build_dir"
                git clone --depth=1 https://github.com/biscuitehh/pam-watchid.git "$build_dir"
                if make -C "$build_dir" 2>/dev/null; then
                    sudo mkdir -p "$(dirname "$local_pam")"
                    sudo cp "$build_dir/pam_watchid.so" "$local_pam"
                    sudo chmod 444 "$local_pam"
                    echo -e "${GREEN}✓ pam_watchid.so${NC}"
                fi
                rm -rf "$build_dir"
            fi
            if [ -f "$local_pam" ]; then
                watchid='auth       sufficient     pam_watchid.so "reason=execute a command as root"'
                touchid='auth       sufficient     pam_tid.so'
                if [ -f "$sudo_local" ]; then
                    grep -q "pam_watchid" "$sudo_local" || echo "$watchid" | sudo tee -a "$sudo_local" >/dev/null
                else
                    printf "# sudo_local\n%s\n%s\n" "$watchid" "$touchid" | sudo tee "$sudo_local" >/dev/null
                fi
                echo -e "${GREEN}✓ pam-watchid${NC}"
            fi
        fi
    fi
fi

# Claude Code
if [ "$SKIP_CLAUDE" = false ] && [ -x "$HOME/.claude/setup.sh" ]; then
    if command -v claude &>/dev/null; then
        [ "$DRY_RUN" = true ] && echo -e "${CYAN}[DRY RUN] Claude Code${NC}" || "$HOME/.claude/setup.sh"
    else
        echo -e "${YELLOW}⚠ Claude Code未インストール → npm install -g @anthropic-ai/claude-code${NC}"
    fi
fi

# ローカル設定
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
