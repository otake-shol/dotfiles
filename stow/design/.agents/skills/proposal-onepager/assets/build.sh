#!/bin/bash
# A4 1枚の提案資料を Markdown から PDF に変換する。
# 使い方: build.sh <入力.md> [出力.pdf]
#   出力を省略すると、入力と同じ場所に同じ名前の .pdf を作る。
# 必要なもの: pandoc、Google Chrome（任意で pdfinfo：ページ数の確認に使う）
set -euo pipefail

main() {
  local dir in out tmp chrome pages
  dir="$(cd "$(dirname "$0")" && pwd)"
  in="${1:?入力の Markdown を指定してください}"
  out="${2:-${in%.md}.pdf}"
  chrome="${CHROME:-/Applications/Google Chrome.app/Contents/MacOS/Google Chrome}"
  tmp="$(mktemp -d)"
  # shellcheck disable=SC2064  # tmp を設定時点で展開する
  trap "rm -rf '$tmp'" EXIT

  pandoc "$in" -f markdown -t html5 --standalone \
    --template="$dir/template.html" -o "$tmp/page.html"
  # 起動中の Chrome とプロファイルが競合して止まらないよう、使い捨てのプロファイルを使う
  "$chrome" --headless=new --disable-gpu --no-pdf-header-footer \
    --user-data-dir="$tmp/profile" --no-first-run \
    --print-to-pdf="$out" "file://$tmp/page.html" 2>/dev/null

  if command -v pdfinfo >/dev/null; then
    pages="$(pdfinfo "$out" | awk '/^Pages:/ {print $2}')"
    if [ "$pages" != "1" ]; then
      echo "警告: ${pages} ページになりました。文章を短くしてください。" >&2
    fi
  fi
  echo "$out"
}

main "$@"
