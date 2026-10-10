#!/usr/bin/env node
// archify スキルの brand-marks（Simple Icons 由来・出典記録つき）から製品ロゴをSVGで書き出す。
// 使い方: node scripts/export-brand-marks.mjs <デッキの assets ディレクトリ> <id>...
//   例: node scripts/export-brand-marks.mjs slides/my-talk/assets github claude openai
// 収録されていないロゴは描き起こさず、使わない（design-system.md「Icons and logos」）。
import { mkdirSync, writeFileSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";

const [assetsDir, ...ids] = process.argv.slice(2);
if (!assetsDir || ids.length === 0) {
  console.error("usage: export-brand-marks.mjs <assets-dir> <id>...");
  process.exit(2);
}
const source = join(homedir(), ".agents/skills/archify/renderers/shared/generated-brand-marks.mjs");
const mod = await import(source);
const marks = Object.values(mod).flatMap((v) => (Array.isArray(v) ? v : typeof v === "object" ? Object.values(v) : []));
mkdirSync(join(assetsDir, "logos"), { recursive: true });
for (const id of ids) {
  const mark = marks.find((m) => m && m.id === id);
  if (!mark) {
    console.error(`missing: ${id}（archify の brand-marks/catalog.json に未収録）`);
    process.exitCode = 1;
    continue;
  }
  const size = mark.viewBox;
  const svg = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${size} ${size}" role="img" aria-label="${mark.title}"><path fill="#${mark.hex}" d="${mark.path}"/></svg>`;
  writeFileSync(join(assetsDir, "logos", `${id}.svg`), svg);
  const p = mark.provenance ?? {};
  console.log(`${id}: ${p.provider ?? "unknown"} ${p.providerVersion ?? ""} ${p.source ?? ""}`.trim());
}
