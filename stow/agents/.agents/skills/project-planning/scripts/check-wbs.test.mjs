/**
 * check-wbs.mjs の回帰テスト。
 *
 * | 観点 | 代表テスト | 意図 |
 * | --- | --- | --- |
 * | 入力の読み取り | parseDelimited handles quotes / rowsFromTable maps headers by name | 列位置を決め打ちしない。引用符内のカンマ・改行を壊さない |
 * | ID | duplicate and empty ids | 重複・空のIDを検出する |
 * | 親子・先行 | missing / self / cycle | 存在しない参照と循環を検出する |
 * | 日付 | date order / milestone span / format | 基準・実績の前後、マイルストーンは同日 |
 * | scheduleタグ | inverted / parent missing | L2→L1→L0 の親子を守る |
 * | 稼働日数 | workdays matches NETWORKDAYS | 土日・祝日を除き、最小1日 |
 * | 終了コード | CLI exit codes | エラーありで1、読めない入力で2 |
 */
import { test } from "node:test";
import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";
import {
  parseDelimited,
  rowsFromTable,
  rowsFromSeed,
  normalizeDate,
  normalizeProgress,
  splitIds,
  scheduleLevel,
  workdays,
  parseHolidays,
  checkWbs,
} from "./check-wbs.mjs";

const here = dirname(fileURLToPath(import.meta.url));
const fixtures = join(here, "..", "evals", "fixtures");

/** テスト用の行を作る。指定しない列は空。 */
const item = (fields) => ({ row: fields.id, ...fields });
const codes = (list) => list.map((x) => `${x.id}:${x.code}`).sort();

test("parseDelimited handles quotes, embedded commas and newlines", () => {
  const rows = parseDelimited('﻿a,b\n"x,1","line1\nline2"\n"say ""hi""",\n\n');
  assert.deepEqual(rows, [
    ["a", "b"],
    ["x,1", "line1\nline2"],
    ['say "hi"', ""],
  ]);
});

test("rowsFromTable maps headers by name regardless of column order", () => {
  const { items, missingHeaders } = rowsFromTable([
    ["基準終了日", "WBS番号", "親WBS番号"],
    ["2026-11-10", "T1", "E1"],
  ]);
  assert.equal(items[0].id, "T1");
  assert.equal(items[0].parentId, "E1");
  assert.equal(items[0].baselineEnd, "2026-11-10");
  assert.ok(missingHeaders.includes("先行タスク"));
});

test("rowsFromTable rejects a table without WBS番号", () => {
  assert.throws(() => rowsFromTable([["名称"], ["x"]]), /WBS番号/);
});

test("rowsFromSeed reads workItems and treats start/due as baseline", () => {
  const { items } = rowsFromSeed({ workItems: [{ id: "A", start: "2026-11-02", due: "2026-11-06", progress: 0.5 }] });
  assert.equal(items[0].baselineStart, "2026-11-02");
  assert.equal(items[0].baselineEnd, "2026-11-06");
  assert.equal(items[0].progress, "0.5");
});

test("normalizeDate accepts hyphen and slash, rejects impossible dates", () => {
  assert.equal(normalizeDate("2026/11/5"), "2026-11-05");
  assert.equal(normalizeDate("2026-11-05"), "2026-11-05");
  assert.equal(normalizeDate(""), "");
  assert.equal(normalizeDate("2026-02-30"), null);
  assert.equal(normalizeDate("11月5日"), null);
});

test("normalizeProgress reads percent and ratio", () => {
  assert.equal(normalizeProgress("50%"), 0.5);
  assert.equal(normalizeProgress("0.25"), 0.25);
  assert.equal(normalizeProgress(""), undefined);
});

test("splitIds splits by comma, Japanese comma and spaces", () => {
  assert.deepEqual(splitIds("WI-001, WI-002、WI-003 WI-004"), ["WI-001", "WI-002", "WI-003", "WI-004"]);
});

test("scheduleLevel reads only exact schedule:L0-L2 tags", () => {
  assert.equal(scheduleLevel("release,schedule:L1"), 1);
  assert.equal(scheduleLevel("schedule:L2"), 2);
  assert.equal(scheduleLevel("schedule"), null);
  assert.equal(scheduleLevel("schedule:L10"), null);
});

test("workdays matches NETWORKDAYS: inclusive, weekends and holidays excluded, minimum 1", () => {
  // 2026-11-02(月)〜2026-11-08(日) は平日5日
  assert.equal(workdays("2026-11-02", "2026-11-08"), 5);
  // 2026-11-03(火) を祝日にすると4日
  assert.equal(workdays("2026-11-02", "2026-11-08", new Set(["2026-11-03"])), 4);
  // 土日だけの期間でも Single版の所要日数と同じく1
  assert.equal(workdays("2026-11-07", "2026-11-08"), 1);
});

test("parseHolidays ignores comments and rejects broken lines", () => {
  assert.deepEqual([...parseHolidays("# 祝日\n2026-11-03 # 文化の日\n\n2026/11/23\n")], ["2026-11-03", "2026-11-23"]);
  assert.throws(() => parseHolidays("文化の日\n"), /解釈できない/);
});

test("duplicate and empty ids are errors", () => {
  const { errors } = checkWbs([item({ id: "A" }), item({ id: "A" }), item({ id: "" })]);
  assert.deepEqual(codes(errors), [":id-empty", "A:id-duplicate"]);
});

test("missing and self parent are errors", () => {
  const { errors } = checkWbs([item({ id: "A", parentId: "Z" }), item({ id: "B", parentId: "B" })]);
  assert.deepEqual(codes(errors), ["A:parent-missing", "B:parent-self"]);
});

