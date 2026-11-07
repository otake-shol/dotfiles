#!/usr/bin/env node
/**
 * WBSの整合性を検査する読み取り専用スクリプト。
 *
 * 入力: Project Portfolio Sheets（Single版）の「WBS」をCSV/TSVで書き出したもの、
 *       または生成元の seed JSON（workItems 配列）。
 * 列は見出し名で探す。列の位置は決め打ちしない。
 *
 * 判定の正本は ../references/wbs-check.md。実装はその仕様に合わせる。
 *
 * 使い方:
 *   node check-wbs.mjs <wbs.csv|wbs.tsv|seed.json> [--holidays <file>] [--json]
 * 終了コード: 0=エラーなし / 1=エラーあり / 2=入力を読めない
 */
import { readFileSync } from "node:fs";
import { pathToFileURL } from "node:url";

/** 見出し名と内部キーの対応。Single版WBSの見出しに合わせる。 */
export const HEADER_KEYS = {
  WBS番号: "id",
  親WBS番号: "parentId",
  階層: "level",
  種別: "type",
  "成果物／作業パッケージ": "title",
  状態: "status",
  担当者: "owner",
  基準開始日: "baselineStart",
  基準終了日: "baselineEnd",
  実績開始日: "actualStart",
  実績終了日: "actualEnd",
  所要日数: "duration",
  先行タスク: "predecessors",
  "進捗%": "progress",
  タグ: "tags",
};

/** seed JSON のキーと内部キーの対応（start/due は baseline の旧名）。 */
const SEED_KEYS = {
  id: "id",
  parentId: "parentId",
  level: "level",
  type: "type",
  title: "title",
  status: "status",
  owner: "owner",
  baselineStart: "baselineStart",
  start: "baselineStart",
  baselineEnd: "baselineEnd",
  due: "baselineEnd",
  actualStart: "actualStart",
  actualEnd: "actualEnd",
  predecessors: "predecessors",
  progress: "progress",
  tags: "tags",
};

/**
 * CSV/TSV文字列を2次元配列にする。引用符内の区切り文字・改行・"" に対応する。
 * @param {string} text
 * @param {string} delimiter
 * @returns {string[][]}
 */
export function parseDelimited(text, delimiter = ",") {
  const rows = [];
  let row = [];
  let field = "";
  let quoted = false;
  const src = text.replace(/^﻿/, "");
  for (let i = 0; i < src.length; i += 1) {
    const ch = src[i];
    if (quoted) {
      if (ch === '"' && src[i + 1] === '"') {
        field += '"';
        i += 1;
      } else if (ch === '"') {
        quoted = false;
      } else {
        field += ch;
      }
    } else if (ch === '"' && field === "") {
      quoted = true;
    } else if (ch === delimiter) {
      row.push(field);
      field = "";
    } else if (ch === "\n" || ch === "\r") {
      if (ch === "\r" && src[i + 1] === "\n") i += 1;
      row.push(field);
      rows.push(row);
      row = [];
      field = "";
    } else {
      field += ch;
    }
  }
  if (field !== "" || row.length) {
    row.push(field);
    rows.push(row);
  }
  return rows.filter((r) => r.some((c) => c.trim() !== ""));
}

/**
 * 見出し行から内部キーの行オブジェクトを作る。WBS番号の列がなければ例外。
 * @param {string[][]} table
 * @returns {{items: object[], missingHeaders: string[]}}
 */
export function rowsFromTable(table) {
  const [header = [], ...body] = table;
  const index = {};
  header.forEach((name, i) => {
    const key = HEADER_KEYS[name.trim()];
    if (key && !(key in index)) index[key] = i;
  });
  if (!("id" in index)) throw new Error("見出し「WBS番号」が見つからない");
  const missingHeaders = Object.entries(HEADER_KEYS)
    .filter(([, key]) => !(key in index))
    .map(([name]) => name);
  const items = body.map((cells, i) => {
    const item = { row: i + 2 };
    for (const [key, col] of Object.entries(index)) item[key] = (cells[col] ?? "").trim();
    return item;
  });
  return { items, missingHeaders };
}

/**
 * seed JSON（workItems 配列を持つ）を行オブジェクトにする。
 * @param {object} seed
 * @returns {{items: object[], missingHeaders: string[]}}
 */
