#!/bin/bash
# sync-brewfile.sh - Brewfileとインストール済みパッケージの差分を検出
# 使用方法: bash scripts/sync-brewfile.sh

# カラー出力
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

BREWFILE="$HOME/dotfiles/Brewfile"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Brewfile 同期チェック${NC}"
echo -e "${BLUE}========================================${NC}"

if [ ! -f "$BREWFILE" ]; then
    echo -e "${YELLOW}⚠ Brewfileが見つかりません: $BREWFILE${NC}"
    exit 1
fi

# ========================================
# Brewfileに含まれていないパッケージ
# ========================================
echo -e "\n${YELLOW}[1/3] Brewfileに含まれていないパッケージ...${NC}"

MISSING_FROM_BREWFILE=()
while IFS= read -r pkg; do
    if ! grep -q "brew \"$pkg\"" "$BREWFILE" 2>/dev/null; then
        MISSING_FROM_BREWFILE+=("$pkg")
    fi
done < <(brew leaves 2>/dev/null)

if [ ${#MISSING_FROM_BREWFILE[@]} -eq 0 ]; then
    echo -e "${GREEN}✓ すべてのパッケージがBrewfileに含まれています${NC}"
else
    echo -e "${YELLOW}⚠ 以下のパッケージがBrewfileにありません:${NC}"
    for pkg in "${MISSING_FROM_BREWFILE[@]}"; do
        echo -e "   brew \"$pkg\""
    done
    echo -e "\n   ${BLUE}追加コマンド:${NC}"
    echo -e "   echo 'brew \"パッケージ名\"' >> $BREWFILE"
fi

# ========================================
# インストールされていないBrewfileのパッケージ
# ========================================
echo -e "\n${YELLOW}[2/3] インストールされていないBrewfileのパッケージ...${NC}"

INSTALLED=$(brew list --formula 2>/dev/null)
NOT_INSTALLED=()

while IFS= read -r line; do
    # brew "package" 形式の行を抽出
    if [[ $line =~ ^brew\ \"([^\"]+)\" ]]; then
        pkg="${BASH_REMATCH[1]}"
        if ! echo "$INSTALLED" | grep -q "^$pkg$"; then
            NOT_INSTALLED+=("$pkg")
        fi
    fi
done < "$BREWFILE"

if [ ${#NOT_INSTALLED[@]} -eq 0 ]; then
    echo -e "${GREEN}✓ Brewfileのすべてのパッケージがインストール済みです${NC}"
else
    echo -e "${YELLOW}⚠ 以下のパッケージがインストールされていません:${NC}"
    for pkg in "${NOT_INSTALLED[@]}"; do
        echo -e "   - $pkg"
    done
    echo -e "\n   ${BLUE}インストールコマンド:${NC}"
    echo -e "   brew bundle --file=$BREWFILE"
fi

# ========================================
# Caskの確認
# ========================================
echo -e "\n${YELLOW}[3/3] Caskの状態確認...${NC}"

INSTALLED_CASKS=$(brew list --cask 2>/dev/null | wc -l | tr -d ' ')
BREWFILE_CASKS=$(grep -c '^cask ' "$BREWFILE" 2>/dev/null || echo "0")

echo -e "${GREEN}✓ インストール済みCask: ${INSTALLED_CASKS}個${NC}"
echo -e "${GREEN}✓ Brewfile内のCask: ${BREWFILE_CASKS}個${NC}"

# ========================================
# 完了
# ========================================
echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}  チェック完了${NC}"
echo -e "${GREEN}========================================${NC}"
