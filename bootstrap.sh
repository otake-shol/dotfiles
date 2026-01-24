#!/bin/bash
# bootstrap.sh - 新しいMacの自動セットアップスクリプト
# 使用方法: bash bootstrap.sh
# オプション:
#   -n, --dry-run    実際の変更を行わずシミュレーション
#   -h, --help       ヘルプを表示
#   -v, --verbose    詳細出力
#   --skip-apps      アプリケーションインストールをスキップ

set -e  # エラーで停止

# ========================================
# 設定
# ========================================
DRY_RUN=false
VERBOSE=false
SKIP_APPS=false
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 共通ライブラリ読み込み
# shellcheck source=scripts/lib/common.sh
if [[ -f "${SCRIPT_DIR}/scripts/lib/common.sh" ]]; then
    source "${SCRIPT_DIR}/scripts/lib/common.sh"
else
    # フォールバック: common.shが無い場合の最小限定義
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    CYAN='\033[0;36m'
    NC='\033[0m'
    # safe_link関数の最小定義
    safe_link() { ln -sf "$1" "$2"; }
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

# ステップ表示（番号付き）
show_step() {
    local step=$1
    local total=$2
    local title=$3
    echo -e "\n${YELLOW}[$step/$total] ${title}${NC}"
}

# ログ関数（bootstrap.sh固有：LOG_FILE, VERBOSE使用）
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
    if [ "$VERBOSE" = true ]; then
        echo -e "${CYAN}[LOG] $1${NC}"
    fi
}

