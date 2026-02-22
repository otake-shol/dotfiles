---
name: typescript-strict-patterns
description: Use when enforcing TypeScript strict mode, designing type-safe API boundaries, auditing for any/as/ts-ignore usage, or applying advanced type patterns like branded types and discriminated unions
---

# TypeScript Strict Patterns

Type safety patterns and anti-pattern detection for strict TypeScript projects.

## When to Use

- User enables or audits TypeScript strict mode
- User asks about type-safe API boundaries (frontend ↔ backend)
- User wants to eliminate `any`, `as`, or `@ts-ignore`
- User asks about advanced patterns (branded types, discriminated unions)

## Quick Reference: Strict Config

### tsconfig.json Strict Flags
```json
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "forceConsistentCasingInFileNames": true
  }
}
```

### Anti-Pattern Detection
| Pattern | Problem | Fix |
|---------|---------|-----|
| `any` | Disables type checking | Use `unknown` + type guard |
| `as Type` | Unsafe assertion | Use type narrowing or `satisfies` |
| `!` (non-null) | Runtime null crash risk | Optional chaining `?.` + `??` |
| `@ts-ignore` | Hides real errors | Use `@ts-expect-error` |
| `Object` / `{}` | Too broad | `Record<string, unknown>` |

### Type-Safe Patterns

#### Branded Types (prevent ID mixups)
```typescript
type UserId = string & { readonly __brand: 'UserId' };
type PostId = string & { readonly __brand: 'PostId' };
const userId = 'abc' as UserId;
// Cannot pass UserId where PostId expected
```

#### Discriminated Unions (safe state handling)
```typescript
type AsyncState<T> =
  | { status: 'idle' }
  | { status: 'loading' }
  | { status: 'success'; data: T }
  | { status: 'error'; error: Error };
// TypeScript narrows `data` only when status === 'success'
```

#### Zod Schema → Type Inference
```typescript
import { z } from 'zod';
const userSchema = z.object({ name: z.string(), email: z.string().email() });
type User = z.infer<typeof userSchema>; // Single source of truth
```

#### Supabase Generated Types
```bash
npx supabase gen types typescript --project-id $PROJECT_ID > src/types/database.ts
```

#### const Assertions
```typescript
const ROLES = ['admin', 'editor', 'viewer'] as const;
type Role = typeof ROLES[number]; // 'admin' | 'editor' | 'viewer'
```

### Audit Checklist
- [ ] `strict: true` in tsconfig.json
- [ ] Zero `any` in production code (`grep -r ": any" src/`)
- [ ] Zero `@ts-ignore` (`grep -r "@ts-ignore" src/`)
- [ ] All API responses typed (no `as` on fetch results)
- [ ] Supabase types auto-generated and up to date
- [ ] Zod schemas for all external data boundaries

## Implementation

1. Enable `strict: true` and fix errors incrementally
2. Search for anti-patterns: `any`, `as`, `!`, `@ts-ignore`
3. Replace `any` with `unknown` + type guards
4. Generate Supabase types and verify usage
5. Add zod validation at API boundaries

## Common Mistakes

- **Enabling strict all at once on large codebase**: Enable flag-by-flag incrementally
- **Using `as` to silence errors**: Usually means the real type is wrong
- **Forgetting `noUncheckedIndexedAccess`**: Array/object access can return `undefined`
- **Not regenerating Supabase types after schema changes**: Types drift from reality
