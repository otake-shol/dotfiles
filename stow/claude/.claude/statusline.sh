#!/bin/bash
# Claude Code statusline - グラデーション＋アクセントスタイル

input=$(cat)

# 値の取得
dir_full=$(echo "$input" | jq -r '.workspace.current_dir // "~"')
dir=$(echo "$dir_full" | sed "s|^$HOME|~|")
model=$(echo "$input" | jq -r '.model.display_name // "Claude"')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
cost=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
session_id=$(echo "$input" | jq -r '.session_id // ""' | cut -c1-8)
lines_added=$(echo "$input" | jq -r '.cost.total_lines_added // 0')
lines_removed=$(echo "$input" | jq -r '.cost.total_lines_removed // 0')

# モデル名とカラー設定
case "$model" in
    *Opus*)
        short_model="Opus"
        MODEL_COLOR='\033[38;5;208m'   # オレンジ（プレミアム感）
        ;;
    *Sonnet*)
        short_model="Sonnet"
        MODEL_COLOR='\033[94m'   # 明るい青
        ;;
    *Haiku*)
        short_model="Haiku"
        MODEL_COLOR='\033[92m'   # 明るい緑
        ;;
    *)
        short_model="$model"
        MODEL_COLOR='\033[97m'   # 明るい白
        ;;
esac

# Git ブランチ・ステータス取得
branch=""
git_uncommitted=""
git_unpushed=""
if git rev-parse --is-inside-work-tree &>/dev/null; then
    branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)

    # 未コミットファイル数（変更+追加+削除）
    uncommitted_count=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
    if [ "$uncommitted_count" -gt 0 ]; then
        git_uncommitted="●${uncommitted_count}"
    fi

    # 未プッシュコミット数
    ahead=$(git rev-list --count '@{upstream}..HEAD' 2>/dev/null || echo "0")
    if [ "$ahead" -gt 0 ]; then
        git_unpushed="↑${ahead}"
    fi
fi

# 現在日時
day_of_week=$(date +"%a")  # Mon, Tue, ...
current_date=$(date +"%m/%d")
current_time=$(date +"%H:%M")

# 曜日カラー（平日=白、土=青、日=赤）
day_num=$(date +"%u")  # 1=Mon, 7=Sun
case "$day_num" in
    6) DAY_COLOR='\033[94m' ;;   # 土曜: 青
    7) DAY_COLOR='\033[91m' ;;   # 日曜: 赤
    *) DAY_COLOR='\033[97m' ;;   # 平日: 白
esac

# カラー定義（グラデーション用）
RESET='\033[0m'
DIM='\033[2m'
BOLD='\033[1m'

# グラデーションカラー（左から右へ明るく）
COLOR_2='\033[36m'    # シアン（ディレクトリ）
COLOR_3='\033[35m'    # マゼンタ（ブランチ）
COLOR_4='\033[33m'    # イエロー（行数変更）
COLOR_5='\033[92m'    # 明るい緑（コスト - 重要）

# ステータス用カラー
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'

# Nerd Font アイコン
ICON_FOLDER=$(printf '\xef\x81\xbb')       # U+F07B
ICON_BRANCH=$(printf '\xee\x9c\xa5')       # U+E725
ICON_MODEL=$(printf '\xf3\xb1\x8c\xbc')    # U+F133C
ICON_BRAIN=$(printf '\xef\x97\x9c')        # U+F5DC
ICON_DIFF=$(printf '\xef\x81\x80')         # U+F040
ICON_MONEY=$(printf '\xef\x85\x95')        # U+F155
ICON_TIME=$(printf '\xef\x80\x97')         # U+F017

# セパレータ
SEP='┃'

# コンテキスト使用率に応じた色
if [ "$used_pct" -lt 50 ]; then
    PCT_COLOR=$GREEN
elif [ "$used_pct" -lt 75 ]; then
    PCT_COLOR=$YELLOW
else
    PCT_COLOR=$RED
fi

# プログレスバー生成（5ブロック）
bar_width=5
filled=$((used_pct * bar_width / 100))
empty=$((bar_width - filled))
bar=""
for ((i=0; i<filled; i++)); do bar+="▰"; done
for ((i=0; i<empty; i++)); do bar+="▱"; done

# コストフォーマット
cost_fmt=$(printf "%.2f" "$cost")

# 出力構築（グラデーション効果）
output=""

# 左セクション（曜日+日付+時刻）
output+="${DAY_COLOR}${BOLD}${day_of_week}${RESET} ${ICON_TIME} ${current_date} ${BOLD}\033[97m${current_time}${RESET}"
output+="  "
output+="${COLOR_2}${ICON_FOLDER} ${dir}${RESET}"
if [ -n "$branch" ]; then
    output+="  "
    output+="${COLOR_3}${ICON_BRANCH} ${branch}${RESET}"
    # Git状態インジケータ（●N = 未コミットN件、↑N = 未プッシュN件）
    if [ -n "$git_uncommitted" ]; then
        output+=" ${YELLOW}${git_uncommitted}${RESET}"
    fi
    if [ -n "$git_unpushed" ]; then
        output+=" ${YELLOW}${git_unpushed}${RESET}"
    fi
fi

# セパレータ
output+=" ${DIM}${SEP}${RESET} "

# 右セクション（重要情報 - 鮮やか）
output+="${MODEL_COLOR}${BOLD}${ICON_MODEL} ${short_model}${RESET}"
output+="  "
output+="${PCT_COLOR}${ICON_BRAIN} ${bar} ${used_pct}%${RESET}"
output+="  "
output+="${COLOR_4}${ICON_DIFF}${RESET} ${GREEN}+${lines_added}${RESET}${RED}-${lines_removed}${RESET}"
output+="  "
output+="${COLOR_5}${BOLD}${ICON_MONEY}\$${cost_fmt}${RESET}"

# セッションID（あれば - 控えめ）
if [ -n "$session_id" ]; then
    output+=" ${DIM}#${session_id}${RESET}"
fi

echo -e "$output"
