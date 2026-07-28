import assert from "node:assert/strict";
import {
  mkdtempSync,
  readFileSync,
  rmSync,
  writeFileSync,
} from "node:fs";
import { tmpdir } from "node:os";
import { resolve } from "node:path";
import test from "node:test";
import {
  applyProfile,
  chartTypes,
  loadChartRows,
  parts,
  profiles,
  renderBrief,
  rootDir,
  validateBrief,
  validateSvg,
} from "../scripts/core.mjs";

function brief(part) {
  return {
    meta: {
      id: `fixture-${part}`,
      title: part,
      part,
      status: "draft",
    },
    intent: {
      message: `${part}で一つの関係を伝える`,
      audience: "テスト読者",
      placement: "article-inline",
    },
    content: {
      eyebrow: part.toUpperCase(),
      title: `${part}のテスト図`,
      subtitle: "生成経路と安全性を検証する",
      slots: {},
    },
    source: {
      label: "筆者作成",
      url: "",
      accessedAt: "",
      note: "",
    },
    accessibility: {
      alt: `${part}パーツの構造と主要な関係を説明するテスト用の代替テキスト。`,
      colorIndependent: true,
    },
    output: {
      targets: ["blog"],
      formats: ["svg"],
    },
  };
}

const chartRows = {
  bar: [
    { category: "A", value: 80 },
    { category: "B", value: 55 },
  ],
  line: [
    { series: "導入前", category: "1月", value: 30 },
    { series: "導入前", category: "2月", value: 42 },
    { series: "導入後", category: "1月", value: 44 },
    { series: "導入後", category: "2月", value: 68 },
  ],
  "stacked-bar": [
    { series: "完了", category: "A", value: 60 },
    { series: "未完了", category: "A", value: 40 },
    { series: "完了", category: "B", value: 75 },
    { series: "未完了", category: "B", value: 25 },
  ],
  dot: [
    { category: "A", value: 68 },
    { category: "B", value: 42 },
  ],
  slope: [
    { category: "A", start: 32, end: 61 },
    { category: "B", start: 54, end: 46 },
  ],
  scatter: [
    { label: "A", x: 12, y: 40 },
    { label: "B", x: 38, y: 72 },
  ],
  heatmap: [
    { x: "月", y: "朝", value: 42 },
    { x: "火", y: "朝", value: 68 },
    { x: "月", y: "夜", value: 31 },
    { x: "火", y: "夜", value: 80 },
  ],
  waterfall: [
    { category: "開始", value: 100 },
    { category: "増加", value: 30 },
    { category: "減少", value: -20 },
  ],
  "small-multiples": [
    { series: "A", category: "1", value: 20 },
    { series: "A", category: "2", value: 40 },
    { series: "B", category: "1", value: 55 },
    { series: "B", category: "2", value: 48 },
  ],
  progress: [
    { category: "設計", value: 90 },
    { category: "実装", value: 72 },
  ],
};

test("全パーツをJSON briefから安全なSVGへ生成できる", () => {
  for (const part of parts.filter(
    (name) => !["chart", "gantt"].includes(name),
  )) {
    const fixture = brief(part);
    assert.deepEqual(validateBrief(fixture), []);
    const svg = renderBrief(fixture);
    assert.match(svg, /^<svg/);
    assert.match(svg, /data-slot="brand"/);
    assert.match(svg, /data-slot="source"/);
    assert.deepEqual(validateSvg(svg, part), []);
  }
});

function ganttBrief() {
  const fixture = brief("gantt");
  fixture.data = {
    type: "gantt",
    today: "2026-08-12",
    rows: [
      {
        id: "design",
        task: "設計",
        owner: "Design",
        start: "2026-08-01",
        end: "2026-08-07",
        status: "done",
        progress: 100,
      },
      {
        id: "build",
        task: "実装",
        owner: "Dev",
        start: "2026-08-08",
        end: "2026-08-21",
        status: "active",
        progress: 45,
        dependsOn: ["design"],
      },
      {
        id: "release",
        task: "公開",
        owner: "PM",
        start: "2026-08-22",
        end: "2026-08-22",
        status: "planned",
        progress: 0,
        dependsOn: ["build"],
        milestone: true,
      },
    ],
  };
  return fixture;
}

test("ガントを日付・進捗・依存関係から描画できる", () => {
  const fixture = ganttBrief();
  assert.deepEqual(validateBrief(fixture), []);
  const svg = renderBrief(fixture);
  assert.match(svg, /TODAY/);
  assert.match(svg, /進行中 45%/);
  assert.match(svg, /stroke-dasharray="5 4"/);
  assert.doesNotMatch(svg, /NaN|Infinity|undefined/);
  assert.deepEqual(validateSvg(svg, "gantt"), []);

  fixture.data.rows[1].status = "";
  assert.deepEqual(validateBrief(fixture), []);
  assert.match(renderBrief(fixture), /予定 45%/);
});

test("全チャート種の寸法を実データから計算できる", () => {
  for (const type of chartTypes) {
    const fixture = brief("chart");
    fixture.data = {
      type,
      unit: "%",
      period: "2026年",
      rows: chartRows[type],
    };
    const svg = renderBrief(fixture);
    assert.match(svg, /^<svg/);
    assert.doesNotMatch(svg, /NaN|Infinity|undefined/);
    assert.deepEqual(validateSvg(svg, type), []);
  }
});

