import {
  existsSync,
  readFileSync,
  readdirSync,
  statSync,
} from "node:fs";
import { dirname, extname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const scriptDir = dirname(fileURLToPath(import.meta.url));

export const rootDir = resolve(scriptDir, "..");
export const generatedDir = resolve(rootDir, "generated");
export const tokens = JSON.parse(
  readFileSync(resolve(rootDir, "tokens.json"), "utf8"),
);
export const profiles = tokens.output;
export const parts = [
  "cover",
  "flow",
  "matrix",
  "comparison",
  "chart",
  "before-after",
  "timeline",
  "architecture",
  "sequence",
  "takeaway",
  "warning",
  "definition",
  "gantt",
  "roadmap",
  "wbs",
  "raci",
  "raid",
  "status-board",
];
export const chartTypes = [
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
];

const palette = [
  tokens.color.primary,
  tokens.color.coral,
  tokens.color.mint,
  tokens.color.violet,
];

export function escapeXml(value) {
  return String(value)
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&apos;");
}

export function slugify(value) {
  const slug = String(value)
    .normalize("NFKC")
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "");
  if (!slug) {
    throw new Error("IDは半角英数字を含めてください");
  }
  return slug;
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

export function renderTokenSource(source, fileName = "source") {
  let rendered = source.replace(
    /\{\{>([a-zA-Z0-9-]+)\}\}/g,
    (_match, componentName) => {
      const componentPath = resolve(
        rootDir,
        "components",
        `${componentName}.svg.tpl`,
      );
      if (!existsSync(componentPath)) {
        throw new Error(`${fileName}: 未定義のコンポーネント ${componentName}`);
      }
      return readFileSync(componentPath, "utf8").trim();
    },
  );
  rendered = rendered.replace(
    /\{\{([a-zA-Z0-9.]+)\}\}/g,
    (_match, path) => {
      try {
        return token(path);
      } catch (error) {
        throw new Error(`${fileName}: ${error.message}`);
      }
    },
  );
  if (/\{\{[^}]+\}\}/.test(rendered)) {
    throw new Error(`${fileName}: 未解決のテンプレート変数があります`);
  }
  return rendered;
}

export function readJson(filePath) {
  try {
    return JSON.parse(readFileSync(filePath, "utf8"));
  } catch (error) {
    throw new Error(`${filePath}: JSONを読めません: ${error.message}`);
  }
}

export function sourceLabel(source) {
  const base = source?.label?.trim();
  if (!base) {
    return "";
  }
  const url = source.url?.trim();
  let urlLabel = "";
  if (url) {
    try {
      urlLabel = new URL(url).hostname;
    } catch {
      urlLabel = url.length > 48 ? `${url.slice(0, 45)}...` : url;
    }
  }
  const accessedAt = source.accessedAt?.trim();
  const suffix = [urlLabel, accessedAt && `参照 ${accessedAt}`]
    .filter(Boolean)
    .join(" / ");
  return suffix ? `${base} — ${suffix}` : base;
}

function isoDateValue(value) {
  if (!/^\d{4}-\d{2}-\d{2}$/.test(String(value ?? ""))) {
    return null;
  }
  const [year, month, day] = String(value).split("-").map(Number);
  const timestamp = Date.UTC(year, month - 1, day);
  const date = new Date(timestamp);
  if (
    date.getUTCFullYear() !== year ||
    date.getUTCMonth() !== month - 1 ||
    date.getUTCDate() !== day
  ) {
    return null;
  }
  return timestamp;
}

