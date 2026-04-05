#!/bin/bash
set -euo pipefail

# Claude Code 自動アップデートスクリプト
# LaunchAgent から毎日実行される

CLAUDE_BIN="$HOME/.local/bin/claude"
LOG_DIR="$HOME/.claude/logs"
LOG_FILE="$LOG_DIR/auto-update.log"
MAX_LOG_LINES=100

mkdir -p "$LOG_DIR"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"; }

# ログローテーション
if [ -f "$LOG_FILE" ] && [ "$(wc -l < "$LOG_FILE")" -gt "$MAX_LOG_LINES" ]; then
    tail -n "$MAX_LOG_LINES" "$LOG_FILE" > "$LOG_FILE.tmp"
    mv "$LOG_FILE.tmp" "$LOG_FILE"
fi

# バイナリ存在チェック
if [ ! -x "$CLAUDE_BIN" ]; then
    log "ERROR: Claude binary not found at $CLAUDE_BIN"
    exit 1
fi

# 現在バージョン取得
current=$("$CLAUDE_BIN" --version 2>/dev/null | head -1 || echo "unknown")
log "CHECK: Current version $current"

# 更新実行
output=$("$CLAUDE_BIN" update 2>&1) || {
    log "ERROR: Update failed - $output"
    exit 1
}

# 更新後バージョン取得
new=$("$CLAUDE_BIN" --version 2>/dev/null | head -1 || echo "unknown")

if [ "$current" = "$new" ]; then
    log "SKIP: Already up to date ($current)"
else
    log "UPDATE: $current -> $new"
fi
