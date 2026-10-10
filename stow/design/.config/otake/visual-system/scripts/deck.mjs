// Marp/OVSスライドの静的検査（lint）とアウトライン抽出。
// ブラウザを使わない純粋関数だけを置き、表示の実測は deck-browser.mjs に分ける。
// 閾値は根拠と一緒に定義し、create-story-slidesの参照仕様に合わせる。

/** 聞き取りやすい日本語の発話速度。NHKの目安「1分300字」 */
export const SPEAKING_CHARS_PER_MINUTE = 300;
/** ノートのないスライドの所要時間の仮定。タイトルと証拠を一言で説明する長さ */
export const UNNOTED_SLIDE_SECONDS = 20;
/** OVSテーマの見出し1行の全角文字数。本文幅1136px（1280−72×2）÷ h1 49px（28px×1.75） */
export const TITLE_CHARS_PER_LINE = 23;
/** 見出しは2行まで（Alley「Assertion-Evidence」のチェックリスト） */
export const TITLE_MAX_LINES = 2;
/** 箇条書きの項目数。Alleyは2〜4項目を推奨する。5項目までは許容する */
export const MAX_BULLETS = 5;
/** 箇条書きの入れ子の深さ。2段を超えると投影では階層が読み取れない */
export const MAX_LIST_DEPTH = 2;
/** 箇条書き1項目の目安。前田鎌利「40字なら約10秒で理解できる」 */
export const BULLET_CHARS = 40;
/**
 * 本文の文字量（タイトル・ヘッダー・フッターを除く）。
 * 発表用は聞きながら十数秒で読める量（40字×3項目＋α）、配布用は読む前提の量。
 */
export const BODY_CHARS = { present: 140, read: 420 };
/** 同じレイアウトの連続上限。3枚目で単調になる */
export const LAYOUT_REPEAT_LIMIT = 3;

export const deckModes = ["present", "read"];

const DIRECTIVE_KEYS = new Set([
  "author",
  "backgroundColor",
  "backgroundImage",
  "backgroundPosition",
  "backgroundRepeat",
  "backgroundSize",
  "class",
  "color",
  "description",
  "footer",
  "header",
  "headingDivider",
  "image",
  "keywords",
  "lang",
  "marp",
  "math",
  "paginate",
  "size",
  "style",
  "theme",
  "title",
  "transition",
  "url",
]);

// 話題名だけで主張を持たない見出し。タイトル列だけで話を追えなくなる（横の論理）
const TOPIC_ONLY_TITLES = new Set(
  [
    "背景",
    "現状",
    "課題",
    "問題",
    "問題点",
    "目的",
    "概要",
    "まとめ",
    "結論",
    "目次",
    "アジェンダ",
    "はじめに",
    "おわりに",
    "最後に",
    "今後",
    "今後の予定",
    "今後の展望",
    "次のステップ",
    "提案",
    "解決策",
    "効果",
    "結果",
    "考察",
    "方針",
    "計画",
    "スケジュール",
    "体制",
    "実績",
    "振り返り",
    "詳細",
    "補足",
    "質疑応答",
    "ご清聴ありがとうございました",
    "ありがとうございました",
    "agenda",
    "summary",
    "overview",
    "background",
    "introduction",
    "conclusion",
    "next steps",
    "thank you",
    "q&a",
  ].map(normalizeKey),
);

