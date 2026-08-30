# DATABASE.md

> High-level database strategy. Engine, multi-tenancy, access policies, migrations.
> Table-by-table reference lives in `SCHEMA.md`.

## Engine

TODO(<owner>): e.g., Postgres 15. Extensions in use.

## Connection

TODO(<owner>): How code connects. Pooling. Where the connection lives in code.

```
TODO(<owner>): example connection import
```

## Do / Don't

**Do:**
- Always wrap multi-statement writes in a transaction.
- Always index foreign-key columns.
- Always add new migrations; never edit migrations that have been applied to any environment.
- Use parameterized queries — every time, no exceptions. (Hard rule, see `SECURITY.md`.)
- Match column types across foreign-key relationships (no joining int to bigint).

**Don't:**
- Don't string-concatenate SQL. Ever. (Hard rule.)
- Don't run `DROP` or destructive `ALTER` in a deploy without an explicit `DECISIONS.md` entry.
- Don't rely on database defaults to enforce business rules — enforce in application code or constraints.
- Don't use the database for queue semantics if a real queue is available.
- Don't store JSON when the data has known structure that justifies columns.

## Multi-tenancy strategy

TODO(<owner>): One of:
- Single DB, shared schema, `tenant_id` column on every tenant table + access policies
- Single DB, schema-per-tenant
- DB-per-tenant
- Not multi-tenant

If access-policy-based: cross-link `SECURITY.md` for the threat-model rationale.

## Access policies (RLS / RBAC / etc.)

TODO(<owner>): Which tables have policies enabled, the general policy pattern, where policies are defined.

## Migrations

- Tool: TODO(<owner>): e.g., Supabase CLI, Drizzle Kit, Prisma Migrate, Alembic, Flyway, sqitch
- Location: TODO(<owner>): e.g., `migrations/`, `db/migrate/`, `supabase/migrations/`
- Naming: TODO(<owner>): e.g., `YYYYMMDDHHMMSS_description.sql`
- **Hard rule:** never edit a migration that has been applied to any environment. Always add a new one.

## Query performance rules

TODO(<owner>): Project-specific rules. Common ones:
- Every query touching a tenant table must filter by `tenant_id` first
- N+1 query patterns are bugs — use joins or batch loading
- Add `EXPLAIN ANALYZE` to any new query expected to handle >1000 rows

## Transaction policy

TODO(<owner>): When transactions are required, isolation level defaults, retry policy on conflicts.

## Backups

TODO(<owner>): Frequency, retention, restore procedure.

## Local development

TODO(<owner>): How to spin up a local DB, seed data approach.
