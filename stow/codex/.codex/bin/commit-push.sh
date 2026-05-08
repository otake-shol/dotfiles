#!/bin/bash
# Commit and push helper used by Codex and shell aliases.

set -euo pipefail

usage() {
    echo "Usage: codex-commit-push <commit message> [file ...]" >&2
}

if [ "$#" -eq 0 ]; then
    usage
    exit 2
fi

message="$1"
shift
files=("$@")

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

has_secret_path() {
    grep -E '(^|/)(\.env(\.|$)|.*credentials.*|.*\.key$)' >/dev/null
}

if [ "${#files[@]}" -gt 0 ]; then
    if printf "%s\n" "${files[@]}" | has_secret_path; then
        echo "Refusing to commit possible secret files." >&2
        printf "%s\n" "${files[@]}" >&2
        exit 1
    fi
elif git status --porcelain | awk '{print $2}' | has_secret_path; then
    echo "Refusing to commit possible secret files." >&2
    git status --porcelain
    exit 1
fi

echo "Branch: $branch"
echo ""
git status --short
echo ""
if [ "${#files[@]}" -gt 0 ]; then
    git diff --stat -- "${files[@]}"
else
    git diff --stat
fi
echo ""

if [ "${#files[@]}" -gt 0 ]; then
    git diff --check -- "${files[@]}"
    git add -- "${files[@]}"
else
    git diff --check
    git add -A
fi

if git diff --cached --quiet; then
    echo "No staged changes to commit."
    exit 0
fi

if git diff --cached --name-only | has_secret_path; then
    echo "Refusing to commit possible secret files." >&2
    git diff --cached --name-only >&2
    exit 1
fi

echo "Staged changes:"
git diff --cached --stat
echo ""

git commit -m "$message"

if git rev-parse --abbrev-ref --symbolic-full-name '@{u}' >/dev/null 2>&1; then
    git push
else
    git push -u origin "$branch"
fi
