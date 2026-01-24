#!/bin/bash
# ========================================
# zsh-benchmark.sh - zsh起動時間計測
# ========================================
# 使用方法: bash scripts/utils/zsh-benchmark.sh [回数]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 共通ライブラリ読み込み
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"

ITERATIONS="${1:-10}"

echo -e "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}${CYAN} zsh 起動時間ベンチマーク${NC}"
echo -e "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# 起動時間の計測
echo -e "${YELLOW}▸ 起動時間計測（$ITERATIONS回）${NC}"
total=0
for i in $(seq 1 "$ITERATIONS"); do
    time=$( { time zsh -i -c exit; } 2>&1 | grep real | awk '{print $2}' | sed 's/[^0-9.]//g' )
    # macOSのtimeコマンド形式に対応
    if [[ -z "$time" ]]; then
        time=$( { /usr/bin/time -p zsh -i -c exit; } 2>&1 | grep real | awk '{print $2}' )
    fi
    total=$(echo "$total + $time" | bc)
    printf "  実行 %2d: %.3fs\n" "$i" "$time"
done
avg=$(echo "scale=3; $total / $ITERATIONS" | bc)
echo -e "  ${GREEN}平均: ${avg}s${NC}"
echo ""

# 結果サマリー
echo -e "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD} 結果サマリー${NC}"
echo -e "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "  平均起動時間: ${GREEN}${avg}s${NC}"

# 目標値との比較
if (( $(echo "$avg < 0.5" | bc -l) )); then
    echo -e "  ${GREEN}✓ 起動時間は良好です（0.5秒未満）${NC}"
elif (( $(echo "$avg < 1.0" | bc -l) )); then
    echo -e "  ${YELLOW}⚠ 起動時間はやや遅め（0.5〜1秒）${NC}"
else
    echo -e "  ${YELLOW}⚠ 起動時間が遅いです（1秒以上）${NC}"
    echo -e "  ${CYAN}ヒント: プラグインを見直してください${NC}"
fi
echo ""

# 詳細プロファイリングの案内
echo -e "${BOLD}詳細なプロファイリング:${NC}"
echo "  zsh -i -c 'zprof' を実行（zshrcに 'zmodload zsh/zprof' を追加）"
echo ""

# プロファイリングオプション
if [[ "${2:-}" == "--profile" ]]; then
    echo -e "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD} 詳細プロファイリング（上位10項目）${NC}"
    echo -e "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    # 一時的なzshrcを作成してzprofを有効化
    TEMP_ZSHRC=$(mktemp)
    echo "zmodload zsh/zprof" > "$TEMP_ZSHRC"
    cat ~/.zshrc >> "$TEMP_ZSHRC"
    echo "zprof | head -20" >> "$TEMP_ZSHRC"

    ZDOTDIR=$(dirname "$TEMP_ZSHRC") zsh -c "source $TEMP_ZSHRC"
    rm "$TEMP_ZSHRC"
fi

# 起動時間の内訳を表示するオプション
if [[ "${2:-}" == "--breakdown" ]]; then
    echo -e "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD} 起動時間内訳${NC}"
    echo -e "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    # 各設定ファイルの読み込み時間を計測
    echo -e "${YELLOW}▸ .zshrc のみ${NC}"
    /usr/bin/time -p zsh --no-rcs -c 'source ~/.zshrc; exit' 2>&1 | grep real

    echo -e "${YELLOW}▸ oh-my-zsh${NC}"
    # shellcheck disable=SC2016
    /usr/bin/time -p zsh -c 'export ZSH="$HOME/.oh-my-zsh"; source $ZSH/oh-my-zsh.sh; exit' 2>&1 | grep real

    echo -e "${YELLOW}▸ .aliases${NC}"
    /usr/bin/time -p zsh --no-rcs -c '[[ -f ~/.aliases ]] && source ~/.aliases; exit' 2>&1 | grep real
fi

echo -e "${BOLD}オプション:${NC}"
echo "  --profile    zprofによる詳細プロファイリング"
echo "  --breakdown  起動時間の内訳表示"
echo ""
