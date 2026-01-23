#!/bin/bash
# ========================================
# verify-setup.sh - dotfilesセットアップ検証
# ========================================
# 使用方法: bash scripts/maintenance/verify-setup.sh

set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

# 色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

# カウンター
PASS=0
FAIL=0
WARN=0

print_header() {
    echo -e "\n${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}${CYAN} $1${NC}"
    echo -e "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

check_pass() {
    echo -e "  ${GREEN}✓${NC} $1"
    ((PASS++))
}

check_fail() {
    echo -e "  ${RED}✗${NC} $1"
    ((FAIL++))
}

check_warn() {
    echo -e "  ${YELLOW}⚠${NC} $1"
    ((WARN++))
}

# ========================================
# シンボリックリンク検証
# ========================================
verify_symlinks() {
    print_header "シンボリックリンク検証"

    local links=(
        "$HOME/.zshrc:$DOTFILES_DIR/.zshrc"
        "$HOME/.aliases:$DOTFILES_DIR/.aliases"
        "$HOME/.gitconfig:$DOTFILES_DIR/git/.gitconfig"
        "$HOME/.config/nvim:$DOTFILES_DIR/nvim/.config/nvim"
        "$HOME/.tmux.conf:$DOTFILES_DIR/tmux/.tmux.conf"
        "$HOME/.config/ghostty:$DOTFILES_DIR/ghostty"
        "$HOME/.tool-versions:$DOTFILES_DIR/.tool-versions"
    )

    for link_pair in "${links[@]}"; do
        local target="${link_pair%%:*}"
        local source="${link_pair##*:}"
        local name
        name=$(basename "$target")

        if [[ -L "$target" ]]; then
            local actual_source
            actual_source=$(readlink "$target")
            if [[ "$actual_source" == "$source" ]]; then
                check_pass "$name → $source"
            else
                check_warn "$name リンク先が異なる: $actual_source"
            fi
        elif [[ -e "$target" ]]; then
            check_warn "$name 存在するがシンボリックリンクではない"
        else
            check_fail "$name リンクが存在しない"
        fi
    done
}

# ========================================
# 必須ツール検証
# ========================================
verify_required_tools() {
    print_header "必須ツール検証"

    local tools=(
        "git:バージョン管理"
        "brew:パッケージ管理"
        "nvim:エディタ"
        "zsh:シェル"
        "eza:モダンls"
        "bat:モダンcat"
        "fd:モダンfind"
        "rg:モダンgrep"
        "fzf:ファジーファインダー"
        "zoxide:スマートcd"
    )

    for tool_pair in "${tools[@]}"; do
        local cmd="${tool_pair%%:*}"
        local desc="${tool_pair##*:}"

        if command -v "$cmd" &>/dev/null; then
            # shellcheck disable=SC2034
            local version
            version=$($cmd --version 2>/dev/null | head -1 || echo "installed")
            check_pass "$cmd ($desc)"
        else
            check_fail "$cmd が見つかりません ($desc)"
        fi
    done
}

# ========================================
# 推奨ツール検証
# ========================================
verify_optional_tools() {
    print_header "推奨ツール検証"

    local tools=(
        "delta:Git diff"
        "dust:ディスク使用量"
        "procs:プロセス表示"
        "tokei:コード統計"
        "glow:Markdown表示"
        "atuin:シェル履歴"
        "gh:GitHub CLI"
        "direnv:環境変数管理"
        "lefthook:Git hooks"
        "trash:安全な削除"
    )

    for tool_pair in "${tools[@]}"; do
        local cmd="${tool_pair%%:*}"
        local desc="${tool_pair##*:}"

        if command -v "$cmd" &>/dev/null; then
            check_pass "$cmd ($desc)"
        else
            check_warn "$cmd が見つかりません ($desc)"
        fi
    done
}

# ========================================
# バージョンマネージャー検証
# ========================================
verify_version_managers() {
    print_header "バージョンマネージャー検証"

    # asdf
    if command -v asdf &>/dev/null; then
        check_pass "asdf インストール済み"

        # .tool-versions確認
        if [[ -f "$HOME/.tool-versions" ]]; then
            check_pass ".tool-versions リンク済み"

            # 各言語のバージョン確認
            while IFS=' ' read -r lang version; do
                if [[ -n "$lang" && ! "$lang" =~ ^# ]]; then
                    if asdf list "$lang" 2>/dev/null | grep -q "$version"; then
                        check_pass "$lang $version インストール済み"
                    else
                        check_warn "$lang $version 未インストール (asdf install で解決)"
                    fi
                fi
            done < "$HOME/.tool-versions"
        else
            check_warn ".tool-versions が見つかりません"
        fi
    else
        check_fail "asdf が見つかりません"
    fi
}

# ========================================
# 設定ファイル検証
# ========================================
verify_configs() {
    print_header "設定ファイル検証"

    # zshプラグイン
    local oh_my_zsh="$HOME/.oh-my-zsh"
    if [[ -d "$oh_my_zsh" ]]; then
        check_pass "Oh My Zsh インストール済み"

        local plugins=(
            "zsh-autosuggestions"
            "zsh-syntax-highlighting"
            "zsh-completions"
        )
        for plugin in "${plugins[@]}"; do
            if [[ -d "$oh_my_zsh/custom/plugins/$plugin" ]]; then
                check_pass "$plugin プラグイン"
            else
                check_warn "$plugin プラグイン未インストール"
            fi
        done
    else
        check_fail "Oh My Zsh が見つかりません"
    fi

    # Powerlevel10k
    if [[ -d "$oh_my_zsh/custom/themes/powerlevel10k" ]]; then
        check_pass "Powerlevel10k テーマ"
    else
        check_warn "Powerlevel10k 未インストール"
    fi

    # tmux plugin manager
    if [[ -d "$HOME/.tmux/plugins/tpm" ]]; then
        check_pass "TPM (tmux plugin manager)"
    else
        check_warn "TPM 未インストール"
    fi
}

# ========================================
# Git設定検証
# ========================================
verify_git_config() {
    print_header "Git設定検証"

    # ユーザー設定
    local name
    local email
    name=$(git config --global user.name 2>/dev/null || echo "")
    email=$(git config --global user.email 2>/dev/null || echo "")

    if [[ -n "$name" ]]; then
        check_pass "Git user.name: $name"
    else
        check_fail "Git user.name 未設定"
    fi

    if [[ -n "$email" ]]; then
        check_pass "Git user.email: $email"
    else
        check_fail "Git user.email 未設定"
    fi

    # git-secrets
    if command -v git-secrets &>/dev/null; then
        check_pass "git-secrets インストール済み"
    else
        check_warn "git-secrets 未インストール"
    fi

    # delta
    local pager
    pager=$(git config --global core.pager 2>/dev/null || echo "")
    if [[ "$pager" == *"delta"* ]]; then
        check_pass "delta がGit pagerに設定済み"
    else
        check_warn "delta がGit pagerに未設定"
    fi
}

# ========================================
# 結果サマリー
# ========================================
print_summary() {
    print_header "検証結果サマリー"

    echo -e "  ${GREEN}✓ 成功:${NC} $PASS 項目"
    echo -e "  ${YELLOW}⚠ 警告:${NC} $WARN 項目"
    echo -e "  ${RED}✗ 失敗:${NC} $FAIL 項目"
    echo ""

    if [[ $FAIL -eq 0 ]]; then
        if [[ $WARN -eq 0 ]]; then
            echo -e "${GREEN}${BOLD}🎉 完璧！全ての検証に成功しました${NC}"
        else
            echo -e "${YELLOW}${BOLD}✅ 基本セットアップは完了。警告項目を確認してください${NC}"
        fi
    else
        echo -e "${RED}${BOLD}❌ いくつかの問題があります。bootstrap.shを再実行してください${NC}"
        echo -e "   ${CYAN}cd ~/dotfiles && bash bootstrap.sh${NC}"
    fi
}

# ========================================
# メイン実行
# ========================================
main() {
    echo -e "${BOLD}${CYAN}"
    echo "╔═══════════════════════════════════════════════╗"
    echo "║   dotfiles セットアップ検証ツール            ║"
    echo "╚═══════════════════════════════════════════════╝"
    echo -e "${NC}"

    verify_symlinks
    verify_required_tools
    verify_optional_tools
    verify_version_managers
    verify_configs
    verify_git_config
    print_summary

    # 終了コード
    if [[ $FAIL -gt 0 ]]; then
        exit 1
    fi
}

main "$@"
