#!/usr/bin/env bats
# lib-common.bats - common.sh ライブラリのテスト

load test_helper

setup() {
    source "${DOTFILES_ROOT}/scripts/lib/common.sh"
    check_reset_counters
}

# ========================================
# 色定義テスト
# ========================================
@test "color variables are defined" {
    [[ -n "$RED" ]]
    [[ -n "$GREEN" ]]
    [[ -n "$YELLOW" ]]
    [[ -n "$BLUE" ]]
    [[ -n "$CYAN" ]]
    [[ -n "$NC" ]]
    [[ -n "$BOLD" ]]
}

@test "color codes are valid ANSI sequences" {
    [[ "$RED" == $'\033[0;31m' ]]
    [[ "$GREEN" == $'\033[0;32m' ]]
    [[ "$NC" == $'\033[0m' ]]
}

# ========================================
# ログ関数テスト
# ========================================
@test "log_info outputs with INFO prefix" {
    run log_info "test message"
    assert_success
    assert_output --partial "[INFO]"
    assert_output --partial "test message"
}

@test "log_success outputs with OK prefix" {
    run log_success "success message"
    assert_success
    assert_output --partial "[OK]"
    assert_output --partial "success message"
}

@test "log_warn outputs to stderr" {
    run log_warn "warning message"
    assert_success
    assert_output --partial "[WARN]"
}

@test "log_error outputs to stderr" {
    run log_error "error message"
    assert_success
    assert_output --partial "[ERROR]"
}

@test "log_debug outputs only when COMMON_VERBOSE is true" {
    COMMON_VERBOSE=false
    run log_debug "debug message"
    assert_success
    refute_output --partial "debug message"

    COMMON_VERBOSE=true
    run log_debug "debug message"
    assert_success
    assert_output --partial "[DEBUG]"
}

# ========================================
# チェック関数テスト
# ========================================
@test "check_pass increments counter" {
    check_reset_counters
    check_pass "test pass"
    [[ "$COMMON_CHECK_PASS" -eq 1 ]]
}

@test "check_fail increments counter" {
    check_reset_counters
    check_fail "test fail"
    [[ "$COMMON_CHECK_FAIL" -eq 1 ]]
}

@test "check_warn increments counter" {
    check_reset_counters
    check_warn "test warn"
    [[ "$COMMON_CHECK_WARN" -eq 1 ]]
}

@test "check_reset_counters resets all counters" {
    COMMON_CHECK_PASS=5
    COMMON_CHECK_FAIL=3
    COMMON_CHECK_WARN=2
    check_reset_counters
    [[ "$COMMON_CHECK_PASS" -eq 0 ]]
    [[ "$COMMON_CHECK_FAIL" -eq 0 ]]
    [[ "$COMMON_CHECK_WARN" -eq 0 ]]
}

# ========================================
# UI関数テスト
# ========================================
@test "print_header outputs header with title" {
    run print_header "Test Header"
    assert_success
    assert_output --partial "Test Header"
}

@test "print_section outputs section with title" {
    run print_section "Test Section"
    assert_success
    assert_output --partial "Test Section"
}

@test "print_banner outputs banner box" {
    run print_banner "Banner Title"
    assert_success
    assert_output --partial "Banner Title"
}

# ========================================
# ユーティリティ関数テスト
# ========================================
@test "require_command succeeds for existing command" {
    run require_command "bash"
    assert_success
}

@test "require_command fails for non-existing command" {
    run require_command "nonexistent_command_xyz"
    assert_failure
}

@test "require_commands succeeds when all commands exist" {
    run require_commands "bash" "sh"
    assert_success
}

@test "require_commands fails when any command is missing" {
    run require_commands "bash" "nonexistent_cmd"
    assert_failure
}

@test "run_cmd executes command normally when DRY_RUN=false" {
    DRY_RUN=false
    run run_cmd echo "hello"
    assert_success
    assert_output "hello"
}

@test "run_cmd shows dry run message when DRY_RUN=true" {
    DRY_RUN=true
    run run_cmd echo "hello"
    assert_success
    assert_output --partial "[DRY RUN]"
}

# ========================================
# OS検出関数テスト
# ========================================
@test "is_macos returns correct value" {
    if [[ "$(uname -s)" == "Darwin" ]]; then
        run is_macos
        assert_success
    else
        run is_macos
        assert_failure
    fi
}

@test "is_linux returns correct value" {
    if [[ "$(uname -s)" == "Linux" ]]; then
        run is_linux
        assert_success
    else
        run is_linux
        assert_failure
    fi
}

@test "is_arm64 returns correct value" {
    if [[ "$(uname -m)" == "arm64" || "$(uname -m)" == "aarch64" ]]; then
        run is_arm64
        assert_success
    else
        run is_arm64
        assert_failure
    fi
}

# ========================================
# 二重読み込み防止テスト
# ========================================
@test "common.sh can be sourced multiple times safely" {
    source "${DOTFILES_ROOT}/scripts/lib/common.sh"
    source "${DOTFILES_ROOT}/scripts/lib/common.sh"
    [[ -n "$RED" ]]
}
