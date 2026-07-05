---
name: create-brd
description: Guidelines for producing Business Requirements Documents (BRDs). Use when capturing business stories, use cases, and scope for a specific domain or feature.
license: MIT
---

# BRD Guidelines

## Purpose

Business Requirements Documents (BRDs) capture the **what** and **why** of a feature or domain at a business level. Each BRD is a standalone file that the product spec (`product.md`) references. Keeping BRDs small and focused makes them easier to review, prioritize, and implement.

## File Naming Convention

BRD files follow the pattern `product_<domain>.md` under `.agents/specs/`:

```
.agents/specs/
├── product.md                  # Master product spec referencing all BRDs
├── product_payments.md         # BRD for payments domain
├── product_user-management.md  # BRD for user management
└── product_notifications.md    # BRD for notifications
```

## Scope Guidelines

- **Prefer many small BRDs** over one large document. Each BRD should cover a single cohesive domain or feature.
- **Numbering**: Use a prefix scheme to show relationships, e.g., `product_01-auth.md`, `product_01a-sso.md`, `product_02-payments.md`.
- **Relations**: Within each BRD, reference related BRDs by number and file path.
- **Product.md** must list all BRDs with their numbers, titles, and a one-line summary.

## Procedure

### 1. Read Existing Context

- Read `.agents/specs/product.md` to understand the existing feature landscape
- Read `.agents/specs/system.md` for architecture constraints
- Check for existing BRDs to avoid overlap

### 2. Ask Questions

Interview the user to fill in the business story. For volumetric questions (users, frequency, data size), if the user is unsure, propose a best-guess default value for discussion.

#### Business Story

- What business problem or opportunity drives this feature?
- Who is requesting it? (stakeholder, customer segment, internal team)
- What is the desired outcome? (revenue, retention, efficiency, compliance)
- What is the priority relative to other work? (P0-critical, P1-high, P2-medium, P3-nice-to-have)
- Is there a target date or deadline?

#### Use Cases

For each use case:

- **Title & ID** — unique identifier (e.g., UC-01)
- **Description** — what the user accomplishes
- **Trigger** — what initiates this use case
- **Preconditions** — what must be true before it starts
- **Postconditions** — what is true after success
- **Main flow** — step-by-step happy path
- **Alternate flows** — variations or options
- **Error flows** — what happens on failure
- **Frequency** — how often does this happen? (default: a few times per day per user)
- **Complexity** — low / medium / high
- **Criticality** — critical / important / nice-to-have

#### Personas

- Which personas are involved in each use case?
- Are there new personas not yet documented in `ux.md`?

#### Volumetrics (with defaults)

For questions about scale, propose a default if the user is unsure:

| Question | Default assumption |
|---|---|
| How many users will use this feature? | Assume 10% of total user base initially |
| How many transactions/operations per day? | Assume 1,000 per day |
| How much data per operation? | Assume 1 KB per record |
| How many concurrent users? | Assume 10% of daily users at peak |
| Retention period for data? | Assume 90 days |
| How many records in reference tables? | Assume 100–1,000 entries |

Adjust defaults based on the project's known scale if available.

### 3. Write the BRD

```markdown
# BRD: <Domain/Feature> (Date: <YYMMDD>)
- **Reference**: <link to requirement, epics, or user story>
- **Related BRDs**: <list of related product_<domain>.md files>

## Business Context
- **Problem statement**:
- **Stakeholder**:
- **Desired outcome**:
- **Priority**: P0 / P1 / P2 / P3
- **Target date**:

## Personas
- **Primary personas**:
- **Secondary personas**:

## Use Cases

### UC-01: <title>
- **Description**:
- **Trigger**:
- **Preconditions**:
- **Postconditions**:
- **Frequency**: (default: a few times per day per user)
- **Complexity**: low / medium / high
- **Criticality**: critical / important / nice-to-have
- **Main flow**:
  1. Step 1
  2. Step 2
- **Alternate flows**:
  - A1: ...
- **Error flows**:
  - E1: ...

### UC-02: <title>
- ...

## Volumetrics
- **Expected users**:
- **Transactions per day**:
- **Data per operation**:
- **Concurrent users**:
- **Retention period**:
- **Notes**:

## Dependencies
- **Internal dependencies**: <other BRDs, teams, components>
- **External dependencies**: <third-party services, APIs>

## Open Questions
- <list unresolved items>
```

### 4. Update `product.md`

After creating a BRD, add a reference entry in `product.md`:

```markdown
## BRDs
- [01 - Payments](product_payments.md) — Payment processing, refunds, invoicing
- [02 - Notifications](product_notifications.md) — Email, SMS, in-app notifications
```
