---
name: seo-technical-audit
description: Use when auditing Next.js site SEO, checking metadata and structured data, reviewing crawlability, optimizing for search rankings, or configuring MicroCMS content for SEO
---

# SEO Technical Audit

Technical SEO checklist for Next.js sites with MicroCMS integration.

## When to Use

- User asks to improve search rankings or SEO
- Before launching a content site, blog, or affiliate project
- User needs structured data (JSON-LD) implementation
- User asks about metadata, sitemap, robots.txt, or Open Graph

## Quick Reference: Audit Checklist

### Metadata (Next.js Metadata API)
- [ ] `generateMetadata` returns unique `title` and `description` per page
- [ ] Title format: `{Page Title} | {Site Name}` (under 60 chars)
- [ ] Description: 120-160 chars, includes target keyword
- [ ] `openGraph` with `title`, `description`, `images`, `type`
- [ ] `twitter` card metadata (`summary_large_image`)
- [ ] Canonical URL set (`alternates.canonical`)
- [ ] `robots` meta: `noindex` on pagination, search, and admin pages

### Structured Data (JSON-LD)
- [ ] `Article` schema on blog posts (headline, datePublished, author)
- [ ] `Organization` or `LocalBusiness` on homepage
- [ ] `BreadcrumbList` for navigation hierarchy
- [ ] `MedicalOrganization` for medical sites (with `medicalSpecialty`)
- [ ] `Product` with `offers` and `aggregateRating` for affiliate/e-commerce
- [ ] `FAQPage` for FAQ sections
- [ ] Validate at: search.google.com/test/rich-results

### Crawlability & Indexing
- [ ] `robots.txt` allows crawling of important paths
- [ ] XML sitemap at `/sitemap.xml` (use `next-sitemap` or App Router `sitemap.ts`)
- [ ] Sitemap includes `lastmod`, `changefreq`, `priority`
- [ ] No orphan pages (every page linked from at least one other page)
- [ ] Internal links use `<Link>` component (not `<a>` with full URL)
- [ ] 404 page returns proper HTTP 404 status

### Performance Signals
- [ ] Core Web Vitals pass (LCP < 2.5s, INP < 200ms, CLS < 0.1)
- [ ] Mobile-friendly (responsive design, no horizontal scroll)
- [ ] HTTPS enforced with proper redirects
- [ ] No render-blocking resources above the fold

### MicroCMS Integration
- [ ] `generateStaticParams` for all CMS content pages
- [ ] ISR `revalidate` set appropriately (e.g., 60-3600s)
- [ ] Preview mode configured for draft content
- [ ] CMS content includes alt text for images
- [ ] Slug field used for clean URLs (not content IDs)

## Implementation

1. Check metadata: inspect `<head>` on each page type
2. Validate structured data: Google Rich Results Test
3. Submit sitemap to Google Search Console
4. Run Lighthouse SEO audit (target: 100)
5. Check mobile usability in Search Console

## Common Mistakes

- **Duplicate titles across pages**: Every page needs a unique title
- **Missing canonical on paginated content**: Causes duplicate content issues
- **JSON-LD in wrong format**: Must be `<script type="application/ld+json">`
- **Blocking CSS/JS in robots.txt**: Googlebot needs these to render pages
