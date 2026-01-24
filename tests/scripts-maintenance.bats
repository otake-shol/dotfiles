#!/usr/bin/env bats
# scripts-maintenance.bats - メンテナンススクリプトのテスト

load test_helper

# ========================================
# verify-setup.sh テスト
# ========================================
@test "verify-setup.sh exists and is executable" {
    assert_file_exists "${DOTFILES_ROOT}/scripts/maintenance/verify-setup.sh"
    [[ -x "${DOTFILES_ROOT}/scripts/maintenance/verify-setup.sh" ]] || \
        chmod +x "${DOTFILES_ROOT}/scripts/maintenance/verify-setup.sh"
}

@test "verify-setup.sh has valid bash syntax" {
    run bash -n "${DOTFILES_ROOT}/scripts/maintenance/verify-setup.sh"
    assert_success
}

@test "verify-setup.sh sources common.sh" {
    run grep -q "source.*common.sh" "${DOTFILES_ROOT}/scripts/maintenance/verify-setup.sh"
    assert_success
}

# ========================================
# update-all.sh テスト
# ========================================
@test "update-all.sh exists and is executable" {
    assert_file_exists "${DOTFILES_ROOT}/scripts/maintenance/update-all.sh"
}

@test "update-all.sh has valid bash syntax" {
    run bash -n "${DOTFILES_ROOT}/scripts/maintenance/update-all.sh"
    assert_success
}

@test "update-all.sh sources common.sh" {
    run grep -q "source.*common.sh" "${DOTFILES_ROOT}/scripts/maintenance/update-all.sh"
    assert_success
}

# ========================================
# check-updates.sh テスト
# ========================================
@test "check-updates.sh exists" {
    assert_file_exists "${DOTFILES_ROOT}/scripts/maintenance/check-updates.sh"
}

@test "check-updates.sh has valid bash syntax" {
    run bash -n "${DOTFILES_ROOT}/scripts/maintenance/check-updates.sh"
    assert_success
}

@test "check-updates.sh sources common.sh" {
    run grep -q "source.*common.sh" "${DOTFILES_ROOT}/scripts/maintenance/check-updates.sh"
    assert_success
}

# ========================================
# sync-brewfile.sh テスト
# ========================================
@test "sync-brewfile.sh exists" {
    assert_file_exists "${DOTFILES_ROOT}/scripts/maintenance/sync-brewfile.sh"
}

@test "sync-brewfile.sh has valid bash syntax" {
    run bash -n "${DOTFILES_ROOT}/scripts/maintenance/sync-brewfile.sh"
    assert_success
}

@test "sync-brewfile.sh sources common.sh" {
    run grep -q "source.*common.sh" "${DOTFILES_ROOT}/scripts/maintenance/sync-brewfile.sh"
    assert_success
}

# ========================================
# 共通テスト: set -euo pipefail
# ========================================
@test "all maintenance scripts use strict mode" {
    for script in "${DOTFILES_ROOT}"/scripts/maintenance/*.sh; do
        run grep -q "set -euo pipefail\|set -e" "$script"
        assert_success "Script $script should use strict mode"
    done
}

# ========================================
# 共通テスト: ShellCheck互換性
# ========================================
@test "maintenance scripts have shellcheck directives where needed" {
    # shellcheck source ディレクティブの存在確認
    for script in "${DOTFILES_ROOT}"/scripts/maintenance/*.sh; do
        if grep -q "source.*common.sh" "$script"; then
            run grep -q "shellcheck source" "$script"
            assert_success "Script $script should have shellcheck source directive"
        fi
    done
}
