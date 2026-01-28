#!/bin/bash
# Claude Code statusline - 詳細派 & かっこいい版

input=$(cat)

# 値の取得
dir=$(echo "$input" | jq -r '.workspace.current_dir // "~"' | xargs basename)
model=$(echo "$input" | jq -r '.model.display_name // "Claude"')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
total_in=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
total_out=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
ctx_size=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')
cost=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')

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
# WHITE='\033[97m'  # 未使用だが将来用に残す

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
for ((i=0; i<filled; i++)); do bar+="█"; done
for ((i=0; i<empty; i++)); do bar+="░"; done

# トークン数のフォーマット（k単位）
format_tokens() {
    local tokens=$1
    if [ "$tokens" -ge 1000 ]; then
        echo "$((tokens / 1000))k"
    else
        echo "$tokens"
    fi
}

total_tokens=$((total_in + total_out))
tokens_fmt=$(format_tokens "$total_tokens")
ctx_fmt=$(format_tokens "$ctx_size")

# コストフォーマット
cost_fmt=$(printf "%.2f" "$cost")

# 左セクション: ディレクトリ + ブランチ
left="${CYAN}${BOLD}${dir}${RESET}"
if [ -n "$branch" ]; then
    left+=" ${DIM}on${RESET} ${MAGENTA}${branch}${RESET}"
fi

# 右セクション: モデル + バー + トークン + コスト
right="${BLUE}${BOLD}${model}${RESET}"
right+=" ${DIM}[${RESET}${PCT_COLOR}${bar}${RESET}${DIM}]${RESET}"
right+=" ${PCT_COLOR}${used_pct}%${RESET}"
right+=" ${DIM}${tokens_fmt}/${ctx_fmt}${RESET}"
right+=" ${GREEN}\$${cost_fmt}${RESET}"

echo -e "${left} ${DIM}│${RESET} ${right}"
