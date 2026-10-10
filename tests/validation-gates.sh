#!/bin/bash

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_DIR="$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-validation-gates.XXXXXX")"

cleanup() {
    python3 -c 'import shutil, sys; shutil.rmtree(sys.argv[1])' "$TEST_DIR"
}
trap cleanup EXIT

expect_failure() {
    local label="$1"
    shift
    if "$@" >/dev/null 2>&1; then
        echo "✗ $label: invalid input was accepted" >&2
        exit 1
    fi
}

printf 'export const value = 1;\n' > "$TEST_DIR/valid.mjs"
printf 'export const = ;\n' > "$TEST_DIR/invalid.mjs"

make -s -C "$REPO_DIR" lint-node-syntax CODEX_MJS_FILES="$TEST_DIR/valid.mjs"
expect_failure "lint-node-syntax checks every file" \
    make -s -C "$REPO_DIR" lint-node-syntax \
    CODEX_MJS_FILES="$TEST_DIR/valid.mjs $TEST_DIR/invalid.mjs"
expect_failure "validate-node-syntax checks every file" \
    make -s -C "$REPO_DIR" validate-node-syntax \
    NODE_SYNTAX_FILES="$TEST_DIR/valid.mjs $TEST_DIR/invalid.mjs"

# A clean install target must pass; a pre-existing file must stop Stow.
mkdir "$TEST_DIR/stow-home"
make -s -C "$REPO_DIR" check-conflicts PACKAGES=git HOME="$TEST_DIR/stow-home"
touch "$TEST_DIR/stow-home/.gitconfig"
expect_failure "check-conflicts rejects an existing target" \
    make -s -C "$REPO_DIR" check-conflicts PACKAGES=git HOME="$TEST_DIR/stow-home"

VISUAL_DIR="$TEST_DIR/visual-system"
FIND_BIN_DIR="$TEST_DIR/bin"
mkdir -p "$VISUAL_DIR/generated/templates" "$VISUAL_DIR/examples" "$FIND_BIN_DIR"
printf '{"valid": true}\n' > "$VISUAL_DIR/valid.json"
printf '#!/bin/bash\nset -euo pipefail\nwhile IFS= read -r file; do printf "%%s\\0" "$file"; done <<< "${VALIDATION_GATE_FIND_FILES:?}"\n' > "$FIND_BIN_DIR/find"
chmod +x "$FIND_BIN_DIR/find"
make -s -C "$REPO_DIR" design-json-check VISUAL_SYSTEM_DIR="$VISUAL_DIR"
printf '{ invalid json\n' > "$VISUAL_DIR/invalid.json"
expect_failure "design-json-check propagates an early loop failure" \
    env PATH="$FIND_BIN_DIR:$PATH" \
    VALIDATION_GATE_FIND_FILES="$VISUAL_DIR/invalid.json
$VISUAL_DIR/valid.json" \
    make -s -C "$REPO_DIR" design-json-check VISUAL_SYSTEM_DIR="$VISUAL_DIR"
expect_failure "design-json-check rejects a missing directory" \
    make -s -C "$REPO_DIR" design-json-check VISUAL_SYSTEM_DIR="$TEST_DIR/missing"

printf '<svg xmlns="http://www.w3.org/2000/svg" width="1" height="1"><rect width="1" height="1"/></svg>\n' > "$VISUAL_DIR/generated/templates/valid.svg"
if command -v xmllint >/dev/null 2>&1; then
    make -s -C "$REPO_DIR" design-svg-check VISUAL_SYSTEM_DIR="$VISUAL_DIR"
    printf '<svg><broken></svg>\n' > "$VISUAL_DIR/generated/templates/invalid.svg"
    expect_failure "design-svg-check propagates an early loop failure" \
        env PATH="$FIND_BIN_DIR:$PATH" \
        VALIDATION_GATE_FIND_FILES="$VISUAL_DIR/generated/templates/invalid.svg
$VISUAL_DIR/generated/templates/valid.svg" \
        make -s -C "$REPO_DIR" design-svg-check VISUAL_SYSTEM_DIR="$VISUAL_DIR"
fi
if command -v rsvg-convert >/dev/null 2>&1; then
    [ ! -e "$VISUAL_DIR/generated/templates/invalid.svg" ] || rm "$VISUAL_DIR/generated/templates/invalid.svg"
    make -s -C "$REPO_DIR" design-render-check VISUAL_SYSTEM_DIR="$VISUAL_DIR"
    printf '<svg><broken></svg>\n' > "$VISUAL_DIR/generated/templates/invalid.svg"
    expect_failure "design-render-check propagates an early loop failure" \
        env PATH="$FIND_BIN_DIR:$PATH" \
        VALIDATION_GATE_FIND_FILES="$VISUAL_DIR/generated/templates/invalid.svg
$VISUAL_DIR/generated/templates/valid.svg" \
        make -s -C "$REPO_DIR" design-render-check VISUAL_SYSTEM_DIR="$VISUAL_DIR"
fi

printf '/* @theme fixture */\n' > "$VISUAL_DIR/generated/marp.css"
printf '# Fixture\n' > "$VISUAL_DIR/examples/slide.md"
printf '#!/bin/bash\nexit 23\n' > "$TEST_DIR/failing-marp"
chmod +x "$TEST_DIR/failing-marp"
make -s -C "$REPO_DIR" design-marp-check VISUAL_SYSTEM_DIR="$VISUAL_DIR"
expect_failure "design-marp-check propagates Marp failure" \
    make -s -C "$REPO_DIR" design-marp-check VISUAL_SYSTEM_DIR="$VISUAL_DIR" MARP_BIN="$TEST_DIR/failing-marp"

echo "✓ validation gates"
