#!/bin/bash
# ========================================
# zsh_benchmark.sh - zsh起動時間計測
# ========================================
# 使用方法: bash scripts/utils/zsh_benchmark.sh [回数]
#
# ■ パフォーマンス目標値
#   - 理想:   < 0.1s (100ms) ... 体感でほぼ即時
#   - 良好:   < 0.3s (300ms) ... 快適に使用可能
#   - 許容:   < 0.5s (500ms) ... 実用上問題なし
#   - 要改善: >= 0.5s        ... 遅延を感じる
#
# ■ 最適化のポイント
#   - 遅延読み込み（lazy.zsh）を活用
#   - 不要なプラグインを無効化
#   - compinit のキャッシュを活用

set -euo pipefail

# 目標値の定義（秒）
TARGET_IDEAL=0.1
TARGET_GOOD=0.3
TARGET_ACCEPTABLE=0.5

# 一時ファイルのクリーンアップ用trap
TEMP_ZSHRC=""
trap 'rm -f "$TEMP_ZSHRC" 2>/dev/null' EXIT INT TERM

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
echo -e "${YELLOW}▸ 起動時間計測（${ITERATIONS}回）${NC}"
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
echo ""
echo -e "${BOLD} 目標値との比較:${NC}"
echo -e "  理想 (< ${TARGET_IDEAL}s): $(if (( $(echo "$avg < $TARGET_IDEAL" | bc -l) )); then echo -e "${GREEN}達成${NC}"; else echo -e "${DIM}未達${NC}"; fi)"
echo -e "  良好 (< ${TARGET_GOOD}s): $(if (( $(echo "$avg < $TARGET_GOOD" | bc -l) )); then echo -e "${GREEN}達成${NC}"; else echo -e "${DIM}未達${NC}"; fi)"
echo -e "  許容 (< ${TARGET_ACCEPTABLE}s): $(if (( $(echo "$avg < $TARGET_ACCEPTABLE" | bc -l) )); then echo -e "${GREEN}達成${NC}"; else echo -e "${DIM}未達${NC}"; fi)"
echo ""

if (( $(echo "$avg < $TARGET_IDEAL" | bc -l) )); then
    echo -e "  ${GREEN}★ 素晴らしい！理想的な起動時間です${NC}"
elif (( $(echo "$avg < $TARGET_GOOD" | bc -l) )); then
    echo -e "  ${GREEN}✓ 良好な起動時間です${NC}"
elif (( $(echo "$avg < $TARGET_ACCEPTABLE" | bc -l) )); then
    echo -e "  ${YELLOW}○ 許容範囲内です${NC}"
else
    echo -e "  ${RED}✗ 起動時間が遅いです（${TARGET_ACCEPTABLE}秒以上）${NC}"
    echo -e "  ${CYAN}ヒント: --profile オプションで詳細を確認してください${NC}"
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
