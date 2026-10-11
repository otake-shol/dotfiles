import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { resolve } from "node:path";
import test from "node:test";
import { rootDir } from "../scripts/core.mjs";

const build = resolve(rootDir, "../../../.agents/skills/create-story-slides/scripts/build.sh");

function runBuild(mode, verifyStatus = "0", extraArgs = [], { noOvs = false, deckOnly = false } = {}) {
  const dir = mkdtempSync(resolve(tmpdir(), "story-build-"));
  try {
    const deck = resolve(dir, "deck with spaces.md");
    const log = resolve(dir, "calls.log");
    writeFileSync(deck, "# スライドの検証\n");
    writeFileSync(log, "");
    for (const tool of noOvs ? ["marp"] : ["ovs", "marp"]) {
      writeFileSync(resolve(dir, tool), `#!/bin/bash\nset -euo pipefail\nprintf '%s\\n' '${tool}' "$@" >> "$BUILD_TEST_LOG"\n${tool === "ovs" ? 'exit "$BUILD_VERIFY_STATUS"' : "exit 0"}\n`, { mode: 0o755 });
    }
    const args = [build, deck];
    if (!deckOnly) args.push(resolve(dir, "output with spaces"));
    if (mode !== undefined) args.push(mode);
    args.push(...extraArgs);
    const result = spawnSync("/bin/bash", args, {
      encoding: "utf8",
      env: { ...process.env, PATH: `${dir}:/usr/bin:/bin`, BUILD_TEST_LOG: log, BUILD_VERIFY_STATUS: verifyStatus },
    });
    return { ...result, calls: readFileSync(log, "utf8").split("\n") };
  } finally {
    rmSync(dir, { recursive: true, force: true });
  }
}

test("Standardのビルドは従来の1・2引数と配布モードで検証してから出力する", () => {
  for (const [mode, deckOnly] of [[undefined, true], [undefined, false], ["read", false]]) {
    const result = runBuild(mode, "0", [], { deckOnly });
    assert.equal(result.status, 0, result.stderr);
    assert.deepEqual(result.calls.slice(0, 3), ["ovs", "deck", "verify"]);
    assert.equal(result.calls[result.calls.indexOf("--mode") + 1], mode ?? "present");
    assert.ok(result.calls.includes("--pdf"));
    assert.ok(!result.calls.includes("--notes"));
    assert.ok(!result.stdout.includes(".notes.txt"));
    assert.ok(!result.calls.includes("--pdf-notes"));
  }
});

test("既存ノートの書き出しは明示指定した場合だけ行う", () => {
  const result = runBuild("present", "0", ["--notes", "--minutes", "5"]);
  assert.equal(result.status, 0, result.stderr);
  assert.ok(result.calls.includes("--notes"));
  assert.match(result.stdout, /既存ノート: .*\.notes\.txt/);
  assert.ok(!result.calls.includes("--pdf-notes"));
  const failed = runBuild("present", "1", ["--notes"]);
  assert.equal(failed.status, 1);
  assert.ok(!failed.calls.includes("marp"));
});

test("検証失敗や不正なモードではPDFとノートを出力しない", () => {
  const failed = runBuild("present", "1");
  assert.equal(failed.status, 1);
  assert.ok(!failed.calls.includes("marp"));
  const invalid = runBuild("unknown");
  assert.equal(invalid.status, 2);
  assert.deepEqual(invalid.calls, [""]);
});

test("持ち時間は同じverifyへ渡し、従来の引数と出力を維持する", () => {
  for (const deckOnly of [false, true]) {
    const result = runBuild(undefined, "0", ["--minutes", "5.5"], { deckOnly });
    assert.equal(result.status, 0, result.stderr);
    assert.equal(result.calls[result.calls.indexOf("--minutes") + 1], "5.5");
    assert.equal(result.calls.filter((arg) => arg === "verify").length, 1);
    assert.ok(result.calls.includes("--pdf"));
  }
  const failed = runBuild("present", "1", ["--minutes", "5"]);
  assert.equal(failed.status, 1);
  assert.ok(!failed.calls.includes("marp"));
});

test("不正な時間指定は外部コマンドを実行する前に拒否する", () => {
  for (const args of [["--minutes"], ["--minutes", ""], ["--minutes", "0"], ["--minutes", "-1"], ["--minutes", "NaN"], ["--minutes", "Infinity"], ["--minutes", "5", "--minutes", "3"], ["--unknown"]]) {
    const result = runBuild("present", "0", args);
    assert.equal(result.status, 2, args.join(" "));
    assert.deepEqual(result.calls, [""]);
  }
});

test("ovsがない環境では時間検査の未実施を明示して画像を書き出す", () => {
  const result = runBuild("present", "0", ["--minutes", "5"], { noOvs: true });
  assert.equal(result.status, 0, result.stderr);
  assert.match(result.stderr, /持ち時間 5 分の検査は未実施/);
  assert.ok(result.calls.includes("--images"));
  assert.ok(result.calls.includes("--pdf"));
});
