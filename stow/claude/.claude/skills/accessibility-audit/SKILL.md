---
name: accessibility-audit
description: Use when checking WCAG compliance, auditing ARIA attributes, verifying keyboard navigation, testing color contrast, or ensuring JIS X 8341-3 conformance for Japanese sites
---

# Accessibility Audit

WCAG 2.2 compliance checklist for Next.js applications with Japanese regulatory considerations.

## When to Use

- User asks to check accessibility or a11y compliance
- Before launching a public-facing site (especially medical/government)
- User reports issues with screen readers, keyboard navigation, or contrast
- User mentions JIS X 8341-3, disability discrimination law, or WCAG

## Quick Reference: Audit Checklist

### Level A (Minimum)
- [ ] All images have meaningful `alt` text (or `alt=""` for decorative)
- [ ] Form inputs have associated `<label>` elements
- [ ] Color is not the only means of conveying information
- [ ] Page has proper heading hierarchy (`h1` → `h2` → `h3`, no skips)
- [ ] All interactive elements are keyboard accessible (Tab/Enter/Escape)
- [ ] Focus indicator is visible on all focusable elements
- [ ] No content flashes more than 3 times per second
- [ ] `lang` attribute set on `<html>` (e.g., `lang="ja"`)

### Level AA (Target for most sites)
- [ ] Color contrast ratio: 4.5:1 for text, 3:1 for large text
- [ ] Text resizable to 200% without loss of content
- [ ] Focus order matches visual reading order
- [ ] Error messages identify the field and suggest correction
- [ ] Consistent navigation across pages
- [ ] Link purpose clear from link text (no "click here")

### ARIA & Semantic HTML
- [ ] Use native HTML elements before ARIA (`<button>` not `<div role="button">`)
- [ ] `aria-label` or `aria-labelledby` on icon-only buttons
- [ ] `aria-live` regions for dynamic content updates
- [ ] `role="navigation"`, `role="main"`, `role="complementary"` on landmarks
- [ ] Modal dialogs trap focus and return focus on close

### Japanese-Specific (JIS X 8341-3)
- [ ] Ruby text (`<ruby>`) for difficult kanji readings
- [ ] Sufficient line-height for Japanese text (≥ 1.5)
- [ ] Vertical writing mode tested if used (`writing-mode: vertical-rl`)
- [ ] Input fields accept full-width and half-width characters

## Implementation

1. Install axe-core: `npm install -D @axe-core/playwright`
2. Add Playwright a11y test:
   ```typescript
   import AxeBuilder from '@axe-core/playwright';
   const results = await new AxeBuilder({ page }).analyze();
   expect(results.violations).toEqual([]);
   ```
3. Run Lighthouse Accessibility audit (target: 95+)
4. Manual keyboard-only navigation test (Tab through entire page)
5. Test with screen reader (VoiceOver on macOS: Cmd+F5)

## Common Mistakes

- **ARIA overuse**: Adding `role` and `aria-*` to elements that already have native semantics
- **Hidden skip links missing**: Always include "Skip to main content" for keyboard users
- **Focus trapping in modals forgotten**: Users get stuck or lose context
- **Contrast only checked on white backgrounds**: Test all background/text combinations
