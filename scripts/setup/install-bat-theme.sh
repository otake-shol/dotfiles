#!/bin/bash
# ========================================
# install-bat-theme.sh - batのTokyoNightテーマインストール
# ========================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 共通ライブラリ読み込み
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"

BAT_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/bat"
THEMES_DIR="$BAT_CONFIG_DIR/themes"

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN} bat TokyoNight テーマインストール${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# テーマディレクトリ作成
mkdir -p "$THEMES_DIR"

# TokyoNight テーマファイルのURL
THEME_URL="https://raw.githubusercontent.com/folke/tokyonight.nvim/main/extras/sublime/tokyonight_night.tmTheme"

echo -e "${YELLOW}▸ TokyoNight Night テーマをダウンロード中...${NC}"

# ダウンロード
if curl -fsSL "$THEME_URL" -o "$THEMES_DIR/tokyonight_night.tmTheme"; then
    echo -e "${GREEN}✓ テーマファイルを保存しました${NC}"
else
    echo -e "${YELLOW}⚠ ダウンロードに失敗しました。代替テーマ(OneHalfDark)を使用します${NC}"
    # bat built-in テーマにフォールバック
    exit 0
fi

# batキャッシュを再構築
echo -e "${YELLOW}▸ batキャッシュを再構築中...${NC}"
if command -v bat &>/dev/null; then
    bat cache --build
    echo -e "${GREEN}✓ キャッシュを再構築しました${NC}"
else
    echo -e "${YELLOW}⚠ batがインストールされていません${NC}"
fi

echo ""
echo -e "${GREEN}✓ インストール完了${NC}"
echo ""
echo "テーマを確認するには:"
echo "  bat --list-themes | grep tokyo"
echo ""
