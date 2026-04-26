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
  @sh "session_id=\(.session_id // "")",
  @sh "session_name=\(.session_name // "")",
  @sh "lines_added=\(.cost.total_lines_added // 0)",
  @sh "lines_removed=\(.cost.total_lines_removed // 0)",
  @sh "usage_5h=\(.rate_limits.five_hour.used_percentage // "")",
  @sh "usage_7d=\(.rate_limits.seven_day.used_percentage // "")",
  @sh "resets_5h=\(.rate_limits.five_hour.resets_at // "")",
  @sh "resets_7d=\(.rate_limits.seven_day.resets_at // "")",
  @sh "worktree_branch=\(.worktree.branch // "")",
  @sh "worktree_name=\(.worktree.name // "")",
  @sh "cache_read=\(.context_window.current_usage.cache_read_input_tokens // 0)",
  @sh "input_tokens=\(.context_window.current_usage.input_tokens // 0)",
  @sh "cache_creation=\(.context_window.current_usage.cache_creation_input_tokens // 0)",
  @sh "exceeds_200k=\(.exceeds_200k_tokens // false)",
  @sh "total_in_tok=\(.context_window.total_input_tokens // 0)",
  @sh "total_out_tok=\(.context_window.total_output_tokens // 0)"
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

# 現在日時（1回のdate呼び出しで全取得）
IFS='|' read -r day_of_week current_date current_time day_num \
  <<< "$(LC_TIME=en_US.UTF-8 date +"%a|%m/%d|%H:%M|%u")"

# バッテリー残量（Mac専用・1回のpmset呼び出し）
_batt=$(pmset -g batt 2>/dev/null)
battery_pct=$(echo "$_batt" | grep -o '[0-9]*%' | tr -d '%')
battery_charging=$(echo "$_batt" | grep -q 'AC Power' && echo "1" || echo "0")

# 曜日カラー（平日=白、土=青、日=赤）
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
ICON_BATT_FULL=$(printf '\xf3\xb0\x81\xb9')    # U+F0079 (battery-full)
ICON_BATT_MED=$(printf '\xf3\xb0\x82\x81')     # U+F0081 (battery-medium)
ICON_BATT_LOW=$(printf '\xf3\xb0\x81\xbe')     # U+F007E (battery-low)
ICON_BATT_OUT=$(printf '\xf3\xb0\x81\xbb')     # U+F007B (battery-outline)
ICON_BATT_ALERT=$(printf '\xf3\xb0\x82\x8e')   # U+F008E (battery-alert)
ICON_CHARGING=$(printf '\xef\x83\xa7')          # U+F0E7 (lightning bolt)
ICON_CACHE=$(printf '\xf3\xb0\xa8\xb6')        # U+F0A36 (cached)
ICON_TOKEN=$(printf '\xf3\xb0\xb2\xa3')        # U+F0CA3 (sigma)
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

# プログレスバー生成（8ブロック・printf -vでサブシェル回避）
_bar() {
    local pct=$1 __var=$2 width=8
    local filled=$((pct * width / 100))
    local b=""
    for ((i=0; i<filled; i++)); do b+="▰"; done
    for ((i=filled; i<width; i++)); do b+="▱"; done
    printf -v "$__var" '%s' "$b"
}

_bar "$used_pct" bar

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

