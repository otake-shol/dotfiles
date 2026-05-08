#!/bin/bash
# Commit and push helper used by Codex and shell aliases.

set -euo pipefail

usage() {
    echo "Usage: codex-commit-push <commit message>" >&2
}

if [ "$#" -eq 0 ]; then
    usage
    exit 2
fi

message="$*"

git rev-parse --is-inside-work-tree >/dev/null
root=$(git rev-parse --show-toplevel)
cd "$root"

branch=$(git branch --show-current)
if [ -z "$branch" ]; then
    echo "Detached HEAD is not supported." >&2
    exit 1
fi

if [ -z "$(git status --porcelain)" ]; then
    echo "No changes to commit."
    exit 0
fi

if git status --porcelain | grep -E '(^.. |/)(\.env(\.|$)|.*credentials.*|.*\.key$)' >/dev/null; then
    echo "Refusing to commit possible secret files." >&2
    git status --porcelain
    exit 1
fi

echo "Branch: $branch"
echo ""
git status --short
echo ""
git diff --stat
echo ""

git add -A
git commit -m "$message"

if git rev-parse --abbrev-ref --symbolic-full-name '@{u}' >/dev/null 2>&1; then
    git push
else
    git push -u origin "$branch"
fi