export function validateBrief(brief) {
  const errors = [];
  if (!brief || typeof brief !== "object" || Array.isArray(brief)) {
    return ["briefはJSONオブジェクトで指定してください"];
  }
  const id = brief.meta?.id;
  if (!/^[a-z0-9][a-z0-9-]*$/.test(id ?? "")) {
    errors.push("meta.idは半角小文字・数字・ハイフンで指定してください");
  }
  if (!parts.includes(brief.meta?.part)) {
    errors.push(`meta.partは次から選択してください: ${parts.join(", ")}`);
  }
  if (!brief.intent?.message?.trim()) {
    errors.push("intent.messageは必須です");
  } else if ([...brief.intent.message].length > 80) {
    errors.push("intent.messageは80文字以内です");
  }
  if (!brief.intent?.audience?.trim()) {
    errors.push("intent.audienceは必須です");
  }
  if (!brief.content?.title?.trim()) {
    errors.push("content.titleは必須です");
  } else {
    const titleLength = [...brief.content.title].length;
    const maxTitle = brief.meta?.part === "cover" ? 48 : 34;
    if (titleLength > maxTitle) {
      errors.push(`content.titleは${maxTitle}文字以内です`);
    }
  }
  if ([...(brief.content?.subtitle ?? "")].length > 80) {
    errors.push("content.subtitleは80文字以内です");
  }
  if (!brief.source?.label?.trim()) {
    errors.push("source.labelは必須です。自作の場合は「筆者作成」とします");
  } else if ([...brief.source.label].length > 48) {
    errors.push("source.labelは48文字以内です");
  }
  if (brief.source?.url) {
    try {
      const sourceUrl = new URL(brief.source.url);
      if (!["http:", "https:"].includes(sourceUrl.protocol)) {
        errors.push("source.urlはhttpまたはhttps URLにしてください");
      }
    } catch {
      errors.push("source.urlは有効なURLにしてください");
    }
  }
  const altLength = [...(brief.accessibility?.alt ?? "")].length;
  if (altLength < 12 || altLength > 300) {
    errors.push("accessibility.altは12〜300文字で指定してください");
  }
  if (brief.accessibility?.colorIndependent !== true) {
    errors.push("accessibility.colorIndependentはtrueが必須です");
  }
  const targets = brief.output?.targets;
  if (!Array.isArray(targets) || targets.length === 0) {
    errors.push("output.targetsを1つ以上指定してください");
  } else {
    if (new Set(targets).size !== targets.length) {
      errors.push("output.targetsは重複しないようにしてください");
    }
    for (const target of targets) {
      if (!profiles[target]) {
        errors.push(`未定義の出力先: ${target}`);
      }
    }
  }
  const formats = brief.output?.formats;
  if (
    !Array.isArray(formats) ||
    formats.length === 0 ||
    formats.some((format) => !["svg", "png"].includes(format))
  ) {
    errors.push("output.formatsはsvgまたはpngを1つ以上指定してください");
  } else if (new Set(formats).size !== formats.length) {
    errors.push("output.formatsは重複しないようにしてください");
  }
  if (brief.meta?.part === "chart") {
    if (!chartTypes.includes(brief.data?.type)) {
      errors.push(`data.typeは次から選択してください: ${chartTypes.join(", ")}`);
    }
    if (!Array.isArray(brief.data?.rows) || brief.data.rows.length === 0) {
      errors.push("chartにはdata.rowsが1件以上必要です");
    } else {
      const numericFields = {
        slope: ["start", "end"],
        scatter: ["x", "y"],
      }[brief.data.type] ?? ["value"];
      for (const [index, row] of brief.data.rows.entries()) {
        for (const key of numericFields) {
          if (!Number.isFinite(Number(row[key]))) {
            errors.push(`data.rows[${index}].${key}は有限数で指定してください`);
          }
        }
        if (
          ["bar", "stacked-bar", "progress"].includes(brief.data.type) &&
          Number(row.value) < 0
        ) {
          errors.push(
            `data.rows[${index}].valueは${brief.data.type}では0以上にしてください`,
          );
        }
        if (brief.data.type === "progress" && Number(row.value) > 100) {
          errors.push(`data.rows[${index}].valueはprogressでは100以下にしてください`);
        }
      }
    }
  } else if (brief.meta?.part === "gantt") {
    if (brief.data?.type !== "gantt") {
      errors.push("ganttにはdata.type=\"gantt\"が必要です");
    }
    if (!Array.isArray(brief.data?.rows) || brief.data.rows.length === 0) {
      errors.push("ganttにはdata.rowsが1件以上必要です");
    } else {
      if (brief.data.rows.length > 8) {
        errors.push("ganttのタスクは1枚8件までです。超える場合はフェーズで分割してください");
      }
      const ids = new Set();
      const dependencies = new Map();
      const allowedStatuses = new Set([
        "planned",
        "active",
        "blocked",
        "done",
      ]);
      const tasks = new Map();
      for (const [index, row] of brief.data.rows.entries()) {
        const id = String(row.id ?? `task-${index + 1}`);
        if (!/^[a-z0-9][a-z0-9-]*$/.test(id)) {
          errors.push(
            `data.rows[${index}].idは半角小文字・数字・ハイフンで指定してください`,
          );
        }
        if (ids.has(id)) {
          errors.push(`data.rows[${index}].idが重複しています: ${id}`);
        }
        ids.add(id);
        tasks.set(id, row);
        const dependsOn = Array.isArray(row.dependsOn)
          ? row.dependsOn
          : String(row.dependsOn ?? row.dependency ?? "")
              .split(/[|;]/)
              .map((value) => value.trim())
              .filter(Boolean);
        dependencies.set(id, dependsOn);
        if (!String(row.task ?? "").trim()) {
          errors.push(`data.rows[${index}].taskは必須です`);
        } else if ([...String(row.task)].length > 16) {
          errors.push(`data.rows[${index}].taskは16文字以内にしてください`);
        }
        if ([...String(row.owner ?? "")].length > 12) {
          errors.push(`data.rows[${index}].ownerは12文字以内にしてください`);
        }
        const start = isoDateValue(row.start);
        const end = isoDateValue(row.end);
        if (start === null) {
          errors.push(`data.rows[${index}].startはYYYY-MM-DD形式の実在日が必要です`);
        }
        if (end === null) {
          errors.push(`data.rows[${index}].endはYYYY-MM-DD形式の実在日が必要です`);
        }
        if (start !== null && end !== null && start > end) {
          errors.push(`data.rows[${index}]はstartをend以前にしてください`);
        }
        const progress = Number(row.progress ?? 0);
        if (!Number.isFinite(progress) || progress < 0 || progress > 100) {
          errors.push(`data.rows[${index}].progressは0〜100にしてください`);
        }
        const status =
          String(row.status ?? "").trim().toLowerCase() || "planned";
        if (!allowedStatuses.has(status)) {
          errors.push(
            `data.rows[${index}].statusはplanned/active/blocked/doneから選択してください`,
          );
        }
      }
      for (const [id, dependsOn] of dependencies) {
        for (const dependency of dependsOn) {
          if (!ids.has(dependency)) {
            errors.push(`${id}の依存先が見つかりません: ${dependency}`);
          } else {
            const predecessorEnd = isoDateValue(tasks.get(dependency)?.end);
            const successorStart = isoDateValue(tasks.get(id)?.start);
            if (
              predecessorEnd !== null &&
              successorStart !== null &&
              predecessorEnd >= successorStart
            ) {
              errors.push(
                `${id}は依存タスク${dependency}の終了翌日以降に開始してください`,
              );
            }
          }
          if (dependency === id) {
            errors.push(`${id}は自分自身へ依存できません`);
          }
        }
      }
      const visited = new Set();
      const visiting = new Set();
      const hasCycle = (id) => {
        if (visiting.has(id)) return true;
        if (visited.has(id)) return false;
        visiting.add(id);
        const cyclic = (dependencies.get(id) ?? []).some(
          (dependency) => dependencies.has(dependency) && hasCycle(dependency),
        );
        visiting.delete(id);
        visited.add(id);
        return cyclic;
      };
      if ([...dependencies.keys()].some((id) => hasCycle(id))) {
        errors.push("ganttの依存関係に循環があります");
      }
    }
    for (const field of ["start", "end", "today"]) {
      if (brief.data?.[field] && isoDateValue(brief.data[field]) === null) {
        errors.push(`data.${field}はYYYY-MM-DD形式の実在日が必要です`);
      }
    }
    const domainStart = brief.data?.start
      ? isoDateValue(brief.data.start)
      : null;
    const domainEnd = brief.data?.end ? isoDateValue(brief.data.end) : null;
    if (
      domainStart !== null &&
      domainEnd !== null &&
      domainStart > domainEnd
    ) {
      errors.push("data.startはdata.end以前にしてください");
    }
    if (
      domainStart !== null &&
      domainEnd !== null &&
      (domainEnd - domainStart) / 86_400_000 >= 366
    ) {
      errors.push("ganttの表示期間は366日以内にしてください");
    }
    if (Array.isArray(brief.data?.rows)) {
      const taskStarts = brief.data.rows
        .map((row) => isoDateValue(row.start))
        .filter((value) => value !== null);
      const taskEnds = brief.data.rows
        .map((row) => isoDateValue(row.end))
        .filter((value) => value !== null);
      const displayedStart =
        domainStart ?? (taskStarts.length > 0 ? Math.min(...taskStarts) : null);
      const displayedEnd =
        domainEnd ?? (taskEnds.length > 0 ? Math.max(...taskEnds) : null);
      if (
        displayedStart !== null &&
        displayedEnd !== null &&
        (displayedEnd - displayedStart) / 86_400_000 >= 366
      ) {
        errors.push("ganttの表示期間は366日以内にしてください");
      }
      for (const [index, row] of brief.data.rows.entries()) {
        const start = isoDateValue(row.start);
        const end = isoDateValue(row.end);
        if (domainStart !== null && start !== null && start < domainStart) {
          errors.push(`data.rows[${index}].startが表示期間より前です`);
        }
        if (domainEnd !== null && end !== null && end > domainEnd) {
          errors.push(`data.rows[${index}].endが表示期間より後です`);
        }
      }
    }
  }
  return [...new Set(errors)];
}

function wrap(value, maxCharacters, maxLines = 2) {
  const explicit = String(value).split(/\r?\n/);
  const lines = [];
  for (const paragraph of explicit) {
    let current = "";
    for (const character of [...paragraph]) {
      if ([...current].length >= maxCharacters) {
        lines.push(current);
        current = "";
      }
      current += character;
    }
    if (current || paragraph === "") {
      lines.push(current);
    }
  }
  if (lines.length > maxLines) {
    throw new Error(
      `「${value}」は長すぎます。${maxCharacters}文字×${maxLines}行以内に短縮してください`,
    );
  }
  return lines;
}

function replaceTextSlot(svg, slot, value, options = {}) {
  const escapedSlot = slot.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
  const pattern = new RegExp(
    `(<text\\b[^>]*data-slot="${escapedSlot}"[^>]*>)([\\s\\S]*?)(</text>)`,
  );
  const match = svg.match(pattern);
  if (!match) {
    return { svg, found: false };
  }
  const opening = match[1];
  const x = opening.match(/\bx="([^"]+)"/)?.[1] ?? "0";
  const lines = wrap(
    value,
    options.maxCharacters ?? 80,
    options.maxLines ?? 1,
  );
  const lineHeight = options.lineHeight ?? 32;
  const body =
    lines.length === 1
      ? escapeXml(lines[0])
      : lines
          .map(
            (line, index) =>
              `<tspan x="${escapeXml(x)}" dy="${index === 0 ? 0 : lineHeight}">${escapeXml(line)}</tspan>`,
          )
          .join("");
  return {
    svg: svg.replace(pattern, (_match, openingTag, _currentBody, closingTag) =>
      `${openingTag}${body}${closingTag}`,
    ),
    found: true,
  };
}