test("parent cycle is reported once", () => {
  const { errors } = checkWbs([
    item({ id: "A", parentId: "C" }),
    item({ id: "B", parentId: "A" }),
    item({ id: "C", parentId: "B" }),
  ]);
  assert.deepEqual(
    errors.map((e) => e.code),
    ["parent-cycle"],
  );
});

test("missing, self and cyclic predecessors are errors", () => {
  const { errors } = checkWbs([
    item({ id: "A", predecessors: "B" }),
    item({ id: "B", predecessors: "A, X" }),
    item({ id: "C", predecessors: "C" }),
  ]);
  assert.deepEqual(codes(errors), ["A:pred-cycle", "B:pred-missing", "C:pred-self"]);
});

test("baseline and actual date order and format are checked", () => {
  const { errors } = checkWbs([
    item({ id: "A", baselineStart: "2026-11-10", baselineEnd: "2026-11-02" }),
    item({ id: "B", actualStart: "2026-11-10", actualEnd: "2026-11-02" }),
    item({ id: "C", baselineStart: "来週" }),
  ]);
  assert.deepEqual(codes(errors), ["A:baseline-order", "B:actual-order", "C:date-format"]);
});

test("milestone must start and end on the same day", () => {
  const { errors } = checkWbs([
    item({ id: "M1", type: "マイルストーン", baselineStart: "2026-11-02", baselineEnd: "2026-11-03" }),
    item({ id: "M2", type: "マイルストーン", baselineStart: "2026-11-02", baselineEnd: "2026-11-02" }),
  ]);
  assert.deepEqual(codes(errors), ["M1:milestone-span"]);
});

test("progress outside 0-100% is an error", () => {
  const { errors } = checkWbs([item({ id: "A", progress: "120%" }), item({ id: "B", progress: "abc" }), item({ id: "C", progress: "1" })]);
  assert.deepEqual(codes(errors), ["A:progress-range", "B:progress-range"]);
});

test("schedule:L2 under schedule:L2 parent chain needs an L1 ancestor", () => {
  const { errors, warnings } = checkWbs([
    item({ id: "P1", tags: "schedule:L0" }),
    item({ id: "E1", parentId: "P1", tags: "schedule:L1" }),
    item({ id: "T1", parentId: "E1", tags: "schedule:L2" }),
    item({ id: "T2", parentId: "T1", tags: "schedule:L2" }),
    item({ id: "X1", parentId: "P1", tags: "schedule:L2" }),
  ]);
  assert.deepEqual(codes(errors), []);
  assert.deepEqual(codes(warnings), ["X1:schedule-parent-missing"]);
});

test("schedule level placed under a lower level is an error", () => {
  const { errors } = checkWbs([
    item({ id: "T1", tags: "schedule:L2" }),
    item({ id: "E1", parentId: "T1", tags: "schedule:L1" }),
  ]);
  assert.deepEqual(codes(errors), ["E1:schedule-level-inverted"]);
});

test("warnings: outside parent range, predecessor overlap, level gap, done without actual", () => {
  const { errors, warnings } = checkWbs([
    item({ id: "E1", level: "1", baselineStart: "2026-11-02", baselineEnd: "2026-11-13" }),
    item({ id: "T1", parentId: "E1", level: "2", baselineStart: "2026-11-02", baselineEnd: "2026-11-06", status: "完了" }),
    item({ id: "T2", parentId: "E1", level: "3", baselineStart: "2026-11-05", baselineEnd: "2026-11-20", predecessors: "T1" }),
  ]);
  assert.deepEqual(codes(errors), []);
  assert.deepEqual(codes(warnings), ["T1:done-without-actual", "T2:level-mismatch", "T2:outside-parent", "T2:pred-overlap"]);
});

test("stated duration that differs from workdays is a warning", () => {
  const { warnings } = checkWbs(
    [item({ id: "A", baselineStart: "2026-11-02", baselineEnd: "2026-11-06", duration: "5" })],
    { holidays: new Set(["2026-11-03"]) },
  );
  assert.deepEqual(codes(warnings), ["A:duration-mismatch"]);
});

test("summary counts milestones, tags and overall span", () => {
  const { summary } = checkWbs([
    item({ id: "P1", tags: "schedule:L0", baselineStart: "2026-11-02", baselineEnd: "2026-11-30" }),
    item({ id: "M1", parentId: "P1", type: "マイルストーン", tags: "schedule:L1", baselineStart: "2026-11-30", baselineEnd: "2026-11-30" }),
    item({ id: "T1", parentId: "P1" }),
  ]);
  assert.equal(summary.milestones, 1);
  assert.deepEqual(summary.scheduleTags, { L0: 1, L1: 1, L2: 0 });
  assert.equal(summary.baselineStart, "2026-11-02");
  assert.equal(summary.baselineEnd, "2026-11-30");
  assert.equal(summary.baselineWorkdays, 21);
  assert.deepEqual(summary.withoutBaseline, ["T1"]);
});

const cli = (...args) => spawnSync(process.execPath, [join(here, "check-wbs.mjs"), ...args], { encoding: "utf8" });

test("CLI exits 0 for the clean fixture", () => {
  const res = cli(join(fixtures, "wbs-clean.csv"), "--holidays", join(fixtures, "holidays.txt"));
  assert.equal(res.status, 0, res.stdout + res.stderr);
  assert.match(res.stdout, /エラー 0件/);
  assert.match(res.stdout, /祝日除外/);
});

test("CLI exits 1 for the broken fixture and 2 for unreadable input", () => {
  const broken = cli(join(fixtures, "wbs-broken.csv"), "--json");
  assert.equal(broken.status, 1);
  const parsed = JSON.parse(broken.stdout);
  assert.ok(parsed.errors.length > 0);
  assert.equal(cli(join(fixtures, "does-not-exist.csv")).status, 2);
  assert.equal(cli().status, 2);
});
