---
name: otake-visual
description: Turn articles, technical explanations, comparisons, retrospectives, project plans, and data into consistent Otake Visual System diagrams, Gantt charts, slide assets, OGP images, and social cards. Use when Codex needs to propose visual parts from Markdown, create or edit an OVS JSON brief, render SVG/PNG/alt artifacts, validate diagrams, or export one visual to multiple media sizes.
---

# Otake Visual

Use the OVS CLI as the only rendering path. Edit JSON briefs; never hand-edit generated SVG.

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
