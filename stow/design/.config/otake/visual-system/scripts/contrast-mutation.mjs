// Deliberately break a temporary copy of the checker, then run its real regression test.
import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { copyFileSync, mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { resolve } from "node:path";
import { browserExecutable } from "./browser.mjs";
import { rootDir } from "./core.mjs";

const testName = "字形の背景を継承色・変形・tspan・描画順から測定する";
const mutations = [
  ["コントラスト判定の無効化", 'minimum < record.minimum ? "contrast" : null', "null"],
  ["大きい文字と通常文字の基準の逆転", "? 3 : 4.5", "? 4.5 : 3"],
  ["文字を覆う図形の見逃し", "unknownBackground || obscured || record.ratio === null", "unknownBackground || record.ratio === null"],
];

function runRegression(directory) {
  const result = spawnSync(process.execPath, [
    "--test", "--test-reporter=tap", `--test-name-pattern=^${testName}$`,
    resolve(directory, "test/contrast.test.mjs"),
  ], { encoding: "utf8", timeout: 90_000 });
  if (result.error || result.signal) {
    throw new Error(`回帰テストを実行できません: ${result.error?.message ?? result.signal}`);
  }
  return { status: result.status, output: `${result.stdout}\n${result.stderr}` };
}

function main() {
  assert.ok(browserExecutable(), "Chrome系ブラウザが必要です。スキップは合格にしません。");
  const directory = mkdtempSync(resolve(tmpdir(), "ovs-contrast-mutation-"));
  try {
    for (const folder of ["scripts", "test"]) mkdirSync(resolve(directory, folder));
    for (const file of [
      "tokens.json", "scripts/browser.mjs", "scripts/core.mjs",
      "scripts/svg-contrast.mjs", "test/contrast.test.mjs",
    ]) copyFileSync(resolve(rootDir, file), resolve(directory, file));
    const checker = resolve(directory, "scripts/svg-contrast.mjs");
    const original = readFileSync(checker, "utf8");
    const baseline = runRegression(directory);
    assert.equal(baseline.status, 0, baseline.output);
    assert.match(baseline.output, new RegExp(`^ok \\d+ - ${testName}$`, "m"), baseline.output);
    assert.match(baseline.output, /^# pass 1$/m, baseline.output);
    console.log("✓ 改変前の回帰テスト: 1件成功");

    for (const [name, before, after] of mutations) {
      // An implementation change must update this explicit mutation, not silently omit it.
      assert.equal(original.split(before).length - 1, 1, `改変箇所が一意ではありません: ${name}`);
      writeFileSync(checker, original.replace(before, after));
      const result = runRegression(directory);
      // A syntax/import/browser failure is not evidence that the test detected the defect.
      assert.equal(result.status, 1, `${name}: 改変を検出できません\n${result.output}`);
      assert.match(result.output, new RegExp(`^not ok \\d+ - ${testName}$`, "m"), result.output);
      assert.match(result.output, /code: 'ERR_ASSERTION'/, result.output);
      assert.match(result.output, /^# fail 1$/m, result.output);
      console.log(`✓ 検出: ${name}`);
    }
    console.log(`✓ contrast mutation: ${mutations.length}/${mutations.length}件検出（元ファイルの変更なし）`);
  } finally {
    rmSync(directory, { recursive: true, force: true });
  }
}

try {
  main();
} catch (error) {
  console.error(error.message);
  process.exitCode = 1;
}
