#!/usr/bin/env node

import {
  existsSync,
  mkdirSync,
  readFileSync,
  readdirSync,
  rmSync,
  writeFileSync,
} from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { renderTokenSource, validateSvg } from "./core.mjs";

const scriptDir = dirname(fileURLToPath(import.meta.url));
const rootDir = resolve(scriptDir, "..");
const sourcePath = resolve(rootDir, "tokens.json");
const templateDir = resolve(rootDir, "templates");
const recipeDir = resolve(rootDir, "recipes");
const outputDir = resolve(rootDir, "generated");
const checkOnly = process.argv.includes("--check");
const tokens = JSON.parse(readFileSync(sourcePath, "utf8"));
const icons = JSON.parse(readFileSync(resolve(rootDir, "icons.json"), "utf8"));
const templateNames = readdirSync(templateDir)
  .filter((name) => name.endsWith(".svg.tpl"))
  .map((name) => name.replace(".svg.tpl", ""))
  .sort();
const recipes = readdirSync(recipeDir)
  .filter((name) => name.endsWith(".json"))
  .map((name) => JSON.parse(readFileSync(resolve(recipeDir, name), "utf8")));
const failures = [];
const expectedOutputs = new Set();

function kebab(value) {
  return value
    .replace(/([a-z0-9])([A-Z])/g, "$1-$2")
    .replace(/[^a-zA-Z0-9]+/g, "-")
    .toLowerCase();
}

function flatten(value, prefix = []) {
  const entries = [];
  for (const [key, child] of Object.entries(value)) {
    const path = [...prefix, key];
    if (child !== null && typeof child === "object") {
      entries.push(...flatten(child, path));
    } else {
      entries.push([path, child]);
    }
  }
  return entries;
}

function token(path) {
  let value = tokens;
  for (const key of path.split(".")) {
    value = value?.[key];
  }
  if (value === undefined || (value !== null && typeof value === "object")) {
    throw new Error(`未定義のトークン: ${path}`);
  }
  return String(value);
}

function relativeLuminance(hex) {
  const channels = [1, 3, 5].map((index) => {
    const value = Number.parseInt(hex.slice(index, index + 2), 16) / 255;
    return value <= 0.04045
      ? value / 12.92
      : ((value + 0.055) / 1.055) ** 2.4;
  });
  return 0.2126 * channels[0] + 0.7152 * channels[1] + 0.0722 * channels[2];
}

function contrastRatio(foreground, background) {
  const values = [
    relativeLuminance(foreground),
    relativeLuminance(background),
  ].sort((a, b) => b - a);
  return (values[0] + 0.05) / (values[1] + 0.05);
}

function validateContrasts() {
  const pairs = [
    ["color.ink", "color.canvas", 7],
    ["color.inkSub", "color.canvas", 4.5],
    ["color.inkMute", "color.canvas", 4.5],
    ["color.primary", "color.surface", 4.5],
    ["color.wine", "color.surface", 4.5],
    ["color.violet", "color.surface", 4.5],
    ["color.ink", "color.coral", 4.5],
    ["color.ink", "color.mint", 4.5],
    ["color.ink", "color.mango", 4.5],
  ];
  for (const [foregroundPath, backgroundPath, minimum] of pairs) {
    const ratio = contrastRatio(token(foregroundPath), token(backgroundPath));
    if (ratio < minimum) {
      throw new Error(
        `コントラスト不足: ${foregroundPath} / ${backgroundPath} = ${ratio.toFixed(2)}（必要 ${minimum}）`,
      );
    }
  }
}

