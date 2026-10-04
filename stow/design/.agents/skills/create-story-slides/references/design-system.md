# Design system

## Contents

- Visual character, canvas, color, and surface balance
- Typography and copy
- Density and pacing
- Diagrams, images, icons, and logos
- Charts, screenshots, and evidence
- QA

## Visual character

Aim for calm, concrete, technically credible slides. Combine the readability of an internal operating proposal with the narrative polish of a conference talk. Use warm light pages for explanation, Primary Blue for the ordinary cover, and Deep Navy selectively for section turns, destination blocks, or major conclusions. Do not default every full-bleed slide to the darkest tone.

## Canvas and grid

- Use a 16:9 canvas. For programmatic authoring, prefer 1280 x 720.
- Keep left and right margins near 72 px and top/bottom margins near 56 px.
- Align elements to an 8 px grid.
- Reserve the top-left area for a small section label and the top-right for a page number on light slides. When N01 is active, let the persistent phase navigator own this top orientation area, suppress the redundant section label, and move the page number to a consistent non-conflicting position.
- Place the takeaway title below the active orientation element: the section label or N01. Allocate roughly the lower 55-65% of the slide to the primary visual or evidence.
- Keep dark cover, section, and end slides free of routine page chrome unless it improves navigation. Never put a page number on L18.

## Color tokens

| Token | Hex | Use |
|---|---:|---|
| Primary blue | `#2C63B4` | Ordinary covers, active navigation, key paths, decisive numbers |
| Deep navy | `#123858` | Destination blocks, major conclusions, high-confidence anchors |
| Primary soft | `#DCE8F6` | Supporting text on Primary Blue, secondary emphasis |
| Pale blue | `#ECF2F9` | Quiet bands, inactive states, contextual surfaces |
| Accent orange | `#E86A50` | Tension, exception, inflection, intervention, action |
| Accent soft | `#FBECE7` | Exception surfaces that need dark readable text |
| Warm canvas | `#FAF8F3` | Default light-slide background |
| Mist gray | `#D5DDE6` | Dividers, borders, secondary paths |
| Ink | `#17202A` | Main text on light slides |
| Muted ink | `#65717E` | Supporting copy and source labels |
| White | `#FFFFFF` | Text on Primary Blue or Deep Navy; evidence surfaces used sparingly |

Use no more than three dominant colors on one slide. Treat Accent Orange as a scarce semantic signal, not decoration. Prefer Warm Canvas over pure white for the page background; use white as a local evidence surface rather than turning the slide into a grid of cards.

The verified core contrast pairs are White on Primary Blue `5.91:1`, White on Deep Navy `12.12:1`, Ink on Warm Canvas `15.50:1`, and Muted Ink on Warm Canvas `4.69:1`. Accent Orange on Warm Canvas is only `2.99:1`, so do not use orange for body text. Use an orange line or border, or use Accent Soft with Ink or Deep Navy text instead. If a large orange label is necessary, verify that specific text and background combination independently.

## Color allocation and surface roles

For an ordinary Standard deck, use this deck-level balance as a starting point:

| Color role | Approximate share |
|---|---:|
| Warm Canvas and White | 66% |
| Primary Blue | 18% |
| Deep Navy | 9% |
| Primary Soft, Pale Blue, and Mist Gray | 5% |
| Accent Orange and Accent Soft | 2% |

Treat these values as an overall balance, not a per-slide quota. A cover may be mostly Primary Blue, an evidence slide may be mostly Warm Canvas, and a major conclusion may use more Deep Navy. Across the deck, keep the warm canvas dominant, let Primary Blue carry orientation and the main route, reserve Deep Navy for weight and arrival, and keep orange rare enough that it continues to signal a real exception or intervention.

Use these surface rules consistently:

- Default cover: Primary Blue with White title and Primary Soft supporting copy.
- Standard content slide: Warm Canvas page, Ink title, and Primary Blue for the decisive number or path.
- Evidence surface: White with a Mist Gray boundary; use only where the separation improves reading.
- Destination or conclusion block: Deep Navy with White text.
- Context or inactive state: Primary Soft or Pale Blue with Deep Navy or Muted Ink text.
- Exception or intervention: Accent Orange as a line or boundary, or Accent Soft with Deep Navy text.
- Personal message or quote: Pale Blue with a 6 px Primary Blue left bar and Ink or Deep Navy text. Do not give a message Accent Orange or Accent Soft unless the message itself is an exception or a call to action.

## Typography

In the Standard profile, assign fonts by role. Latin letters follow the family of the text they sit in; do not add a separate Latin font.

| Role | Typeface name | Bold |
|---|---|---|
| Deck, section, and slide titles; mid-level labels and callouts | `Zen Maru Gothic` | on |
| Section labels and N01 navigation labels | `Zen Maru Gothic Medium` | off |
| Body copy, sources, tables, and chart text | `Noto Sans JP` | only for the conclusion inside a sentence |
| Figure numbers: the decisive number of a KPI or L14, the L03 section number, L12 takeaway numbers, and page numbers | `Plus Jakarta Sans` | on |

