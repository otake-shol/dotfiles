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

# モデル名とカラー設定
case "$model" in
    *Opus*)
        short_model="Opus"
        MODEL_COLOR='\033[35m'   # 紫（高級感）
        ;;
    *Sonnet*)
        short_model="Sonnet"
        MODEL_COLOR='\033[34m'   # 青
        ;;
    *Haiku*)
        short_model="Haiku"
        MODEL_COLOR='\033[32m'   # 緑（軽量）
        ;;
    *)
        short_model="$model"
        MODEL_COLOR='\033[37m'   # 白（デフォルト）
        ;;
esac

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

# Nerd Font アイコン（UTF-8バイト列で指定）
# U+F07B (folder)    → UTF-8: EF 81 BB
# U+E725 (branch)    → UTF-8: EE 9C A5
# U+F544 (robot)     → UTF-8: EF 95 84
# U+F5DC (brain)     → UTF-8: EF 97 9C
# U+F040 (pencil)    → UTF-8: EF 81 80
# U+F017 (clock)     → UTF-8: EF 80 97
# U+F155 (dollar)    → UTF-8: EF 85 95
ICON_FOLDER=$(printf '\xef\x81\xbb')
ICON_BRANCH=$(printf '\xee\x9c\xa5')
ICON_MODEL=$(printf '\xf3\xb1\x8c\xbc')
ICON_BRAIN=$(printf '\xef\x97\x9c')
ICON_DIFF=$(printf '\xef\x81\x80')
ICON_CLOCK=$(printf '\xef\x80\x97')
ICON_MONEY=$(printf '\xef\x85\x95')

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
left="${CYAN}${BOLD}${ICON_FOLDER} ${dir}${RESET}"
if [ -n "$branch" ]; then
    left+=" ${MAGENTA}${ICON_BRANCH} ${branch}${RESET}"
fi

# 右セクション: モデル + コンテキスト + 行数 + 時間 + コスト
right="${MODEL_COLOR}${BOLD}${ICON_MODEL} ${short_model}${RESET}"
right+=" ${PCT_COLOR}${ICON_BRAIN} ${bar} ${used_pct}%${RESET}"
right+=" ${DIM}${ICON_DIFF}${RESET}${GREEN}+${lines_added}${RESET}${RED}-${lines_removed}${RESET}"
right+=" ${DIM}${ICON_CLOCK} ${duration_fmt}${RESET}"
right+=" ${GREEN}${ICON_MONEY} \$${cost_fmt}${RESET}"

echo -e "${left} ${DIM}│${RESET} ${right}"
