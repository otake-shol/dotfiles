#!/usr/bin/env node

import {
  copyFileSync,
  existsSync,
  lstatSync,
  mkdtempSync,
  mkdirSync,
  readFileSync,
  readdirSync,
  renameSync,
  rmSync,
  unlinkSync,
  writeFileSync,
} from "node:fs";
import { randomUUID } from "node:crypto";
import { tmpdir } from "node:os";
import { basename, dirname, extname, relative, resolve } from "node:path";
import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";
import {
  applyProfile,
  chartTypes,
  escapeXml,
  findSvgFiles,
  generatedDir,
  loadChartRows,
  parts,
  profiles,
  readJson,
  renderBrief,
  rootDir,
  slugify,
  sourceLabel,
  tokens,
  validateBrief,
  validateSvg,
} from "./core.mjs";

const scriptDir = dirname(fileURLToPath(import.meta.url));
const args = process.argv.slice(2);
const command = args.shift() ?? "help";

function parseOptions(values) {
  const positional = [];
  const options = {};
  for (let index = 0; index < values.length; index += 1) {
    const value = values[index];
    if (!value.startsWith("--")) {
      positional.push(value);
      continue;
    }
    const [rawKey, inlineValue] = value.slice(2).split("=", 2);
    const key = rawKey.replace(/-([a-z])/g, (_match, letter) =>
      letter.toUpperCase(),
    );
    if (inlineValue !== undefined) {
      options[key] = inlineValue;
    } else if (values[index + 1] && !values[index + 1].startsWith("--")) {
      options[key] = values[index + 1];
      index += 1;
    } else {
      options[key] = true;
    }
  }
  return { positional, options };
}

function fail(message, code = 1) {
  console.error(`✗ ${message}`);
  process.exitCode = code;
}

function ensureDirectory(path) {
  mkdirSync(path, { recursive: true });
}

function existingStat(path) {
  try {
    return lstatSync(path);
  } catch (error) {
    if (error.code === "ENOENT") {
      return null;
    }
    throw error;
  }
}

function assertNoSymlinkParents(path) {
  let parent = dirname(resolve(path));
  while (true) {
    const current = existingStat(parent);
    if (current?.isSymbolicLink() && current.uid !== 0) {
      throw new Error(
        `${path}の親ディレクトリ${parent}がシンボリックリンクのため書込みできません`,
      );
    }
    const next = dirname(parent);
    if (next === parent) {
      return;
    }
    parent = next;
  }
}

function assertWritable(path, force = false) {
  assertNoSymlinkParents(path);
  const current = existingStat(path);
  if (!current) {
    return;
  }
  if (current.isSymbolicLink()) {
    throw new Error(`${path}はシンボリックリンクのため上書きできません`);
  }
  if (!current.isFile()) {
    throw new Error(`${path}は通常ファイルではありません`);
  }
  if (!force) {
    throw new Error(`${path}は既に存在します。更新する場合は--forceを付けてください`);
  }
}

function temporaryPath(path) {
  return `${path}.ovs-tmp-${process.pid}-${randomUUID()}`;
}

function write(path, content, { force = false } = {}) {
  assertWritable(path, force);
  ensureDirectory(dirname(path));
  const temporary = temporaryPath(path);
  try {
    writeFileSync(
      temporary,
      content.endsWith("\n") ? content : `${content}\n`,
      { encoding: "utf8", flag: "wx" },
    );
    renameSync(temporary, path);
  } catch (error) {
    if (existsSync(temporary)) {
      unlinkSync(temporary);
    }
    throw error;
  }
}

function preflight(paths, force = false) {
  for (const path of paths) {
    assertWritable(path, force);
  }
}

function validateXmlFile(path) {
  const result = spawnSync("xmllint", ["--noout", "--nonet", path], {
    encoding: "utf8",
  });
  if (result.error?.code === "ENOENT") {
    throw new Error("SVG構文検証にはxmllintが必要です");
  }
  if (result.error) {
    throw new Error(`${path}: xmllintを実行できません: ${result.error.message}`);
  }
  if (result.status !== 0) {
    throw new Error(`${path}: XML構文エラー: ${(result.stderr ?? "").trim()}`);
  }
}

function help() {
  console.log(`Otake Visual System ${tokens.meta.version}

使い方:
  ovs new <slug> [--part flow] [--out DIR]
  ovs suggest <article.md> [--write suggestions.json] [--force]
  ovs render <brief.json> [--out DIR] [--force]
  ovs chart <data.csv|json> --type bar --title TITLE --source SOURCE --alt ALT [--out DIR] [--force]
  ovs gantt <tasks.csv|json> --title TITLE [--today YYYY-MM-DD] [--target blog,slide] [--out DIR] [--force]
  ovs document <file.md> [--target html,marp] [--source LABEL] [--out DIR] [--force]
  ovs export <file.svg> --target ogp,square [--out DIR] [--force]
  ovs preview [DIR] [--out gallery.html] [--force]
  ovs lint <SVG|DIR>
  ovs list [parts|charts|pm|recipes|targets|icons]

原則:
  OVSネイティブ図はJSON briefを入力にし、SVG・PNG・altを同時生成します。
  Markdown内のMermaidはdocumentでOVSテーマ付きSVGへ事前変換します。
  SVGをAIや手作業で直接編集する運用は想定していません。`);
}