- The Marp theme reaches Medium as `Zen Maru Gothic` at weight 500 and bold at weight 700. `Noto Sans JP` and `Plus Jakarta Sans` are variable fonts and render their true Bold, so a PDF font name such as `PlusJakartaSans-Regular_Bold` does not indicate synthetic bold.
- Set only the figure itself in `Plus Jakarta Sans`, including numeric symbols and Latin units such as `%` or `h`. Put a Japanese unit such as `件` or `倍` in a separate span (`<span class="unit">`) set in `Zen Maru Gothic` bold; Plus Jakarta Sans has no Japanese glyphs.
- Keep numbers inside titles, labels, body copy, tables, and charts in the surrounding family.
- `assets/story-slides.css` declares these families. In an inline SVG chart or diagram, set labels in `Zen Maru Gothic` and other text in `Noto Sans JP`.
- If a font is unavailable in the rendering runtime, substitute `Noto Sans JP`, then `Yu Gothic`. Disclose the substitution in the handoff and do not claim the intended typography.
- Kanji-only navigation labels look almost identical in `Zen Maru Gothic` and `Noto Sans JP` at 10-13 pt. Do not enlarge or embolden them to make the rounded face visible.
- Deck title: 50-58 pt, bold.
- Section title: 40-48 pt, bold.
- Slide title: 35-42 pt, bold.
- Mid-level labels and callouts: 20-26 pt, bold.
- Body: 18-22 pt for core explanatory copy. Use 16 pt only for secondary labels that do not carry the slide's primary argument.
- Section labels, page numbers, and sources: 10-13 pt.
- Use bold for the conclusion inside a sentence, not for whole paragraphs.
- Keep titles to one or two intentional lines. Prefer a manual break at a meaningful phrase boundary.

## Copy

- Write titles as claims a presenter can say aloud, not topic labels.
- Keep a typical Japanese title around 20-42 characters when possible.
- Use two to four short bullets or one concise explanatory paragraph per content area.
- Make the final line or bottom callout state the implication when the slide needs one.
- Avoid slogans, repeated parallel phrasing, and abstract noun chains.

## Density and pacing

- Alternate explanation, evidence, and synthesis. Do not make every slide equally dense.
- Use a sparse slide only for a real narrative turn: constraint, contradiction, decision, or outcome.
- After two dense evidence slides, prefer a synthesis or model slide before adding more detail.
- Keep working-session detail in the appendix when the audience can inspect it later; do not make a projected slide behave like a document page.
- At 25% thumbnail size, the title and primary visual relationship must remain recognizable.

## Diagrams

### Visual evidence selection

During slide planning, choose the representation that best supports the claim:

| Claim or audience need | Preferred representation | Decision criterion |
|---|---|---|
| Relationship, branching, boundary, or mechanism | Editable diagram | The audience needs to see how parts connect |
| Quantity, trend, or measured comparison | Chart or small table | Supported data and comparable conditions are available |
| UI operation, observed behavior, or an exact documented statement | Real screenshot or artifact | The actual appearance or wording is evidence |
| A premise, personal question, or synthesis | Concise text | A visual would add no useful relationship or evidence |

Record a compact visual plan with slide number, representation, purpose, asset source or capture conditions, and status (available / to create / missing). Keep it in the outline or deck README. Inspect existing project assets first. When evidence is missing, finish independent diagrams and copy, then request only the material needed for the claim; do not invent an interface, screenshot, output, or measurement.

For an observed UI change, prefer comparable before/after captures and record the version, operation, and session conditions. A documentation screenshot supports the documented rule, not proof that the user reproduced it. Clearly distinguish real captures, schematic diagrams, and measured results. Do not draw rising performance curves without measured data. Use no minimum number of images per deck.

- Use diagrams only when relationships, sequence, boundaries, or tradeoffs are clearer visually.
- Prefer flat rectangles, wedge arrows, straight connectors, lanes, and one highlighted exception.
- Create connectors before nodes so lines remain behind objects.
- Keep connector meanings consistent: Primary Blue for the main path, Mist Gray for context, and Accent Orange for friction or intervention. Use Deep Navy for a destination or integration gate, not as a second competing route.
- Avoid tiny labels, decorative or excessive icons, and nested boxes. Split a dense diagram across slides instead. Follow "Icons and logos" for when a mark helps.
- Keep simple diagrams editable as theme components or inline SVG in the Markdown source. Use a generated illustration only for a cover, section atmosphere, or a concept that cannot be expressed cleanly with those shapes.
- When a process, lifecycle, system map, or operating model recurs, preserve its geometry and labels across slides. Change only the active stage, highlighted path, annotation, or before/after scale.
- Use the repeated diagram as navigation and accumulated evidence, not as decorative repetition.
- Distinguish a content-area anchor diagram from page chrome. Use L13 when the process itself is the primary visual; use N01 from `navigation-components.md` when the whole path and current phase must remain visible above different primary layouts.

## Images and illustrations

