#!/usr/bin/env bats
# integration-bootstrap.bats - bootstrap.sh の統合テスト

load test_helper

# ========================================
# 基本テスト
# ========================================
@test "bootstrap.sh exists" {
    assert_file_exists "${DOTFILES_ROOT}/bootstrap.sh"
}

@test "bootstrap.sh has valid bash syntax" {
    run bash -n "${DOTFILES_ROOT}/bootstrap.sh"
    assert_success
}

@test "bootstrap.sh has shebang" {
    run head -1 "${DOTFILES_ROOT}/bootstrap.sh"
    assert_output --partial "#!/bin/bash"
}

# ========================================
# ヘルプオプションテスト
# ========================================
@test "bootstrap.sh shows help with -h" {
    run bash "${DOTFILES_ROOT}/bootstrap.sh" -h
    assert_success
    assert_output --partial "使用方法"
}

@test "bootstrap.sh shows help with --help" {
    run bash "${DOTFILES_ROOT}/bootstrap.sh" --help
    assert_success
    assert_output --partial "使用方法"
}

# ========================================
# ドライランテスト
# ========================================
@test "bootstrap.sh accepts --dry-run flag" {
    # CI環境でのドライラン実行（実際の変更なし）
    if [[ "${CI:-}" == "true" ]]; then
        skip "Skipping in CI environment"
    fi
    run timeout 5 bash "${DOTFILES_ROOT}/bootstrap.sh" --dry-run <<< "n" 2>&1 || true
    # --dry-runフラグが認識されることを確認
    [[ ! "$output" =~ "不明なオプション" ]]
}

@test "bootstrap.sh accepts -n flag" {
    if [[ "${CI:-}" == "true" ]]; then
        skip "Skipping in CI environment"
    fi
    run timeout 5 bash "${DOTFILES_ROOT}/bootstrap.sh" -n <<< "n" 2>&1 || true
    [[ ! "$output" =~ "不明なオプション" ]]
}

# ========================================
# 関数定義テスト
# ========================================
@test "bootstrap.sh defines safe_link function" {
    run grep -q "safe_link()" "${DOTFILES_ROOT}/bootstrap.sh"
    assert_success
}

@test "bootstrap.sh defines run_cmd function" {
    run grep -q "run_cmd()" "${DOTFILES_ROOT}/bootstrap.sh"
    assert_success
}

@test "bootstrap.sh defines detect_system function" {
    run grep -q "detect_system()" "${DOTFILES_ROOT}/bootstrap.sh"
    assert_success
}

@test "bootstrap.sh defines check_dependencies function" {
    run grep -q "check_dependencies()" "${DOTFILES_ROOT}/bootstrap.sh"
    assert_success
}

# ========================================
# 設定ファイル参照テスト
# ========================================
@test "bootstrap.sh references Brewfile" {
    run grep -q "Brewfile" "${DOTFILES_ROOT}/bootstrap.sh"
    assert_success
}

@test "bootstrap.sh references .zshrc" {
    run grep -q ".zshrc" "${DOTFILES_ROOT}/bootstrap.sh"
    assert_success
}

@test "bootstrap.sh references .gitconfig" {
    run grep -q ".gitconfig" "${DOTFILES_ROOT}/bootstrap.sh"
    assert_success
}

# ========================================
# セキュリティテスト
# ========================================
@test "bootstrap.sh uses trap for cleanup" {
    run grep -q "trap.*cleanup" "${DOTFILES_ROOT}/bootstrap.sh"
    assert_success
}

@test "bootstrap.sh does not contain hardcoded secrets" {
    # API keys, tokens, passwords などが含まれていないことを確認
    run grep -iE "(api_key|api_secret|password|token).*=" "${DOTFILES_ROOT}/bootstrap.sh"
    # マッチしない（失敗する）ことを期待
    assert_failure
}

# ========================================
# common.sh 連携テスト
# ========================================
@test "bootstrap.sh attempts to source common.sh" {
    run grep -q "common.sh" "${DOTFILES_ROOT}/bootstrap.sh"
    assert_success
}

# ========================================
# OS対応テスト
# ========================================
@test "bootstrap.sh handles macOS" {
    run grep -q "Darwin" "${DOTFILES_ROOT}/bootstrap.sh"
    assert_success
}

@test "bootstrap.sh handles Linux" {
    run grep -q "Linux" "${DOTFILES_ROOT}/bootstrap.sh"
    assert_success
}

@test "bootstrap.sh handles WSL" {
    run grep -q "WSL\|Microsoft" "${DOTFILES_ROOT}/bootstrap.sh"
    assert_success
}
