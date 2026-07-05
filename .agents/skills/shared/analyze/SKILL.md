---
name: analyze
description: Guidelines for producing architectural decision records (ADRs). Use when investigating a new feature, bug fix, or refactor to document context, alternatives, and the selected approach.
license: MIT
---

# Research Guidelines

## Purpose

Research documents capture **why** architectural decisions were made. They serve as the long-term memory of the project — answering "why this way?" months later.

## When to Create Research

Before making any non-trivial change — adding a feature, fixing a complex bug, or refactoring — create a research document when:

- The change affects multiple components or interfaces
- The change introduces a new dependency or technology
- There are multiple valid approaches with different trade-offs
- The change may have side effects on existing behavior
- The decision is irreversible or costly to undo

## Research Procedure

### 1. Reference

Every research document must reference the related requirement, bug fix, feature request, or call for change that drives it. Link to the source (plan, issue, PR) when possible.

### 2. Current Architecture

Describe the current architecture **limited to the scope of the change**. Include:

- **Components involved** — which modules, services, or packages are affected
- **Internal interfaces** — functions, APIs, events, or data structures within the system
- **External interfaces** — third-party services, APIs, databases, or libraries consumed
- **Call sites** — where the relevant code is invoked (entry points, consumers)
- **Targets** — where the code produces its effect (outputs, side effects, persisted data)

Be concise. Focus only on what is relevant to the decision at hand.

### 3. Alternatives & Options

List the viable approaches considered. For each alternative, document:

- **Approach** — brief description of how it works
- **Pros** — advantages relevant to this project
- **Cons** — disadvantages, trade-offs, risks
- **Fit** — how well it aligns with the existing architecture

When evaluating dependencies or technology stack changes, apply these criteria in order:

1. **Least dependencies** — prefer packages with minimal transitive dependencies
2. **Least footprint** — prefer smaller bundles, fewer runtime overheads
3. **Purpose-specific** — prefer libraries focused on the exact problem (avoid Swiss-army-knife packages)
4. **Version conflict free** — verify compatibility with existing dependency tree; prefer packages that don't require upgrading/downgrading shared dependencies
5. **Maintenance** — prefer actively maintained, widely adopted packages with good documentation

### 4. Decision & Solution Selection

Document the chosen approach and the rationale:

- **Selected option** — which alternative was chosen
- **Rationale** — why this option was selected over others (reference specific pros/cons)
- **Rejected alternatives** — briefly note why each was not chosen
- **Impact** — what changes are expected (components to modify, new files, migrations, etc.)
- **Risks** — known risks, open questions, or follow-up work

## Research Template

```markdown
# Research: <title> (Date: <YYMMDD>)
- **Reference**: <requirement/bug/feature/call-for-change link or description>

## Current Architecture
- **Components involved**:
- **Internal interfaces**:
- **External interfaces**:
- **Call sites**:
- **Targets**:

## Alternatives & Options

### Option A: <name>
- **Approach**:
- **Pros**:
- **Cons**:
- **Fit**:

### Option B: <name>
- **Approach**:
- **Pros**:
- **Cons**:
- **Fit**:

## Decision
- **Selected option**:
- **Rationale**:
- **Rejected alternatives**:
- **Impact**:
- **Risks**:
```

## Best Practices

- **Write for your future self** — assume the reader has no context. Explain acronyms, reference links, and spell out trade-offs.
- **One decision per document** — if a change involves multiple independent decisions, create separate research files.
- **Date everything** — use YYMMDD format so files sort chronologically.
- **Update on reversal** — if a decision is later reversed, create a new research document superseding the old one. Don't modify historical records.
- **Keep research read-only after acceptance** — once a decision is made and implementation starts, the research document is a historical record. Do not edit it to reflect new decisions; create a new document instead.

## File Naming Conventions

- Research: `research_YYMMDD_<topic>.md` → `.agents/research/`
- Plans: `plan_YYMMDD_<short-name>.md` → `.agents/plans/`
- Status: `status_YYMMDD_<subject>.md` → `.agents/status/`