function validateSystemData() {
  const iconNames = icons.icons.map((icon) => icon.name);
  if (new Set(iconNames).size !== iconNames.length) {
    throw new Error("icons.jsonに重複したnameがあります");
  }
  for (const [name, profile] of Object.entries(tokens.output)) {
    if (
      !Number.isInteger(profile.width) ||
      !Number.isInteger(profile.height) ||
      profile.width <= 0 ||
      profile.height <= 0 ||
      !Number.isInteger(profile.safe) ||
      profile.safe <= 0
    ) {
      throw new Error(`output.${name}: width/height/safeは正の整数が必要です`);
    }
    if (!["full", "compact"].includes(profile.density)) {
      throw new Error(`output.${name}: densityはfullまたはcompactです`);
    }
  }
  for (const recipe of recipes) {
    if (
      !/^[a-z0-9-]+$/.test(recipe.id ?? "") ||
      !recipe.name ||
      !Array.isArray(recipe.sequence) ||
      recipe.sequence.length === 0
    ) {
      throw new Error("recipeにはid、name、1件以上のsequenceが必要です");
    }
    const unknownParts = recipe.sequence.filter(
      (part) => !templateNames.includes(part),
    );
    if (unknownParts.length > 0) {
      throw new Error(`${recipe.id}: 未定義のパーツ ${unknownParts.join(", ")}`);
    }
  }
}

function renderTemplate(source, fileName) {
  const rendered = renderTokenSource(source, fileName);
  const errors = validateSvg(rendered, fileName);
  if (errors.length > 0) {
    throw new Error(errors.join("\n"));
  }
  return rendered;
}

function emit(relativePath, content) {
  expectedOutputs.add(relativePath);
  const target = resolve(outputDir, relativePath);
  const normalized = content.endsWith("\n") ? content : `${content}\n`;
  if (checkOnly) {
    if (!existsSync(target) || readFileSync(target, "utf8") !== normalized) {
      failures.push(relativePath);
    }
    return;
  }
  mkdirSync(dirname(target), { recursive: true });
  writeFileSync(target, normalized);
}

