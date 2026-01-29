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

# macOS通知を送信
if command -v osascript &>/dev/null; then
    osascript -e "display notification \"$message\" with title \"$title\" sound name \"Glass\""
fi

exit 0
