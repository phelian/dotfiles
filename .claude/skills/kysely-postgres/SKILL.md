---
name: kysely-postgres
description: "PostgreSQL with Kysely query builder, dbmate migrations, and kysely-codegen. Use when working with Kysely queries, PostgreSQL schemas, or database migrations."
---

# Kysely + PostgreSQL + dbmate

## Stack Overview

| Component      | Purpose                               |
| -------------- | ------------------------------------- |
| PostgreSQL     | Database                              |
| Kysely         | Type-safe query builder               |
| pg             | Node postgres driver                  |
| dbmate         | SQL migrations                        |
| kysely-codegen | Generate TypeScript types from schema |

## Kysely Setup

```typescript
import { CamelCasePlugin, Kysely, PostgresDialect } from "kysely";
import pg from "pg";
import type { DB } from "./dbTypes.ts";

const db = new Kysely<DB>({
  dialect: new PostgresDialect({
    pool: new pg.Pool({ connectionString: process.env.DATABASE_URL }),
  }),
  plugins: [new CamelCasePlugin()],
});

export default db;
```

The `CamelCasePlugin` converts: `snake_case` (DB) ↔ `camelCase` (code).

## Query Patterns

### Select

```typescript
const rows = await db
  .selectFrom("user")
  .select(["id", "email", "createdAt"])
  .where("deletedAt", "is", null)
  .orderBy("createdAt", "desc")
  .limit(10)
  .execute();

const user = await db
  .selectFrom("user")
  .selectAll()
  .where("id", "=", userId)
  .executeTakeFirst();
```

### Insert

```typescript
const id = crypto.randomUUID();

await db.insertInto("user").values({ id, email, name }).execute();

const inserted = await db
  .insertInto("user")
  .values({ id, email, name })
  .returning(["id", "email"])
  .executeTakeFirstOrThrow();
```

### Update

```typescript
await db
  .updateTable("user")
  .set({ name: newName })
  .where("id", "=", userId)
  .execute();

const result = await db
  .updateTable("user")
  .set({ deletedAt: new Date() })
  .where("id", "=", userId)
  .executeTakeFirst();

const affected = result.numUpdatedRows ?? 0n;
```

### Delete (prefer soft delete)

```typescript
await db
  .updateTable("user")
  .set({ deletedAt: new Date() })
  .where("id", "=", userId)
  .execute();
```

### Count

```typescript
const result = await db
  .selectFrom("user")
  .select((eb) => eb.fn.count("id").as("count"))
  .where("deletedAt", "is", null)
  .executeTakeFirst();

const total = Number(result?.count ?? 0);
```

### Joins

```typescript
const rows = await db
  .selectFrom("order")
  .innerJoin("user", "user.id", "order.userId")
  .select(["order.id", "order.total", "user.email"])
  .execute();
```

### Transactions

```typescript
await db.transaction().execute(async (trx) => {
  await trx.insertInto("order").values({ id, userId, total }).execute();
  await trx.insertInto("orderItem").values(items).execute();
});
```

### Raw SQL

```typescript
import { sql } from "kysely";

const result = await sql`select now()`.execute(db);

const rows = await db
  .selectFrom("user")
  .select(["id", sql<number>`extract(year from created_at)`.as("year")])
  .execute();
```

## dbmate Migrations

### Create migration

```bash
dbmate new add_users_table
```

Creates `db/migrations/YYYYMMDDHHMMSS_add_users_table.sql`.

### Migration template

```sql
-- migrate:up
create table my_table (
  id text primary key,
  user_id text not null references users(id),
  name text not null,
  data jsonb not null default '{}',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create index my_table_user_id_idx on my_table(user_id);
create index my_table_updated_at_idx on my_table(updated_at);

create trigger my_table_updated_at before update on my_table
  for each row execute function update_updated_at();

-- migrate:down
drop table if exists my_table;
```

### Run migrations

```bash
dbmate up        # apply pending
dbmate down      # rollback last
dbmate status    # show migration status
dbmate dump      # dump schema to db/schema.sql
```

### update_updated_at trigger function

Create once in initial migration:

```sql
create or replace function update_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;
```

## kysely-codegen

Regenerate types after schema changes:

```bash
DATABASE_URL="postgres://..." kysely-codegen --out-file ./dbTypes.ts
```

Never edit `dbTypes.ts` manually.

## Schema Conventions

| Column       | Type                        | Purpose                        |
| ------------ | --------------------------- | ------------------------------ |
| `id`         | `text primary key`          | UUID via `crypto.randomUUID()` |
| `user_id`    | `text references users(id)` | Foreign key                    |
| `created_at` | `timestamptz default now()` | Creation timestamp             |
| `updated_at` | `timestamptz default now()` | Auto-updated via trigger       |
| `deleted_at` | `timestamptz`               | Soft delete (null = active)    |

## Common Patterns

### Soft delete filter

Always filter out deleted records:

```typescript
.where("deletedAt", "is", null)
```

### Sync queries (mobile/offline)

Return records modified since timestamp:

```typescript
const rows = await db
  .selectFrom("entry")
  .select(["id", "data", "updatedAt", "deletedAt"])
  .where("userId", "=", userId)
  .where("updatedAt", ">", new Date(since))
  .orderBy("updatedAt", "asc")
  .execute();
```

### Upsert by unique field

```typescript
const existing = await db
  .selectFrom("entry")
  .select("id")
  .where("userId", "=", userId)
  .where("date", "=", date)
  .executeTakeFirst();

if (existing) {
  await db
    .updateTable("entry")
    .set(data)
    .where("id", "=", existing.id)
    .execute();
} else {
  await db
    .insertInto("entry")
    .values({ id: crypto.randomUUID(), ...data })
    .execute();
}
```

### Pagination

```typescript
const rows = await db
  .selectFrom("entry")
  .selectAll()
  .where("deletedAt", "is", null)
  .orderBy("createdAt", "desc")
  .limit(limit)
  .offset(offset)
  .execute();
```
