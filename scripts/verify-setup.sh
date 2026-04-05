#!/bin/bash
# verify-setup.sh - dotfilesセットアップ検証
# Usage: bash scripts/verify-setup.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "${SCRIPT_DIR}/common.sh"

# --- シンボリックリンク ---
verify_symlinks() {
    print_header "シンボリックリンク"
    local links=(
        "$HOME/.zshrc:stow/zsh/.zshrc"
        "$HOME/.aliases:stow/zsh/.aliases"
        "$HOME/.gitconfig:stow/git/.gitconfig"
        "$HOME/.config/nvim:stow/nvim/.config/nvim"
        "$HOME/.config/ghostty:stow/ghostty/.config/ghostty"
        "$HOME/.config/bat:stow/bat/.config/bat"
        "$HOME/.config/atuin:stow/atuin/.config/atuin"
        "$HOME/.config/yazi:stow/yazi/.config/yazi"
    )
    for pair in "${links[@]}"; do
        local target="${pair%%:*}"
        local name; name=$(basename "$target")
        if [[ -L "$target" ]]; then
            check_pass "$name"
        elif [[ -e "$target" ]]; then
            check_warn "$name (リンクではない)"
        else
            check_fail "$name"
        fi
    done
}

# --- ツール ---
verify_tools() {
    print_header "ツール"
    local tools=(
        git brew nvim zsh eza bat fd rg fzf zoxide
        delta atuin gh direnv stow
    )
    for cmd in "${tools[@]}"; do
        if command -v "$cmd" &>/dev/null; then
            check_pass "$cmd"
        else
            check_fail "$cmd"
        fi
    done
}

# --- asdf ---
verify_asdf() {
    print_header "asdf"
    if ! command -v asdf &>/dev/null; then
        check_fail "asdf"; return
    fi
    check_pass "asdf"
    [[ -f "$HOME/.tool-versions" ]] || { check_warn ".tool-versions なし"; return; }
    while IFS=' ' read -r lang version; do
        [[ -n "$lang" && ! "$lang" =~ ^# ]] || continue
        if asdf list "$lang" 2>/dev/null | grep -q "$version"; then
            check_pass "$lang $version"
        else
            check_warn "$lang $version 未インストール"
        fi
    done < "$HOME/.tool-versions"
}

# --- Git ---
verify_git() {
    print_header "Git"
    local name; name=$(git config user.name 2>/dev/null || echo "")
    local email; email=$(git config user.email 2>/dev/null || echo "")
    [[ -n "$name" ]] && check_pass "user.name: $name" || check_fail "user.name 未設定"
    [[ -n "$email" ]] && check_pass "user.email: $email" || check_fail "user.email 未設定"
}

# --- Oh My Zsh ---
verify_omz() {
    print_header "Oh My Zsh"
    local omz="$HOME/.oh-my-zsh"
    [[ -d "$omz" ]] && check_pass "Oh My Zsh" || { check_fail "Oh My Zsh"; return; }
    for p in zsh-autosuggestions zsh-syntax-highlighting zsh-completions; do
        [[ -d "$omz/custom/plugins/$p" ]] && check_pass "$p" || check_warn "$p"
    done
    [[ -d "$omz/custom/themes/powerlevel10k" ]] && check_pass "powerlevel10k" || check_warn "powerlevel10k"
}

# --- メイン ---
echo -e "${BOLD}${CYAN}dotfiles セットアップ検証${NC}"
verify_symlinks
verify_tools
verify_asdf
verify_git
verify_omz

print_header "結果"
echo -e "  ${GREEN}✓${NC} $COMMON_CHECK_PASS  ${YELLOW}⚠${NC} $COMMON_CHECK_WARN  ${RED}✗${NC} $COMMON_CHECK_FAIL"
[[ $COMMON_CHECK_FAIL -gt 0 ]] && exit 1 || true
