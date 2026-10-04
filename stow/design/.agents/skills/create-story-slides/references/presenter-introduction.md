# Presenter introduction

A presenter introduction tells the audience who is speaking and why this person is worth hearing on this topic or for this team. It is not a résumé. SKILL.md owns the decision gate that selects full, compact, or none; this reference defines what each outcome looks like, where presenter facts come from, and what each audience may see.

## Contents

- Outcomes and placement
- L17 presenter introduction
- Compact lines
- Content selection
- Presenter data sources
- Local presenter profile
- Confidentiality scopes
- Outline contract
- Exceptions
- QA

## Outcomes and placement

| Outcome | Placement | Adds |
|---|---|---|
| full | Slide 2, immediately after L01 and before the stakes or any agenda. Use slide 3 only after a single intentional opening hook such as L14 or L02. The cover also carries the compact line, or the presenter block on the Event cover. | One L17 slide |
| compact | One line on L01, placed by the cover template in `cover-templates.md` | No new slide |
| none | — | Nothing |

- Use L17 at most once per deck. Never place it after the first L03, in L12, or in the appendix.
- Count L17 toward the length range. When an explicit request pushes a short deck past its range, compress other slides with the compression rules in `story-modes.md`; do not drop narrative beats.
- For two or three presenters, use one L17 with columns. On the first slide of each presenter's part, usually L03 or the first content slide, add a small `担当: 氏名` next to the section label.

## L17 presenter introduction

Choose one variant, then apply the profile adjustments. Coordinates assume the 1280 x 720 canvas as x, y, w, h in px, and fonts follow the typography roles in `design-system.md`.

| Variant | Use when |
|---|---|
| LT | One presenter has a slot of about 10 minutes or less, such as an LT |
| Relationship | The audience will work with the presenter from now on, such as the first meeting with a team the presenter joins or takes over, or a meeting that welcomes new members to the presenter's team |
| Several presenters | Two or three people present |
| Relevance | Otherwise; use the photo layout when a usable photo exists |

### Shared header

| Element | Position | Type and color |
|---|---|---|
| Section label | 72, 48, 400, 20 | Section-label role, 12 pt, Muted Ink: `自己紹介`, or `登壇者紹介` for several presenters |
| Page number | 1128, 48, 80, 20, right-aligned | Figure-number role, 11 pt, Muted Ink |
| Title | 72, 84, 1136, 120 | Title role, 36 pt, line spacing 1.2, Ink, at most two intentional lines; the LT variant has no title |

Title rules:

- Write one claim that links the presenter to the topic or to the team, about 20-42 Japanese characters. Never use a bare `自己紹介` title.
- Build it from the strongest supported fact about this presenter: personal involvement stated in the request or material, then the role, then team membership. Do not upgrade participation into leadership or ownership.
- Relevance example: `決済基盤の移行を3年担当した立場から話します`. Relationship example: `〇〇チームのEMとして、まず大事にしたいこと`.
- When none of these facts is known, use `［要入力：この話をする立場を1文で］`, or `［要入力：チームとしてこの話をする理由］` for several presenters.

### Relevance variant

| Element | Without a photo | With a photo |
|---|---|---|
| Photo | — | 72, 268, 184 x 184, square crop |
| Accent bar | 72, 324, 4 x 112, Primary Blue | — |
| Name | 96, 320, 400, 44 | 72, 472, 424, 44 |
| Affiliation and role | 96, 372, 400, 64 | 72, 520, 424, 64 |
| Vertical divider | 528, 312, 1 x 250, Mist Gray | 528, 276, 1 x 300, Mist Gray |
| First point row | 560, 320 | 560, 292 |

- Name: title role, 28 pt, Ink. In an English deck, use the profile's `name.en`.
- Affiliation and role: body role, 18 pt, Muted Ink, line spacing 1.3, with the team and the role on separate lines.
- Points: two or three rows with a 76 px pitch. Each row has a 10 x 10 Primary Blue marker at (x, y + 12) and one sentence at (x + 26, y, 620, 40) in body role, 20 pt, Ink, on one line: about 23 full-width characters or fewer, counting half-width letters and digits as about half.
- Photo: use only a photo the user supplies for this deck or the profile's `photo` within its `photo_scope`. Crop it to a square; do not otherwise alter it. Never use a silhouette, an initials avatar, a generated portrait, or an empty frame.

### LT variant

