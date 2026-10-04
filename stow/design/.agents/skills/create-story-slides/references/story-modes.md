# Story modes

## Contents

- Select two dimensions
- Short proposal mode
- Planning and alignment mode
- Review and learning mode
- Case-study and explanation mode
- Long-talk expansion
- Lightning compression
- Compression, expansion, and outline tests

## Select two dimensions

Choose the communication job first and the length second. Do not infer the job from source length.

| Job | Audience outcome | Default sequence |
|---|---|---|
| Proposal | Approve, choose, or commit to one near-term action | Stakes -> problem -> principle -> recommendation -> execution -> decision |
| Planning and alignment | Share priorities, tradeoffs, roles, ways of working, and commitments | Look back -> current state -> theme -> priorities -> operating model -> commitments |
| Review and learning | Understand what happened, what changed, and what should be repeated or corrected | Target -> actual -> mechanism -> evidence -> learning -> next move |
| Case study and explanation | Learn how a mechanism works and when it transfers | Common model -> local constraint -> adaptation -> problem/solution -> evidence -> boundary |

If a deck mixes jobs, choose the job that governs the final audience action. Use the other material as evidence or appendix content.

Choose a length with the first rule that applies:

1. **Stated count:** use the slide count the user states.
2. **Known time:** size the main story by the time the presenter speaks; exclude Q&A and hands-on time.

   | Format and time | Length | Main-story slides |
   |---|---|---|
   | A talk of 10 minutes or less, such as an LT | Lightning | 5-10 |
   | A talk of more than 10 and up to 20 minutes | Short | 8-12, up to 15 for a talk longer than 15 minutes |
   | A talk of more than 20 minutes | Long talk | About one per minute, 20-45 |
   | A meeting where discussion takes about a third of the time or more | Working session | About one per two minutes of the meeting, usually 12-20 |

   Treat a slot as a talk unless the request plans discussion for about a third of the time or more.

3. **Purpose only:** use Short for a decision, concise update, or one mechanism; Working session for team alignment, review, or a facilitated discussion; and Long talk for a complex case or multiple evidence threads.

The length decides the slide count; the job decides the sequence and which beats to keep. Each mode's target below is its default only when rule 1 or 2 has not set the length. When the length and a mode's target disagree, follow the length and apply the compression or expansion rules.

Keep the main story under 45 slides. Treat detailed tables, organization charts, source screenshots, and alternate plans as appendix material. A long source does not justify a long main deck.

## Short proposal mode

Target 8-12 slides. The communication job is usually to align, recommend, or obtain a decision.

| Beat | Narrative question | Typical layout |
|---|---|---|
| 1. Cover | What are we here to decide or understand? | L01 |
| 2. Stakes | Why does this matter now? | L02 or L04 |
| 3. Current state | What is happening today? | L05 or L10 |
| 4. Problem | Where is the bottleneck or risk? | L06 or L07 |
| 5. Principle | What must remain true while we change? | L04 |
| 6. Recommendation | What should we do? | L08 or L11 |
| 7. Execution | How will we implement it? | L05 or L08 |
| 8. Boundaries and risks | What will we not do, and what could fail? | L06 or L07 |
| 9. Close | What decision or action follows? | L12 |

Add a case or evidence slide only when it materially increases confidence. Remove repeated explanations before adding pages.

## Planning and alignment mode

Target 12-18 core slides plus an appendix. The communication job is to make the next operating period legible and actionable.

1. State the period, team, and communication contract.
2. Acknowledge the previous period before introducing new demands.
3. Show expected versus actual outcomes and name the interpretation.
4. Establish the current business, product, or technical stakes.
5. State one governing theme that resolves the current tension.
6. Make simultaneous priorities or tradeoffs explicit.
7. Translate the theme into a small set of missions or outcomes.
8. Show the operating model, process lanes, or decision boundaries.
9. Define roles only to the depth needed for action.
10. State the few ways of working or cultural norms that enable the plan.
11. Close with commitments, owners, and the next checkpoint.

