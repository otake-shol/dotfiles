#!/bin/bash
# Antigravity拡張機能の一括インストールスクリプト
# Usage: ./install-extensions.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
EXTENSIONS_FILE="$SCRIPT_DIR/extensions.txt"
ANTIGRAVITY_CLI="/Applications/Antigravity.app/Contents/Resources/app/bin/antigravity"

# Antigravity CLIの存在確認
if [ ! -f "$ANTIGRAVITY_CLI" ]; then
    echo "Error: Antigravity CLI not found at $ANTIGRAVITY_CLI"
    exit 1
fi

# extensions.txtの存在確認
if [ ! -f "$EXTENSIONS_FILE" ]; then
    echo "Error: extensions.txt not found at $EXTENSIONS_FILE"
    exit 1
fi

echo "Installing Antigravity extensions from $EXTENSIONS_FILE"
echo "================================================"

# 現在インストール済みの拡張機能を取得
installed=$("$ANTIGRAVITY_CLI" --list-extensions 2>/dev/null)

# extensions.txtを1行ずつ読み込んでインストール
while IFS= read -r extension || [ -n "$extension" ]; do
    # 空行やコメント行をスキップ
    [[ -z "$extension" || "$extension" =~ ^# ]] && continue

    # 既にインストール済みかチェック
    if echo "$installed" | grep -q "^${extension}$"; then
        echo "[SKIP] $extension (already installed)"
    else
        echo "[INSTALL] $extension"
        "$ANTIGRAVITY_CLI" --install-extension "$extension" --force 2>/dev/null || {
            echo "  -> Failed to install $extension"
        }
    fi
done < "$EXTENSIONS_FILE"

echo ""
echo "Done!"
