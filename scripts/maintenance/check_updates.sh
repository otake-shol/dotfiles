#!/bin/bash
# check_updates.sh - dotfilesとBrewの更新状況を確認（読み取り専用）
# 使用方法: bash scripts/maintenance/check_updates.sh
# エイリアス: dotup
#
# 役割分担:
#   check_updates.sh (dotup)   - 更新があるか確認するのみ（変更なし）
#   update_all.sh (dotupdate)  - 実際に更新を実行する

set -euo pipefail

# ヘルプ表示
show_help() {
    cat << 'EOF'
check_updates.sh - dotfilesとBrewの更新状況を確認（読み取り専用）

使用方法:
    bash scripts/maintenance/check_updates.sh
    dotup  # エイリアス

オプション:
    -h, --help    このヘルプを表示

説明:
    このスクリプトは更新の確認のみを行い、実際の更新は行いません。
    更新を実行するには update_all.sh (dotupdate) を使用してください。
EOF
}

[[ "${1:-}" == "-h" || "${1:-}" == "--help" ]] && show_help && exit 0

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 共通ライブラリ読み込み
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  更新チェック${NC}"
echo -e "${BLUE}========================================${NC}"

# ========================================
# dotfilesの更新確認
# ========================================
echo -e "\n${YELLOW}[1/2] dotfilesの更新確認...${NC}"

cd ~/dotfiles 2>/dev/null || {
    echo -e "${YELLOW}⚠ ~/dotfiles が見つかりません${NC}"
    exit 1
}

# リモートの最新情報を取得
git fetch origin --quiet 2>/dev/null

# デフォルトブランチを動的に取得 (main/master 両対応)
DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
DEFAULT_BRANCH=${DEFAULT_BRANCH:-main}

LOCAL=$(git rev-parse HEAD 2>/dev/null)
REMOTE=$(git rev-parse "origin/${DEFAULT_BRANCH}" 2>/dev/null)

if [ -z "$REMOTE" ]; then
    echo -e "${YELLOW}⚠ リモートリポジトリに接続できません${NC}"
elif [ "$LOCAL" != "$REMOTE" ]; then
    BEHIND=$(git rev-list --count "HEAD..origin/${DEFAULT_BRANCH}" 2>/dev/null)
    echo -e "${YELLOW}⚠ dotfilesに ${BEHIND} 件の更新があります${NC}"
    echo -e "   更新: cd ~/dotfiles && git pull"
else
    echo -e "${GREEN}✓ dotfilesは最新です${NC}"
fi

# ローカルの未コミット変更確認
if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
    echo -e "${YELLOW}⚠ 未コミットの変更があります${NC}"
    echo -e "   確認: cd ~/dotfiles && git status"
fi

# ========================================
# Homebrewの更新確認
# ========================================
echo -e "\n${YELLOW}[2/2] Homebrewの更新確認...${NC}"

if ! command -v brew &> /dev/null; then
    echo -e "${YELLOW}⚠ Homebrewがインストールされていません${NC}"
else
    # 更新情報を取得（静かに）
    brew update --quiet 2>/dev/null

    # 更新可能なパッケージ数を取得
    OUTDATED=$(brew outdated --quiet 2>/dev/null)
    OUTDATED_COUNT=$(echo "$OUTDATED" | grep -c '^' 2>/dev/null || echo "0")

    if [ "$OUTDATED_COUNT" -gt 0 ] && [ -n "$OUTDATED" ]; then
        echo -e "${YELLOW}⚠ ${OUTDATED_COUNT} 個のパッケージが更新可能です${NC}"
        echo -e "   一覧: brew outdated"
        echo -e "   更新: brew upgrade"
    else
        echo -e "${GREEN}✓ Homebrewパッケージは最新です${NC}"
    fi
fi

# ========================================
# 完了
# ========================================
echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}  チェック完了${NC}"
echo -e "${GREEN}========================================${NC}"
