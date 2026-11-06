/**
 * check-okf.mjs の回帰テスト。確認すること:
 * - frontmatter の有無・閉じ忘れの判定
 * - type の必須判定（空文字・引用符つき空文字も不可）
 * - index.md の frontmatter 禁止（バンドル直下の okf_version のみ可）
 * - log.md の日付見出しの形式と新しい順
 * - 推奨事項（description・status・リンク切れ）は警告にとどまる
 * - ドット始まりのディレクトリと --ignore の除外
 */
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { mkdtempSync, mkdirSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join, dirname } from 'node:path';
import { extractFrontmatter, topLevelScalars, checkLog, internalLinks, checkBundle } from './check-okf.mjs';

/** 一時ディレクトリにファイル群を作る */
function bundle(files) {
  const root = mkdtempSync(join(tmpdir(), 'okf-'));
  for (const [path, content] of Object.entries(files)) {
    mkdirSync(dirname(join(root, path)), { recursive: true });
    writeFileSync(join(root, path), content);
  }
  return root;
}

const concept = (type, extra = '') => `---\ntype: ${type}\ndescription: 要約。\n${extra}---\n\n# 見出し\n`;

test('frontmatter: 無い・閉じていない・正常', () => {
  assert.deepEqual(extractFrontmatter('# title\n'), { ok: false, reason: 'missing' });
  assert.deepEqual(extractFrontmatter('---\ntype: A\n'), { ok: false, reason: 'unclosed' });
  const ok = extractFrontmatter('﻿---\r\ntype: A\r\n---\r\nbody\r\n');
  assert.equal(ok.ok, true);
  assert.equal(ok.raw, 'type: A');
  assert.equal(ok.body, 'body\n');
});

test('topLevelScalars: 引用符とコメントを外し、ネストは無視する', () => {
  const m = topLevelScalars('type: "Guide"  # 種別\ntitle: \'x\'\ngenerated:\n  by: human:me\n');
  assert.equal(m.get('type'), 'Guide');
  assert.equal(m.get('title'), 'x');
  assert.equal(m.get('generated'), '');
  assert.equal(m.has('by'), false);
});

test('checkLog: 形式違反と並び順違反を検出する', () => {
  assert.deepEqual(checkLog('# Log\n\n## 2026-11-06\n\n* a\n\n## 2026-11-01\n'), []);
  assert.equal(checkLog('## 11/6\n').length, 1);
  assert.equal(checkLog('## 2026-11-01\n## 2026-11-06\n').length, 1);
  assert.equal(checkLog('## 2026-11-06\n## 2026-11-06\n').length, 1);
});

test('internalLinks: 外部URL・アンカーのみ・.md以外を除く', () => {
  const links = internalLinks('[a](/x/y.md) [b](./z.md#sec) [c](https://e.com/a.md) [d](#top) [e](img.png)');
  assert.deepEqual(links, ['/x/y.md', './z.md']);
});

test('checkBundle: 適合バンドルはエラー0', () => {
  const root = bundle({
    'index.md': '---\nokf_version: "0.2"\n---\n\n# Docs\n\n* [A](a.md) - 要約\n',
    'log.md': '# Log\n\n## 2026-11-06\n\n* **Creation** A を追加\n',
    'a.md': concept('Guide') + '\n[B](/sub/b.md)\n',
    'sub/b.md': concept('Playbook'),
  });
  const r = checkBundle(root);
  assert.deepEqual(r.errors, []);
  assert.deepEqual(r.warnings, []);
  assert.equal(r.concepts, 2);
});

test('checkBundle: type 欠落・空の type・frontmatter なしはエラー', () => {
  const root = bundle({
    'no-fm.md': '# x\n',
    'no-type.md': '---\ntitle: x\n---\n',
    'empty-type.md': '---\ntype: ""\n---\n',
  });
  const files = checkBundle(root).errors.map((e) => e.file).sort();
  assert.deepEqual(files, ['empty-type.md', 'no-fm.md', 'no-type.md']);
});

test('checkBundle: サブディレクトリの index.md は frontmatter 不可', () => {
  const root = bundle({ 'sub/index.md': '---\nokf_version: "0.2"\n---\n' });
  assert.equal(checkBundle(root).errors.length, 1);
});

test('checkBundle: 推奨事項は警告にとどまる', () => {
  const root = bundle({
    'a.md': '---\ntype: evergreen\nstatus: active\n---\n\n[x](/missing.md)\n',
  });
  const r = checkBundle(root);
  assert.equal(r.errors.length, 0);
  assert.equal(r.warnings.length, 3);
});

test('checkBundle: ドット始まりと --ignore のディレクトリを除外する', () => {
  const root = bundle({
    '.obsidian/x.md': '# no fm\n',
    'templates/t.md': '# no fm\n',
    'a.md': concept('Guide'),
  });
  assert.equal(checkBundle(root, { ignore: ['templates'] }).errors.length, 0);
  assert.equal(checkBundle(root).errors.length, 1);
});
