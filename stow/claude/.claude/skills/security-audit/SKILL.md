---
name: security-audit
description: Use when performing OWASP Top 10 security audit, reviewing authentication flows, checking input sanitization, scanning dependency CVEs, or hardening Next.js and Supabase applications
---

# Security Audit

OWASP-aligned security checklist for Next.js + Supabase applications.

## When to Use

- User asks for a security review or penetration test prep
- Before launching an app handling user data or payments
- User asks about authentication, authorization, or data protection
- After adding new API endpoints or third-party integrations

## Quick Reference: Audit Checklist

### Authentication & Authorization
- [ ] Supabase Auth with PKCE flow (not implicit)
- [ ] JWT verification on all protected API routes
- [ ] Session refresh handled (token expiry gracefully managed)
- [ ] Password policy enforced (min 8 chars, complexity)
- [ ] Rate limiting on auth endpoints (login, signup, password reset)
- [ ] MFA enabled for admin accounts

### Input Validation & Injection
- [ ] All user inputs validated server-side (zod/valibot schemas)
- [ ] SQL injection prevented (parameterized queries, Supabase client API)
- [ ] XSS prevented: no `dangerouslySetInnerHTML` with user content
- [ ] CSRF protection on state-changing operations
- [ ] File upload validation (type, size, content inspection)

### HTTP Security Headers
- [ ] `Content-Security-Policy` configured (block inline scripts)
- [ ] `Strict-Transport-Security` (HSTS) with `max-age=31536000`
- [ ] `X-Content-Type-Options: nosniff`
- [ ] `X-Frame-Options: DENY` (or CSP `frame-ancestors`)
- [ ] `Referrer-Policy: strict-origin-when-cross-origin`
- [ ] Configure in `next.config.js` `headers()` function

### Environment & Secrets
- [ ] No secrets in client code (`NEXT_PUBLIC_` prefix audit)
- [ ] Supabase `service_role` key ONLY in server-side code
- [ ] `.env` files in `.gitignore`
- [ ] API keys rotated on schedule
- [ ] No secrets logged or returned in error responses

### Dependency Security
- [ ] `npm audit` shows no high/critical vulnerabilities
- [ ] Dependencies pinned to exact versions in lockfile
- [ ] No `eval()`, `Function()`, or dynamic `require()` with user input
- [ ] Third-party scripts loaded with `integrity` attribute (SRI)

### Data Protection
- [ ] RLS enabled on all Supabase tables (cross-reference with `supabase-postgres-best-practices`)
- [ ] PII encrypted at rest and in transit
- [ ] Sensitive data not stored in localStorage (use httpOnly cookies)
- [ ] Audit logging for admin actions
- [ ] Medical data: additional encryption layer, access logging

## Implementation

1. Run `npm audit --audit-level=high`
2. Check security headers: securityheaders.com
3. Audit `NEXT_PUBLIC_` variables: `grep -r "NEXT_PUBLIC_" src/`
4. Review Supabase RLS policies in Dashboard
5. Test auth flow edge cases (expired tokens, concurrent sessions)

## Common Mistakes

- **Trusting client-side validation alone**: Always validate on server
- **Exposing service role key**: `NEXT_PUBLIC_SUPABASE_SERVICE_ROLE_KEY` is a critical leak
- **Missing rate limiting**: Brute force attacks on login endpoints
- **CSP too permissive**: `unsafe-inline` and `unsafe-eval` negate CSP benefits
