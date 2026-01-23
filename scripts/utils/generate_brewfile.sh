#!/bin/bash
# generate_brewfile.sh - Brewfileを生成するヘルパースクリプト

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

echo "=== Brewfile Generator ==="
echo ""
echo "現在インストールされているアプリケーションをBrewfileに保存します。"
echo ""
echo "保存先を選択してください:"
echo "  1) Brewfile (必須ツールのみ - 手動で編集が必要)"
echo "  2) Brewfile.full (全ツール)"
echo ""
read -p "選択 (1 or 2): " choice

case $choice in
    1)
        OUTPUT_FILE="$DOTFILES_DIR/Brewfile"
        echo ""
        echo "注意: Brewfileには全ツールが出力されます。"
        echo "必要なツールのみを残すため、手動で編集してください。"
        ;;
    2)
        OUTPUT_FILE="$DOTFILES_DIR/Brewfile.full"
        ;;
    *)
        echo "無効な選択です。"
        exit 1
        ;;
esac

echo ""
echo "Brewfileを生成しています: $OUTPUT_FILE"
brew bundle dump --force --file="$OUTPUT_FILE"

if [ $? -eq 0 ]; then
    echo ""
    echo "✓ Brewfileの生成が完了しました: $OUTPUT_FILE"
    echo ""
    echo "次のステップ:"
    if [ "$choice" = "1" ]; then
        echo "  1. $OUTPUT_FILE を開く"
        echo "  2. 必須ツールのみを残して編集"
        echo "  3. git add & commit"
    else
        echo "  1. git add & commit"
    fi
else
    echo ""
    echo "✗ Brewfileの生成に失敗しました"
    exit 1
fi