const slotDefaults = {
  cover: {
    "label-1": "構造",
    "label-2": "判断",
    "label-3": "実践",
  },
  flow: {
    "label-1": "入力を揃える",
    "body-1": "事実と前提を分ける",
    "label-2": "判断する",
    "body-2": "比較軸を一つに絞る",
    "label-3": "行動へ変える",
    "body-3": "次の一歩を具体化する",
  },
  matrix: {
    "label-quadrant-1": "計画して育てる",
    "label-quadrant-2": "今すぐ着手",
    "label-quadrant-3": "保留・観察",
    "label-quadrant-4": "小さく試す",
    "point-label-1": "A",
    "point-label-2": "B",
    "point-label-3": "C",
    "point-label-4": "D",
  },
  comparison: {
    "label-column-1": "方式 A",
    "label-column-2": "方式 B",
    "label-column-3": "方式 C",
    "label-row-1": "導入コスト",
    "label-row-2": "変更しやすさ",
    "label-row-3": "再利用性",
    "label-row-4": "向いている場面",
  },
  "before-after": {
    "label-1": "変更前の状態",
    "body-1": "問題を18文字×2行で書く",
    "note-1": "困っていたこと",
    "change-label": "変更",
    "label-2": "変更後の状態",
    "body-2": "改善を18文字×2行で書く",
    "note-2": "得られた価値",
  },
  timeline: {
    "date-1": "STEP 01",
    "label-1": "最初の出来事",
    "body-1": "何が変わったか",
    "date-2": "STEP 02",
    "label-2": "次の出来事",
    "body-2": "何を判断したか",
    "date-3": "STEP 03",
    "label-3": "転機",
    "body-3": "何を実装したか",
    "date-4": "STEP 04",
    "label-4": "現在",
    "body-4": "次に何をするか",
  },
  architecture: {
    "layer-1": "Reader / Author",
    "body-1": "利用者の責務",
    "layer-2": "Interface",
    "body-2": "入力と出力の境界",
    "layer-3": "Application",
    "body-3": "処理の責務",
    "layer-4": "Data / Output",
    "body-4": "保存と公開の責務",
  },
  sequence: {
    "actor-1": "Actor A",
    "actor-2": "Actor B",
    "actor-3": "Actor C",
    "message-1": "依頼する",
    "message-2": "処理を渡す",
    "message-3": "結果を返す",
    "message-4": "完了を返す",
  },
  takeaway: {
    message: "読者に残したい一文",
    action: "次に取る具体的な行動",
  },
  warning: {
    message: "避けるべきこと",
    "body-1": "なぜ問題になるか",
    action: "代わりに取る安全な行動",
  },
  definition: {
    term: "用語",
    reading: "読みまたは正式名称",
    definition: "この記事での短い定義",
    includes: "含む対象",
    excludes: "含まない対象",
  },
  roadmap: {
    "period-1": "NOW",
    "period-2": "NEXT",
    "period-3": "LATER",
    "label-1": "課題を絞る",
    "body-1": "仮説と成功条件を定義",
    "label-2": "価値を届ける",
    "body-2": "実装・検証・改善",
    "label-3": "仕組みにする",
    "body-3": "展開と運用を標準化",
  },
  wbs: {
    root: "プロジェクト",
    "label-1": "企画",
    "label-2": "制作",
    "label-3": "公開",
    "leaf-1-1": "要件整理",
    "leaf-1-2": "計画",
    "leaf-2-1": "設計",
    "leaf-2-2": "実装",
    "leaf-3-1": "検証",
    "leaf-3-2": "リリース",
  },
  raci: {
    "role-1": "PM",
    "role-2": "Design",
    "role-3": "Dev",
    "role-4": "Owner",
    "deliverable-1": "要件定義",
    "deliverable-2": "デザイン",
    "deliverable-3": "実装",
    "deliverable-4": "承認",
  },
  raid: {
    "label-1": "Risk",
    "body-1": "納期の遅延可能性",
    "owner-1": "Owner: PM",
    "label-2": "Assumption",
    "body-2": "既存基盤を再利用",
    "owner-2": "確認: 8/05",
    "label-3": "Issue",
    "body-3": "仕様が一部未確定",
    "owner-3": "Owner: Product",
    "label-4": "Dependency",
    "body-4": "外部APIの公開待ち",
    "owner-4": "確認: 8/12",
  },
  "status-board": {
    overall: "ON TRACK",
    progress: "68%",
    health: "予定どおり",
    "milestone-1": "デザイン確定",
    "date-1": "8/07",
    "milestone-2": "β版リリース",
    "date-2": "8/21",
    blocker: "外部APIの仕様確定待ち",
    next: "結合テストと公開準備",
  },
};

function defaultBrief(id, part) {
  return {
    meta: {
      id,
      title: id,
      part,
      status: "draft",
    },
    intent: {
      message: "この図で伝える一文",
      audience: "想定読者",
      placement: part === "cover" ? "cover" : "article-inline",
    },
    content: {
      eyebrow: part.toUpperCase(),
      title: "図中の主見出し",
      subtitle: "補足は一文まで",
      slots: slotDefaults[part] ?? {},
    },
    ...(part === "chart"
      ? {
          data: {
            type: "bar",
            unit: "%",
            period: "",
            rows: [
              { category: "項目 A", value: 72 },
              { category: "項目 B", value: 48 },
            ],
          },
        }
      : part === "gantt"
        ? {
            data: {
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
            },
          }
        : {}),
    source: {
      label: "筆者作成",
      url: "",
      accessedAt: "",
      note: "",
    },
    accessibility: {
      alt: "図の結論と要素間の関係を、画像を見なくても理解できるように説明する代替テキスト。",
      colorIndependent: true,
    },
    output: {
      targets: ["blog"],
      formats: ["svg", "png"],
    },
  };
}

function newProject(values) {
  const { positional, options } = parseOptions(values);
  if (!positional[0]) {
    throw new Error("slugを指定してください");
  }
  const part = options.part ?? "cover";
  if (!parts.includes(part)) {
    throw new Error(`未定義のパーツ: ${part}`);
  }
  const slug = slugify(positional[0]);
  const outDir = resolve(options.out ?? process.cwd(), slug);
  if (existsSync(outDir)) {
    throw new Error(`${outDir}は既に存在します`);
  }
  assertNoSymlinkParents(outDir);
  ensureDirectory(outDir);
  copyFileSync(resolve(rootDir, "templates", "article.md"), resolve(outDir, "article.md"));
  write(
    resolve(outDir, `${slug}.brief.json`),
    JSON.stringify(defaultBrief(slug, part), null, 2),
  );
  console.log(`✓ 記事図解ワークスペースを作成: ${outDir}`);
  console.log(`  1. article.mdを書く`);
  console.log(`  2. ovs suggest ${resolve(outDir, "article.md")}`);
  console.log(`  3. brief.jsonを整えて ovs render`);
}

const suggestionRules = [
  {
    part: "gantt",
    score: 94,
    pattern: /ガント|工程表|タスク依存|依存タスク|担当者|納期|進捗率/g,
    reason: "タスク・担当・依存関係を時間軸で追う",
  },
  {
    part: "wbs",
    score: 91,
    pattern: /WBS|作業分解|成果物|スコープ/g,
    reason: "成果物を実行可能な作業へ分解する",
  },
  {
    part: "raci",
    score: 91,
    pattern: /RACI|責任分担|役割分担|承認者/g,
    reason: "成果物ごとの責任と関与を明確にする",
  },
  {
    part: "raid",
    score: 90,
    pattern: /RAID|リスク管理|前提条件|課題管理|プロジェクト依存/g,
    reason: "リスク・前提・課題・依存を一枚で管理する",
  },
  {
    part: "status-board",
    score: 89,
    pattern: /週次|定例|ステータス|マイルストーン|ブロッカー/g,
    reason: "進捗・節目・阻害要因・次の行動を共有する",
  },
  {
    part: "definition",
    score: 90,
    pattern: /定義|とは|用語|意味|概念/g,
    reason: "用語の意味を最初に固定する",
  },
  {
    part: "before-after",
    score: 88,
    pattern: /変更前|変更後|以前|現在|改善|ビフォー|アフター/g,
    reason: "変化を同じ軸で対比する",
  },
  {
    part: "timeline",
    score: 84,
    pattern: /時系列|経緯|歴史|ロードマップ|月|年|フェーズ/g,
    reason: "出来事や計画を時間順に並べる",
  },
  {
    part: "architecture",
    score: 86,
    pattern: /構成|アーキテクチャ|サーバー|API|DB|コンポーネント|境界/g,
    reason: "構成要素と境界を俯瞰する",
  },
  {
    part: "sequence",
    score: 87,
    pattern: /順序|リクエスト|レスポンス|呼び出し|処理|通信|シーケンス/g,
    reason: "主体間のやり取りを順番に示す",
  },
  {
    part: "comparison",
    score: 82,
    pattern: /比較|違い|選択肢|メリット|デメリット|対して|一方/g,
    reason: "選択肢を共通の判断軸で比べる",
  },
  {
    part: "chart",
    score: 85,
    pattern: /データ|数値|%|％|増加|減少|推移|件|人|円/g,
    reason: "実測値の差や推移を直接ラベルする",
  },
  {
    part: "warning",
    score: 80,
    pattern: /注意|危険|失敗|落とし穴|制約|できない|禁止/g,
    reason: "誤用や適用条件を独立して強調する",
  },
  {
    part: "flow",
    score: 76,
    pattern: /手順|流れ|入力|出力|原因|結果|ステップ/g,
    reason: "変換や因果を3〜5段階へ分ける",
  },
  {
    part: "matrix",
    score: 72,
    pattern: /優先|重要|緊急|難易度|二軸|ポジション/g,
    reason: "2軸で優先領域を決める",
  },
  {
    part: "takeaway",
    score: 78,
    pattern: /まとめ|結論|要点|覚えて|重要|学び/g,
    reason: "記事の主張を一文で残す",
  },
];

