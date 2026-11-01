#!/bin/bash
# Claude研修キットの雛形を slides リポジトリに作る。
# 使い方:
#   scripts/new-claude-training.sh <slug> "<題名>" [--minutes 60] [--subtitle "<副題>"]
#   scripts/new-claude-training.sh <slug> "<題名>" --from slides/2026-claude-first-step-lt
#     例: scripts/new-claude-training.sh claude-work-basics "Claudeを仕事の<br>相棒にしよう" --minutes 90
# 作るもの: slides/<年>-<slug>/{training.md,worksheet.md,facilitator-guide.md,README.md,assets/icons}、
#   package.json の build:<slug> スクリプト、ルート README の一覧の行
# --from は既存キットの原稿と素材を複製する（ビルド済みの PDF・HTML は複製しない）。
# 自己紹介は空欄のまま作る。公開リポジトリ（dotfiles）に個人情報を書かない。
set -euo pipefail

usage() {
  echo "usage: $0 <slug> <title> [--minutes N] [--subtitle TEXT] [--from DIR]" >&2
  exit 2
}

main() {
  [[ $# -ge 2 ]] || usage
  local slug="$1" title="$2"
  shift 2
  local minutes=60 subtitle="" from=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --minutes) minutes="${2:?}"; shift 2 ;;
      --subtitle) subtitle="${2:?}"; shift 2 ;;
      --from) from="${2:?}"; shift 2 ;;
      *) usage ;;
    esac
  done

  local skill_dir repo name dir title_plain
  skill_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  repo="${SLIDES_REPO:-$HOME/01_development/slides/repository}"
  name="$(date +%Y)-${slug}"
  dir="slides/${name}"
  title_plain="${title//<br>/}"
  [[ -n "${subtitle}" ]] || subtitle="Claudeハンズオン（${minutes}分）"

  [[ -d "${repo}/slides" ]] || { echo "slides リポジトリが見つからない: ${repo}" >&2; exit 1; }
  [[ ! -e "${repo}/${dir}" ]] || { echo "既に存在する: ${repo}/${dir}" >&2; exit 1; }
  for theme in story-slides.css story-slides-warm.css; do
    [[ -f "${repo}/themes/${theme}" ]] || { echo "テーマがない: ${repo}/themes/${theme}" >&2; exit 1; }
  done

  if [[ -n "${from}" ]]; then
    local src="${repo}/${from}"
    [[ -f "${src}/training.md" ]] || { echo "複製元に training.md がない: ${src}" >&2; exit 1; }
    mkdir -p "${repo}/${dir}"
    local f
    for f in training.md worksheet.md facilitator-guide.md deck.md README.md; do
      [[ -f "${src}/${f}" ]] && cp "${src}/${f}" "${repo}/${dir}/${f}"
    done
    [[ -d "${src}/assets" ]] && cp -R "${src}/assets" "${repo}/${dir}/assets"
  else
    mkdir -p "${repo}/${dir}/assets"
    local f
    for f in training.md worksheet.md facilitator-guide.md README.md; do
      TITLE="${title}" TITLE_PLAIN="${title_plain}" SUBTITLE="${subtitle}" MINUTES="${minutes}" \
        SLUG="${slug}" DIR="${dir}" python3 - "${skill_dir}/assets/templates/${f}" "${repo}/${dir}/${f}" <<'PY'
import os, sys
src, dst = sys.argv[1], sys.argv[2]
text = open(src, encoding="utf-8").read()
for key in ("TITLE_PLAIN", "TITLE", "SUBTITLE", "MINUTES", "SLUG", "DIR"):
    text = text.replace("{{" + key + "}}", os.environ[key])
open(dst, "w", encoding="utf-8").write(text)
PY
    done
    ICON_COLOR='#B0502C' "${HOME}/.agents/skills/create-story-slides/scripts/fetch-icons.sh" \
      "${repo}/${dir}/assets" compass log-in shield-check circle-check shield-alert
  fi

  # shellcheck disable=SC2016  # JS のテンプレート文字列なのでシェルでは展開しない
  (cd "${repo}" && SLUG="${slug}" DIR="${dir}" TITLE="${title_plain}" MINUTES="${minutes}" node -e '
const fs = require("fs");
const { SLUG, DIR, TITLE, MINUTES } = process.env;
const p = JSON.parse(fs.readFileSync("package.json", "utf8"));
const marp = "marp --no-stdin --theme-set themes --theme themes/story-slides-warm.css --html --allow-local-files";
const steps = [
  `${marp} ${DIR}/training.md -o ${DIR}/training.html`,
  `${marp} --pdf --pdf-outlines ${DIR}/training.md -o ${DIR}/training.pdf`,
  `${marp} --pdf ${DIR}/worksheet.md -o ${DIR}/worksheet.pdf`,
];
if (fs.existsSync(`${DIR}/deck.md`)) {
  steps.push(`${marp} ${DIR}/deck.md -o ${DIR}/deck.html`, `${marp} --pdf --pdf-outlines ${DIR}/deck.md -o ${DIR}/deck.pdf`);
}
p.scripts[`build:${SLUG}`] = steps.join(" && ");
fs.writeFileSync("package.json", JSON.stringify(p, null, 2) + "\n");
const readme = fs.readFileSync("README.md", "utf8").split("\n");
let last = -1;
readme.forEach((line, i) => { if (line.includes("](slides/") && line.startsWith("|")) last = i; });
const row = `| ${TITLE} | ${MINUTES}分ハンズオン研修キット（日付未定） | [研修](${DIR}/training.md)・[講師ガイド](${DIR}/facilitator-guide.md)・[詳細](${DIR}/README.md) |`;
if (last >= 0) readme.splice(last + 1, 0, row);
fs.writeFileSync("README.md", readme.join("\n"));
')

  echo "作成: ${repo}/${dir}"
  if [[ -n "${from}" ]]; then
    echo "次: 題名・副題・README・講師ガイドを新しいキットに合わせて書き換え、facts.md の項目を確かめ直す"
  else
    echo "次: 〈〉を埋め、npm run build:${slug} と ovs deck check で確認する"
  fi
}

main "$@"
