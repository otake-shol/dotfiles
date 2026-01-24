#!/bin/bash
# ========================================
# common.sh - dotfiles共通ライブラリ
# ========================================
# 使用方法: source scripts/lib/common.sh
#
# このライブラリは以下を提供します:
#   - 色定義（統一されたカラーコード）
#   - ログ関数（log_info, log_success, log_warn, log_error, log_debug）
#   - チェック関数（check_pass, check_fail, check_warn）
#   - UI関数（print_header, print_section）
#   - ユーティリティ（require_command, confirm, run_cmd）

# 二重読み込み防止
[[ -n "${_COMMON_SH_LOADED:-}" ]] && return 0
_COMMON_SH_LOADED=1

# ========================================
# 色定義
# ========================================
# 基本色
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export BLUE='\033[0;34m'
export CYAN='\033[0;36m'
export MAGENTA='\033[0;35m'

# 修飾
export BOLD='\033[1m'
export DIM='\033[2m'
export UNDERLINE='\033[4m'

# リセット
export NC='\033[0m'

# ========================================
# ログ関数
# ========================================
# 詳細出力フラグ（グローバル設定）
COMMON_VERBOSE="${COMMON_VERBOSE:-false}"

# 情報ログ（青色）
log_info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

# 成功ログ（緑色）
log_success() {
    echo -e "${GREEN}[OK]${NC} $*"
}

# 警告ログ（黄色）
log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*" >&2
}

# エラーログ（赤色）
log_error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

# デバッグログ（シアン、COMMON_VERBOSE=trueの時のみ）
log_debug() {
    if [[ "${COMMON_VERBOSE}" == "true" ]]; then
        echo -e "${CYAN}[DEBUG]${NC} $*"
    fi
}

# ========================================
# チェック関数（テスト結果表示用）
# ========================================
# グローバルカウンター
COMMON_CHECK_PASS=0
COMMON_CHECK_FAIL=0
COMMON_CHECK_WARN=0

# 成功チェック
check_pass() {
    echo -e "  ${GREEN}✓${NC} $*"
    ((COMMON_CHECK_PASS++)) || true
}

# 失敗チェック
check_fail() {
    echo -e "  ${RED}✗${NC} $*"
    ((COMMON_CHECK_FAIL++)) || true
}

# 警告チェック
check_warn() {
    echo -e "  ${YELLOW}⚠${NC} $*"
    ((COMMON_CHECK_WARN++)) || true
}

# カウンターリセット
check_reset_counters() {
    COMMON_CHECK_PASS=0
    COMMON_CHECK_FAIL=0
    COMMON_CHECK_WARN=0
}

# カウンター取得
check_get_pass() { echo "$COMMON_CHECK_PASS"; }
check_get_fail() { echo "$COMMON_CHECK_FAIL"; }
check_get_warn() { echo "$COMMON_CHECK_WARN"; }

