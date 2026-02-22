---
name: ui-ux-pro-max
description: Use when the user provides a reference URL or screenshot and wants to extract design tokens, replicate a visual design, or generate a design system with Tailwind CSS
---

# UI/UX Pro Max

Extract design systems from reference sites and generate production-ready Tailwind CSS.

## When to Use

- User shares a URL or screenshot saying "make it look like this"
- User wants to extract colors, typography, spacing from a live site
- User needs a Tailwind-based design system from visual references
- User asks to replicate or be inspired by a specific design

## Core Pattern: Extract → Define → Generate

### Step 1: Capture Reference
Use Playwright MCP to snapshot the reference:
```
browser_navigate → URL
browser_snapshot → Get accessibility tree
browser_take_screenshot → Visual reference
```

### Step 2: Extract Design Tokens
Analyze the snapshot for these dimensions:

| Token | What to Extract |
|-------|----------------|
| Colors | Primary, secondary, accent, neutral palette (hex values) |
| Typography | Font families, sizes, weights, line heights |
| Spacing | Padding/margin patterns, gap values |
| Layout | Grid columns, max-widths, breakpoints |
| Borders | Radius values, border widths, styles |
| Shadows | Box-shadow values, elevation levels |

Use `browser_evaluate` to extract computed styles:
```javascript
getComputedStyle(element).getPropertyValue('color')
```

### Step 3: Generate Tailwind Config
Map extracted tokens to `tailwind.config.ts`:
- `colors.primary` → extracted primary palette
- `fontFamily` → detected font stack
- `spacing` → observed spacing scale
- `borderRadius` → extracted radius values

### Step 4: Build Components
Create components using the generated design tokens:
1. Start with layout structure (header, hero, grid)
2. Apply typography scale
3. Add color scheme
4. Refine spacing and borders
5. Add responsive breakpoints

## Implementation Notes

- Always take both a screenshot (visual) AND snapshot (accessibility tree)
- Extract from multiple page sections for a complete palette
- Prefer CSS custom properties when the site uses them
- Round extracted values to the nearest Tailwind default scale when close

## Common Mistakes

- **Copying exact hex values blindly**: Normalize to a consistent palette with proper contrast ratios
- **Ignoring responsive behavior**: Capture at multiple viewport widths
- **Missing dark mode**: Check for `prefers-color-scheme` or class-based dark mode
- **Font licensing**: Note font names but warn about license requirements