test("全媒体プロファイルへ正しいSVG寸法で変換できる", () => {
  const svg = renderBrief(brief("cover"));
  for (const [target, profile] of Object.entries(profiles)) {
    const output = applyProfile(svg, target);
    assert.match(
      output,
      new RegExp(`width="${profile.width}" height="${profile.height}"`),
    );
    assert.match(output, new RegExp(`data-profile-background="${target}"`));
  }
  const reordered =
    '<svg viewBox="0 0 1200 675" xmlns="http://www.w3.org/2000/svg"><title>x</title><desc>description</desc></svg>';
  assert.match(applyProfile(reordered, "ogp"), /width="1200" height="630"/);
});

test("CSVとJSONのチャート行を同じ形で読める", () => {
  const csvRows = loadChartRows(resolve(rootDir, "examples", "data", "bar.csv"));
  assert.equal(csvRows.length, 4);
  assert.equal(csvRows[0].category, "記事 A");

  const tempDir = mkdtempSync(resolve(tmpdir(), "ovs-test-"));
  try {
    const jsonPath = resolve(tempDir, "rows.json");
    writeFileSync(jsonPath, JSON.stringify({ rows: chartRows.scatter }));
    assert.deepEqual(loadChartRows(jsonPath), chartRows.scatter);
  } finally {
    rmSync(tempDir, { recursive: true, force: true });
  }
});

test("危険なSVGと不完全なbriefを拒否する", () => {
  const unsafe =
    '<svg viewBox="0 0 1 1"><title>x</title><desc>x</desc><script>alert(1)</script></svg>';
  assert.ok(validateSvg(unsafe, "unsafe").some((error) => error.includes("script")));
  const entity =
    '<!DOCTYPE svg [<!ENTITY xxe SYSTEM "file:///etc/passwd">]><svg viewBox="0 0 1 1"><title>x</title><desc>&xxe;</desc></svg>';
  assert.ok(validateSvg(entity, "entity").some((error) => error.includes("DOCTYPE")));
  const spacedAttributes =
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1 1"><title>x</title><desc>x</desc><path xlink:href = "javascript:alert(1)" onclick = "run()" style = "fill:red"/></svg>';
  const spacedErrors = validateSvg(spacedAttributes, "spaced");
  assert.ok(spacedErrors.some((error) => error.includes("xlink:href")));
  assert.ok(spacedErrors.some((error) => error.includes("onclick")));
  assert.ok(spacedErrors.some((error) => error.includes("style")));

  const invalid = brief("flow");
  invalid.source.label = "";
  invalid.source.url = "file:///tmp/private";
  invalid.accessibility.alt = "短い";
  const errors = validateBrief(invalid);
  assert.ok(errors.some((error) => error.includes("source.label")));
  assert.ok(errors.some((error) => error.includes("httpまたはhttps")));
  assert.ok(errors.some((error) => error.includes("12〜300文字")));

  const invalidGantt = ganttBrief();
  invalidGantt.data.rows[0].dependsOn = ["release"];
  const ganttErrors = validateBrief(invalidGantt);
  assert.ok(ganttErrors.some((error) => error.includes("循環")));
  invalidGantt.data.rows[0].dependsOn = ["missing"];
  assert.ok(
    validateBrief(invalidGantt).some((error) =>
      error.includes("依存先が見つかりません"),
    ),
  );
  invalidGantt.data.rows[0].start = "2026-02-30";
  assert.ok(
    validateBrief(invalidGantt).some((error) => error.includes("実在日")),
  );
  invalidGantt.data.rows[0].start = "2026-08-01";
  invalidGantt.data.rows[0].id = "設計";
  assert.ok(
    validateBrief(invalidGantt).some((error) =>
      error.includes("半角小文字・数字・ハイフン"),
    ),
  );
  const reversedDependency = ganttBrief();
  reversedDependency.data.rows[1].start = "2026-08-07";
  assert.ok(
    validateBrief(reversedDependency).some((error) =>
      error.includes("終了翌日以降"),
    ),
  );
  const longGantt = ganttBrief();
  longGantt.data.rows[2].end = "2027-09-01";
  assert.ok(
    validateBrief(longGantt).some((error) => error.includes("366日以内")),
  );

  const duplicateOutput = brief("flow");
  duplicateOutput.output.targets = ["blog", "blog"];
  duplicateOutput.output.formats = ["svg", "svg"];
  const duplicateErrors = validateBrief(duplicateOutput);
  assert.ok(duplicateErrors.some((error) => error.includes("targetsは重複")));
  assert.ok(duplicateErrors.some((error) => error.includes("formatsは重複")));
});

test("サンプルbriefは実際にレンダリングできる", () => {
  const sample = JSON.parse(
    readFileSync(resolve(rootDir, "examples", "chart.brief.json"), "utf8"),
  );
  assert.deepEqual(validateBrief(sample), []);
  assert.match(renderBrief(sample), /記事別の読了率を比較する/);

  const ganttSample = JSON.parse(
    readFileSync(resolve(rootDir, "examples", "gantt.brief.json"), "utf8"),
  );
  assert.deepEqual(validateBrief(ganttSample), []);
  assert.match(renderBrief(ganttSample), /新機能リリース計画/);
});