const APPENDIX_TITLE = /^(参考資料|参考文献|付録|補足資料|appendix|references?)/i;
const CLOSING_TITLE = /(ご清聴|ありがとうございました|thank\s*you|^おわり$|^以上$)/i;
// テンプレートの埋め残し。指針のテンプレートは〈〉で差し替え箇所を示す
const PLACEHOLDER = /〈[^〈〉\n]{1,40}〉|\bTODO\b|\bTBD\b|\bFIXME\b|\bXXX\b|lorem ipsum|\[insert/i;
// 主張の根拠になる数値。割合・倍率・金額・桁区切り・件数など
const QUANTITY =
  /\d+(?:\.\d+)?\s*(?:%|％|倍|pt\b|ポイント)|[$¥€£]\s?\d|\d{1,3}(?:,\d{3})+|\d+(?:\.\d+)?\s*(?:件|人|名|社|円|万|億|兆|ドル|USD|MB|GB|TB|ms)/;
const SOURCE_MARK = /出典|引用|source|参考[:：]/i;
// 体言止めにしていない見出しの語尾（ユーザーの資料文体ルール）。
// 動詞の終止形（なる・変わる・続く・示す・進む・防ぐ・選ぶ・使う）も拾い、「どう」「そう」などは除く
const PREDICATE_ENDING =
  /(?:する|した|します|しました|です|でした|ます|である|だ|れる|られる|ない|たい|ている|ていた|[るくすむぐぶ]|[^どこそもょ]う)$/;
// 本文で読点の要否を確認する助詞（ユーザーの資料文体ルール）
const PARTICLE_COMMA = /(は、|を、|が、|で、|など、)/g;
const LITERAL_COLOR =
  /(?:^|;)\s*(?:color|background(?:-color)?|fill|stroke|border(?:-[a-z]+)?-color)\s*:\s*(?:#[0-9a-f]{3,8}\b|rgba?\(|hsla?\(|(?:red|blue|green|black|white|gray|grey|orange|yellow|purple|pink)\b)/i;
const IMAGE_KEYWORDS =
  /^(bg|left|right|contain|cover|fit|auto|vertical|horizontal|sepia|grayscale|invert|blur|brightness|contrast|opacity|saturate|drop-shadow|hue-rotate|(?:w|h|width|height|left|right|sepia|grayscale|invert|blur|brightness|contrast|opacity|saturate|drop-shadow|hue-rotate):\S*|\d+%)$/i;

export const deckRules = {
  "deck/lang": {
    severity: "warn",
    summary: "front matterに `lang: ja` がない",
    why: "html要素がen-USになり、word-break: auto-phrase（文節改行）が効かず、読み上げも英語になる",
  },
  "deck/theme": {
    severity: "info",
    summary: "Standardまたは既存OVSのテーマを使っていない",
    why: "新規はstory-slides、既存OVSはotake-visual。指定テンプレートがある場合は維持する",
  },
  "deck/repeat-layout": {
    severity: "warn",
    summary: `同じレイアウトが${LAYOUT_REPEAT_LIMIT}枚以上続く`,
    why: "同じ構造の反復は単調で、重要なスライドが埋もれる",
  },
  "deck/timing": {
    severity: "warn",
    summary: "推定の発表時間が持ち時間を超える",
    why: `ノートを${SPEAKING_CHARS_PER_MINUTE}字/分で換算。緊張や間で延びるため持ち時間の9割に収める`,
  },
  "deck/closing": {
    severity: "info",
    summary: "最後のスライドが挨拶だけ",
    why: "持ち帰る一文と次の行動が必要。Standardの結論L12に続く終了L18は許容する",
  },
  "slide/placeholder": {
    severity: "error",
    summary: "テンプレートの差し替え箇所（〈〉・TODO等）が残っている",
    why: "埋め残しはそのまま聴衆に見える",
  },
  "slide/no-title": {
    severity: "warn",
    summary: "見出しがない",
    why: "タイトル列で主張を追えなくなる",
  },
  "slide/topic-title": {
    severity: "warn",
    summary: "見出しが話題名だけ（例: 背景、まとめ）",
    why: "主張を含む見出しにしないとタイトル列だけで話が通らない",
  },
  "slide/title-length": {
    severity: "warn",
    summary: `見出しが${TITLE_MAX_LINES}行を超える長さ`,
    why: "見出しは一目で読める長さにし、2行までに収める",
  },
  "slide/title-period": {
    severity: "warn",
    summary: "見出しが句点で終わる",
    why: "見出しは体言止め（資料文体ルール）",
  },
  "slide/title-taigen": {
    severity: "info",
    summary: "見出しが用言で終わる",
    why: "見出しは体言止め（資料文体ルール）。問いかけの見出しは対象外",
  },
  "slide/bullets": {
    severity: "warn",
    summary: `箇条書きが${MAX_BULLETS}項目を超える、または入れ子が${MAX_LIST_DEPTH}段を超える`,
    why: "2〜4項目が読み取りやすい。多い場合は分割か図解にする",
  },
  "slide/bullet-length": {
    severity: "info",
    summary: `箇条書き1項目が${BULLET_CHARS}字を超える`,
    why: "40字で約10秒。長い項目は話す内容をノートへ移す",
  },
  "slide/dense": {
    severity: "warn",
    summary: "本文の文字量が多い",
    why: "発表用は聞きながら読める量に絞る。詳細はノートか付録へ",
  },
  "slide/image-alt": {
    severity: "error",
    summary: "内容を持つ画像にaltがない",
    why: "PDF・HTMLの読み上げと検索で内容が失われる",
  },
  "slide/inline-color": {
    severity: "warn",
    summary: "style属性に色を直接書いている",
    why: "色はテーマのクラスとトークンに任せる。必要な表現が未実装ならテーマを直す",
  },
  "slide/hand-svg": {
    severity: "info",
    summary: "手書きのインラインSVGがある",
    why: "チャートは `ovs chart` で実データから生成すると、alt・出典・配色が揃う",
  },
  "slide/source": {
    severity: "warn",
    summary: "数値があるのに出典が見えない",
    why: "外部・自分のデータの数値はフッターに出典を示す",
  },
  "slide/footer-url": {
    severity: "warn",
    summary: "フッターにURLがある",
    why: "URLは参考資料スライドへ。フッターは資料名・版・年だけにする",
  },
  "slide/notes": {
    severity: "info",
    summary: "発表者ノートがない",
    why: "発表用はノートに話す内容とつなぎを書く",
  },
  "slide/comma": {
    severity: "info",
    summary: "助詞直後の読点（は、を、が、で、など、）",
    why: "誤読防止に必要な場合を除いて削る（資料文体ルール）",
  },
};

function normalizeKey(value) {
  return value
    .toLowerCase()
    .replace(/[\s　]+/g, " ")
    .trim();
}

function scalar(raw) {
  const value = raw.replace(/\s+#.*$/, "").trim();
  if (/^(['"])(.*)\1$/.test(value)) {
    return value.slice(1, -1);
  }
  if (value === "true") return true;
  if (value === "false") return false;
  if (/^-?\d+(\.\d+)?$/.test(value)) return Number(value);
  return value;
}

/** 全角を1、半角英数・半角カナを0.5として数えた表示幅 */
export function displayWidth(text) {
  let width = 0;
  for (const char of text) {
    const code = char.codePointAt(0);
    const half = code <= 0x7e || (code >= 0xff61 && code <= 0xff9f);
    width += half ? 0.5 : 1;
  }
  return width;
}

/** 空白を除いた文字数 */
export function countChars(text) {
  return [...text.replace(/\s/g, "")].length;
}

/** Markdownのインライン記法とHTMLタグを外した表示テキスト */
export function inlineText(value) {
  return value
    .replace(/<!--[\s\S]*?-->/g, "")
    .replace(/!\[[^\]]*\]\([^)]*\)/g, "")
    .replace(/\[([^\]]*)\]\([^)]*\)/g, "$1")
    .replace(/<br\s*\/?>/gi, "\n")
    .replace(/<[^>]+>/g, "")
    .replace(/`([^`]*)`/g, "$1")
    .replace(/(\*\*|__)(.+?)\1/g, "$2")
    .replace(/(^|[^*\w])\*(?!\s)([^*\n]+?)\*(?!\w)/g, "$1$2")
    .replace(/&nbsp;/g, " ")
    .replace(/&lt;/g, "<")
    .replace(/&gt;/g, ">")
    .replace(/&quot;/g, '"')
    .replace(/&#39;/g, "'")
    .replace(/&amp;/g, "&")
    .replace(/\\([\\`*_{}[\]()#+\-.!|])/g, "$1")
    .trim();
}