export function rowsFromSeed(seed) {
  const list = Array.isArray(seed) ? seed : seed.workItems;
  if (!Array.isArray(list)) throw new Error("workItems 配列が見つからない");
  const items = list.map((src, i) => {
    const item = { row: `workItems[${i}]` };
    for (const [from, to] of Object.entries(SEED_KEYS)) {
      if (src[from] !== undefined && src[from] !== null && item[to] === undefined) {
        item[to] = String(src[from]).trim();
      }
    }
    return item;
  });
  return { items, missingHeaders: [] };
}

/**
 * 日付文字列を YYYY-MM-DD に正規化する。空なら ""、解釈できなければ null。
 * 2026-11-05 / 2026/11/5 を受け付ける。
 * @param {string|undefined} value
 * @returns {string|null}
 */
export function normalizeDate(value) {
  const v = (value ?? "").trim();
  if (v === "") return "";
  const m = v.match(/^(\d{4})[-/](\d{1,2})[-/](\d{1,2})$/);
  if (!m) return null;
  const [y, mo, d] = [Number(m[1]), Number(m[2]), Number(m[3])];
  const date = new Date(Date.UTC(y, mo - 1, d));
  if (date.getUTCFullYear() !== y || date.getUTCMonth() !== mo - 1 || date.getUTCDate() !== d) return null;
  return `${m[1]}-${String(mo).padStart(2, "0")}-${String(d).padStart(2, "0")}`;
}

/**
 * 進捗を0〜1の数値にする。"50%" と 0.5 を受け付ける。空なら undefined、解釈できなければ NaN。
 * @param {string|undefined} value
 * @returns {number|undefined}
 */
export function normalizeProgress(value) {
  const v = (value ?? "").trim();
  if (v === "") return undefined;
  if (v.endsWith("%")) return Number(v.slice(0, -1)) / 100;
  return Number(v);
}

/**
 * カンマ・読点・空白で区切られたIDの並びを配列にする。
 * @param {string|undefined} value
 * @returns {string[]}
 */
export function splitIds(value) {
  return (value ?? "")
    .split(/[,、\s]+/)
    .map((s) => s.trim())
    .filter(Boolean);
}

/**
 * タグから schedule:L0〜L2 の階層番号を取り出す。なければ null。
 * @param {string|undefined} tags
 * @returns {number|null}
 */
export function scheduleLevel(tags) {
  const m = (tags ?? "").match(/(?:^|[,\s])schedule:L([0-2])(?=$|[,\s])/);
  return m ? Number(m[1]) : null;
}

/**
 * NETWORKDAYS と同じく、両端を含む平日数から祝日を引く。Single版の所要日数に合わせ最小1。
 * @param {string} start YYYY-MM-DD
 * @param {string} end YYYY-MM-DD
 * @param {Set<string>} holidays YYYY-MM-DD の集合
 * @returns {number}
 */
export function workdays(start, end, holidays = new Set()) {
  let count = 0;
  const cur = new Date(`${start}T00:00:00Z`);
  const last = new Date(`${end}T00:00:00Z`);
  while (cur <= last) {
    const dow = cur.getUTCDay();
    const iso = cur.toISOString().slice(0, 10);
    if (dow !== 0 && dow !== 6 && !holidays.has(iso)) count += 1;
    cur.setUTCDate(cur.getUTCDate() + 1);
  }
  return Math.max(1, count);
}

/**
 * 祝日ファイル（1行1日付、# 以降はコメント）を読む。
 * @param {string} text
 * @returns {Set<string>}
 */
