#!/bin/bash
# Claude Code statusline - Nerd Font アイコン版

input=$(cat)

# 値の取得
dir=$(echo "$input" | jq -r '.workspace.current_dir // "~"' | xargs basename)
model=$(echo "$input" | jq -r '.model.display_name // "Claude"')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
cost=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
duration_ms=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')
lines_added=$(echo "$input" | jq -r '.cost.total_lines_added // 0')
lines_removed=$(echo "$input" | jq -r '.cost.total_lines_removed // 0')

# モデル名短縮
short_model=$(echo "$model" | sed -E 's/Claude //' | sed -E 's/Opus 4.5/O4.5/' | sed -E 's/Sonnet 4/S4/' | sed -E 's/Haiku 3.5/H3.5/')

# 経過時間フォーマット（ms → 分/時間）
format_duration() {
    local ms=$1
    local seconds=$((ms / 1000))
    local minutes=$((seconds / 60))
    local hours=$((minutes / 60))

    if [ "$hours" -gt 0 ]; then
        echo "${hours}h$((minutes % 60))m"
    elif [ "$minutes" -gt 0 ]; then
        echo "${minutes}m"
    else
        echo "${seconds}s"
    fi
}
duration_fmt=$(format_duration "$duration_ms")

# Git ブランチ取得
branch=""
if git rev-parse --is-inside-work-tree &>/dev/null; then
    branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
fi

# カラー定義
RESET='\033[0m'
DIM='\033[2m'
BOLD='\033[1m'
CYAN='\033[36m'
MAGENTA='\033[35m'
YELLOW='\033[33m'
GREEN='\033[32m'
RED='\033[31m'
BLUE='\033[34m'

# コンテキスト使用率に応じた色
if [ "$used_pct" -lt 50 ]; then
    PCT_COLOR=$GREEN
elif [ "$used_pct" -lt 75 ]; then
    PCT_COLOR=$YELLOW
else
    PCT_COLOR=$RED
fi

# プログレスバー生成（10ブロック）
bar_width=10
filled=$((used_pct * bar_width / 100))
empty=$((bar_width - filled))
bar=""
for ((i=0; i<filled; i++)); do bar+="▰"; done
for ((i=0; i<empty; i++)); do bar+="▱"; done

# コストフォーマット
cost_fmt=$(printf "%.2f" "$cost")

# 左セクション: アイコン + ディレクトリ + ブランチ
left="${CYAN}${BOLD} ${dir}${RESET}"
if [ -n "$branch" ]; then
    left+=" ${MAGENTA} ${branch}${RESET}"
fi

# 右セクション: モデル + バー + % + 行数 + 時間 + コスト
right="${BLUE}${BOLD} ${short_model}${RESET}"
right+=" ${PCT_COLOR}${bar} ${used_pct}%${RESET}"
right+=" ${GREEN}+${lines_added}${RESET} ${RED}-${lines_removed}${RESET}"
right+=" ${DIM} ${duration_fmt}${RESET}"
right+=" ${GREEN} \$${cost_fmt}${RESET}"

echo -e "${left} ${DIM}│${RESET} ${right}"
