#!/bin/bash
# Codex notification hook.

set -euo pipefail

input=$(cat)

message=$(echo "$input" | jq -r '.message // .text // "Codex task completed"' 2>/dev/null || echo "Codex task completed")
title=$(echo "$input" | jq -r '.title // "Codex"' 2>/dev/null || echo "Codex")

if [ -S /tmp/cmux.sock ] && command -v cmux >/dev/null 2>&1; then
    cmux notify --title "$title" --body "$message" >/dev/null 2>&1 || true
fi

if command -v osascript >/dev/null 2>&1; then
    escaped_message="${message//\\/\\\\}"
    escaped_message="${escaped_message//\"/\\\"}"
    escaped_title="${title//\\/\\\\}"
    escaped_title="${escaped_title//\"/\\\"}"
    osascript -e "display notification \"$escaped_message\" with title \"$escaped_title\" sound name \"Glass\"" >/dev/null 2>&1 || true
fi
