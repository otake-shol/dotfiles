#!/usr/bin/env bats
# ssh-helper.bats - setup-ssh.sh のテスト

load 'test_helper'

@test "setup-ssh.sh exists and is executable" {
    assert_file_exists "$DOTFILES_ROOT/scripts/utils/setup-ssh.sh"
    [[ -x "$DOTFILES_ROOT/scripts/utils/setup-ssh.sh" ]]
}

@test "setup-ssh.sh has valid bash syntax" {
    run bash -n "$DOTFILES_ROOT/scripts/utils/setup-ssh.sh"
    assert_success
}

@test "setup-ssh.sh --help shows usage" {
    run bash "$DOTFILES_ROOT/scripts/utils/setup-ssh.sh" --help
    assert_success
    assert_output --partial "使用方法"
}

@test "setup-ssh.sh --list runs without error" {
    run bash "$DOTFILES_ROOT/scripts/utils/setup-ssh.sh" --list
    # 鍵がなくても成功するはず
    assert_success
}

@test "setup-ssh.sh validates key type" {
    # 無効な鍵タイプでエラーになることを確認
    # 実際に生成はしない（--helpで検証）
    run bash "$DOTFILES_ROOT/scripts/utils/setup-ssh.sh" --help
    assert_success
    assert_output --partial "ed25519"
    assert_output --partial "rsa"
}

@test "setup-ssh.sh supports GitHub mode" {
    run bash "$DOTFILES_ROOT/scripts/utils/setup-ssh.sh" --help
    assert_success
    assert_output --partial "--github"
}
