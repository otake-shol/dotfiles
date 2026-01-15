#!/bin/bash
# 現在インストール済みのAntigravity拡張機能をextensions.txtにエクスポート
# Usage: ./export-extensions.sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
EXTENSIONS_FILE="$SCRIPT_DIR/extensions.txt"
ANTIGRAVITY_CLI="/Applications/Antigravity.app/Contents/Resources/app/bin/antigravity"

# Antigravity CLIの存在確認
if [ ! -f "$ANTIGRAVITY_CLI" ]; then
    echo "Error: Antigravity CLI not found at $ANTIGRAVITY_CLI"
    exit 1
fi

echo "Exporting installed extensions to $EXTENSIONS_FILE"

"$ANTIGRAVITY_CLI" --list-extensions 2>/dev/null | sort > "$EXTENSIONS_FILE"

count=$(wc -l < "$EXTENSIONS_FILE" | tr -d ' ')
echo "Exported $count extensions"