| Element | Position | Type and color |
|---|---|---|
| Accent line | 72, 196, 64 x 4 | Primary Blue |
| Name | 72, 220, 900, 96 | Title role, 64 pt, Ink |
| Affiliation and role | 72, 328, 900, 36 | Body role, 22 pt, Muted Ink, one line separated by a full-width space |
| Handle | 72, 372, 600, 28 | Section-label role, 18 pt, Primary Blue; external scope only |
| Claim band | 72, 472, 1136 x 120 | Pale Blue |
| Claim | 112, 512, 1060, 44 | Title role, 26 pt, Ink, one line of about 30 full-width characters or fewer |

The claim replaces the title: one sentence that links the presenter to this talk, such as `今日は、〇〇の話をします`. Shorten it rather than wrapping it. The LT variant has no photo and no points.

### Relationship variant

Use the relevance variant's layout without a photo, and replace the points with three labeled rows at y = 312 + 96n:

- Label at (560, y, 640, 24): title role, 16 pt, Primary Blue: `役割と範囲`, `大事にしていること`, and `相談・連絡の取り方`.
- Text at (560, y + 30, 648, 34): body role, 20 pt, Ink, one line of about 24 full-width characters or fewer.
- A Mist Gray hairline at (560, y - 12, 648 x 1) between rows, and the vertical divider at 528, 308, 1 x 280.

### Several presenters

For two or three presenters, use columns at x = 72 + 392n, each 352 px wide, with a Mist Gray hairline at x - 20 from y = 284 to 544 between columns:

- Accent at (x, 288, 40 x 4), Primary Blue.
- Name at (x, 308, 352, 40): title role, 26 pt, Ink.
- Role at (x, 352, 352, 26): body role, 16 pt, Muted Ink.
- Part at (x, 392, 352, 26): section-label role, 16 pt, Primary Blue: `担当: <パート名>（n番目）`.
- Relevance at (x, 432, 352, 60): body role, 18 pt, Ink, line spacing 1.35, at most two lines of about 14 full-width characters each, broken at a phrase boundary.

Make the title one sentence on why this team is presenting this topic. For four or more presenters, L17 appears only through an explicit R1 request; then list names, roles, and parts without relevance lines.

### Profile adjustments

- **Standard:** Warm Canvas background. Do not use Accent Orange or a full Deep Navy page on L17.

### Other rules

- **Copy budget:** keep body copy within about 160 Japanese characters. Remove a point before reducing type size.
- **Nickname or reading:** when a name 24 pt or larger ends with a parenthesized nickname or reading, such as `山田 花子（はなこ）`, set the parenthesized part as `<small class="reading">`, which the theme renders at about 56% of the name size (58%, to stay at 20 px or more) with the same typeface and color. Keep the whole name on one line; never shorten the name itself.
- **Missing facts:** write each missing field as `［要入力：<項目>］`, for example `［要入力：氏名］`, `［要入力：所属・役割］`, `［要入力：この話題との関わり］`, `［要入力：大事にしていること］`, or `［要入力：チームとしてこの話をする理由］`.
- **English deck:** use `About me` or `Speakers` as the section label, translate the placeholders, keep the title within about 12 words, and keep each point to one line of about 8 words.
- **Optional footer:** a one-line disclaimer at 10-13 pt in Muted Ink, only when the user or the profile supplies one, typically for an external talk given in a personal capacity.
- **Speaker notes:** write a 15-30 second self-introduction script per presenter that uses only facts shown on the slide. Cite the source as `依頼内容`, `提供資料`, or `登壇者プロフィール`; never write file paths or rule numbers.

## Compact lines

Compact is a variation of L01 and does not receive a layout ID. Use exactly one of these lines.

| Line | Use | Format and rules |
|---|---|---|
| Presenter line | A presented deck, unless the presenter and author line applies | `氏名｜所属・役割` on one line at 16-20 pt: about 28 full-width characters or fewer, counting half-width letters and digits as about half. For several presenters, write `氏名A・氏名B・氏名C｜所属`, using at most two lines for four or more. |
| Presenter and author line | Someone other than the requesting user presents to an internal audience | `説明: 氏名｜作成: 氏名（所属チーム）` at 16-20 pt. When the user says questions go to the author, append `｜問い合わせ:` with the published contact the material gives, or `［要入力：公開済みの窓口］` when it gives none. In the external scope, use the presenter line instead. |
| Author line | A deck that nobody presents | `作成: 氏名（所属チーム）｜問い合わせ: <公開済みの窓口>｜YYYY-MM-DD` on one line at 12-13 pt. Use `作成: <チーム名>` for a team-authored notice. The date is the planned distribution date when known, otherwise the creation date. Include a contact only when the supplied material names one as the inquiry point and it fits the confidentiality scope: an internal team channel or queue only in the internal scope, and a public address or form in the external scope. Never include a private email address or a personal DM handle. |
| Placeholder line | A reusable template or a deck whose presenter is undecided | The line type stays placeholder line. Use the author-line fields with every value, including the contact and date, as `［要入力：…］`; use the presenter-line fields instead for a template of decks that someone presents live, such as a talk or LT template. |

