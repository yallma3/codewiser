---
name: analyze
description: Guidelines for reverse engineering a codebase to document how a specific functionality works — its architecture, contracts, interfaces, data flow, and component interactions. Use when updating the project specs, debugging a complex feature, or producing a system reference for future planning for new Module or Feature.
license: MIT
---

# Reverse Engineering Guidelines

## Purpose

Reverse engineering documents capture **how a specific functionality actually works** in the current codebase and **keep that understanding in sync** as the system evolves. They serve as the project's living map — answering "how does this feature work from entry to exit?" for both human readers and agents. When no specific topic is given, the agent should analyze recent changes and determine whether a new `system_<topic>.md` spec is needed or an existing one should be updated. The analysis is either about a how-it-works or a module.

## When to Create a Reverse Engineering Document

Create a reverse engineering analysis when:

- Documenting and updating specs for future reference
- Planning a change that modifies or extends existing behavior
- Onboarding to a new module or unfamiliar area of the codebase
- Debugging a subtle or cross-cutting bug
- Extracting contracts and interfaces for test doubles or mocks

## Procedure

### 1. Scope

Define the functionality or subsystem under analysis. State what is being analyzed and, equally important, what is out of scope.

### 2. Entry Points

Identify every **entry point** into the functionality:

- Public APIs (REST endpoints, CLI commands, event handlers, library exports)
- UI components or screens that trigger the flow
- Scheduled jobs, cron triggers, or background workers
- Test entry points (factories, test helpers)

### 3. Data Flow Trace

Trace the execution path from an entry point through the system:

- **Call chain** — sequence of function/method calls, ordered by invocation
- **Data transformations** — how data is shaped, validated, enriched, or serialized at each step
- **Branching logic** — conditionals, feature flags, or configuration that alter the path
- **Error paths** — what happens when something fails at each step (exceptions, fallbacks, retries)

### 4. Components & Responsibilities

List every component involved and its specific responsibility:

- **Modules/packages** — file paths and their role in this functionality
- **Classes/structs** — key types and their methods relevant to the flow
- **State machines** — if applicable, the states and transitions

### 5. Interfaces & Contracts

Document every interface boundary crossed:

- **Internal interfaces** — function signatures, abstract classes, traits, or protocols; the contracts they enforce (preconditions, postconditions, invariants)
- **External interfaces** — HTTP endpoints consumed, database queries, message queue topics, file I/O; include the schema or shape of data
- **Shared data structures** — types, DTOs, or records passed between components; include field meanings where not obvious

### 6. Dependencies

List external dependencies specific to this functionality:

- **Libraries/packages** — and which part of the flow uses them
- **Services** — external APIs, databases, caches, or queues
- **Configuration** — environment variables, feature flags, or settings that affect behavior

### 7. Tests & Verification

Document how the functionality is tested:

- **Test types** — unit, integration, e2e, snapshot
- **Key test files** — paths and what they cover
- **Test doubles** — what is mocked/stubbed and why
- **Coverage gaps** — areas without test coverage

### 8. Update Spec Index

Register the analysis in `.agents/specs/spec-index.json`:

- If creating a **new** `system_<topic>.md`, add an entry with the file path, topic, type (how-it-works | module), and date.
- If **updating** an existing spec, bump the version or update the date to reflect the revision.

## Reverse Engineering Template

```markdown
# System Analysis: <feature/subsystem name> (Date: <YYMMDD>)

## Scope

- **Analyzed functionality**:
- **Out of scope**:

## Entry Points

- **API / UI / CLI**:
- **Background triggers**:
- **Tests**:

## Data Flow Trace
```

<entry> → <component A> → <component B> → ... → <output>

```

### Step-by-step
1. <step description> — file:path:line
2. <step description> — file:path:line
...

### Error paths
- <failure mode> → <handling behavior>

## Components & Responsibilities
| Component | Path | Responsibility |
|-----------|------|----------------|
|           |      |                |

## Interfaces & Contracts
### Internal Interfaces
| Interface / Function | Contract | Callers |
|----------------------|----------|---------|
|                      |          |         |

### External Interfaces
| System | Operation | Schema / Shape |
|--------|-----------|----------------|
|        |           |                |

### Shared Data Structures
| Type | Fields | Notes |
|------|--------|-------|
|      |        |       |

## Dependencies
| Dependency | Usage | Configuration |
|------------|-------|---------------|
|            |       |               |

## Tests & Verification
| Test File | Type | Coverage |
|-----------|------|----------|
|           |      |          |

### Coverage gaps
- <gap description>
```

## Best Practices

- **Trace, don't assume** — verify each step by reading the actual code, not by guessing. Cite file paths and line numbers.
- **One feature per document** — each document covers a single cohesive functionality. Split if the flow branches into independent subsystems.
- **Date everything** — use YYMMDD format so files sort chronologically.
- **Update on significant changes** — when the implementation of the analyzed functionality changes substantially, update the document rather than creating a new one. It is a living reference.
- **Include line numbers** — reference specific lines for interfaces, contracts, and branching logic to make verification fast.
- **Update system.md** - consider if system.md should refer to the added analysis, but keep it in the high level.

## File Naming Conventions

- Research: `system_YYMMDD_<how-it-works-topic or module-name>.md` → `.agents/specs/`
