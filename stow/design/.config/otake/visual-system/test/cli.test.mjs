import assert from "node:assert/strict";
import {
  chmodSync,
  existsSync,
  mkdtempSync,
  mkdirSync,
  readFileSync,
  rmSync,
  symlinkSync,
  writeFileSync,
} from "node:fs";
import { tmpdir } from "node:os";
import { resolve } from "node:path";
import { spawnSync } from "node:child_process";
import test from "node:test";
import { parts, rootDir } from "../scripts/core.mjs";

const cli = resolve(rootDir, "scripts", "ovs.mjs");

function run(args, options = {}) {
  const result = spawnSync(process.execPath, [cli, ...args], {
    encoding: "utf8",
    ...options,
  });
  assert.equal(
    result.status,
    0,
    `${args.join(" ")}\nSTDOUT:\n${result.stdout}\nSTDERR:\n${result.stderr}`,
  );
  return result;
}

function fakeDocumentTools(tempDir) {
  const binDir = resolve(tempDir, "bin");
  mkdirSync(binDir);
  const script = `#!/usr/bin/env node
import { basename } from "node:path";
import { readFileSync, writeFileSync } from "node:fs";

const name = basename(process.argv[1]);
const args = process.argv.slice(2);
const outputFlag = name === "mmdc" ? "-o" : "--output";
const outputIndex = args.indexOf(outputFlag);
if (outputIndex === -1 || !args[outputIndex + 1]) {
  process.exit(2);
}
const output = args[outputIndex + 1];
if (name === "mmdc") {
  const input = args[args.indexOf("-i") + 1];
  const source = readFileSync(input, "utf8");
  const title = source.match(/^\\s*accTitle:\\s*(.+?)\\s*$/m)?.[1] ?? "Diagram";
  const desc = source.match(/^\\s*accDescr:\\s*(.+?)\\s*$/m)?.[1] ?? "Diagram description";
  writeFileSync(output, \`<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 420"><title>\${title}</title><desc>\${desc}</desc><rect x="20" y="20" width="760" height="380"/></svg>\\n\`);
} else {
  const input = args.at(-1);
  const source = readFileSync(input, "utf8");
  const body = source.includes("[target\\\\]label]: javascript:")
    ? '<a href="javascript:alert(1)">go</a>'
    : source;
  writeFileSync(output, \`<!doctype html><html><body>\${body}</body></html>\\n\`);
}
`;
  for (const name of ["mmdc", "pandoc", "marp"]) {
    const path = resolve(binDir, name);
    writeFileSync(path, script);
    chmodSync(path, 0o755);
  }
  return binDir;
}

test("ovs newの全パーツを編集なしでrender・lintできる", () => {
  const tempDir = mkdtempSync(resolve(tmpdir(), "ovs-cli-"));
  try {
    for (const part of parts) {
      const slug = `sample-${part}`;
      run(["new", slug, "--part", part, "--out", tempDir]);
      const briefPath = resolve(tempDir, slug, `${slug}.brief.json`);
      const brief = JSON.parse(readFileSync(briefPath, "utf8"));
      brief.output.formats = ["svg"];
      writeFileSync(briefPath, `${JSON.stringify(brief, null, 2)}\n`);
      run([
        "render",
        briefPath,
        "--out",
        resolve(tempDir, slug, "dist"),
      ]);
    }
    const lint = run(["lint", tempDir]);
    assert.match(lint.stdout, new RegExp(`${parts.length} SVG`));
    const gallery = resolve(tempDir, "gallery.html");
    run(["preview", tempDir, "--out", gallery]);
    assert.ok(existsSync(gallery));
  } finally {
    rmSync(tempDir, { recursive: true, force: true });
  }
});

