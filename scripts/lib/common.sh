#!/bin/bash
# ========================================
# common.sh - dotfiles共通ライブラリ
# ========================================
# 使用方法: source scripts/lib/common.sh
#
# このライブラリは以下を提供します:
#   - 色定義（統一されたカラーコード）
#   - チェック関数（dotfiles_check_pass, dotfiles_check_fail, dotfiles_check_warn）
#   - UI関数（dotfiles_print_header, dotfiles_print_section, dotfiles_print_banner）
#   - ユーティリティ（dotfiles_safe_link, dotfiles_update_zsh_plugin）
#
# 注: 後方互換性のため、接頭辞なしの関数名もエイリアスとして利用可能

# 二重読み込み防止
[[ -n "${_COMMON_SH_LOADED:-}" ]] && return 0
_COMMON_SH_LOADED=1

# ========================================
# グローバル定数
# ========================================
# キャッシュの有効期限（日数）- 全体で統一
export DOTFILES_CACHE_TTL_DAYS="${DOTFILES_CACHE_TTL_DAYS:-7}"

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
# チェック関数（テスト結果表示用）
# ========================================
# グローバルカウンター
COMMON_CHECK_PASS=0
COMMON_CHECK_FAIL=0
COMMON_CHECK_WARN=0

# 成功チェック
dotfiles_check_pass() {
    echo -e "  ${GREEN}✓${NC} $*"
    ((COMMON_CHECK_PASS++)) || true
}

# 失敗チェック
dotfiles_check_fail() {
    echo -e "  ${RED}✗${NC} $*"
    ((COMMON_CHECK_FAIL++)) || true
}

# 警告チェック
dotfiles_check_warn() {
    echo -e "  ${YELLOW}⚠${NC} $*"
    ((COMMON_CHECK_WARN++)) || true
}

# 短縮エイリアス（各スクリプトで使用）
check_pass() { dotfiles_check_pass "$@"; }
check_fail() { dotfiles_check_fail "$@"; }
check_warn() { dotfiles_check_warn "$@"; }

# ========================================
# UI関数
# ========================================
# ヘッダー表示（大きな区切り）
dotfiles_print_header() {
    local title="$1"
    echo -e "\n${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}${CYAN} ${title}${NC}"
    echo -e "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# セクション表示（小さな区切り）
dotfiles_print_section() {
    local title="$1"
    echo -e "\n${BOLD}${BLUE}▸ ${title}${NC}"
}

# バナー表示（スクリプト開始時用）
dotfiles_print_banner() {
    local title="$1"
    echo -e "${BOLD}${CYAN}"
    echo "╔═══════════════════════════════════════════════╗"
    printf "║ %-45s ║\n" "$title"
    echo "╚═══════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# 短縮エイリアス（各スクリプトで使用）
print_header() { dotfiles_print_header "$@"; }
print_section() { dotfiles_print_section "$@"; }
print_banner() { dotfiles_print_banner "$@"; }

# ========================================
# Zshプラグイン更新（update-all.shで使用）
# ========================================
# 引数: プラグイン名, プラグインパス
dotfiles_update_zsh_plugin() {
    local name="$1"
    local path="$2"

    if [ -d "$path" ]; then
        cd "$path" || return 1
        if git pull --quiet; then
            echo -e "  ${GREEN}✓${NC} $name"
            return 0
        else
            echo -e "  ${RED}✗${NC} $name"
            return 1
        fi
    fi
}

# 短縮エイリアス（各スクリプトで使用）
update_zsh_plugin() { dotfiles_update_zsh_plugin "$@"; }

# ========================================
# ファイルリンク関数
# ========================================
# 安全にシンボリックリンクを作成（既存ファイルのバックアップ付き）
# Usage: dotfiles_safe_link "/path/to/source" "/path/to/destination"
dotfiles_safe_link() {
    local src="$1"
    local dst="$2"

    # ソースファイルの存在確認
    if [[ ! -e "$src" ]]; then
        echo -e "${YELLOW}⚠ ソースが存在しません: $src${NC}"
        return 1
    fi

    # 既存ファイル/ディレクトリの処理
    if [[ -e "$dst" && ! -L "$dst" ]]; then
        local backup
        backup="${dst}.backup.$(date +%Y%m%d%H%M%S)"
        echo -e "${YELLOW}⚠ $dst が存在します。バックアップを作成: $backup${NC}"
        mv "$dst" "$backup"
    fi

    # シンボリックリンク作成
    ln -sf "$src" "$dst"
}

# 短縮エイリアス（bootstrap.shで使用）
safe_link() { dotfiles_safe_link "$@"; }

# ========================================
# OS検出（os-detect.shとの連携）
# ========================================
# os-detect.shが存在すれば読み込む
_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "${_SCRIPT_DIR}/os_detect.sh" ]]; then
    # shellcheck source=./os_detect.sh
    source "${_SCRIPT_DIR}/os_detect.sh"
fi
