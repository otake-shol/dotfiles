---
name: otake-visual
description: Turn articles, technical explanations, comparisons, retrospectives, project plans, and data into consistent Otake Visual System diagrams, Gantt charts, slide assets, OGP images, and social cards. Use when Codex needs to propose visual parts from Markdown, create or edit an OVS JSON brief, render SVG/PNG/alt artifacts, validate diagrams, or export one visual to multiple media sizes.
---

# Otake Visual

Use the Standard profile in [create-story-slides](../create-story-slides/references/design-system.md) as the visual authority for all OVS media. The OVS Marp build reuses that skill’s CSS; tokens.json adapts its colors and fonts for diagrams and HTML.

Use the OVS CLI as the only rendering path. Edit JSON briefs; never hand-edit generated SVG.

Before selecting a composition, read [design intent and user burden](references/design-intent.md).
Record the audience's task, information priority, and the reason for the chosen form in the
existing planning notes; do not add unsupported fields to the JSON brief. Apply its final
review to the rendered output alongside the checks below.

For Markdown/Marp deck creation or slide layout work, first read
[the shared slide guide](references/slides.md). It owns deck structure, theme
resolution, export selection, and visual review for both Claude `/slides` and
Codex `source-command-slides`. Use the workflow below for diagram assets within
the deck; it does not replace Marp for rendering the deck itself. Preserve any
user-supplied template or design direction. Verify decks with
`ovs deck verify slide.md --minutes N --shots DIR` (static lint plus headless
render measurement with annotated screenshots).

## Workflow

1. Resolve the CLI:

   ```bash
   command -v ovs || printf '%s\n' "node ${XDG_CONFIG_HOME:-$HOME/.config}/otake/visual-system/scripts/ovs.mjs"
   ```

2. For an article, get an initial proposal:

   ```bash
   ovs suggest article.md
   ovs list recipes
   ```

3. To publish one Markdown source with Mermaid to HTML and Marp, keep the diagram
   accessible and attributable, then build through OVS:

   ```bash
   ovs document article.md --target html,marp --out dist
   ```

   Each Mermaid block must include a 12–300 character `accDescr`. Use
   `%% ovs-id:` for a stable asset name and `%% ovs-source:` for a per-diagram
   source. The generated SVG is shared by HTML and Marp; do not hand-edit it.

4. Select only visuals that materially improve understanding. Keep one message per visual. Use:

   - `definition` for a term or scope.
   - `before-after` for a state change.
   - `timeline` for events or a roadmap.
   - `architecture` for boundaries and responsibilities.
   - `sequence` for ordered interactions.
   - `flow` for cause, procedure, or transformation.
   - `comparison` or `matrix` for a choice.
   - `chart` only for real data.
   - `gantt` for tasks, dates, owners, progress, and dependencies.
   - `roadmap` for Now / Next / Later outcomes.
   - `wbs` for deliverable-based work breakdown.
   - `raci` for responsibility assignment.
   - `raid` for risks, assumptions, issues, and dependencies.
   - `status-board` for weekly project reporting.
   - `takeaway` or `warning` for article emphasis.

5. Copy the brief shape from
   `${XDG_CONFIG_HOME:-$HOME/.config}/otake/visual-system/templates/brief.json`.
   Set a stable lowercase `meta.id`, the intended audience, one message, a non-empty source,
   a 12–300 character alt description, targets, and formats.

6. For charts, preserve the raw CSV/JSON input and state the unit, period, and source.
   Never invent data for decoration. Use `ovs list charts` to choose a supported chart.

7. For project management, start with `ovs list pm`. Generate a Gantt directly from
   `id,task,start,end,owner,status,progress,dependsOn,milestone` columns:

   ```bash
   ovs gantt tasks.csv --id release-plan --title "Release plan" \
     --today 2026-08-12 --target blog,slide --out assets
   ```

   Keep tasks to eight per visual. Split by phase instead of shrinking labels.
   Preserve dependencies and use milestones for zero-duration decision points.

8. Render and validate:

   ```bash
   ovs render topic.brief.json --out assets
   ovs lint assets
   ovs preview assets --out assets/gallery.html
   ```

   If owned outputs already exist, inspect the exact paths before rerunning with `--force`.
   Never force-write through a symbolic link.

9. Report the selected recipe, generated files, source status, and verification result.

## Guardrails

- Do not copy another author’s signature motif or trace third-party figures.
- Do not put secrets, personal information, or unpublished business data in a brief.
- Do not remove the source, alt text, or lower-right brand marker.
- Do not add raw colors or fonts outside `tokens.json`.
- If labels overflow, shorten the figure and move detail back to the article.
