# Cover templates

L01 uses one of two templates. Coordinates assume the 1280 x 720 canvas as x, y, w, h in px. Fonts follow the typography roles in `design-system.md`.

## Contents

- Template selection
- Shared title block
- Standard cover
- Event cover
- End slide (L18)
- QA

## Template selection

| Template | Use when |
|---|---|
| Event cover | The request or material names the event of a talk, with an event name, date, or hashtag |
| Standard cover | Otherwise |

Use one template per deck.

The presenter introduction gate decides what the cover shows about the presenter: nothing for none, and the compact line, or the presenter block on the Event cover, for compact and full.

## Shared title block

| Element | Position | Type and color |
|---|---|---|
| Title | 72, 226, 900, 150 | Title role, 50 pt, line spacing 1.15, White, at most two intentional lines |
| Subtitle | 72, 416, 900, 40 | Body role, 22 pt, Primary Soft |

Keep the positions for a one-line title. Keep at least 24 px between the last title line and the subtitle.

When the deck has no subtitle, the subtitle position may carry the presentation date or the occasion in the same style, such as `2026年9月30日`. When the deck has both, append the date after the subtitle with a full-width space. The Event cover keeps the date in its event band instead.

## Standard cover

- Background: Primary Blue.
- Shared title block.
- Compact line: 72, 616, 800, 30; body role, 18 pt, Primary Soft.
- Add no decorative shapes. Place an editorial illustration or motif only when it previews the deck's subject or anchor diagram, keep it on the right or lower edge, and keep it clear of the title block and the compact line.

## Event cover

- Background: Primary Blue.
- Event band:
  - Event name and date: 72, 56, 700, 24; section-label role, 16 pt; the event name in White and the date in Primary Soft, separated by a full-width space.
  - Hashtag: 808, 56, 400, 24, right-aligned; section-label role, 16 pt, Primary Soft. Omit it when none is supplied.
  - Hairline: 72, 96, 1136 x 1; White at 60% transparency.
- Shared title block.
- Presenter block, in place of the compact line:
  - Name: 72, 580, 600, 40; title role, 26 pt, White. Apply the nickname rule in `presenter-introduction.md`.
  - Affiliation, role, and handle: 72, 626, 900, 28; body role, 16 pt, Primary Soft, separated by full-width spaces. Show the handle only in the external scope.
- When the gate resolves to none, keep the event band and omit the presenter block.
- Keep the event band on one line; shorten the event name before reducing the type size.

## End slide (L18)

L18 reuses the deck's cover template so that the talk visibly closes where it opened.

- Background, event band, and compact line or presenter block: the same as the deck's cover.
- Closing sentence: in the shared title block, in the title role and size, bottom-aligned so that a one-line sentence sits just above the subtitle position. Keep it to one sentence, such as `ご清聴ありがとうございました`.
- Second line (optional): at the subtitle position, inviting questions or feedback or naming the next contact point that the scope allows.
- A recurring motif may take the place of the cover's illustration. Add no page number, summary, or new content.

## QA

- Confirm that the deck uses exactly one template, chosen by the selection table.
- Confirm that the title and subtitle keep at least 24 px between them and that no text crosses a motif.
- Confirm that the Event cover's band stays on one line and that a handle appears only in the external scope.
- Confirm that the Standard cover carries no shape without a subject-related purpose.
- Confirm that L18 uses the same template and background as the cover and adds no new content.