- Prefer editorial illustrations with matte textures, restrained depth, and ample negative space.
- Keep the palette close to Deep Navy, Warm Canvas, Mist Gray, Primary Blue, and Accent Orange.
- Do not put text inside generated images.
- Place the visual opposite the main text column and preserve useful negative space for the title or explanation.
- Do not reuse the same hero image on multiple slides except as a deliberate background motif.

## Icons and logos

Use a mark only when it lets the audience recognize an item before reading its label.

- **Logos for named products and services:** when a slide names a concrete external product, service, tool, or channel that the audience recognizes by its mark, such as Datadog, Slack, GitHub, an AWS service, or an AI tool, place its official mark next to that item. Name the product in the same item's text; a logo never stands alone. Use one mark per product.
- **Concept icons for labeled items:** add a line icon to a flow step, list item, fact, or function only when the icon maps one-to-one to that item's label and reinforces it. Do not use icons as decoration, to fill space, or to signal status, success, or severity.
- **One family, one size, one color rule:** use one icon family for the whole deck, such as Lucide (ISC). On one slide, give every mark in the same role the same displayed size, usually 20-36 px, and align it with its label. Draw concept icons in the profile's primary blue on light surfaces and in White on primary-blue or dark fills; keep logos in their own brand colors.
- **Density:** keep to about five or six marks per slide. Do not add icons to every bullet of a long list, to dense tables, or to slide titles.
- **Slides without marks:** keep L01, L03, L12, L14, L17, and L18 free of concept icons and third-party logos.
- **Sources and integrity:** prefer assets already in the project, then a vetted local catalogue that records provenance, such as the brand-mark catalogue bundled with the archify skill, then the owner's official media kit. Do not recolor, crop, stretch, outline, or redraw a logo, and follow the owner's brand guidelines. When no licensed source is available, omit the mark instead of drawing an imitation. Use SVG directly; when only a raster source exists, use one of at least four times the displayed size. Give every mark alt text, and record logo and icon sources in the speaker notes or the deck README.
- **Organization logos:** add an organization's own logo only when the user supplies it with its brand rules for the deck, and never pair it with third-party logos, which identify tools only.

## Charts and evidence

- Show only the data needed to support the current claim.
- Highlight one ordinary series in Primary Blue. Use Accent Orange only when the highlighted point is an exception, intervention, or inflection; mute the rest.
- Remove chart junk, heavy borders, unnecessary legends, and redundant labels.
- Put the meaning in the title or an adjacent callout instead of making the audience infer it.
- Add the source in speaker notes and, when audience-relevant, a small visible source line.
- Prefer one decisive metric, comparison, or inflection per slide. Move full KPI tables to the appendix unless the audience must inspect the table to decide.
- Distinguish observation, interpretation, and causal claim. Use cautious language when the evidence shows correlation or timing but not causality.

## Screenshots and reference artifacts

- Never shrink a full schedule, spreadsheet, chat thread, code editor, architecture canvas, or web screen and expect the audience to read it.
- Crop to the decisive region, enlarge it, and add one annotation that explains what to notice.
- Preserve the source meaning when cropping or annotating. Keep the original capture separately and record the URL or supplied file, capture date, and relevant version or conditions in notes or the deck README. Keep annotation text separate from the source image so it remains editable.
- When both overview and detail matter, use an overview slide followed by a zoom slide or use one overview thumbnail plus one readable crop.
- Rebuild small tables and simple flows with Markdown tables or theme components. Use a raw screenshot only when authenticity is evidence.
- Replace raw URLs with a short source label or speaker-note link. Do not let URLs become visual content.
- Remove or redact names, avatars, internal identifiers, and confidential data unless the user explicitly authorizes their inclusion.

## QA

- Check intentional title wrapping, body overflow, object overlap, page-number consistency, and source legibility.
- Inspect every slide at full size after rendering, using the images that `scripts/build.sh` writes.
- Confirm that the visual hierarchy is obvious at a glance: section, claim, evidence, implication.
- Confirm that orange always has a meaning.
- In the Standard profile, confirm that titles, labels, and navigation use `Zen Maru Gothic`, body and chart text use `Noto Sans JP`, only figure numbers use `Plus Jakarta Sans`, and any font substitution is disclosed.
- Confirm that the deck-level color balance remains warm and light overall, Primary Blue carries the main orientation, and Deep Navy is selective rather than the default full-page background.
- Confirm that no small text relies on Accent Orange against Warm Canvas.
- When N01 applies, confirm that its coordinates, phase labels, order, active-state treatment, and omission rules remain consistent across the deck.
- Confirm that no title, bottom note, screenshot, or diagram label is clipped by the canvas edge.
- Confirm that every screenshot annotation and every table cell needed for the argument is readable at fit-to-window size.
- Confirm that every logo has its product named in the same item, uses official unmodified artwork, and has its source recorded.
- Confirm that concept icons come from one family, map one-to-one to labeled items, share one size per role on each slide, and stay off L01, L03, L12, L14, L17, and L18.
- For a presented deck, confirm that exactly one L18 follows L12 and adds no new content.
- Confirm that draft prompts, empty section pages, asset-library pages, and duplicate agenda slides are not present in the audience-facing deck.