Do not repeat a full agenda at every section. Use a section turn or N01 from `navigation-components.md` when the audience needs persistent orientation across three or more stable phases. Put detailed staffing tables, project lists, and asset inventories in the appendix.

## Review and learning mode

Target 10-16 slides. The communication job is to connect observed outcomes to reusable learning without overstating causality.

1. Define the target, timebox, and constraints.
2. Show the actual outcome against the target.
3. Introduce one stable process or system view.
4. Explain the critical decisions in sequence.
5. Use two to four concrete examples, each with claim, evidence, and implication.
6. Name surprises, failures, or unresolved conditions.
7. Separate source facts from the presenter's interpretation.
8. Close with what to repeat, what to stop, and the next experiment.

Use screenshots as evidence only after cropping and annotating the decisive region. Do not make the audience read a schedule, spreadsheet, chat log, or architecture canvas at full-page scale.

## Case-study and explanation mode

Target 15-30 slides. The communication job is to teach a mechanism and its transfer boundary.

1. Establish the premise, stakes, and central question.
2. Explain the common model or audience expectation.
3. Introduce the local constraint that makes the common model insufficient.
4. Show the chosen adaptation and the reasoning behind it.
5. Reuse one process or operating-model diagram as an anchor.
6. Present one to three `PROBLEM -> RESPONSE -> EFFECT` sequences.
7. Add evidence after the mechanism is understandable.
8. State where the method does not apply or what it costs.
9. Generalize the transferable lesson.
10. Close with the next experiment, decision, or open question.

Use a sparse tension beat only at a genuine turn: an impossible constraint, a contradiction, a result, or a change of lens. In a short case, compress each problem and response into one contrast slide. In a long talk, a problem and response may occupy separate slides, but do not repeat the same beat more than three times without synthesis.

## Long-talk expansion

Expand the selected job to the Long talk range when rule 2 selects it for a talk longer than 20 minutes, or, without a stated count or time, only when the audience must learn a complex argument, compare several cases, or follow multiple evidence threads.

1. Open with the topic, stakes, and central question in two or three slides.
2. Establish the historical, technical, or operating context. Use only the context needed for the later conclusion.
3. Introduce the structural change or tension that makes the old model insufficient.
4. Present cases and evidence. Give each case a mechanism and a transferable lesson, not just a result.
5. Generalize the recurring pattern into a model, framework, or set of conditions.
6. Translate the model into implications for people, organization, architecture, or operations.
7. Close by answering the opening question and naming the next decision, action, or productive uncertainty.
8. Put detailed sources, organization charts, raw tables, alternative cases, and dense reference material in an appendix.

Use L03 for section turns, L09 for case mechanisms, L10 for evidence, L13 for a stable process visual, L14 for a sparse turn, L15 for `WHY/WHAT/HOW`, and L16 for problem/response sequences. Add N01 as a cross-slide component, not a layout ID, when the whole phase path and current position must stay visible across different layouts. Vary silhouettes so consecutive slides do not feel like a report exported page by page.

## Lightning compression

For a Lightning deck, keep three to five beats from the job's sequence: the opening stakes or question, the single most important mechanism or claim, one piece of evidence, and the close. Merge or drop the other beats instead of shrinking text. Use no L03 section turn, and plan about 30-60 seconds per slide. When the presenter introduction gate adds L17, count it toward the 5-10 slides, and count the closing L18 as well. In a farewell or thank-you LT, the L18 sentence carries the thanks.

## Compression rules

When the deck is too long:

1. Remove repeated evidence that supports the same claim.
2. Merge context that the audience already knows.
3. Move detailed methods and source lists to the appendix.
4. Preserve the causal chain and the final decision; do not compress by shrinking text.

## Expansion rules

When the deck needs more depth:

1. Add a concrete case before adding abstract explanation.
2. Separate mechanism from evidence when one slide cannot carry both clearly.
3. Add a section turn only when the lens truly changes.
4. Add appendix material instead of interrupting the main throughline.

## Outline test

Read only the slide titles in order. They should form a coherent argument without the body copy. If the title sequence reads like a list of topics, rewrite it as claims and consequences before authoring slides.
