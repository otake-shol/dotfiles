#!/bin/bash
# shellcheck disable=SC2154  # eval経由で代入される変数群
# Claude Code statusline - グラデーション＋アクセントスタイル

input=$(cat)

# 値の一括取得（jq 1回で全抽出）
eval "$(echo "$input" | jq -r '
  @sh "dir_full=\(.workspace.current_dir // "~")",
  @sh "model=\(.model.display_name // "Claude")",
  @sh "used_pct=\(.context_window.used_percentage // 0 | floor)",
  @sh "ctx_size=\(.context_window.context_window_size // 200000)",
  @sh "cost=\(.cost.total_cost_usd // 0)",
  @sh "duration_ms=\(.cost.total_duration_ms // 0)",
  @sh "api_duration_ms=\(.cost.total_api_duration_ms // 0)",
  @sh "session_id=\(.session_id // "")",
  @sh "session_name=\(.session_name // "")",
  @sh "lines_added=\(.cost.total_lines_added // 0)",
  @sh "lines_removed=\(.cost.total_lines_removed // 0)",
  @sh "usage_5h=\(.rate_limits.five_hour.used_percentage // "")",
  @sh "usage_7d=\(.rate_limits.seven_day.used_percentage // "")",
  @sh "resets_5h=\(.rate_limits.five_hour.resets_at // "")",
  @sh "resets_7d=\(.rate_limits.seven_day.resets_at // "")",
  @sh "worktree_branch=\(.worktree.branch // "")",
  @sh "worktree_name=\(.worktree.name // "")"
')"

dir=$(echo "$dir_full" | sed "s|^$HOME|~|")

# コンテキストウィンドウサイズを人間が読める形式に変換（200000→200K, 1000000→1M）
if [ "$ctx_size" -ge 1000000 ]; then
    ctx_label="$((ctx_size / 1000000))M"
else
    ctx_label="$((ctx_size / 1000))K"
fi

# モデル名とカラー設定（バージョン番号付き）
version=$(echo "$model" | grep -oE '[0-9]+\.[0-9]+' | head -1)
case "$model" in
    *Opus*)
        short_model="Opus${version:+ $version}"
        MODEL_COLOR='\033[38;5;208m'   # オレンジ（プレミアム感）
        ;;
    *Sonnet*)
        short_model="Sonnet${version:+ $version}"
        MODEL_COLOR='\033[94m'   # 明るい青
        ;;
    *Haiku*)
        short_model="Haiku${version:+ $version}"
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
day_of_week=$(LC_TIME=en_US.UTF-8 date +"%a")  # Mon, Tue, ...
current_date=$(date +"%m/%d")
current_time=$(date +"%H:%M")

# バッテリー残量（Mac専用）
battery_pct=$(pmset -g batt 2>/dev/null | grep -o '[0-9]*%' | tr -d '%')
battery_charging=$(pmset -g batt 2>/dev/null | grep -q 'AC Power' && echo "1" || echo "0")

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
ICON_BRAIN=$(printf '\xef\x8b\x9b')        # U+F2DB (microchip)
ICON_DIFF=$(printf '\xef\x81\x80')         # U+F040
ICON_MONEY=$(printf '\xef\x83\x96')        # U+F0D6 (money/banknote)
ICON_TIME=$(printf '\xef\x80\x97')         # U+F017
ICON_BATTERY=$(printf '\xef\x89\x80')      # U+F240 (battery full)
ICON_CHARGING=$(printf '\xef\x83\xa7')     # U+F0E7 (lightning bolt)
ICON_GAUGE=$(printf '\xef\x83\xa4')        # U+F0E4 (dashboard)
ICON_WORKTREE=$(printf '\xef\x84\xa6')     # U+F126 (code-fork)

# セパレータ
SEP='┃'

# コンテキスト使用率に応じた色と強調
BLINK='\033[5m'
if [ "$used_pct" -lt 50 ]; then
    PCT_COLOR=$GREEN
    PCT_STYLE=""
elif [ "$used_pct" -lt 75 ]; then
    PCT_COLOR=$YELLOW
    PCT_STYLE=""
elif [ "$used_pct" -lt 90 ]; then
    PCT_COLOR=$RED
    PCT_STYLE="${BOLD}"
else
    # 90%以上: 点滅+太字で警告
    PCT_COLOR=$RED
    PCT_STYLE="${BLINK}${BOLD}"
fi

# プログレスバー生成（5ブロック）
_bar() {
    local pct=$1 width=5
    local filled=$((pct * width / 100))
    local empty=$((width - filled))
    local b=""
    for ((i=0; i<filled; i++)); do b+="▰"; done
    for ((i=0; i<empty; i++)); do b+="▱"; done
    echo -n "$b"
}

bar=$(_bar "$used_pct")

# コストフォーマット
cost_fmt=$(printf "%.2f" "$cost")

# ヘルパー関数（Usage表示用）
_usage_color() {
    local pct=$1
    if [ "$pct" -lt 50 ]; then echo -n "$GREEN"
    elif [ "$pct" -lt 75 ]; then echo -n "$YELLOW"
    elif [ "$pct" -lt 90 ]; then echo -n "${BOLD}${RED}"
    else echo -n "${BLINK}${BOLD}${RED}"
    fi
}

_format_reset_time() {
    local reset_ts=$1
    if [ -z "$reset_ts" ]; then return; fi
    date -r "$reset_ts" +"~%-m/%-d %H:%M"
}