function parseFrontMatter(text) {
  const match = text.match(/^---[ \t]*\n([\s\S]*?)\n---[ \t]*(?:\n|$)/);
  if (!match) {
    return { data: {}, body: text, lineOffset: 0 };
  }
  const data = {};
  for (const line of match[1].split("\n")) {
    const pair = line.match(/^([A-Za-z_][\w-]*)\s*:\s*(.*?)\s*$/);
    if (pair) {
      data[pair[1]] = scalar(pair[2]);
    }
  }
  return {
    data,
    body: text.slice(match[0].length),
    lineOffset: match[0].split("\n").length - (match[0].endsWith("\n") ? 1 : 0),
  };
}

/**
 * HTMLコメントがMarpのディレクティブなら値の辞書を、発表者ノートならnullを返す。
 * 全行が既知のキーの `key: value` であるコメントだけをディレクティブとみなす。
 */
export function parseDirectiveComment(content) {
  const trimmed = content.trim();
  if (trimmed === "fit") {
    return { fit: true };
  }
  const lines = trimmed
    .split("\n")
    .map((line) => line.trim())
    .filter(Boolean);
  if (lines.length === 0) {
    return null;
  }
  const result = {};
  for (const line of lines) {
    const pair = line.match(/^(_?)([A-Za-z]+)\s*:\s*(.*)$/);
    if (!pair || !DIRECTIVE_KEYS.has(pair[2])) {
      return null;
    }
    result[`${pair[1]}${pair[2]}`] = scalar(pair[3]);
  }
  return result;
}

