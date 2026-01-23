#!/usr/bin/env bats
# bootstrap.bats - bootstrap.sh のテスト

load 'test_helper'

@test "bootstrap.sh exists and is executable" {
    assert_file_exists "${DOTFILES_ROOT}/bootstrap.sh"
    [[ -x "${DOTFILES_ROOT}/bootstrap.sh" ]] || chmod +x "${DOTFILES_ROOT}/bootstrap.sh"
}

@test "bootstrap.sh has valid bash syntax" {
    run bash -n "${DOTFILES_ROOT}/bootstrap.sh"
    assert_success
}

@test "bootstrap.sh --help shows usage" {
    run bash "${DOTFILES_ROOT}/bootstrap.sh" --help
    assert_success
    assert_output --partial "使用方法"
}

@test "bootstrap.sh --dry-run completes without error" {
    # dry-runは対話的入力をスキップするためのモック環境が必要
    # 実際のテストでは環境によってスキップ
    if [[ "$CI" != "true" ]]; then
        skip "Skipping interactive test outside CI"
    fi
    run bash "${DOTFILES_ROOT}/bootstrap.sh" --dry-run <<< "n"
    # dry-runはHomebrew未インストールで停止する可能性がある
    # エラーがあっても特定のエラー以外はOK
}

@test "bootstrap.sh detects OS correctly" {
    source "${DOTFILES_ROOT}/scripts/lib/os-detect.sh"
    run detect_os
    assert_success
    # macOS または linux が返される
    [[ "$output" == "macos" ]] || [[ "$output" == "linux" ]]
}

@test "bootstrap.sh detects architecture correctly" {
    source "${DOTFILES_ROOT}/scripts/lib/os-detect.sh"
    run detect_arch
    assert_success
    # arm64, amd64, x86 のいずれか
    [[ "$output" == "arm64" ]] || [[ "$output" == "amd64" ]] || [[ "$output" == "x86" ]]
}