function renderStaticBrief(brief) {
  const templatePath = resolve(
    generatedDir,
    "templates",
    `${brief.meta.part}.svg`,
  );
  if (!existsSync(templatePath)) {
    throw new Error(
      `${brief.meta.part}の生成済みテンプレートがありません。先に build.mjs を実行してください`,
    );
  }
  let svg = readFileSync(templatePath, "utf8");
  const values = {
    eyebrow: brief.content.eyebrow ?? brief.meta.part.toUpperCase(),
    title: brief.content.title,
    subtitle: brief.content.subtitle ?? "",
    source: sourceLabel(brief.source),
    ...(brief.content.slots ?? {}),
  };
  const requiredSlots = new Set(["title", ...Object.keys(brief.content.slots ?? {})]);
  for (const [slot, value] of Object.entries(values)) {
    const isTitle = slot === "title";
    const isBody = slot.startsWith("body-");
    const result = replaceTextSlot(svg, slot, value, {
      maxCharacters: isTitle && brief.meta.part === "cover" ? 18 : isBody ? 18 : 80,
      maxLines: isTitle && brief.meta.part === "cover" ? 2 : isBody ? 2 : 1,
      lineHeight: isTitle ? 68 : 32,
    });
    svg = result.svg;
    if (requiredSlots.has(slot) && !result.found) {
      throw new Error(`${brief.meta.part}: data-slot="${slot}" がありません`);
    }
  }
  svg = svg.replace(
    /<title id="title">[\s\S]*?<\/title>/,
    `<title id="title">${escapeXml(brief.content.title)}</title>`,
  );
  svg = svg.replace(
    /<desc id="desc">[\s\S]*?<\/desc>/,
    `<desc id="desc">${escapeXml(brief.accessibility.alt)}</desc>`,
  );
  return svg;
}

function brandAt(x = 892, y = 586) {
  const component = renderTokenSource(
    readFileSync(resolve(rootDir, "components", "brand.svg.tpl"), "utf8"),
    "brand.svg.tpl",
  ).trim();
  return `<g transform="translate(${x} ${y})">${component}</g>`;
}

function chartShell(brief, chartBody) {
  const title = escapeXml(brief.content.title);
  const subtitle = escapeXml(
    brief.content.subtitle ||
      [brief.data?.unit && `単位: ${brief.data.unit}`, brief.data?.period]
        .filter(Boolean)
        .join("　"),
  );
  return `<svg xmlns="http://www.w3.org/2000/svg" width="1200" height="675" viewBox="0 0 1200 675" role="img" aria-labelledby="title desc">
  <title id="title">${title}</title>
  <desc id="desc">${escapeXml(brief.accessibility.alt)}</desc>
  <rect width="1200" height="675" fill="${tokens.color.canvas}"/>
  <rect x="64" y="54" width="112" height="36" rx="18" fill="${tokens.color.mint}"/>
  <text data-slot="eyebrow" x="120" y="79" text-anchor="middle" fill="${tokens.color.ink}" font-family="${tokens.font.numeric}" font-size="${tokens.type.label}" font-weight="700">CHART</text>
  <text data-slot="title" x="64" y="144" fill="${tokens.color.ink}" font-family="${tokens.font.heading}" font-size="${tokens.type.title}" font-weight="700">${title}</text>
  <text data-slot="subtitle" x="66" y="183" fill="${tokens.color.inkSub}" font-family="${tokens.font.body}" font-size="${tokens.type.body}">${subtitle}</text>
  ${chartBody}
  <text data-slot="source" x="64" y="620" fill="${tokens.color.inkMute}" font-family="${tokens.font.body}" font-size="${tokens.type.caption}">${escapeXml(sourceLabel(brief.source))}</text>
  ${brandAt()}
</svg>`;
}

function finite(value, label) {
  const number = Number(value);
  if (!Number.isFinite(number)) {
    throw new Error(`${label}は有限数で指定してください`);
  }
  return number;
}

function rowLabel(row, index) {
  return String(row.category ?? row.label ?? row.name ?? `項目 ${index + 1}`);
}

function valueDomain(values, includeZero = true) {
  const finiteValues = values.map((value, index) => finite(value, `値${index + 1}`));
  const min = Math.min(...finiteValues, includeZero ? 0 : Infinity);
  const max = Math.max(...finiteValues, includeZero ? 0 : -Infinity);
  return min === max ? [min, min + 1] : [min, max];
}

function position(value, domain, start, end) {
  return (
    start + ((finite(value, "座標値") - domain[0]) / (domain[1] - domain[0])) * (end - start)
  );
}

function renderBar(rows, unit) {
  const limited = rows.slice(0, 6);
  const values = limited.map((row) => finite(row.value, "value"));
  const [, max] = valueDomain(values);
  const rowGap = Math.min(62, 300 / limited.length);
  return `<g transform="translate(64 230)">
    <line x1="210" y1="0" x2="210" y2="310" stroke="${tokens.color.ink}" stroke-width="${tokens.stroke.rule}"/>
    ${limited
      .map((row, index) => {
        const value = values[index];
        const width = Math.max(3, (value / max) * 760);
        const y = index * rowGap + 10;
        return `<text x="188" y="${y + 27}" text-anchor="end" fill="${tokens.color.ink}" font-family="${tokens.font.body}" font-size="${tokens.type.body}">${escapeXml(rowLabel(row, index))}</text>
    <rect x="210" y="${y}" width="${width.toFixed(1)}" height="36" rx="12" fill="${palette[index % palette.length]}" stroke="${tokens.color.ink}" stroke-width="${tokens.stroke.hairline}"/>
    <text x="${Math.min(1010, 228 + width).toFixed(1)}" y="${y + 27}" fill="${tokens.color.ink}" font-family="${tokens.font.numeric}" font-size="${tokens.type.body}" font-weight="700">${escapeXml(value)}${escapeXml(unit)}</text>`;
      })
      .join("\n")}
  </g>`;
}

function groupedRows(rows) {
  const map = new Map();
  for (const [index, row] of rows.entries()) {
    const name = String(row.series ?? "値");
    if (!map.has(name)) {
      map.set(name, []);
    }
    map.get(name).push({ ...row, _index: index });
  }
  return [...map.entries()].slice(0, 4);
}

function renderLine(rows, unit) {
  const groups = groupedRows(rows);
  const allValues = rows.map((row) => finite(row.value, "value"));
  const domain = valueDomain(allValues);
  const maxPoints = Math.max(...groups.map(([, items]) => items.length));
  const xAt = (index) => 250 + (index / Math.max(1, maxPoints - 1)) * 790;
  const yAt = (value) => position(value, domain, 520, 238);
  return `<g>
    <line x1="250" y1="220" x2="250" y2="520" stroke="${tokens.color.ink}" stroke-width="${tokens.stroke.rule}"/>
    <line x1="250" y1="520" x2="1050" y2="520" stroke="${tokens.color.ink}" stroke-width="${tokens.stroke.rule}"/>
    ${groups
      .map(([series, items], seriesIndex) => {
        const color = palette[seriesIndex];
        const points = items
          .map((row, index) => `${xAt(index).toFixed(1)},${yAt(row.value).toFixed(1)}`)
          .join(" ");
        return `<polyline points="${points}" fill="none" stroke="${color}" stroke-width="5" stroke-linecap="round" stroke-linejoin="round"/>
      ${items
        .map(
          (row, index) =>
            `<circle cx="${xAt(index).toFixed(1)}" cy="${yAt(row.value).toFixed(1)}" r="8" fill="${tokens.color.surface}" stroke="${color}" stroke-width="4"/>
        <text x="${xAt(index).toFixed(1)}" y="550" text-anchor="middle" fill="${tokens.color.inkSub}" font-family="${tokens.font.body}" font-size="${tokens.type.caption}">${escapeXml(rowLabel(row, index))}</text>`,
        )
        .join("\n")}
      <text x="1065" y="${yAt(items.at(-1).value).toFixed(1)}" fill="${color}" font-family="${tokens.font.body}" font-size="${tokens.type.label}" font-weight="700">${escapeXml(series)} ${escapeXml(items.at(-1).value)}${escapeXml(unit)}</text>`;
      })
      .join("\n")}
  </g>`;
}