function splitSlides(body, lineOffset, headingDivider) {
  const lines = body.split("\n");
  const slides = [];
  let buffer = [];
  let startIndex = 0;
  let fence = null;
  let inComment = false;
  let previousBlank = true;

  const flush = (nextStart) => {
    slides.push({ raw: buffer.join("\n"), startLine: lineOffset + startIndex + 1 });
    buffer = [];
    startIndex = nextStart;
  };

  for (let index = 0; index < lines.length; index += 1) {
    const line = lines[index];
    if (fence) {
      if (fence.test(line)) {
        fence = null;
      }
      buffer.push(line);
      previousBlank = false;
      continue;
    }
    if (inComment) {
      if (line.includes("-->")) {
        inComment = false;
      }
      buffer.push(line);
      previousBlank = false;
      continue;
    }
    const opening = line.match(/^\s{0,3}(`{3,}|~{3,})/);
    if (opening) {
      const char = opening[1][0] === "`" ? "`" : "~";
      fence = new RegExp(`^\\s{0,3}${char}{${opening[1].length},}\\s*$`);
      buffer.push(line);
      previousBlank = false;
      continue;
    }
    if (/^\s{0,3}([-*_])(?:\s*\1){2,}\s*$/.test(line) && previousBlank) {
      flush(index + 1);
      previousBlank = true;
      continue;
    }
    const heading = line.match(/^(#{1,6})\s/);
    if (
      heading &&
      typeof headingDivider === "number" &&
      heading[1].length <= headingDivider &&
      buffer.some((entry) => entry.trim() && !/^<!--[\s\S]*-->$/.test(entry.trim()))
    ) {
      flush(index);
    }
    const lastOpen = line.lastIndexOf("<!--");
    if (lastOpen !== -1 && !line.slice(lastOpen).includes("-->")) {
      inComment = true;
    }
    buffer.push(line);
    previousBlank = line.trim() === "";
  }
  flush(lines.length);
  return slides;
}

function analyzeBody(markdown) {
  const lines = markdown.split("\n");
  const textLines = [];
  const listItems = [];
  const headings = [];
  let fence = null;
  let codeLines = 0;
  let tableRows = 0;
  let blockquote = false;
  const indentStack = [];
  // 箇条書きは連続する1ブロックごとに数える（2カラムの左右は別のリスト）
  let listBlock = 0;
  let inList = false;

  for (const line of lines) {
    if (fence) {
      if (fence.test(line)) {
        fence = null;
      } else {
        codeLines += 1;
      }
      continue;
    }
    const opening = line.match(/^\s{0,3}(`{3,}|~{3,})/);
    if (opening) {
      const char = opening[1][0] === "`" ? "`" : "~";
      fence = new RegExp(`^\\s{0,3}${char}{${opening[1].length},}\\s*$`);
      continue;
    }
    if (!line.trim()) {
      continue;
    }
    const heading = line.match(/^\s{0,3}(#{1,6})\s+(.*?)\s*#*\s*$/);
    if (heading) {
      headings.push({ level: heading[1].length, text: inlineText(heading[2]) });
      indentStack.length = 0;
      inList = false;
      continue;
    }
    if (/^\s*\|?\s*:?-{3,}:?\s*(\|\s*:?-{3,}:?\s*)*\|?\s*$/.test(line) && line.includes("-")) {
      continue;
    }
    if (/^\s*\|/.test(line)) {
      tableRows += 1;
      const cells = line
        .trim()
        .replace(/^\||\|$/g, "")
        .split(/(?<!\\)\|/)
        .map((cell) => inlineText(cell));
      textLines.push(cells.join(" "));
      indentStack.length = 0;
      inList = false;
      continue;
    }
    const item = line.match(/^(\s*)(?:[-*+]|\d+[.)])\s+(.*)$/);
    if (item) {
      if (!inList) {
        listBlock += 1;
        inList = true;
        indentStack.length = 0;
      }
      const indent = item[1].replace(/\t/g, "    ").length;
      while (indentStack.length && indent < indentStack.at(-1)) {
        indentStack.pop();
      }
      if (!indentStack.length || indent > indentStack.at(-1)) {
        indentStack.push(indent);
      }
      const text = inlineText(item[2]);
      listItems.push({ depth: indentStack.length, block: listBlock, text });
      textLines.push(text);
      continue;
    }
    if (/^\s*>/.test(line)) {
      blockquote = true;
      inList = false;
      textLines.push(inlineText(line.replace(/^\s*>\s?/, "")));
      continue;
    }
    if (!/^\s/.test(line)) {
      indentStack.length = 0;
      inList = false;
    }
    const text = inlineText(line);
    if (text) {
      textLines.push(text);
    }
  }
  return { textLines, listItems, headings, codeLines, tableRows, blockquote };
}

function imagesIn(markdown) {
  const images = [];
  for (const match of markdown.matchAll(/!\[([^\]]*)\]\(([^)\s]+)(?:\s+"[^"]*")?\)/g)) {
    const words = match[1].split(/\s+/).filter(Boolean);
    const background = words.some((word) => word.toLowerCase() === "bg");
    const alt = words.filter((word) => !IMAGE_KEYWORDS.test(word)).join(" ");
    images.push({ src: match[2], alt, background });
  }
  for (const match of markdown.matchAll(/<img\b[^>]*>/gi)) {
    const alt = match[0].match(/\balt\s*=\s*"([^"]*)"|\balt\s*=\s*'([^']*)'/i);
    const src = match[0].match(/\bsrc\s*=\s*"([^"]*)"|\bsrc\s*=\s*'([^']*)'/i);
    images.push({
      src: src ? (src[1] ?? src[2]) : "",
      alt: alt ? (alt[1] ?? alt[2]).trim() : "",
      background: false,
    });
  }
  return images;
}

