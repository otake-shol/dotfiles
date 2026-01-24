#!/bin/bash
# ========================================
# welcome.sh - 初回起動ウェルカムメッセージ
# ========================================
# 使用方法: source scripts/utils/welcome.sh
# .zshrcから呼び出される

# フラグファイル
WELCOME_FLAG="$HOME/.dotfiles-welcomed"

# 既に表示済みなら終了
[[ -f "$WELCOME_FLAG" ]] && return 0

# 色定義（sourceされる場合に備えて）
_W_CYAN='\033[0;36m'
_W_GREEN='\033[0;32m'
_W_YELLOW='\033[1;33m'
_W_BLUE='\033[0;34m'
_W_BOLD='\033[1m'
_W_NC='\033[0m'

# ウェルカムメッセージ表示
show_welcome() {
    cat << EOF

${_W_BOLD}${_W_CYAN}
    ____        __  _____ __
   / __ \____  / /_/ __(_) /__  _____
  / / / / __ \/ __/ /_/ / / _ \/ ___/
 / /_/ / /_/ / /_/ __/ / /  __(__  )
/_____/\____/\__/_/ /_/_/\___/____/
${_W_NC}
${_W_GREEN}Welcome to your new development environment!${_W_NC}

EOF

    echo -e "${_W_YELLOW}Quick Start:${_W_NC}"
    echo -e "  ${_W_CYAN}dothelp${_W_NC}        - Show available commands and aliases"
    echo -e "  ${_W_CYAN}dotupdate${_W_NC}      - Update all tools and plugins"
    echo -e "  ${_W_CYAN}dotup${_W_NC}          - Check for updates"
    echo ""

    echo -e "${_W_YELLOW}Useful Commands:${_W_NC}"
    echo -e "  ${_W_CYAN}ll${_W_NC}             - List files with details (eza)"
    echo -e "  ${_W_CYAN}j <dir>${_W_NC}        - Jump to directory (zoxide)"
    echo -e "  ${_W_CYAN}fvim${_W_NC}           - Fuzzy find and edit file"
    echo -e "  ${_W_CYAN}c${_W_NC}              - Open Claude Code"
    echo ""

    echo -e "${_W_YELLOW}Profile Switching:${_W_NC}"
    echo -e "  ${_W_BLUE}DOTFILES_PROFILE=personal${_W_NC}  - Default profile"
    echo -e "  ${_W_BLUE}DOTFILES_PROFILE=work${_W_NC}      - Work profile"
    echo -e "  ${_W_BLUE}DOTFILES_PROFILE=minimal${_W_NC}   - Fast startup"
    echo ""

    echo -e "${_W_YELLOW}Configuration:${_W_NC}"
    echo -e "  ${_W_CYAN}~/.zshrc.local${_W_NC} - Your local customizations"
    echo -e "  ${_W_CYAN}~/dotfiles/${_W_NC}    - Dotfiles repository"
    echo ""

    echo -e "${_W_GREEN}Happy coding!${_W_NC}"
    echo ""
}

# メイン処理
main() {
    show_welcome

    # フラグファイル作成（次回から表示しない）
    touch "$WELCOME_FLAG"

    # 次回以降の案内
    echo -e "${_W_YELLOW}(This message will only appear once. Run 'rm $WELCOME_FLAG' to see it again)${_W_NC}"
    echo ""
}

# 直接実行された場合、または source された場合に実行
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # 直接実行
    main
elif [[ -z "${WELCOME_FLAG_CHECKED:-}" ]]; then
    # sourceされた場合（一度だけ）
    export WELCOME_FLAG_CHECKED=1
    main
fi
