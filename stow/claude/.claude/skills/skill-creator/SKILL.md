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
---
```

## Core Principles (CSO - Claude Search Optimization)

1. **Description = Trigger Only**: The `description` field must specify WHEN to activate, never HOW the skill works. Claude uses this to decide whether to load the skill body.
2. **Verb-First Naming**: Use action verbs (e.g., `debug-api`, `audit-security`)
3. **Keyword-Rich Content**: Include terms Claude would search for when matching user intent
4. **Under 500 Words**: Minimize token cost since skills load into context on every invocation

## Creation Workflow

### Step 1: Define the Trigger
Ask: "What situation should activate this skill?"
Write a `description` starting with "Use when..."

### Step 2: Structure the Body
Follow this section order:
1. **Overview** - One sentence explaining the skill's purpose
2. **When to Use** - Bullet list of trigger scenarios
3. **Quick Reference** - Core pattern or checklist (the main value)
4. **Implementation** - Step-by-step instructions
5. **Common Mistakes** - Anti-patterns to avoid

### Step 3: Validate
- [ ] Description starts with "Use when" and contains NO workflow summary
- [ ] Body is under 500 words
- [ ] No external file dependencies (self-contained)
- [ ] Frontmatter has exactly `name` and `description` fields
- [ ] Content uses English (user's language setting handles translation)

## Common Mistakes

- **Workflow in description**: "Use when... by first doing X then Y" - Claude skips the body
- **Too generic**: "Use for coding tasks" matches everything, helps nothing
- **Too long**: Skills over 500 words waste tokens on every load
- **Missing trigger scenarios**: If "When to Use" is vague, Claude won't match it
