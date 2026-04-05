#!/bin/bash
# op-env: 1Password CLIでシークレットを注入してコマンドを起動
#
# 使い方:
#   op-env claude          # Claude Codeをシークレット付きで起動
#   op-env npm run dev     # 任意のコマンドに注入可能
#
# テンプレート: ~/.claude/.env.tpl
#   OPENAI_API_KEY=op://vault/item/field
#   SOME_SECRET=op://vault/item/field
#
# exec でプロセスを置換するため、TTY が維持される（Claude Code対応）

set -euo pipefail

TPL="${OP_ENV_TPL:-${HOME}/.claude/.env.tpl}"

if [[ ! -f "$TPL" ]]; then
    echo "op-env: テンプレートが見つかりません: $TPL" >&2
    echo "op-env: ~/.claude/.env.tpl を作成してください" >&2
    echo "op-env: フォーマット: KEY=op://vault/item/field" >&2
    exec "$@"
fi

if ! command -v op &>/dev/null; then
    echo "op-env: 1Password CLI (op) が見つかりません" >&2
    exec "$@"
fi

# テンプレートからキー名を抽出
KEYS=$(grep -v '^#' "$TPL" | grep -v '^$' | cut -d= -f1 | tr '\n' '|' | sed 's/|$//')

if [[ -z "$KEYS" ]]; then
    exec "$@"
fi

# 1Password APIを1回だけ呼び出し、全シークレットを一括解決
while IFS='=' read -r key value; do
    export "$key=$value"
done < <(op run --no-masking --env-file "$TPL" -- env 2>/dev/null | grep -E "^($KEYS)=")

# プロセス置換でTTYを維持したまま起動
exec "$@"
