#!/bin/bash
# generate_brewfile.sh - 現在インストールされているパッケージからBrewfileを生成
# 使用方法: bash scripts/utils/generate_brewfile.sh

set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
OUTPUT_FILE="$DOTFILES_DIR/Brewfile"

echo "=== Brewfile Generator ==="
echo ""
echo "現在インストールされているパッケージをBrewfileに保存します。"
echo "出力先: $OUTPUT_FILE"
echo ""

read -p "続行しますか? (y/n): " confirm
if [[ "$confirm" != "y" ]]; then
    echo "キャンセルしました"
    exit 0
fi

echo ""
echo "Brewfileを生成しています..."
brew bundle dump --force --file="$OUTPUT_FILE"

echo ""
echo "✓ Brewfileの生成が完了しました"
echo ""
echo "次のステップ:"
echo "  1. $OUTPUT_FILE を確認・編集"
echo "  2. git add Brewfile && git commit -m 'chore: update Brewfile'"
