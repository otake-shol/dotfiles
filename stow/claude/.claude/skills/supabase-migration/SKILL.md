---
name: supabase-migration
description: Use when creating Supabase database migrations, reviewing schema changes, planning safe rollbacks, or executing migration workflows with supabase CLI
---

# Supabase Migration

Safe migration workflow for Supabase PostgreSQL schema changes.

## When to Use

- User needs to create a new migration (add table, column, index)
- User wants to review a migration for safety
- User asks about rollback strategies
- User needs to sync RLS policies with schema changes

## Quick Reference: Migration Workflow

### Creating Migrations
```bash
# 1. Make changes in local Supabase Studio or SQL
supabase migration new <descriptive_name>
# 2. Edit the generated SQL file in supabase/migrations/
# 3. Test locally
supabase db reset   # Recreates from scratch
supabase db diff    # Compare local vs remote
# 4. Push to remote
supabase db push
```

### Safe Change Patterns

| Change | Safe Pattern | Dangerous Pattern |
|--------|-------------|-------------------|
| Add column | `ALTER TABLE ADD COLUMN col type` (nullable) | Adding NOT NULL without default |
| Remove column | 1) Stop reading → 2) Deploy → 3) Drop column | Drop column while code reads it |
| Rename column | 1) Add new → 2) Migrate data → 3) Drop old | `ALTER TABLE RENAME COLUMN` |
| Add NOT NULL | 1) Add nullable → 2) Backfill → 3) Add constraint | Direct `NOT NULL` on existing column |
| Change type | 1) Add new column → 2) Migrate → 3) Drop old | `ALTER COLUMN SET DATA TYPE` |
| Drop table | 1) Remove all code references → 2) Deploy → 3) Drop | Drop while code references it |

### Migration SQL Template
```sql
-- Migration: <description>
-- Safe: YES/NO (if NO, explain rollback)

BEGIN;

-- Forward migration
ALTER TABLE public.my_table ADD COLUMN new_col text;

-- Update RLS if needed
-- CREATE POLICY ... ON public.my_table ...

COMMIT;
```

### Rollback Strategy
- [ ] Every migration has a corresponding rollback SQL
- [ ] Store rollback in comment block or separate file
- [ ] Test rollback locally before pushing to production
- [ ] For data migrations: backup before, verify after

### RLS Sync Checklist
- [ ] New tables: add `ENABLE ROW LEVEL SECURITY` + policies
- [ ] New columns with sensitive data: update policies
- [ ] Dropped columns: verify no policy references them
- [ ] Role changes: audit all affected policies

## Implementation

1. `supabase migration new add_feature_x`
2. Write forward SQL with transaction wrapper (`BEGIN`/`COMMIT`)
3. Write rollback SQL in comments
4. `supabase db reset` — verify clean apply
5. `supabase db push` — apply to remote
6. Verify in Supabase Dashboard

## Common Mistakes

- **No transaction wrapper**: Partial migrations leave database in broken state
- **Skipping local test**: `supabase db reset` catches errors before production
- **Forgetting RLS on new tables**: New tables are publicly accessible without RLS
- **Data-dependent migrations without backfill**: NOT NULL constraints fail on existing rows
