import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { mkdtempSync, rmSync, writeFileSync, existsSync } from "node:fs";
import { tmpdir } from "node:os";
import { resolve } from "node:path";
import test from "node:test";
import { browserExecutable } from "../scripts/browser.mjs";
import { rootDir } from "../scripts/core.mjs";
import {
  BODY_CHARS,
  MAX_BULLETS,
  SPEAKING_CHARS_PER_MINUTE,
  deckRules,
  displayWidth,
  estimateSeconds,
  lintDeck,
  outlineDeck,
  parseDeck,
  parseDirectiveComment,
  spokenNotes,
} from "../scripts/deck.mjs";

const cli = resolve(rootDir, "scripts", "ovs.mjs");

function deckOf(slides, frontMatter = "marp: true\ntheme: otake-visual\nlang: ja\npaginate: true") {
  return `---\n${frontMatter}\n---\n\n${slides.join("\n\n---\n\n")}\n`;
}

function rulesOf(markdown, options) {
  return lintDeck(parseDeck(markdown), options).issues.map((entry) => entry.rule);
}

const cleanDeck = deckOf([
  `<!-- _class: lead -->
<!-- _paginate: false -->

# 問い合わせ対応の属人化

一次回答の待ち時間を半分にする提案

<div class="meta">

**竹内 尊紀**
社内勉強会・2026-10-30

</div>

<!-- メモ: 5分。結論は手順書と当番制 -->`,
  `<!-- _footer: '出典: サポート窓口の対応記録（2026-04〜09）' -->

# 一次回答まで平均26時間の待ち

- 担当者の不在時に回答が止まる
- 手順が個人のメモにしかない
- 同じ質問に毎回調べ直す

<!--
話す: 待ち時間の原因は人ではなく仕組み。
つなぎ: では何を変えればよいか。
根拠: 対応記録 412件の平均 https://example.com/report
-->`,
  `<!-- _class: invert -->

# 手順書と当番制で待ちを半減

- 手順書を共有の場所へ
- 当番を週替わりで決める

<!-- 話す: 来週から当番表を試す。決めてほしいのは試行の承認だけ。 -->`,
]);

test("Marp Markdownをスライド単位に分け、ディレクティブとノートを分離する", () => {
  const deck = parseDeck(cleanDeck);
  assert.equal(deck.frontMatter.lang, "ja");
  assert.equal(deck.slides.length, 3);
  const [cover, problem, closing] = deck.slides;
  assert.equal(cover.className, "lead");
  assert.equal(cover.paginate, false);
  assert.equal(cover.title, "問い合わせ対応の属人化");
  assert.equal(problem.footer, "出典: サポート窓口の対応記録（2026-04〜09）");
  assert.equal(problem.listItems.length, 3);
  assert.match(problem.notes, /話す: 待ち時間/);
  assert.equal(closing.className, "invert");
  assert.equal(problem.startLine, 25);
});

test("下線なしのディレクティブ（class:）は後続スライドにも引き継ぐ", () => {
  const deck = parseDeck(deckOf(["<!-- class: invert -->\n\n# 引き継ぐ見出し", "# 次の見出し", "<!-- _class: lead -->\n\n# 一枚だけ上書き", "# 元に戻る見出し"]));
  assert.deepEqual(
    deck.slides.map((slide) => slide.className),
    ["invert", "invert", "lead", "invert"],
  );
});

test("コードブロックとHTMLコメント内の --- ではスライドを分けない", () => {
  const deck = parseDeck(
    deckOf([
      "# コードを含む見出し\n\n```yaml\n---\nkey: value\n---\n```",
      "# ノートを含む見出し\n\n<!--\n説明\n\n---\n\n続き\n-->",
    ]),
  );
  assert.equal(deck.slides.length, 2);
  assert.match(deck.slides[1].notes, /続き/);
});

test("ディレクティブとノートを区別する", () => {
  assert.deepEqual(parseDirectiveComment(" _class: lead "), { _class: "lead" });
  assert.deepEqual(parseDirectiveComment("_footer: '出典: A'\n_paginate: false"), {
    _footer: "出典: A",
    _paginate: false,
  });
  assert.equal(parseDirectiveComment("出典: 公式ドキュメント"), null);
  assert.equal(parseDirectiveComment("ここは発表者ノート"), null);
});

test("話さない行（根拠・メモ・URL）を時間の換算から外す", () => {
  const notes = "話す: これは話す\n根拠: 412件\nメモ: 間を取る\n参照 https://example.com\nつなぎ: 次へ";
  assert.equal(spokenNotes(notes), "話す: これは話す\nつなぎ: 次へ");
  const slide = { notesChars: SPEAKING_CHARS_PER_MINUTE };
  assert.equal(estimateSeconds(slide), 60);
});

test("全角1・半角0.5で表示幅を数える", () => {
  assert.equal(displayWidth("日本語"), 3);
  assert.equal(displayWidth("max"), 1.5);
  assert.equal(displayWidth("Opus 5.5の既定"), 7);
});

