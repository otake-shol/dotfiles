#!/usr/bin/env node
/**
 * OKF（Open Knowledge Format v0.2）バンドルの適合性を検査する。
 * 判定は references/spec.md に合わせる（仕様が正、このスクリプトが従）。
 *
 * エラー（適合性違反・終了コード1）:
 *   - 予約名以外の .md に frontmatter が無い／閉じていない
 *   - frontmatter に空でない `type` が無い
 *   - index.md に frontmatter がある（バンドル直下の okf_version だけは可）
 *   - log.md の見出しが `## YYYY-MM-DD` でない／新しい順でない
 * 警告（推奨事項・終了コードに影響しない）:
 *   - description が無い
 *   - status が draft / stable / deprecated 以外
 *   - バンドル内リンクの参照先が無い
 *
 * 使い方: node check-okf.mjs <bundle-dir> [--errors-only] [--json] [--ignore <dir>]...
 */
import { readdirSync, readFileSync, existsSync, statSync } from 'node:fs';
import { join, relative, dirname, resolve, sep } from 'node:path';

export const RESERVED = new Set(['index.md', 'log.md']);
export const OKF_STATUS = new Set(['draft', 'stable', 'deprecated']);

/**
 * 先頭の frontmatter を取り出す。
 * @param {string} text ファイル本文
 * @returns {{ok: true, raw: string, body: string} | {ok: false, reason: 'missing' | 'unclosed'}}
 */
export function extractFrontmatter(text) {
  const src = text.replace(/^﻿/, '').replace(/\r\n/g, '\n');
  if (!src.startsWith('---\n')) return { ok: false, reason: 'missing' };
  const end = src.indexOf('\n---', 3);
  if (end === -1) return { ok: false, reason: 'unclosed' };
  const after = src.slice(end + 4);
  if (after !== '' && !after.startsWith('\n')) return { ok: false, reason: 'unclosed' };
  return { ok: true, raw: src.slice(4, end), body: after.replace(/^\n/, '') };
}

/**
 * frontmatter からトップレベルのスカラー値を読む（ネストや複数行は対象外）。
 * @param {string} raw frontmatter 本文
 * @returns {Map<string, string>} キー → 値（引用符は外す）
 */
