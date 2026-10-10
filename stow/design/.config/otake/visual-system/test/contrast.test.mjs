import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { resolve } from "node:path";
import test from "node:test";
import { browserExecutable } from "../scripts/browser.mjs";
import { checkSvgContrasts, contrastIssues } from "../scripts/svg-contrast.mjs";
import { chartTypes, renderBrief, rootDir } from "../scripts/core.mjs";

const canRender = Boolean(browserExecutable());
const renderOptions = { skip: canRender ? false : "Chrome系ブラウザが必要" };
const fixture = (body, background = '<rect width="500" height="220" fill="#FFFFFF"/>') =>
  `<svg xmlns="http://www.w3.org/2000/svg" width="500" height="220" viewBox="0 0 500 220">
  <title>Contrast fixture</title><desc>文字と背景の実測用SVG</desc>
  ${background}<g font-family="sans-serif" font-size="16">${body}</g>
  <g data-slot="source"/><g data-slot="brand"/></svg>`;

test("危険なSVGはChrome起動前に拒否する", async () => {
  await assert.rejects(checkSvgContrasts([{ name: "unsafe", svg: fixture('<script>alert(1)</script>') }]), /script/);
  for (const body of [
    '<text x="20" y="50" opacity="0.2">○</text>',
    '<text x="20" y="50" fill-opacity="0.2">○</text>',
    '<g opacity="0.2"><text x="20" y="50">○</text></g>',
  ]) {
    await assert.rejects(checkSvgContrasts([{ name: "unsupported-opacity", svg: fixture(body) }]), /許可されていないSVG属性/);
  }
});

test("字形の背景を継承色・変形・tspan・描画順から測定する", renderOptions, async () => {
  const inputs = [
    { name: "same", svg: fixture('<text x="20" y="50" fill="#FFFFFF">Invisible</text>') },
    { name: "dark", svg: fixture('<rect x="10" y="20" width="200" height="60" fill="#123858"/><g fill="#FFFFFF" transform="translate(25 10)"><text x="0" y="40">Readable</text></g>') },
    { name: "mixed", svg: fixture('<text x="20" y="50" fill="#17202A">Good <tspan fill="#EEEEEE">Bad</tspan><tspan x="20" dy="30">Good again</tspan></text>') },
    { name: "split", svg: fixture('<rect x="90" y="20" width="200" height="60" fill="#17202A"/><text x="20" y="50" fill="#17202A">Across backgrounds</text>') },
    { name: "size", svg: fixture('<text x="20" y="40" fill="#777777">Normal</text><text x="20" y="90" font-size="24" fill="#777777">Large</text><g transform="translate(20 120) scale(0.5)"><text font-size="24" fill="#777777">Scaled</text></g>') },
    { name: "transparent", svg: fixture('<text x="20" y="50" fill="#17202A">Unknown backdrop</text>', "") },
    { name: "opacity", svg: fixture('<text x="20" y="50" fill="rgba(23,32,42,0.2)">Faint</text>') },
    { name: "repaint", svg: fixture('<rect x="10" y="20" width="200" height="60" fill="#123858"/><rect x="10" y="20" width="200" height="60" fill="#FFFFFF"/><text x="20" y="50" fill="#FFFFFF">Last background</text>') },
    { name: "covered", svg: fixture('<text x="20" y="50" fill="#FFFFFF">Covered</text><rect x="10" y="20" width="200" height="60" fill="#123858"/>') },
    { name: "thin", svg: fixture('<text x="20" y="50" font-size="2" fill="#17202A">○</text>') },
    { name: "thin-same", svg: fixture('<text x="20" y="50" font-size="2" fill="#FFFFFF">○</text>') },
    { name: "thin-covered", svg: fixture('<text x="20" y="50" font-size="2" fill="#FFFFFF">○</text><rect x="10" y="20" width="200" height="60" fill="#123858"/>') },
  ];
  const reports = await checkSvgContrasts(inputs);
  const issues = (name) => reports.find((report) => report.name === name).results.filter((r) => r.issue);
  assert.equal(issues("same")[0]?.ratio, 1);
  assert.deepEqual(issues("dark"), []);
  assert.deepEqual(issues("mixed").map((r) => r.text), ["Bad"]);
  assert.equal(issues("split")[0]?.issue, "contrast");
  assert.deepEqual(issues("size").map((r) => r.text), ["Normal", "Scaled"]);
  assert.equal(issues("transparent")[0]?.issue, "unmeasured");
  assert.equal(issues("opacity")[0]?.issue, "contrast");
  assert.equal(issues("repaint")[0]?.ratio, 1);
  assert.equal(issues("covered")[0]?.issue, "unmeasured");
  assert.equal(reports.find((report) => report.name === "thin").results[0].issue, null);
  assert.equal(issues("thin-same")[0]?.issue, "contrast");
  assert.equal(issues("thin-covered")[0]?.issue, "unmeasured");
  assert.match(contrastIssues(reports).join("\n"), /Invisible.*1.00:1/);
});