function renderIcon(icon) {
  if (!/^[a-z0-9-]+$/.test(icon.name)) {
    throw new Error(`不正なアイコン名: ${icon.name}`);
  }
  if (!icon.label || !Array.isArray(icon.paths) || icon.paths.length === 0) {
    throw new Error(`${icon.name}: labelとpathsが必要です`);
  }
  for (const path of icon.paths) {
    if (
      typeof path !== "string" ||
      /[<>{}"']/.test(path) ||
      !/^[MmLlHhVvCcSsQqTtAaZz0-9.,+\-\s]+$/.test(path)
    ) {
      throw new Error(`${icon.name}: 不正なSVG pathです`);
    }
  }
  return `<svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="${icons.meta.viewBox}" role="img" aria-labelledby="title">
  <title id="title">${icon.label}</title>
  <g fill="none" stroke="${tokens.color.ink}" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
    ${icon.paths.map((path) => `<path d="${path}"/>`).join("\n    ")}
  </g>
</svg>`;
}

function listFiles(dir, prefix = "") {
  if (!existsSync(dir)) {
    return [];
  }
  return readdirSync(dir, { withFileTypes: true }).flatMap((entry) => {
    const relativePath = prefix ? `${prefix}/${entry.name}` : entry.name;
    if (entry.isDirectory()) {
      return listFiles(resolve(dir, entry.name), relativePath);
    }
    return [relativePath];
  });
}

validateContrasts();
validateSystemData();

const cssLines = flatten(tokens)
  .filter(([path]) => path[0] !== "meta")
  .map(([path, value]) => `  --ovs-${path.map(kebab).join("-")}: ${value};`);

emit(
  "tokens.css",
  [
    `/* Generated from tokens.json — ${tokens.meta.name} ${tokens.meta.version} */`,
    ":root {",
    ...cssLines,
    "}",
  ].join("\n"),
);

emit(
  "tokens.mjs",
  [
    `// Generated from tokens.json — ${tokens.meta.name} ${tokens.meta.version}`,
    `export const tokens = ${JSON.stringify(tokens, null, 2)};`,
    "export default tokens;",
  ].join("\n"),
);

for (const fileName of readdirSync(templateDir).filter((name) =>
  name.endsWith(".svg.tpl"),
)) {
  const source = readFileSync(resolve(templateDir, fileName), "utf8");
  emit(
    `templates/${fileName.replace(/\.tpl$/, "")}`,
    renderTemplate(source, fileName),
  );
}

for (const icon of icons.icons) {
  emit(`icons/${icon.name}.svg`, renderIcon(icon));
}

const themeSource = readFileSync(
  resolve(rootDir, "themes", "marp.css.tpl"),
  "utf8",
);
emit("marp.css", renderTokenSource(themeSource, "marp.css.tpl"));

const htmlThemeSource = readFileSync(
  resolve(rootDir, "themes", "html.css.tpl"),
  "utf8",
);
emit("html.css", renderTokenSource(htmlThemeSource, "html.css.tpl"));

emit(
  "mermaid.json",
  JSON.stringify(
    {
      theme: "base",
      securityLevel: "strict",
      htmlLabels: false,
      fontFamily: tokens.font.body,
      themeVariables: {
        background: tokens.color.canvas,
        primaryColor: tokens.color.primaryWash,
        primaryTextColor: tokens.color.ink,
        primaryBorderColor: tokens.color.ink,
        secondaryColor: tokens.color.wineWash,
        secondaryTextColor: tokens.color.ink,
        secondaryBorderColor: tokens.color.wine,
        tertiaryColor: tokens.color.mangoWash,
        tertiaryTextColor: tokens.color.ink,
        tertiaryBorderColor: tokens.color.mango,
        lineColor: tokens.color.primaryDark,
        textColor: tokens.color.ink,
        mainBkg: tokens.color.surface,
        secondBkg: tokens.color.primaryWash,
        border1: tokens.color.ink,
        border2: tokens.color.primaryDark,
        noteBkgColor: tokens.color.mangoWash,
        noteTextColor: tokens.color.ink,
        noteBorderColor: tokens.color.mango,
        actorBkg: tokens.color.surface,
        actorBorder: tokens.color.ink,
        actorTextColor: tokens.color.ink,
        actorLineColor: tokens.color.inkSub,
        signalColor: tokens.color.primaryDark,
        signalTextColor: tokens.color.ink,
        labelBoxBkgColor: tokens.color.primaryWash,
        labelBoxBorderColor: tokens.color.primary,
        labelTextColor: tokens.color.ink,
        loopTextColor: tokens.color.ink,
        activationBorderColor: tokens.color.wine,
        activationBkgColor: tokens.color.wineWash,
        sequenceNumberColor: tokens.color.surface,
        fontSize: tokens.type.label,
      },
      flowchart: {
        htmlLabels: false,
        curve: "basis",
        useMaxWidth: true,
      },
      sequence: {
        useMaxWidth: true,
      },
    },
    null,
    2,
  ),
);

emit(
  "manifest.json",
  JSON.stringify(
    {
      name: tokens.meta.name,
      version: tokens.meta.version,
      parts: templateNames,
      charts: [
        "bar",
        "line",
        "stacked-bar",
        "dot",
        "slope",
        "scatter",
        "heatmap",
        "waterfall",
        "small-multiples",
        "progress",
      ],
      icons: icons.icons.map((icon) => icon.name),
      recipes: recipes.map((recipe) => recipe.id).sort(),
      targets: Object.keys(tokens.output),
      documentTargets: ["html", "marp"],
    },
    null,
    2,
  ),
);

for (const relativePath of listFiles(outputDir)) {
  if (
    relativePath === "gallery.html" ||
    expectedOutputs.has(relativePath)
  ) {
    continue;
  }
  if (checkOnly) {
    failures.push(`余剰生成物:${relativePath}`);
  } else {
    rmSync(resolve(outputDir, relativePath));
  }
}

if (checkOnly && failures.length > 0) {
  console.error(`生成物が古いか不足しています: ${failures.join(", ")}`);
  process.exitCode = 1;
} else if (checkOnly) {
  console.log("✓ visual-system generated files are current");
} else {
  console.log(`✓ generated ${outputDir}`);
}
