#!/bin/bash
# Notification Hook: タスク完了をmacOS通知で知らせる
#
# 入力JSON例:
# {
#   "message": "Task completed",
#   "title": "Claude Code"
# }

set -euo pipefail

input=$(cat)

# 通知メッセージを取得
message=$(echo "$input" | jq -r '.message // "Claude Code notification"')
title=$(echo "$input" | jq -r '.title // "Claude Code"')

# macOS通知を送信（特殊文字をエスケープして安全に渡す）
if command -v osascript &>/dev/null; then
    escaped_message="${message//\\/\\\\}"
    escaped_message="${escaped_message//\"/\\\"}"
    escaped_title="${title//\\/\\\\}"
    escaped_title="${escaped_title//\"/\\\"}"
    osascript -e "display notification \"$escaped_message\" with title \"$escaped_title\" sound name \"Glass\""
fi

exit 0
