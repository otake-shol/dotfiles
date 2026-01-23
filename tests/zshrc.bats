#!/usr/bin/env bats
# zshrc.bats - zshrc構文とfzf関数テスト

load 'test_helper'

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

# fzf関数の存在確認
@test ".zshrc defines fbr function" {
    grep -q '^fbr()' "$DOTFILES_ROOT/.zshrc"
}

@test ".zshrc defines fshow function" {
    grep -q '^fshow()' "$DOTFILES_ROOT/.zshrc"
}

@test ".zshrc defines fvim function" {
    grep -q '^fvim()' "$DOTFILES_ROOT/.zshrc"
}

@test ".zshrc defines fkill function" {
    grep -q '^fkill()' "$DOTFILES_ROOT/.zshrc"
}

@test ".zshrc defines fcd function" {
    grep -q '^fcd()' "$DOTFILES_ROOT/.zshrc"
}

@test ".zshrc defines fstash function" {
    grep -q '^fstash()' "$DOTFILES_ROOT/.zshrc"
}

@test ".zshrc defines fenv function" {
    grep -q '^fenv()' "$DOTFILES_ROOT/.zshrc"
}

@test ".zshrc defines fhistory function" {
    grep -q '^fhistory()' "$DOTFILES_ROOT/.zshrc"
}

@test ".zshrc defines fman function" {
    grep -q '^fman()' "$DOTFILES_ROOT/.zshrc"
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
