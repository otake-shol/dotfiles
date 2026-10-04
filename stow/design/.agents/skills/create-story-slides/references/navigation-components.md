# Navigation components

Navigation components are cross-slide orientation aids. They sit outside the primary layout archetype, so a slide may use one layout ID such as L09 or L10 and also use a navigation component such as N01.

## Contents

- Component model
- Decision gate
- N01 persistent phase navigator
- Outline contract
- Placement and compatibility
- State and visual behavior
- Dark-background variant
- Exceptions
- QA

## Component model

Use a navigation component only when it reduces the audience's reorientation cost. Define it once for the deck, keep its labels and geometry stable, and assign its state per slide. Do not use it as a decorative agenda or expose component IDs in audience-facing copy.

Navigation components do not replace a slide's narrative job or layout ID. For example, a chart slide may be `L10 + N01`, and a process explanation may be `L13 + N01`.

## Decision gate

Use N01 when all of the following are true:

- the story has three to six stable, ordered phases;
- at least three content slides discuss different phases or remain inside one phase long enough that the audience may lose its place;
- showing the whole path and the current phase improves comprehension;
- the phase labels can be fixed before slide authoring.

Prefer a section label or L03 section turn instead when the deck has only one or two phases, the headings are unrelated topics rather than an ordered path, or the phase model is likely to change during the presentation. Do not add N01 merely because the source deck has an agenda.

## N01 persistent phase navigator

N01 keeps the whole ordered path visible while emphasizing the current phase. It is appropriate for a development lifecycle, customer journey, transformation sequence, operating cycle, review method, or other stable progression.

Define one phase map before planning individual slides:

| Field | Requirement |
|---|---|
| `navigator_id` | Use `N01` in planning metadata. |
| `phase_id` | Use a short stable identifier that does not appear in audience-facing copy. |
| `label` | Use a concise audience-facing label; keep wording and order unchanged throughout the deck. |
| `order` | Define one unambiguous order from 1 through the final phase. |

Use three derived visual states:

- **Completed:** phases before `current_phase`; recognizable but quieter than the active phase.
- **Active:** the one phase assigned to the current slide; strongest contrast and weight.
- **Upcoming:** phases after `current_phase`; legible but visually subordinate.

If the phases are ordered but completion would overstate reality, use **Active** and **Inactive** only. Never imply that a phase is complete when the source material does not support that claim.

## Outline contract

When N01 applies, define the phase map once and add `Navigator` and `Phase ID` to the internal slide outline. Assign every slide one of the following:

- `N01` plus exactly one valid phase ID; or
- `—` plus an omission reason allowed by the Exceptions section.

Example planning row:

| Slide | Title | Narrative job | Layout | Navigator | Phase ID |
|---:|---|---|---|---|---|
| 7 | 要件を早く固定し、後続作業の待ち時間を減らす | Explain the intervention | L09 | N01 | define |

Validate that phase IDs are defined and normally progress in non-decreasing order across the main story. A phase may remain visible without receiving a dedicated slide when the source does not cover it. A backward transition is allowed only when the narrative explicitly returns to an earlier phase; make the return visible and explain why.

## Placement and compatibility

For the default 1280 x 720 canvas:

- reserve a top navigation band approximately 24-36 px high;
- place the band inside the horizontal safe area, normally `x=72` to `x=1208`;
- place the takeaway title below the band with enough separation to preserve hierarchy;
- keep the band at the exact same coordinates and width on every eligible slide;
- divide the available width consistently across phases unless phase duration is itself meaningful and intentionally encoded.

When N01 is active, it owns the routine top orientation area. Do not also show a redundant top-left section label. Move the page number to a consistent non-conflicting position, normally the footer, unless the governing template already provides another safe location.

N01 may coexist with any content layout. L13 remains a primary content-area diagram used to explain a process or accumulate evidence; N01 is compact page chrome used to preserve location. When both use the same phase model, their labels, order, and active phase must agree.

## State and visual behavior

Do not rely on color alone. Combine color with at least one of weight, underline, fill, border, or an explicit current-position marker.

For the Standard profile:

- use Primary Blue with White bold text and a non-color cue such as fill, weight, border, or underline for the active phase;
- use Deep Navy or Primary Soft for completed phases only when completion is evidenced;
- use Pale Blue or Mist Gray with Muted Ink for upcoming or inactive phases;
- do not use Accent Orange for ordinary progression; reserve it for a real exception, intervention, or risk.

### Dark-background variant

The light-slide states above lose their hierarchy on a dark full-page background: a blue active cell blends into the page while pale inactive cells become the brightest objects. On any eligible slide whose page background is dark, invert the states instead of reusing the light-slide styling:

- **Active:** White fill with bold text in the profile's primary blue, plus an underline in the same blue. The active cell must be the brightest object in the navigator.
- **Inactive:** no fill, a 1 px White outline, and White regular-weight text.
- Keep the band's coordinates, cell widths, labels, and order identical to the light-slide navigator. Change only the state styling.

Profile colors for the dark variant:

| Profile | Dark page backgrounds | Active text and underline | Inactive text and outline |
|---|---|---|---|
| Standard | Primary Blue, Deep Navy | Primary Blue on White | White |

These pairs stay within the verified combinations: Primary Blue on White and White on Primary Blue or Deep Navy. Do not use a translucent fill or a pale tint on a dark page.

Keep labels readable at fit-to-window size. Use the design system's 10-13 pt range for section labels and navigation text; shorten labels or increase the navigation band's height before reducing text below 10 pt.

## Exceptions

- **L01 cover:** omit N01.
- **L17 presenter introduction:** omit N01; the phase path has not started yet.
- **L03 section turn:** choose one rule for the deck: either keep N01 to preserve continuity or omit it because the section turn itself provides orientation. Do not alternate without meaning. When L03 opens every part, prefer omitting N01 there and showing the part map inside L03 instead: the same labels and order as N01, the dark-background variant on a dark page, and the current part as the brightest cell.
- **L12 close:** keep the final phase active when it reinforces resolution; otherwise omit N01.
- **L18 end slide:** omit N01.
- **Appendix:** omit N01 or replace it with a separate `付録` label. Do not add `付録` as a lifecycle phase unless it is genuinely part of the model.
- **Full-bleed evidence or image:** preserve N01 when the deck has promised persistent orientation; adapt the content crop instead of allowing the navigator to disappear unexpectedly.

## QA

- Confirm that every eligible content slide contains N01 at identical coordinates and size.
- Confirm that exactly one phase is active on every N01 slide.
- Confirm that labels, order, widths, and inactive styling do not drift between slides.
- Confirm that the outline phase assignment matches the rendered active phase.
- Confirm that N01 does not collide with the title, page number, logo, source line, or screenshot.
- Confirm that the active phase is identifiable without color and at 25% thumbnail size.
- Confirm that on every dark-background slide the navigator uses the dark-background variant and the active cell is the brightest cell in the band.
- Confirm that completed styling does not make an unsupported completion claim.
- Confirm that L13 and N01 agree when both represent the same process.
- Confirm that omission on covers, presenter introductions, section turns, closes, and appendix slides follows one documented deck-level rule.
