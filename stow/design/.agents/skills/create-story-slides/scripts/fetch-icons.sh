#!/bin/bash
# Lucide（ISC）から使うアイコンだけを取得し、Primary Blue に着色してデッキへ置く。
# 使い方: scripts/fetch-icons.sh <デッキの assets ディレクトリ> <アイコン名>...
#   例: scripts/fetch-icons.sh slides/my-talk/assets terminal package link
# 白抜き（濃色の面の上）に使う場合は ICON_COLOR=#FFFFFF を付けて別名で保存する。
set -euo pipefail

main() {
  if [[ $# -lt 2 ]]; then
    echo "usage: $0 <assets-dir> <icon-name>..." >&2
    exit 2
  fi
  local assets_dir="$1"
  shift
  local color="${ICON_COLOR:-#2C63B4}"
  WORK_DIR="$(mktemp -d)"
  trap 'rm -rf "${WORK_DIR:-}"' EXIT
  local work="${WORK_DIR}"

  (cd "${work}" && npm pack lucide-static --silent >/dev/null && tar xzf lucide-static-*.tgz)
  local version
  version="$(node -p "require('${work}/package/package.json').version")"

  mkdir -p "${assets_dir}/icons"
  local name src
  for name in "$@"; do
    src="${work}/package/icons/${name}.svg"
    if [[ ! -f "${src}" ]]; then
      echo "missing: ${name}（https://lucide.dev/icons で名前を確認）" >&2
      exit 1
    fi
    sed "s/stroke=\"currentColor\"/stroke=\"${color}\"/" "${src}" >"${assets_dir}/icons/${name}.svg"
  done
  echo "lucide-static ${version}（ISC）から $# 個を ${assets_dir}/icons に保存。README の素材の出典に版を記録する。"
}

main "$@"
