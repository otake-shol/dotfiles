---
name: grilling
description: Grill the user relentlessly about a plan, decision, or idea. Use when the user wants to stress-test their thinking, or uses any 'grill' trigger phrases.
---

Interview the user relentlessly until you reach a shared understanding. Map this as a **design tree**: every decision branches into the decisions that hang off it.

Work the tree in **rounds**. The **frontier** is every decision whose prerequisites are already settled: the questions you can ask _now_ without guessing at answers you haven't heard yet. Ask the whole frontier in one round: number each question and give your recommended answer. Then wait for the user's answers before the next round.

Format a round like so:

```
❓ **Q1** - **<question title>**: <question body, might be multiple paragraphs, including multiple choices>

➡️ <your recommended answer>

---

❓ **Q2** - **<question title>**: <question body, might be multiple paragraphs, including multiple choices>

➡️ <your recommended answer>
```

Each round the user answers reshapes the tree: settled decisions push the frontier outward and unblock questions that depended on them. Recompute the frontier and ask the next round. A question whose answer depends on another question still open in this round belongs to a _later_ round, not this one.

Finding _facts_ is your job, never the user's. When a frontier question needs a fact from the environment (filesystem, tools, etc.), dispatch a sub-agent to find it; don't ask the user for anything you could look up yourself. Don't block on it: a running exploration is an unsettled prerequisite, so only the questions downstream of it wait for the sub-agent to report; ask the rest of the frontier now. The _decisions_ are the user's: put each to them and wait.

For consequential assumptions, separate established facts, hypotheses, and preferences. Ask what observable evidence would change the user's mind, and capture that condition before looking only for supporting evidence. Investigate counterevidence as well; missing evidence is not proof that an assumption is false. Do not demand empirical proof for a value preference.

Present the strongest reasonable opposing view before testing a decision. Preserve its actual premises and tradeoffs rather than replacing it with an easy-to-dismiss version. Apply this within the current frontier, without reopening settled branches unless new evidence matters. Agreement or confidence alone does not verify a factual premise.

The session is done when the frontier is empty: every branch of the design tree visited, nothing left silently assumed. Record unresolved factual uncertainty and any agreed condition for revisiting a decision; a consciously provisional decision need not trigger endless questioning. Do not act on it until the user confirms you have reached a shared understanding.
