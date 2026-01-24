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
# コマンド存在確認
require_command() {
    local cmd="$1"
    local msg="${2:-$cmd が必要です}"
    if ! command -v "$cmd" &>/dev/null; then
        log_error "$msg"
        return 1
    fi
    return 0
}

# 複数コマンド存在確認
require_commands() {
    local missing=()
    for cmd in "$@"; do
        if ! command -v "$cmd" &>/dev/null; then
            missing+=("$cmd")
        fi
    done
    if [[ ${#missing[@]} -gt 0 ]]; then
        log_error "必要なコマンドがインストールされていません: ${missing[*]}"
        return 1
    fi
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
