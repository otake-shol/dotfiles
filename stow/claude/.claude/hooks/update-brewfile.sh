#!/bin/bash
# Brewfile自動更新スクリプト
# brew install 実行後に自動でBrewfileを更新する

set -euo pipefail

BREWFILE="$HOME/dotfiles/Brewfile.full"

# Hook入力をJSON形式で受け取る
INPUT=$(cat)

# 実行されたコマンドを抽出
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null || echo "")

# brew install コマンドを検出
if echo "$COMMAND" | grep -qE "^brew install"; then
  # パッケージ名を抽出
  PACKAGE=$(echo "$COMMAND" | sed 's/brew install //' | awk '{print $1}')

  # Brewfile.fullを更新
  if brew bundle dump --describe --force --file="$BREWFILE" 2>/dev/null; then
    echo "✓ Brewfile.full updated after installing: $PACKAGE"
    echo "  Note: Review ~/dotfiles/Brewfile to add essential packages manually"
  else
    echo "⚠ Failed to update Brewfile.full"
  fi
fi

exit 0
