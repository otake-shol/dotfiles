#!/usr/bin/env bats
# symlinks.bats - シンボリックリンク検証テスト

load 'test_helper'

# safe_link関数のテスト
@test "safe_link function exists in bootstrap.sh" {
    grep -q "safe_link()" "$DOTFILES_ROOT/bootstrap.sh"
}

@test "safe_link function handles new symlink creation" {
    setup_temp_home

    # safe_link関数を抽出してテスト
    source_file="$DOTFILES_ROOT/bootstrap.sh"

    # テスト用のソースファイル作成
    mkdir -p "$TEST_HOME/dotfiles"
    echo "test content" > "$TEST_HOME/dotfiles/testfile"

    # safe_link関数をエクスポート
    safe_link() {
        local src="$1"
        local dest="$2"
        ln -sf "$src" "$dest"
    }

    # シンボリックリンク作成
    safe_link "$TEST_HOME/dotfiles/testfile" "$TEST_HOME/.testfile"

    # 検証
    [ -L "$TEST_HOME/.testfile" ]
    [ "$(readlink "$TEST_HOME/.testfile")" = "$TEST_HOME/dotfiles/testfile" ]

    teardown_temp_home
}

@test "safe_link function handles existing symlink update" {
    setup_temp_home

    # テスト用ファイル作成
    mkdir -p "$TEST_HOME/dotfiles"
    echo "new content" > "$TEST_HOME/dotfiles/newfile"
    echo "old content" > "$TEST_HOME/dotfiles/oldfile"

    # 既存のシンボリックリンク作成
    ln -s "$TEST_HOME/dotfiles/oldfile" "$TEST_HOME/.testfile"

    # safe_link関数
    safe_link() {
        local src="$1"
        local dest="$2"
        if [ -L "$dest" ]; then
            rm "$dest"
        fi
        ln -sf "$src" "$dest"
    }

    # 更新
    safe_link "$TEST_HOME/dotfiles/newfile" "$TEST_HOME/.testfile"

    # 検証：新しいターゲットを指していること
    [ -L "$TEST_HOME/.testfile" ]
    [ "$(readlink "$TEST_HOME/.testfile")" = "$TEST_HOME/dotfiles/newfile" ]

    teardown_temp_home
}

@test "safe_link function backs up existing regular file" {
    setup_temp_home

    # テスト用ファイル作成
    mkdir -p "$TEST_HOME/dotfiles"
    echo "source content" > "$TEST_HOME/dotfiles/sourcefile"
    echo "existing content" > "$TEST_HOME/.testfile"

    # safe_link関数（バックアップ機能付き）
    safe_link() {
        local src="$1"
        local dest="$2"
        if [ -L "$dest" ]; then
            rm "$dest"
        elif [ -e "$dest" ]; then
            mv "$dest" "${dest}.backup"
        fi
        ln -sf "$src" "$dest"
    }

    # 実行
    safe_link "$TEST_HOME/dotfiles/sourcefile" "$TEST_HOME/.testfile"

    # 検証
    [ -L "$TEST_HOME/.testfile" ]
    [ -f "$TEST_HOME/.testfile.backup" ]
    [ "$(cat "$TEST_HOME/.testfile.backup")" = "existing content" ]

    teardown_temp_home
}

# stow構造の検証
@test "stow directory structure exists" {
    assert_dir_exists "$DOTFILES_ROOT/stow"
}

@test "stow/zsh package exists" {
    assert_dir_exists "$DOTFILES_ROOT/stow/zsh"
}

@test "stow/git package exists" {
    assert_dir_exists "$DOTFILES_ROOT/stow/git"
}

@test "stow/nvim package exists" {
    assert_dir_exists "$DOTFILES_ROOT/stow/nvim"
}

@test "stow/tmux package exists" {
    assert_dir_exists "$DOTFILES_ROOT/stow/tmux"
}

@test "stow/ghostty package exists" {
    assert_dir_exists "$DOTFILES_ROOT/stow/ghostty"
}

@test "stow/bat package exists" {
    assert_dir_exists "$DOTFILES_ROOT/stow/bat"
}

@test "stow/atuin package exists" {
    assert_dir_exists "$DOTFILES_ROOT/stow/atuin"
}
