#!/bin/bash
# Claude Code環境検証スクリプト
#
# 使い方: ~/.claude/validate.sh
#
# 環境が正しくセットアップされているか検証

set -euo pipefail

echo "=== Claude Code 環境検証 ==="
echo ""

errors=0
warnings=0

# 色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

ok() { echo -e "${GREEN}✓${NC} $1"; }
warn() { echo -e "${YELLOW}⚠${NC} $1"; ((warnings++)); }
fail() { echo -e "${RED}✗${NC} $1"; ((errors++)); }

# 1. 必須ファイル
echo "📁 必須ファイル..."
[ -f ~/.claude/settings.json ] && ok "settings.json" || fail "settings.json 未検出"
[ -f ~/.claude/CLAUDE.md ] && ok "CLAUDE.md" || fail "CLAUDE.md 未検出"
[ -f ~/.claude/environment.md ] && ok "environment.md" || warn "environment.md 未検出（推奨）"

# 2. Hooks
echo ""
echo "🔗 Hooks..."
[ -x ~/.claude/hooks/auto-format.sh ] && ok "auto-format.sh (実行可能)" || warn "auto-format.sh 未設定"
[ -x ~/.claude/hooks/notify.sh ] && ok "notify.sh (実行可能)" || warn "notify.sh 未設定"
[ -x ~/.claude/hooks/verify.sh ] && ok "verify.sh (実行可能)" || warn "verify.sh 未設定"

# 3. コマンド
echo ""
echo "📝 コマンド..."
commands=(verify worktree learn commit-push review test spec)
for cmd in "${commands[@]}"; do
    [ -f ~/.claude/commands/"$cmd".md ] && ok "/$(basename "$cmd")" || warn "/$cmd 未定義"
done

# 4. エージェント
echo ""
echo "🤖 エージェント..."
agents=(code-reviewer test-engineer frontend-engineer spec-analyst architecture-reviewer)
for agent in "${agents[@]}"; do
    if [ -f ~/.claude/agents/"$agent".md ]; then
        if grep -q "^model:" ~/.claude/agents/"$agent".md 2>/dev/null; then
            ok "$agent (model指定あり)"
        else
            warn "$agent (model指定なし)"
        fi
    else
        warn "$agent 未定義"
    fi
done

# 5. 依存ツール
echo ""
echo "🔧 依存ツール..."
command -v jq &>/dev/null && ok "jq" || fail "jq 未インストール（必須）"
command -v prettier &>/dev/null && ok "prettier" || warn "prettier 未インストール"
command -v eslint &>/dev/null && ok "eslint" || warn "eslint 未インストール"
command -v shfmt &>/dev/null && ok "shfmt" || warn "shfmt 未インストール"
command -v black &>/dev/null && ok "black (Python)" || warn "black 未インストール"
command -v rustfmt &>/dev/null && ok "rustfmt (Rust)" || warn "rustfmt 未インストール"
command -v gofmt &>/dev/null && ok "gofmt (Go)" || warn "gofmt 未インストール"

# 6. MCP設定
echo ""
echo "🌐 MCP..."
if [ -f ~/.claude/settings.json ]; then
    mcp_count=$(jq '.mcpServers | length // 0' ~/.claude/settings.json 2>/dev/null || echo "0")
    if [ "$mcp_count" -gt 0 ]; then
        ok "MCPサーバー: $mcp_count 個設定済み"
    else
        warn "MCPサーバー未設定"
    fi
fi

# 7. プラグイン
echo ""
echo "🔌 プラグイン..."
if [ -f ~/.claude/settings.json ]; then
    if jq -e '.enabledPlugins["superpowers@superpowers-marketplace"]' ~/.claude/settings.json &>/dev/null; then
        ok "superpowers プラグイン有効"
    else
        warn "superpowers プラグイン無効（推奨）"
    fi
fi

# 結果サマリー
echo ""
echo "=== 検証完了 ==="
echo "エラー: $errors / 警告: $warnings"
echo ""

if [ $errors -eq 0 ]; then
    echo -e "${GREEN}環境は正常です${NC}"
    exit 0
else
    echo -e "${RED}$errors 個のエラーを修正してください${NC}"
    exit 1
fi
