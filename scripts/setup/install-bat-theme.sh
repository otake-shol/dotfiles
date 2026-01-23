#!/bin/bash
# ========================================
# install-bat-theme.sh - batのTokyoNightテーマインストール
# ========================================

set -e

BAT_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/bat"
THEMES_DIR="$BAT_CONFIG_DIR/themes"

# 色定義
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

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
