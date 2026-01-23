#!/usr/bin/env bash
# test_helper.bash - テストヘルパー関数

# bats-support と bats-assert のロード
# ローカルインストール または システムインストール
if [[ -d "${BATS_TEST_DIRNAME}/../node_modules/bats-support" ]]; then
    load "${BATS_TEST_DIRNAME}/../node_modules/bats-support/load"
    load "${BATS_TEST_DIRNAME}/../node_modules/bats-assert/load"
elif [[ -d "/usr/local/lib/bats-support" ]]; then
    load "/usr/local/lib/bats-support/load"
    load "/usr/local/lib/bats-assert/load"
fi

# プロジェクトルート
export DOTFILES_ROOT="${BATS_TEST_DIRNAME}/.."

# テスト用一時ディレクトリ
setup_temp_home() {
    export TEST_HOME=$(mktemp -d)
    export ORIGINAL_HOME="$HOME"
    export HOME="$TEST_HOME"
}

teardown_temp_home() {
    export HOME="$ORIGINAL_HOME"
    rm -rf "$TEST_HOME"
}

# ファイル存在チェック
assert_file_exists() {
    local file="$1"
    if [[ ! -f "$file" ]]; then
        echo "File does not exist: $file" >&2
        return 1
    fi
}

# ディレクトリ存在チェック
assert_dir_exists() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        echo "Directory does not exist: $dir" >&2
        return 1
    fi
}

# シンボリックリンクチェック
assert_symlink() {
    local link="$1"
    local target="$2"

    if [[ ! -L "$link" ]]; then
        echo "Not a symlink: $link" >&2
        return 1
    fi

    local actual_target=$(readlink "$link")
    if [[ "$actual_target" != "$target" ]]; then
        echo "Symlink target mismatch: expected $target, got $actual_target" >&2
        return 1
    fi
}
