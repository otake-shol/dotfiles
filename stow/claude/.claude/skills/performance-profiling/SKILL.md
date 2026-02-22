---
name: performance-profiling
description: Use when diagnosing page load delays, analyzing memory usage, optimizing JavaScript execution time, profiling network waterfalls, or improving Core Web Vitals beyond component-level optimization
---

# Performance Profiling

Deep performance analysis for Next.js applications beyond component-level optimization.

## When to Use

- User reports slow page loads that React optimization alone can't fix
- User needs to analyze network waterfall or resource loading
- User targets specific Core Web Vitals improvements
- User asks about image, font, or script optimization
- Site serves users on slow connections (medical sites, elderly users)

## Quick Reference: Profiling Checklist

### Network & Loading
- [ ] Critical CSS inlined (no render-blocking stylesheets)
- [ ] Resource hints configured:
  - `<link rel="preload">` for critical fonts and hero images
  - `<link rel="prefetch">` for likely next-page resources
  - `<link rel="dns-prefetch">` for third-party domains
- [ ] No unused CSS/JS in initial bundle
- [ ] HTTP/2 or HTTP/3 enabled (Vercel default)
- [ ] CDN caching headers set (`Cache-Control`, `s-maxage`)

### Image Optimization
- [ ] All images use `next/image` component
- [ ] `sizes` attribute matches layout (not default `100vw`)
- [ ] `priority` on LCP image (hero/above-the-fold)
- [ ] Appropriate format: AVIF > WebP > JPEG (Next.js auto-negotiates)
- [ ] No images larger than 2x display size
- [ ] Lazy loading for below-the-fold images (default in `next/image`)

### Font Optimization
- [ ] `next/font` with subset (e.g., `subsets: ['latin']`)
- [ ] Japanese fonts: subset with `unicode-range` or use `next/font/google`
- [ ] `display: 'swap'` to prevent FOIT
- [ ] No more than 2-3 font families loaded
- [ ] Variable fonts preferred over multiple weights

### JavaScript Budget
| Route Type | JS Budget | Approach |
|-----------|-----------|----------|
| Landing page | < 100KB | Minimal client JS, Server Components |
| Dashboard | < 250KB | Code-split per feature |
| Blog post | < 150KB | Static generation, minimal interactivity |

### Core Web Vitals Targets
| Metric | Good | Poor |
|--------|------|------|
| LCP | < 2.5s | > 4.0s |
| INP | < 200ms | > 500ms |
| CLS | < 0.1 | > 0.25 |

## Implementation

1. `npx next build` — review route sizes and static/dynamic status
2. `ANALYZE=true npx next build` — bundle analyzer for JS breakdown
3. Lighthouse in incognito (Performance score target: 90+)
4. WebPageTest for real-world waterfall analysis
5. Vercel Analytics / Speed Insights for field data

## Common Mistakes

- **Optimizing before measuring**: Always profile first, optimize second
- **Missing `sizes` on `next/image`**: Causes full-size download on mobile
- **Loading all fonts upfront**: Subset and defer non-critical weights
- **Third-party scripts blocking render**: Load analytics/chat widgets after `onload`
