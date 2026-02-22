---
name: figma-to-code
description: Use when converting Figma designs to code, extracting design tokens via Figma MCP, mapping Figma components to shadcn/ui, or translating Auto Layout to CSS Flexbox/Grid
---

# Figma to Code

Workflow for converting Figma designs to production React/Tailwind code using Figma MCP.

## When to Use

- User provides a Figma file URL or mentions Figma designs
- User wants to extract design tokens (colors, spacing, typography)
- User asks to implement a design from Figma mockups
- User wants to map Figma components to shadcn/ui

## Quick Reference: Conversion Workflow

### Step 1: Extract from Figma MCP
```
1. Get file structure: list pages and frames
2. Extract design tokens: colors, typography, spacing, effects
3. Identify component hierarchy and variants
4. Note Auto Layout properties (direction, gap, padding)
```

### Step 2: Map to Tailwind Config
| Figma Property | Tailwind Mapping |
|----------------|-----------------|
| Fill colors | `colors` in `tailwind.config.ts` |
| Text styles | `fontSize` + `fontWeight` + `lineHeight` |
| Spacing (Auto Layout gap/padding) | `spacing` scale |
| Border radius | `borderRadius` |
| Shadows/effects | `boxShadow` |
| Opacity | `opacity` utilities |

### Step 3: Layout Translation
| Figma Auto Layout | CSS/Tailwind |
|-------------------|-------------|
| Horizontal, gap: 16 | `flex flex-row gap-4` |
| Vertical, gap: 8 | `flex flex-col gap-2` |
| Fill container | `flex-1` or `w-full` |
| Fixed width | `w-[value]` |
| Hug contents | `w-fit` |
| Space between | `justify-between` |
| Wrap | `flex-wrap` |
| Grid (≥2 columns, equal items) | `grid grid-cols-N gap-N` |

### Step 4: Component Mapping
| Figma Component | shadcn/ui Component |
|-----------------|-------------------|
| Button (variants) | `<Button variant="...">` |
| Input field | `<Input>` |
| Dropdown/Select | `<Select>` |
| Modal/Dialog | `<Dialog>` |
| Card | `<Card>` |
| Tabs | `<Tabs>` |
| Avatar | `<Avatar>` |
| Badge/Tag | `<Badge>` |

### Quality Checks
- [ ] Pixel-perfect at design breakpoints
- [ ] Responsive behavior matches Figma constraints
- [ ] Hover/focus/active states implemented
- [ ] Typography scale matches design system
- [ ] Colors use CSS variables (not hardcoded hex)
- [ ] Icons exported as SVG, used via component

## Implementation

1. Connect to Figma file via MCP tools
2. Extract global styles → update `tailwind.config.ts`
3. Build atomic components bottom-up (icons → buttons → cards → sections)
4. Compose page layouts from components
5. Compare side-by-side with Figma (use Playwright screenshot)

## Common Mistakes

- **Hardcoding pixel values**: Use Tailwind's spacing scale or CSS variables
- **Ignoring responsive design**: Figma shows one breakpoint; implement all
- **1:1 Figma layer → div mapping**: Simplify DOM structure; not every Figma layer needs an element
- **Skipping hover/focus states**: Designers specify these; implement all interaction states