test("ovs ganttがCSVからbrief・SVG・altを生成する", () => {
  const tempDir = mkdtempSync(resolve(tmpdir(), "ovs-gantt-"));
  try {
    const result = run([
      "gantt",
      resolve(rootDir, "examples", "data", "gantt.csv"),
      "--id",
      "release-plan",
      "--title",
      "新機能リリース計画",
      "--today",
      "2026-08-12",
      "--format",
      "svg",
      "--out",
      tempDir,
    ]);
    assert.match(result.stdout, /6タスクのガントチャート/);
    assert.ok(existsSync(resolve(tempDir, "release-plan.brief.json")));
    assert.ok(existsSync(resolve(tempDir, "release-plan-blog.svg")));
    assert.ok(existsSync(resolve(tempDir, "release-plan-blog.alt.txt")));
    const svg = readFileSync(resolve(tempDir, "release-plan-blog.svg"), "utf8");
    assert.match(svg, /要対応 40%/);
    assert.match(svg, /UIデザイン/);
    run(["lint", tempDir]);
  } finally {
    rmSync(tempDir, { recursive: true, force: true });
  }
});

test("ovs ganttは重複targetを部分出力せず拒否する", () => {
  const tempDir = mkdtempSync(resolve(tmpdir(), "ovs-gantt-target-"));
  try {
    const result = spawnSync(
      process.execPath,
      [
        cli,
        "gantt",
        resolve(rootDir, "examples", "data", "gantt.csv"),
        "--id",
        "duplicate-target",
        "--title",
        "重複target",
        "--target",
        "blog,blog",
        "--format",
        "svg",
        "--out",
        tempDir,
      ],
      { encoding: "utf8" },
    );
    assert.notEqual(result.status, 0);
    assert.match(result.stderr, /targetsは重複/);
    assert.equal(existsSync(resolve(tempDir, "duplicate-target-blog.svg")), false);
    assert.equal(
      existsSync(resolve(tempDir, "duplicate-target-blog.alt.txt")),
      false,
    );
  } finally {
    rmSync(tempDir, { recursive: true, force: true });
  }
});

test("list pmが既存パーツのPM用途も案内する", () => {
  const result = run(["list", "pm"]);
  assert.match(result.stdout, /gantt/);
  assert.match(result.stdout, /バーンダウン/);
  assert.match(result.stdout, /ステークホルダー/);
});

test("suggestが記事レシピと図解候補を返す", () => {
  const result = run([
    "suggest",
    resolve(rootDir, "examples", "article.md"),
  ]);
  assert.match(result.stdout, /推奨レシピ:/);
  assert.match(result.stdout, /before-after/);
  assert.match(result.stdout, /architecture/);
  assert.match(result.stdout, /chart/);
});

test("suggestがPM記事をproject-planレシピへ案内する", () => {
  const tempDir = mkdtempSync(resolve(tmpdir(), "ovs-suggest-pm-"));
  try {
    const articlePath = resolve(tempDir, "plan.md");
    writeFileSync(
      articlePath,
      "# リリース計画\n\n工程表で納期と進捗率を確認し、RACIで責任分担を決める。\n",
    );
    const result = run(["suggest", articlePath]);
    assert.match(result.stdout, /推奨レシピ: project-plan/);
    assert.match(result.stdout, /gantt/);
    assert.match(result.stdout, /raci/);
  } finally {
    rmSync(tempDir, { recursive: true, force: true });
  }
});