function suggest(values) {
  const { positional, options } = parseOptions(values);
  const articlePath = resolve(positional[0] ?? "");
  if (!positional[0] || !existsSync(articlePath)) {
    throw new Error("存在する記事Markdownを指定してください");
  }
  const text = readFileSync(articlePath, "utf8");
  const suggestions = suggestionRules
    .map((rule) => {
      const matches = text.match(rule.pattern)?.length ?? 0;
      return {
        part: rule.part,
        score: Math.min(99, rule.score + Math.max(0, matches - 1) * 2),
        matches,
        reason: rule.reason,
      };
    })
    .filter((item) => item.matches > 0)
    .sort((left, right) => right.score - left.score)
    .slice(0, 6);
  suggestions.unshift({
    part: "cover",
    score: 100,
    matches: 1,
    reason: "記事の主題と作者性を最初に示す",
  });
  const hasData = suggestions.some((item) => item.part === "chart");
  const hasCompare = suggestions.some((item) =>
    ["before-after", "comparison", "matrix"].includes(item.part),
  );
  const hasRetrospective =
    /振り返り|失敗|学び|経緯/.test(text) &&
    suggestions.some((item) => item.part === "timeline");
  const hasProjectManagement = suggestions.some((item) =>
    ["gantt", "wbs", "raci", "raid", "status-board"].includes(item.part),
  );
  const recipe = hasProjectManagement
    ? "project-plan"
    : hasData
    ? "data-story"
    : hasRetrospective
      ? "retrospective"
      : hasCompare
        ? "comparison-guide"
        : "technical-explainer";
  const result = {
    article: articlePath,
    recipe,
    suggestions,
    note: "提案は見出しと語彙による初期案です。1図1メッセージを優先して採否を決めてください。",
  };
  if (options.write) {
    write(resolve(options.write), JSON.stringify(result, null, 2), {
      force: options.force === true,
    });
    console.log(`✓ 提案を書き出しました: ${resolve(options.write)}`);
  }
  console.log(`推奨レシピ: ${recipe}`);
  for (const item of suggestions) {
    console.log(
      `  ${String(item.score).padStart(3)}  ${item.part.padEnd(16)} ${item.reason}`,
    );
  }
}

function pngOutput(svgPath, pngPath, profile, force = false) {
  assertWritable(pngPath, force);
  const temporary = temporaryPath(pngPath);
  const result = spawnSync(
    "rsvg-convert",
    [
      "--width",
      String(profile.width),
      "--height",
      String(profile.height),
      "--keep-aspect-ratio",
      "--background-color",
      tokens.color.canvas,
      "--output",
      temporary,
      svgPath,
    ],
    { encoding: "utf8" },
  );
  if (result.error?.code === "ENOENT") {
    throw new Error("PNG生成にはrsvg-convert（librsvg）が必要です");
  }
  if (result.error) {
    if (existsSync(temporary)) {
      unlinkSync(temporary);
    }
    throw new Error(`rsvg-convertを実行できません: ${result.error.message}`);
  }
  if (result.status !== 0) {
    if (existsSync(temporary)) {
      unlinkSync(temporary);
    }
    throw new Error(`PNG生成に失敗しました: ${(result.stderr ?? "").trim()}`);
  }
  try {
    renameSync(temporary, pngPath);
  } catch (error) {
    if (existsSync(temporary)) {
      unlinkSync(temporary);
    }
    throw error;
  }
}

function emitRendered(brief, outDir, force = false) {
  const canonical = renderBrief(brief);
  const outputs = [];
  const planned = [];
  for (const target of brief.output.targets) {
    const base = resolve(outDir, `${brief.meta.id}-${target}`);
    planned.push(`${base}.svg`, `${base}.alt.txt`);
    if (brief.output.formats.includes("png")) {
      planned.push(`${base}.png`);
    }
  }
  preflight(planned, force);
  ensureDirectory(outDir);
  for (const target of brief.output.targets) {
    const profile = profiles[target];
    const svg = applyProfile(canonical, target);
    const base = resolve(outDir, `${brief.meta.id}-${target}`);
    const svgPath = `${base}.svg`;
    const altPath = `${base}.alt.txt`;
    const svgErrors = validateSvg(svg, `${brief.meta.id}-${target}`);
    if (svgErrors.length > 0) {
      throw new Error(svgErrors.join("\n"));
    }
    if (brief.output.formats.includes("svg") || brief.output.formats.includes("png")) {
      write(svgPath, svg, { force });
      validateXmlFile(svgPath);
      outputs.push(svgPath);
    }
    write(altPath, brief.accessibility.alt, { force });
    outputs.push(altPath);
    if (brief.output.formats.includes("png")) {
      const pngPath = `${base}.png`;
      pngOutput(svgPath, pngPath, profile, force);
      outputs.push(pngPath);
    }
  }
  return outputs;
}

function render(values) {
  const { positional, options } = parseOptions(values);
  const briefPath = resolve(positional[0] ?? "");
  if (!positional[0] || !existsSync(briefPath)) {
    throw new Error("存在するbrief.jsonを指定してください");
  }
  const brief = readJson(briefPath);
  const errors = validateBrief(brief);
  if (errors.length > 0) {
    throw new Error(errors.join("\n"));
  }
  const outDir = options.out
    ? resolve(options.out)
    : resolve(dirname(briefPath), "dist");
  const outputs = emitRendered(brief, outDir, options.force === true);
  console.log(`✓ ${outputs.length}ファイル生成: ${outDir}`);
  for (const path of outputs) {
    console.log(`  ${basename(path)}`);
  }
}

