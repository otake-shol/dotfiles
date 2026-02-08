#!/bin/bash
# 検証フック: 型チェック + Lint + テストを一括実行
#
# 使い方:
#   ~/.claude/hooks/verify.sh [project_path]
#
# 引数なしの場合はカレントディレクトリで実行

set -euo pipefail

project_path="${1:-.}"
cd "$project_path"

echo "=== 検証ループ開始 ==="

# 結果追跡
errors=0

# 1. 型チェック
echo ""
echo "📝 型チェック..."
if [ -f "tsconfig.json" ]; then
    if [ -f "node_modules/.bin/tsc" ]; then
        ./node_modules/.bin/tsc --noEmit || ((errors++))
    elif command -v tsc &>/dev/null; then
        tsc --noEmit || ((errors++))
    else
        echo "  ⚠️ TypeScript未インストール"
    fi
else
    echo "  ⏭️ tsconfig.jsonなし、スキップ"
fi

# 2. Lint
echo ""
echo "🔍 Lint..."
if [ -f "package.json" ]; then
    if grep -q '"lint"' package.json 2>/dev/null; then
        npm run lint || ((errors++))
    elif [ -f "node_modules/.bin/eslint" ]; then
        ./node_modules/.bin/eslint . --ext .js,.jsx,.ts,.tsx || ((errors++))
    else
        echo "  ⏭️ ESLint未設定、スキップ"
    fi
else
    echo "  ⏭️ package.jsonなし、スキップ"
fi

# 3. テスト
echo ""
echo "🧪 テスト..."
if [ -f "package.json" ]; then
    if grep -q '"test"' package.json 2>/dev/null; then
        npm test || ((errors++))
    else
        echo "  ⏭️ testスクリプトなし、スキップ"
    fi
else
    echo "  ⏭️ package.jsonなし、スキップ"
fi

# 結果サマリー
echo ""
echo "=== 検証完了 ==="
if [ $errors -eq 0 ]; then
    echo "✅ すべてのチェックをパス"
    exit 0
else
    echo "❌ $errors 個のエラーが発生"
    exit 1
fi