// ノートのうち話さない行。根拠・メモ・出典の行とURLを含む行は時間の換算から外す
const UNSPOKEN_NOTE_LINE = /^\s*(?:[・\-*]\s*)?(?:根拠|メモ|出典|参考|URL|確認日)[:：]|https?:\/\//i;

/** 発表者ノートから話す部分だけを返す */
export function spokenNotes(notes) {
  return notes
    .split("\n")
    .filter((line) => !UNSPOKEN_NOTE_LINE.test(line))
    .join("\n");
}

function layoutKind(slide) {
  if (slide.hasSvg || slide.images.some((image) => !image.background)) return "visual";
  if (slide.tableRows > 0) return "table";
  if (slide.listItems.length > 0) return "list";
  if (slide.blockquote) return "quote";
  if (slide.codeLines > 0) return "code";
  return "text";
}

/** Marp Markdownをスライド単位に分解する */
export function parseDeck(markdown) {
  const text = markdown.replace(/\r\n?/g, "\n");
  const { data, body, lineOffset } = parseFrontMatter(text);
  const local = {};
  for (const key of ["class", "paginate", "header", "footer", "backgroundColor", "color"]) {
    if (data[key] !== undefined) local[key] = data[key];
  }
  const slides = splitSlides(body, lineOffset, data.headingDivider).map((entry, index) => {
    const directives = {};
    const notes = [];
    for (const comment of entry.raw.matchAll(/<!--([\s\S]*?)-->/g)) {
      const parsed = parseDirectiveComment(comment[1]);
      if (parsed) {
        Object.assign(directives, parsed);
      } else if (comment[1].trim()) {
        notes.push(comment[1].trim());
      }
    }
    for (const [key, value] of Object.entries(directives)) {
      if (!key.startsWith("_") && key !== "fit") local[key] = value;
    }
    const effective = { ...local };
    for (const [key, value] of Object.entries(directives)) {
      if (key.startsWith("_")) effective[key.slice(1)] = value;
    }
    const visible = entry.raw.replace(/<!--[\s\S]*?-->/g, "");
    const analysis = analyzeBody(visible);
    const titleHeading = analysis.headings[0];
    const title = titleHeading ? titleHeading.text : "";
    const bodyLines = [
      ...analysis.headings.slice(1).map((heading) => heading.text),
      ...analysis.textLines,
    ];
    const bodyText = bodyLines.join("\n");
    const notesText = notes.join("\n");
    const slide = {
      index: index + 1,
      startLine: entry.startLine,
      raw: entry.raw,
      className: String(effective.class ?? "").trim(),
      paginate: effective.paginate,
      header: effective.header ? inlineText(String(effective.header)) : "",
      footer: effective.footer ? inlineText(String(effective.footer)) : "",
      title,
      titleLevel: titleHeading?.level ?? 0,
      bodyText,
      bodyChars: countChars(bodyText),
      listItems: analysis.listItems,
      tableRows: analysis.tableRows,
      codeLines: analysis.codeLines,
      blockquote: analysis.blockquote,
      images: imagesIn(visible),
      hasSvg: /<svg\b/i.test(visible),
      styles: [...visible.matchAll(/\bstyle\s*=\s*"([^"]*)"|\bstyle\s*=\s*'([^']*)'/gi)].map(
        (match) => match[1] ?? match[2],
      ),
      notes: notesText,
      notesChars: countChars(spokenNotes(notesText)),
    };
    slide.appendix = APPENDIX_TITLE.test(slide.title);
    slide.layout = `${slide.className || "default"}:${layoutKind(slide)}`;
    return slide;
  });
  return { frontMatter: data, slides };
}