function renderStackedBar(rows, unit) {
  const categories = [...new Set(rows.map((row, index) => rowLabel(row, index)))].slice(0, 5);
  const series = [...new Set(rows.map((row) => String(row.series ?? "値")))].slice(0, 4);
  const sums = categories.map((category) =>
    rows
      .filter((row, index) => rowLabel(row, index) === category)
      .reduce((sum, row) => sum + Math.max(0, finite(row.value, "value")), 0),
  );
  const max = Math.max(...sums, 1);
  return `<g transform="translate(64 235)">
    ${categories
      .map((category, categoryIndex) => {
        let x = 210;
        const segments = series
          .map((seriesName, seriesIndex) => {
            const value = rows
              .filter(
                (row, index) =>
                  rowLabel(row, index) === category &&
                  String(row.series ?? "値") === seriesName,
              )
              .reduce((sum, row) => sum + Math.max(0, finite(row.value, "value")), 0);
            const width = (value / max) * 760;
            const segment = `<rect x="${x.toFixed(1)}" y="${categoryIndex * 58}" width="${width.toFixed(1)}" height="36" fill="${palette[seriesIndex]}" stroke="${tokens.color.ink}" stroke-width="${tokens.stroke.hairline}"/>`;
            x += width;
            return segment;
          })
          .join("");
        return `<text x="188" y="${categoryIndex * 58 + 26}" text-anchor="end" fill="${tokens.color.ink}" font-family="${tokens.font.body}" font-size="${tokens.type.body}">${escapeXml(category)}</text>
        ${segments}
        <text x="${Math.min(1030, x + 12).toFixed(1)}" y="${categoryIndex * 58 + 26}" fill="${tokens.color.ink}" font-family="${tokens.font.numeric}" font-size="${tokens.type.label}" font-weight="700">${sums[categoryIndex]}${escapeXml(unit)}</text>`;
      })
      .join("\n")}
    ${series
      .map(
        (name, index) =>
          `<circle cx="${250 + index * 180}" cy="322" r="7" fill="${palette[index]}"/><text x="${265 + index * 180}" y="328" fill="${tokens.color.inkSub}" font-family="${tokens.font.body}" font-size="${tokens.type.caption}">${escapeXml(name)}</text>`,
      )
      .join("\n")}
  </g>`;
}

function renderDot(rows, unit) {
  const limited = rows.slice(0, 7);
  const values = limited.map((row) => finite(row.value, "value"));
  const domain = valueDomain(values);
  return `<g transform="translate(64 226)">
    <line x1="230" y1="0" x2="230" y2="318" stroke="${tokens.color.ink}" stroke-width="${tokens.stroke.rule}"/>
    ${limited
      .map((row, index) => {
        const y = 18 + index * 44;
        const x = position(values[index], domain, 250, 980);
        return `<line x1="230" y1="${y}" x2="1000" y2="${y}" stroke="${tokens.color.rule}" stroke-width="${tokens.stroke.hairline}"/>
        <text x="208" y="${y + 7}" text-anchor="end" fill="${tokens.color.ink}" font-family="${tokens.font.body}" font-size="${tokens.type.label}">${escapeXml(rowLabel(row, index))}</text>
        <circle cx="${x.toFixed(1)}" cy="${y}" r="11" fill="${palette[index % palette.length]}" stroke="${tokens.color.ink}" stroke-width="${tokens.stroke.rule}"/>
        <text x="${(x + 20).toFixed(1)}" y="${y + 7}" fill="${tokens.color.ink}" font-family="${tokens.font.numeric}" font-size="${tokens.type.label}" font-weight="700">${values[index]}${escapeXml(unit)}</text>`;
      })
      .join("\n")}
  </g>`;
}

function renderSlope(rows, unit) {
  const limited = rows.slice(0, 6);
  const values = limited.flatMap((row) => [
    finite(row.start, "start"),
    finite(row.end, "end"),
  ]);
  const domain = valueDomain(values, false);
  const yAt = (value) => position(value, domain, 515, 230);
  return `<g>
    <line x1="340" y1="220" x2="340" y2="525" stroke="${tokens.color.ink}" stroke-width="${tokens.stroke.rule}"/>
    <line x1="860" y1="220" x2="860" y2="525" stroke="${tokens.color.ink}" stroke-width="${tokens.stroke.rule}"/>
    <text x="340" y="210" text-anchor="middle" fill="${tokens.color.ink}" font-family="${tokens.font.heading}" font-size="${tokens.type.label}" font-weight="700">BEFORE</text>
    <text x="860" y="210" text-anchor="middle" fill="${tokens.color.ink}" font-family="${tokens.font.heading}" font-size="${tokens.type.label}" font-weight="700">AFTER</text>
    ${limited
      .map((row, index) => {
        const start = finite(row.start, "start");
        const end = finite(row.end, "end");
        const color = palette[index % palette.length];
        return `<line x1="340" y1="${yAt(start).toFixed(1)}" x2="860" y2="${yAt(end).toFixed(1)}" stroke="${color}" stroke-width="4"/>
        <circle cx="340" cy="${yAt(start).toFixed(1)}" r="7" fill="${color}"/>
        <circle cx="860" cy="${yAt(end).toFixed(1)}" r="7" fill="${color}"/>
        <text x="320" y="${(yAt(start) + 6).toFixed(1)}" text-anchor="end" fill="${tokens.color.ink}" font-family="${tokens.font.numeric}" font-size="${tokens.type.caption}">${start}${escapeXml(unit)}</text>
        <text x="880" y="${(yAt(end) + 6).toFixed(1)}" fill="${tokens.color.ink}" font-family="${tokens.font.body}" font-size="${tokens.type.caption}">${escapeXml(rowLabel(row, index))} ${end}${escapeXml(unit)}</text>`;
      })
      .join("\n")}
  </g>`;
}

function renderScatter(rows, unit) {
  const limited = rows.slice(0, 20);
  const xDomain = valueDomain(limited.map((row) => finite(row.x, "x")), false);
  const yDomain = valueDomain(limited.map((row) => finite(row.y, "y")), false);
  return `<g>
    <line x1="220" y1="220" x2="220" y2="525" stroke="${tokens.color.ink}" stroke-width="${tokens.stroke.rule}"/>
    <line x1="220" y1="525" x2="1050" y2="525" stroke="${tokens.color.ink}" stroke-width="${tokens.stroke.rule}"/>
    ${limited
      .map((row, index) => {
        const x = position(row.x, xDomain, 250, 1020);
        const y = position(row.y, yDomain, 500, 240);
        return `<circle cx="${x.toFixed(1)}" cy="${y.toFixed(1)}" r="10" fill="${palette[index % palette.length]}" stroke="${tokens.color.ink}" stroke-width="${tokens.stroke.hairline}"/>
        <text x="${(x + 14).toFixed(1)}" y="${(y - 12).toFixed(1)}" fill="${tokens.color.inkSub}" font-family="${tokens.font.body}" font-size="${tokens.type.caption}">${escapeXml(rowLabel(row, index))}</text>`;
      })
      .join("\n")}
    <text x="1050" y="555" text-anchor="end" fill="${tokens.color.inkSub}" font-family="${tokens.font.body}" font-size="${tokens.type.caption}">X ${escapeXml(unit)}</text>
    <text x="185" y="230" text-anchor="end" fill="${tokens.color.inkSub}" font-family="${tokens.font.body}" font-size="${tokens.type.caption}">Y ${escapeXml(unit)}</text>
  </g>`;
}