# ========================================
# UI関数
# ========================================
# ヘッダー表示（大きな区切り）
print_header() {
    local title="$1"
    echo -e "\n${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}${CYAN} ${title}${NC}"
    echo -e "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# セクション表示（小さな区切り）
print_section() {
    local title="$1"
    echo -e "\n${BOLD}${BLUE}▸ ${title}${NC}"
}

# バナー表示（スクリプト開始時用）
print_banner() {
    local title="$1"
    echo -e "${BOLD}${CYAN}"
    echo "╔═══════════════════════════════════════════════╗"
    printf "║ %-45s ║\n" "$title"
    echo "╚═══════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# 区切り線
print_separator() {
    echo -e "${BLUE}========================================${NC}"
}

# ========================================
# ユーティリティ関数
# ========================================

# インストール方法のヒント（コマンド名 -> インストール方法）
_get_install_hint() {
    local cmd="$1"
    local os_type
    os_type="$(uname -s)"

    # macOS用のインストール方法
    local -A macos_hints=(
        [git]="xcode-select --install"
        [brew]="/bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        [stow]="brew install stow"
        [zsh]="brew install zsh"
        [fzf]="brew install fzf"
        [rg]="brew install ripgrep"
        [fd]="brew install fd"
        [bat]="brew install bat"
        [eza]="brew install eza"
        [zoxide]="brew install zoxide"
        [atuin]="brew install atuin"
        [direnv]="brew install direnv"
        [gh]="brew install gh"
        [jq]="brew install jq"
        [shellcheck]="brew install shellcheck"
        [bats]="brew install bats-core"
        [nix]="curl -L https://nixos.org/nix/install | sh"
    )

    # Linux用のインストール方法
    local -A linux_hints=(
        [git]="sudo apt install git  # または yum/dnf/pacman"
        [stow]="sudo apt install stow"
        [zsh]="sudo apt install zsh"
        [fzf]="sudo apt install fzf  # または git clone"
        [rg]="sudo apt install ripgrep"
        [fd]="sudo apt install fd-find"
        [bat]="sudo apt install bat"
        [jq]="sudo apt install jq"
        [shellcheck]="sudo apt install shellcheck"
        [nix]="curl -L https://nixos.org/nix/install | sh"
    )

    if [[ "$os_type" == "Darwin" ]]; then
        echo "${macos_hints[$cmd]:-brew install $cmd}"
    else
        echo "${linux_hints[$cmd]:-パッケージマネージャーでインストールしてください}"
    fi
}

# コマンド存在確認（インストールヒント付き）
require_command() {
    local cmd="$1"
    local msg="${2:-}"
    if ! command -v "$cmd" &>/dev/null; then
        if [[ -n "$msg" ]]; then
            log_error "$msg"
        else
            log_error "$cmd が必要です"
            log_info "インストール方法: $(_get_install_hint "$cmd")"
        fi
        return 1
    fi
    return 0
}

# 複数コマンド存在確認（インストールヒント付き）
require_commands() {
    local missing=()
    for cmd in "$@"; do
        if ! command -v "$cmd" &>/dev/null; then
            missing+=("$cmd")
        fi
    done
    if [[ ${#missing[@]} -gt 0 ]]; then
        log_error "必要なコマンドがインストールされていません: ${missing[*]}"
        echo ""
        for cmd in "${missing[@]}"; do
            log_info "  $cmd: $(_get_install_hint "$cmd")"
        done
        return 1
    fi
    return 0
}

# バージョン要件チェック
# 使用例: require_version "node" "18.0.0" "node --version"
require_version() {
    local cmd="$1"
    local min_version="$2"
    local version_cmd="${3:-$cmd --version}"

    if ! command -v "$cmd" &>/dev/null; then
        log_error "$cmd がインストールされていません"
        log_info "インストール方法: $(_get_install_hint "$cmd")"
        return 1
    fi

    # バージョン取得（数字部分のみ抽出）
    local current_version
    current_version=$(eval "$version_cmd" 2>/dev/null | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1)

    if [[ -z "$current_version" ]]; then
        log_warn "$cmd のバージョンを取得できませんでした"
        return 0  # バージョン取得失敗は警告のみ
    fi

    # バージョン比較（シンプルな文字列比較）
    if [[ "$(printf '%s\n' "$min_version" "$current_version" | sort -V | head -n1)" != "$min_version" ]]; then
        log_error "$cmd のバージョンが古いです: $current_version (必要: >= $min_version)"
        return 1
    fi

    log_debug "$cmd バージョン確認OK: $current_version (>= $min_version)"
    return 0
}

# ユーザー確認プロンプト
confirm() {
    local prompt="${1:-続行しますか?}"
    local default="${2:-n}"  # デフォルトはno

    local yn_hint
    if [[ "$default" == "y" ]]; then
        yn_hint="Y/n"
    else
        yn_hint="y/N"
    fi

    echo -en "${YELLOW}${prompt} [${yn_hint}]: ${NC}"
    read -r answer
    answer="${answer:-$default}"

    case "$answer" in
        [Yy]*) return 0 ;;
        *) return 1 ;;
    esac
}

# ドライラン対応コマンド実行
# 使用前に DRY_RUN=true/false を設定
run_cmd() {
    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        echo -e "${CYAN}[DRY RUN]${NC} $*"
        return 0
    else
        "$@"
    fi
}

# 安全なシンボリックリンク作成
safe_link() {
    local src="$1"
    local dest="$2"

    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        if [[ -L "$dest" ]]; then
            log_debug "[DRY RUN] Would update symlink: $dest -> $src"
        elif [[ -e "$dest" ]]; then
            log_debug "[DRY RUN] Would backup and link: $dest -> $src"
        else
            log_debug "[DRY RUN] Would create symlink: $dest -> $src"
        fi
        return 0
    fi

    if [[ -L "$dest" ]]; then
        rm "$dest"
    elif [[ -e "$dest" ]]; then
        local backup
        backup="${dest}.backup.$(date +%Y%m%d%H%M%S)"
        mv "$dest" "$backup"
        log_warn "バックアップ作成: $backup"
    fi

    ln -sf "$src" "$dest"
    log_debug "リンク作成: $src -> $dest"
}

# ========================================
# OS検出（os-detect.shとの連携）
# ========================================
# os-detect.shが存在すれば読み込む
_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "${_SCRIPT_DIR}/os-detect.sh" ]]; then
    # shellcheck source=./os-detect.sh
    source "${_SCRIPT_DIR}/os-detect.sh"
fi

# 基本的なOS検出（os-detect.shがない場合のフォールバック）
is_macos() {
    [[ "$(uname -s)" == "Darwin" ]]
}

is_linux() {
    [[ "$(uname -s)" == "Linux" ]]
}

is_wsl() {
    is_linux && grep -qEi "(Microsoft|WSL)" /proc/version 2>/dev/null
}

is_arm64() {
    [[ "$(uname -m)" == "arm64" || "$(uname -m)" == "aarch64" ]]
}

# ========================================
# プログレスバー
# ========================================
# 使用例: show_progress 3 10 "処理中..."
show_progress() {
    local current=$1
    local total=$2
    local message="${3:-処理中}"
    local width=40
    local percent=$((current * 100 / total))
    local filled=$((width * current / total))
    local empty=$((width - filled))

    # プログレスバーの描画
    printf '\r%s[' "${BLUE}"
    printf "%${filled}s" | tr ' ' '█'
    printf "%${empty}s" | tr ' ' '░'
    printf '] %3d%% %s%s' "$percent" "${NC}" "${message}"

    # 完了時は改行
    if [ "$current" -eq "$total" ]; then
        echo ""
    fi
}

# スピナー表示（バックグラウンド処理用）
# 使用例: start_spinner "処理中" & SPINNER_PID=$!; ...; stop_spinner $SPINNER_PID
start_spinner() {
    local message="${1:-処理中}"
    local chars="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
    local i=0
    while true; do
        printf '\r%s%s%s %s' "${CYAN}" "${chars:$i:1}" "${NC}" "${message}"
        i=$(( (i + 1) % ${#chars} ))
        sleep 0.1
    done
}

stop_spinner() {
    local pid=$1
    kill "$pid" 2>/dev/null
    printf "\r"
}

# ========================================
# 結果サマリー表示
# ========================================
print_summary() {
    local title="${1:-検証結果サマリー}"
    print_header "$title"

    echo -e "  ${GREEN}✓ 成功:${NC} $COMMON_CHECK_PASS 項目"
    echo -e "  ${YELLOW}⚠ 警告:${NC} $COMMON_CHECK_WARN 項目"
    echo -e "  ${RED}✗ 失敗:${NC} $COMMON_CHECK_FAIL 項目"
    echo ""

    if [[ $COMMON_CHECK_FAIL -eq 0 ]]; then
        if [[ $COMMON_CHECK_WARN -eq 0 ]]; then
            echo -e "${GREEN}${BOLD}完璧！全ての検証に成功しました${NC}"
        else
            echo -e "${YELLOW}${BOLD}基本セットアップは完了。警告項目を確認してください${NC}"
        fi
        return 0
    else
        echo -e "${RED}${BOLD}いくつかの問題があります${NC}"
        return 1
    fi
}

# ========================================
# 直接実行された場合のテスト
# ========================================
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "common.sh ライブラリテスト"
    print_separator

    log_info "情報メッセージ"
    log_success "成功メッセージ"
    log_warn "警告メッセージ"
    log_error "エラーメッセージ"

    COMMON_VERBOSE=true
    log_debug "デバッグメッセージ（VERBOSE=true）"

    print_header "ヘッダーテスト"
    print_section "セクションテスト"

    check_pass "成功項目"
    check_warn "警告項目"
    check_fail "失敗項目"

    print_summary "テスト結果"

    echo ""
    echo "OS情報:"
    is_macos && echo "  - macOS"
    is_linux && echo "  - Linux"
    is_wsl && echo "  - WSL"
    is_arm64 && echo "  - ARM64"
fi
