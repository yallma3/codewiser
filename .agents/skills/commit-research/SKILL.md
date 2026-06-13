---
name: commit-research
description: Procedure for updating specification files to reflect a design decision documented in a research ADR. Bridges research output into actionable specs that guide future planning and implementation.
license: MIT
---

# Commit Research Guidelines

## Purpose

Once a research document has been finalized and a decision is made, the specifications must be updated to reflect the new design. This ensures the spec files remain the single source of truth for what the system is and does.

## Prerequisites

- A finalized research document exists at `.agents/research/research_YYMMDD_<topic>.md`
- The decision has been reviewed and accepted

## Procedure

### 1. Read the Research Document

Read the research file identified by the reference. Understand the selected solution, its impact on the system architecture, and any changes to product requirements.

### 2. Update Specification Files

Update the relevant spec files to reflect the new design. Scope the changes as narrowly as possible — update only what the research changed.

- **`.agents/specs/product.md`** — update if the research affects user stories, acceptance criteria, business logic, or user-facing behavior
- **`.agents/specs/system.md`** — update if the research affects architecture, component boundaries, schemas, or API contracts
- **`.agents/specs/system_<module>.md`** — for large systems, use module-scoped spec files (e.g., `system_auth.md`, `system_api.md`) to keep changes scoped and focused

Each updated spec must include a reference to the research that drove the change. Add a line such as:

```markdown
> **ADR**: [research_YYMMDD_<topic>.md](../research/research_YYMMDD_<topic>.md)
```

### 3. Update the Research Document

Add a note to the research file indicating that the specs have been updated. Append a section like:

```markdown
## Specs Updated
- **Date**: <YYMMDD>
- **Files modified**:
  - `.agents/specs/product.md`
  - `.agents/specs/system.md`
```

This creates a clear audit trail from research → spec update.

### 4. Creating Plans from Research

Research documents can serve as the foundation for execution plans. When creating a plan based on a research decision:

- Reference the research file in the plan's `Reference` field
- Use the research's impact assessment to define plan phases
- Link back to the research document for full context

## File Naming Conventions

- Research: `research_YYMMDD_<topic>.md` → `.agents/research/`
- Plans: `plan_YYMMDD_<short-name>.md` → `.agents/plans/`
- Status: `status_YYMMDD_<subject>.md` → `.agents/status/`
