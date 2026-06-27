# codewiser

A **multi-agent AI development framework** — a reusable skills-and-specs system for running multiple AI coding agents (OpenCode, Claude Code, Cursor, Antigravity, Kilo Code) on the same repository with **shared context, shared skills, and a spec-driven execution protocol**.

## Problem

When multiple AI coding agents work on the same codebase, each agent has its own private config, instructions, and context. Work done by one agent is invisible to the next, leading to context loss, duplicated effort, and conflicting changes.

## Solution

A centralized `.agents/` directory and a universal `AGENTS.md` instruction file that every agent reads. Agents use a **spec-driven protocol**: before modifying code, they read product and system specs to ensure alignment. If the design changes, specs are updated first.

```
.agents/
├── skills/           # What agents can do (commands/capabilities)
│   ├── bootstrap/    #   Project initialization
│   ├── create-brd/   #   Business requirements docs
│   ├── create-plan/  #   Task planning
│   ├── create-ux-specs/   #   UX specifications
│   ├── design-db/    #   Database schema design
│   ├── git-worktrees/#   Branch & worktree isolation
│   ├── implement-plan/    #   Code implementation
│   └── research/     #   Architecture decision records
├── specs/            # What agents are building (system & product architecture)
│   ├── product.md    #   User stories, acceptance criteria, business logic
│   ├── product_<brd>.md    #   Domain-scoped business requirements (for larger projects)
│   ├── ux.md         #   Design system, personas, UX requirements
│   ├── system.md     #   Architecture, component boundaries, schemas
│   ├── system_<module>.md  #   Module-scoped system specs (for larger projects)
│   └── spec-index.json
├── plans/            # How agents execute tasks (short-term context)
└── research/         # Why architectural decisions were made (ADRs)
```

## Quick Start

```bash
# 1. Run the interactive setup script with a target directory
./codewiser-init.sh ./my-project

# 2. Select your AI agents (OpenCode, Claude Code, Cursor, etc.)
#    The script downloads the latest AGENTS.md, skills, and spec
#    templates from GitHub, creates agent-specific configs, and
#    symlinks skills into each agent's private config directory.

# 3. Start coding — agents read shared context from AGENTS.md,
#    load skills from .agents/skills/, and follow spec-driven protocol.
```

On Windows (PowerShell):

```powershell
.\codewiser-init.ps1 .\my-project
```

## Supported Agents

| Agent | Config File | Integration |
|---|---|---|
| **OpenCode** / MiMo / Crush | `opencode.json` | References `.agents/skills/**/SKILL.md` and `AGENTS.md` |
| **Claude Code** | `CLAUDE.md` | `@include AGENTS.md`, symlinked skills at `.claude/skills/` |
| **Cursor** | `.cursor/` | Symlinked skills at `.cursor/skills/` |
| **Antigravity** | `.antigravity/workflows.json` | Workflows reference shared `.agents/skills` |
| **Kilo Code** | `.kilo/config.json` | References `AGENTS.md` and `.agents/skills/*/SKILL.md` |

## Spec-Driven Workflow

1. **Read specs** — Before writing code, agents read `.agents/specs/product.md` and `.agents/specs/system.md`
2. **Git Worktrees first** — Create an isolated feature branch/worktree before planning and spec changes (see [git-worktrees skill](.agents/skills/git-worktrees/SKILL.md))
3. **Update specs first** — If an implementation changes the design, update specs before writing production code
4. **Document decisions** — Architecture rationale goes in `.agents/research/` as ADRs
5. **Plan execution** — Task breakdowns go in `.agents/plans/` (naming: `plan_YYMMDD_<name>.md`)

## Adding a New Skill

Skills are shared across all agents. Create a file at `.agents/skills/<skill-name>/SKILL.md` with instructions for what the skill does. Then add it to the relevant workflow stage's `files` section in `manifest.json` with an initial version. The setup script symlinks this directory into each agent's private config so every agent can load it.

Example: the [git-worktrees skill](.agents/skills/git-worktrees/SKILL.md) was added to teach agents how to isolate feature work using branches and worktrees during concurrent multi-agent development.

## Setup Scripts

| Platform | Script | Source |
|---|---|---|
| Linux / macOS | `codewiser-init.sh` | Downloads `AGENTS.md`, skills, and specs from `https://github.com/yallma3/codewiser` |
| Windows | `codewiser-init.ps1` | Same logic via PowerShell with `Invoke-WebRequest` |

Both scripts use `manifest.json` to track artifact versions organized by workflows and stages. During setup, you select which AI agents and which workflows (e.g., frontend, backend) to install. Only files from the selected workflows' stages are downloaded.

## Requirements

- Bash **or** PowerShell 5+
- Git

## License

MIT — see [LICENSE](LICENSE). Copyright (c) 2026 AssemHassan.
