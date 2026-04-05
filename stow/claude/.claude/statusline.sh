#!/bin/bash
# Claude Code statusline - グラデーション＋アクセントスタイル

input=$(cat)

# 値の取得
dir_full=$(echo "$input" | jq -r '.workspace.current_dir // "~"')
dir=$(echo "$dir_full" | sed "s|^$HOME|~|")
model=$(echo "$input" | jq -r '.model.display_name // "Claude"')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
ctx_size=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')

# コンテキストウィンドウサイズを人間が読める形式に変換（200000→200K, 1000000→1M）
if [ "$ctx_size" -ge 1000000 ]; then
    ctx_label="$((ctx_size / 1000000))M"
else
    ctx_label="$((ctx_size / 1000))K"
fi
cost=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
duration_ms=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')
session_id=$(echo "$input" | jq -r '.session_id // ""')
lines_added=$(echo "$input" | jq -r '.cost.total_lines_added // 0')
lines_removed=$(echo "$input" | jq -r '.cost.total_lines_removed // 0')

# Usage（レートリミット）情報
usage_5h=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
usage_7d=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
resets_5h=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
resets_7d=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

# モデル名とカラー設定（バージョン番号付き）
# display_name例: "Opus 4.6", "Sonnet 4.5", "Haiku 4.5" など
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
output+="${ICON_TIME} ${DAY_COLOR}${BOLD}${day_of_week}${RESET} ${current_date} ${BOLD}\033[97m${current_time}${RESET}"
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
    # リセット日時を「M/D H:MM迄」形式で表示
    date -r "$reset_ts" +"~%-m/%-d %H:%M"
}

_usage_bar() {
    local pct=$1
    local width=5
    local filled=$((pct * width / 100))
    local empty=$((width - filled))
    local b=""
    for ((i=0; i<filled; i++)); do b+="▰"; done
    for ((i=0; i<empty; i++)); do b+="▱"; done
    echo -n "$b"
}

# 右セクション（重要情報 - 鮮やか）
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


# 1行目出力
echo -e "$output"

# 2行目: Usage（レートリミット） + コンテキスト使用率
line2=""

if [ -n "$usage_5h" ] || [ -n "$usage_7d" ]; then
    line2+="${DIM}${ICON_GAUGE}${RESET} "
    if [ -n "$usage_5h" ]; then
        pct_5h=$(printf '%.0f' "$usage_5h")
        u5_color=$(_usage_color "$pct_5h")
        u5_bar=$(_usage_bar "$pct_5h")
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
        u7_bar=$(_usage_bar "$pct_7d")
        reset_label=""
        [ -n "$resets_7d" ] && reset_label=" $(_format_reset_time "$resets_7d")"
        line2+="${u7_color}7d ${u7_bar} ${pct_7d}%${RESET}${DIM}${reset_label}${RESET}"
    fi
    line2+="  "
fi

line2+="${PCT_STYLE}${PCT_COLOR}${ICON_BRAIN} ${bar} ${used_pct}%${RESET}${DIM}(${ctx_label})${RESET}"

echo -e "$line2"

# 3行目: セッションコスト詳細（合計・時間単価・日単価）
if [ "$duration_ms" -gt 0 ]; then
    duration_sec=$((duration_ms / 1000))
    # 経過時間の表示（XhYm or Ym）
    dur_h=$((duration_sec / 3600))
    dur_m=$(( (duration_sec % 3600) / 60 ))
    if [ "$dur_h" -gt 0 ]; then
        dur_label="${dur_h}h${dur_m}m"
    else
        dur_label="${dur_m}m"
    fi

    # 時間あたり・日あたりコスト計算（awk で浮動小数点演算）
    cost_per_hour=$(awk "BEGIN { printf \"%.2f\", $cost / ($duration_sec / 3600) }")
    cost_per_day=$(awk "BEGIN { printf \"%.2f\", $cost / ($duration_sec / 3600) * 24 }")

    line3="${COLOR_5}${ICON_MONEY}${RESET} "
    line3+="${BOLD}\$${cost_fmt}${RESET}${DIM}/${dur_label}${RESET}"
    line3+="  ${DIM}≈${RESET} \$${cost_per_hour}${DIM}/h${RESET}"
    line3+="  ${DIM}≈${RESET} \$${cost_per_day}${DIM}/day${RESET}"
    line3+="  ${COLOR_4}${ICON_DIFF}${RESET} ${GREEN}+${lines_added}${RESET}${RED}-${lines_removed}${RESET}"
    if [ -n "$session_id" ]; then
        line3+="  ${DIM}#${session_id}${RESET}"
    fi
    echo -e "$line3"
fi