# Brewfileパッケージを個別インストール（状況表示付き）
install_brewfile_packages() {
    local brewfile="$1"
    local success=0
    local failed=0
    local skipped=0
    local failed_packages=()

    # Brewfileをパース
    local taps=()
    local brews=()
    local casks=()

    while IFS= read -r line; do
        # コメントと空行をスキップ
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
    local current=0

    echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║  📦 Brewfile パッケージインストール                    ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
    echo -e "総パッケージ数: ${CYAN}$total${NC} (tap: ${#taps[@]}, brew: ${#brews[@]}, cask: ${#casks[@]})"
    echo ""

    # Taps
    if [ ${#taps[@]} -gt 0 ]; then
        echo -e "${CYAN}┌── 🔌 Taps ──────────────────────────────────────────────┐${NC}"
        for tap in "${taps[@]}"; do
            ((current++))

            # インストール済みチェック
            if brew tap | grep -q "^${tap}$" 2>/dev/null; then
                printf "│ [%3d/%3d] %-42s ${GREEN}✓ 済${NC}\n" "$current" "$total" "$tap"
                ((skipped++))
            else
                printf "│ [%3d/%3d] %-42s " "$current" "$total" "$tap"
                if brew tap "$tap" &>/dev/null; then
                    echo -e "${GREEN}✓ 追加${NC}"
                    ((success++))
                else
                    echo -e "${RED}✗ 失敗${NC}"
                    ((failed++))
                    failed_packages+=("tap: $tap")
                fi
            fi
        done
        echo -e "${CYAN}└──────────────────────────────────────────────────────────┘${NC}"
        echo ""
    fi

    # Brews (CLIツール)
    if [ ${#brews[@]} -gt 0 ]; then
        echo -e "${CYAN}┌── 🛠  CLI Tools (brew) ─────────────────────────────────┐${NC}"
        for pkg in "${brews[@]}"; do
            ((current++))

            if brew list --formula "$pkg" &>/dev/null; then
                printf "│ [%3d/%3d] %-42s ${GREEN}✓ 済${NC}\n" "$current" "$total" "$pkg"
                ((skipped++))
            else
                printf "│ [%3d/%3d] %-42s " "$current" "$total" "$pkg"
                if brew install "$pkg" &>/dev/null; then
                    echo -e "${GREEN}✓ 完了${NC}"
                    ((success++))
                else
                    echo -e "${RED}✗ 失敗${NC}"
                    ((failed++))
                    failed_packages+=("brew: $pkg")
                fi
            fi

            # 10パッケージごとに進捗表示
            if (( current % 10 == 0 )); then
                printf "│ 進捗: %d/%d\n" "$current" "$total"
            fi
        done
        echo -e "${CYAN}└──────────────────────────────────────────────────────────┘${NC}"
        echo ""
    fi

    # Casks (GUIアプリ)
    if [ ${#casks[@]} -gt 0 ]; then
        echo -e "${CYAN}┌── 🖥  GUI Apps (cask) ──────────────────────────────────┐${NC}"
        for pkg in "${casks[@]}"; do
            ((current++))

            if brew list --cask "$pkg" &>/dev/null; then
                printf "│ [%3d/%3d] %-42s ${GREEN}✓ 済${NC}\n" "$current" "$total" "$pkg"
                ((skipped++))
            else
                printf "│ [%3d/%3d] %-42s " "$current" "$total" "$pkg"
                if brew install --cask "$pkg" &>/dev/null; then
                    echo -e "${GREEN}✓ 完了${NC}"
                    ((success++))
                else
                    echo -e "${RED}✗ 失敗${NC}"
                    ((failed++))
                    failed_packages+=("cask: $pkg")
                fi
            fi
        done
        echo -e "${CYAN}└──────────────────────────────────────────────────────────┘${NC}"
        echo ""
    fi

    # 完了メッセージ
    echo -e "完了: ${GREEN}$total/$total${NC}\n"

    # サマリー表示
    echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║  📊 インストール結果サマリー                          ║${NC}"
    echo -e "${BLUE}╠════════════════════════════════════════════════════════╣${NC}"
    printf "${BLUE}║${NC}  ${GREEN}✓ 新規インストール${NC}: %-34s${BLUE}║${NC}\n" "$success"
    printf "${BLUE}║${NC}  ${CYAN}○ スキップ（済）${NC}  : %-34s${BLUE}║${NC}\n" "$skipped"
    printf "${BLUE}║${NC}  ${RED}✗ 失敗${NC}            : %-34s${BLUE}║${NC}\n" "$failed"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"

    if [ $failed -gt 0 ]; then
        echo -e "\n${YELLOW}⚠ 失敗したパッケージ:${NC}"
        for pkg in "${failed_packages[@]}"; do
            echo -e "  ${RED}├─ $pkg${NC}"
        done
        log "Failed packages: ${failed_packages[*]}"
        return 1
    fi

    return 0
}

# クリーンアップ処理
cleanup() {
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        echo ""
        echo -e "${RED}╔════════════════════════════════════════════════════════╗${NC}"
        echo -e "${RED}║  ❌ エラーが発生しました                               ║${NC}"
        echo -e "${RED}╠════════════════════════════════════════════════════════╣${NC}"
        echo -e "${RED}║${NC}  終了コード: $exit_code"
        echo -e "${RED}║${NC}  ログファイル: $LOG_FILE"
        echo -e "${RED}╚════════════════════════════════════════════════════════╝${NC}"

        # ログから失敗パッケージを抽出
        if [ -f "$LOG_FILE" ]; then
            local failed_pkgs
            failed_pkgs=$(grep -i "failed packages" "$LOG_FILE" | tail -1)
            if [ -n "$failed_pkgs" ]; then
                echo ""
                echo -e "${YELLOW}┌── 失敗したパッケージ ───────────────────────────────────┐${NC}"
                echo -e "${YELLOW}│${NC} ${failed_pkgs#*: }"
                echo -e "${YELLOW}└──────────────────────────────────────────────────────────┘${NC}"
            fi

            # 直近のログエントリを表示
            echo ""
            echo -e "${CYAN}┌── 直近のログ (最後の5件) ───────────────────────────────┐${NC}"
            tail -5 "$LOG_FILE" | while IFS= read -r line; do
                echo -e "${CYAN}│${NC} $line"
            done
            echo -e "${CYAN}└──────────────────────────────────────────────────────────┘${NC}"
        fi

        echo ""
        echo -e "${YELLOW}💡 ヒント:${NC}"
        echo -e "  • 失敗したパッケージは後で個別にインストールできます"
        echo -e "  • brew install <パッケージ名> で再試行"
        echo -e "  • 詳細ログ: cat $LOG_FILE"

        log "ERROR: Setup failed with exit code $exit_code"
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

# OS/アーキテクチャ検出（os-detect.shの関数を使用）
detect_system() {
    OS="$(uname -s)"
    ARCH="$(uname -m)"

    # macOS専用
    if ! is_macos; then
        echo -e "${RED}このスクリプトはmacOS専用です${NC}"
        exit 1
    fi

    # Homebrewプレフィックスを統一関数で取得
    HOMEBREW_PREFIX=$(detect_homebrew_prefix)

    log "Detected: $OS ($ARCH), Homebrew prefix: $HOMEBREW_PREFIX"
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
    echo -e "\n${YELLOW}[0/7] Rosetta 2の確認（オプション）...${NC}"
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
    echo -e "${YELLOW}Homebrewをインストールしますか? (y/n)${NC}"
    read -r answer
    if [ "$answer" = "y" ]; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        # Homebrew PATH設定（HOMEBREW_PREFIXを使用）
        eval "$("${HOMEBREW_PREFIX}/bin/brew" shellenv)"
        echo -e "${GREEN}Homebrewのインストールが完了しました。${NC}"
    else
        echo -e "${RED}macOSではHomebrewが必要です。終了します。${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✓ Homebrewはインストール済みです${NC}"
    # 既存のHomebrew PATH設定（HOMEBREW_PREFIXを使用）
    eval "$("${HOMEBREW_PREFIX}/bin/brew" shellenv)" 2>/dev/null || true
fi

# ========================================
# 2. アプリケーションのインストール
# ========================================
echo -e "\n${YELLOW}[2/7] アプリケーションのインストール...${NC}"

if [ "$SKIP_APPS" = true ]; then
    echo -e "${CYAN}アプリケーションインストールをスキップします${NC}"
elif command -v brew &>/dev/null; then
    BREWFILE="Brewfile"
    echo -e "${GREEN}Brewfileからツールをインストールします${NC}"

    if [ -f "$BREWFILE" ]; then
        if install_brewfile_packages "$BREWFILE"; then
            echo -e "${GREEN}✓ アプリケーションのインストールが完了しました${NC}"
        else
            echo -e "${YELLOW}続行しますか? (y/n)${NC}"
            read -r answer
            if [ "$answer" != "y" ]; then
                echo -e "${RED}セットアップを中断しました${NC}"
                exit 1
            fi
        fi
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
# 注: sshはテンプレート方式のため別処理
STOW_PACKAGES=(zsh git nvim ghostty bat atuin claude gh)

for pkg in "${STOW_PACKAGES[@]}"; do
    stow_package "$pkg"
done
echo -e "${GREEN}✓ Stowパッケージをインストールしました (${STOW_PACKAGES[*]})${NC}"

# SSH設定（テンプレートからコピー、既存ファイルは上書きしない）
if [ "$DRY_RUN" != true ]; then
    mkdir -p ~/.ssh/sockets
    chmod 700 ~/.ssh
    if [ ! -f ~/.ssh/config ]; then
        cp "$SCRIPT_DIR/stow/ssh/.ssh/config.template" ~/.ssh/config
        echo -e "${GREEN}✓ SSH configを作成しました${NC}"
    else
        echo -e "${GREEN}✓ SSH configは既存です（スキップ）${NC}"
    fi
    chmod 600 ~/.ssh/config
else
    echo -e "${CYAN}[DRY RUN] Would setup SSH config${NC}"
fi

# antigravity (macOS only)
if [ "$IS_MACOS" = true ]; then
    ANTIGRAVITY_USER_DIR="$HOME/Library/Application Support/Antigravity/User"
    if [ -d "$HOME/Library/Application Support/Antigravity" ]; then
        mkdir -p "$ANTIGRAVITY_USER_DIR"
        safe_link ~/dotfiles/stow/antigravity/settings.json "$ANTIGRAVITY_USER_DIR/settings.json"
        if [ -f ~/dotfiles/stow/antigravity/keybindings.json ]; then
            safe_link ~/dotfiles/stow/antigravity/keybindings.json "$ANTIGRAVITY_USER_DIR/keybindings.json"
        fi
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
        git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions \
            "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/plugins/zsh-autosuggestions

        # zsh-syntax-highlighting
        git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting \
            "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/plugins/zsh-syntax-highlighting

        # zsh-completions
        git clone --depth=1 https://github.com/zsh-users/zsh-completions \
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

# macOS固有設定
if [ -f ~/dotfiles/scripts/setup/macos_defaults.sh ]; then
    bash ~/dotfiles/scripts/setup/macos_defaults.sh
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
    asdf plugin add terraform 2>/dev/null || true

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
# 6. 追加のmacOS設定
# ========================================
echo -e "\n${YELLOW}[6/7] macOS固有設定は適用済みです${NC}"

# ========================================
# 7. 完了
# ========================================
log "=== Setup completed successfully ==="

# 成功時はログファイルを削除（失敗時のみ残す）
rm -f "$LOG_FILE"

echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}  セットアップが完了しました！${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "\n${YELLOW}次のステップ:${NC}"
echo -e "  1. ターミナルを再起動するか、'source ~/.zshrc' を実行"
echo -e "  2. Powerlevel10kの設定: 'p10k configure'"
echo -e "  3. Nerd Fontをターミナルに設定"
echo -e "\n${BLUE}追加のアプリケーションは docs/setup/APPS.md を参照してください${NC}"
