#!/bin/bash
# generate-changelog.sh - CHANGELOGを生成
# 使用方法: bash scripts/generate-changelog.sh
# 前提条件: brew install git-cliff

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

# カラー出力
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=== CHANGELOG Generator ==="
echo ""

# git-cliff インストール確認
if ! command -v git-cliff &> /dev/null; then
    echo -e "${YELLOW}git-cliff がインストールされていません${NC}"
    echo "インストール: brew install git-cliff"
    exit 1
fi

cd "$DOTFILES_DIR"

# CHANGELOG生成
echo "CHANGELOG.md を生成しています..."
git-cliff --config cliff.toml --output CHANGELOG.md

echo ""
echo -e "${GREEN}✓ CHANGELOG.md を生成しました${NC}"
echo ""
echo "次のステップ:"
echo "  1. CHANGELOG.md を確認"
echo "  2. git add CHANGELOG.md && git commit -m 'docs: update changelog'"
