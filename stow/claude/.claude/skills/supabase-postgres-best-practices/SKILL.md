---
name: supabase-postgres-best-practices
description: Use when designing Supabase database schemas, auditing PostgreSQL performance, configuring Row Level Security (RLS), or troubleshooting slow queries
---

# Supabase Postgres Best Practices

Security and performance audit checklist for Supabase/PostgreSQL.

## When to Use

- User is setting up a new Supabase project or database schema
- User reports slow queries or timeout errors
- User needs to configure or audit RLS policies
- User asks about indexing, migrations, or query optimization

## Quick Reference: Audit Checklist

### Row Level Security (RLS)
- [ ] RLS enabled on ALL tables (`ALTER TABLE t ENABLE ROW LEVEL SECURITY`)
- [ ] No tables with `public` access without explicit policy
- [ ] Policies use `auth.uid()` not client-supplied user IDs
- [ ] `USING` clause for SELECT, `WITH CHECK` for INSERT/UPDATE
- [ ] Service role key NEVER exposed to client code
- [ ] Test policies with different user contexts

### Indexing
- [ ] Primary keys and foreign keys indexed (auto for PK, manual for FK)
- [ ] Columns in `WHERE`, `JOIN`, `ORDER BY` have appropriate indexes
- [ ] Composite indexes match query column order (leftmost prefix rule)
- [ ] No unused indexes (check `pg_stat_user_indexes`)
- [ ] Partial indexes for filtered queries (`WHERE status = 'active'`)
- [ ] GIN indexes for JSONB and full-text search columns

### Query Optimization
- [ ] Use `EXPLAIN ANALYZE` to verify query plans
- [ ] Avoid `SELECT *` — fetch only needed columns
- [ ] Pagination uses cursor-based (`WHERE id > $1`) not `OFFSET`
- [ ] N+1 queries resolved with joins or batch fetching
- [ ] Supabase client uses `.select('col1, col2')` not `.select('*')`

### Schema Design
- [ ] UUID primary keys (`gen_random_uuid()`)
- [ ] `created_at` / `updated_at` timestamps with defaults
- [ ] Enums for fixed value sets instead of text
- [ ] Soft delete (`deleted_at`) where audit trail needed
- [ ] Foreign key constraints with appropriate `ON DELETE` behavior

### Supabase Specific
- [ ] Edge Functions for server-side logic (not client-side SQL)
- [ ] Realtime enabled only on tables that need it
- [ ] Storage policies match RLS patterns
- [ ] Database webhooks for async operations
- [ ] Connection pooling mode set appropriately (transaction vs session)

## Implementation

1. Run `EXPLAIN ANALYZE` on slow queries
2. Check missing indexes: query `pg_stat_user_tables` for sequential scans
3. Audit RLS: list all tables and their policies
4. Review Supabase Dashboard > Database > Query Performance

## Common Mistakes

- **RLS disabled "temporarily"**: Every table must have RLS from day one
- **Over-indexing**: Each index slows writes; only index what queries need
- **Using `OFFSET` for pagination**: Degrades linearly; use keyset pagination
- **Storing files in database**: Use Supabase Storage for binary data
