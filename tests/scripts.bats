#!/usr/bin/env bats
# scripts.bats - スクリプトの構文チェック

load 'test_helper'

# 全てのシェルスクリプトの構文チェック
@test "all shell scripts have valid syntax" {
    local failed=()

    while IFS= read -r script; do
        if ! bash -n "$script" 2>/dev/null; then
            failed+=("$script")
        fi
    done < <(find "${DOTFILES_ROOT}" -name "*.sh" -type f -not -path "*/.git/*")

    if [[ ${#failed[@]} -gt 0 ]]; then
        echo "Scripts with syntax errors:" >&2
        printf '  %s\n' "${failed[@]}" >&2
        return 1
    fi
}

@test "os-detect.sh works correctly" {
    run bash "${DOTFILES_ROOT}/scripts/lib/os-detect.sh"
    assert_success
    assert_output --partial "OS:"
    assert_output --partial "Arch:"
}

@test "verify-setup.sh has valid syntax" {
    run bash -n "${DOTFILES_ROOT}/scripts/maintenance/verify-setup.sh"
    assert_success
}

@test "zsh-benchmark.sh has valid syntax" {
    run bash -n "${DOTFILES_ROOT}/scripts/utils/zsh-benchmark.sh"
    assert_success
}
