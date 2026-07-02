---
name: create-plan
description: Guidelines for planning tasks and creating plans. Use when starting a new task, breaking down work, or defining verifiable goals before implementation. Status tracking is handled by the implementation skill.
license: MIT
---

# Planning Guidelines

## 1. Plan Requirements

- **Incremental**: Each phase must be completable in a single session.
- **Verifiable per step**: Every step must have a concrete verification command.
- **Gated**: After every step, verify gates pass (e.g., `npm run lint && npm test` or project-equivalent).
- **Self-contained**: Include enough context for a different agent to continue.
- **Reference tracking**: Every plan must reference the related requirement, feature, user story, bug fix, or PR that drives the work. Link to the source when possible.
- **Status tracking**: After any work on a plan, a status file should be created or updated (handled by the implementation skill).
- **Risk & complexity labeling**: Every phase, step, or file-change must label its risk level (low/medium/high) and complexity (low/medium/high).

## 2. Plan Template

```markdown
# Plan: <title> (Date: <YYMMDD>)
- **Agent**: <tool/agent name>
- **LLM**: <model name>
- **Reference**: <requirement/feature/user-story/bug/PR link or description>

## Goal
Single sentence describing what this plan achieves.

## Current State
What exists now, what gaps exist.

## Phases
### Phase N: <name>
- **Risk**: low/medium/high
- **Complexity**: low/medium/high
- **Gate**: <lint + test command>
- **Steps**:
  - Step 1 — `[verify: <command>]`
  - Step 2 — `[verify: <command>]`
- **Files affected**: `path/to/file.ext`
- **Deliverable**: What "done" looks like

## Success Criteria
- Measurable outcomes.

## Risks
- Anything that could block.

## Resumption Notes
- Last completed phase:
- Next step to start:
```

## 3. File Naming Conventions

- Plans: `plan_YYMMDD_<short-name>.md` → `.agents/plans/`
- Research: `research_YYMMDD_<topic>.md` → `.agents/research/`
- Status: `status_YYMMDD_<subject>.md` → `.agents/status/`
- Never delete old plans — the implementation skill adds status reports alongside.
