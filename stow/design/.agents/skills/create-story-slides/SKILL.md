---
name: create-story-slides
description: Create clear Japanese business presentations with one-message-per-slide storytelling, a restrained navy-blue-orange visual system, and proposal, planning, review, or case-study modes at short or long length. Decide per deck whether to add a presenter self-introduction (自己紹介) slide or a presenter line on the cover, filling it from a local presenter profile when one exists. Use when turning a memo, project plan, strategy, operational proposal, technical explanation, retrospective, case study, LT, or conference-talk content into a slide outline or a Marp deck exported to PDF, or when the user asks for a standalone self-introduction slide.
---

# Create Story Slides

Turn rough source material into a cumulative story that is easy to present and easy to scan. Default to Japanese copy. Choose the communication job before choosing the length; use a short proposal only when the audience needs a decision.

## References

Read all four core references before planning a deck:

- `references/story-modes.md`: choose the communication job, length, and narrative sequence.
- `references/design-system.md`: apply typography, color, spacing, copy, diagram, and chart rules.
- `references/layout-catalog.md`: map every slide to one of the supported layout archetypes.
- `references/reference-derived-patterns.md`: apply the reusable storytelling patterns and reject the common failure modes.

Before choosing the composition, also read the shared
[design intent and user burden guide](../otake-visual/references/design-intent.md).
Record the audience's task, information priority, and composition rationale in the outline's
production notes. Apply its final review to the rendered deck; preserve the selected visual profile.

Also read `references/navigation-components.md` when the story spans three or more stable phases, the user requests persistent current-position context, or a reference deck uses a repeated phase navigator. It defines cross-slide components separately from primary layout IDs.

Read `references/cover-templates.md` before planning or authoring the cover; it defines the Standard and Event cover templates.

Read `references/presenter-introduction.md` when the presenter introduction gate resolves to full or compact, or when the user asks for a standalone presenter introduction slide. It defines L17, the compact presenter and author lines, presenter data sources, confidentiality scopes, and the outline contract. The gate itself is defined only in this file.

Read `references/marp-output.md` before authoring or rendering a deck. It maps every layout and N01 to the Marp theme in `assets/`, defines page chrome and speaker notes, and owns the build and QA commands.

## Visual profile

Use the Standard profile for every deck: the default navy-blue-orange system and typography in `references/design-system.md`.

If a product, service, client, or another organization may have its own governing brand, do not imitate it from memory. Ask the user to identify or provide that brand's rules and approved assets, and apply them only to colors, typography, imagery, charts, and logos while keeping the narrative and layout rules from the other references.

After a profile is selected, keep it for the outline, Marp authoring, PDF export, page additions, copy edits, and visual revisions of that deck. Do not ask again unless the user starts a different deck or explicitly changes the profile.

## Presenter introduction decision gate

Resolve the presenter introduction once per deck, after the audience, communication job, and length are known. Judge by familiarity, not by organizational membership or by keywords such as LT or 勉強会 alone. An audience member is familiar with the presenter after working with them or knowing them well; a few Slack exchanges do not count. Unless the request says otherwise, treat the team the presenter works in as familiar, and people from other internal teams or outside the company as mostly not familiar. Treat the requesting user as the author, and as the presenter unless the request says someone else presents or nobody presents.

| Outcome | Apply |
|---|---|
| full | One L17 presenter introduction slide, normally slide 2, plus the presenter's name on the cover |
| compact | One compact line on L01 and no L17; `presenter-introduction.md` defines the line types |
| none | No presenter information beyond what the user explicitly requests |

Evaluate R1-R8 in order; the first match wins:

- **R1 Explicit instruction:** apply when the user explicitly asks to include or omit a self-introduction or the presenter's name; the phrases below are examples. Facts such as a moderator introducing the presenter are not instructions. When an instruction matches several rows, the none row wins.

  | Instruction | Outcome | Offer as an override when the outcome is |
  |---|---|---|
  | `自己紹介を入れて`, `自己紹介を1枚で` | full | compact or none |
  | `表紙に名前だけ` | compact | none |
  | `名前も不要`, `表紙にも名前を入れない` | none | full or compact |
  | `自己紹介なし`, `自己紹介スライドはいらない` | Remove L17 only: evaluate R2-R8, turn full into compact, and keep compact or none unchanged. Label the decision line `R1→R<n>` after the rule that matched. After turning full into compact, say once in the handoff that the name and role remain on the cover and that `名前も不要` removes them. | full |