export function parseHolidays(text) {
  const set = new Set();
  for (const line of text.split(/\r?\n/)) {
    const value = line.replace(/#.*/, "").trim();
    if (!value) continue;
    const date = normalizeDate(value);
    if (!date) throw new Error(`祝日ファイルの日付を解釈できない: ${value}`);
    set.add(date);
  }
  return set;
}

/**
 * 有向グラフの循環を検出する。
 * @param {Map<string, string[]>} edges id -> 参照先id
 * @returns {string[][]} 循環ごとのIDの並び（重複なし）
 */
export function findCycles(edges) {
  const state = new Map();
  const stack = [];
  const cycles = [];
  const seen = new Set();
  const visit = (id) => {
    state.set(id, 1);
    stack.push(id);
    for (const next of edges.get(id) ?? []) {
      if (!edges.has(next)) continue;
      if (state.get(next) === 1) {
        const cycle = stack.slice(stack.indexOf(next));
        const key = [...cycle].sort().join(",");
        if (!seen.has(key)) {
          seen.add(key);
          cycles.push([...cycle, next]);
        }
      } else if (!state.has(next)) {
        visit(next);
      }
    }
    stack.pop();
    state.set(id, 2);
  };
  for (const id of edges.keys()) if (!state.has(id)) visit(id);
  return cycles;
}

/**
 * WBSの行を検査する。
 * @param {object[]} items rowsFromTable / rowsFromSeed の items
 * @param {{holidays?: Set<string>, holidaysProvided?: boolean}} options
 * @returns {{errors: object[], warnings: object[], summary: object}}
 */
export function checkWbs(items, options = {}) {
  const holidays = options.holidays ?? new Set();
  const errors = [];
  const warnings = [];
  const err = (row, id, code, message) => errors.push({ row, id, code, message });
  const warn = (row, id, code, message) => warnings.push({ row, id, code, message });

  // ID
  const byId = new Map();
  for (const item of items) {
    if (!item.id) {
      err(item.row, "", "id-empty", "WBS番号が空");
      continue;
    }
    if (byId.has(item.id)) {
      err(item.row, item.id, "id-duplicate", `WBS番号が重複（${byId.get(item.id).row} 行目と同じ）`);
      continue;
    }
    byId.set(item.id, item);
  }
  const rows = [...byId.values()];

  // 日付・進捗の正規化
  for (const item of rows) {
    item.dates = {};
    for (const [key, label] of [
      ["baselineStart", "基準開始日"],
      ["baselineEnd", "基準終了日"],
      ["actualStart", "実績開始日"],
      ["actualEnd", "実績終了日"],
    ]) {
      const date = normalizeDate(item[key]);
      if (date === null) err(item.row, item.id, "date-format", `${label}を日付として解釈できない: ${item[key]}`);
      item.dates[key] = date || "";
    }
    const progress = normalizeProgress(item.progress);
    if (progress !== undefined && (Number.isNaN(progress) || progress < 0 || progress > 1)) {
      err(item.row, item.id, "progress-range", `進捗%が0〜100%の範囲外: ${item.progress}`);
    }
  }

  // 親
  const parentEdges = new Map();
  for (const item of rows) {
    const parent = item.parentId ?? "";
    parentEdges.set(item.id, parent ? [parent] : []);
    if (!parent) continue;
    if (parent === item.id) err(item.row, item.id, "parent-self", "親WBS番号が自分自身");
    else if (!byId.has(parent)) err(item.row, item.id, "parent-missing", `親WBS番号 ${parent} が存在しない`);
  }
  for (const cycle of findCycles(parentEdges)) {
    if (cycle.length <= 2) continue; // 自己参照は parent-self で報告済み
    const head = byId.get(cycle[0]);
    err(head.row, head.id, "parent-cycle", `親子関係が循環: ${cycle.join(" → ")}`);
  }

  // 先行
  const predEdges = new Map();
  for (const item of rows) {
    const preds = splitIds(item.predecessors);
    predEdges.set(item.id, preds);
    for (const pred of preds) {
      if (pred === item.id) err(item.row, item.id, "pred-self", "先行タスクに自分自身がある");
      else if (!byId.has(pred)) err(item.row, item.id, "pred-missing", `先行タスク ${pred} が存在しない`);
    }
  }
  for (const cycle of findCycles(predEdges)) {
    if (cycle.length <= 2) continue;
    const head = byId.get(cycle[0]);
    err(head.row, head.id, "pred-cycle", `先行関係が循環: ${cycle.join(" → ")}`);
  }

  const hasParentCycle = errors.some((e) => e.code === "parent-cycle");
  const ancestors = (item) => {
    const list = [];
    const visited = new Set([item.id]);
    let cur = byId.get(item.parentId ?? "");
    while (cur && !visited.has(cur.id)) {
      list.push(cur);
      visited.add(cur.id);
      cur = byId.get(cur.parentId ?? "");
    }
    return list;
  };

  for (const item of rows) {
    const d = item.dates;
    const parent = byId.get(item.parentId ?? "");

    // 日付の前後
    if (d.baselineStart && d.baselineEnd && d.baselineStart > d.baselineEnd) {
      err(item.row, item.id, "baseline-order", `基準開始日 ${d.baselineStart} が基準終了日 ${d.baselineEnd} より後`);
    }
    if (d.actualStart && d.actualEnd && d.actualStart > d.actualEnd) {
      err(item.row, item.id, "actual-order", `実績開始日 ${d.actualStart} が実績終了日 ${d.actualEnd} より後`);
    }
    if (d.actualEnd && !d.actualStart) {
      warn(item.row, item.id, "actual-start-missing", "実績終了日があるのに実績開始日が空");
    }
    if (item.status === "完了" && !d.actualEnd) {
      warn(item.row, item.id, "done-without-actual", "状態が完了なのに実績終了日が空");
    }

    // マイルストーン
    if (item.type === "マイルストーン" && d.baselineStart && d.baselineEnd && d.baselineStart !== d.baselineEnd) {
      err(item.row, item.id, "milestone-span", "マイルストーンの基準開始日と基準終了日が別の日");
    }

    // 階層
    if (parent && item.level && parent.level && Number(item.level) !== Number(parent.level) + 1) {
      warn(item.row, item.id, "level-mismatch", `階層 ${item.level} が親 ${parent.id} の階層 ${parent.level} +1 と一致しない`);
    }

    // 親の日程の範囲
    if (parent) {
      const p = parent.dates;
      if (d.baselineStart && p.baselineStart && d.baselineStart < p.baselineStart) {
        warn(item.row, item.id, "outside-parent", `基準開始日 ${d.baselineStart} が親 ${parent.id} の開始 ${p.baselineStart} より前`);
      }
      if (d.baselineEnd && p.baselineEnd && d.baselineEnd > p.baselineEnd) {
        warn(item.row, item.id, "outside-parent", `基準終了日 ${d.baselineEnd} が親 ${parent.id} の終了 ${p.baselineEnd} より後`);
      }
    }

    // 先行の終了と後続の開始（終了→開始の関係として見る）
    for (const predId of predEdges.get(item.id)) {
      const pred = byId.get(predId);
      if (!pred || pred.id === item.id) continue;
      if (pred.dates.baselineEnd && d.baselineStart && pred.dates.baselineEnd > d.baselineStart) {
        warn(item.row, item.id, "pred-overlap", `先行 ${pred.id} の基準終了 ${pred.dates.baselineEnd} が基準開始 ${d.baselineStart} より後`);
      }
    }

    // schedule:L タグの親子
    const level = scheduleLevel(item.tags);
    if (level !== null && !hasParentCycle) {
      const tagged = ancestors(item)
        .map((a) => scheduleLevel(a.tags))
        .filter((l) => l !== null);
      if (tagged.length && level < tagged[0]) {
        err(item.row, item.id, "schedule-level-inverted", `schedule:L${level} が schedule:L${tagged[0]} の配下にある`);
      }
      if (level >= 1 && !tagged.includes(level - 1)) {
        warn(item.row, item.id, "schedule-parent-missing", `schedule:L${level} の上位に schedule:L${level - 1} の項目がない`);
      }
    }

    // 所要日数
    if (d.baselineStart && d.baselineEnd && d.baselineStart <= d.baselineEnd) {
      item.workdays = workdays(d.baselineStart, d.baselineEnd, holidays);
      const stated = Number(item.duration);
      if (item.duration && Number.isFinite(stated) && stated !== item.workdays) {
        warn(item.row, item.id, "duration-mismatch", `所要日数 ${item.duration} と稼働日数の計算 ${item.workdays} が一致しない`);
      }
    }
  }

  // 集計
  const starts = rows.map((r) => r.dates.baselineStart).filter(Boolean).sort();
  const ends = rows.map((r) => r.dates.baselineEnd).filter(Boolean).sort();
  const summary = {
    items: items.length,
    milestones: rows.filter((r) => r.type === "マイルストーン").length,
    scheduleTags: { L0: 0, L1: 0, L2: 0 },
    baselineStart: starts[0] ?? "",
    baselineEnd: ends[ends.length - 1] ?? "",
    baselineWorkdays: null,
    holidaysProvided: Boolean(options.holidaysProvided),
    withoutBaseline: rows.filter((r) => !r.dates.baselineStart || !r.dates.baselineEnd).map((r) => r.id),
  };
  for (const r of rows) {
    const level = scheduleLevel(r.tags);
    if (level !== null) summary.scheduleTags[`L${level}`] += 1;
  }
  if (summary.baselineStart && summary.baselineEnd && summary.baselineStart <= summary.baselineEnd) {
    summary.baselineWorkdays = workdays(summary.baselineStart, summary.baselineEnd, holidays);
  }
  return { errors, warnings, summary };
}

/**
 * 結果を人が読む形式にする。
 * @param {{errors: object[], warnings: object[], summary: object}} result
 * @param {string[]} missingHeaders
 * @returns {string}
 */
export function formatReport(result, missingHeaders = []) {
  const { errors, warnings, summary } = result;
  const line = (x) => `- [${x.code}] ${x.id || "(IDなし)"}（${x.row}${typeof x.row === "number" ? "行目" : ""}）: ${x.message}`;
  const out = [];
  out.push(`エラー ${errors.length}件 / 警告 ${warnings.length}件 / 行 ${summary.items}件`);
  if (errors.length) out.push("", "## エラー", ...errors.map(line));
  if (warnings.length) out.push("", "## 警告", ...warnings.map(line));
  out.push("", "## 集計");
  out.push(`- マイルストーン: ${summary.milestones}件`);
  out.push(`- scheduleタグ: L0=${summary.scheduleTags.L0} / L1=${summary.scheduleTags.L1} / L2=${summary.scheduleTags.L2}`);
  out.push(`- 基準日程の全体: ${summary.baselineStart || "未入力"} 〜 ${summary.baselineEnd || "未入力"}`);
  if (summary.baselineWorkdays !== null) {
    out.push(`- 全体の稼働日数: ${summary.baselineWorkdays}日（土日除外・祝日${summary.holidaysProvided ? "除外" : "未考慮"}）`);
  }
  if (summary.withoutBaseline.length) out.push(`- 基準日程が未入力: ${summary.withoutBaseline.join(", ")}`);
  if (missingHeaders.length) out.push(`- 見つからなかった列（その列の検査は未実施）: ${missingHeaders.join(", ")}`);
  return out.join("\n");
}

/**
 * ファイルを読み込み、items と不足列を返す。
 * @param {string} path
 */
export function loadItems(path) {
  const text = readFileSync(path, "utf8");
  if (/\.json$/i.test(path)) return rowsFromSeed(JSON.parse(text));
  const delimiter = /\.tsv$/i.test(path) ? "\t" : ",";
  return rowsFromTable(parseDelimited(text, delimiter));
}

function main(argv) {
  const args = argv.slice(2);
  let json = false;
  let holidaysPath;
  let file;
  for (let i = 0; i < args.length; i += 1) {
    if (args[i] === "--json") json = true;
    else if (args[i] === "--holidays") holidaysPath = args[++i];
    else if (!file) file = args[i];
  }
  if (!file || (args.includes("--holidays") && !holidaysPath)) {
    console.error("使い方: check-wbs.mjs <wbs.csv|wbs.tsv|seed.json> [--holidays <file>] [--json]");
    return 2;
  }
  let loaded;
  let holidays = new Set();
  try {
    loaded = loadItems(file);
    if (holidaysPath) holidays = parseHolidays(readFileSync(holidaysPath, "utf8"));
  } catch (e) {
    console.error(`入力を読めない: ${e.message}`);
    return 2;
  }
  const result = checkWbs(loaded.items, { holidays, holidaysProvided: Boolean(holidaysPath) });
  if (json) console.log(JSON.stringify({ ...result, missingHeaders: loaded.missingHeaders }, null, 2));
  else console.log(formatReport(result, loaded.missingHeaders));
  return result.errors.length ? 1 : 0;
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  process.exitCode = main(process.argv);
}
