---
name: template-sync
description: Use when creating a new client site from a template, syncing shared components across template variants, auditing template drift, or managing the corporate/local/LP/minimal/portfolio template family
---

# Template Sync

Multi-template management for the client site family (corporate, local, LP, minimal, portfolio).

## When to Use

- User creates a new client site from a template
- User updates a shared component and needs to propagate changes
- User asks about differences between template variants
- User wants to audit templates for consistency

## Quick Reference: Template Family

### Template Selection Guide
| Template | Use Case | Key Features |
|----------|----------|-------------|
| `corporate` | Company/organization sites | Multi-page, about/services/contact, formal tone |
| `local` | Local businesses, clinics | Google Maps, hours, phone CTA, local SEO |
| `LP` | Landing pages, campaigns | Single-page, CTA-focused, conversion-optimized |
| `minimal` | Simple presence sites | Few pages, fast load, low maintenance |
| `portfolio` | Creative/professional showcase | Gallery, project grid, visual-heavy |

### New Site Creation Checklist
- [ ] Choose template based on client requirements
- [ ] Clone from template (not from another client site)
- [ ] Update `package.json` name and description
- [ ] Replace all placeholder content (company name, logo, colors)
- [ ] Configure domain and deployment (Vercel project)
- [ ] Verify baseline quality (below)

### Baseline Quality Requirements
All templates must meet:
- [ ] **SEO**: Unique title/description per page, OG tags, sitemap
- [ ] **a11y**: WCAG 2.2 Level AA, keyboard navigable, contrast 4.5:1
- [ ] **Responsive**: Mobile-first, tested at 320px/768px/1024px/1440px
- [ ] **Performance**: LCP < 2.5s, total JS < 200KB, images optimized
- [ ] **Core files**: robots.txt, sitemap.xml, favicon, manifest.json

### Shared Component Sync
```
Shared across all templates:
├── Header/Navigation patterns
├── Footer (copyright, links)
├── Contact form component
├── SEO metadata utilities
├── Analytics integration
└── Cookie consent banner
```

### Drift Detection
When auditing, check for divergence in:
- [ ] Tailwind config (theme colors, fonts, spacing)
- [ ] Component API signatures (props interface)
- [ ] Dependency versions (Next.js, React, Tailwind)
- [ ] Build configuration (next.config.ts settings)
- [ ] Deployment settings (Vercel configuration)

## Implementation

1. List all templates: `ls client-sites/`
2. Compare package versions: check `package.json` across templates
3. Diff shared components: identify diverged implementations
4. Create update PR per template when syncing changes
5. Run baseline quality checks on each template

## Common Mistakes

- **Cloning from another client site**: Always start from the base template
- **Updating one template, forgetting others**: Track shared component versions
- **Over-customizing shared components per client**: Extract client-specific logic into config
- **No version tracking**: Tag template releases so client sites can reference a baseline
