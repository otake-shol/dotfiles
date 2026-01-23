#!/bin/bash
# update-all.sh - 開発環境の一括更新スクリプト
# 使用方法: bash scripts/update-all.sh
# エイリアス: dotupdate (推奨)

set -euo pipefail

# カラー出力
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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
echo -e "\n${YELLOW}[1/5] Homebrew...${NC}"
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
echo -e "\n${YELLOW}[2/5] Oh My Zsh...${NC}"
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
# 3. Zsh Plugins
# ========================================
echo -e "\n${YELLOW}[3/5] Zshプラグイン...${NC}"
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# Powerlevel10k
if [ -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
    cd "$ZSH_CUSTOM/themes/powerlevel10k"
    git pull --quiet && echo -e "${GREEN}  ✓ Powerlevel10k${NC}" || echo -e "${RED}  ✗ Powerlevel10k${NC}"
fi

# zsh-autosuggestions
if [ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    cd "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    git pull --quiet && echo -e "${GREEN}  ✓ zsh-autosuggestions${NC}" || echo -e "${RED}  ✗ zsh-autosuggestions${NC}"
fi

# zsh-syntax-highlighting
if [ -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    cd "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    git pull --quiet && echo -e "${GREEN}  ✓ zsh-syntax-highlighting${NC}" || echo -e "${RED}  ✗ zsh-syntax-highlighting${NC}"
fi

# zsh-completions
if [ -d "$ZSH_CUSTOM/plugins/zsh-completions" ]; then
    cd "$ZSH_CUSTOM/plugins/zsh-completions"
    git pull --quiet && echo -e "${GREEN}  ✓ zsh-completions${NC}" || echo -e "${RED}  ✗ zsh-completions${NC}"
fi

UPDATED+=("Zshプラグイン")

# ========================================
# 4. asdf
# ========================================
echo -e "\n${YELLOW}[4/5] asdf...${NC}"
if command -v asdf &> /dev/null; then
    asdf plugin update --all 2>/dev/null || true
    UPDATED+=("asdf plugins")
    echo -e "${GREEN}✓ asdfプラグイン更新完了${NC}"
else
    SKIPPED+=("asdf (未インストール)")
fi

# ========================================
# 5. TPM (tmux plugin manager)
# ========================================
echo -e "\n${YELLOW}[5/5] TPM (tmuxプラグイン)...${NC}"
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [ -d "$TPM_DIR" ]; then
    cd "$TPM_DIR"
    if git pull --quiet; then
        # プラグイン更新
        "$TPM_DIR/bin/update_plugins" all 2>/dev/null || true
        UPDATED+=("TPM")
        echo -e "${GREEN}✓ TPM更新完了${NC}"
    else
        FAILED+=("TPM")
        echo -e "${RED}✗ TPM更新失敗${NC}"
    fi
else
    SKIPPED+=("TPM (未インストール)")
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
