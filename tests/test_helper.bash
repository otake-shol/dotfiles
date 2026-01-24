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

# ========================================
# モック関数
# ========================================

# コマンドモック作成
mock_command() {
    local cmd="$1"
    local output="${2:-}"
    local exit_code="${3:-0}"

    eval "${cmd}() { echo '${output}'; return ${exit_code}; }"
    export -f "$cmd"
}

# コマンドモック削除
unmock_command() {
    local cmd="$1"
    unset -f "$cmd" 2>/dev/null || true
}

# ========================================
# 環境分離ヘルパー
# ========================================

# 隔離された環境でスクリプト実行
run_isolated() {
    local script="$1"
    shift
    (
        setup_temp_home
        bash "$script" "$@"
        local result=$?
        teardown_temp_home
        return $result
    )
}

# 環境変数のバックアップと復元
backup_env() {
    export _BACKUP_PATH="$PATH"
    export _BACKUP_HOME="$HOME"
}

restore_env() {
    export PATH="$_BACKUP_PATH"
    export HOME="$_BACKUP_HOME"
}

# ========================================
# アサーション拡張
# ========================================

# ファイルが特定の内容を含むことを確認
assert_file_contains() {
    local file="$1"
    local pattern="$2"
    if ! grep -q "$pattern" "$file" 2>/dev/null; then
        echo "File $file does not contain pattern: $pattern" >&2
        return 1
    fi
}

# ファイルが特定のパーミッションを持つことを確認
assert_file_permission() {
    local file="$1"
    local expected_perm="$2"
    local actual_perm
    actual_perm=$(stat -f "%Lp" "$file" 2>/dev/null || stat -c "%a" "$file" 2>/dev/null)
    if [[ "$actual_perm" != "$expected_perm" ]]; then
        echo "Permission mismatch for $file: expected $expected_perm, got $actual_perm" >&2
        return 1
    fi
}

# コマンドが存在することを確認
assert_command_exists() {
    local cmd="$1"
    if ! command -v "$cmd" &>/dev/null; then
        echo "Command not found: $cmd" >&2
        return 1
    fi
}

# ========================================
# スキップヘルパー
# ========================================

# macOS専用テストのスキップ
skip_if_not_macos() {
    if [[ "$(uname -s)" != "Darwin" ]]; then
        skip "This test requires macOS"
    fi
}

# Linux専用テストのスキップ
skip_if_not_linux() {
    if [[ "$(uname -s)" != "Linux" ]]; then
        skip "This test requires Linux"
    fi
}

# CI環境でのスキップ
skip_if_ci() {
    if [[ "${CI:-}" == "true" ]]; then
        skip "Skipping in CI environment"
    fi
}

# 特定コマンド不在時のスキップ
skip_if_no_command() {
    local cmd="$1"
    if ! command -v "$cmd" &>/dev/null; then
        skip "Command $cmd not available"
    fi
}
