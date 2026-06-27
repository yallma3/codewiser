# Shared AI Agent Instructions

Global instructions and behavioral constraints live in this file.
Project-specific scripts, technology choices, and setup instructions are documented in `README.md`.

## Core Directives
- `.agents/skills/` — What the agents can do (Commands/Capabilities).
- `.agents/specs/` — What the agents are building (System & Product Architecture).
- `.agents/plans/` — How the agents will execute the current task (Short-term context).
- `.agents/research/` — Why the architectural decisions were made (Long-term engineering notes).

## Spec-Driven Execution Protocol

All file modifications or code generation tasks MUST follow this lifecycle:

### Read Phase
1. Read `.agents/specs/product.md` to verify feature compliance.
2. Read `.agents/specs/system.md` to ensure architectural alignment.
3. Read `.agents/specs/ux.md` for UX and design system constraints.

### Spec Creation Sequence (when establishing a new feature)
1. **Bootstrap** — Initialize project context (`README.md`, `product.md`, `system.md`).
2. **Git Worktrees & Branch Management** — create an isolated feature branch or worktree before planning and spec changes.
3. **Create BRD** — Capture business requirements in `product_<domain>.md`.
4. **Create UX Specs** — Define design system, personas, and UX requirements in `ux.md`.
5. **Design DB** — Design relational schemas based on volumetric data; document in `system.md`.

### For Complex Decisions
1. **Research** — Produce an ADR (`.agents/research/research_YYMMDD_<topic>.md`)
   documenting context, alternatives, and the selected approach.
2. **Commit Research** — Update relevant spec files (`product.md`, `system.md`,
   `system_<module>.md`) with a reference back to the research document.

### Execution (per task)
1. **Create Plan** — Break work into incremental, verifiable phases
   (`.agents/plans/plan_YYMMDD_<name>.md`).
2. **Implement Plan** — Execute phases, verify gates, retry up to 5 times on
   failure. On success, update `.agents/specs/spec-index.json` and
   `.agents/specs/product.md` as needed.

### Core rule
If an implementation changes the system design, update the relevant spec files
first before writing production code.

## File Naming Conventions
- Plans: `plan_YYMMDD_<short-name>.md` → `.agents/plans/`
- Research: `research_YYMMDD_<topic>.md` → `.agents/research/`
- Status: `status_YYMMDD_<subject>.md` → `.agents/status/`
