# Marp output

Author every deck as Marp Markdown and export it to PDF. `assets/story-slides.css` implements the Standard profile in `design-system.md` and the coordinates in `cover-templates.md`, `presenter-introduction.md`, and `navigation-components.md`, so choose a layout class and its markup instead of restating positions in the deck. `assets/sample-deck.md` shows every layout and N01 in one story; `assets/sample-variants.md` shows the cover, presenter introduction, and end-slide variants.

## Contents

- Deck file
- Units and type floors
- Page chrome
- Layout markup
- Surfaces, numbers, and emphasis
- N01 markup
- Diagrams and images
- Build and QA
- Handoff

## Deck file

Start every deck with this front matter:

```yaml
---
marp: true
theme: story-slides
lang: ja
paginate: true
title: <deck title>
---
```

- Keep `lang: ja`. Japanese phrase-aware line breaking and the render check depend on it.
- Separate slides with `---`. Write directives in HTML comments, such as `<!-- _class: l05 -->`.
- Any HTML comment that is not a directive becomes a speaker note. Put notes at the end of the slide.
- Inside an HTML block, leave a blank line before and after Markdown content, such as a list inside `<div class="contrast">`.
- Save the deck with its images and use relative paths.

## Units and type floors

- The canvas is 1280 x 720 px. The theme sets type in pt; in CSS 1 pt is 4/3 px, which keeps the proportions of the pt sizes in `design-system.md`.
- Keep core body copy at 18 pt or more and secondary labels at 16 pt or more. Use 11-13 pt for section labels, page numbers, and sources; 10 pt falls below the render check's 14 px floor for secondary text.
- Mark secondary text with `<small>`, as in a source note or the reading of a name. The render check measures other text against the 20 px body floor.

## Page chrome

| Element | Markup | Theme behavior |
|---|---|---|
| Section label | `<!-- _header: 現状 -->` on each slide that needs one | Top left at 12 pt. Hidden on L01, L03, and L18, and replaced by N01 when N01 is present |
| Page number | `paginate: true` in the front matter | Top right; hidden on L01, L03, and L18; moved to the bottom right when N01 is present |
| Source line | `<!-- _footer: 出典: … -->` | Bottom left at 11 pt. Also record the source in the speaker notes |
| Speaker notes | A non-directive HTML comment | Written to `<name>.notes.txt` by the build; never embedded in the PDF |

## Layout markup

Set exactly one layout class per slide with `_class`, matching the layout ID in the outline, such as `<!-- _class: l10 -->`. Write the title as `# …` and break a two-line title with `<br>` at a phrase boundary. Copy the matching slide from a sample deck and replace its copy.

| ID | Class | Markup |
|---|---|---|
| L01 | `l01`, or `l01 event` | `# title`, `<p class="subtitle">`, and one compact line: `<p class="compact">` for a presenter line, or `<small class="compact author">` for an author line. Event cover: `<p class="event-line">イベント名　<span class="date">日付</span></p>`, optional `<p class="hashtag">`, and `<p class="presenter-name">` with `<p class="presenter-affil">` in place of the compact line. Optional `<img class="motif">` |
| L02 | `l02` | One short paragraph and one tension visual: `.kpis`, `.contrast`, `.exception`, or an inline SVG |
| L03 | `l03` | N01 markup as the part map, `<p class="number">01</p>`, `# section title`, `<p class="question">`, and optional `<p class="period">` |
| L04 | `l04` | `<div class="split">` with a text `<div>` and a `<div class="visual">`. To put the visual first, write it first and use `split reverse` |
| L05 | `l05` | `<ol class="rail">` with two to five `<li><b>stage</b><span>detail</span></li>`; `class="active"` on the decisive stage, `style="flex-grow: 1.6"` to show change by width; `<p class="band">` for the implication |
| L06 | `l06` | `<div class="contrast">` with two `<div>`s, the decisive one with `class="hl"`; `<p class="band">` for the decisive difference |
| L07 | `l07` | `<div class="causal">` with `<div class="cause">`, `<div class="mechanism">`, and a `<ul>` of two or three consequences; `li class="exception"` for an exception |
| L08 | `l08` | `<ol class="steps">` with three or four `<li><b>action</b><span>owner or artifact</span></li>` |
| L09 | `l09` | `.split` with the narrative and a `.visual`; `<p class="band">` for the transferable lesson |
| L10 | `l10` | `.bars` with one `.bar.hl` and the rest muted, `--v` as the bar length, `<p class="annotation">` on the decisive point, and `_footer` for the source |
| L11 | `l11` | `<div class="lanes">` with two `.lane` blocks, `.lane.main` for the main path, and `<p class="loop">` for the central feedback loop |
| L12 | `l12`, or `l12 dark` | `<ol class="takeaways">` with up to three `<li><b>takeaway</b><span>detail</span></li>` |
| L13 | `l13` | `<ol class="rail">` at a fixed position with the stage marked `active`, and details in `<div class="detail">`. Keep the stages and labels identical on every L13 slide. Put every image inside `.detail` too: the rail and `.detail` are absolutely positioned, so an image placed between them is hidden behind the rail, and the render check does not flag it. `.detail` has about 240 px of height |
| L14 | `l14`, optional `dark` | `# one sentence or question`, or `<p class="kpi"><span class="fig">60%</span><span class="label">…</span></p>` |
| L15 | `l15` | `<div class="wwh">` with three rows of `<div><b>WHY</b><p>…</p></div>` |
| L16 | `l16` | `_header` carries the exact problem label; `<div class="pr">` with `.problem`, `.response`, and `.effect`, and the remaining cost or boundary in `<small>` |
| L17 | `l17`, `l17 photo`, `l17 lt`, `l17 relationship`, or `l17 team` | `_header: 自己紹介`, or `登壇者紹介` for several presenters. `# claim` except in LT. `<p class="name">` with `<small class="reading">（読み）</small>`, `<p class="affil">` with the team and role split by `<br>`. Relevance: `<ul class="points">`; photo: `<img class="photo">`; LT: `<p class="handle">` and `<p class="claim">`; relationship: `<dl class="rows">` with three `dt`/`dd` pairs; several presenters: `<div class="people">` of `<div class="person">` with `.name`, `.role`, `.part`, and `.why`. Optional `<p class="disclaimer">` |
| L18 | `l18`, or `l18 event` | The cover's markup with `# closing sentence`, an optional `<p class="subtitle">`, and the same compact line or presenter block as L01 |