Give every compact line the cover's supporting-copy treatment: Primary Soft on a Primary Blue cover. Keep the line away from the illustration.

## Content selection

- **Relevance variant (default):** select points in this order: the presenter's first-hand involvement in this topic; the responsibility or role that matters for the audience's decision or learning; adjacent expertise. Prefer profile experiences whose tags match the deck topic.
- **Relationship variant:** show the role and its scope, what the presenter values, and how to work and communicate with the presenter. Keep detailed team norms on the deck's ways-of-working slide instead of repeating them on L17.
- **LT variant:** show only the name, affiliation and role, the handle in the external scope, and the claim sentence. Choose the claim from the talk's central takeaway, not from the presenter's career.

Rules:

- Tie every point to the central takeaway or to the audience relationship. Drop facts that do neither.
- Do not list career timelines, past employers, hobbies, or certifications unless one directly supports the title's claim or the LT claim.
- Never invent years, counts, titles, or achievements.

## Presenter data sources

Resolve each presenter or author field from the first source that supplies it:

1. The current conversation and supplied material.
2. The local presenter profile, only for fields about the profile owner, who is the requesting user by default. Never read it for another presenter, a co-presenter, or an R3 template. The profile's `photo` counts as a photo the user supplies; use it only within its `photo_scope`, and never download, generate, or retouch a photo.
3. Placeholders in the `［要入力：<項目>］` form.

Use the names of presenters other than the requesting user exactly as the user gives them, such as surnames only; do not complete them from other sources.

Never look up presenter facts in git config, account or environment emails, agent memory, earlier sessions, Slack/Atlassian/GitHub profiles, SSO avatars, HR systems, LinkedIn, or the web.

Handle profile states explicitly:

- **Missing:** use placeholders; when the profile would have supplied the owner's fields, say once in the handoff that creating `~/.config/create-story-slides/presenter-profile.yaml` fills them automatically next time. Do not create the file unless the user asks. When asked, resolve `~` to the home directory first, create the directory with mode 700 and the file with mode 600, and write placeholder values only.
- **Unreadable:** use placeholders and report the cause, such as permissions, sandbox restrictions, or invalid YAML. Do not describe an unreadable profile as missing.
- **Stale:** when `updated` is more than 180 days old, still use the profile and state its update date in the handoff.
- **Conflicting:** when the conversation or supplied material contradicts the profile, use the conversation or material and mention the difference in the handoff.

## Local presenter profile

Keep the profile outside every repository. This skill directory is synchronized into Git-managed copies, so a profile stored inside it would be committed and pushed.

- Path: `~/.config/create-story-slides/presenter-profile.yaml`.
- Permissions: directory 700, file 600.
- The profile is optional. Without it, the skill uses placeholders.

Schema with placeholder values only. Never put real values in this reference or anywhere in a repository:

```yaml
# Local only. Never commit. chmod 600.
# Do not store: grade, evaluation, compensation, employee ID, career-aspiration notes,
# manager or report names, private contact details, birth date, family, or health.
version: 1
updated: YYYY-MM-DD
name:
  ja: "<氏名>"
  en: "<Name>"
photo: "<optional: path to a local photo file>"   # Cropped to a square on L17.
photo_scope: internal   # internal: internal audiences only. external: external audiences too.
external:        # Used alone for external audiences: outside the company, published where outsiders can access it, or unknown.
  affiliation: "<公開してよい所属表記>"
  role: "<公開してよい役割>"
  experience:
    - text: "<公開してよい経験（1行: 全角23字以内）>"
      tags: ["<タグ>"]
  disclaimer: "<任意: 個人の見解である旨>"
  handle: "<optional: public social handle, such as @name>"
internal:        # Use only when every audience member and recipient is internal.
  affiliation: "<部署・チーム>"
  role: "<社内での役割>"
  experience:
    - text: "<社内向けの経験（1行: 全角23字以内）>"
      tags: ["<タグ>"]
  values:        # Relationship variant only.
    - "<大事にしていること／進め方／連絡の取り方>"
```

In the internal scope, fill a field that `internal` omits from `external`. Never fill an external field from `internal`.

## Confidentiality scopes

Apply these scopes to presenter elements: L17, every compact line, and their speaker notes.

