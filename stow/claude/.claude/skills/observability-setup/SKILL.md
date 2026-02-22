---
name: observability-setup
description: Use when setting up error tracking, logging, monitoring, health checks, or privacy-friendly analytics for Next.js applications on Vercel
---

# Observability Setup

Error tracking, monitoring, and analytics setup for Next.js production applications.

## When to Use

- User deploys a new app to production and needs monitoring
- User asks about error tracking, Sentry, or logging
- User wants to add analytics without compromising user privacy
- User needs a health check endpoint or uptime monitoring

## Quick Reference: Observability Stack

### Recommended Stack
| Layer | Tool | Purpose |
|-------|------|---------|
| Error tracking | Sentry | Unhandled errors, performance traces |
| Analytics | Vercel Analytics | Web Vitals, page views (privacy-first) |
| Speed monitoring | Vercel Speed Insights | Real user performance metrics |
| Logging | Structured JSON logs | Server-side debugging |
| Health check | `/api/health` endpoint | Uptime monitoring |

### Sentry Integration
```typescript
// next.config.ts
import { withSentryConfig } from '@sentry/nextjs';
export default withSentryConfig(nextConfig, {
  org: 'your-org', project: 'your-project',
  silent: true, // Suppress build logs
});
```
- [ ] `sentry.client.config.ts` configured
- [ ] `sentry.server.config.ts` configured
- [ ] `sentry.edge.config.ts` configured (for middleware)
- [ ] Source maps uploaded (automatic with Vercel integration)
- [ ] Error boundary: `global-error.tsx` in App Router

### Vercel Analytics & Speed Insights
```typescript
// app/layout.tsx
import { Analytics } from '@vercel/analytics/react';
import { SpeedInsights } from '@vercel/speed-insights/next';

export default function RootLayout({ children }) {
  return (
    <html><body>
      {children}
      <Analytics />
      <SpeedInsights />
    </body></html>
  );
}
```

### Structured Logging
```typescript
// lib/logger.ts
export function log(level: 'info' | 'warn' | 'error', message: string, meta?: Record<string, unknown>) {
  const entry = { timestamp: new Date().toISOString(), level, message, ...meta };
  console[level](JSON.stringify(entry));
}
```

### Health Check Endpoint
```typescript
// app/api/health/route.ts
export async function GET() {
  return Response.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    version: process.env.VERCEL_GIT_COMMIT_SHA?.slice(0, 7) ?? 'dev',
  });
}
```

### Privacy-Friendly Alternatives
| Tool | Privacy Level | Features |
|------|-------------|----------|
| Vercel Analytics | High | No cookies, GDPR-compliant |
| Plausible | High | No cookies, EU-hosted option |
| Umami | High | Self-hosted, open source |

## Implementation

1. `npx @sentry/wizard@latest -i nextjs` for Sentry setup
2. Add `<Analytics />` and `<SpeedInsights />` to root layout
3. Create `/api/health` endpoint
4. Configure structured logging in server-side code
5. Set up uptime monitoring (Vercel Cron or external)

## Common Mistakes

- **No error boundary**: Unhandled errors crash the entire app without user feedback
- **Logging PII**: Never log emails, passwords, or medical data
- **Analytics without consent**: Medical sites need explicit cookie consent in Japan
- **No source maps in production**: Sentry stack traces become unreadable
