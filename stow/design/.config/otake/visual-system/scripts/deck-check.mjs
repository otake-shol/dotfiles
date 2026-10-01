// Marpスライドをヘッドレスで描画し、はみ出し・重なり・孤立行・小さな文字・コントラストを実測する。
// 目視の前に機械で落とせる不具合を落とし、問題箇所に枠を描いた画像で目視を助ける。

import { spawnSync } from "node:child_process";
import {
  existsSync,
  mkdirSync,
  mkdtempSync,
  readFileSync,
  rmSync,
  writeFileSync,
} from "node:fs";
import { tmpdir } from "node:os";
import { dirname, resolve } from "node:path";
import { pathToFileURL } from "node:url";
import { withPage } from "./browser.mjs";
import { rootDir } from "./core.mjs";
import { parseDeck } from "./deck.mjs";

/** 本文の最小文字サイズ。1280px幅で20px≒15pt。Alleyの本文18〜24ptを下回らない範囲の下限 */
export const MIN_BODY_PX = 20;
/** 出典・ヘッダー・キャプションなど補助情報の最小文字サイズ。14px≒10.5pt */
export const MIN_SECONDARY_PX = 14;
/** WCAG 2.2 AA（1.4.3）のコントラスト比。大きな文字は3:1 */
export const CONTRAST_NORMAL = 4.5;
export const CONTRAST_LARGE = 3;
/** 25%表示の確認用一覧。1枚320×180px（1280×720の25%） */
const SHEET_COLUMNS = 4;
const SHEET_SCALE = 0.25;

export const renderRules = {
  "render/overflow": { severity: "error", summary: "スライドの外へはみ出す" },
  "render/clipped": { severity: "error", summary: "枠（overflow: hidden）で文字が切れる" },
  "render/collision": { severity: "error", summary: "ヘッダー・フッター・ページ番号と本文が重なる" },
  "render/broken-image": { severity: "error", summary: "画像を読み込めない" },
  "render/overlap": { severity: "warn", summary: "文字同士、または文字と図が重なる" },
  "render/safe-area": { severity: "warn", summary: "余白（安全領域）へはみ出す" },
  "render/title-lines": { severity: "warn", summary: "見出しが3行以上に折り返す" },
  "render/orphan": { severity: "warn", summary: "最終行に1〜2文字だけ残る" },
  "render/small-text": { severity: "warn", summary: "投影で読みにくい小さな文字" },
  "render/contrast": { severity: "warn", summary: "文字と背景のコントラスト不足（WCAG AA）" },
  "render/font-missing": { severity: "warn", summary: "指定フォントが未導入でフォールバック表示" },
  "render/lang": { severity: "warn", summary: "html要素のlangが日本語でない" },
};

/**
 * ブラウザ内で実行する実測処理。Node側の変数は参照できないため、設定は引数で受け取る。
 * 戻り値はJSONへ直列化できる値だけにする。
 */