function heatColor(value, domain) {
  const ratio = (finite(value, "value") - domain[0]) / (domain[1] - domain[0]);
  if (ratio < 0.25) return tokens.color.primaryWash;
  if (ratio < 0.5) return tokens.color.mangoWash;
  if (ratio < 0.75) return tokens.color.mango;
  return tokens.color.coral;
}

function renderHeatmap(rows, unit) {
  const xs = [...new Set(rows.map((row) => String(row.x)))].slice(0, 6);
  const ys = [...new Set(rows.map((row) => String(row.y)))].slice(0, 5);
  const domain = valueDomain(rows.map((row) => finite(row.value, "value")), false);
  const cellWidth = 720 / Math.max(1, xs.length);
  const cellHeight = 270 / Math.max(1, ys.length);
  return `<g transform="translate(250 240)">
    ${xs
      .map(
        (label, index) =>
          `<text x="${index * cellWidth + cellWidth / 2}" y="-16" text-anchor="middle" fill="${tokens.color.inkSub}" font-family="${tokens.font.body}" font-size="${tokens.type.caption}">${escapeXml(label)}</text>`,
      )
      .join("\n")}
    ${ys
      .map(
        (label, index) =>
          `<text x="-18" y="${index * cellHeight + cellHeight / 2 + 6}" text-anchor="end" fill="${tokens.color.inkSub}" font-family="${tokens.font.body}" font-size="${tokens.type.caption}">${escapeXml(label)}</text>`,
      )
      .join("\n")}
    ${rows
      .filter((row) => xs.includes(String(row.x)) && ys.includes(String(row.y)))
      .map((row) => {
        const xIndex = xs.indexOf(String(row.x));
        const yIndex = ys.indexOf(String(row.y));
        const value = finite(row.value, "value");
        return `<rect x="${(xIndex * cellWidth).toFixed(1)}" y="${(yIndex * cellHeight).toFixed(1)}" width="${cellWidth.toFixed(1)}" height="${cellHeight.toFixed(1)}" fill="${heatColor(value, domain)}" stroke="${tokens.color.ink}" stroke-width="${tokens.stroke.hairline}"/>
        <text x="${(xIndex * cellWidth + cellWidth / 2).toFixed(1)}" y="${(yIndex * cellHeight + cellHeight / 2 + 7).toFixed(1)}" text-anchor="middle" fill="${tokens.color.ink}" font-family="${tokens.font.numeric}" font-size="${tokens.type.label}" font-weight="700">${value}${escapeXml(unit)}</text>`;
      })
      .join("\n")}
  </g>`;
}

function renderWaterfall(rows, unit) {
  const limited = rows.slice(0, 8);
  let cumulative = 0;
  const steps = limited.map((row, index) => {
    const start = cumulative;
    const value = finite(row.value, "value");
    cumulative += value;
    return { label: rowLabel(row, index), start, end: cumulative, value };
  });
  const domain = valueDomain(steps.flatMap((step) => [step.start, step.end]));
  const yAt = (value) => position(value, domain, 515, 235);
  const width = 740 / Math.max(1, steps.length);
  return `<g>
    <line x1="230" y1="${yAt(0).toFixed(1)}" x2="1040" y2="${yAt(0).toFixed(1)}" stroke="${tokens.color.ink}" stroke-width="${tokens.stroke.rule}"/>
    ${steps
      .map((step, index) => {
        const x = 250 + index * width;
        const y = Math.min(yAt(step.start), yAt(step.end));
        const height = Math.max(3, Math.abs(yAt(step.start) - yAt(step.end)));
        const color = step.value >= 0 ? tokens.color.mint : tokens.color.coral;
        return `<rect x="${x.toFixed(1)}" y="${y.toFixed(1)}" width="${(width - 18).toFixed(1)}" height="${height.toFixed(1)}" fill="${color}" stroke="${tokens.color.ink}" stroke-width="${tokens.stroke.hairline}"/>
        <text x="${(x + (width - 18) / 2).toFixed(1)}" y="${Math.max(230, y - 10).toFixed(1)}" text-anchor="middle" fill="${tokens.color.ink}" font-family="${tokens.font.numeric}" font-size="${tokens.type.caption}" font-weight="700">${step.value > 0 ? "+" : ""}${step.value}${escapeXml(unit)}</text>
        <text x="${(x + (width - 18) / 2).toFixed(1)}" y="555" text-anchor="middle" fill="${tokens.color.inkSub}" font-family="${tokens.font.body}" font-size="${tokens.type.caption}">${escapeXml(step.label)}</text>`;
      })
      .join("\n")}
  </g>`;
}

function renderSmallMultiples(rows, unit) {
  const groups = groupedRows(rows);
  return `<g transform="translate(70 220)">
    ${groups
      .map(([series, items], groupIndex) => {
        const panelX = (groupIndex % 2) * 540;
        const panelY = Math.floor(groupIndex / 2) * 170;
        const domain = valueDomain(items.map((row) => finite(row.value, "value")));
        const points = items
          .map((row, index) => {
            const x = panelX + 40 + (index / Math.max(1, items.length - 1)) * 430;
            const y = panelY + position(row.value, domain, 130, 40);
            return `${x.toFixed(1)},${y.toFixed(1)}`;
          })
          .join(" ");
        return `<rect x="${panelX}" y="${panelY}" width="500" height="145" rx="18" fill="${tokens.color.surface}" stroke="${tokens.color.ink}" stroke-width="${tokens.stroke.hairline}"/>
        <text x="${panelX + 20}" y="${panelY + 28}" fill="${tokens.color.ink}" font-family="${tokens.font.heading}" font-size="${tokens.type.label}" font-weight="700">${escapeXml(series)}</text>
        <polyline points="${points}" fill="none" stroke="${palette[groupIndex]}" stroke-width="4" stroke-linecap="round" stroke-linejoin="round"/>
        <text x="${panelX + 475}" y="${panelY + 28}" text-anchor="end" fill="${palette[groupIndex]}" font-family="${tokens.font.numeric}" font-size="${tokens.type.caption}" font-weight="700">${escapeXml(items.at(-1).value)}${escapeXml(unit)}</text>`;
      })
      .join("\n")}
  </g>`;
}

function renderProgress(rows, unit) {
  const limited = rows.slice(0, 4);
  return `<g transform="translate(80 235)">
    ${limited
      .map((row, index) => {
        const value = Math.max(0, Math.min(100, finite(row.value, "value")));
        const y = index * 75;
        return `<text x="0" y="${y + 22}" fill="${tokens.color.ink}" font-family="${tokens.font.body}" font-size="${tokens.type.body}" font-weight="700">${escapeXml(rowLabel(row, index))}</text>
        <rect x="220" y="${y}" width="740" height="34" rx="17" fill="${tokens.color.sunken}" stroke="${tokens.color.ink}" stroke-width="${tokens.stroke.hairline}"/>
        <rect x="220" y="${y}" width="${(740 * value / 100).toFixed(1)}" height="34" rx="17" fill="${palette[index % palette.length]}"/>
        <text x="980" y="${y + 24}" fill="${tokens.color.ink}" font-family="${tokens.font.numeric}" font-size="${tokens.type.body}" font-weight="700">${value}${escapeXml(unit || "%")}</text>`;
      })
      .join("\n")}
  </g>`;
}

export function renderChart(brief) {
  const rows = brief.data.rows;
  const unit = brief.data.unit ?? "";
  const renderers = {
    bar: renderBar,
    line: renderLine,
    "stacked-bar": renderStackedBar,
    dot: renderDot,
    slope: renderSlope,
    scatter: renderScatter,
    heatmap: renderHeatmap,
    waterfall: renderWaterfall,
    "small-multiples": renderSmallMultiples,
    progress: renderProgress,
  };
  return chartShell(brief, renderers[brief.data.type](rows, unit));
}

