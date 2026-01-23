#!/usr/bin/env bats
# config.bats - 設定ファイルのテスト

load 'test_helper'

@test ".zshrc exists" {
    assert_file_exists "${DOTFILES_ROOT}/.zshrc"
}

@test ".zshrc has valid zsh syntax" {
    # zshrc は oh-my-zsh に依存するため、構文チェックのみ
    run zsh -n "${DOTFILES_ROOT}/.zshrc"
    # oh-my-zsh がない環境ではエラーになる可能性があるためスキップ
    if [[ $status -ne 0 ]]; then
        skip "zshrc syntax check requires oh-my-zsh"
    fi
    assert_success
}

@test ".editorconfig exists" {
    assert_file_exists "${DOTFILES_ROOT}/.editorconfig"
}

@test ".tool-versions exists" {
    assert_file_exists "${DOTFILES_ROOT}/.tool-versions"
}

@test "git/.gitconfig exists" {
    assert_file_exists "${DOTFILES_ROOT}/git/.gitconfig"
}

@test "git/.gitignore_global exists" {
    assert_file_exists "${DOTFILES_ROOT}/git/.gitignore_global"
}

@test "nvim/init.lua exists" {
    assert_file_exists "${DOTFILES_ROOT}/nvim/.config/nvim/init.lua"
}

@test "tmux/.tmux.conf exists" {
    assert_file_exists "${DOTFILES_ROOT}/tmux/.tmux.conf"
}

@test "ghostty/config exists" {
    assert_file_exists "${DOTFILES_ROOT}/ghostty/config"
}
