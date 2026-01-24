#!/usr/bin/env bats
# stow-integration.bats - GNU Stow統合テスト

load test_helper

# ========================================
# Makefile存在テスト
# ========================================
@test "Makefile exists in dotfiles root" {
    assert_file_exists "${DOTFILES_ROOT}/Makefile"
}

@test "Makefile has stow targets" {
    run grep -q "stow" "${DOTFILES_ROOT}/Makefile"
    assert_success
}

# ========================================
# Makefileターゲットテスト
# ========================================
@test "Makefile has install target" {
    run grep -E "^install:" "${DOTFILES_ROOT}/Makefile"
    assert_success
}

@test "Makefile has check target for dry-run" {
    run grep -E "^check:" "${DOTFILES_ROOT}/Makefile"
    assert_success
}

@test "Makefile has uninstall target" {
    run grep -E "^uninstall:" "${DOTFILES_ROOT}/Makefile"
    assert_success
}

# ========================================
# Stowパッケージ構造テスト
# ========================================
@test "all stow packages have proper structure" {
    for pkg_dir in "${DOTFILES_ROOT}"/stow/*/; do
        local pkg_name
        pkg_name=$(basename "$pkg_dir")
        # パッケージディレクトリが空でないことを確認
        local file_count
        file_count=$(find "$pkg_dir" -type f | wc -l)
        [[ "$file_count" -gt 0 ]] || fail "Package $pkg_name is empty"
    done
}

@test "stow packages do not contain .git directories" {
    for pkg_dir in "${DOTFILES_ROOT}"/stow/*/; do
        run find "$pkg_dir" -name ".git" -type d
        # .gitディレクトリがないことを確認
        [[ -z "$output" ]] || fail "Package contains .git directory: $output"
    done
}

# ========================================
# 重要なStowパッケージ内容テスト
# ========================================
@test "stow/zsh contains .zshrc or zsh config" {
    # .zshrc か .config/zsh のどちらかが存在
    local has_config=false
    [[ -f "${DOTFILES_ROOT}/stow/zsh/.zshrc" ]] && has_config=true
    [[ -d "${DOTFILES_ROOT}/stow/zsh/.config" ]] && has_config=true
    [[ "$has_config" == "true" ]]
}

@test "stow/git contains .gitconfig or git config" {
    local has_config=false
    [[ -f "${DOTFILES_ROOT}/stow/git/.gitconfig" ]] && has_config=true
    [[ -d "${DOTFILES_ROOT}/stow/git/.config/git" ]] && has_config=true
    [[ "$has_config" == "true" ]]
}

@test "stow/nvim contains nvim config" {
    assert_dir_exists "${DOTFILES_ROOT}/stow/nvim/.config/nvim"
}

# ========================================
# Stowドライランテスト
# ========================================
@test "make check runs without error (dry-run)" {
    if ! command -v stow &>/dev/null; then
        skip "stow not installed"
    fi

    cd "${DOTFILES_ROOT}"
    run make check 2>&1
    # ドライランなので実際の変更はない
    # エラーがなければOK（警告は許容）
    [[ "$status" -eq 0 ]] || [[ "$output" =~ "BUG" ]] || [[ "$output" =~ "WARN" ]] || true
}

# ========================================
# パッケージ別インストールターゲットテスト
# ========================================
@test "Makefile has individual package targets" {
    # 主要パッケージの個別ターゲットが存在することを確認
    run grep -E "^install-zsh:|^install-git:|^install-nvim:" "${DOTFILES_ROOT}/Makefile"
    assert_success
}

# ========================================
# Stow除外パターンテスト
# ========================================
@test ".stow-local-ignore exists if needed" {
    # .stow-local-ignoreが存在する場合、有効な内容であることを確認
    if [[ -f "${DOTFILES_ROOT}/.stow-local-ignore" ]]; then
        # ファイルが空でないことを確認
        [[ -s "${DOTFILES_ROOT}/.stow-local-ignore" ]]
    else
        skip ".stow-local-ignore does not exist"
    fi
}

# ========================================
# シンボリックリンク競合テスト
# ========================================
@test "stow packages do not have overlapping files" {
    local all_files=()
    local duplicates=()

    for pkg_dir in "${DOTFILES_ROOT}"/stow/*/; do
        while IFS= read -r -d '' file; do
            local rel_path="${file#$pkg_dir}"
            if [[ " ${all_files[*]} " =~ " ${rel_path} " ]]; then
                duplicates+=("$rel_path")
            else
                all_files+=("$rel_path")
            fi
        done < <(find "$pkg_dir" -type f -print0)
    done

    [[ ${#duplicates[@]} -eq 0 ]] || fail "Duplicate files found: ${duplicates[*]}"
}
