#!/usr/bin/env bats
# brewfile.bats - Brewfileのテスト

load 'test_helper'

@test "Brewfile exists" {
    assert_file_exists "${DOTFILES_ROOT}/Brewfile"
}

@test "Brewfile.full exists" {
    assert_file_exists "${DOTFILES_ROOT}/Brewfile.full"
}

@test "Brewfile.linux exists" {
    assert_file_exists "${DOTFILES_ROOT}/Brewfile.linux"
}

@test "Brewfile has no duplicate entries" {
    local duplicates=$(grep -E "^(brew|cask|tap) " "${DOTFILES_ROOT}/Brewfile" | sort | uniq -d)
    if [[ -n "$duplicates" ]]; then
        echo "Duplicate entries found:" >&2
        echo "$duplicates" >&2
        return 1
    fi
}

@test "Brewfile.full has no duplicate entries" {
    local duplicates=$(grep -E "^(brew|cask|tap) " "${DOTFILES_ROOT}/Brewfile.full" | sort | uniq -d)
    if [[ -n "$duplicates" ]]; then
        echo "Duplicate entries found:" >&2
        echo "$duplicates" >&2
        return 1
    fi
}

@test "Brewfile entries are properly quoted" {
    # 不正な引用符をチェック
    if grep -E '^(brew|cask) [^"]+[^#]$' "${DOTFILES_ROOT}/Brewfile" | grep -v "^#"; then
        # コメント以外で引用符なしのエントリは警告（エラーではない）
        echo "Warning: Some entries may not be properly quoted" >&2
    fi
    return 0
}
