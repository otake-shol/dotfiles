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

# Figma - デザイン→コード変換（HTTP）
info "  → Figma"
claude mcp add figma --scope user --transport http https://mcp.figma.com/mcp 2>/dev/null || warn "Figma の追加をスキップ（既存の可能性）"

# Serena - シンボリックコード解析（uvx必要）
if command -v uvx &>/dev/null; then
    info "  → Serena"
    claude mcp add serena --scope user -- uvx --from "git+https://github.com/oraios/serena" serena start-mcp-server --context=claude-code --project-from-cwd 2>/dev/null || warn "Serena の追加をスキップ（既存の可能性）"
else
    warn "  → Serena をスキップ（uvx未インストール）"
fi

# Atlassian - Jira/Confluence（uvx必要、環境変数要設定）
if command -v uvx &>/dev/null; then
    info "  → Atlassian（環境変数の設定が必要）"
    # 注意: 環境変数は別途設定が必要
    # JIRA_URL, JIRA_USERNAME, JIRA_API_TOKEN
    # CONFLUENCE_URL, CONFLUENCE_USERNAME, CONFLUENCE_API_TOKEN
    claude mcp add atlassian --scope user -- uvx mcp-atlassian 2>/dev/null || warn "Atlassian の追加をスキップ（既存の可能性）"
    warn "  Atlassianを使用するには環境変数の設定が必要です:"
    echo "    export JIRA_URL=https://your-domain.atlassian.net"
    echo "    export JIRA_USERNAME=your-email@example.com"
    echo "    export JIRA_API_TOKEN=your-api-token"
else
    warn "  → Atlassian をスキップ（uvx未インストール）"
fi

success "MCPサーバー設定完了"
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
echo "  - Figma       : デザイン→コード変換（OAuth認証必要）"
echo "  - Serena      : シンボリックコード解析"
echo "  - Atlassian   : Jira/Confluence操作（環境変数必要）"
echo ""
echo "インストールされたプラグイン:"
echo "  - superpowers : 開発ワークフロー強化"
echo ""
echo "確認コマンド:"
echo "  claude mcp list        # MCPサーバー一覧"
echo "  claude /plugin list    # プラグイン一覧"
echo ""
