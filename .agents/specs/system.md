# System Architecture

## Overview

The codewiser framework uses a **workflow-scoped skills** architecture. Skills live flat under `.agents/skills/<skill-name>/` and are categorized by naming convention:

- **No prefix (shared)** — Workflow-agnostic skills available to all workflows: `bootstrap`, `create-brd`, `create-plan`, `implement-plan`, `analyze`, `design-thinking`, `commit-design`, `commit-research`, `git-worktrees`
- **`frontend-*`** — Frontend-only skills: `frontend-create-ux-specs`
- **`backend-*`** — Backend-only skills: `backend-design-db`
- **`testdriven-*`** — Test-driven development skills: `testdriven-test-infrastructure`, `testdriven-test-fixtures`, `testdriven-test-doubles`

## Workflow Selection

The `manifest.json` defines which files belong to each workflow. The setup script (`codewiser-init.sh` / `codewiser-init.ps1`) downloads only the files from selected workflows and generates agent configs that reference only the installed skill directories.

### Frontend workflow
- Shared (no-prefix) skills + frontend-create-ux-specs

### Backend workflow
- Shared (no-prefix) skills + backend-design-db

### Testdriven workflow
- Shared (no-prefix) skills + testdriven-test-infrastructure, testdriven-test-fixtures, testdriven-test-doubles

## Setup Script Flow

1. User selects agents (OpenCode, Claude Code, etc.)
2. User selects workflows (frontend, backend, testdriven, or any combination)
3. Script flattens selected workflows into a deduplicated file set from their manifest stages
4. Script downloads files from selected workflows' stages
5. Script generates agent configs with paths scoped to installed skill directories

## Component Boundaries

- `.agents/skills/<skill-name>/` — Skill definitions (SKILL.md files)
- `.agents/specs/` — Product and system specifications
- `.agents/plans/` — Task execution plans
