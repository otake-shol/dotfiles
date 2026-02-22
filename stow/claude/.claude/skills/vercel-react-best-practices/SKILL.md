---
name: vercel-react-best-practices
description: Use when auditing React or Next.js application performance, reviewing component render behavior, analyzing bundle size, or optimizing Core Web Vitals
---

# Vercel React Best Practices

Performance audit checklist for React/Next.js applications.

## When to Use

- User asks to optimize a Next.js or React app
- User reports slow page loads or poor Lighthouse scores
- Before deploying a new feature to production
- User asks about re-renders, bundle size, or Core Web Vitals

## Quick Reference: Audit Checklist

### Rendering Performance
- [ ] No unnecessary re-renders (use React DevTools Profiler)
- [ ] `React.memo()` on expensive pure components
- [ ] `useMemo`/`useCallback` for expensive computations and stable references
- [ ] No inline object/array literals in JSX props
- [ ] State colocated to the lowest necessary component

### Bundle Size
- [ ] Dynamic imports (`next/dynamic`) for heavy components
- [ ] No barrel file re-exports pulling entire modules
- [ ] Tree-shaking friendly imports (`import { x } from 'lib'` not `import lib`)
- [ ] Images use `next/image` with proper `sizes` attribute
- [ ] Fonts use `next/font` (no layout shift)

### Data Fetching (App Router)
- [ ] Server Components by default, `'use client'` only when needed
- [ ] Parallel data fetching with `Promise.all()` where possible
- [ ] Appropriate caching strategy (`force-cache`, `no-store`, `revalidate`)
- [ ] `loading.tsx` for streaming / Suspense boundaries
- [ ] `generateStaticParams` for static pages

### Core Web Vitals
| Metric | Target | Common Fix |
|--------|--------|------------|
| LCP | < 2.5s | Optimize hero image, preload critical resources |
| INP | < 200ms | Reduce JS on main thread, use `startTransition` |
| CLS | < 0.1 | Set explicit dimensions, use `next/font` |

### Next.js Specific
- [ ] Metadata API used for SEO (`generateMetadata`)
- [ ] `next.config.js` has proper `images.remotePatterns`
- [ ] Middleware is lightweight (no heavy computation)
- [ ] Route handlers use proper HTTP caching headers

## Implementation

1. Run `npx next build` and review the output for page sizes
2. Check bundle analyzer: `ANALYZE=true npx next build`
3. Run Lighthouse in incognito mode
4. Review Server vs Client component boundaries
5. Check for N+1 queries in data fetching

## Common Mistakes

- **Over-memoizing**: Don't memoize cheap operations; adds complexity without benefit
- **Client Components at layout level**: Pushes everything below to client
- **Missing Suspense boundaries**: One slow fetch blocks the entire page
- **Ignoring `sizes` on images**: Causes browser to download full-size images on mobile
