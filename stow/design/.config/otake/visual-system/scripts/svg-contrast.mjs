import { withPage } from "./browser.mjs";
import { validateSvg } from "./core.mjs";

// Executed inside an isolated Chrome page. Only allowlisted OVS SVG reaches here.
async function measureContrast(source) {
  const doc = new DOMParser().parseFromString(source, "image/svg+xml");
  if (doc.querySelector("parsererror")) throw new Error("SVGのXML構文が不正です");
  document.body.style.margin = "0";
  document.body.replaceChildren(document.importNode(doc.documentElement, true));
  const svg = document.querySelector("svg");
  const size = svg.getBoundingClientRect();
  const width = Math.ceil(size.width);
  const height = Math.ceil(size.height);
  if (!(width > 0 && height > 0) || width * height > 8_000_000) {
    throw new Error("描画寸法は正の数かつ800万画素以内にしてください");
  }
  svg.getBBox();
  await document.fonts.ready;
  const runs = (root) => {
    const walker = document.createTreeWalker(root, NodeFilter.SHOW_TEXT);
    const result = [];
    while (walker.nextNode()) {
      const node = walker.currentNode;
      if (node.parentElement.closest("text") && node.textContent.trim()) result.push(node);
    }
    return result;
  };
  const canvas = document.createElement("canvas");
  canvas.width = width;
  canvas.height = height;
  const context = canvas.getContext("2d", { willReadFrequently: true });
  const raster = async (root) => {
    root.setAttribute("width", width);
    root.setAttribute("height", height);
    const url = URL.createObjectURL(new Blob(
      [new XMLSerializer().serializeToString(root)], { type: "image/svg+xml" },
    ));
    try {
      const image = new Image();
      image.src = url;
      await image.decode();
      context.clearRect(0, 0, width, height);
      context.drawImage(image, 0, 0);
    } finally {
      URL.revokeObjectURL(url);
    }
  };
  const background = svg.cloneNode(true);
  for (const element of background.querySelectorAll("text, tspan")) {
    element.setAttribute("fill", "none");
    element.setAttribute("stroke", "none");
  }
  await raster(background);
  const pixels = context.getImageData(0, 0, width, height).data;
  const colorCanvas = document.createElement("canvas");
  colorCanvas.width = colorCanvas.height = 1;
  const colorContext = colorCanvas.getContext("2d", { willReadFrequently: true });
  const parseColor = (fill) => {
    if (!CSS.supports("color", fill)) return null;
    colorContext.clearRect(0, 0, 1, 1);
    colorContext.fillStyle = fill;
    colorContext.fillRect(0, 0, 1, 1);
    return [...colorContext.getImageData(0, 0, 1, 1).data];
  };
  const luminance = (rgb) => rgb.slice(0, 3).reduce((sum, byte, index) => {
    const s = byte / 255;
    return sum + [0.2126, 0.7152, 0.0722][index] *
      (s <= 0.04045 ? s / 12.92 : ((s + 0.055) / 1.055) ** 2.4);
  }, 0);
  const contrast = (a, b) => {
    const light = luminance(a);
    const dark = luminance(b);
    return (Math.max(light, dark) + 0.05) / (Math.min(light, dark) + 0.05);
  };
  const results = [];
  const textRuns = runs(svg);
  for (const [index, node] of textRuns.entries()) {
    const element = node.parentElement;
    const style = getComputedStyle(element);
    const range = document.createRange();
    range.selectNodeContents(node);
    const box = range.getBoundingClientRect();
    const rect = { x: box.x - size.x, y: box.y - size.y, width: box.width, height: box.height };
    const record = {
      text: node.textContent.trim(), slot: element.closest("[data-slot]")?.getAttribute("data-slot") ?? null,
      rect, ratio: null, minimum: 4.5, issue: null,
    };
    results.push(record);
    // SVG font-size is in user units. Use the smallest scale under skew/nonuniform transforms.
    const matrix = element.getScreenCTM();
    const trace = matrix.a ** 2 + matrix.b ** 2 + matrix.c ** 2 + matrix.d ** 2;
    const determinant = matrix.a * matrix.d - matrix.b * matrix.c;
    const scale = Math.sqrt(Math.max(0, (trace - Math.sqrt(Math.max(0, trace ** 2 - 4 * determinant ** 2))) / 2));
    const fontSize = parseFloat(style.fontSize) * scale;
    record.minimum = fontSize >= 24 || (parseInt(style.fontWeight, 10) >= 700 && fontSize >= 56 / 3) ? 3 : 4.5;
    const foreground = parseColor(style.fill === "currentcolor" ? style.color : style.fill);
    if (!foreground || foreground[3] === 0 || style.stroke !== "none" ||
        box.width === 0 || box.height === 0 ||
        rect.x < -1 || rect.y < -1 || rect.x + rect.width > width + 1 || rect.y + rect.height > height + 1) {
      record.issue = "unmeasured";
      continue;
    }
    const mask = svg.cloneNode(true);
    const target = runs(mask)[index];
    for (const shape of mask.querySelectorAll("path, rect, circle, ellipse, line, polyline, polygon")) {
      shape.setAttribute("visibility", "hidden");
    }
    for (const text of mask.querySelectorAll("text, tspan")) {
      text.setAttribute("fill", "transparent");
      text.setAttribute("stroke", "none");
    }
    // Keep all text in place, including adjacent runs, so tspan positioning does not change.
    const highlight = document.createElementNS("http://www.w3.org/2000/svg", "tspan");
    highlight.setAttribute("fill", "white");
    target.replaceWith(highlight);
    highlight.append(target);
    await raster(mask);
    const left = Math.max(0, Math.floor(rect.x));
    const top = Math.max(0, Math.floor(rect.y));
    const cropWidth = Math.min(width - left, Math.ceil(rect.x + rect.width) - left);
    const cropHeight = Math.min(height - top, Math.ceil(rect.y + rect.height) - top);
    const maskPixels = context.getImageData(left, top, cropWidth, cropHeight).data;
    // A shape painted after this run is an occluder, not its backdrop.
    // Keep defs for markers, and retain all transforms and paint alpha.
    const overlay = svg.cloneNode(true);
    const selector = "path, rect, circle, ellipse, line, polyline, polygon";
    const shapes = [...svg.querySelectorAll(selector)];
    for (const [shapeIndex, shape] of [...overlay.querySelectorAll(selector)].entries()) {
      if (!shape.closest("defs") &&
          !(node.compareDocumentPosition(shapes[shapeIndex]) & Node.DOCUMENT_POSITION_FOLLOWING)) {
        shape.setAttribute("visibility", "hidden");
      }
    }
    for (const text of overlay.querySelectorAll("text, tspan")) {
      text.setAttribute("fill", "none");
      text.setAttribute("stroke", "none");
    }
    await raster(overlay);
    const overlayPixels = context.getImageData(left, top, cropWidth, cropHeight).data;
    let minimum = Infinity;
    let unknownBackground = false;
    let obscured = false;
    for (let y = 0; y < cropHeight; y += 1) {
      for (let x = 0; x < cropWidth; x += 1) {
        // Ignore antialiased glyph edges; compare specified ink with the actual backdrop.
        if (maskPixels[(y * cropWidth + x) * 4 + 3] < 250) continue;
        if (overlayPixels[(y * cropWidth + x) * 4 + 3] > 0) obscured = true;
        const offset = ((y + top) * width + x + left) * 4;
        if (pixels[offset + 3] !== 255) {
          unknownBackground = true;
          continue;
        }
        const bg = [...pixels.slice(offset, offset + 3)];
        const alpha = foreground[3] / 255;
        const ink = foreground.slice(0, 3).map((v, channel) => v * alpha + bg[channel] * (1 - alpha));
        const ratio = contrast(ink, bg);
        if (ratio < minimum) {
          minimum = ratio;
          record.foreground = foreground.slice(0, 3);
          record.background = bg;
        }
      }
    }
    record.ratio = Number.isFinite(minimum) ? minimum : null;
    record.issue = unknownBackground || obscured || record.ratio === null
      ? "unmeasured" : minimum < record.minimum ? "contrast" : null;
  }
  return { width, height, checked: results.length, results };
}