Use `dark` only where `design-system.md` allows Deep Navy, such as a major conclusion on L12 or L14.

## Surfaces, numbers, and emphasis

- `<p class="band">`: destination or conclusion in Deep Navy, pushed to the bottom of the slide. `band soft` uses Pale Blue.
- `.note`: context surface. `.exception`: exception or intervention with an orange line. `.quote`: personal message. `.evidence`: white evidence surface. `.annotation`: callout on the decisive point.
- `.cols` and `.cols three`: two or three columns.
- `strong`: the conclusion inside a sentence. `em`: the decisive number or word in Primary Blue.
- `.kpis` holds `.kpi` blocks: `<span class="fig">` for the figure and Latin units, `<span class="unit">` for a Japanese unit such as `日` or `倍`, and `<span class="label">` for the caption. `kpi muted` marks a before value; `kpi exception` adds an orange underline instead of orange text.

## N01 markup

Place N01 first on the slide, before the title:

```html
<header class="n01"><ol><li class="active">現状を測る</li><li>待ちを減らす</li><li>週次で出す</li></ol></header>
```

- Keep the labels and their order identical on every slide. Mark exactly one phase `active`. Use `done` only when the source shows that a phase is complete.
- The theme lowers the title, hides the section label, moves the page number to the bottom right, and applies the dark-background variant on `l03` and `dark` slides.
- Use the same markup as the part map on L03.

## Diagrams and images

- Build simple diagrams from the components above. For anything else, write an inline SVG in the Markdown with the token colors from `design-system.md`, `Zen Maru Gothic` for labels, `Noto Sans JP` for text, and at least 22 px type. Draw connectors before nodes so that lines stay behind objects.
- Give every image and inline SVG alt text, with `alt` or `aria-label`. Use SVG for icons and logos directly; rasterize only when a source is raster-only.
- Mark up marks and captures with the theme classes instead of inline styles: `<img class="ico" src="assets/icons/<name>.svg" alt="…">` before a label (30 px), `<img class="logo" src="assets/logos/<id>.svg" alt="<製品名>のロゴ">` next to the product name (26 px), `<img class="ico-lg" …>` at the top of a `.cols` column (56 px), and `<img class="shot" src="assets/<capture>.png" alt="…">` for a cropped screenshot (full width, at most 360 px high; override `max-height` inline only when the layout needs it).
- Code blocks and inline code in tables render at 15 pt (20 px) to meet the body floor. Keep code excerpts to about five lines; put the rest in the speaker notes.
- Local images load because the build allows local files.

## Build and QA

Run the build script in this skill's `scripts/` directory:

```bash
scripts/build.sh <deck.md> <output directory>
```

1. `ovs deck check` renders the deck and measures overflow, clipping, collisions with the header, footer, or page number, overlaps, one- or two-character last lines, small text, contrast, broken images, and missing fonts. An error stops the build; fix every error. Treat each warning as a defect unless the referenced specification requires the flagged element, and state any warning that remains in the handoff.
2. Inspect `<name>-check/contact-sheet.png` for the 25% thumbnail checks and every `<name>-check/slide-NN.png` at full size. Then apply the QA lists in `design-system.md` and the other references.
3. The build writes `<name>.pdf` with bookmarks and `<name>.notes.txt`. It never embeds speaker notes in the PDF, because recipients could read them.

- Without `ovs`, the build writes slide PNGs instead of measuring them; inspect each one.
- If `marp` or a Chrome-based browser is unavailable, stop at the outline and the Marp source and say that the PDF is blocked.
- Produce PowerPoint only on explicit request: `marp --pptx` with the same `--theme`, `--html`, and `--allow-local-files` options writes image-only slides that cannot be edited. Say so in the handoff.

## Handoff

Give the PDF path and the notes path, the 自己紹介 decision line, every remaining placeholder, any font substitution, and any remaining warning with its reason.