export function topLevelScalars(raw) {
  const map = new Map();
  for (const line of raw.split('\n')) {
    const m = line.match(/^([A-Za-z_][\w-]*)\s*:\s*(.*)$/);
    if (!m) continue;
    let value = m[2].replace(/\s+#.*$/, '').trim();
    value = value.replace(/^(['"])(.*)\1$/, '$2').trim();
    map.set(m[1], value);
  }
  return map;
}

/**
 * log.md の日付見出しを検査する。
 * @param {string} text log.md の本文
 * @returns {string[]} エラーメッセージ
 */
export function checkLog(text) {
  const errors = [];
  const dates = [];
  for (const line of text.replace(/\r\n/g, '\n').split('\n')) {
    const m = line.match(/^##\s+(.*)$/);
    if (!m) continue;
    const heading = m[1].trim();
    if (!/^\d{4}-\d{2}-\d{2}$/.test(heading)) {
      errors.push(`日付見出しは "## YYYY-MM-DD" にする: "${line}"`);
      continue;
    }
    dates.push(heading);
  }
  for (let i = 1; i < dates.length; i++) {
    if (dates[i] >= dates[i - 1]) {
      errors.push(`日付は新しい順・重複なしにする: ${dates[i - 1]} の後に ${dates[i]}`);
    }
  }
  return errors;
}

/**
 * 本文中のバンドル内リンク（.md 宛て）を抜き出す。外部URL・アンカーのみは除く。
 * @param {string} body 本文
 * @returns {string[]} リンク先（#以降は除去）
 */
export function internalLinks(body) {
  const out = [];
  const re = /\[[^\]]*\]\(([^)\s]+)(?:\s+"[^"]*")?\)/g;
  for (const m of body.matchAll(re)) {
    const target = m[1].split('#')[0];
    if (!target || /^[a-z][a-z0-9+.-]*:/i.test(target)) continue;
    if (!target.endsWith('.md')) continue;
    out.push(decodeURI(target));
  }
  return out;
}

/**
 * バンドル配下の .md を列挙する。ドット始まりのディレクトリと node_modules は除く。
 * @param {string} root バンドルのルート
 * @param {string[]} ignore 除外するディレクトリ（ルートからの相対パス）
 * @returns {string[]} 絶対パス
 */
export function listMarkdown(root, ignore = []) {
  const skip = new Set(ignore.map((d) => d.replace(/\/+$/, '')));
  const files = [];
  const walk = (dir) => {
    for (const name of readdirSync(dir).sort()) {
      const full = join(dir, name);
      const rel = relative(root, full).split(sep).join('/');
      if (statSync(full).isDirectory()) {
        if (name.startsWith('.') || name === 'node_modules' || skip.has(rel)) continue;
        walk(full);
      } else if (name.endsWith('.md')) {
        files.push(full);
      }
    }
  };
  walk(root);
  return files;
}

/**
 * バンドルを検査する。
 * @param {string} root バンドルのルート
 * @param {{ignore?: string[]}} [options]
 * @returns {{files: number, concepts: number, errors: {file: string, message: string}[], warnings: {file: string, message: string}[]}}
 */
export function checkBundle(root, options = {}) {
  const absRoot = resolve(root);
  const errors = [];
  const warnings = [];
  const files = listMarkdown(absRoot, options.ignore);
  let concepts = 0;

  for (const file of files) {
    const rel = relative(absRoot, file).split(sep).join('/');
    const name = rel.split('/').pop();
    const text = readFileSync(file, 'utf8');
    const fm = extractFrontmatter(text);
    const err = (message) => errors.push({ file: rel, message });
    const warn = (message) => warnings.push({ file: rel, message });

    if (name === 'index.md') {
      if (fm.ok) {
        const keys = [...topLevelScalars(fm.raw).keys()];
        const rootOnlyVersion = rel === 'index.md' && keys.every((k) => k === 'okf_version');
        if (!rootOnlyVersion) err('index.md に frontmatter は書かない（バンドル直下の okf_version のみ可）');
      }
    } else if (name === 'log.md') {
      for (const message of checkLog(fm.ok ? fm.body : text)) err(message);
    } else {
      concepts++;
      if (!fm.ok) {
        err(fm.reason === 'missing' ? '先頭に frontmatter（---）が無い' : 'frontmatter が閉じていない');
        continue;
      }
      const fields = topLevelScalars(fm.raw);
      if (!fields.get('type')) err('frontmatter に空でない type が無い');
      if (!fields.get('description')) warn('description（1文の要約）が無い');
      const status = fields.get('status');
      if (status && !OKF_STATUS.has(status)) warn(`status "${status}" は OKF の値（draft / stable / deprecated）ではない`);
    }

    const body = fm.ok ? fm.body : text;
    for (const link of internalLinks(body)) {
      const target = link.startsWith('/') ? join(absRoot, link) : join(dirname(file), link);
      if (!existsSync(target)) warn(`リンク先が無い: ${link}`);
    }
  }
  return { files: files.length, concepts, errors, warnings };
}

function main(argv) {
  const args = argv.slice(2);
  const ignore = [];
  let root;
  let errorsOnly = false;
  let json = false;
  for (let i = 0; i < args.length; i++) {
    const a = args[i];
    if (a === '--errors-only') errorsOnly = true;
    else if (a === '--json') json = true;
    else if (a === '--ignore') ignore.push(args[++i]);
    else if (!root) root = a;
  }
  if (!root || !existsSync(root) || !statSync(root).isDirectory()) {
    console.error('使い方: node check-okf.mjs <bundle-dir> [--errors-only] [--json] [--ignore <dir>]...');
    return 2;
  }
  const result = checkBundle(root, { ignore });
  if (json) {
    console.log(JSON.stringify(result, null, 2));
  } else {
    for (const e of result.errors) console.log(`✗ ${e.file}: ${e.message}`);
    if (!errorsOnly) for (const w of result.warnings) console.log(`⚠ ${w.file}: ${w.message}`);
    console.log(
      `OKF: ${result.files} ファイル（概念 ${result.concepts}）／エラー ${result.errors.length}／警告 ${result.warnings.length}`,
    );
  }
  return result.errors.length > 0 ? 1 : 0;
}

if (import.meta.url === `file://${process.argv[1]}` || process.argv[1]?.endsWith('check-okf.mjs')) {
  process.exitCode = main(process.argv);
}
