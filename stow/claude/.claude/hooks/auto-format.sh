#!/bin/bash
# PostToolUse Hook: ファイル編集後に自動フォーマット
#
# 入力JSON例:
# {
#   "tool_name": "Edit",
#   "tool_input": { "file_path": "/path/to/file.ts", ... },
#   "tool_response": "..."
# }

set -euo pipefail

input=$(cat)

# ファイルパスを取得
file_path=$(echo "$input" | jq -r '.tool_input.file_path // ""')

# ファイルパスがなければ終了
if [ -z "$file_path" ] || [ ! -f "$file_path" ]; then
    exit 0
fi

# 拡張子を取得
ext="${file_path##*.}"

# プロジェクトルートを探す（package.json があるディレクトリ）
find_project_root() {
    local dir="$1"
    while [ "$dir" != "/" ]; do
        if [ -f "$dir/package.json" ]; then
            echo "$dir"
            return 0
        fi
        dir=$(dirname "$dir")
    done
    return 1
}

project_root=$(find_project_root "$(dirname "$file_path")" 2>/dev/null || echo "")

# Prettierでフォーマット（対応拡張子のみ）
case "$ext" in
    js|jsx|ts|tsx|json|md|css|scss|html|yaml|yml)
        if [ -n "$project_root" ] && [ -f "$project_root/node_modules/.bin/prettier" ]; then
            # プロジェクトのPrettierを使用
            "$project_root/node_modules/.bin/prettier" --write "$file_path" 2>/dev/null || true
        elif command -v prettier &>/dev/null; then
            # グローバルPrettierを使用
            prettier --write "$file_path" 2>/dev/null || true
        fi
        # ESLint --fix（Prettier適用後、JS/TS系のみ）
        case "$ext" in
            js|jsx|ts|tsx)
                if [ -n "$project_root" ] && [ -f "$project_root/node_modules/.bin/eslint" ]; then
                    "$project_root/node_modules/.bin/eslint" --fix "$file_path" 2>/dev/null || true
                fi
                ;;
        esac
        ;;
    sh|bash)
        # シェルスクリプトはshfmtでフォーマット（あれば）
        if command -v shfmt &>/dev/null; then
            shfmt -w "$file_path" 2>/dev/null || true
        fi
        ;;
esac

exit 0
