# System Architecture

## Overview

The codewiser framework uses a **workflow-scoped skills** architecture. Skills are organized into three directories under `.agents/skills/`:

- **`shared/`** — Workflow-agnostic skills available to all workflows (bootstrap, create-brd, create-plan, implement-plan, analyze, commit-research, git-worktrees)
- **`frontend/`** — Frontend-only skills (create-ux-specs)
- **`backend/`** — Backend-only skills (design-db)

## Workflow Selection

The `manifest.json` defines which files belong to each workflow. The setup script (`codewiser-init.sh`) downloads only the files from selected workflows and generates agent configs that reference only the installed skill directories.

### Frontend workflow
- Shared skills + frontend/create-ux-specs

### Backend workflow
- Shared skills + backend/design-db

## Setup Script Flow

1. User selects agents (OpenCode, Claude Code, etc.)
2. User selects workflows (frontend, backend, or both)
3. Script computes deduplicated skill directory list from selected workflows
4. Script downloads files from selected workflows' stages
5. Script generates agent configs with paths scoped to installed skill directories

## Component Boundaries

- `.agents/skills/{shared,frontend,backend}/` — Skill definitions (SKILL.md files)
- `.agents/specs/` — Product and system specifications
- `.agents/plans/` — Task execution plans
- `.agents/research/` — Architecture Decision Records (ADRs)
