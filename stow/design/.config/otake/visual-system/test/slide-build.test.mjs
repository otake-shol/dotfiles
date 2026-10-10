import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { resolve } from "node:path";
import test from "node:test";
import { rootDir } from "../scripts/core.mjs";

const build = resolve(rootDir, "../../../.agents/skills/create-story-slides/scripts/build.sh");

function runBuild(mode, verifyStatus = "0") {
  const dir = mkdtempSync(resolve(tmpdir(), "story-build-"));
  try {
    const deck = resolve(dir, "deck with spaces.md");
    const log = resolve(dir, "calls.log");
    writeFileSync(deck, "# スライドの検証\n");
    writeFileSync(log, "");
    for (const tool of ["ovs", "marp"]) {
      writeFileSync(resolve(dir, tool), `#!/bin/bash\nset -euo pipefail\nprintf '%s\\n' '${tool}' "$@" >> "$BUILD_TEST_LOG"\n${tool === "ovs" ? 'exit "$BUILD_VERIFY_STATUS"' : "exit 0"}\n`, { mode: 0o755 });
    }
    const args = [build, deck, resolve(dir, "output with spaces")];
    if (mode !== undefined) args.push(mode);
    const result = spawnSync("/bin/bash", args, {
      encoding: "utf8",
      env: { ...process.env, PATH: `${dir}:/usr/bin:/bin`, BUILD_TEST_LOG: log, BUILD_VERIFY_STATUS: verifyStatus },
    });
    return { ...result, calls: readFileSync(log, "utf8").split("\n") };
  } finally {
    rmSync(dir, { recursive: true, force: true });
  }
}

test("Standardのビルドは従来の2引数と配布モードで検証してから出力する", () => {
  for (const mode of [undefined, "read"]) {
    const result = runBuild(mode);
    assert.equal(result.status, 0, result.stderr);
    assert.deepEqual(result.calls.slice(0, 3), ["ovs", "deck", "verify"]);
    assert.equal(result.calls[result.calls.indexOf("--mode") + 1], mode ?? "present");
    assert.ok(result.calls.includes("--pdf"));
    assert.ok(result.calls.includes("--notes"));
    assert.ok(!result.calls.includes("--pdf-notes"));
  }
});

test("検証失敗や不正なモードではPDFとノートを出力しない", () => {
  const failed = runBuild("present", "1");
  assert.equal(failed.status, 1);
  assert.ok(!failed.calls.includes("marp"));
  const invalid = runBuild("unknown");
  assert.equal(invalid.status, 2);
  assert.deepEqual(invalid.calls, [""]);
});