function chart(values) {
  const { positional, options } = parseOptions(values);
  const dataPath = resolve(positional[0] ?? "");
  if (!positional[0] || !existsSync(dataPath)) {
    throw new Error("存在する.csvまたは.jsonを指定してください");
  }
  for (const required of ["type", "title", "source", "alt"]) {
    if (!options[required]) {
      throw new Error(`--${required}は必須です`);
    }
  }
  if (!chartTypes.includes(options.type)) {
    throw new Error(`未定義のチャート: ${options.type}`);
  }
  const id = slugify(options.id ?? options.title);
  const brief = defaultBrief(id, "chart");
  brief.intent.message = options.message ?? options.title;
  brief.intent.audience = options.audience ?? "記事読者";
  brief.content.title = options.title;
  brief.content.subtitle = options.subtitle ?? "";
  brief.data = {
    type: options.type,
    unit: options.unit ?? "",
    period: options.period ?? "",
    rows: loadChartRows(dataPath),
  };
  brief.source.label = options.source;
  brief.source.url = options.sourceUrl ?? "";
  brief.accessibility.alt = options.alt;
  brief.output.targets = String(options.target ?? "blog").split(",");
  brief.output.formats = String(options.format ?? "svg,png").split(",");
  const outDir = options.out
    ? resolve(options.out)
    : resolve(process.cwd(), "dist");
  const briefPath = resolve(outDir, `${id}.brief.json`);
  const force = options.force === true;
  assertWritable(briefPath, force);
  const outputs = emitRendered(brief, outDir, force);
  write(briefPath, JSON.stringify(brief, null, 2), { force });
  console.log(`✓ データから${options.type}チャートを生成: ${outDir}`);
  console.log(`  brief: ${briefPath}`);
  console.log(`  outputs: ${outputs.length}`);
}

function normalizedGanttStatus(value) {
  const status = String(value ?? "planned").trim().toLowerCase();
  const aliases = {
    planned: "planned",
    "未着手": "planned",
    "予定": "planned",
    active: "active",
    "進行": "active",
    "進行中": "active",
    blocked: "blocked",
    "遅延": "blocked",
    "ブロック": "blocked",
    done: "done",
    complete: "done",
    completed: "done",
    "完了": "done",
  };
  return aliases[status] ?? (status || "planned");
}

function gantt(values) {
  const { positional, options } = parseOptions(values);
  const dataPath = resolve(positional[0] ?? "");
  if (!positional[0] || !existsSync(dataPath)) {
    throw new Error("存在するタスク.csvまたは.jsonを指定してください");
  }
  if (!options.title) {
    throw new Error("--titleは必須です");
  }
  let id;
  if (options.id) {
    id = slugify(options.id);
  } else {
    try {
      id = slugify(options.title);
    } catch {
      try {
        id = slugify(basename(dataPath, extname(dataPath)));
      } catch {
        id = "project-gantt";
      }
    }
  }
  const rows = loadChartRows(dataPath).map((row, index) => ({
    id: String(row.id || `task-${index + 1}`),
    task: String(row.task ?? row.category ?? row.label ?? "").trim(),
    owner: String(row.owner ?? "").trim(),
    start: String(row.start ?? "").trim(),
    end: String(row.end ?? "").trim(),
    status: normalizedGanttStatus(row.status),
    progress: Number(row.progress || 0),
    dependsOn: Array.isArray(row.dependsOn)
      ? row.dependsOn.map(String)
      : String(row.dependsOn ?? row.dependency ?? "")
          .split(/[|;]/)
          .map((value) => value.trim())
          .filter(Boolean),
    milestone:
      row.milestone === true ||
      String(row.milestone ?? "").toLowerCase() === "true",
  }));
  const statusSummary = Object.entries(
    rows.reduce((summary, row) => {
      summary[row.status] = (summary[row.status] ?? 0) + 1;
      return summary;
    }, {}),
  )
    .map(([status, count]) => `${status} ${count}件`)
    .join("、");
  const brief = defaultBrief(id, "gantt");
  brief.intent.message = options.message ?? options.title;
  brief.intent.audience = options.audience ?? "プロジェクト関係者";
  brief.content.title = options.title;
  brief.content.subtitle = options.subtitle ?? "";
  brief.data = {
    type: "gantt",
    rows,
    ...(options.start ? { start: options.start } : {}),
    ...(options.end ? { end: options.end } : {}),
    ...(options.today ? { today: options.today } : {}),
  };
  brief.source.label = options.source ?? "筆者作成";
  brief.source.url = options.sourceUrl ?? "";
  brief.accessibility.alt =
    options.alt ??
    `${options.title}のガントチャート。${rows.length}件のタスクがあり、状態は${statusSummary}。`;
  brief.output.targets = String(options.target ?? "blog")
    .split(",")
    .map((value) => value.trim())
    .filter(Boolean);
  brief.output.formats = String(options.format ?? "svg,png")
    .split(",")
    .map((value) => value.trim())
    .filter(Boolean);
  const outDir = options.out
    ? resolve(options.out)
    : resolve(process.cwd(), "dist");
  const briefPath = resolve(outDir, `${id}.brief.json`);
  const force = options.force === true;
  assertWritable(briefPath, force);
  const outputs = emitRendered(brief, outDir, force);
  write(briefPath, JSON.stringify(brief, null, 2), { force });
  console.log(`✓ ${rows.length}タスクのガントチャートを生成: ${outDir}`);
  console.log(`  brief: ${briefPath}`);
  console.log(`  outputs: ${outputs.length}`);
}

function siblingAlt(svgPath) {
  return svgPath.replace(/\.svg$/i, ".alt.txt");
}

function exportSvg(values) {
  const { positional, options } = parseOptions(values);
  const svgPath = resolve(positional[0] ?? "");
  if (!positional[0] || !existsSync(svgPath)) {
    throw new Error("存在するSVGを指定してください");
  }
  if (!options.target) {
    throw new Error("--targetを指定してください");
  }
  const sourceSvg = readFileSync(svgPath, "utf8");
  const errors = validateSvg(sourceSvg, svgPath);
  if (errors.length > 0) {
    throw new Error(errors.join("\n"));
  }
  validateXmlFile(svgPath);
  const targets = String(options.target).split(",");
  const outDir = options.out
    ? resolve(options.out)
    : resolve(dirname(svgPath), "export");
  const altPath = siblingAlt(svgPath);
  const alt = existsSync(altPath)
    ? readFileSync(altPath, "utf8").trim()
    : sourceSvg.match(/<desc\b[^>]*>([\s\S]*?)<\/desc>/)?.[1] ?? "";
  if ([...alt].length < 12) {
    throw new Error("同名.alt.txtまたは12文字以上のSVG descが必要です");
  }
  const planned = targets.flatMap((target) => {
    if (!profiles[target]) {
      throw new Error(`未定義の出力先: ${target}`);
    }
    const baseName = basename(svgPath, ".svg");
    const outSvg = resolve(outDir, `${baseName}-${target}.svg`);
    return [
      outSvg,
      outSvg.replace(/\.svg$/, ".alt.txt"),
      outSvg.replace(/\.svg$/, ".png"),
    ];
  });
  const force = options.force === true;
  preflight(planned, force);
  ensureDirectory(outDir);
  for (const target of targets) {
    const profile = profiles[target];
    if (!profile) {
      throw new Error(`未定義の出力先: ${target}`);
    }
    const baseName = basename(svgPath, ".svg");
    const outSvg = resolve(outDir, `${baseName}-${target}.svg`);
    const profiledSvg = applyProfile(sourceSvg, target);
    const profiledErrors = validateSvg(profiledSvg, outSvg);
    if (profiledErrors.length > 0) {
      throw new Error(profiledErrors.join("\n"));
    }
    write(outSvg, profiledSvg, { force });
    validateXmlFile(outSvg);
    write(outSvg.replace(/\.svg$/, ".alt.txt"), alt, { force });
    pngOutput(outSvg, outSvg.replace(/\.svg$/, ".png"), profile, force);
    console.log(
      `✓ ${target}: ${profile.width}x${profile.height} SVG/PNG/alt`,
    );
  }
}