- **R2 Continuing deck:** for page additions, edits, compression, or re-renders of an existing deck, inherit its outcome and confidentiality scope. A self-introduction slide in a supplied deck counts as L17, and a name or author line on its cover counts as a compact line. When no decision line survives, infer the outcome from the deck (L17 means full, a compact line alone means compact, and neither means none), infer the scope from the deck's evident audience or the request with external as the default, and treat this handoff as the deck's first for the override hint. Never add, remove, or rewrite presenter elements unless the user asks, even when shortening or restructuring the deck; flag in the handoff any kept element that conflicts with the current scope.
- **R3 No presenter or author yet:** select compact with a placeholder line for a reusable template or a deck whose presenter is undecided, and do not read the local presenter profile.
- **R4 Familiar audience:** select none when every audience member is familiar with the presenter, and also with the author when someone else presents, such as the presenter's day-to-day team, a 1on1 with the direct manager, or a recurring meeting whose members regularly work with the presenter. R4 does not apply when the deck will clearly travel to people who are not familiar with the presenter.
- **R5 Read, not presented:** select compact with an author line when nobody presents the deck, such as a Confluence page, pre-read, or circulated PDF. A recorded talk, or a deck that someone presents and later circulates, counts as presented.
- **R6 Decision deck:** select compact when the deck asks its audience to decide or approve, or reports briefly to decision makers, whatever its story mode, even when the audience is new to the presenter.
- **R7 Unfamiliar audience:** select full for a live or recorded talk in which most of the audience is not familiar with the presenter, such as an external conference, meetup, LT, or study session, a cross-organization study session or training, or the first meeting with a team the presenter joins from elsewhere. Select compact instead when a moderator or organizer introduces the presenter, or when four or more presenters share the talk.
- **R8 Otherwise:** select compact. When the audience is unknown, apply the external confidentiality scope to presenter facts.

When someone other than the requesting user presents to an internal audience, a compact line names both the presenter and the author. Do not ask a question for this gate alone; when the user asks whether an introduction is needed, answer with the matching rule and one sentence of reasoning.

Record the result in one line at the top of each outline and handoff, even for none: `自己紹介: compact（R6: 他部署の意思決定者への短い提案）`. When presenter facts are used, append `｜出典:` with `依頼内容`, `提供資料`, or `登壇者プロフィール（更新 YYYY-MM-DD）`, joining several sources with `・`. In the first outline or handoff of a deck, unless R1 matched (including `R1→R<n>`) or the output has no L01, add one override hint that offers one phrase from each R1 row whose last column matches the current outcome. Keep the line out of slide copy and speaker notes.

## Workflow

1. Establish the communication job in one sentence: audience, desired outcome, and central takeaway.
2. Extract only supported facts, claims, decisions, examples, and evidence from the supplied material. Never invent data, quotations, people, outcomes, or sources. Use an explicit placeholder when a necessary fact is missing.
3. Choose a communication job and length using `story-modes.md`. Use a short proposal only when the audience needs a decision; otherwise select planning, review, or case-study mode explicitly.
4. Resolve the visual profile: use the Standard profile unless the user supplied another governing brand's rules for this deck.
5. Resolve the presenter introduction through its decision gate. For full, plan L17 as slide 2 unless `presenter-introduction.md` allows slide 3; for compact, add one compact line to L01; for none, add no presenter information.
6. Decide whether a cross-slide navigation component applies. When N01 applies, define its ordered phase map once and assign one phase ID to every eligible slide; do not treat N01 as the slide's primary layout.
7. Write the narrative as a sequence of questions and answers. Make each slide answer one question and create the need for the next slide.
8. Give every slide one narrative job, one primary claim, and one layout ID from `layout-catalog.md`. When N01 applies, also record its navigator ID and phase ID in planning metadata.
   Before authoring, choose how the slide supports that claim: concise text, an editable diagram, a chart, or a real artifact. Record the visual's role, source or capture conditions, and asset status in the outline or deck README. Use `design-system.md`'s Visual evidence selection guidance; do not default every slide to text or impose an image quota.