const dayMs = 86_400_000;

function ganttDependencies(row) {
  return Array.isArray(row.dependsOn)
    ? row.dependsOn.map(String)
    : String(row.dependsOn ?? row.dependency ?? "")
        .split(/[|;]/)
        .map((value) => value.trim())
        .filter(Boolean);
}

function ganttDateLabel(timestamp, durationDays) {
  const date = new Date(timestamp);
  const month = date.getUTCMonth() + 1;
  const day = date.getUTCDate();
  if (durationDays > 120) {
    return `${date.getUTCFullYear()}/${month}`;
  }
  return `${month}/${day}`;
}

function ganttTickStep(durationDays) {
  if (durationDays <= 21) return 3;
  if (durationDays <= 70) return 7;
  if (durationDays <= 180) return 28;
  return 56;
}

export function renderGantt(brief) {
  const rows = brief.data.rows;
  const starts = rows.map((row) => isoDateValue(row.start));
  const ends = rows.map((row) => isoDateValue(row.end));
  const domainStart = brief.data.start
    ? isoDateValue(brief.data.start)
    : Math.min(...starts);
  const domainEnd = brief.data.end
    ? isoDateValue(brief.data.end)
    : Math.max(...ends);
  const durationDays = Math.max(1, (domainEnd - domainStart) / dayMs + 1);
  const timelineX = 390;
  const timelineWidth = 650;
  const rowTop = 252;
  const rowHeight = 39;
  const xAt = (timestamp) =>
    timelineX +
    ((timestamp - domainStart) / (durationDays * dayMs)) * timelineWidth;
  const taskById = new Map(
    rows.map((row, index) => [
      String(row.id ?? `task-${index + 1}`),
      { row, index },
    ]),
  );
  const colors = {
    planned: [tokens.color.violet, tokens.color.violetWash],
    active: [tokens.color.primary, tokens.color.primaryWash],
    blocked: [tokens.color.coral, tokens.color.coralWash],
    done: [tokens.color.mint, tokens.color.mintWash],
  };
  const statusLabels = {
    planned: "予定",
    active: "進行中",
    blocked: "要対応",
    done: "完了",
  };
  const dependencyLines = rows
    .flatMap((row, index) =>
      ganttDependencies(row).map((dependency) => {
        const predecessor = taskById.get(dependency);
        if (!predecessor) return "";
        const fromX = xAt(isoDateValue(predecessor.row.end) + dayMs);
        const toX = xAt(isoDateValue(row.start));
        const fromY = rowTop + predecessor.index * rowHeight + 14;
        const toY = rowTop + index * rowHeight + 14;
        const elbowX = Math.min(
          timelineX + timelineWidth - 8,
          Math.max(fromX + 10, toX - 10),
        );
        return `<path d="M${fromX.toFixed(1)} ${fromY}H${elbowX.toFixed(1)}V${toY}H${Math.max(timelineX, toX - 5).toFixed(1)}" fill="none" stroke="${tokens.color.inkMute}" stroke-width="${tokens.stroke.hairline}" stroke-dasharray="5 4"/>
        <polygon points="${toX.toFixed(1)},${toY} ${(toX - 7).toFixed(1)},${toY - 4} ${(toX - 7).toFixed(1)},${toY + 4}" fill="${tokens.color.inkMute}"/>`;
      }),
    )
    .join("\n");
  const ticks = [];
  const tickStep = ganttTickStep(durationDays);
  for (let day = 0; day < durationDays; day += tickStep) {
    const timestamp = domainStart + day * dayMs;
    ticks.push({
      x: xAt(timestamp),
      label: ganttDateLabel(timestamp, durationDays),
    });
  }
  if (ticks.at(-1)?.x < timelineX + timelineWidth - 44) {
    ticks.push({
      x: xAt(domainEnd),
      label: ganttDateLabel(domainEnd, durationDays),
    });
  }
  const today = brief.data.today ? isoDateValue(brief.data.today) : null;
  const todayLine =
    today !== null && today >= domainStart && today <= domainEnd
      ? `<line x1="${xAt(today).toFixed(1)}" y1="218" x2="${xAt(today).toFixed(1)}" y2="570" stroke="${tokens.color.wine}" stroke-width="${tokens.stroke.rule}" stroke-dasharray="7 5"/>
      <rect x="${(xAt(today) - 30).toFixed(1)}" y="202" width="60" height="24" rx="12" fill="${tokens.color.wine}"/>
      <text x="${xAt(today).toFixed(1)}" y="219" text-anchor="middle" fill="${tokens.color.surface}" font-family="${tokens.font.body}" font-size="${tokens.type.caption}" font-weight="700">TODAY</text>`
      : "";
  const title = escapeXml(brief.content.title);
  const subtitle = escapeXml(
    brief.content.subtitle ||
      `${ganttDateLabel(domainStart, durationDays)}–${ganttDateLabel(domainEnd, durationDays)} / ${rows.length} tasks`,
  );
  return `<svg xmlns="http://www.w3.org/2000/svg" width="1200" height="675" viewBox="0 0 1200 675" role="img" aria-labelledby="title desc">
  <title id="title">${title}</title>
  <desc id="desc">${escapeXml(brief.accessibility.alt)}</desc>
  <rect width="1200" height="675" fill="${tokens.color.canvas}"/>
  <rect x="64" y="54" width="120" height="36" rx="18" fill="${tokens.color.wine}"/>
  <text data-slot="eyebrow" x="124" y="79" text-anchor="middle" fill="${tokens.color.surface}" font-family="${tokens.font.numeric}" font-size="${tokens.type.label}" font-weight="700">GANTT</text>
  <text data-slot="title" x="64" y="144" fill="${tokens.color.ink}" font-family="${tokens.font.heading}" font-size="${tokens.type.title}" font-weight="700">${title}</text>
  <text data-slot="subtitle" x="66" y="183" fill="${tokens.color.inkSub}" font-family="${tokens.font.body}" font-size="${tokens.type.body}">${subtitle}</text>

  <text x="64" y="232" fill="${tokens.color.inkSub}" font-family="${tokens.font.body}" font-size="${tokens.type.caption}" font-weight="700">TASK</text>
  <text x="282" y="232" fill="${tokens.color.inkSub}" font-family="${tokens.font.body}" font-size="${tokens.type.caption}" font-weight="700">OWNER</text>
  ${ticks
    .map(
      (tick) =>
        `<line x1="${tick.x.toFixed(1)}" y1="238" x2="${tick.x.toFixed(1)}" y2="570" stroke="${tokens.color.rule}" stroke-width="${tokens.stroke.hairline}"/>
  <text x="${tick.x.toFixed(1)}" y="232" text-anchor="middle" fill="${tokens.color.inkSub}" font-family="${tokens.font.numeric}" font-size="${tokens.type.caption}">${escapeXml(tick.label)}</text>`,
    )
    .join("\n")}
  ${rows
    .map(
      (_row, index) =>
        `<line x1="64" y1="${rowTop + index * rowHeight + 32}" x2="1136" y2="${rowTop + index * rowHeight + 32}" stroke="${tokens.color.rule}" stroke-width="${tokens.stroke.hairline}"/>`,
    )
    .join("\n")}
  ${dependencyLines}
  ${rows
    .map((row, index) => {
      const status =
        String(row.status ?? "").trim().toLowerCase() || "planned";
      const [strong, wash] = colors[status];
      const start = isoDateValue(row.start);
      const end = isoDateValue(row.end);
      const barX = xAt(start);
      const barWidth = Math.max(14, xAt(end + dayMs) - barX);
      const progress = Number(row.progress ?? 0);
      const progressWidth = Math.max(0, barWidth * (progress / 100));
      const y = rowTop + index * rowHeight;
      const isMilestone =
        row.milestone === true ||
        String(row.milestone).toLowerCase() === "true" ||
        start === end;
      const bar =
        isMilestone
          ? `<polygon points="${xAt(end).toFixed(1)},${y + 2} ${(xAt(end) + 12).toFixed(1)},${y + 14} ${xAt(end).toFixed(1)},${y + 26} ${(xAt(end) - 12).toFixed(1)},${y + 14}" fill="${strong}" stroke="${tokens.color.ink}" stroke-width="${tokens.stroke.hairline}"/>`
          : `<rect x="${barX.toFixed(1)}" y="${y + 3}" width="${barWidth.toFixed(1)}" height="23" rx="9" fill="${wash}" stroke="${tokens.color.ink}" stroke-width="${tokens.stroke.hairline}"/>
        ${progressWidth > 0 ? `<rect x="${barX.toFixed(1)}" y="${y + 3}" width="${progressWidth.toFixed(1)}" height="23" rx="9" fill="${strong}"/>` : ""}`;
      return `<text x="64" y="${y + 21}" fill="${tokens.color.ink}" font-family="${tokens.font.body}" font-size="${tokens.type.label}" font-weight="700">${escapeXml(String(row.task))}</text>
      <text x="282" y="${y + 21}" fill="${tokens.color.inkSub}" font-family="${tokens.font.body}" font-size="${tokens.type.caption}">${escapeXml(String(row.owner ?? "—"))}</text>
      ${bar}
      <text x="1128" y="${y + 21}" text-anchor="end" fill="${strong}" font-family="${tokens.font.body}" font-size="${tokens.type.caption}" font-weight="700">${statusLabels[status]} ${progress}%</text>`;
    })
    .join("\n")}
  ${todayLine}
  <g transform="translate(64 582)" font-family="${tokens.font.body}" font-size="${tokens.type.caption}">
    ${Object.entries(statusLabels)
      .map(
        ([status, label], index) =>
          `<rect x="${index * 108}" y="-8" width="14" height="14" rx="4" fill="${colors[status][0]}" stroke="${tokens.color.ink}" stroke-width="${tokens.stroke.hairline}"/><text x="${index * 108 + 22}" y="4" fill="${tokens.color.inkSub}">${label}</text>`,
      )
      .join("\n")}
  </g>
  <text data-slot="source" x="64" y="632" fill="${tokens.color.inkMute}" font-family="${tokens.font.body}" font-size="${tokens.type.caption}">${escapeXml(sourceLabel(brief.source))}</text>
  ${brandAt(892, 598)}
</svg>`;
}

