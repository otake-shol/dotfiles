---
name: content-publishing
description: Use when publishing content to MicroCMS, writing Zenn articles, managing blog post workflows, optimizing article SEO and readability, or generating OG images
---

# Content Publishing

Consistent workflow for MicroCMS and Zenn content publishing.

## When to Use

- User creates or updates MicroCMS content
- User writes a Zenn article or book chapter
- User asks about blog post structure or SEO optimization
- User wants to generate OG images for articles

## Quick Reference: Publishing Workflows

### MicroCMS Workflow
```
1. Schema Design → Define API schema in MicroCMS dashboard
2. Content Creation → Write in MicroCMS rich editor
3. Preview → Use Next.js draft mode (/api/preview?slug=xxx)
4. Review → Check SEO, images, links
5. Publish → Set status to "published" in MicroCMS
6. Verify → ISR revalidation triggers, check live page
```

### MicroCMS API Patterns
```typescript
// Fetching with type safety
import { client } from '@/lib/microcms';

// List endpoint
const posts = await client.getList<Blog>({
  endpoint: 'blogs',
  queries: { limit: 10, offset: 0, orders: '-publishedAt' },
});

// Detail endpoint
const post = await client.getListDetail<Blog>({
  endpoint: 'blogs',
  contentId: slug,
});
```

### Zenn Article Format
```markdown
---
title: "記事タイトル（60文字以内）"
emoji: "📝"
type: "tech"  # tech or idea
topics: ["nextjs", "typescript", "react"]
published: true
---

## 導入（WHY: なぜこの記事を書くか）
## 本題（WHAT/HOW: 具体的な内容）
## まとめ（SO WHAT: 読者が持ち帰るもの）
```

### Article Quality Checklist
- [ ] Title: 30-60 chars, includes primary keyword
- [ ] Meta description: 120-160 chars
- [ ] Heading hierarchy: h2 → h3 → h4 (no skips)
- [ ] Images: all have alt text, optimized size
- [ ] Internal links: 2-3 links to related content
- [ ] Code blocks: language specified, tested and working
- [ ] CTA: clear next action for the reader

### OG Image Generation
```typescript
// app/api/og/route.tsx (Next.js ImageResponse)
import { ImageResponse } from 'next/og';

export async function GET(request: Request) {
  const { searchParams } = new URL(request.url);
  const title = searchParams.get('title') ?? 'Default Title';

  return new ImageResponse(
    <div style={{ display: 'flex', fontSize: 48, background: '#fff',
      width: '100%', height: '100%', alignItems: 'center', justifyContent: 'center' }}>
      {title}
    </div>,
    { width: 1200, height: 630 }
  );
}
```

### Content Calendar
| Frequency | Content Type | Platform |
|-----------|-------------|----------|
| Weekly | Technical blog post | MicroCMS blog |
| Bi-weekly | Zenn tech article | Zenn |
| Monthly | Product review | Affiliate site |

## Implementation

1. Draft content in MicroCMS or local markdown
2. Run through quality checklist
3. Preview in draft mode (MicroCMS) or local dev (Zenn)
4. Verify OG image renders correctly
5. Publish and verify ISR/deployment

## Common Mistakes

- **No preview before publish**: Always use draft mode to catch formatting issues
- **Missing OG image**: Social shares without images get 50% less engagement
- **Inconsistent slug format**: Use kebab-case, never change after publication
- **Forgetting ISR revalidation**: Published content may not appear until cache expires
