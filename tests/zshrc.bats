#!/usr/bin/env bats
# zshrc.bats - zshrc構文とfzf関数テスト

load 'test_helper'

# fzf関数ファイルのパス
FZF_FUNCTIONS_FILE="$DOTFILES_ROOT/stow/zsh/.zsh/functions/fzf-functions.zsh"

# 構文チェック
@test ".zshrc has valid zsh syntax" {
    if command -v zsh &>/dev/null; then
        run zsh -n "$DOTFILES_ROOT/.zshrc"
        [ "$status" -eq 0 ]
    else
        skip "zsh not installed"
    fi
}

@test ".aliases has valid zsh syntax" {
    if command -v zsh &>/dev/null && [ -f "$DOTFILES_ROOT/.aliases" ]; then
        run zsh -n "$DOTFILES_ROOT/.aliases"
        [ "$status" -eq 0 ]
    else
        skip "zsh not installed or .aliases not found"
    fi
}

@test "fzf-functions.zsh has valid zsh syntax" {
    if command -v zsh &>/dev/null && [ -f "$FZF_FUNCTIONS_FILE" ]; then
        run zsh -n "$FZF_FUNCTIONS_FILE"
        [ "$status" -eq 0 ]
    else
        skip "zsh not installed or fzf-functions.zsh not found"
    fi
}

# 必須設定の存在確認
@test ".zshrc contains Oh My Zsh configuration" {
    grep -q 'export ZSH=' "$DOTFILES_ROOT/.zshrc"
}

@test ".zshrc contains Powerlevel10k theme" {
    grep -q 'ZSH_THEME="powerlevel10k/powerlevel10k"' "$DOTFILES_ROOT/.zshrc"
}

@test ".zshrc contains essential plugins" {
    grep -q 'zsh-autosuggestions' "$DOTFILES_ROOT/.zshrc"
    grep -q 'zsh-syntax-highlighting' "$DOTFILES_ROOT/.zshrc"
    grep -q 'zsh-completions' "$DOTFILES_ROOT/.zshrc"
}

@test ".zshrc contains git plugin" {
    grep -q 'plugins=(' "$DOTFILES_ROOT/.zshrc"
    grep -q 'git' "$DOTFILES_ROOT/.zshrc"
}

@test ".zshrc contains fzf plugin" {
    grep -q 'fzf' "$DOTFILES_ROOT/.zshrc"
}

# fzf関数ファイルの存在確認
@test "fzf functions file exists" {
    assert_file_exists "$FZF_FUNCTIONS_FILE"
}

# fzf関数の存在確認（遅延読み込みファイル内）
@test "fzf-functions.zsh defines fbr function" {
    grep -q '^fbr()' "$FZF_FUNCTIONS_FILE"
}

@test "fzf-functions.zsh defines fshow function" {
    grep -q '^fshow()' "$FZF_FUNCTIONS_FILE"
}

@test "fzf-functions.zsh defines fvim function" {
    grep -q '^fvim()' "$FZF_FUNCTIONS_FILE"
}

@test "fzf-functions.zsh defines fkill function" {
    grep -q '^fkill()' "$FZF_FUNCTIONS_FILE"
}

@test "fzf-functions.zsh defines fcd function" {
    grep -q '^fcd()' "$FZF_FUNCTIONS_FILE"
}

@test "fzf-functions.zsh defines fstash function" {
    grep -q '^fstash()' "$FZF_FUNCTIONS_FILE"
}

@test "fzf-functions.zsh defines fenv function" {
    grep -q '^fenv()' "$FZF_FUNCTIONS_FILE"
}

@test "fzf-functions.zsh defines fhistory function" {
    grep -q '^fhistory()' "$FZF_FUNCTIONS_FILE"
}

@test "fzf-functions.zsh defines fman function" {
    grep -q '^fman()' "$FZF_FUNCTIONS_FILE"
}

# .zshrcがfzf関数の遅延読み込みを設定していること
@test ".zshrc sets up lazy loading for fzf functions" {
    grep -q '_fzf_functions_file' "$DOTFILES_ROOT/.zshrc"
    grep -q '_load_fzf_functions' "$DOTFILES_ROOT/.zshrc"
}

# エイリアス読み込み確認
@test ".zshrc sources .aliases file" {
    grep -q 'source ~/.aliases' "$DOTFILES_ROOT/.zshrc" || \
    grep -q '\. ~/.aliases' "$DOTFILES_ROOT/.zshrc" || \
    grep -qE 'if \[\[.*~/.aliases.*\]\].*source' "$DOTFILES_ROOT/.zshrc"
}

# ヒストリ設定確認
@test ".zshrc contains history configuration" {
    grep -q 'HISTSIZE=' "$DOTFILES_ROOT/.zshrc"
    grep -q 'SAVEHIST=' "$DOTFILES_ROOT/.zshrc"
    grep -q 'HISTFILE=' "$DOTFILES_ROOT/.zshrc"
}

# zshオプション確認
@test ".zshrc sets recommended zsh options" {
    grep -q 'setopt.*hist_ignore_dups' "$DOTFILES_ROOT/.zshrc"
    grep -q 'setopt.*share_history' "$DOTFILES_ROOT/.zshrc"
}

# Powerlevel10k instant prompt確認
@test ".zshrc has Powerlevel10k instant prompt at top" {
    # 最初の30行以内にinstant promptがあること
    head -30 "$DOTFILES_ROOT/.zshrc" | grep -q 'p10k-instant-prompt'
}

# プロファイル機能確認
@test ".zshrc supports DOTFILES_PROFILE" {
    grep -q 'DOTFILES_PROFILE' "$DOTFILES_ROOT/.zshrc"
}

# ローカル設定読み込み確認
@test ".zshrc sources .zshrc.local" {
    grep -q '\.zshrc\.local' "$DOTFILES_ROOT/.zshrc"
}

# セキュリティ：機密情報がないこと
@test ".zshrc does not contain hardcoded API keys" {
    ! grep -qE 'sk-[A-Za-z0-9]{48}' "$DOTFILES_ROOT/.zshrc"
    ! grep -qE 'ghp_[A-Za-z0-9]{36}' "$DOTFILES_ROOT/.zshrc"
}

# エディタ設定確認
@test ".zshrc sets EDITOR variable" {
    grep -q 'export EDITOR=' "$DOTFILES_ROOT/.zshrc"
}