| Scope | When | Allowed | Not allowed |
|---|---|---|---|
| External | Anyone outside the company attends or receives the deck; the talk or deck will be published, archived, or uploaded where people outside the company can access it; or the audience is unknown | The name, the `external` block including `handle`, the profile photo only when `photo_scope` is `external`, and facts approved for public use | The `internal` block, internal team names, code names, internal system names, internal metrics or headcounts, Slack or Jira references, internal URLs, employee IDs |
| Internal | Every audience member and recipient is internal | The `internal` block, completed from `external` where needed, and the profile photo | Excluded-by-default items and the handle |
| Excluded by default | Every presenter element, unless the user explicitly asks for the item in the current request | — | Grade, evaluation, compensation, employee ID, career-aspiration notes, names of the presenter's managers or reports unless they are presenters or authors named in the request, private contact details, birth date, family, health |

- The SKILL.md guardrail refers to the excluded-by-default row. The row applies whatever the source of the fact, and it does not restrict deck content that the user supplies as the subject, such as a self-review deck for an evaluation meeting.
- In the external scope, a fact from the request or supplied material counts as approved for public use only when the user says so or the fact is already public, such as the published abstract of the talk. The talk's title or theme, and the presenter's stated role in it, count as public for that talk; internal details from the material, such as system names or metrics, do not.
- The presenter's own name and role from the current conversation or the local profile count as explicitly authorized under the redaction rule in `design-system.md`; the scope rows still decide which other facts may appear. Names of presenters, co-presenters, and authors that the user gives also count as authorized. Other people's names still follow the redaction rule.
- Speaker notes follow the same scope as slide copy.

## Outline contract

SKILL.md defines the 自己紹介 decision line, its source labels, and the override hint. In addition:

- For full, give L17 its own row, for example `| 2 | 決済基盤の移行を3年担当した立場から話します | Establish presenter relevance | 登壇者プロフィール: 経験2件／残りのプレースホルダ: なし | L17 |`.
- For compact, do not add a row. Append `presenter line`, `presenter and author line`, `author line`, or `placeholder line` to the Evidence cell of the L01 row.
- When N01 applies, set the L17 row's Navigator to `—` with the omission reason `L17 exception`.
- List every remaining presenter placeholder in the handoff.
- Keep the decision line, rule numbers, and file paths out of slide copy and speaker notes.

## Exceptions

- **Standalone request:** when the user asks only for a presenter introduction slide, for example for an event organizer or onboarding, skip the deck workflow and the gate and produce one L17 under the same content, data-source, and confidentiality rules. Use the external scope unless the user states that every recipient is internal.
- **Someone else presents:** keep the gate outcome and never read the local profile for the presenter; the profile may still supply the requesting user's author fields.
- **Traditional title requested:** when the user explicitly asks for `自己紹介` as the title, use it and keep the other L17 rules.
- **N01:** follow the L17 exception in `navigation-components.md`.

## QA

Apply these checks to presenter elements written in the current task. Keep a supplied deck's existing presenter elements unless the user asks for a change.

- Confirm that the 自己紹介 decision line records the outcome, matched rule, and reason, plus the source when presenter facts are used.
- For full, confirm exactly one L17 at slide 2, or at slide 3 after a single opening hook, and none after the first L03, in L12, or in the appendix.
- For compact, confirm that there is no L17 and exactly one compact line of the right type: a presenter line of about 28 full-width characters or fewer on one line (two lines only for four or more presenters), a presenter and author line, an author line without personal contacts, or a placeholder line. Confirm that it avoids the illustration.
- For none, confirm that no presenter information appears beyond what the user requested.
- Confirm that the L17 title is a claim, that `自己紹介` appears only as the section label unless the user asked for a traditional title, and that each point ties to the central takeaway or the audience relationship.
- Confirm that every presenter fact traces to the conversation, supplied material, or local profile, and that missing facts are `［要入力：…］` placeholders rather than guessed years or numbers.
- In the external scope, including an unknown audience, confirm that only the name, `external` facts, and facts approved for public use appear, and that neither slides nor notes contain internal names or file paths.
- Confirm that L17 uses the variant the selection table requires and matches its coordinates, type sizes, and colors.
- In the LT variant, confirm that the claim band carries one sentence on one line and that the slide has no title, photo, or points.
- Confirm that any photo comes from a user-supplied file or the profile's `photo` within its `photo_scope`, with no generated portrait, silhouette, or empty frame, and that a handle appears only in the external scope.
- Confirm that the local profile was read only for the profile owner's fields.
- Confirm that L17 has no N01 and that Standard uses no orange on L17.
- Confirm that L17 has no overflow or overlap at 1280 x 720 and that the title and names remain legible at 25% thumbnail size.
- When the Fast path audience condition applies, confirm that the turn asked exactly one question, about the audience rather than about whether to include an introduction.
