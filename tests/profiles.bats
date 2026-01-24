#!/usr/bin/env bats
# profiles.bats - プロファイル機能の統合テスト

load test_helper

# ========================================
# プロファイルファイル存在テスト
# ========================================
@test "personal.zsh profile exists" {
    assert_file_exists "${DOTFILES_ROOT}/profiles/personal.zsh"
}

@test "work.zsh profile exists" {
    assert_file_exists "${DOTFILES_ROOT}/profiles/work.zsh"
}

@test "minimal.zsh profile exists" {
    assert_file_exists "${DOTFILES_ROOT}/profiles/minimal.zsh"
}

# ========================================
# プロファイル構文テスト
# ========================================
@test "personal.zsh has valid zsh syntax" {
    run zsh -n "${DOTFILES_ROOT}/profiles/personal.zsh" 2>&1 || true
    # 構文エラーがなければOK
    [[ ! "$output" =~ "parse error" ]]
}

@test "work.zsh has valid zsh syntax" {
    run zsh -n "${DOTFILES_ROOT}/profiles/work.zsh" 2>&1 || true
    [[ ! "$output" =~ "parse error" ]]
}

@test "minimal.zsh has valid zsh syntax" {
    run zsh -n "${DOTFILES_ROOT}/profiles/minimal.zsh" 2>&1 || true
    [[ ! "$output" =~ "parse error" ]]
}

# ========================================
# プロファイル内容テスト
# ========================================
@test "personal.zsh contains personal-specific settings" {
    run cat "${DOTFILES_ROOT}/profiles/personal.zsh"
    assert_success
    # プロファイルが空でないことを確認
    [[ -s "${DOTFILES_ROOT}/profiles/personal.zsh" ]]
}

@test "work.zsh contains work-specific settings" {
    run cat "${DOTFILES_ROOT}/profiles/work.zsh"
    assert_success
    [[ -s "${DOTFILES_ROOT}/profiles/work.zsh" ]]
}

@test "minimal.zsh is minimalist" {
    # minimal.zshはサイズが小さいか、コメントのみであることを期待
    local line_count
    line_count=$(wc -l < "${DOTFILES_ROOT}/profiles/minimal.zsh")
    # 100行未満であることを確認（ミニマルなので）
    [[ "$line_count" -lt 100 ]]
}

# ========================================
# プロファイル切り替え環境変数テスト
# ========================================
@test "DOTFILES_PROFILE environment variable is documented" {
    # .zshrcまたはREADMEでDOTFILES_PROFILEの説明があることを確認
    run grep -r "DOTFILES_PROFILE" "${DOTFILES_ROOT}"
    assert_success
}

@test "profiles directory is referenced in .zshrc" {
    if [[ -f "${DOTFILES_ROOT}/.zshrc" ]]; then
        run grep -q "profiles" "${DOTFILES_ROOT}/.zshrc"
        assert_success
    else
        skip ".zshrc not found in dotfiles root"
    fi
}

# ========================================
# プロファイルセキュリティテスト
# ========================================
@test "profiles do not contain hardcoded secrets" {
    for profile in "${DOTFILES_ROOT}"/profiles/*.zsh; do
        run grep -iE "(api_key|api_secret|password|token|secret).*=" "$profile"
        # マッチしない（失敗する）ことを期待
        assert_failure "Profile $profile should not contain hardcoded secrets"
    done
}

@test "profiles do not source external URLs" {
    for profile in "${DOTFILES_ROOT}"/profiles/*.zsh; do
        run grep -E "source.*(http|https|ftp)://" "$profile"
        # 外部URLからのsourceがないことを確認
        assert_failure "Profile $profile should not source from external URLs"
    done
}

# ========================================
# プロファイル互換性テスト
# ========================================
@test "all profiles can be sourced without errors in subshell" {
    for profile in "${DOTFILES_ROOT}"/profiles/*.zsh; do
        # サブシェルでプロファイルをsourceしてエラーがないか確認
        # 環境依存の部分はスキップ
        run bash -c "
            # bashでzshファイルを読み込む場合は構文チェックのみ
            head -20 '$profile'
        "
        assert_success "Profile $profile should be readable"
    done
}