export async function checkSvgContrasts(inputs) {
  // Validate the whole batch before opening a browser. Never navigate to an input file.
  for (const { svg, name } of inputs) {
    const errors = validateSvg(svg, name);
    if (errors.length) throw new Error(errors.join("\n"));
  }
  return withPage("about:blank", { width: 1600, height: 1000 }, async (page) => {
    await page.send("Network.enable");
    await page.send("Network.setBlockedURLs", {
      urls: ["http://*", "https://*", "file://*", "ftp://*", "ws://*", "wss://*"],
    });
    const reports = [];
    for (const { svg, name } of inputs) {
      const report = await page.evaluate(`(${measureContrast.toString()})(${JSON.stringify(svg)})`);
      reports.push({ name, ...report });
    }
    return reports;
  });
}

export function contrastIssues(reports) {
  return reports.flatMap((report) => report.results.filter((result) => result.issue).map((result) => {
    const position = `(${Math.round(result.rect.x)}, ${Math.round(result.rect.y)})`;
    const detail = result.issue === "contrast"
      ? `${result.ratio.toFixed(2)}:1（必要 ${result.minimum}:1）`
      : "測定不能（透明な背景・画面外・文字の輪郭線・上に重なる図形などを確認）";
    return `${report.name}: 「${result.text}」${position} ${detail}`;
  }));
}
