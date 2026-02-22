---
name: find-skills
description: Use when the user asks what skills are available, wants to find a skill for a specific task, or says "find skill", "list skills", "what skills", or "recommend a skill"
---

# Find Skills

Discover and recommend the right skill for any task.

## When to Use

- User asks "what skills do I have?"
- User describes a task and wants skill recommendations
- User says "find skill" or "recommend a skill"

## Available Custom Skills

| Skill | Trigger | Category |
|-------|---------|----------|
| `find-skills` | Find or list available skills | Meta |
| `skill-creator` | Create a new custom SKILL.md | Meta |
| `ui-ux-pro-max` | Extract design from URL → Tailwind CSS | Frontend |
| `vercel-react-best-practices` | Audit React/Next.js performance | Frontend |
| `figma-to-code` | Convert Figma designs → production code | Frontend |
| `performance-profiling` | Deep performance analysis (network, images, fonts) | Frontend |
| `typescript-strict-patterns` | Enforce strict TypeScript, eliminate `any` | Frontend |
| `supabase-postgres-best-practices` | Audit Supabase/Postgres security & perf | Backend |
| `stripe-best-practices` | Implement Stripe payments correctly | Backend |
| `api-design` | REST API design, error format, OpenAPI | Backend |
| `supabase-migration` | Safe migration workflow & rollback | Backend |
| `security-audit` | OWASP Top 10 audit for Next.js + Supabase | Security |
| `accessibility-audit` | WCAG 2.2 / JIS X 8341-3 compliance | Compliance |
| `seo-technical-audit` | Metadata, structured data, crawlability | SEO |
| `template-sync` | Client site template management & sync | Operations |
| `observability-setup` | Error tracking, logging, health checks | Operations |
| `content-publishing` | MicroCMS & Zenn publishing workflow | Content |
| `browser-use` | AI browser automation via Playwright MCP | Automation |
| `funnel-analysis` | Conversion funnel audit & CRO | Marketing |

## Superpowers Plugin Skills (pre-installed)

| Skill | Trigger |
|-------|---------|
| `brainstorming` | Before any creative or feature design work |
| `test-driven-development` | Before writing implementation code |
| `systematic-debugging` | When encountering bugs or unexpected behavior |
| `writing-plans` | Multi-step task planning |
| `executing-plans` | Execute a written plan with review checkpoints |
| `requesting-code-review` | Before merging or completing features |
| `receiving-code-review` | When processing code review feedback |
| `writing-skills` | Creating or editing skills |
| `verification-before-completion` | Before claiming work is done |
| `dispatching-parallel-agents` | 2+ independent tasks to parallelize |
| `using-git-worktrees` | Feature isolation in git worktrees |
| `finishing-a-development-branch` | Merge, PR, or cleanup after implementation |
| `subagent-driven-development` | Execute plans with independent subtasks |

## Matching Logic

Match by: exact name → category → keyword → workflow.
Priority: process skills (brainstorming/TDD/debugging) → domain skills → utility skills.

## Common Mistakes

- **Skipping process skills**: Always check brainstorming/TDD/debugging before domain skills
- **Not checking superpowers**: The plugin has 13 skills; check both lists
