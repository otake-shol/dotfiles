#!/bin/bash
# ========================================
# demo-scenario.sh - 自動デモシナリオスクリプト
# ========================================
# このスクリプトはデモGIF録画中に自動実行されます
# 使用方法: asciinema rec --command "bash demo-scenario.sh" demo.cast
#
# 各コマンドは自動的にタイプされ、実行されます
# タイピング速度と待機時間を調整可能

set -e

# タイピング速度（秒/文字）
TYPE_SPEED=0.03
# コマンド間の待機時間
WAIT_TIME=1.5
# 実行後の待機時間
EXEC_WAIT=1.0

# 色定義
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# タイプ風にテキストを表示
type_text() {
    local text="$1"
    echo -n -e "${GREEN}\$ ${NC}"
    for ((i = 0; i < ${#text}; i++)); do
        echo -n "${text:$i:1}"
        sleep $TYPE_SPEED
    done
    echo ""
}

# コメント表示
show_comment() {
    echo -e "${CYAN}# $1${NC}"
    sleep 0.5
}

# コマンド実行
run_cmd() {
    type_text "$1"
    sleep 0.3
    eval "$1"
    sleep $EXEC_WAIT
}

# セクション区切り
section() {
    echo ""
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}▶ $1${NC}"
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    sleep $WAIT_TIME
}

# ========================================
# デモシナリオ開始
# ========================================

clear

echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}    ${GREEN}dotfiles${NC} - Modern Cross-Platform Development Setup   ${CYAN}║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
sleep 2

# セクション1: セットアップの簡単さ
section "Quick Setup"
show_comment "One command to set up everything"
type_text "cd ~/dotfiles && bash bootstrap.sh --dry-run"
sleep $WAIT_TIME

# セクション2: モダンCLIツール
section "Modern CLI Tools"

show_comment "eza: ls with icons and Git status"
run_cmd "eza -la --icons --git"

show_comment "bat: cat with syntax highlighting"
run_cmd "bat --style=header,grid ~/.zshrc --line-range 1:20"

show_comment "ripgrep: blazingly fast search"
run_cmd "rg --type zsh 'alias' ~/dotfiles/aliases/ -l"

# セクション3: fzf統合
section "fzf Integrations"

show_comment "Fuzzy file finder (fvim)"
type_text "fvim"
echo -e "${CYAN}  → Interactively select file and open in nvim${NC}"
sleep $WAIT_TIME

show_comment "Git branch selector (fbr)"
type_text "fbr"
echo -e "${CYAN}  → Fuzzy search branches and checkout${NC}"
sleep $WAIT_TIME

# セクション4: Gitエイリアス
section "Git Aliases"

show_comment "Common git operations"
run_cmd "alias | grep \"^g\""

show_comment "Quick status"
run_cmd "gs"

# セクション5: エイリアスヘルプ
section "Built-in Documentation"

show_comment "Find any alias or function"
run_cmd "dothelp | head -20"

# セクション6: AI駆動開発
section "AI-Driven Development"

show_comment "13 MCP servers pre-configured"
type_text "claude --version"
echo ""
echo -e "${CYAN}  MCP Servers:${NC}"
echo "  • Context7 (real-time docs)"
echo "  • Serena (symbolic code analysis)"
echo "  • Playwright (browser automation)"
echo "  • GitHub, Slack, Linear, Notion..."
sleep 2

# セクション7: カスタムコマンド
section "Custom Claude Commands"

show_comment "Available slash commands"
echo -e "${GREEN}/commit-push${NC}  - Stage, commit, and push"
echo -e "${GREEN}/review${NC}       - AI code review"
echo -e "${GREEN}/test${NC}         - Generate test code"
echo -e "${GREEN}/spec${NC}         - Create specifications"
sleep 2

# 終了
echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}           ${GREEN}Get started in seconds!${NC}                        ${CYAN}║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
type_text "git clone https://github.com/otake-shol/dotfiles ~/dotfiles"
type_text "cd ~/dotfiles && bash bootstrap.sh"
echo ""
echo -e "${YELLOW}⭐ Star the repo if you find it useful!${NC}"
echo ""
sleep 3
