---
name: skill-creator
description: Use when the user wants to create a new custom Claude Code skill, write a SKILL.md file, or asks about skill authoring best practices
---

# Skill Creator

Interactive guide for creating high-quality Claude Code custom skills.

## When to Use

- User says "create a skill", "new skill", "write a skill"
- User wants to automate a recurring workflow as a skill
- User needs help structuring a SKILL.md file

## SKILL.md Template

```yaml
---
name: skill-name
description: Use when [specific trigger condition]. Never summarize the workflow here.
skill_type: rigid | flexible
---
```

## Core Principles (CSO - Claude Search Optimization)

1. **Description = Trigger Only**: The `description` field must specify WHEN to activate, never HOW the skill works.
2. **Verb-First Naming**: Use action verbs (e.g., `debug-api`, `audit-security`)
3. **Keyword-Rich Content**: Include terms Claude would search for when matching user intent
4. **Under 500 Words**: Minimize token cost since skills load into context on every invocation

## Skill Type

Every skill must declare its type:

- **Rigid** (TDD, debugging): Follow the workflow exactly. Do not adapt away discipline. Claude must not skip steps.
- **Flexible** (patterns, design guides): Adapt principles to context. Claude uses judgment.

The skill itself states which type it is. When both types could apply, prefer rigid.

## Skill Priority

Skills fall into two roles — declare which one applies:

- **Process skills** (brainstorming, debugging): Define HOW to approach. Invoke these FIRST.
- **Implementation skills** (api-design, frontend-design): Guide execution. Invoke these AFTER process skills.

Example: "Build feature X" → brainstorming first, then implementation skill.

## TodoWrite Integration

If the skill has a checklist, include this instruction in the body:

> "Register each checklist item with TodoWrite before executing. Run all independent steps in parallel."

## Creation Workflow

### Step 1: Define the Trigger
Ask: "What situation should activate this skill?"
Write a `description` starting with "Use when..."

### Step 2: Classify
- Rigid or Flexible?
- Process or Implementation?

### Step 3: Structure the Body
1. **Overview** - One sentence
2. **When to Use** - Bullet list of trigger scenarios
3. **Quick Reference** - Core pattern or checklist
4. **Implementation** - Step-by-step instructions
5. **Common Mistakes** - Anti-patterns to avoid

### Step 4: Validate
- [ ] Description starts with "Use when" and contains NO workflow summary
- [ ] `skill_type` (rigid/flexible) is declared in frontmatter
- [ ] Skill priority role (process/implementation) is stated
- [ ] If checklist exists, TodoWrite instruction is included
- [ ] Body is under 500 words
- [ ] No external file dependencies (self-contained)

## Common Mistakes

- **Workflow in description**: "Use when... by first doing X then Y" — Claude skips the body
- **Too generic**: "Use for coding tasks" matches everything, helps nothing
- **Too long**: Skills over 500 words waste tokens on every load
- **Missing skill_type**: Claude can't enforce discipline without knowing if it's rigid
