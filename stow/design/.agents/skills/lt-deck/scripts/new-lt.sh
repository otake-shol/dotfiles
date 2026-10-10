#!/bin/bash
# LT デッキの雛形を slides リポジトリに作る。
# 使い方: scripts/new-lt.sh <slug> "<題名>" ["<イベント名>"]
#   例: scripts/new-lt.sh statusline "statuslineの表示を充実させよう"
# 作るもの: slides/<年>-<slug>-lt/{deck.md,README.md,assets/photo.jpg}、package.json の build:<slug> スクリプト、ルート README の一覧の行
# 自己紹介は非公開のプロフィール（self-intro.md の lt-profile ブロック）から差し込む。公開リポジトリに個人情報を書かない。
set -euo pipefail

main() {
  if [[ $# -lt 2 ]]; then
    echo "usage: $0 <slug> <title> [event]" >&2
    exit 2
  fi
  local slug="$1" title="$2" event="${3:-Kagoshima | Claude Meetup}"
  local repo="${SLIDES_REPO:-$HOME/01_development/slides/repository}"
  local profile_dir="${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles-local/claude/slides"
  local name dir
  name="$(date +%Y)-${slug}-lt"
  dir="${repo}/slides/${name}"

  [[ -d "${repo}/slides" ]] || { echo "slides リポジトリが見つからない: ${repo}" >&2; exit 1; }
  [[ ! -e "${dir}" ]] || { echo "既に存在する: ${dir}" >&2; exit 1; }
  [[ -f "${profile_dir}/self-intro.md" ]] || { echo "プロフィールが見つからない: ${profile_dir}/self-intro.md" >&2; exit 1; }

  local profile presenter
  profile="$(awk '/<!-- lt-profile:start -->/{p=1;next} /<!-- lt-profile:end -->/{p=0} p' "${profile_dir}/self-intro.md")"
  [[ -n "${profile}" ]] || { echo "self-intro.md に lt-profile ブロックがない" >&2; exit 1; }
  presenter="$(printf '%s\n' "${profile}" | sed -n 's|.*<p class="name">\(.*\)</p>.*|\1|p' | head -1)"

  mkdir -p "${dir}/assets"
  cp "${profile_dir}/assets/photo.jpg" "${dir}/assets/photo.jpg"

  cat >"${dir}/deck.md" <<DECK
---
marp: true
theme: story-slides
lang: ja
paginate: true
size: 16:9
title: ${title}
description: 〈1文の説明〉
author: ${presenter%%（*}
---

<!-- _class: l01 event -->

<p class="event-line">${event}　<span class="date">〈YYYY-MM-DD〉</span></p>

# ${title}

<p class="subtitle">〈副題：何の話かを1行で〉</p>
<p class="presenter-name">${presenter}</p>

<!--
【T】
話す: 〈最初の一言〉
メモ: LT 10分。中心メッセージは「〈主張と、聞き手にとっての意味〉」。
メモ: 流れは〈章1〉→〈章2〉→〈章3〉→〈章4〉。
根拠: 〈数値の出典と集計日〉
-->

---

${profile}

---

<!-- 〈本編：章ごとにN01を付けて書く。lt-deck の SKILL.md の手順に従う〉 -->

---

<!-- _class: l18 event -->

<p class="event-line">${event}　<span class="date">〈YYYY-MM-DD〉</span></p>

# ご清聴<br>ありがとうございました

<!-- 【T】ありがとうございました。 -->
DECK

  cat >"${dir}/README.md" <<README
# ${title}

〈1〜2文の概要〉。${event} で発表予定（日付未定）。

自己紹介: full（R7: ミートアップで聞き手の大半が初対面）｜出典: 登壇者プロフィール

## 発表設計

- 中心メッセージ：〈〉
- 時間：10分・本編〈N〉枚（推定〈m:ss〉、ノート300字/分換算）。
- テーマ：story-slides。章の現在地（N01）：〈章1〉｜〈章2〉｜〈章3〉｜〈章4〉。
- 数値：〈出典・集計日〉
- 未定：表紙と終幕の発表日（\`〈YYYY-MM-DD〉\`のまま）。

## 構成

| 枚 | 見出し | 型 | Phase |
| --- | --- | --- | --- |

## 素材の出典

- 〈アイコン・ロゴ・スクショ・描画した出力の出典と条件〉

## 編集と再生成

\`\`\`bash
npm run build:${slug}
ovs deck check slides/${name}/deck.md --theme themes/story-slides.css
ovs deck lint slides/${name}/deck.md --minutes 10
\`\`\`

## 検証

〈日付、検査結果、目視したページ、意図的に残した指摘と理由〉
README

  # shellcheck disable=SC2016  # JS のテンプレート文字列なのでシェルでは展開しない
  (cd "${repo}" && SLUG="${slug}" NAME="${name}" TITLE="${title}" node -e '
const fs = require("fs");
const { SLUG, NAME, TITLE } = process.env;
const p = JSON.parse(fs.readFileSync("package.json", "utf8"));
const d = `slides/${NAME}`;
const marp = "marp --no-stdin --theme themes/story-slides.css --html --allow-local-files";
p.scripts[`build:${SLUG}`] = `npm run build:${SLUG}:html && npm run build:${SLUG}:pdf`;
p.scripts[`build:${SLUG}:html`] = `${marp} ${d}/deck.md -o ${d}/deck.html`;
p.scripts[`build:${SLUG}:pdf`] = `${marp} --pdf --pdf-outlines ${d}/deck.md -o ${d}/deck.pdf`;
fs.writeFileSync("package.json", JSON.stringify(p, null, 2) + "\n");
const readme = fs.readFileSync("README.md", "utf8").split("\n");
let last = -1;
readme.forEach((line, i) => { if (line.includes("](slides/") && line.startsWith("|")) last = i; });
const row = `| ${TITLE} | 10分LT（日付未定） | [原稿](${d}/deck.md)・[詳細](${d}/README.md) |`;
if (last >= 0) readme.splice(last + 1, 0, row);
fs.writeFileSync("README.md", readme.join("\n"));
')

  echo "作成: ${dir}"
  echo "次: deck.md の本編を書き、npm run build:${slug} と ovs deck check で確認する"
}

main "$@"