_format_relative_reset() {
    local reset_ts=$1
    [ -z "$reset_ts" ] && return
    local now diff days hours mins
    now=$(date +%s)
    diff=$((reset_ts - now))
    if [ "$diff" -le 0 ]; then
        echo -n "now"
        return
    fi
    days=$((diff / 86400))
    hours=$(( (diff % 86400) / 3600 ))
    mins=$(( (diff % 3600) / 60 ))
    if [ "$days" -gt 0 ]; then
        if [ "$hours" -gt 0 ]; then
            echo -n "あと${days}d${hours}h"
        else
            echo -n "あと${days}d"
        fi
    elif [ "$hours" -gt 0 ]; then
        if [ "$mins" -gt 0 ]; then
            echo -n "あと${hours}h${mins}m"
        else
            echo -n "あと${hours}h"
        fi
    else
        echo -n "あと${mins}m"
    fi
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

# バッテリー表示（段階アイコン）
if [ -n "$battery_pct" ]; then
    if [ "$battery_pct" -gt 75 ]; then
        BATT_COLOR=$GREEN; BATT_ICON=$ICON_BATT_FULL
    elif [ "$battery_pct" -gt 50 ]; then
        BATT_COLOR=$GREEN; BATT_ICON=$ICON_BATT_MED
    elif [ "$battery_pct" -gt 25 ]; then
        BATT_COLOR=$YELLOW; BATT_ICON=$ICON_BATT_LOW
    elif [ "$battery_pct" -gt 10 ]; then
        BATT_COLOR=$RED; BATT_ICON=$ICON_BATT_OUT
    else
        BATT_COLOR=$RED; BATT_ICON=$ICON_BATT_ALERT
    fi
    output+="  "
    if [ "$battery_charging" = "1" ]; then
        output+="${BATT_COLOR}${ICON_CHARGING}${battery_pct}%${RESET}"
    else
        output+="${BATT_COLOR}${BATT_ICON}${battery_pct}%${RESET}"
    fi
fi

echo -e "$output"

# === 2行目: Usage（レートリミット） + コンテキスト使用率 ===
line2=""

if [ -n "$usage_5h" ] || [ -n "$usage_7d" ]; then
    line2+="${DIM}${ICON_GAUGE}${RESET} "
    if [ -n "$usage_5h" ]; then
        pct_5h=$(printf '%.0f' "$usage_5h")
        rem_5h=$((100 - pct_5h))
        u5_color=$(_usage_color "$pct_5h")
        _bar "$pct_5h" u5_bar
        reset_label=""
        [ -n "$resets_5h" ] && reset_label="・$(_format_relative_reset "$resets_5h")"
        line2+="${u5_color}5h ${u5_bar} ${pct_5h}%${RESET}${DIM}（残${rem_5h}%${reset_label}）${RESET}"
    fi
    if [ -n "$usage_5h" ] && [ -n "$usage_7d" ]; then
        line2+="  "
    fi
    if [ -n "$usage_7d" ]; then
        pct_7d=$(printf '%.0f' "$usage_7d")
        rem_7d=$((100 - pct_7d))
        u7_color=$(_usage_color "$pct_7d")
        _bar "$pct_7d" u7_bar
        reset_label=""
        [ -n "$resets_7d" ] && reset_label="・$(_format_relative_reset "$resets_7d")"
        line2+="${u7_color}7d ${u7_bar} ${pct_7d}%${RESET}${DIM}（残${rem_7d}%${reset_label}）${RESET}"
    fi
    line2+="  "
fi

line2+="${PCT_STYLE}${PCT_COLOR}${ICON_BRAIN} ${bar} ${used_pct}%${RESET}${DIM}(${ctx_label})${RESET}"

# 200Kトークン超過警告
if [ "$exceeds_200k" = "true" ]; then
    line2+="  ${BLINK}${BOLD}${RED}⚠ >200K${RESET}"
fi

# キャッシュヒット率
total_input=$((input_tokens + cache_read + cache_creation))
if [ "$total_input" -gt 0 ]; then
    cache_pct=$((cache_read * 100 / total_input))
    if [ "$cache_pct" -gt 60 ]; then
        CACHE_COLOR=$GREEN
    elif [ "$cache_pct" -gt 30 ]; then
        CACHE_COLOR=$YELLOW
    else
        CACHE_COLOR=$RED
    fi
    line2+="  ${CACHE_COLOR}${ICON_CACHE}${cache_pct}%${RESET}"
fi

# 累積トークン
total_tok=$((total_in_tok + total_out_tok))
if [ "$total_tok" -gt 0 ]; then
    if [ "$total_tok" -ge 1000000 ]; then
        tok_label="$((total_tok / 1000000)).$(( (total_tok % 1000000) / 100000 ))M"
    else
        tok_label="$((total_tok / 1000))K"
    fi
    line2+="  ${DIM}${ICON_TOKEN}${tok_label}${RESET}"
fi

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
    read -r cost_per_hour cost_per_day <<< \
      "$(awk "BEGIN { h=$cost/($duration_sec/3600); printf \"%.2f %.2f\", h, h*8 }")"
    line3+="${BOLD}\$${cost_fmt}${RESET}${DIM}/${dur_label}${RESET}"
    line3+="  ${DIM}≈${RESET} \$${cost_per_hour}${DIM}/h${RESET}"
    line3+="  ${DIM}≈${RESET} \$${cost_per_day}${DIM}/8h${RESET}"
else
    line3+="${BOLD}\$${cost_fmt}${RESET}"
fi

# diff（ネット表示付き）
net_diff=$((lines_added - lines_removed))
if [ "$net_diff" -ge 0 ]; then
    net_label="${GREEN}+${net_diff}${RESET}"
else
    net_label="${RED}${net_diff}${RESET}"
fi
line3+="  ${COLOR_4}${ICON_DIFF}${RESET} ${GREEN}+${lines_added}${RESET} ${RED}-${lines_removed}${RESET} ${DIM}(net ${RESET}${net_label}${DIM})${RESET}"

# セッション名 or セッションID
if [ -n "$session_name" ]; then
    line3+="  ${DIM}${session_name}${RESET}"
elif [ -n "$session_id" ]; then
    line3+="  ${DIM}#${session_id}${RESET}"
fi

echo -e "$line3"
