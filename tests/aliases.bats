#!/usr/bin/env bats
# aliases.bats - エイリアスファイルのテスト

load 'test_helper'

@test "aliases directory exists" {
    assert_dir_exists "${DOTFILES_ROOT}/aliases"
}

@test "core.zsh exists" {
    assert_file_exists "${DOTFILES_ROOT}/aliases/core.zsh"
}

@test "git.zsh exists" {
    assert_file_exists "${DOTFILES_ROOT}/aliases/git.zsh"
}

@test "all alias files have valid zsh syntax" {
    local failed=()

    for file in "${DOTFILES_ROOT}"/aliases/*.zsh; do
        if [[ -f "$file" ]]; then
            if ! zsh -n "$file" 2>/dev/null; then
                failed+=("$file")
            fi
        fi
    done

    if [[ ${#failed[@]} -gt 0 ]]; then
        echo "Files with syntax errors:" >&2
        printf '  %s\n' "${failed[@]}" >&2
        return 1
    fi
}

@test ".aliases loader has valid syntax" {
    run zsh -n "${DOTFILES_ROOT}/.aliases"
    assert_success
}