const allowedSvgElements = new Set([
  "svg",
  "title",
  "desc",
  "defs",
  "marker",
  "path",
  "rect",
  "circle",
  "ellipse",
  "g",
  "text",
  "tspan",
  "line",
  "polyline",
  "polygon",
]);

const allowedSvgAttributes = new Set([
  "xmlns",
  "width",
  "height",
  "viewBox",
  "role",
  "aria-labelledby",
  "aria-hidden",
  "aria-label",
  "id",
  "fill",
  "stroke",
  "stroke-width",
  "stroke-linecap",
  "stroke-linejoin",
  "stroke-dasharray",
  "x",
  "y",
  "x1",
  "y1",
  "x2",
  "y2",
  "cx",
  "cy",
  "r",
  "rx",
  "ry",
  "d",
  "points",
  "transform",
  "font-family",
  "font-size",
  "font-weight",
  "text-anchor",
  "letter-spacing",
  "dy",
  "marker-end",
  "markerWidth",
  "markerHeight",
  "refX",
  "refY",
  "orient",
  "data-slot",
  "data-profile-background",
]);

function inspectSvgStructure(svg, fileName) {
  const errors = [];
  const stack = [];
  let cursor = 0;
  let rootCount = 0;

  while (cursor < svg.length) {
    const start = svg.indexOf("<", cursor);
    if (start === -1) {
      break;
    }
    if (svg.startsWith("<!--", start)) {
      const commentEnd = svg.indexOf("-->", start + 4);
      if (commentEnd === -1) {
        errors.push(`${fileName}: XMLコメントが閉じていません`);
        break;
      }
      cursor = commentEnd + 3;
      continue;
    }
    if (svg.startsWith("<?", start) || svg.startsWith("<!", start)) {
      errors.push(`${fileName}: XML宣言・宣言要素は使用できません`);
      break;
    }

    let end = start + 1;
    let quote = "";
    for (; end < svg.length; end += 1) {
      const character = svg[end];
      if (quote) {
        if (character === quote) {
          quote = "";
        }
      } else if (character === '"' || character === "'") {
        quote = character;
      } else if (character === ">") {
        break;
      }
    }
    if (end >= svg.length) {
      errors.push(`${fileName}: SVGタグが閉じていません`);
      break;
    }

    const raw = svg.slice(start + 1, end).trim();
    cursor = end + 1;
    if (!raw) {
      errors.push(`${fileName}: 空のXMLタグがあります`);
      continue;
    }

    const closing = raw.startsWith("/");
    const selfClosing = !closing && raw.endsWith("/");
    const body = closing
      ? raw.slice(1).trim()
      : selfClosing
        ? raw.slice(0, -1).trim()
        : raw;
    const nameMatch = body.match(/^([A-Za-z][A-Za-z0-9_.:-]*)/);
    if (!nameMatch) {
      errors.push(`${fileName}: 不正なXMLタグ <${raw}>`);
      continue;
    }
    const elementName = nameMatch[1];
    let attributesSource = body.slice(nameMatch[0].length);

    if (!allowedSvgElements.has(elementName)) {
      errors.push(`${fileName}: 許可されていないSVG要素 <${elementName}>`);
    }
    if (elementName === "svg" && !closing) {
      rootCount += 1;
    }

    if (closing) {
      if (attributesSource.trim()) {
        errors.push(`${fileName}: 閉じタグに余分な内容があります`);
      }
      const expected = stack.pop();
      if (expected !== elementName) {
        errors.push(
          `${fileName}: 閉じタグ不一致 </${elementName}>（期待: ${expected ?? "なし"}）`,
        );
      }
      continue;
    }

    const seenAttributes = new Set();
    while (attributesSource.trim()) {
      attributesSource = attributesSource.trimStart();
      const attributeMatch = attributesSource.match(
        /^([A-Za-z_:][A-Za-z0-9_.:-]*)\s*=\s*(["'])([\s\S]*?)\2/,
      );
      if (!attributeMatch) {
        errors.push(
          `${fileName}: <${elementName}>に不正または引用符なしの属性があります`,
        );
        break;
      }
      const [, attributeName, , attributeValue] = attributeMatch;
      attributesSource = attributesSource.slice(attributeMatch[0].length);
      if (seenAttributes.has(attributeName)) {
        errors.push(
          `${fileName}: <${elementName}>の${attributeName}属性が重複しています`,
        );
      }
      seenAttributes.add(attributeName);
      if (!allowedSvgAttributes.has(attributeName)) {
        errors.push(
          `${fileName}: 許可されていないSVG属性 ${attributeName}`,
        );
      }
      if (
        /[\u0000-\u0008\u000B\u000C\u000E-\u001F]/.test(attributeValue)
      ) {
        errors.push(`${fileName}: ${attributeName}に制御文字があります`);
      }
      if (
        attributeName === "xmlns" &&
        attributeValue !== "http://www.w3.org/2000/svg"
      ) {
        errors.push(`${fileName}: xmlnsがSVG名前空間ではありません`);
      }
      if (
        ["fill", "stroke", "marker-end"].includes(attributeName) &&
        /url\s*\(/i.test(attributeValue) &&
        !/^url\(#[A-Za-z][A-Za-z0-9_.:-]*\)$/.test(attributeValue)
      ) {
        errors.push(
          `${fileName}: ${attributeName}のURLは同一SVG内のID参照だけ使用できます`,
        );
      }
      if (
        attributeName !== "xmlns" &&
        /(?:javascript|vbscript|data|file|https?):/i.test(attributeValue)
      ) {
        errors.push(
          `${fileName}: ${attributeName}に外部または実行可能URLがあります`,
        );
      }
    }

    if (!selfClosing) {
      stack.push(elementName);
    }
  }

  if (stack.length > 0) {
    errors.push(`${fileName}: 閉じていないSVGタグがあります: ${stack.join(", ")}`);
  }
  if (rootCount !== 1) {
    errors.push(`${fileName}: svgルート要素は1つだけ必要です`);
  }
  return errors;
}

export function validateSvg(svg, fileName = "SVG") {
  const errors = [];
  const forbidden = [
    [/<script[\s>]/i, "script"],
    [/<foreignObject[\s>]/i, "foreignObject"],
    [/<image[\s>]/i, "image"],
    [/<style[\s>]/i, "style"],
    [/<(?:animate|animateMotion|animateTransform|set)[\s>]/i, "アニメーション"],
    [/<!DOCTYPE/i, "DOCTYPE"],
    [/<!ENTITY/i, "ENTITY"],
    [/@import/i, "CSS import"],
    [/\shref=/i, "href"],
    [/\sstyle=/i, "style属性"],
    [/\son[a-z]+=/i, "イベント属性"],
    [/(?:url\(\s*["']?(?:https?|file|data):|(?:src|href)\s*=\s*["'](?:https?|file|data):)/i, "外部または埋め込みURL"],
  ];
  for (const [pattern, label] of forbidden) {
    if (pattern.test(svg)) {
      errors.push(`${fileName}: 禁止された${label}があります`);
    }
  }
  errors.push(...inspectSvgStructure(svg, fileName));
  if (/\{\{[^}]+\}\}/.test(svg)) {
    errors.push(`${fileName}: 未解決のテンプレート変数があります`);
  }
  if (/#[0]{3}(?:[0]{3})?\b/i.test(svg)) {
    errors.push(`${fileName}: 純黒は使用できません`);
  }
  if (!/<svg\b[^>]*\bviewBox="[^"]+"/.test(svg)) {
    errors.push(`${fileName}: viewBoxがありません`);
  }
  if (!/<title\b/.test(svg) || !/<desc\b/.test(svg)) {
    errors.push(`${fileName}: titleまたはdescがありません`);
  }
  if (!svg.includes('data-slot="source"')) {
    errors.push(`${fileName}: sourceスロットがありません`);
  }
  if (!svg.includes('data-slot="brand"')) {
    errors.push(`${fileName}: brandスロットがありません`);
  }
  return errors;
}

export function renderBrief(brief) {
  const errors = validateBrief(brief);
  if (errors.length > 0) {
    throw new Error(errors.join("\n"));
  }
  const svg =
    brief.meta.part === "chart"
      ? renderChart(brief)
      : brief.meta.part === "gantt"
        ? renderGantt(brief)
        : renderStaticBrief(brief);
  const svgErrors = validateSvg(svg, brief.meta.id);
  if (svgErrors.length > 0) {
    throw new Error(svgErrors.join("\n"));
  }
  return svg.endsWith("\n") ? svg : `${svg}\n`;
}

export function applyProfile(svg, target) {
  const profile = profiles[target];
  if (!profile) {
    throw new Error(`未定義の出力先: ${target}`);
  }
  const baseWidth = tokens.canvas.width;
  const baseHeight = tokens.canvas.height;
  const targetRatio = profile.width / profile.height;
  const baseRatio = baseWidth / baseHeight;
  let viewX = 0;
  let viewY = 0;
  let viewWidth = baseWidth;
  let viewHeight = baseHeight;
  if (targetRatio > baseRatio) {
    viewWidth = baseHeight * targetRatio;
    viewX = (baseWidth - viewWidth) / 2;
  } else if (targetRatio < baseRatio) {
    viewHeight = baseWidth / targetRatio;
    viewY = (baseHeight - viewHeight) / 2;
  }
  let output = svg.replace(
    /<svg\b([^>]*)>/,
    (_match, attributes) => {
      const remaining = attributes.replace(
        /\s+(?:width|height|viewBox)="[^"]*"/g,
        "",
      );
      return `<svg${remaining} width="${profile.width}" height="${profile.height}" viewBox="${viewX.toFixed(2)} ${viewY.toFixed(2)} ${viewWidth.toFixed(2)} ${viewHeight.toFixed(2)}">`;
    },
  );
  output = output.replace(
    /(<svg\b[^>]*>)/,
    `$1\n  <rect x="${viewX.toFixed(2)}" y="${viewY.toFixed(2)}" width="${viewWidth.toFixed(2)}" height="${viewHeight.toFixed(2)}" fill="${tokens.color.canvas}" data-profile-background="${target}"/>`,
  );
  if (profile.density === "compact") {
    output = replaceTextSlot(output, "subtitle", "", {
      maxCharacters: 1,
      maxLines: 1,
    }).svg;
  }
  return output;
}

function parseCsvRows(text) {
  const rows = [];
  let row = [];
  let cell = "";
  let quoted = false;
  for (let index = 0; index < text.length; index += 1) {
    const character = text[index];
    const next = text[index + 1];
    if (character === '"' && quoted && next === '"') {
      cell += '"';
      index += 1;
    } else if (character === '"') {
      quoted = !quoted;
    } else if (character === "," && !quoted) {
      row.push(cell.trim());
      cell = "";
    } else if ((character === "\n" || character === "\r") && !quoted) {
      if (character === "\r" && next === "\n") {
        index += 1;
      }
      row.push(cell.trim());
      if (row.some((value) => value !== "")) {
        rows.push(row);
      }
      row = [];
      cell = "";
    } else {
      cell += character;
    }
  }
  row.push(cell.trim());
  if (row.some((value) => value !== "")) {
    rows.push(row);
  }
  if (quoted) {
    throw new Error("CSVの引用符が閉じていません");
  }
  return rows;
}

export function loadChartRows(filePath) {
  const extension = extname(filePath).toLowerCase();
  if (extension === ".json") {
    const data = readJson(filePath);
    const rows = Array.isArray(data) ? data : data.rows;
    if (!Array.isArray(rows)) {
      throw new Error("JSONは配列、またはrows配列を持つオブジェクトにしてください");
    }
    return rows;
  }
  if (extension !== ".csv") {
    throw new Error("チャート入力は.csvまたは.jsonにしてください");
  }
  const parsed = parseCsvRows(readFileSync(filePath, "utf8"));
  if (parsed.length < 2) {
    throw new Error("CSVにはヘッダーと1行以上のデータが必要です");
  }
  const [headers, ...rows] = parsed;
  return rows.map((cells) =>
    Object.fromEntries(headers.map((header, index) => [header, cells[index] ?? ""])),
  );
}

export function findSvgFiles(inputPath) {
  if (!existsSync(inputPath)) {
    throw new Error(`${inputPath}が見つかりません`);
  }
  if (statSync(inputPath).isFile()) {
    return extname(inputPath).toLowerCase() === ".svg" ? [inputPath] : [];
  }
  return readdirSync(inputPath, { withFileTypes: true }).flatMap((entry) => {
    const child = resolve(inputPath, entry.name);
    if (entry.isDirectory()) {
      return findSvgFiles(child);
    }
    return extname(entry.name).toLowerCase() === ".svg" ? [child] : [];
  });
}
