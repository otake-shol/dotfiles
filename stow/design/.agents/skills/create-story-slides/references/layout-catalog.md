# Layout catalog

Choose one primary archetype per slide. Variants may change image placement or density, but must preserve the archetype's narrative job.

| ID | Archetype | Use when | Composition | Avoid |
|---|---|---|---|---|
| L01 | Dark cover | Opening the deck with a clear theme | One template from `cover-templates.md` (Standard or Event): minimal title and subtitle on the left, plus the presenter line or block the presenter introduction gate allows; an illustration or motif only when it previews the deck's subject | Agenda, dense metadata, multiple messages |
| L02 | Context and stakes | Explaining why the topic matters now | Takeaway title above; short context paragraph and one central tension visual below | A generic topic heading without a claim |
| L03 | Section turn | Starting a new chapter or changing the lens | Large section number and title; one sentence that states the question the section answers; a compact map of every part with only the current part emphasized, using the same labels and order as the parts preview and any N01; an optional period line; one recurring motif or light geometric atmosphere at the same coordinates on every L03 | Repeating the full agenda as a list, a section title with no question, changing the composition between section turns |
| L04 | Claim plus hero visual | Making one important concept memorable | Text column on one side; one large illustration, screenshot, or object on the other | Several unrelated visuals or icon rows |
| L05 | Process or journey | Showing sequence, expansion, milestones, or iteration | One horizontal path with two to five stages; use width or color to show change; implication band at bottom | More than six stages or tiny labels |
| L06 | Contrast | Comparing old/new, with/without, or two operating choices | Two balanced halves or two aligned horizontal paths; highlight the decisive difference | Unequal evidence presented as equivalent |
| L07 | Cause and consequence | Explaining a bottleneck, funnel, branch, or compounding effect | One clear cause enters a transformation and produces two or three consequences | Decorative arrows without a causal claim |
| L08 | Operating flow | Explaining a repeatable four-step method | Three or four connected stages with short action titles; supporting artifacts or owners below only when necessary | Dense card grids and long prose inside steps |
| L09 | Case study | Combining concrete context, mechanism, and learning | Narrative copy on the left; one architecture/process visual on the right, kept editable in the Markdown; learning callout at bottom | Retelling the case without a transferable lesson |
| L10 | Evidence or chart | Proving a claim with data | Takeaway title above; one dominant chart; one annotation on the decisive point; source line | Multiple charts competing for attention |
| L11 | Operating model | Showing two lanes, feedback, roles, or system boundaries | Two horizontal lanes or one controlled relationship diagram; connectors first; one central feedback loop | An org chart when the point is flow or responsibility |
| L12 | Summary and close | Resolving the opening with a decision, action, or synthesis | Dark or light conclusion slide with up to three numbered takeaways and one closing visual | Generic thanks (put thanks on L18), repeated agenda, unresolved next step |
| L13 | Stateful process rail | Making a recurring process, lifecycle, or system view the primary content visual while accumulating detail | Reuse one content-area process, lifecycle, or system view in the same position; highlight the active stage or changed path | Using it as a substitute for the persistent top navigator defined as N01, redrawing the structure, or changing labels between sections |
| L14 | Tension beat | Marking an impossible constraint, contradiction, decision, or result | One sentence, question, or number with generous negative space; optional single arrow or quiet motif | Topic labels, long explanations, or several sparse slides in a row |
| L15 | Why, what, how | Connecting rationale to the operating choice and action | Three aligned layers: reason or desired property, selected intervention, concrete implementation | Treating the labels as proof or putting many initiatives inside each layer |
| L16 | Problem and response | Teaching a repeatable mechanism through a paired failure and intervention | One problem slide followed by one response/effect slide, or one aligned contrast; repeat the exact problem label to preserve continuity | Generic `PROBLEM/SOLUTION` labels without evidence, cost, or boundary |
| L17 | Presenter introduction | Showing why this audience should hear this talk from this presenter, only when the presenter introduction gate resolves to full | One variant from `presenter-introduction.md`: relevance (with or without a photo), LT, relationship, or several presenters; small `自己紹介` section label and a claim that links the presenter to the topic or team | Résumés, career timelines, hobby lists, past-employer logos, generated or silhouette portraits, a bare `自己紹介` title unless the user asks for one |
| L18 | End slide | Showing that a presented talk is over and handing the floor to questions | The cover's background and presenter line; one closing sentence in the title style, such as `ご清聴ありがとうございました`; an optional second line at the subtitle position that invites questions or feedback; an optional recurring motif | New content, a repeated summary, an agenda, long contact lists, a page number |

## Selection rules

- Use L01 once at the opening and L12 once at the close.
- End every new presented Standard deck with one L18 after L12, so that the audience can see the talk is over. Preserve an existing deck's structure unless migration is requested. Omit L18 when nobody presents the deck (R5 in `SKILL.md`), and count it toward the length range. When gratitude is the purpose of the talk, such as a farewell or thank-you LT, let the L18 sentence carry the thanks; do not add a second thanks slide.
- Use L03 only for meaningful chapter changes, and count every L03 toward the length range:
  - Lightning decks need none.
  - When the main story has three or more top-level parts that each change the lens, and the talk lasts about 10 minutes or longer (or, when the time is unknown, the main story has about 12 slides or more), open every part with one L03. Do not skip a part, and keep the composition and coordinates identical across them.
  - Otherwise, short decks usually need zero or one, and long talks may use three to six.
- When L03 opens every part, preview the parts once before the first L03, for example on an L08 slide, and do not add a separate agenda slide. Reuse the preview's part labels and order on every L03 map and on N01.
- Do not repeat the same silhouette more than twice in a row.
- Prefer L05 for time and sequence, L08 for an operating method, and L11 for parallel work or feedback.
- Prefer L06 when the audience must choose or notice a difference; prefer L07 when the audience must understand causality.
- Use L09 and L10 together in long talks when a case needs both mechanism and measurable evidence.
- Use L13 when three or more slides explain different stages of the same process through a primary content-area visual. Preserve coordinates and inactive-state styling. L13 may coexist with N01; when both represent the same process, keep labels, order, and active phase synchronized.
- Use L14 sparingly at genuine turns. Do not use it as a substitute for a section title.
- Use L15 for planning and operating-policy explanations. Follow it with concrete evidence or an implementation slide.
- Use L16 for one to three mechanisms in a case study. Add a synthesis after the sequence instead of continuing indefinitely.
- Use L17 at most once, only when the presenter introduction gate in SKILL.md resolves to full or the user asks for a standalone introduction slide. Follow `presenter-introduction.md` for its placement and composition, and count it toward the length range.
- When a slide cannot be mapped cleanly, clarify its narrative job before inventing a new layout.
