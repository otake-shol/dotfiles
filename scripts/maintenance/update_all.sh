#!/bin/bash
# update_all.sh - 開発環境の一括更新スクリプト（実行）
# 使用方法: bash scripts/maintenance/update_all.sh
# エイリアス: dotupdate
#
# 役割分担:
#   check_updates.sh (dotup)   - 更新があるか確認するのみ（変更なし）
#   update_all.sh (dotupdate)  - 実際に更新を実行する

set -euo pipefail

# ヘルプ表示
show_help() {
    cat << 'EOF'
update_all.sh - 開発環境の一括更新スクリプト

使用方法:
    bash scripts/maintenance/update_all.sh
    dotupdate  # エイリアス

オプション:
    -h, --help    このヘルプを表示

更新対象:
    - Homebrew (brew update && upgrade && cleanup)
    - Oh My Zsh
    - Zshプラグイン (Powerlevel10k, autosuggestions, syntax-highlighting, completions)
    - miseランタイム

説明:
    このスクリプトは実際に更新を実行します。
    更新の確認のみを行うには check_updates.sh (dotup) を使用してください。
EOF
}

[[ "${1:-}" == "-h" || "${1:-}" == "--help" ]] && show_help && exit 0

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 共通ライブラリ読み込み
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"

# 更新結果を格納
UPDATED=()
SKIPPED=()
FAILED=()

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  開発環境 一括更新${NC}"
echo -e "${BLUE}========================================${NC}"

# ========================================
# 1. Homebrew
# ========================================
echo -e "\n${YELLOW}[1/4] Homebrew...${NC}"
if command -v brew &> /dev/null; then
    brew update && brew upgrade && brew cleanup
    UPDATED+=("Homebrew")
    echo -e "${GREEN}✓ Homebrew更新完了${NC}"
else
    SKIPPED+=("Homebrew (未インストール)")
fi

# ========================================
# 2. Oh My Zsh
# ========================================
echo -e "\n${YELLOW}[2/4] Oh My Zsh...${NC}"
if [ -d "$HOME/.oh-my-zsh" ]; then
    cd "$HOME/.oh-my-zsh"
    if git pull --rebase origin master; then
        UPDATED+=("Oh My Zsh")
        echo -e "${GREEN}✓ Oh My Zsh更新完了${NC}"
    else
        FAILED+=("Oh My Zsh")
        echo -e "${RED}✗ Oh My Zsh更新失敗${NC}"
    fi
else
    SKIPPED+=("Oh My Zsh (未インストール)")
fi

# ========================================
# 3. Zsh Plugins（共通関数を使用）
# ========================================
echo -e "\n${YELLOW}[3/4] Zshプラグイン...${NC}"
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# プラグインリスト: 名前|パス
ZSH_PLUGINS=(
    "Powerlevel10k|$ZSH_CUSTOM/themes/powerlevel10k"
    "zsh-autosuggestions|$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    "zsh-syntax-highlighting|$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    "zsh-completions|$ZSH_CUSTOM/plugins/zsh-completions"
)

for plugin in "${ZSH_PLUGINS[@]}"; do
    name="${plugin%%|*}"
    path="${plugin##*|}"
    update_zsh_plugin "$name" "$path"
done

UPDATED+=("Zshプラグイン")

# ========================================
# 4. mise
# ========================================
echo -e "\n${YELLOW}[4/4] mise...${NC}"
if command -v mise &> /dev/null; then
    mise upgrade 2>/dev/null || true
    UPDATED+=("mise runtimes")
    echo -e "${GREEN}✓ miseランタイム更新完了${NC}"
else
    SKIPPED+=("mise (未インストール)")
fi

# ========================================
# 結果サマリー
# ========================================
echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}  更新完了${NC}"
echo -e "${GREEN}========================================${NC}"

if [ ${#UPDATED[@]} -gt 0 ]; then
    echo -e "\n${GREEN}更新済み:${NC}"
    for item in "${UPDATED[@]}"; do
        echo -e "  ✓ $item"
    done
fi

if [ ${#SKIPPED[@]} -gt 0 ]; then
    echo -e "\n${YELLOW}スキップ:${NC}"
    for item in "${SKIPPED[@]}"; do
        echo -e "  - $item"
    done
fi

if [ ${#FAILED[@]} -gt 0 ]; then
    echo -e "\n${RED}失敗:${NC}"
    for item in "${FAILED[@]}"; do
        echo -e "  ✗ $item"
    done
fi

echo -e "\n${BLUE}ヒント: 'source ~/.zshrc' で設定を再読み込み${NC}"