function lint(values) {
  const { positional } = parseOptions(values);
  const inputPath = resolve(positional[0] ?? "");
  if (!positional[0]) {
    throw new Error("SVGまたはディレクトリを指定してください");
  }
  const files = findSvgFiles(inputPath);
  if (files.length === 0) {
    throw new Error("SVGが見つかりません");
  }
  const errors = [];
  for (const file of files) {
    const svg = readFileSync(file, "utf8");
    const svgErrors = validateSvg(svg, file);
    errors.push(...svgErrors);
    if (svgErrors.length === 0) {
      try {
        validateXmlFile(file);
      } catch (error) {
        errors.push(error.message);
      }
    }
    const altPath = siblingAlt(file);
    if (!existsSync(altPath)) {
      errors.push(`${file}: 同名の.alt.txtがありません`);
    } else {
      const altLength = [...readFileSync(altPath, "utf8").trim()].length;
      if (altLength < 12 || altLength > 300) {
        errors.push(`${altPath}: 代替テキストは12〜300文字にしてください`);
      }
    }
  }
  if (errors.length > 0) {
    throw new Error(errors.join("\n"));
  }
  console.log(`✓ ${files.length} SVG: 構文・安全性・altを確認`);
}

function htmlEscape(value) {
  return escapeXml(value);
}

function preview(values) {
  const { positional, options } = parseOptions(values);
  const inputDir = resolve(positional[0] ?? resolve(generatedDir, "templates"));
  const svgFiles = findSvgFiles(inputDir);
  if (svgFiles.length === 0) {
    throw new Error("プレビュー対象のSVGがありません");
  }
  const outPath = options.out
    ? resolve(options.out)
    : resolve(inputDir, "gallery.html");
  const cards = svgFiles
    .map((file) => {
      const src = relative(dirname(outPath), file).split("\\").join("/");
      return `<article><img src="${htmlEscape(src)}" alt=""><h2>${htmlEscape(basename(file, ".svg"))}</h2><code>${htmlEscape(src)}</code></article>`;
    })
    .join("\n");
  const html = `<!doctype html>
<html lang="ja">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>OVS Gallery</title>
  <style>
    :root { color-scheme: light; font-family: ${tokens.font.body}; color: ${tokens.color.ink}; background: ${tokens.color.canvas}; }
    body { margin: 0; padding: 40px; }
    header { max-width: 1200px; margin: 0 auto 32px; }
    h1 { font-family: ${tokens.font.heading}; margin-bottom: 8px; }
    main { display: grid; grid-template-columns: repeat(auto-fit, minmax(360px, 1fr)); gap: 28px; max-width: 1440px; margin: auto; }
    article { background: ${tokens.color.surface}; border: ${tokens.stroke.rule} solid ${tokens.color.ink}; border-radius: ${tokens.radius.card}; box-shadow: ${tokens.shadow.x} ${tokens.shadow.y} 0 ${tokens.color.ink}; overflow: hidden; }
    img { width: 100%; display: block; border-bottom: ${tokens.stroke.hairline} solid ${tokens.color.ink}; }
    h2, code { display: block; margin: 16px 20px; }
    code { color: ${tokens.color.inkSub}; font-size: 12px; overflow-wrap: anywhere; }
  </style>
</head>
<body>
  <header><h1>Otake Visual System</h1><p>${svgFiles.length} assets · v${tokens.meta.version}</p></header>
  <main>${cards}</main>
</body>
</html>`;
  write(outPath, html, { force: options.force === true });
  console.log(`✓ ${svgFiles.length}件のギャラリーを生成: ${outPath}`);
}

function runExternal(commandName, commandArgs, label) {
  const result = spawnSync(commandName, commandArgs, {
    encoding: "utf8",
    maxBuffer: 10 * 1024 * 1024,
  });
  if (result.error?.code === "ENOENT") {
    throw new Error(
      `${label}には${commandName}が必要です。Brewfileを反映してください`,
    );
  }
  if (result.error) {
    throw new Error(
      `${commandName}を実行できません: ${result.error.message}`,
    );
  }
  if (result.status !== 0) {
    const detail = (result.stderr || result.stdout || "").trim();
    throw new Error(`${label}に失敗しました${detail ? `: ${detail}` : ""}`);
  }
}