test("以前の薄い文字を再現すると比較表・状態ボード・ガントで失敗する", renderOptions, async () => {
  const inputs = ["comparison", "status-board", "gantt"].map((name) => {
    let svg = readFileSync(resolve(rootDir, `generated/templates/${name}.svg`), "utf8");
    const slot = name === "comparison" ? 'data-slot="cell-2-2"' : name === "status-board" ? 'data-slot="overall"' : 'x="1058" y="55"';
    const pattern = new RegExp(`(<text[^>]*${slot}[^>]*fill=")#[0-9A-Fa-f]+`);
    svg = svg.replace(pattern, "$1#DCE8F6");
    return { name, svg };
  });
  const reports = await checkSvgContrasts(inputs);
  for (const report of reports) {
    assert.ok(report.results.some((r) => r.issue === "contrast"), report.name);
  }
});

test("全10チャートとデータ駆動ガントの実際の文字が読める", renderOptions, async () => {
  const base = JSON.parse(readFileSync(resolve(rootDir, "templates/brief.json"), "utf8"));
  const seriesRows = ["A", "B", "C", "D"].flatMap((series, i) => [
    { series, category: "1", value: 10 + i * 20 },
    { series, category: "2", value: 20 + i * 20 },
  ]);
  const inputs = chartTypes.map((type) => {
    const brief = structuredClone(base);
    brief.meta.part = "chart";
    brief.content.slots = {};
    let rows = [{ category: "A", value: 30 }, { category: "B", value: 70 }];
    if (["line", "stacked-bar", "small-multiples"].includes(type)) rows = seriesRows;
    if (type === "slope") rows = [{ category: "A", start: 30, end: 60 }, { category: "B", start: 70, end: 40 }];
    if (type === "scatter") rows = [{ label: "A", x: 10, y: 30 }, { label: "B", x: 50, y: 60 }];
    if (type === "heatmap") rows = [10, 30, 60, 90].map((value, i) => ({ x: String(i), y: "A", value }));
    if (type === "waterfall") rows = [{ category: "A", value: 40 }, { category: "B", value: -10 }];
    brief.data = { type, rows, unit: "%", period: "テスト期間" };
    return { name: type, svg: renderBrief(brief) };
  });
  const gantt = JSON.parse(readFileSync(resolve(rootDir, "examples/gantt.brief.json"), "utf8"));
  inputs.push({ name: "gantt", svg: renderBrief(gantt) });
  assert.deepEqual(contrastIssues(await checkSvgContrasts(inputs)), []);
});

test("contrast CLIはJSON結果と失敗終了コードを返す", renderOptions, () => {
  const dir = mkdtempSync(resolve(tmpdir(), "ovs-contrast-test-"));
  try {
    const file = resolve(dir, "bad.svg");
    writeFileSync(file, fixture('<text x="20" y="50" fill="#FFFFFF">Hidden</text>'));
    const result = spawnSync(process.execPath, [
      resolve(rootDir, "scripts/ovs.mjs"), "contrast", file, "--json",
    ], { encoding: "utf8", timeout: 30000 });
    assert.equal(result.status, 1, result.stderr);
    assert.equal(JSON.parse(result.stdout)[0].results[0].issue, "contrast");
  } finally {
    rmSync(dir, { recursive: true, force: true });
  }
});