test("整ったデッキは警告を出さない", () => {
  const result = lintDeck(parseDeck(cleanDeck), { minutes: 5 });
  assert.deepEqual(
    result.issues.filter((entry) => entry.severity !== "info"),
    [],
    JSON.stringify(result.issues, null, 2),
  );
});

test("lang未指定・埋め残し・話題名の見出し・句点を検出する", () => {
  const rules = rulesOf(
    deckOf(
      [
        "<!-- _class: lead -->\n\n# 新機能の提案\n\n〈イベント名〉・〈YYYY-MM-DD〉",
        "# 背景\n\n- 現行の手順\n\n<!-- 話す -->",
        "# 待ち時間を半分にします。\n\n- 当番制\n\n<!-- 話す -->",
      ],
      "marp: true\ntheme: otake-visual",
    ),
  );
  for (const rule of ["deck/lang", "slide/placeholder", "slide/topic-title", "slide/title-period"]) {
    assert.ok(rules.includes(rule), `${rule} を検出しない: ${rules.join(", ")}`);
  }
});

test("箇条書きはリストごとに数え、2カラムの左右を合算しない", () => {
  const items = (count) => Array.from({ length: count }, (_, index) => `- 項目${index + 1}`).join("\n");
  const twoColumns = `<!-- _class: columns -->\n\n# 足した道具と引いた道具\n\n<div>\n\n${items(4)}\n\n</div>\n<div>\n\n${items(4)}\n\n</div>\n\n<!-- 話す -->`;
  assert.ok(!rulesOf(deckOf([twoColumns])).includes("slide/bullets"));
  const tooMany = `# 多すぎる箇条書きの例\n\n${items(MAX_BULLETS + 1)}\n\n<!-- 話す -->`;
  assert.ok(rulesOf(deckOf([tooMany])).includes("slide/bullets"));
  const deep = "# 深すぎる入れ子の例\n\n- 一段目\n  - 二段目\n    - 三段目\n\n<!-- 話す -->";
  assert.ok(rulesOf(deckOf([deep])).includes("slide/bullets"));
});

test("数値の出典はフッターで判定し、表紙・自己紹介・参考資料は対象外にする", () => {
  const withoutSource = "# 継続率は68%で横ばい\n\n- 前年比 +2pt\n\n<!-- 話す -->";
  assert.ok(rulesOf(deckOf([withoutSource])).includes("slide/source"));
  const withSource = `<!-- _footer: '出典: 社内ダッシュボード（2026-09）' -->\n\n${withoutSource}`;
  assert.ok(!rulesOf(deckOf([withSource])).includes("slide/source"));
  const profile = "<!-- _class: profile -->\n\n# 自己紹介\n\n- 最大20名をリード\n\n<!-- 話す -->";
  assert.ok(!rulesOf(deckOf([profile])).includes("slide/source"));
  const references = "# 参考資料\n\n- 調査 2,000件 https://example.com";
  assert.ok(!rulesOf(deckOf([references])).includes("slide/source"));
});

test("本文の量・alt・色の直書き・手書きSVG・フッターURLを検出する", () => {
  const dense = `# 量が多いスライドの例\n\n${"あ".repeat(BODY_CHARS.present + 1)}\n\n<!-- 話す -->`;
  assert.ok(rulesOf(deckOf([dense])).includes("slide/dense"));
  assert.ok(!rulesOf(deckOf([dense]), { mode: "read" }).includes("slide/dense"));
  const media = `<!-- _footer: 'https://example.com' -->\n\n# 図を置いたスライドの例\n\n![](chart.png)\n\n<span style="color:#ff0000">赤</span>\n\n<svg viewBox="0 0 10 10"></svg>\n\n<!-- 話す -->`;
  const rules = rulesOf(deckOf([media]));
  for (const rule of ["slide/image-alt", "slide/inline-color", "slide/hand-svg", "slide/footer-url"]) {
    assert.ok(rules.includes(rule), `${rule} を検出しない: ${rules.join(", ")}`);
  }
  const background = "![bg right:40%](photo.jpg)\n\n# 背景画像はaltを求めない\n\n<!-- 話す -->";
  assert.ok(!rulesOf(deckOf([background])).includes("slide/image-alt"));
});

test("同じレイアウトの3連続と、挨拶だけの最終スライドを検出する", () => {
  const table = (title) => `# ${title}\n\n| 項目 | 値 |\n| --- | --- |\n| 甲 | 乙 |\n\n<!-- 話す -->`;
  const rules = rulesOf(deckOf([table("一つ目の表の主張"), table("二つ目の表の主張"), table("三つ目の表の主張"), "# ご清聴ありがとうございました"]));
  assert.ok(rules.includes("deck/repeat-layout"));
  assert.ok(rules.includes("deck/closing"));
});

test("ノートの推定時間が持ち時間の9割を超えると警告する", () => {
  const long = `# 話す量の多いスライド\n\n- 要点\n\n<!-- ${"あ".repeat(SPEAKING_CHARS_PER_MINUTE * 2)} -->`;
  assert.ok(rulesOf(deckOf([long]), { minutes: 2 }).includes("deck/timing"));
  assert.ok(!rulesOf(deckOf([long]), { minutes: 3 }).includes("deck/timing"));
  assert.throws(() => lintDeck(parseDeck(deckOf([long])), { minutes: "abc" }), /正の数/);
});