function parseMermaidDocument(markdown, documentId, defaultSource) {
  const lines = markdown.replaceAll("\r\n", "\n").split("\n");
  const output = [];
  const blocks = [];
  const ids = new Set();

  for (let index = 0; index < lines.length; index += 1) {
    const opening = lines[index].match(
      /^ {0,3}((?:`{3,})|(?:~{3,}))mermaid(?:\s+.*)?\s*$/,
    );
    if (!opening) {
      output.push(lines[index]);
      continue;
    }

    const marker = opening[1][0];
    const minimumLength = opening[1].length;
    const closing = new RegExp(`^ {0,3}${marker}{${minimumLength},}\\s*$`);
    const sourceLines = [];
    let closed = false;
    for (index += 1; index < lines.length; index += 1) {
      if (closing.test(lines[index])) {
        closed = true;
        break;
      }
      sourceLines.push(lines[index]);
    }
    if (!closed) {
      throw new Error("Mermaidコードブロックが閉じていません");
    }

    const source = `${sourceLines.join("\n").trim()}\n`;
    if (/^\s*---\s*$/m.test(source) || /%%\s*\{/.test(source)) {
      throw new Error(
        "Mermaid内のfront matterと設定directiveは使用できません。OVS生成テーマを使ってください",
      );
    }
    const number = blocks.length + 1;
    const rawId =
      source.match(/^\s*%%\s*ovs-id:\s*(.+?)\s*$/m)?.[1] ??
      `${documentId}-diagram-${number}`;
    const id = slugify(rawId);
    if (ids.has(id)) {
      throw new Error(`Mermaidのovs-idが重複しています: ${id}`);
    }
    ids.add(id);

    const title =
      source.match(/^\s*accTitle:\s*(.+?)\s*$/m)?.[1]?.trim() ??
      `図解 ${number}`;
    const alt =
      source.match(/^\s*accDescr:\s*(.+?)\s*$/m)?.[1]?.trim() ?? "";
    const altLength = [...alt].length;
    if (altLength < 12 || altLength > 300) {
      throw new Error(
        `${id}: accDescrは代替テキストとして12〜300文字で指定してください`,
      );
    }
    const sourceLabel =
      source.match(/^\s*%%\s*ovs-source:\s*(.+?)\s*$/m)?.[1]?.trim() ??
      defaultSource;
    if (!sourceLabel) {
      throw new Error(`${id}: ovs-sourceまたは--sourceを指定してください`);
    }

    const placeholder = `<!-- OVS_MERMAID_${randomUUID()}_${number} -->`;
    blocks.push({
      id,
      title,
      alt,
      source: sourceLabel,
      mermaid: source,
      placeholder,
    });
    output.push(placeholder);
  }

  return {
    blocks,
    markdown: output.join("\n"),
  };
}

function markdownHtmlSurface(markdown) {
  const output = [];
  let closing = null;
  for (const line of markdown.split("\n")) {
    if (closing) {
      if (closing.test(line)) {
        closing = null;
      }
      continue;
    }
    const opening = line.match(/^ {0,3}((?:`{3,})|(?:~{3,}))/);
    if (opening) {
      const marker = opening[1][0];
      closing = new RegExp(`^ {0,3}${marker}{${opening[1].length},}\\s*$`);
      continue;
    }
    if (/^(?: {4}|\t)/.test(line)) {
      continue;
    }
    output.push(line.replace(/`+[^`]*`+/g, ""));
  }
  return output.join("\n");
}

function markdownHtmlErrors(markdown, fileName) {
  const html = markdownHtmlSurface(markdown);
  const visibleHtml = html.replace(/<!--[\s\S]*?-->/g, "");
  const errors = [];
  const allowedHtmlElements = new Set([
    "abbr",
    "br",
    "details",
    "kbd",
    "mark",
    "sub",
    "summary",
    "sup",
  ]);
  for (const match of visibleHtml.matchAll(
    /<\/?([A-Za-z][A-Za-z0-9-]*)\b[^>]*>/g,
  )) {
    const element = match[1].toLowerCase();
    if (!allowedHtmlElements.has(element)) {
      errors.push(`${fileName}: HTML要素<${element}>は使用できません`);
    }
  }
  const forbidden = [
    [/<(?:script|iframe|object|embed|style|link|base|svg)[\s>]/i, "危険なHTML要素"],
    [/\son[a-z]+\s*=/i, "イベント属性"],
    [/\sstyle\s*=/i, "style属性"],
    [
      /\s(?:src|href)\s*=\s*["']?\s*(?:javascript|vbscript|data|file|https?):/i,
      "外部または実行可能URL",
    ],
    [/\]\(\s*(?:javascript|vbscript|data|file):/i, "実行可能Markdownリンク"],
    [
      /\]\([^)\n]*&(?:#[xX][0-9A-Fa-f]+|#\d+|[A-Za-z][A-Za-z0-9]+);/i,
      "文字参照を含むMarkdownリンク",
    ],
    [
      /^ {0,3}\[[^\]\n]+\]:[ \t]*<?[ \t]*(?:javascript|vbscript|data|file):/im,
      "実行可能Markdown参照",
    ],
    [
      /^ {0,3}\[[^\]\n]+\]:[^\n]*&(?:#[xX][0-9A-Fa-f]+|#\d+|[A-Za-z][A-Za-z0-9]+);/im,
      "文字参照を含むMarkdown参照",
    ],
  ];
  for (const [pattern, label] of forbidden) {
    if (pattern.test(visibleHtml)) {
      errors.push(`${fileName}: ${label}は使用できません`);
    }
  }
  const frontMatter = markdown.match(
    /^---\s*\n([\s\S]*?)\n---\s*(?:\n|$)/,
  )?.[1];
  if (
    frontMatter &&
    /^(?:style|css|header-includes|include-in-header|include-before(?:-body)?|include-after(?:-body)?|backgroundColor|backgroundImage|color|size)\s*:/im.test(
      frontMatter,
    )
  ) {
    errors.push(
      `${fileName}: front matterからのCSS・HTML注入は使用できません`,
    );
  }
  if (
    /<!--(?:(?!-->)[\s\S])*?_?(?:style|theme|size|backgroundColor|backgroundImage|color)\s*:/i.test(
      html,
    )
  ) {
    errors.push(
      `${fileName}: Marpコメントからのスタイル上書きは使用できません`,
    );
  }
  for (const match of html.matchAll(/<!--([\s\S]*?)-->/g)) {
    const comment = match[1];
    if (!/^\s*_?[A-Za-z][A-Za-z0-9-]*\s*:/m.test(comment)) {
      continue;
    }
    if (
      /<\/?[A-Za-z][A-Za-z0-9-]*\b[^>]*>/.test(comment) ||
      /\]\(\s*(?:javascript|vbscript|data|file):/i.test(comment) ||
      /\]\([^)\n]*&(?:#[xX][0-9A-Fa-f]+|#\d+|[A-Za-z][A-Za-z0-9]+);/i.test(
        comment,
      )
    ) {
      errors.push(
        `${fileName}: Marpコメント内の生HTML・実行可能リンクは使用できません`,
      );
    }
  }
  return errors;
}

function decodeHtmlUrl(value) {
  const named = new Map([
    ["amp", "&"],
    ["colon", ":"],
    ["newline", "\n"],
    ["tab", "\t"],
  ]);
  let decoded = value;
  for (let pass = 0; pass < 3; pass += 1) {
    const next = decoded
      .replace(/&#x([0-9A-Fa-f]+);?/g, (_, digits) =>
        String.fromCodePoint(Number.parseInt(digits, 16)),
      )
      .replace(/&#([0-9]+);?/g, (_, digits) =>
        String.fromCodePoint(Number.parseInt(digits, 10)),
      )
      .replace(/&([A-Za-z]+);/g, (entity, name) =>
        named.get(name.toLowerCase()) ?? entity,
      );
    if (next === decoded) {
      break;
    }
    decoded = next;
  }
  return decoded.replace(/[\u0000-\u0020\u007f]+/g, "");
}

function generatedHtmlErrors(html, fileName) {
  const errors = [];
  const attributes =
    /\b(href|xlink:href|src|action|formaction)\s*=\s*(?:"([^"]*)"|'([^']*)'|([^\s"'`=<>]+))/gi;
  for (const match of html.matchAll(attributes)) {
    const attribute = match[1].toLowerCase();
    const value = decodeHtmlUrl(match[2] ?? match[3] ?? match[4] ?? "");
    const forbiddenSchemes =
      attribute === "src"
        ? /^(?:javascript|vbscript|file):/i
        : /^(?:javascript|vbscript|data|file):/i;
    if (forbiddenSchemes.test(value)) {
      errors.push(
        `${fileName}: 生成HTMLの${attribute}属性に実行可能またはローカルURLがあります`,
      );
    }
  }
  return errors;
}

