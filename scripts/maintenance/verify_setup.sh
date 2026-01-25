#!/bin/bash
# ========================================
# verify_setup.sh - dotfilesセットアップ検証
# ========================================
# 使用方法: bash scripts/maintenance/verify_setup.sh

set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 共通ライブラリ読み込み
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"

# カウンターはcommon.shのグローバル変数（COMMON_CHECK_PASS/FAIL/WARN）を直接使用

# ========================================
# シンボリックリンク検証
# ========================================
verify_symlinks() {
    print_header "シンボリックリンク検証"

    # stow/配下のパスパターン（相対パスで作成されるため末尾で判定）
    local links=(
        "$HOME/.zshrc:stow/zsh/.zshrc"
        "$HOME/.aliases:stow/zsh/.aliases"
        "$HOME/.gitconfig:stow/git/.gitconfig"
        "$HOME/.config/nvim:stow/nvim/.config/nvim"
        "$HOME/.config/ghostty:stow/ghostty/.config/ghostty"
        "$HOME/.tool-versions:stow/zsh/.tool-versions"
        "$HOME/.p10k.zsh:stow/zsh/.p10k.zsh"
        "$HOME/.config/bat:stow/bat/.config/bat"
        "$HOME/.config/atuin:stow/atuin/.config/atuin"
        "$HOME/.config/gh/config.yml:stow/gh/.config/gh/config.yml"
        "$HOME/.config/yazi:stow/yazi/.config/yazi"
    )

    for link_pair in "${links[@]}"; do
        local target="${link_pair%%:*}"
        local expected_suffix="${link_pair##*:}"
        local name
        name=$(basename "$target")

        if [[ -L "$target" ]]; then
            local actual_source
            actual_source=$(readlink "$target")
            # 相対パスの末尾が期待するパターンと一致するかチェック
            if [[ "$actual_source" == *"$expected_suffix" ]]; then
                check_pass "$name"
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
        "tokei:コード統計"
        "atuin:シェル履歴"
        "gh:GitHub CLI"
        "direnv:環境変数管理"
        "lefthook:Git hooks"
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

    # mise
    if command -v mise &>/dev/null; then
        check_pass "mise インストール済み"

        # .tool-versions確認
        if [[ -f "$HOME/.tool-versions" ]]; then
            check_pass ".tool-versions リンク済み"

            # 各言語のバージョン確認
            while IFS=' ' read -r lang version; do
                if [[ -n "$lang" && ! "$lang" =~ ^# ]]; then
                    if mise list "$lang" 2>/dev/null | grep -q "$version"; then
                        check_pass "$lang $version インストール済み"
                    else
                        check_warn "$lang $version 未インストール (mise install で解決)"
                    fi
                fi
            done < "$HOME/.tool-versions"
        else
            check_warn ".tool-versions が見つかりません"
        fi
    else
        check_fail "mise が見つかりません"
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
}

# ========================================
# Git設定検証
# ========================================
verify_git_config() {
    print_header "Git設定検証"

    # ユーザー設定（include経由の設定も取得するため--globalなしで実行）
    local name
    local email
    name=$(git -C "$DOTFILES_DIR" config user.name 2>/dev/null || echo "")
    email=$(git -C "$DOTFILES_DIR" config user.email 2>/dev/null || echo "")

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
# 結果サマリー（common.shのカウンターを使用）
# ========================================
show_summary() {
    print_header "検証結果サマリー"

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
    else
        echo -e "${RED}${BOLD}いくつかの問題があります。bootstrap.shを再実行してください${NC}"
        echo -e "   ${CYAN}cd ~/dotfiles && bash bootstrap.sh${NC}"
    fi
}

# ========================================
# メイン実行
# ========================================
main() {
    print_banner "dotfiles セットアップ検証ツール"

    verify_symlinks
    verify_required_tools
    verify_optional_tools
    verify_version_managers
    verify_configs
    verify_git_config
    show_summary

    # 終了コード
    if [[ $COMMON_CHECK_FAIL -gt 0 ]]; then
        exit 1
    fi
}

main "$@"
