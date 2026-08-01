#!/bin/bash

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_DIR="$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-bootstrap-test.XXXXXX")"
TEST_HOME="$TEST_DIR/home"
FAKE_BIN="$TEST_DIR/bin"
STOW_TEST_LOG="$TEST_DIR/stow.log"
BOOTSTRAP_LOG="$TEST_DIR/bootstrap.log"

cleanup() {
    rm -r -- "$TEST_DIR"
}
trap cleanup EXIT

make_executable() {
    local path="$1"
    shift
    printf '%s\n' "$@" > "$path"
    chmod +x "$path"
}

fail() {
    echo "✗ $*" >&2
    exit 1
}

mkdir -p "$TEST_HOME" "$FAKE_BIN"
: > "$TEST_HOME/.dotfiles-macos-defaults-applied"
: > "$STOW_TEST_LOG"

make_executable "$FAKE_BIN/uname" \
    '#!/bin/bash' \
    'if [ "${1:-}" = "-m" ]; then printf "arm64\n"; else printf "Darwin\n"; fi'

make_executable "$FAKE_BIN/brew" \
    '#!/bin/bash' \
    'exit 0'

make_executable "$FAKE_BIN/make" \
    '#!/bin/bash' \
    'printf "zsh\n"'

make_executable "$FAKE_BIN/stow" \
    '#!/bin/bash' \
    'set -euo pipefail' \
    'printf "%s\n" "$*" >> "${STOW_TEST_LOG:?}"' \
    'case " $* " in *" --adopt "*) exit 0 ;; *) exit 1 ;; esac'

run_bootstrap() {
    CI=true \
        HOME="$TEST_HOME" \
        PATH="$FAKE_BIN:/usr/bin:/bin" \
        STOW_TEST_LOG="$STOW_TEST_LOG" \
        /bin/bash "$REPO_DIR/bootstrap.sh" --skip-apps --no-codex-desktop "$@" \
        > "$BOOTSTRAP_LOG" 2>&1
}

if run_bootstrap -y; then
    fail "-yだけでStow競合が成功扱いになりました"
fi
grep -q -- ' --adopt ' "$STOW_TEST_LOG" && fail "-yだけで--adoptが実行されました"

: > "$STOW_TEST_LOG"
run_bootstrap -y --adopt-conflicts || fail "明示opt-in付きの-yで--adoptできませんでした"
grep -q -- ' --adopt ' "$STOW_TEST_LOG" || fail "明示opt-in時に--adoptが実行されませんでした"

: > "$STOW_TEST_LOG"
if printf 'n\n' | run_bootstrap --adopt-conflicts; then
    fail "対話で拒否したStow競合が成功扱いになりました"
fi
grep -q -- ' --adopt ' "$STOW_TEST_LOG" && fail "対話で拒否したのに--adoptが実行されました"

: > "$STOW_TEST_LOG"
printf 'y\n' | run_bootstrap --adopt-conflicts || fail "対話で許可した--adoptが失敗しました"
grep -q -- ' --adopt ' "$STOW_TEST_LOG" || fail "対話で許可したのに--adoptが実行されませんでした"

echo "✓ bootstrap Stow safety"
