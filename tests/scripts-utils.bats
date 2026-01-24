#!/usr/bin/env bats
# scripts-utils.bats - ユーティリティスクリプトのテスト

load test_helper

# ========================================
# zsh-benchmark.sh テスト
# ========================================
@test "zsh-benchmark.sh exists" {
    assert_file_exists "${DOTFILES_ROOT}/scripts/utils/zsh-benchmark.sh"
}

@test "zsh-benchmark.sh has valid bash syntax" {
    run bash -n "${DOTFILES_ROOT}/scripts/utils/zsh-benchmark.sh"
    assert_success
}

@test "zsh-benchmark.sh sources common.sh" {
    run grep -q "source.*common.sh" "${DOTFILES_ROOT}/scripts/utils/zsh-benchmark.sh"
    assert_success
}

# ========================================
# dothelp.sh テスト
# ========================================
@test "dothelp.sh exists" {
    assert_file_exists "${DOTFILES_ROOT}/scripts/utils/dothelp.sh"
}

@test "dothelp.sh has valid bash syntax" {
    run bash -n "${DOTFILES_ROOT}/scripts/utils/dothelp.sh"
    assert_success
}

@test "dothelp.sh sources common.sh" {
    run grep -q "source.*common.sh" "${DOTFILES_ROOT}/scripts/utils/dothelp.sh"
    assert_success
}

@test "dothelp.sh shows help with -h flag" {
    run bash "${DOTFILES_ROOT}/scripts/utils/dothelp.sh" -h
    assert_success
    assert_output --partial "dothelp"
}

@test "dothelp.sh shows all aliases with all argument" {
    run bash "${DOTFILES_ROOT}/scripts/utils/dothelp.sh" all
    assert_success
    assert_output --partial "Git"
}

# ========================================
# os-detect.sh テスト
# ========================================
@test "os-detect.sh exists" {
    assert_file_exists "${DOTFILES_ROOT}/scripts/lib/os-detect.sh"
}

@test "os-detect.sh has valid bash syntax" {
    run bash -n "${DOTFILES_ROOT}/scripts/lib/os-detect.sh"
    assert_success
}

@test "os-detect.sh detect_os returns valid value" {
    source "${DOTFILES_ROOT}/scripts/lib/os-detect.sh"
    run detect_os
    assert_success
    # Should return macos, linux, or unknown
    [[ "$output" =~ ^(macos|linux|windows|unknown)$ ]]
}

@test "os-detect.sh detect_arch returns valid value" {
    source "${DOTFILES_ROOT}/scripts/lib/os-detect.sh"
    run detect_arch
    assert_success
    [[ "$output" =~ ^(arm64|amd64|x86|unknown)$ ]]
}

# ========================================
# 共通テスト: 実行可能性
# ========================================
@test "all utils scripts have shebang" {
    for script in "${DOTFILES_ROOT}"/scripts/utils/*.sh; do
        run head -1 "$script"
        assert_output --partial "#!/bin/bash"
    done
}

# ========================================
# 共通テスト: 変数の適切な使用
# ========================================
@test "utils scripts use SCRIPT_DIR for relative paths" {
    for script in "${DOTFILES_ROOT}"/scripts/utils/*.sh; do
        if grep -q "source.*common.sh" "$script"; then
            run grep -q 'SCRIPT_DIR=' "$script"
            assert_success "Script $script should define SCRIPT_DIR"
        fi
    done
}