function mermaidSvgErrors(svg, fileName) {
  const errors = [];
  const forbidden = [
    [/<script[\s>]/i, "script"],
    [/<foreignObject[\s>]/i, "foreignObject"],
    [/<image[\s>]/i, "image"],
    [/<(?:animate|animateMotion|animateTransform|set)[\s>]/i, "アニメーション"],
    [/<!DOCTYPE/i, "DOCTYPE"],
    [/<!ENTITY/i, "ENTITY"],
    [/@import/i, "CSS import"],
    [/\s(?:href|xlink:href)\s*=/i, "href"],
    [/\son[a-z]+\s*=/i, "イベント属性"],
    [
      /(?:url\(\s*["']?(?:https?|file|data):|(?:src|href)\s*=\s*["'](?:https?|file|data):)/i,
      "外部または埋め込みURL",
    ],
  ];
  for (const [pattern, label] of forbidden) {
    if (pattern.test(svg)) {
      errors.push(`${fileName}: 禁止された${label}があります`);
    }
  }
  if (!/<svg\b[^>]*\bviewBox="[^"]+"/.test(svg)) {
    errors.push(`${fileName}: viewBoxがありません`);
  }
  if (!/<title\b/.test(svg) || !/<desc\b/.test(svg)) {
    errors.push(`${fileName}: accTitleまたはaccDescrがSVGへ反映されていません`);
  }
  return errors;
}

function diagramFigure(block) {
  const captionId = `${block.id}-caption`;
  return `<figure class="ovs-diagram" aria-labelledby="${captionId}">
  <img src="assets/${block.id}.svg" alt="${htmlEscape(block.alt)}">
  <figcaption id="${captionId}">
    <span class="ovs-diagram-meta">
      <strong class="ovs-diagram-title">${htmlEscape(block.title)}</strong>
      <span>${htmlEscape(block.source)}</span>
    </span>
    <span class="ovs-brand"><span class="ovs-marker" aria-hidden="true"><i></i><i></i><i></i></span>otake-shol / visual note</span>
  </figcaption>
</figure>`;
}

function marpMarkdown(markdown) {
  const lines = markdown.split("\n");
  if (lines[0]?.trim() !== "---") {
    return `---
marp: true
theme: otake-visual
---

${markdown}`;
  }
  const closing = lines.findIndex(
    (line, index) => index > 0 && line.trim() === "---",
  );
  if (closing === -1) {
    throw new Error("Markdown front matterが閉じていません");
  }
  const header = lines.slice(1, closing);
  const directives = {
    marp: false,
    theme: false,
  };
  const updated = header.map((line) => {
    if (/^marp\s*:/.test(line)) {
      directives.marp = true;
      return "marp: true";
    }
    if (/^theme\s*:/.test(line)) {
      directives.theme = true;
      return "theme: otake-visual";
    }
    return line;
  });
  if (!directives.marp) {
    updated.push("marp: true");
  }
  if (!directives.theme) {
    updated.push("theme: otake-visual");
  }
  return ["---", ...updated, "---", ...lines.slice(closing + 1)].join("\n");
}

function browserExecutable() {
  if (
    process.env.PUPPETEER_EXECUTABLE_PATH &&
    existsSync(process.env.PUPPETEER_EXECUTABLE_PATH)
  ) {
    return process.env.PUPPETEER_EXECUTABLE_PATH;
  }
  for (const commandName of [
    "google-chrome",
    "chromium",
    "chromium-browser",
    "brave-browser",
    "microsoft-edge",
  ]) {
    const result = spawnSync("which", [commandName], { encoding: "utf8" });
    if (result.status === 0 && result.stdout.trim()) {
      return result.stdout.trim();
    }
  }
  for (const [application, executable] of [
    ["Google Chrome.app", "Google Chrome"],
    ["Chromium.app", "Chromium"],
    ["Brave Browser.app", "Brave Browser"],
    ["Microsoft Edge.app", "Microsoft Edge"],
  ]) {
    const candidate = resolve(
      "/",
      "Applications",
      application,
      "Contents",
      "MacOS",
      executable,
    );
    if (existsSync(candidate)) {
      return candidate;
    }
  }
  return "";
}

function document(values) {
  const { positional, options } = parseOptions(values);
  const inputPath = resolve(positional[0] ?? "");
  if (!positional[0] || !existsSync(inputPath)) {
    throw new Error("存在するMarkdownを指定してください");
  }
  if (![".md", ".markdown"].includes(extname(inputPath).toLowerCase())) {
    throw new Error("documentの入力は.mdまたは.markdownです");
  }

  const targets = String(options.target ?? "html,marp")
    .split(",")
    .map((value) => value.trim())
    .filter(Boolean);
  if (targets.length === 0) {
    throw new Error("--targetにはhtmlまたはmarpを指定してください");
  }
  if (new Set(targets).size !== targets.length) {
    throw new Error("documentのtargetは重複できません");
  }
  const unknownTargets = targets.filter(
    (target) => !["html", "marp"].includes(target),
  );
  if (unknownTargets.length > 0) {
    throw new Error(
      `documentのtargetはhtml、marpから選択してください: ${unknownTargets.join(", ")}`,
    );
  }

  let documentId;
  try {
    documentId = slugify(
      options.id ?? basename(inputPath, extname(inputPath)),
    );
  } catch {
    documentId = "document";
  }
  const sourceMarkdown = readFileSync(inputPath, "utf8");
  const parsed = parseMermaidDocument(
    sourceMarkdown,
    documentId,
    String(options.source ?? "筆者作成").trim(),
  );
  const sourceErrors = markdownHtmlErrors(parsed.markdown, inputPath);
  if (sourceErrors.length > 0) {
    throw new Error(sourceErrors.join("\n"));
  }
  const outDir = options.out
    ? resolve(options.out)
    : resolve(dirname(inputPath), "dist");
  const finalAssetsDir = resolve(outDir, "assets");
  const force = options.force === true;
  const generatedMermaidConfig = resolve(generatedDir, "mermaid.json");
  const generatedHtmlTheme = resolve(generatedDir, "html.css");
  const generatedMarpTheme = resolve(generatedDir, "marp.css");
  const requiredGenerated = [
    ...(parsed.blocks.length > 0 ? [generatedMermaidConfig] : []),
    ...(targets.includes("html") ? [generatedHtmlTheme] : []),
    ...(targets.includes("marp") ? [generatedMarpTheme] : []),
  ];
  for (const generatedPath of requiredGenerated) {
    if (!existsSync(generatedPath)) {
      throw new Error(
        `${generatedPath}がありません。先にnode scripts/build.mjsを実行してください`,
      );
    }
  }

  const planned = parsed.blocks.map((block) =>
    resolve(finalAssetsDir, `${block.id}.svg`),
  );
  if (targets.includes("html")) {
    planned.push(
      resolve(finalAssetsDir, "ovs.css"),
      resolve(outDir, `${documentId}.html`),
    );
  }
  if (targets.includes("marp")) {
    planned.push(
      resolve(outDir, `${documentId}.marp.md`),
      resolve(outDir, `${documentId}.marp.html`),
    );
  }
  preflight(planned, force);

  const workDir = mkdtempSync(resolve(tmpdir(), "ovs-document-"));
  try {
    const workAssetsDir = resolve(workDir, "assets");
    const workSourcesDir = resolve(workDir, "sources");
    ensureDirectory(workAssetsDir);
    ensureDirectory(workSourcesDir);
    const browserPath = browserExecutable();
    const puppeteerConfigPath = resolve(workDir, "puppeteer.json");
    if (browserPath) {
      writeFileSync(
        puppeteerConfigPath,
        `${JSON.stringify({ executablePath: browserPath }, null, 2)}\n`,
        "utf8",
      );
    }

    let compiledMarkdown = parsed.markdown;
    for (const block of parsed.blocks) {
      const mermaidPath = resolve(workSourcesDir, `${block.id}.mmd`);
      const svgPath = resolve(workAssetsDir, `${block.id}.svg`);
      writeFileSync(mermaidPath, block.mermaid, "utf8");
      runExternal(
        "mmdc",
        [
          "-i",
          mermaidPath,
          "-o",
          svgPath,
          "-c",
          generatedMermaidConfig,
          "-b",
          "transparent",
          ...(browserPath ? ["-p", puppeteerConfigPath] : []),
          "--quiet",
        ],
        `${block.id}のMermaid SVG生成`,
      );
      const svg = readFileSync(svgPath, "utf8");
      const errors = mermaidSvgErrors(svg, block.id);
      if (errors.length > 0) {
        throw new Error(errors.join("\n"));
      }
      compiledMarkdown = compiledMarkdown.replace(
        block.placeholder,
        diagramFigure(block),
      );
    }

    const outputFiles = new Map();
    for (const block of parsed.blocks) {
      outputFiles.set(
        resolve(finalAssetsDir, `${block.id}.svg`),
        readFileSync(resolve(workAssetsDir, `${block.id}.svg`), "utf8"),
      );
    }

    const title =
      sourceMarkdown.match(/^#\s+(.+?)\s*$/m)?.[1]?.trim() ?? documentId;
    if (targets.includes("html")) {
      const articlePath = resolve(workDir, `${documentId}.article.md`);
      const htmlPath = resolve(workDir, `${documentId}.html`);
      writeFileSync(articlePath, compiledMarkdown, "utf8");
      writeFileSync(
        resolve(workAssetsDir, "ovs.css"),
        readFileSync(generatedHtmlTheme, "utf8"),
        "utf8",
      );
      runExternal(
        "pandoc",
        [
          "--from",
          "gfm+raw_html",
          "--to",
          "html5",
          "--standalone",
          "--css",
          "assets/ovs.css",
          "--metadata",
          "title=",
          "--metadata",
          `pagetitle=${title}`,
          "--output",
          htmlPath,
          articlePath,
        ],
        "HTML生成",
      );
      const html = readFileSync(htmlPath, "utf8");
      const htmlErrors = generatedHtmlErrors(html, htmlPath);
      if (htmlErrors.length > 0) {
        throw new Error(htmlErrors.join("\n"));
      }
      outputFiles.set(
        resolve(finalAssetsDir, "ovs.css"),
        readFileSync(resolve(workAssetsDir, "ovs.css"), "utf8"),
      );
      outputFiles.set(resolve(outDir, `${documentId}.html`), html);
    }

    if (targets.includes("marp")) {
      const marpSource = marpMarkdown(compiledMarkdown);
      const marpPath = resolve(workDir, `${documentId}.marp.md`);
      const marpHtmlPath = resolve(workDir, `${documentId}.marp.html`);
      writeFileSync(marpPath, marpSource, "utf8");
      runExternal(
        "marp",
        [
          "--no-stdin",
          "--html",
          "--theme",
          generatedMarpTheme,
          "--output",
          marpHtmlPath,
          marpPath,
        ],
        "Marp HTML生成",
      );
      const marpHtml = readFileSync(marpHtmlPath, "utf8");
      const marpHtmlErrors = generatedHtmlErrors(marpHtml, marpHtmlPath);
      if (marpHtmlErrors.length > 0) {
        throw new Error(marpHtmlErrors.join("\n"));
      }
      outputFiles.set(
        resolve(outDir, `${documentId}.marp.md`),
        marpSource,
      );
      outputFiles.set(
        resolve(outDir, `${documentId}.marp.html`),
        marpHtml,
      );
    }

    for (const [path, content] of outputFiles) {
      write(path, content, { force });
    }
    console.log(
      `✓ Markdown文書を生成: ${parsed.blocks.length} Mermaid / ${targets.join(", ")}`,
    );
    for (const path of outputFiles.keys()) {
      console.log(`  ${relative(outDir, path)}`);
    }
  } finally {
    rmSync(workDir, { recursive: true, force: true });
  }
}

function list(values) {
  const { positional } = parseOptions(values);
  const kind = positional[0] ?? "parts";
  if (kind === "parts") {
    console.log(parts.join("\n"));
    return;
  }
  if (kind === "charts") {
    console.log(chartTypes.join("\n"));
    return;
  }
  if (kind === "pm") {
    console.log(`gantt         タスクCSV/JSONから工程表を生成（ovs gantt）
roadmap       Now / Next / Laterの計画
wbs           成果物と作業の分解
raci          責任・承認・協議・共有の分担
raid          Risk / Assumption / Issue / Dependency
status-board  週次の進捗・節目・阻害要因
timeline      マイルストーン／ロードマップにも再利用
matrix        ステークホルダー／リスクの2軸整理
line          バーンダウン／バーンアップ（ovs chart --type line）
architecture  依存関係マップ`);
    return;
  }
  if (kind === "targets") {
    for (const [name, profile] of Object.entries(profiles)) {
      console.log(
        `${name.padEnd(10)} ${profile.width}x${profile.height} ${profile.density}`,
      );
    }
    return;
  }
  if (kind === "recipes") {
    const recipeNames = readdirSync(resolve(rootDir, "recipes"))
      .filter((name) => name.endsWith(".json"))
      .map((name) => name.replace(/\.json$/, ""))
      .sort();
    for (const name of recipeNames) {
      const recipe = readJson(resolve(rootDir, "recipes", `${name}.json`));
      console.log(`${recipe.id.padEnd(20)} ${recipe.sequence.join(" → ")}`);
    }
    return;
  }
  if (kind === "icons") {
    const icons = readJson(resolve(rootDir, "icons.json"));
    for (const icon of icons.icons) {
      console.log(`${icon.name.padEnd(12)} ${icon.label}`);
    }
    return;
  }
  throw new Error("listはparts、charts、pm、recipes、targets、iconsから選択してください");
}

try {
  if (["help", "-h", "--help"].includes(command)) {
    help();
  } else if (command === "new") {
    newProject(args);
  } else if (command === "suggest") {
    suggest(args);
  } else if (command === "render") {
    render(args);
  } else if (command === "chart") {
    chart(args);
  } else if (command === "gantt") {
    gantt(args);
  } else if (command === "pm" && args.shift() === "gantt") {
    gantt(args);
  } else if (command === "document") {
    document(args);
  } else if (command === "export") {
    exportSvg(args);
  } else if (command === "lint") {
    lint(args);
  } else if (command === "preview") {
    preview(args);
  } else if (command === "list") {
    list(args);
  } else {
    fail(`未定義のコマンド: ${command}`, 2);
    help();
  }
} catch (error) {
  fail(error.message);
}
