---
name: design-db
description: Guidelines for designing or updating relational database schemas based on product requirements, system architecture, and volumetric data. Use when adding new features that require data modeling or revisiting existing schema design.
license: MIT
---

# DB Design Guidelines

## Purpose

Translate product requirements and system architecture into a relational database design that accounts for data volumes, growth patterns, and access dynamics. The output is documented in `.agents/specs/system.md` as part of the architecture.

## Procedure

### 1. Read Existing Context

- Read `.agents/specs/product.md` — understand user stories, acceptance criteria, and business logic
- Read `.agents/specs/system.md` — understand existing architecture, schemas, and API contracts
- Read the relevant BRD (`.agents/specs/product_<domain>.md`) — understand the specific feature domain and use cases

### 2. Interview for Data Dynamics

Ask the user to fill in data behavior for each entity. Propose defaults when the user is unsure.

#### Growth & Mutation Profile

For each table or entity, determine:

| Question | Default assumption |
|---|---|
| Is this entity **append-only** (logs, events, audit trails)? | Assume append-only unless stated otherwise for transaction tables |
| Is this entity **update-heavy** (profiles, statuses, scores)? | Assume updates are infrequent unless stated |
| Is this entity **delete-heavy** (sessions, temp data, queues)? | Assume deletes are rare unless stated |
| What is the **growth rate** (rows per day/month/year)? | Assume 1,000 rows/day for a core entity, 100 rows/day for reference data |
| Is growth **bounded** (finite reference data) or **unbounded** (user-generated)? | Assume unbounded for user-generated data, bounded for reference/lookup tables |
| What is the **retention policy**? | Assume 90 days for transient data, indefinite for permanent data |
| What is the **row size** estimate? | Assume 1 KB per row unless complex JSON or BLOBs are involved |

#### Access Patterns

For each table or entity, determine:

| Question | Default assumption |
|---|---|
| **Read-to-write ratio**? | Assume 80:20 (read-heavy) unless known otherwise |
| Is it **read-heavy** (catalogs, content, dashboards)? | Default: yes for listing/search screens |
| Is it **write-heavy** (events, logs, high-frequency inserts)? | Default: yes for audit/event tables |
| Is it **balanced** (transactional, CRUD)? | Default: yes for core business entities |
| Are there **hot rows** (rows updated by many users concurrently)? | Assume no unless the entity is a shared counter or status |
| What is the **concurrent user count** affecting this entity? | Assume 10% of total daily users at peak |
| Are there **range scans** (date ranges, pagination) or **point lookups** (by ID)? | Assume both: point lookups by PK, range scans by time |

#### Locking & Contention

- Which entities are subject to **heavy concurrent writes** by many users? (e.g., likes, votes, inventory)
- Which entities have **high read concurrency** with stale tolerance? (e.g., product catalog)
- Are there **batch operations** (nightly jobs, ETL) that lock tables?
- Are there **transactional dependencies** where multiple tables must be updated atomically?

### 3. Derive Design Decisions

From the collected data, determine:

- **Indexing strategy** — PKs, foreign keys, covering indexes for frequent queries, partial indexes for filtered queries
- **Partitioning strategy** — time-based partitioning for append-only tables, list partitioning for multi-tenant
- **Read replicas** — if read-heavy with stale tolerance, recommend read replicas
- **Write optimization** — if write-heavy, consider batching, async writes, or append-only patterns with materialized views
- **Locking mitigation** — if hot rows exist, consider optimistic locking, queuing, or counter tables
- **Archival strategy** — retention-based partitioning, tiered storage, or archival jobs for append-only data
- **Connection pooling** — estimate pool size based on concurrent users and query latency

### 4. Document in `system.md`

Append or update the **Database Schemas** section of `.agents/specs/system.md`:

```markdown
## Database Schemas

### <Entity/Table Name>
- **Purpose**:
- **Growth profile**: (append-only / update-heavy / delete-heavy / bounded)
- **Estimated volume**: <rows/day> rows/day, <total rows> at retention limit
- **Access pattern**: (read-heavy / write-heavy / balanced)
- **Read-to-write ratio**: <ratio>
- **Concurrent writers**: <estimate>
- **Key columns**:
  - `id` (PK, type)
  - `created_at` (indexed)
  - ...
- **Indexes**:
  - `idx_<table>_<column>` — purpose
- **Partitioning**: <strategy if any>
- **Retention**: <policy>

### Change History
- **YYYY-MM-DD**: Initial schema design for <feature>. (Reference: <BRD or plan>)
```

### 5. Add Change History Note

At the end of the database section, maintain a chronological change log:

```markdown
## Schema Change History
- **YYYY-MM-DD**: Added `<table>` for `<feature>` — `product_<domain>.md`
- **YYYY-MM-DD**: Added `<column>` to `<table>` — `<reason>`
- **YYYY-MM-DD**: Partitioned `<table>` by `<key>` — `<reason>`
```

## Best Practices

- **Design for the known present, not the imagined future** — avoid over-partitioning or over-indexing for speculative queries. Add indexes when query patterns are confirmed.
- **Name indexes by purpose** — use `idx_<table>_<column>` for single-column, `idx_<table>_<col1>_<col2>` for composite.
- **Document why** — for every non-trivial design decision (partitioning, denormalization, read replicas), note the volumetric driver.
- **Keep schema documentation in system.md** — do not split database design across multiple files unless the schema is very large; use `system_db.md` for large projects.
- **Revisit with new BRDs** — when a new BRD touches existing tables, re-evaluate growth projections and access patterns.
