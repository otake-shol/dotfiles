#!/bin/bash
# Claude Code セットアップスクリプト
# 新しいPCでMCPサーバーとプラグインを設定する
#
# 使用方法:
#   ~/.claude/setup.sh
#
# 前提条件:
#   - Claude Code がインストール済み
#   - npm, uvx (uv) がインストール済み

set -euo pipefail

# カラー定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

info() { echo -e "${CYAN}[INFO]${RESET} $1"; }
success() { echo -e "${GREEN}[OK]${RESET} $1"; }
warn() { echo -e "${YELLOW}[WARN]${RESET} $1"; }
error() { echo -e "${RED}[ERROR]${RESET} $1"; }

echo ""
echo "========================================"
echo "  Claude Code セットアップ"
echo "========================================"
echo ""

# 前提条件チェック
info "前提条件をチェック中..."

if ! command -v claude &>/dev/null; then
    error "Claude Code がインストールされていません"
    echo "  → npm install -g @anthropic-ai/claude-code"
    exit 1
fi

if ! command -v npx &>/dev/null; then
    error "npx がインストールされていません"
    exit 1
fi

if ! command -v uvx &>/dev/null; then
    warn "uvx がインストールされていません（Serena, Atlassian MCPに必要）"
    echo "  → brew install uv"
fi

success "前提条件OK"
echo ""

# ======================================
# MCPサーバーの設定
# ======================================
info "MCPサーバーを設定中..."

# Context7 - リアルタイムドキュメント参照
info "  → Context7"
claude mcp add context7 --scope user -- npx -y @upstash/context7-mcp@latest 2>/dev/null || warn "Context7 の追加をスキップ（既存の可能性）"

# Playwright - ブラウザ自動化
info "  → Playwright"
claude mcp add playwright --scope user -- npx -y @playwright/mcp@latest 2>/dev/null || warn "Playwright の追加をスキップ（既存の可能性）"

# GitHub - Issue/PR操作（OAuth認証）
info "  → GitHub"
claude mcp add github --scope user --transport http https://api.githubcopilot.com/mcp/ 2>/dev/null || warn "GitHub の追加をスキップ（既存の可能性）"

# Google Workspace CLI - Gmail/Drive/Calendar/Sheets/Docs操作
if command -v gws &>/dev/null; then
    info "  → Google Workspace (gws)"
    claude mcp add gws --scope user -- gws mcp -s all 2>/dev/null || warn "gws の追加をスキップ（既存の可能性）"
else
    warn "  → Google Workspace (gws) をスキップ（未インストール）"
    echo "    インストール: npm install -g @googleworkspace/cli"
    echo "    認証設定:    gws auth setup"
fi

success "MCPサーバー設定完了"
echo ""

# ======================================
# 日本特化MCPサーバー
# ======================================
info "日本特化MCPサーバーを設定中..."

# hourei-mcp-server - e-Gov法令API（法令検索・条文取得・改正履歴）
info "  → 法令検索（hourei）"
claude mcp add hourei --scope user -- npx -y hourei-mcp-server 2>/dev/null || warn "hourei の追加をスキップ（既存の可能性）"

# tax-law-mcp - 税法・通達・裁決事例
info "  → 税法（tax-law）"
claude mcp add tax-law --scope user -- npx -y tax-law-mcp 2>/dev/null || warn "tax-law の追加をスキップ（既存の可能性）"

success "日本特化MCPサーバー設定完了"
echo ""

# ======================================
# プラグインのインストール
# ======================================
info "プラグインをインストール中..."

# superpowers マーケットプレイスを追加
info "  → マーケットプレイス: obra/superpowers-marketplace"
claude /plugin marketplace add obra/superpowers-marketplace 2>/dev/null || warn "マーケットプレイス追加をスキップ（既存の可能性）"

# superpowers プラグインをインストール
info "  → プラグイン: superpowers"
claude /plugin install superpowers@superpowers-marketplace 2>/dev/null || warn "プラグインインストールをスキップ（既存の可能性）"

success "プラグインインストール完了"
echo ""

# ======================================
# 完了
# ======================================
echo "========================================"
echo -e "${GREEN}  セットアップ完了！${RESET}"
echo "========================================"
echo ""
echo "設定されたMCPサーバー:"
echo "  - Context7    : リアルタイムドキュメント参照"
echo "  - Playwright  : ブラウザ自動化・E2Eテスト"
echo "  - GitHub      : Issue/PR操作（OAuth認証必要）"
echo "  - gws         : Gmail/Drive/Calendar/Sheets/Docs操作（要 gws auth setup）"
echo "  - hourei      : e-Gov法令検索・条文取得"
echo "  - tax-law     : 税法・通達・裁決事例"
echo ""
echo "インストールされたプラグイン:"
echo "  - superpowers : 開発ワークフロー強化"
echo ""
echo "確認コマンド:"
echo "  claude mcp list        # MCPサーバー一覧"
echo "  claude /plugin list    # プラグイン一覧"
echo ""