test("見出しの用言止めは問いかけを除いて知らせる", () => {
  for (const title of ["待ち時間が半分になる", "手順書で回答を早めます", "当番制を使う"]) {
    assert.ok(rulesOf(deckOf([`# ${title}\n\n<!-- 話す -->`])).includes("slide/title-taigen"), title);
  }
  for (const title of ["全部maxでよくない？", "待ち時間の半減", "ultracodeとの違い", "最初の一歩はどう"]) {
    assert.ok(!rulesOf(deckOf([`# ${title}\n\n<!-- 話す -->`])).includes("slide/title-taigen"), title);
  }
});

test("全ルールに重大度・要約・根拠がある", () => {
  for (const [id, rule] of Object.entries(deckRules)) {
    assert.match(rule.severity, /^(error|warn|info)$/, id);
    assert.ok(rule.summary && rule.why, id);
  }
});

test("アウトラインにタイトル列と推定時間を出す", () => {
  const text = outlineDeck(parseDeck(cleanDeck), { minutes: 5 });
  assert.match(text, /問い合わせ対応の属人化/);
  assert.match(text, /一次回答まで平均26時間の待ち/);
  assert.match(text, /持ち時間5:00/);
  const markdown = outlineDeck(parseDeck(cleanDeck), { format: "md" });
  assert.match(markdown, /^\| No \| 型 \| タイトル/);
});

test("CLIのlintはerrorがあると終了コード1を返す", () => {
  const tempDir = mkdtempSync(resolve(tmpdir(), "ovs-deck-"));
  try {
    const clean = resolve(tempDir, "clean.md");
    writeFileSync(clean, cleanDeck);
    const ok = spawnSync(process.execPath, [cli, "deck", "lint", clean, "--minutes", "5"], { encoding: "utf8" });
    assert.equal(ok.status, 0, ok.stdout + ok.stderr);
    assert.match(ok.stdout, /error 0/);

    const broken = resolve(tempDir, "broken.md");
    writeFileSync(broken, deckOf(["<!-- _class: lead -->\n\n# 題名\n\n〈イベント名〉"]));
    const ng = spawnSync(process.execPath, [cli, "deck", "lint", broken], { encoding: "utf8" });
    assert.equal(ng.status, 1, ng.stdout + ng.stderr);
    assert.match(ng.stdout, /slide\/placeholder/);

    const outline = spawnSync(process.execPath, [cli, "deck", "outline", clean], { encoding: "utf8" });
    assert.equal(outline.status, 0, outline.stderr);
    assert.match(outline.stdout, /本編3枚/);
  } finally {
    rmSync(tempDir, { recursive: true, force: true });
  }
});

// 実測はフォントと描画環境に依存するため、ブラウザとmarpがあるローカル環境だけで確認する
const marpAvailable = spawnSync("marp", ["--version"], { encoding: "utf8" }).status === 0;
const canRender = Boolean(browserExecutable()) && marpAvailable && process.env.CI !== "true";

test(
  "描画してはみ出し・画像切れ・コントラスト・言語を検出し、画像を保存する",
  { skip: canRender ? false : "Chrome系ブラウザとmarpが必要（CIでは省略）" },
  async () => {
    const { checkDeck } = await import("../scripts/deck-check.mjs");
    const tempDir = mkdtempSync(resolve(tmpdir(), "ovs-deck-check-"));
    try {
      const file = resolve(tempDir, "slide.md");
      writeFileSync(
        file,
        deckOf(
          [
            "# 枠からはみ出す要素の例\n\n<div style=\"min-height:900px\">最小高さ900pxの箱</div>",
            "# 読み込めない画像の例\n\n<img src=\"missing.png\" alt=\"存在しない画像\">",
            "# 薄い文字の例\n\n<p style=\"color: rgb(200, 200, 200)\">背景に溶ける薄い灰色の本文</p>",
          ],
          "marp: true\ntheme: otake-visual\npaginate: true",
        ),
      );
      const shots = resolve(tempDir, "shots");
      const result = await checkDeck(file, { shots });
      const found = (rule, slide) => result.issues.some((entry) => entry.rule === rule && entry.slide === slide);
      assert.ok(found("render/overflow", 1), JSON.stringify(result.issues, null, 2));
      assert.ok(found("render/broken-image", 2), JSON.stringify(result.issues, null, 2));
      assert.ok(found("render/contrast", 3), JSON.stringify(result.issues, null, 2));
      assert.ok(result.issues.some((entry) => entry.rule === "render/lang"));
      assert.equal(result.shots.length, 3);
      assert.ok(result.shots.every((path) => existsSync(path)));
      assert.ok(existsSync(result.sheet));
    } finally {
      rmSync(tempDir, { recursive: true, force: true });
    }
  },
);
