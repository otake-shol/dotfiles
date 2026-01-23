#!/bin/bash
# ========================================
# zsh-benchmark.sh - zsh起動時間計測
# ========================================
# 使用方法: bash scripts/utils/zsh-benchmark.sh [回数]

set -e

ITERATIONS="${1:-10}"

# 色定義
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'
BOLD='\033[1m'

echo -e "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}${CYAN} zsh 起動時間ベンチマーク${NC}"
echo -e "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# 通常起動の計測
echo -e "${YELLOW}▸ 通常モード（$ITERATIONS回計測）${NC}"
total=0
for i in $(seq 1 $ITERATIONS); do
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

# minimalモード計測
echo -e "${YELLOW}▸ Minimalモード（$ITERATIONS回計測）${NC}"
total_minimal=0
for i in $(seq 1 $ITERATIONS); do
    time=$( { DOTFILES_PROFILE=minimal /usr/bin/time -p zsh -i -c exit; } 2>&1 | grep real | awk '{print $2}' )
    total_minimal=$(echo "$total_minimal + $time" | bc)
    printf "  実行 %2d: %.3fs\n" "$i" "$time"
done
avg_minimal=$(echo "scale=3; $total_minimal / $ITERATIONS" | bc)
echo -e "  ${GREEN}平均: ${avg_minimal}s${NC}"
echo ""

# 結果サマリー
echo -e "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD} 結果サマリー${NC}"
echo -e "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "  通常モード平均:   ${GREEN}${avg}s${NC}"
echo -e "  Minimalモード平均: ${GREEN}${avg_minimal}s${NC}"

# 目標値との比較
if (( $(echo "$avg < 0.5" | bc -l) )); then
    echo -e "  ${GREEN}✓ 起動時間は良好です（0.5秒未満）${NC}"
elif (( $(echo "$avg < 1.0" | bc -l) )); then
    echo -e "  ${YELLOW}⚠ 起動時間はやや遅め（0.5〜1秒）${NC}"
else
    echo -e "  ${YELLOW}⚠ 起動時間が遅いです（1秒以上）${NC}"
    echo -e "  ${CYAN}ヒント: 'DOTFILES_PROFILE=minimal' を使用するか、プラグインを見直してください${NC}"
fi
echo ""

# 詳細プロファイリングの案内
echo -e "${BOLD}詳細なプロファイリング:${NC}"
echo "  zsh -i -c 'zprof' を実行（zshrcに 'zmodload zsh/zprof' を追加）"
echo ""