/** ノートから推定した1枚の発表秒数。ノートがなければ仮定値を使う */
export function estimateSeconds(slide) {
  if (slide.notesChars > 0) {
    return Math.round((slide.notesChars / SPEAKING_CHARS_PER_MINUTE) * 60);
  }
  return UNNOTED_SLIDE_SECONDS;
}

export function formatDuration(seconds) {
  const minutes = Math.floor(seconds / 60);
  return `${minutes}:${String(Math.round(seconds % 60)).padStart(2, "0")}`;
}

function truncate(text, width) {
  let result = "";
  let used = 0;
  for (const char of text) {
    const next = displayWidth(char);
    if (used + next > width) {
      return `${result}…`;
    }
    result += char;
    used += next;
  }
  return result;
}

function issue(rule, slide, message) {
  return {
    rule,
    severity: deckRules[rule].severity,
    slide: slide?.index ?? 0,
    line: slide?.startLine ?? 1,
    message,
  };
}

/**
 * 構成と文面の静的検査。
 * @param {{frontMatter: object, slides: object[]}} deck parseDeckの結果
 * @param {{mode?: "present"|"read", minutes?: number}} options
 */
export function lintDeck(deck, options = {}) {
  const mode = options.mode ?? "present";
  if (!deckModes.includes(mode)) {
    throw new Error(`modeは${deckModes.join("、")}から選択してください`);
  }
  const issues = [];
  const { frontMatter, slides } = deck;
  const standardTheme = ["story-slides", "otake-visual"].includes(frontMatter.theme);
  const mainSlides = slides.filter((slide) => !slide.appendix);
  const last = mainSlides.at(-1);
  const conclusion = mainSlides.at(-2);
  const hasClass = (slide, name) => slide?.className.split(/\s+/).includes(name);
  // Standardでは結論L12の後に終了L18を置く。結論を省いた挨拶だけの資料は免除しない。
  const standardEndSlide = standardTheme && hasClass(last, "l18") &&
    hasClass(conclusion, "l12") && conclusion.bodyText.trim() &&
    mainSlides.filter((slide) => hasClass(slide, "l18")).length === 1 ? last : null;

  if (!String(frontMatter.lang ?? "").toLowerCase().startsWith("ja")) {
    issues.push(issue("deck/lang", null, "front matterに `lang: ja` を追加する"));
  }
  if (!standardTheme) {
    issues.push(
      issue("deck/theme", null, `theme: ${frontMatter.theme ?? "（未指定）"}。新規資料は story-slides、既存OVS資料は otake-visual を使う。指定テーマは維持する`),
    );
  }

  let run = 1;
  for (const slide of slides) {
    const label = slide.title ? `「${truncate(slide.title.replace(/\s+/g, " "), 18)}」` : `${slide.index}枚目`;
    const previous = slides[slide.index - 2];
    run = previous && previous.layout === slide.layout && !slide.appendix ? run + 1 : 1;
    if (run === LAYOUT_REPEAT_LIMIT) {
      issues.push(
        issue("deck/repeat-layout", slide, `${label}: ${slide.layout} が${run}枚続く。型を変えるか構成を見直す`),
      );
    }

    const placeholderSource = [slide.title, slide.bodyText, slide.header, slide.footer].join("\n");
    const placeholder = placeholderSource.match(PLACEHOLDER);
    if (placeholder) {
      issues.push(issue("slide/placeholder", slide, `${label}: 「${placeholder[0]}」が残っている`));
    }

    if (!slide.title) {
      if (!slide.images.some((image) => image.background)) {
        issues.push(issue("slide/no-title", slide, `${slide.index}枚目: 主張を述べる見出しを置く`));
      }
    } else {
      const key = normalizeKey(slide.title);
      if (TOPIC_ONLY_TITLES.has(key) && slide !== standardEndSlide) {
        issues.push(issue("slide/topic-title", slide, `${label}: 話題名ではなく主張にする（例: 「現状」→「問い合わせ対応の属人化」）`));
      }
      const width = displayWidth(slide.title);
      const limit = slide.className.split(/\s+/).includes("lead")
        ? TITLE_CHARS_PER_LINE * TITLE_MAX_LINES * 0.8
        : TITLE_CHARS_PER_LINE * TITLE_MAX_LINES;
      if (width > limit) {
        issues.push(issue("slide/title-length", slide, `${label}: 全角換算${width}字。${Math.floor(limit)}字以内に縮める`));
      }
      if (/[。．.]$/.test(slide.title)) {
        issues.push(issue("slide/title-period", slide, `${label}: 句点を外して体言止めにする`));
      }
      const ending = slide.title.replace(/[」』）)\]！!…]+$/, "");
      if (slide !== standardEndSlide && !/[？?]$/.test(ending) && PREDICATE_ENDING.test(ending)) {
        issues.push(issue("slide/title-taigen", slide, `${label}: 体言止めを検討する`));
      }
    }

    const blockSizes = new Map();
    for (const item of slide.listItems) {
      if (item.depth === 1) blockSizes.set(item.block, (blockSizes.get(item.block) ?? 0) + 1);
    }
    const count = Math.max(0, ...blockSizes.values());
    const tooMany = count > MAX_BULLETS;
    const tooDeep = slide.listItems.some((item) => item.depth > MAX_LIST_DEPTH);
    if (!slide.appendix && (tooMany || tooDeep)) {
      issues.push(
        issue("slide/bullets", slide, `${label}: ${tooMany ? `${count}項目` : ""}${tooMany && tooDeep ? "・" : ""}${tooDeep ? "3段以上の入れ子" : ""}。分割するか図・表にする`),
      );
    }
    if (mode === "present" && !slide.appendix) {
      const long = slide.listItems.filter((item) => countChars(item.text) > BULLET_CHARS);
      if (long.length) {
        issues.push(
          issue("slide/bullet-length", slide, `${label}: ${long.length}項目が${BULLET_CHARS}字超（最長${Math.max(...long.map((item) => countChars(item.text)))}字）`),
        );
      }
    }
    if (!slide.appendix && slide.bodyChars > BODY_CHARS[mode]) {
      issues.push(
        issue("slide/dense", slide, `${label}: 本文${slide.bodyChars}字（${mode === "present" ? "発表用" : "配布用"}の目安${BODY_CHARS[mode]}字）。分割・図解・ノートへの移動を検討`),
      );
    }

    for (const image of slide.images) {
      if (!image.background && !image.alt) {
        issues.push(issue("slide/image-alt", slide, `${label}: ${image.src || "画像"} に内容を説明するaltを付ける`));
      }
    }
    if (slide.styles.some((style) => LITERAL_COLOR.test(style))) {
      issues.push(issue("slide/inline-color", slide, `${label}: style属性の色指定をクラスかトークン（var(--ovs-*)）へ置き換える`));
    }
    if (slide.hasSvg) {
      issues.push(issue("slide/hand-svg", slide, `${label}: 実データのチャートなら ovs chart で生成した画像に置き換える`));
    }

    // 表紙と自己紹介の数値は発表者自身の情報なので出典を求めない
    const classes = slide.className.split(/\s+/);
    const presenterSlide = classes.includes("lead") || classes.includes("profile") ||
      (standardTheme && classes.some((name) => ["l01", "l17", "l18"].includes(name)));
    if (!slide.appendix && !presenterSlide) {
      const claim = `${slide.title}\n${slide.bodyText}`;
      const quantity = claim.match(QUANTITY);
      if (quantity && !SOURCE_MARK.test(`${slide.footer}\n${slide.bodyText}`)) {
        const inNotes = SOURCE_MARK.test(slide.notes) || /https?:\/\//.test(slide.notes);
        issues.push(
          issue("slide/source", slide, `${label}: 「${quantity[0]}」の出典${inNotes ? "がノートにしかない" : "がない"}。_footer に「出典: 」を示す`),
        );
      }
    }
    if (/https?:\/\//.test(slide.footer)) {
      issues.push(issue("slide/footer-url", slide, `${label}: URLは参考資料スライドへ移し、フッターは資料名・年にする`));
    }
    if (mode === "present" && !slide.appendix && slide.notesChars === 0) {
      issues.push(issue("slide/notes", slide, `${label}: 話す内容と次へのつなぎをノートに書く`));
    }
    const commas = [...`${slide.bodyText}`.matchAll(PARTICLE_COMMA)].map((match) => match[0]);
    if (commas.length) {
      issues.push(issue("slide/comma", slide, `${label}: ${[...new Set(commas)].join(" ")} の読点を確認`));
    }
  }

  if (last && last !== standardEndSlide && CLOSING_TITLE.test(last.title)) {
    issues.push(issue("deck/closing", last, `「${truncate(last.title, 18)}」: 持ち帰る一文と次の行動を最後に置く`));
  }

  const seconds = mainSlides.reduce((sum, slide) => sum + estimateSeconds(slide), 0);
  if (options.minutes) {
    const limit = Number(options.minutes) * 60;
    if (!Number.isFinite(limit) || limit <= 0) {
      throw new Error("--minutes は正の数で指定してください");
    }
    if (seconds > limit * 0.9) {
      issues.push(
        issue("deck/timing", null, `推定${formatDuration(seconds)}／持ち時間${formatDuration(limit)}。9割（${formatDuration(limit * 0.9)}）に収める`),
      );
    }
  }

  const order = { error: 0, warn: 1, info: 2 };
  issues.sort((a, b) => a.slide - b.slide || order[a.severity] - order[b.severity]);
  return {
    issues,
    stats: {
      slides: slides.length,
      mainSlides: mainSlides.length,
      seconds,
      unnoted: mainSlides.filter((slide) => slide.notesChars === 0).length,
    },
  };
}