# === 1行目: 日時・ディレクトリ・Git・モデル・バッテリー ===
output=""

output+="${ICON_TIME} ${DAY_COLOR}${BOLD}${day_of_week}${RESET} ${current_date} ${BOLD}\033[97m${current_time}${RESET}"
output+="  "
output+="${COLOR_2}${ICON_FOLDER} ${dir}${RESET}"
if [ -n "$branch" ]; then
    output+="  "
    output+="${COLOR_3}${ICON_BRANCH} ${branch}${RESET}"
    if [ -n "$git_uncommitted" ]; then
        output+=" ${YELLOW}${git_uncommitted}${RESET}"
    fi
    if [ -n "$git_unpushed" ]; then
        output+=" ${YELLOW}${git_unpushed}${RESET}"
    fi
fi

# worktree表示
if [ -n "$worktree_branch" ]; then
    output+="  ${COLOR_3}${ICON_WORKTREE} ${worktree_branch}${RESET}"
elif [ -n "$worktree_name" ]; then
    output+="  ${COLOR_3}${ICON_WORKTREE} ${worktree_name}${RESET}"
fi

output+=" ${DIM}${SEP}${RESET} "

output+="${MODEL_COLOR}${BOLD}${ICON_MODEL} ${short_model}${RESET}"

# バッテリー表示
if [ -n "$battery_pct" ]; then
    if [ "$battery_pct" -gt 50 ]; then
        BATT_COLOR=$GREEN
    elif [ "$battery_pct" -gt 20 ]; then
        BATT_COLOR=$YELLOW
    else
        BATT_COLOR=$RED
    fi
    output+="  "
    if [ "$battery_charging" = "1" ]; then
        output+="${BATT_COLOR}${ICON_CHARGING}${battery_pct}%${RESET}"
    else
        output+="${BATT_COLOR}${ICON_BATTERY}${battery_pct}%${RESET}"
    fi
fi

echo -e "$output"

# === 2行目: Usage（レートリミット） + コンテキスト使用率 ===
line2=""

if [ -n "$usage_5h" ] || [ -n "$usage_7d" ]; then
    line2+="${DIM}${ICON_GAUGE}${RESET} "
    if [ -n "$usage_5h" ]; then
        pct_5h=$(printf '%.0f' "$usage_5h")
        u5_color=$(_usage_color "$pct_5h")
        u5_bar=$(_bar "$pct_5h")
        reset_label=""
        [ -n "$resets_5h" ] && reset_label=" $(_format_reset_time "$resets_5h")"
        line2+="${u5_color}5h ${u5_bar} ${pct_5h}%${RESET}${DIM}${reset_label}${RESET}"
    fi
    if [ -n "$usage_5h" ] && [ -n "$usage_7d" ]; then
        line2+="  "
    fi
    if [ -n "$usage_7d" ]; then
        pct_7d=$(printf '%.0f' "$usage_7d")
        u7_color=$(_usage_color "$pct_7d")
        u7_bar=$(_bar "$pct_7d")
        reset_label=""
        [ -n "$resets_7d" ] && reset_label=" $(_format_reset_time "$resets_7d")"
        line2+="${u7_color}7d ${u7_bar} ${pct_7d}%${RESET}${DIM}${reset_label}${RESET}"
    fi
    line2+="  "
fi

line2+="${PCT_STYLE}${PCT_COLOR}${ICON_BRAIN} ${bar} ${used_pct}%${RESET}${DIM}(${ctx_label})${RESET}"

echo -e "$line2"

# === 3行目: コスト・diff・セッション（常に表示） ===
line3="${COLOR_5}${ICON_MONEY}${RESET} "

if [ "$duration_ms" -gt 0 ]; then
    duration_sec=$((duration_ms / 1000))
    dur_h=$((duration_sec / 3600))
    dur_m=$(( (duration_sec % 3600) / 60 ))
    if [ "$dur_h" -gt 0 ]; then
        dur_label="${dur_h}h${dur_m}m"
    else
        dur_label="${dur_m}m"
    fi

    cost_per_hour=$(awk "BEGIN { printf \"%.2f\", $cost / ($duration_sec / 3600) }")
    cost_per_day=$(awk "BEGIN { printf \"%.2f\", $cost / ($duration_sec / 3600) * 24 }")

    line3+="${BOLD}\$${cost_fmt}${RESET}${DIM}/${dur_label}${RESET}"
    line3+="  ${DIM}≈${RESET} \$${cost_per_hour}${DIM}/h${RESET}"
    line3+="  ${DIM}≈${RESET} \$${cost_per_day}${DIM}/day${RESET}"

    # API待ち時間の割合
    if [ "$api_duration_ms" -gt 0 ]; then
        api_pct=$((api_duration_ms * 100 / duration_ms))
        line3+="  ${DIM}API:${api_pct}%${RESET}"
    fi
else
    line3+="${BOLD}\$${cost_fmt}${RESET}"
fi

line3+="  ${COLOR_4}${ICON_DIFF}${RESET} ${GREEN}+${lines_added}${RESET}${RED}-${lines_removed}${RESET}"

# セッション名 or セッションID
if [ -n "$session_name" ]; then
    line3+="  ${DIM}${session_name}${RESET}"
elif [ -n "$session_id" ]; then
    line3+="  ${DIM}#${session_id}${RESET}"
fi

echo -e "$line3"
