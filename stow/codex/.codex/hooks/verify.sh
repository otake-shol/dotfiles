#!/bin/bash
# Project verification helper for Codex.

set -euo pipefail

project_path="${1:-.}"
cd "$project_path"

errors=0

echo "=== verification start ==="

if [ -f "tsconfig.json" ]; then
    echo ""
    echo "TypeScript..."
    if [ -x "node_modules/.bin/tsc" ]; then
        ./node_modules/.bin/tsc --noEmit || ((errors++))
    elif command -v tsc >/dev/null 2>&1; then
        tsc --noEmit || ((errors++))
    else
        echo "  tsc not found, skipped"
    fi
fi

if [ -f "package.json" ]; then
    echo ""
    echo "Lint..."
    if grep -q '"lint"' package.json 2>/dev/null; then
        npm run lint || ((errors++))
    else
        echo "  lint script not found, skipped"
    fi

    echo ""
    echo "Test..."
    if grep -q '"test"' package.json 2>/dev/null; then
        npm test || ((errors++))
    else
        echo "  test script not found, skipped"
    fi
fi

if [ -f "Makefile" ] && grep -q '^lint:' Makefile 2>/dev/null; then
    echo ""
    echo "Make lint..."
    make lint || ((errors++))
fi

echo ""
echo "=== verification complete ==="
if [ "$errors" -eq 0 ]; then
    echo "pass"
    exit 0
fi

echo "$errors check(s) failed"
exit 1
