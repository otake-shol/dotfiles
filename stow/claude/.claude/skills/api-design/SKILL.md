---
name: api-design
description: Use when designing REST API endpoints, standardizing error responses, creating OpenAPI schemas, reviewing API contracts, or building Next.js Route Handlers and Java APIs
---

# API Design

REST API design patterns for Next.js Route Handlers and Java APIs.

## When to Use

- User is creating new API endpoints
- User asks about error handling or response format standardization
- User needs to design API contracts between frontend and backend
- User asks about API versioning, pagination, or rate limiting

## Quick Reference: Design Patterns

### URL Design
```
GET    /api/users          → List users
GET    /api/users/:id      → Get single user
POST   /api/users          → Create user
PATCH  /api/users/:id      → Partial update
DELETE /api/users/:id      → Delete user
GET    /api/users/:id/posts → Nested resource
```

### Standard Response Format
```typescript
// Success
{ data: T, meta?: { page, totalPages, totalCount } }

// Error
{ error: { code: string, message: string, details?: Record<string, string[]> } }
```

### HTTP Status Codes
| Code | Use Case |
|------|----------|
| 200 | Success (GET, PATCH, DELETE) |
| 201 | Created (POST) |
| 204 | No Content (DELETE with no body) |
| 400 | Validation error (invalid input) |
| 401 | Unauthenticated (no/invalid token) |
| 403 | Forbidden (valid token, insufficient permissions) |
| 404 | Resource not found |
| 409 | Conflict (duplicate resource) |
| 422 | Unprocessable (valid syntax, semantic error) |
| 429 | Rate limited |
| 500 | Internal server error |

### Next.js Route Handler Pattern
```typescript
// app/api/users/route.ts
import { NextRequest, NextResponse } from 'next/server';
import { z } from 'zod';

const schema = z.object({ name: z.string().min(1), email: z.string().email() });

export async function POST(request: NextRequest) {
  const body = await request.json();
  const parsed = schema.safeParse(body);
  if (!parsed.success) {
    return NextResponse.json(
      { error: { code: 'VALIDATION_ERROR', message: 'Invalid input', details: parsed.error.flatten().fieldErrors } },
      { status: 400 }
    );
  }
  // ... create user
  return NextResponse.json({ data: user }, { status: 201 });
}
```

### Pagination
```typescript
// Cursor-based (preferred)
GET /api/posts?cursor=abc123&limit=20
→ { data: [...], meta: { nextCursor: "def456", hasMore: true } }

// Offset-based (simpler, less performant)
GET /api/posts?page=2&limit=20
→ { data: [...], meta: { page: 2, totalPages: 10, totalCount: 200 } }
```

### Zod Schema Sharing
```typescript
// shared/schemas/user.ts — single source of truth
export const userSchema = z.object({ ... });
export type User = z.infer<typeof userSchema>;
// Used in both Route Handler validation and client-side form validation
```

## Implementation

1. Define resource models and relationships
2. Design URL structure (RESTful, consistent naming)
3. Create zod schemas for request/response validation
4. Implement Route Handlers with standard error format
5. Document with OpenAPI/Swagger if external consumers exist

## Common Mistakes

- **Verbs in URLs**: Use `/api/users` not `/api/getUsers`
- **Inconsistent error format**: Every error must follow the same structure
- **Returning 200 for errors**: Use proper HTTP status codes
- **No input validation on server**: Client schemas can be bypassed
