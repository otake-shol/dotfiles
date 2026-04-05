#!/bin/bash
# common.sh - dotfiles共通ライブラリ
# Usage: source scripts/lib/common.sh

[[ -n "${_COMMON_SH_LOADED:-}" ]] && return 0
_COMMON_SH_LOADED=1

# --- 色定義 ---
export RED='\033[0;31m' GREEN='\033[0;32m' YELLOW='\033[1;33m'
export BLUE='\033[0;34m' CYAN='\033[0;36m' NC='\033[0m'
export BOLD='\033[1m'

# --- チェック関数 ---
COMMON_CHECK_PASS=0
COMMON_CHECK_FAIL=0
COMMON_CHECK_WARN=0

check_pass() { echo -e "  ${GREEN}✓${NC} $*"; ((COMMON_CHECK_PASS++)) || true; }
check_fail() { echo -e "  ${RED}✗${NC} $*"; ((COMMON_CHECK_FAIL++)) || true; }
check_warn() { echo -e "  ${YELLOW}⚠${NC} $*"; ((COMMON_CHECK_WARN++)) || true; }

# --- UI関数 ---
print_header() { echo -e "\n${BOLD}${CYAN}── $1 ──${NC}"; }
print_section() { echo -e "\n${BOLD}${BLUE}▸ $1${NC}"; }

# --- Zshプラグイン冪等インストール（bootstrap.shで使用） ---
ensure_zsh_plugin() {
    local name="$1" repo_url="$2" dest="$3"
    if [ -d "$dest/.git" ]; then
        cd "$dest" && git pull --quiet 2>/dev/null && echo -e "  ${GREEN}✓${NC} $name (updated)" || echo -e "  ${YELLOW}⚠${NC} $name (pull failed)"
    elif [ -d "$dest" ]; then
        rm -rf "$dest"
        git clone --depth=1 "$repo_url" "$dest" 2>/dev/null
        echo -e "  ${GREEN}✓${NC} $name (re-cloned)"
    else
        git clone --depth=1 "$repo_url" "$dest" 2>/dev/null
        echo -e "  ${GREEN}✓${NC} $name (installed)"
    fi
}

# --- ファイルリンク ---
safe_link() {
    local src="$1" dst="$2"
    [[ ! -e "$src" ]] && echo -e "${YELLOW}⚠ ソースが存在しません: $src${NC}" && return 1
    if [[ -e "$dst" && ! -L "$dst" ]]; then
        mv "$dst" "${dst}.backup.$(date +%Y%m%d%H%M%S)"
    fi
    ln -sf "$src" "$dst"
}

# --- OS検出 ---
is_macos() { [[ "$(uname -s)" == "Darwin" ]]; }

detect_homebrew_prefix() {
    [[ "$(uname -m)" == "arm64" ]] && echo "/opt/homebrew" || echo "/usr/local"
}