/** 端末での表示桁数（全角2・半角1） */
function terminalColumns(text) {
  return displayWidth(text) * 2;
}

function padColumns(text, width) {
  return text + " ".repeat(Math.max(0, width - terminalColumns(text)));
}

function truncateColumns(text, width) {
  return terminalColumns(text) <= width ? text : truncate(text, (width - 2) / 2);
}

/** タイトル列（横の論理）と推定時間の一覧 */
export function outlineDeck(deck, options = {}) {
  const format = options.format ?? "text";
  const rows = deck.slides.map((slide) => ({
    no: slide.index,
    layout: slide.layout,
    title: slide.title.replace(/\s+/g, " ") || "（見出しなし）",
    body: slide.bodyChars,
    notes: slide.notesChars,
    seconds: slide.appendix ? 0 : estimateSeconds(slide),
    appendix: slide.appendix,
  }));
  const main = rows.filter((row) => !row.appendix);
  const total = main.reduce((sum, row) => sum + row.seconds, 0);
  const unnoted = deck.slides.filter((slide) => !slide.appendix && slide.notesChars === 0).length;
  const summary = [
    `${rows.length}枚（本編${main.length}枚）`,
    `推定${formatDuration(total)}（ノート${SPEAKING_CHARS_PER_MINUTE}字/分換算${unnoted ? `・ノートなし${unnoted}枚を各${UNNOTED_SLIDE_SECONDS}秒で計上` : ""}）`,
    options.minutes ? `持ち時間${formatDuration(Number(options.minutes) * 60)}` : "",
  ]
    .filter(Boolean)
    .join("／");

  if (format === "md") {
    const lines = [
      "| No | 型 | タイトル | 本文 | ノート | 推定 |",
      "| ---: | --- | --- | ---: | ---: | ---: |",
      ...rows.map(
        (row) =>
          `| ${row.no} | ${row.layout} | ${row.title.replaceAll("|", "\\|")} | ${row.body} | ${row.notes} | ${row.appendix ? "付録" : formatDuration(row.seconds)} |`,
      ),
      "",
      summary,
    ];
    return lines.join("\n");
  }
  const layoutWidth = Math.max(4, ...rows.map((row) => terminalColumns(row.layout))) + 2;
  const titleWidth = 48;
  const lines = [
    `${padColumns("No", 4)}${padColumns("型", layoutWidth)}${padColumns("タイトル", titleWidth + 2)}${padColumns("本文", 6)}${padColumns("ノート", 8)}推定`,
    ...rows.map(
      (row) =>
        `${padColumns(String(row.no), 4)}${padColumns(row.layout, layoutWidth)}${padColumns(truncateColumns(row.title, titleWidth), titleWidth + 2)}${padColumns(String(row.body), 6)}${padColumns(String(row.notes), 8)}${row.appendix ? "付録" : formatDuration(row.seconds)}`,
    ),
    "",
    summary,
  ];
  return lines.join("\n");
}

/** lint結果を人が読む形式へ */
export function formatIssues(fileName, result) {
  const marks = { error: "✗", warn: "▲", info: "・" };
  const lines = [fileName];
  for (const entry of result.issues) {
    const where = entry.slide ? `${String(entry.slide).padStart(2)}枚目 L${entry.line}` : "全体";
    lines.push(`  ${marks[entry.severity]} ${entry.severity.padEnd(5)} ${entry.rule.padEnd(20)} ${where}  ${entry.message}`);
  }
  const count = (severity) => result.issues.filter((entry) => entry.severity === severity).length;
  lines.push(`  error ${count("error")} / warn ${count("warn")} / info ${count("info")}`);
  return lines.join("\n");
}

/** ルール一覧（ovs deck rules） */
export function formatRules() {
  return Object.entries(deckRules)
    .map(([id, rule]) => `${id.padEnd(20)} ${rule.severity.padEnd(5)} ${rule.summary}\n${" ".repeat(27)}${rule.why}`)
    .join("\n");
}
