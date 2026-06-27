---
name: bootstrap
description: Initialize or enrich the project's shared context files. Use when starting fresh on a new or existing codebase to ensure README.md and .agents/specs/ are populated and accurate.
license: MIT
---

# Bootstrap Guidelines

## Purpose

Before any agent can follow the spec-driven execution protocol, the shared context files must exist and reflect the current state of the project. This skill handles initializing or enriching those files.

## Targets

| File | Responsibility |
|---|---|---|
| `README.md` | Project overview, technology choices, available scripts (lint, test, build, typecheck), setup instructions, and coding conventions. |
| `.agents/specs/product.md` | User stories, acceptance criteria, business logic — what the system does. May reference `product_<brd>.md` for larger projects. |
| `.agents/specs/product_<brd>.md` | Business requirements documents scoped to a specific domain or feature. |
| `.agents/specs/ux.md` | Design system, personas, persona profiles, and UX requirements for each persona. |
| `.agents/specs/system.md` | Architecture, component boundaries, schemas, API contracts — how the system is wired. |

## Procedure

### 1. Read the Codebase

Explore the repository to understand:
- Language, framework, and major dependencies
- Project structure (directories, entry points, configuration files)
- Existing tests, lint/typecheck setup, build scripts
- Any existing documentation or config files

### 2. Ask Questions for Gaps

After exploring, ask the user about anything important that is not clearly specified or discoverable from the codebase. For example:

- **Project purpose** — if not obvious from the code or existing docs
- **Target audience or environment** — who uses it, where is it deployed
- **Technology decisions** — if multiple options are plausible and no preference is documented
- **Business logic or rules** — that can't be inferred from the code alone
- **Priority or scope** — which parts to focus on, what to deprioritize

Only ask about what matters — skip questions where the answer is already clear from the codebase. The goal is to fill in unknowns, not to checklist every field.

### 3. Populate or Enrich `README.md`

If `README.md` is missing or sparse:
- Add a project description and purpose
- Document technology stack (language, framework, key libraries)
- List available scripts with their purpose (e.g., `npm run lint`, `yarn test`, `cargo build`)
- Note any coding conventions observed in the codebase
- Add setup/quick-start instructions if applicable

If `README.md` already exists, enrich it with any missing sections discovered during exploration.

### 4. Populate or Enrich `.agents/specs/product.md`

- Derive user stories, features, and acceptance criteria from code exploration and user answers
- Document known entry points, configuration, and user-facing behavior
- If a `product.md` already exists, update it to reflect any newly discovered aspects

### 5. Populate or Enrich `.agents/specs/system.md`

- Document the architecture: major components and their responsibilities
- Map out schemas, data models, key interfaces
- Document external integrations and API contracts
- If a `system.md` already exists, update it to reflect any newly discovered aspects

### 6. Verify

- Reread the updated files to confirm they accurately represent the project
- Ensure no placeholder content remains (e.g., "Describe the high-level system architecture here")