test("documentがMermaidを共通SVGへ変換してHTMLとMarpを生成する", () => {
  const tempDir = mkdtempSync(resolve(tmpdir(), "ovs-document-test-"));
  try {
    const binDir = fakeDocumentTools(tempDir);
    const inputPath = resolve(tempDir, "system.md");
    const outDir = resolve(tempDir, "dist");
    writeFileSync(
      inputPath,
      `---
title: システム構成
---

# システム構成

<!-- OVS_MERMAID_1 -->

\`\`\`mermaid
flowchart LR
  %% ovs-id: build-flow
  %% ovs-source: 筆者作成・検証用
  accTitle: OVS文書生成フロー
  accDescr: Markdownから共通のSVGを生成し、HTMLとMarpで再利用する処理フロー。
  A[Markdown] --> B[OVS]
  B --> C[HTML]
  B --> D[Marp]
\`\`\`
`,
    );
    const result = run(
      [
        "document",
        inputPath,
        "--target",
        "html,marp",
        "--out",
        outDir,
      ],
      {
        env: {
          ...process.env,
          PATH: `${binDir}:${process.env.PATH}`,
        },
      },
    );
    assert.match(result.stdout, /1 Mermaid/);
    assert.ok(existsSync(resolve(outDir, "assets", "build-flow.svg")));
    assert.ok(existsSync(resolve(outDir, "assets", "ovs.css")));
    assert.ok(existsSync(resolve(outDir, "system.html")));
    assert.ok(existsSync(resolve(outDir, "system.marp.html")));
    const marp = readFileSync(resolve(outDir, "system.marp.md"), "utf8");
    assert.match(marp, /marp: true/);
    assert.match(marp, /theme: otake-visual/);
    assert.match(marp, /class="ovs-diagram"/);
    assert.match(marp, /assets\/build-flow\.svg/);
    assert.match(marp, /otake-shol \/ visual note/);
    assert.match(marp, /筆者作成・検証用/);
    assert.doesNotMatch(marp, /```mermaid/);
    assert.ok(
      marp.indexOf("<!-- OVS_MERMAID_1 -->") <
        marp.indexOf('<figure class="ovs-diagram"'),
    );
  } finally {
    rmSync(tempDir, { recursive: true, force: true });
  }
});

test("documentはaccDescrのないMermaidを拒否する", () => {
  const tempDir = mkdtempSync(resolve(tmpdir(), "ovs-document-alt-"));
  try {
    const inputPath = resolve(tempDir, "missing-alt.md");
    writeFileSync(
      inputPath,
      "# Missing alt\n\n```mermaid\nflowchart LR\n  A --> B\n```\n",
    );
    const result = spawnSync(
      process.execPath,
      [cli, "document", inputPath, "--out", resolve(tempDir, "dist")],
      { encoding: "utf8" },
    );
    assert.notEqual(result.status, 0);
    assert.match(result.stderr, /accDescrは代替テキストとして12〜300文字/);
    assert.equal(existsSync(resolve(tempDir, "dist")), false);
  } finally {
    rmSync(tempDir, { recursive: true, force: true });
  }
});

test("documentは危険な生HTMLを拒否し、コード例内のHTMLは許可する", () => {
  const tempDir = mkdtempSync(resolve(tmpdir(), "ovs-document-html-"));
  try {
    const unsafePath = resolve(tempDir, "unsafe.md");
    writeFileSync(unsafePath, "# Unsafe\n\n<script>alert(1)</script>\n");
    const refused = spawnSync(
      process.execPath,
      [cli, "document", unsafePath, "--target", "html"],
      { encoding: "utf8" },
    );
    assert.notEqual(refused.status, 0);
    assert.match(refused.stderr, /危険なHTML要素は使用できません/);

    const redirectPath = resolve(tempDir, "unsafe-redirect.md");
    writeFileSync(
      redirectPath,
      '# Redirect\n\n<meta http-equiv="refresh" content="0;url=https://example.com">\n',
    );
    const redirectRefused = spawnSync(
      process.execPath,
      [cli, "document", redirectPath, "--target", "html"],
      { encoding: "utf8" },
    );
    assert.notEqual(redirectRefused.status, 0);
    assert.match(redirectRefused.stderr, /HTML要素<meta>は使用できません/);

    const stylePath = resolve(tempDir, "unsafe-style.md");
    writeFileSync(
      stylePath,
      "---\nstyle: |\n  body { background: red; }\n---\n\n# Unsafe style\n",
    );
    const styleRefused = spawnSync(
      process.execPath,
      [cli, "document", stylePath, "--target", "html"],
      { encoding: "utf8" },
    );
    assert.notEqual(styleRefused.status, 0);
    assert.match(styleRefused.stderr, /front matterからのCSS・HTML注入/);

    const themePath = resolve(tempDir, "unsafe-theme.md");
    writeFileSync(
      themePath,
      "# Unsafe theme\n\n<!-- theme: gaia -->\n",
    );
    const themeRefused = spawnSync(
      process.execPath,
      [cli, "document", themePath, "--target", "marp"],
      { encoding: "utf8" },
    );
    assert.notEqual(themeRefused.status, 0);
    assert.match(themeRefused.stderr, /Marpコメントからのスタイル上書き/);

    const footerPath = resolve(tempDir, "unsafe-footer.md");
    writeFileSync(
      footerPath,
      "# Unsafe footer\n\n<!-- footer: <script>alert(1)</script> -->\n",
    );
    const footerRefused = spawnSync(
      process.execPath,
      [cli, "document", footerPath, "--target", "marp"],
      { encoding: "utf8" },
    );
    assert.notEqual(footerRefused.status, 0);
    assert.match(
      footerRefused.stderr,
      /Marpコメント内の生HTML・実行可能リンク/,
    );

    const encodedLinkPath = resolve(tempDir, "unsafe-link.md");
    writeFileSync(
      encodedLinkPath,
      "# Unsafe link\n\n[go](jav&#x61;script:alert(1))\n",
    );
    const encodedLinkRefused = spawnSync(
      process.execPath,
      [cli, "document", encodedLinkPath, "--target", "html"],
      { encoding: "utf8" },
    );
    assert.notEqual(encodedLinkRefused.status, 0);
    assert.match(encodedLinkRefused.stderr, /文字参照を含むMarkdownリンク/);

    const binDir = fakeDocumentTools(tempDir);
    const referenceLinkPath = resolve(tempDir, "unsafe-reference.md");
    writeFileSync(
      referenceLinkPath,
      "# Unsafe reference\n\n[go][target\\]label]\n\n[target\\]label]: javascript:alert(1)\n",
    );
    const referenceLinkRefused = spawnSync(
      process.execPath,
      [
        cli,
        "document",
        referenceLinkPath,
        "--target",
        "html",
        "--out",
        resolve(tempDir, "unsafe-reference-dist"),
      ],
      {
        encoding: "utf8",
        env: {
          ...process.env,
          PATH: `${binDir}:${process.env.PATH}`,
        },
      },
    );
    assert.notEqual(referenceLinkRefused.status, 0);
    assert.match(referenceLinkRefused.stderr, /生成HTMLのhref属性/);

    const safePath = resolve(tempDir, "safe.md");
    const outDir = resolve(tempDir, "safe-dist");
    writeFileSync(
      safePath,
      "# Safe\n\n```html\n<script>alert(1)</script>\n```\n",
    );
    run(
      ["document", safePath, "--target", "html", "--out", outDir],
      {
        env: {
          ...process.env,
          PATH: `${binDir}:${process.env.PATH}`,
        },
      },
    );
    assert.ok(existsSync(resolve(outDir, "safe.html")));
  } finally {
    rmSync(tempDir, { recursive: true, force: true });
  }
});

test("documentはMermaid側のテーマ上書きを拒否する", () => {
  const tempDir = mkdtempSync(resolve(tmpdir(), "ovs-document-theme-"));
  try {
    const inputPath = resolve(tempDir, "override.md");
    writeFileSync(
      inputPath,
      "# Override\n\n```mermaid\n%%{init: {\"theme\": \"dark\"}}%%\nflowchart LR\n  accDescr: OVSテーマを上書きしようとする検証用のMermaid図。\n  A --> B\n```\n",
    );
    const result = spawnSync(
      process.execPath,
      [cli, "document", inputPath, "--target", "html"],
      { encoding: "utf8" },
    );
    assert.notEqual(result.status, 0);
    assert.match(result.stderr, /OVS生成テーマを使ってください/);
  } finally {
    rmSync(tempDir, { recursive: true, force: true });
  }
});

test("既存出力は拒否し、forceでもシンボリックリンクは上書きしない", () => {
  const tempDir = mkdtempSync(resolve(tmpdir(), "ovs-overwrite-"));
  try {
    const source = JSON.parse(
      readFileSync(resolve(rootDir, "templates", "brief.json"), "utf8"),
    );
    source.meta.id = "overwrite-check";
    source.output.formats = ["svg"];
    const briefPath = resolve(tempDir, "brief.json");
    writeFileSync(briefPath, `${JSON.stringify(source, null, 2)}\n`);
    run(["render", briefPath, "--out", tempDir]);

    const refused = spawnSync(
      process.execPath,
      [cli, "render", briefPath, "--out", tempDir],
      { encoding: "utf8" },
    );
    assert.notEqual(refused.status, 0);
    assert.match(refused.stderr, /既に存在/);
    run(["render", briefPath, "--out", tempDir, "--force"]);

    const svgPath = resolve(tempDir, "overwrite-check-blog.svg");
    const outside = resolve(tempDir, "must-not-change.txt");
    writeFileSync(outside, "original\n");
    rmSync(svgPath);
    symlinkSync(outside, svgPath);
    const symlinkRefused = spawnSync(
      process.execPath,
      [cli, "render", briefPath, "--out", tempDir, "--force"],
      { encoding: "utf8" },
    );
    assert.notEqual(symlinkRefused.status, 0);
    assert.match(symlinkRefused.stderr, /シンボリックリンク/);
    assert.equal(readFileSync(outside, "utf8"), "original\n");

    const realOutDir = resolve(tempDir, "real-out");
    const linkedOutDir = resolve(tempDir, "linked-out");
    mkdirSync(realOutDir);
    symlinkSync(realOutDir, linkedOutDir, "dir");
    const parentSymlinkRefused = spawnSync(
      process.execPath,
      [cli, "render", briefPath, "--out", linkedOutDir],
      { encoding: "utf8" },
    );
    assert.notEqual(parentSymlinkRefused.status, 0);
    assert.match(parentSymlinkRefused.stderr, /親ディレクトリ.*シンボリックリンク/);
    assert.equal(
      existsSync(resolve(realOutDir, "overwrite-check-blog.svg")),
      false,
    );
  } finally {
    rmSync(tempDir, { recursive: true, force: true });
  }
});

const rsvgAvailable =
  spawnSync("rsvg-convert", ["--version"], { encoding: "utf8" }).status === 0;

test(
  "renderが媒体寸法どおりのPNGとaltを生成する",
  { skip: !rsvgAvailable },
  () => {
    const tempDir = mkdtempSync(resolve(tmpdir(), "ovs-png-"));
    try {
      const sample = JSON.parse(
        readFileSync(resolve(rootDir, "examples", "chart.brief.json"), "utf8"),
      );
      sample.output.targets = ["ogp", "square"];
      const briefPath = resolve(tempDir, "chart.brief.json");
      writeFileSync(briefPath, `${JSON.stringify(sample, null, 2)}\n`);
      run(["render", briefPath, "--out", tempDir]);

      const dimensions = {
        ogp: [1200, 630],
        square: [1080, 1080],
      };
      for (const [target, expected] of Object.entries(dimensions)) {
        const png = readFileSync(
          resolve(tempDir, `sample-article-chart-${target}.png`),
        );
        assert.equal(png.toString("ascii", 1, 4), "PNG");
        assert.equal(png.readUInt32BE(16), expected[0]);
        assert.equal(png.readUInt32BE(20), expected[1]);
        assert.ok(
          existsSync(
            resolve(tempDir, `sample-article-chart-${target}.alt.txt`),
          ),
        );
      }
    } finally {
      rmSync(tempDir, { recursive: true, force: true });
    }
  },
);
