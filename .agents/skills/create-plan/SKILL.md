---
name: create-plan
description: Guidelines for planning tasks and creating plans. Use when starting a new task, breaking down work, or defining verifiable goals before implementation. Status tracking is handled by the implementation skill.
license: MIT
---

# Create Plan Guidelines

## Purpose

Break work into incremental, verifiable phases before implementation. Plans are saved to `.agents/plans/plan_YYMMDD_<short-name>.md` and referenced during execution.

## When to Use

- Starting a new feature or task
- Breaking down complex work
- Defining clear acceptance criteria before coding
- When a design decision has been committed and needs implementation planning

## Procedure

### 1. Understand the Context

Read relevant specs:
- `.agents/specs/product.md` — what the system does
- `.agents/specs/system.md` — how the system is wired
- `.agents/specs/ux.md` — UX requirements (if applicable)
- Any `system_<area>.md` or `product_<brd>.md` files for the domain
- **Design-options file (optional, but primary input if present)** — if a `commit-design` decision was made, read the design-options file (e.g., `.agents/design-options/design-option_YYMMDD_<topic>.md`) and its **Selected Option** section, especially the **Spec Update Plan**

### 2. Identify Scope & Acceptance Criteria

Define what is in/out of scope. Write testable acceptance criteria for each phase.

**Surface assumptions and tradeoffs explicitly:**
- State every assumption the plan depends on (e.g., "assumes auth module exists").
- If multiple approaches exist for a phase, document the tradeoffs and why the chosen one is preferred.
- If a simpler approach exists than what the design decision prescribes, flag it here.

### 3. Break Into Phases

Split work into phases that:
- Can be verified independently
- Have clear entry/exit criteria
- Minimize risk early (e.g., infrastructure before features)

### 4. Write the Plan

Use the template below. Save as `.agents/plans/plan_YYMMDD_<short-name>.md`.

### 5. Verify

Confirm the plan:
- Covers all acceptance criteria
- Phases are independently verifiable
- No hidden dependencies between phases
- References spec files and design decisions

## Plan Template

```markdown
---
purpose: "<explicit purpose>"
agent: "<agent name>"
llm: "<model name>"
date: "<YYMMDD>"
design_option_ref: "<path to design-options file, e.g., .agents/design-options/design-option_YYMMDD_<topic>.md>"
---

# Plan: <short name>

## Context
- **Related specs**: <links to product.md, system.md, ux.md, design-options>
- **Design decision**: <reference to Selected Option in design-options file>
- **Scope**: <what is in/out of scope>

## Acceptance Criteria
- [ ] <criterion 1>
- [ ] <criterion 2>

## Phases

### Phase 1: <name>
- **Goal**: <what this phase achieves>
- **Tasks**:
  - [ ] <task 1>
  - [ ] <task 2>
- **Verification**: <how to verify this phase is complete>
- **Spec updates**: <spec files to update, e.g., product.md, system.md, system_<topic>.md — per Spec Update Plan in design-options>

### Phase 2: <name>
...

## Risks & Mitigations
- <risk>: <mitigation>

## Dependencies
- <external or cross-team dependencies>
```

## Spec Updates

When a design-options file contains a **Spec Update Plan** (added by `commit-design`), the plan should include those spec updates in the relevant phases. The `implement-plan` skill will execute the spec updates during implementation.

Every plan phase that produces architectural changes must include `system.md` and any relevant `system_<topic>.md` files in its `**Spec updates**:` field. This ensures impl agents know exactly which system docs to update after verification gates pass.

## Plan Naming

- Format: `plan_YYMMDD_<short-name>.md`
- Location: `.agents/plans/`
- Never delete old plans — implementation skill adds status reports alongside.

## Status Tracking

Status is tracked by the `implement-plan` skill in `.agents/status/status_YYMMDD_<subject>.md`. The plan file itself remains immutable after creation.