9. Write takeaway-style titles in natural audience-facing language. Use a deliberate line break when a two-line title is necessary; never allow accidental wrapping.
10. Apply `design-system.md` and `reference-derived-patterns.md`. Prefer one composition over card grids, reuse a stable anchor diagram across sections when it reduces reorientation, and keep diagrams simple. In the Standard profile, reserve orange for tension, change, exception, or action.
11. If the user requests an outline, precede it with the 自己紹介 decision line, then provide a compact slide table with number, title, narrative job, evidence, and layout ID. Add `Navigator` and `Phase ID` only when a navigation component applies.
12. If the user requests slides or a deck, author a Marp deck and export it to PDF as `references/marp-output.md` defines: one layout class per slide, speaker notes with sources, and `scripts/build.sh` for the render check, the PDF, and the notes file. Fix every render error and inspect every slide image. Keep simple diagrams editable as theme components or inline SVG in the Markdown. Generate or source imagery only when it materially improves understanding. In the handoff, give the PDF path, state the 自己紹介 decision, and list any remaining presenter placeholders.

## Fast path

When the user provides sufficient source material, do not ask open-ended questions about visual style. Infer the audience and purpose when they are clear, select the mode, and produce the first useful draft. Ask one question only when the answer would materially change the deck's conclusion, audience, requested decision, or governing brand.

If the audience cannot be inferred as the presenter's own team, other internal teams, or external, and the material contains internal system names, colleague names, internal metrics, or other internal identifiers, ask exactly one question before drafting a new deck: `発表相手はどなたですか？（自チーム／社内の他部署／社外）`. Apply the answer through the familiarity defaults in the presenter introduction gate; 社外 also sets the external confidentiality scope. When the material contains only public information, proceed without asking and evaluate the presenter introduction gate as usual. Do not ask this question for page additions, edits, compression, or re-renders of an existing deck.

## Guardrails

- Keep one message per slide.
- Prefer 8-12 slides for an ordinary internal proposal.
- Do not make an agenda substitute for a narrative.
- Do not expose planning notes, layout IDs, or production instructions in audience-facing slide copy.
- Do not shrink body copy below the type floors in `design-system.md` and `marp-output.md`; shorten copy or change the layout.
- Keep citations and source notes traceable when research or supplied evidence informs a claim.
- Treat supplied reference decks as confidential by default. Do not copy their raw slides, screenshots, company names, people, metrics, or internal claims into a new deck; transfer only the structural pattern unless the user explicitly authorizes reuse.
- Take presenter facts only from the sources that `presenter-introduction.md` allows, and never write real profile values into this skill or any repository.
- Keep the excluded-by-default items listed in `presenter-introduction.md`, such as grade, evaluation, compensation, employee ID, and private contact details, out of presenter elements unless the user explicitly asks for that item in the current request. This does not restrict deck content that the user supplies as the subject.
- Do not turn a source deck's project-management or technical claim into a universal rule merely because the slide presents it confidently. Separate communication technique from domain validity.
- If `marp` or a Chrome-based browser is unavailable, complete the outline and the Marp source, state the PDF blocker plainly, and do not silently switch to another renderer. Produce PowerPoint only on explicit request, and say that Marp exports image-only slides that cannot be edited.

## Completion check

Confirm that diagrams explain relationships without implying unmeasured results, real artifacts show the decisive region at readable size, and every used asset has traceable provenance. List any missing evidence assets in the handoff and keep capture instructions out of audience-facing slides.

Before handing off an outline or deck, confirm that the opening establishes why the topic matters, the middle supports the central takeaway without repeated beats, and the closing resolves the opening with a decision, action, synthesis, or implication. For a presented deck, also confirm that one L18 end slide follows L12 so that the end of the talk is unmistakable. When a navigation component applies, also confirm that its phase map is stable and every eligible slide's rendered current phase matches the outline. Also confirm that the 自己紹介 decision line is recorded, any included introduction appears once at its documented position, and presenter elements show only sourced, scope-permitted facts or explicit placeholders.