async function measureDeck(config) {
  await document.fonts.ready;
  await Promise.all(
    [...document.images].map((image) =>
      image.complete
        ? null
        : new Promise((done) => {
            image.addEventListener("load", done, { once: true });
            image.addEventListener("error", done, { once: true });
          }),
    ),
  );
  await new Promise((done) => requestAnimationFrame(() => requestAnimationFrame(done)));

  const styleOf = (element) => getComputedStyle(element);
  const parseColor = (value) => {
    const match = /rgba?\(([^)]+)\)/.exec(value ?? "");
    if (!match) return null;
    const parts = match[1].split(/[\s,/]+/).filter(Boolean).map(Number);
    return { r: parts[0], g: parts[1], b: parts[2], a: parts.length > 3 ? parts[3] : 1 };
  };
  const channel = (value) => {
    const s = value / 255;
    return s <= 0.04045 ? s / 12.92 : ((s + 0.055) / 1.055) ** 2.4;
  };
  const luminance = (color) => 0.2126 * channel(color.r) + 0.7152 * channel(color.g) + 0.0722 * channel(color.b);
  const blend = (top, bottom) => ({
    r: top.r * top.a + bottom.r * (1 - top.a),
    g: top.g * top.a + bottom.g * (1 - top.a),
    b: top.b * top.a + bottom.b * (1 - top.a),
    a: 1,
  });
  const ratio = (a, b) => {
    const [light, dark] = [luminance(a), luminance(b)].sort((x, y) => y - x);
    return (light + 0.05) / (dark + 0.05);
  };
  const union = (rects) => {
    if (!rects.length) return null;
    const left = Math.min(...rects.map((rect) => rect.left));
    const top = Math.min(...rects.map((rect) => rect.top));
    const right = Math.max(...rects.map((rect) => rect.right));
    const bottom = Math.max(...rects.map((rect) => rect.bottom));
    return { left, top, right, bottom, width: right - left, height: bottom - top };
  };
  const intersection = (a, b) => {
    const width = Math.min(a.right, b.right) - Math.max(a.left, b.left);
    const height = Math.min(a.bottom, b.bottom) - Math.max(a.top, b.top);
    return width > 0 && height > 0 ? width * height : 0;
  };
  const snippet = (text) => {
    const compact = text.replace(/\s+/g, " ").trim();
    return compact.length > 16 ? `${compact.slice(0, 16)}…` : compact;
  };

  const canvas = document.createElement("canvas").getContext("2d");
  const fontAvailable = (family) => {
    const sample = "あいうえお漢字ABCabc123";
    return ["monospace", "serif", "sans-serif"].some((base) => {
      canvas.font = `40px ${base}`;
      const fallback = canvas.measureText(sample).width;
      canvas.font = `40px "${family}", ${base}`;
      return Math.abs(canvas.measureText(sample).width - fallback) > 0.5;
    });
  };
  const genericFamilies = new Set(["serif", "sans-serif", "monospace", "cursive", "fantasy", "system-ui", "ui-sans-serif", "ui-serif", "ui-monospace", "math", "emoji", "-apple-system", "blinkmacsystemfont"]);
  const usedFamilies = new Set();

  const report = { lang: document.documentElement.lang || "", slides: [], missingFonts: [] };
  const svgs = [...document.querySelectorAll("svg[data-marpit-svg]")];

  svgs.forEach((svg, slideIndex) => {
    const issues = [];
    const section = [...svg.querySelectorAll(":scope > foreignObject > section")].find((node) => {
      const kind = node.getAttribute("data-marpit-advanced-background");
      return !kind || kind === "content";
    });
    if (!section) {
      report.slides.push({ index: slideIndex + 1, issues });
      return;
    }
    const sRect = section.getBoundingClientRect();
    const scale = sRect.width / (section.offsetWidth || sRect.width);
    const sectionStyle = styleOf(section);
    const pad = {
      top: parseFloat(sectionStyle.paddingTop) * scale,
      right: parseFloat(sectionStyle.paddingRight) * scale,
      bottom: parseFloat(sectionStyle.paddingBottom) * scale,
      left: parseFloat(sectionStyle.paddingLeft) * scale,
    };
    const safe = {
      left: sRect.left + pad.left,
      top: sRect.top + pad.top,
      right: sRect.right - pad.right,
      bottom: sRect.bottom - pad.bottom,
    };
    const local = (rect) => ({
      x: Math.round((rect.left - sRect.left) / scale),
      y: Math.round((rect.top - sRect.top) / scale),
      width: Math.round(rect.width / scale),
      height: Math.round(rect.height / scale),
    });
    const add = (rule, message, rect) => {
      const key = `${rule}|${message}`;
      if (issues.some((entry) => entry.key === key)) return;
      issues.push({ key, rule, message, rect: rect ? local(rect) : null });
    };
    const isChrome = (element) => Boolean(element.closest("header, footer"));
    const isSvgText = (element) => {
      const innerSvg = element.closest("svg");
      if (!innerSvg || !section.contains(innerSvg)) return false;
      const foreign = element.closest("foreignObject");
      return !foreign || !innerSvg.contains(foreign);
    };
    const blockOf = (element) => {
      let node = element;
      while (node && node !== section && ["inline", "contents"].includes(styleOf(node).display)) {
        node = node.parentElement;
      }
      return node ?? section;
    };
    const scaleOf = (element) => {
      const rect = element.getBoundingClientRect();
      return element.offsetWidth ? rect.width / element.offsetWidth : scale;
    };

    // 文字単位の位置を集め、ブロックごとの行と文字の外接矩形を求める
    const blocks = new Map();
    const walker = document.createTreeWalker(section, NodeFilter.SHOW_TEXT);
    for (let node = walker.nextNode(); node; node = walker.nextNode()) {
      const parent = node.parentElement;
      if (!parent || !node.nodeValue.trim() || isSvgText(parent)) continue;
      if (["STYLE", "SCRIPT", "TEMPLATE"].includes(parent.tagName)) continue;
      const parentStyle = styleOf(parent);
      if (parentStyle.visibility === "hidden" || parentStyle.display === "none") continue;
      const block = blockOf(parent);
      if (!blocks.has(block)) {
        blocks.set(block, { element: block, chars: [], parents: new Set() });
      }
      const entry = blocks.get(block);
      entry.parents.add(parent);
      const family = parentStyle.fontFamily.split(",")[0].trim().replace(/^["']|["']$/g, "");
      if (family && !genericFamilies.has(family.toLowerCase())) usedFamilies.add(family);
      const text = node.nodeValue;
      for (let offset = 0; offset < text.length; ) {
        const code = text.codePointAt(offset);
        const size = code > 0xffff ? 2 : 1;
        const char = text.slice(offset, offset + size);
        if (/\s/.test(char)) {
          // 空白は位置を持たせず、行の文字列にだけ残す（指摘文の読みやすさのため）
          if (entry.chars.length && entry.chars.at(-1).char !== " ") {
            entry.chars.push({ char: " ", rect: null, parent });
          }
        } else {
          const range = document.createRange();
          range.setStart(node, offset);
          range.setEnd(node, offset + size);
          const rect = range.getClientRects()[0];
          if (rect && rect.width > 0 && rect.height > 0) {
            entry.chars.push({ char, rect, parent });
          }
        }
        offset += size;
      }
    }

    const textBoxes = [];
    for (const entry of blocks.values()) {
      const positioned = entry.chars.filter((item) => item.rect);
      if (!positioned.length) continue;
      const element = entry.element;
      const lines = [];
      for (const item of entry.chars) {
        const current = lines.at(-1);
        if (!item.rect) {
          if (current) current.text += " ";
          continue;
        }
        if (current && item.rect.top < current.top + current.height * 0.6) {
          current.text += item.char;
          current.rects.push(item.rect);
          current.height = Math.max(current.height, item.rect.height);
        } else {
          lines.push({ text: item.char, rects: [item.rect], top: item.rect.top, height: item.rect.height });
        }
      }
      const box = union(positioned.map((item) => item.rect));
      const chrome = isChrome(element);
      const text = lines.map((line) => line.text.trim()).join("");
      textBoxes.push({ element, box, chrome, text, lines });

      // 最小文字サイズ（変形による縮小も含めた実効サイズ）
      const secondary =
        chrome ||
        Boolean(element.closest("figcaption, small, sup, sub, .meta, .links, .ovs-diagram")) ||
        [...entry.parents].every((parent) => parent.closest("small, sup, sub"));
      const sizes = [...entry.parents].map((parent) => parseFloat(styleOf(parent).fontSize) * scaleOf(parent) / scale);
      const smallest = Math.min(...sizes);
      const minimum = secondary ? config.minSecondaryPx : config.minBodyPx;
      if (smallest < minimum - 0.25) {
        add("render/small-text", `「${snippet(text)}」${smallest.toFixed(1)}px（${secondary ? "補助情報" : "本文"}の下限${minimum}px）`, box);
      }

      // 見出しの行数と最終行の孤立
      const inCode = Boolean(element.closest("pre, code"));
      if (/^H1$/.test(element.tagName) && lines.length > 2) {
        add("render/title-lines", `見出し「${snippet(text)}」が${lines.length}行`, box);
      }
      if (!inCode && lines.length >= 2 && !element.querySelector("br")) {
        const last = lines.at(-1).text.trim();
        if ([...last.replace(/\s/g, "")].length <= 2) {
          add("render/orphan", `「${snippet(text)}」の最終行が「${last}」だけ`, union(lines.at(-1).rects));
        }
      }

      // コントラスト（背景に画像・グラデーションがある場合は判定しない）
      const parent = entry.chars[0].parent;
      const parentStyle = styleOf(parent);
      const foreground = parseColor(parentStyle.color);
      const layers = [];
      let unknown = false;
      for (let node = parent; node; node = node.parentElement) {
        const nodeStyle = styleOf(node);
        if (nodeStyle.backgroundImage && nodeStyle.backgroundImage !== "none") {
          unknown = true;
          break;
        }
        const color = parseColor(nodeStyle.backgroundColor);
        if (color && color.a > 0) {
          layers.push(color);
          if (color.a >= 1) break;
        }
        if (node === section) break;
      }
      if (foreground && !unknown) {
        let background = { r: 255, g: 255, b: 255, a: 1 };
        for (const layer of layers.reverse()) background = blend(layer, background);
        const color = foreground.a < 1 ? blend(foreground, background) : foreground;
        const size = parseFloat(parentStyle.fontSize);
        const weight = Number(parentStyle.fontWeight) || 400;
        const large = size >= 24 || (size >= 18.66 && weight >= 700);
        const threshold = large ? config.contrastLarge : config.contrastNormal;
        const value = ratio(color, background);
        if (value < threshold - 0.005) {
          add("render/contrast", `「${snippet(text)}」${value.toFixed(2)}:1（基準${threshold}:1）`, box);
        }
      }
    }

    // ページ番号（section::after）の位置を推定する
    const pagination = section.getAttribute("data-marpit-pagination");
    let pageBox = null;
    const after = getComputedStyle(section, "::after");
    if (pagination && after.content && after.content !== "none" && after.display !== "none") {
      canvas.font = `${after.fontWeight} ${after.fontSize} ${after.fontFamily}`;
      const width = canvas.measureText(pagination).width * scale;
      const height = parseFloat(after.fontSize) * 1.2 * scale;
      const right = sRect.right - (parseFloat(after.right) || 0) * scale - (parseFloat(after.paddingRight) || 0) * scale;
      const bottom = sRect.bottom - (parseFloat(after.bottom) || 0) * scale - (parseFloat(after.paddingBottom) || 0) * scale;
      pageBox = { left: right - width, top: bottom - height, right, bottom, width, height };
    }

    const content = textBoxes.filter((entry) => !entry.chrome);
    const chrome = textBoxes.filter((entry) => entry.chrome);
    const media = [...section.querySelectorAll("img, video, canvas, svg")]
      .filter((element) => !isChrome(element) && !element.closest("svg svg") && element.getBoundingClientRect().width > 0)
      .filter((element) => element.tagName.toLowerCase() !== "svg" || !element.parentElement.closest("svg"))
      .map((element) => ({ element, box: element.getBoundingClientRect() }));

    for (const image of section.querySelectorAll("img")) {
      if (!image.complete || image.naturalWidth === 0) {
        add("render/broken-image", `${image.getAttribute("src") ?? "画像"} を読み込めない`, image.getBoundingClientRect());
      }
    }

    // はみ出し: スライド外はerror、余白への侵入はwarn
    const outside = (box, area, margin) =>
      box.left < area.left - margin || box.top < area.top - margin || box.right > area.right + margin || box.bottom > area.bottom + margin;
    const describe = (box, area) => {
      const over = [
        ["下端", box.bottom - area.bottom],
        ["右端", box.right - area.right],
        ["上端", area.top - box.top],
        ["左端", area.left - box.left],
      ].filter(([, value]) => value > 0.5).sort((a, b) => b[1] - a[1])[0];
      return over ? `${over[0]}から${Math.round(over[1] / scale)}px` : "";
    };
    for (const entry of [...content, ...media.map((item) => ({ ...item, text: item.element.getAttribute("alt") ?? item.element.tagName.toLowerCase() }))]) {
      if (outside(entry.box, sRect, 1.5)) {
        add("render/overflow", `「${snippet(entry.text)}」が${describe(entry.box, sRect)}はみ出す`, entry.box);
      } else if (outside(entry.box, safe, 2)) {
        add("render/safe-area", `「${snippet(entry.text)}」が余白へ${describe(entry.box, safe)}入る`, entry.box);
      }
    }
    for (const element of section.querySelectorAll("*")) {
      if (isChrome(element) || isSvgText(element) || element.closest("svg svg")) continue;
      const box = element.getBoundingClientRect();
      if (box.width === 0 || box.height === 0) continue;
      if (outside(box, sRect, 2) && !(element.parentElement && element.parentElement !== section && outside(element.parentElement.getBoundingClientRect(), sRect, 2))) {
        add("render/overflow", `${element.tagName.toLowerCase()}${element.className && typeof element.className === "string" ? `.${element.className.trim().split(/\s+/).join(".")}` : ""} の枠が${describe(box, sRect)}はみ出す`, box);
      }
    }

    // overflow: hidden の祖先で切れる文字
    for (const entry of content) {
      for (let node = entry.element.parentElement; node && node !== section; node = node.parentElement) {
        const nodeStyle = styleOf(node);
        if ([nodeStyle.overflowX, nodeStyle.overflowY].some((value) => value !== "visible")) {
          const rect = node.getBoundingClientRect();
          const inner = {
            left: rect.left + parseFloat(nodeStyle.borderLeftWidth) * scale,
            top: rect.top + parseFloat(nodeStyle.borderTopWidth) * scale,
            right: rect.right - parseFloat(nodeStyle.borderRightWidth) * scale,
            bottom: rect.bottom - parseFloat(nodeStyle.borderBottomWidth) * scale,
          };
          if (outside(entry.box, inner, 1)) {
            add("render/clipped", `「${snippet(entry.text)}」が${node.tagName.toLowerCase()}の枠で切れる`, entry.box);
          }
          break;
        }
      }
    }

    // ヘッダー・フッター・ページ番号との衝突
    const reserved = [
      ...chrome.map((entry) => ({ box: entry.box, label: entry.element.closest("header") ? "ヘッダー" : "フッター" })),
      ...(pageBox ? [{ box: pageBox, label: "ページ番号" }] : []),
    ];
    for (const zone of reserved) {
      for (const entry of [...content, ...media.map((item) => ({ ...item, text: item.element.getAttribute("alt") ?? "図" }))]) {
        if (intersection(zone.box, entry.box) > 1) {
          add("render/collision", `${zone.label}と「${snippet(entry.text)}」が重なる`, entry.box);
        }
      }
    }

    // 文字同士・文字と図の重なり（祖先・子孫の関係は除く）
    for (let i = 0; i < content.length; i += 1) {
      for (let j = i + 1; j < content.length; j += 1) {
        const a = content[i];
        const b = content[j];
        if (a.element.contains(b.element) || b.element.contains(a.element)) continue;
        const overlapping = a.lines.some((lineA) =>
          b.lines.some((lineB) => intersection(union(lineA.rects), union(lineB.rects)) > 4),
        );
        if (overlapping) {
          add("render/overlap", `「${snippet(a.text)}」と「${snippet(b.text)}」が重なる`, union([a.box, b.box]));
        }
      }
      for (const item of media) {
        if (item.element.contains(content[i].element) || content[i].element.contains(item.element)) continue;
        if (item.element.tagName.toLowerCase() === "svg" && item.element.contains(content[i].element)) continue;
        const overlapping = content[i].lines.some((line) => intersection(union(line.rects), item.box) > 4);
        if (overlapping) {
          add("render/overlap", `「${snippet(content[i].text)}」と図が重なる`, content[i].box);
        }
      }
    }

    report.slides.push({
      index: slideIndex + 1,
      issues: issues.map(({ key, ...rest }) => rest),
    });
  });

  report.missingFonts = [...usedFamilies].filter((family) => !fontAvailable(family));
  return report;
}

/** 問題箇所に枠とルール名を描く（スクリーンショット用） */
function annotateDeck(slides) {
  const svgs = [...document.querySelectorAll("svg[data-marpit-svg]")];
  for (const slide of slides) {
    const svg = svgs[slide.index - 1];
    const section = svg && [...svg.querySelectorAll(":scope > foreignObject > section")].find((node) => {
      const kind = node.getAttribute("data-marpit-advanced-background");
      return !kind || kind === "content";
    });
    if (!section) continue;
    for (const entry of slide.issues) {
      if (!entry.rect) continue;
      const x = Math.max(0, entry.rect.x - 4);
      const y = Math.max(0, entry.rect.y - 4);
      const box = document.createElement("div");
      box.setAttribute("data-ovs-check", "");
      box.style.cssText = `position:absolute;left:${x}px;top:${y}px;width:${Math.max(8, entry.rect.width + 8)}px;height:${Math.max(8, entry.rect.height + 8)}px;outline:4px solid ${entry.severity === "error" ? "#E5004F" : "#F28C00"};background:rgba(229,0,79,0.08);z-index:2147483646;pointer-events:none;box-sizing:border-box;`;
      const label = document.createElement("div");
      label.setAttribute("data-ovs-check", "");
      label.textContent = entry.rule.replace("render/", "");
      label.style.cssText = `position:absolute;left:${x}px;top:${y >= 24 ? y - 24 : y + 4}px;font:700 15px/1.2 sans-serif;color:#fff;background:${entry.severity === "error" ? "#E5004F" : "#F28C00"};padding:2px 6px;border-radius:4px;z-index:2147483647;pointer-events:none;`;
      section.append(box, label);
    }
  }
  return true;
}

function marpOutput(markdownPath, deck, workDir, themeOption) {
  const output = resolve(workDir, "deck.html");
  const args = ["--no-stdin", "--html", "--template", "bare"];
  const theme =
    themeOption ??
    (deck.frontMatter.theme === "otake-visual" ? resolve(rootDir, "generated", "marp.css") : null);
  if (theme) {
    if (!existsSync(theme)) {
      throw new Error(`テーマが見つかりません: ${theme}`);
    }
    args.push("--theme", theme);
  }
  args.push(markdownPath, "--output", output);
  const result = spawnSync("marp", args, { encoding: "utf8" });
  if (result.error) {
    throw new Error(
      result.error.code === "ENOENT"
        ? "marpが見つかりません（brew install marp-cli）"
        : `marpを実行できません: ${result.error.message}`,
    );
  }
  if (result.status !== 0 || !existsSync(output)) {
    throw new Error(`Marpの変換に失敗しました: ${(result.stderr ?? "").trim()}`);
  }
  const base = pathToFileURL(`${dirname(resolve(markdownPath))}/`).href;
  const html = readFileSync(output, "utf8").replace(/<head>/i, `<head><base href="${base}">`);
  writeFileSync(output, html, "utf8");
  return output;
}

/**
 * Markdownを描画して実測する。
 * @param {string} markdownPath
 * @param {{theme?: string, shots?: string}} options shotsを指定すると各スライドと25%一覧の画像を保存する
 */
export async function checkDeck(markdownPath, options = {}) {
  const deck = parseDeck(readFileSync(markdownPath, "utf8"));
  const workDir = mkdtempSync(resolve(tmpdir(), "ovs-deck-"));
  try {
    const htmlPath = marpOutput(markdownPath, deck, workDir, options.theme);
    const config = {
      minBodyPx: MIN_BODY_PX,
      minSecondaryPx: MIN_SECONDARY_PX,
      contrastNormal: CONTRAST_NORMAL,
      contrastLarge: CONTRAST_LARGE,
    };
    const report = await withPage(pathToFileURL(htmlPath).href, { width: 1280, height: 720 }, async (page) => {
      const measured = await page.evaluate(`(${measureDeck.toString()})(${JSON.stringify(config)})`);
      for (const slide of measured.slides) {
        for (const entry of slide.issues) {
          entry.severity = renderRules[entry.rule].severity;
        }
      }
      if (options.shots) {
        mkdirSync(options.shots, { recursive: true });
        await page.evaluate(`(${annotateDeck.toString()})(${JSON.stringify(measured.slides)})`);
        // bareテンプレートはhtml要素がスクロール領域になり、画面外のスライドを撮影できないため解除する
        const boxes = await page.evaluate(`(() => {
          const style = document.createElement("style");
          style.textContent = "html{height:auto!important;overflow:visible!important;scroll-snap-type:none!important;}";
          document.head.append(style);
          return [...document.querySelectorAll("svg[data-marpit-svg]")].map((svg) => {
            const rect = svg.getBoundingClientRect();
            return { x: rect.left + scrollX, y: rect.top + scrollY, width: rect.width, height: rect.height };
          });
        })()`);
        const digits = String(boxes.length).length < 2 ? 2 : String(boxes.length).length;
        measured.shots = [];
        for (const [index, box] of boxes.entries()) {
          const file = resolve(options.shots, `slide-${String(index + 1).padStart(digits, "0")}.png`);
          writeFileSync(file, await page.screenshot(box));
          measured.shots.push(file);
        }
        const sheet = await page.evaluate(`(() => {
          const style = document.createElement("style");
          style.textContent = "html,body{background:#fff!important;scroll-snap-type:none!important;margin:0!important;}body{width:${SHEET_COLUMNS * (1280 * SHEET_SCALE + 12)}px;padding:6px;box-sizing:content-box;}svg[data-marpit-svg]{display:inline-block!important;width:${1280 * SHEET_SCALE}px!important;height:${720 * SHEET_SCALE}px!important;margin:6px!important;outline:1px solid #C8CED8;vertical-align:top;}";
          document.head.append(style);
          return { width: document.body.scrollWidth + 12, height: document.body.scrollHeight + 12 };
        })()`);
        const sheetPath = resolve(options.shots, "contact-sheet.png");
        writeFileSync(sheetPath, await page.screenshot({ x: 0, y: 0, width: sheet.width, height: sheet.height }));
        measured.sheet = sheetPath;
      }
      return measured;
    });
    const issues = [];
    if (!report.lang.toLowerCase().startsWith("ja")) {
      issues.push({ rule: "render/lang", severity: "warn", slide: 0, message: `lang="${report.lang}"。front matterに lang: ja を書く` });
    }
    for (const family of report.missingFonts) {
      issues.push({ rule: "render/font-missing", severity: "warn", slide: 0, message: `${family} が未導入（Brewfileのフォントを入れる）` });
    }
    for (const slide of report.slides) {
      for (const entry of slide.issues) {
        issues.push({ ...entry, slide: slide.index });
      }
    }
    return { issues, slides: report.slides.length, shots: report.shots ?? [], sheet: report.sheet ?? "" };
  } finally {
    rmSync(workDir, { recursive: true, force: true });
  }
}

export function formatRenderIssues(fileName, result) {
  const marks = { error: "✗", warn: "▲", info: "・" };
  const lines = [`${fileName}（表示の実測 ${result.slides}枚）`];
  const order = { error: 0, warn: 1, info: 2 };
  const sorted = [...result.issues].sort((a, b) => a.slide - b.slide || order[a.severity] - order[b.severity]);
  for (const entry of sorted) {
    const where = entry.slide ? `${String(entry.slide).padStart(2)}枚目` : "全体";
    lines.push(`  ${marks[entry.severity]} ${entry.severity.padEnd(5)} ${entry.rule.padEnd(19)} ${where}  ${entry.message}`);
  }
  const count = (severity) => result.issues.filter((entry) => entry.severity === severity).length;
  lines.push(`  error ${count("error")} / warn ${count("warn")}`);
  if (result.shots.length) {
    lines.push(`  画像: ${dirname(result.shots[0])}/slide-*.png（問題箇所に枠）／25%一覧: ${result.sheet}`);
  }
  return lines.join("\n");
}
