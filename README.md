# codewiser

An **agentic skills framework & software development flows** system — a reusable skills-and-specs platform for AI coding agents (OpenCode, Claude Code, Cursor, Antigravity, Kilo Code) that enforces **spec-driven development** through shared context, composable skills, and mode-tailored execution protocols.

## Philosophy

### 1. Speed must not blur vision

Software development slows down when the team can't tell what needs to change, where it needs to change, and how it should change. Coding agents amplify this risk — they generate code faster than anyone can review, making it easy to lose sight of the bigger picture. Codewiser ensures that **speed does not blur vision**: every change is grounded in explicit specs, plans, and design decisions that are kept in sync with the code.

### 2. Higher-order artifacts are first-class citizens

Specs, plans, design options, architecture decisions — these are not paperwork. They are **first-class artifacts** that must be analyzed, verified, and enhanced just as rigorously as compilable code. A change to the code without a corresponding update to the spec is an incomplete change. Codewiser treats documentation, requirements, and design as code — versioned, reviewed, and kept truthful.

## How It Works

A centralized `.agents/` directory and a universal `AGENTS.md` instruction file that every agent reads. Agents follow a **mode-tailored execution protocol**: depending on the selected mode (Prototype, Spec Driven, Rigid), they read relevant specs, create plans, explore options, and update artifacts before and after every code change.

```
.agents/
├── skills/           # What agents can do (commands/capabilities)
│   ├── shared/       #   Workflow-agnostic skills
│   │   ├── bootstrap/    #   Project initialization
│   │   ├── create-brd/   #   Business requirements docs
│   │   ├── create-plan/  #   Task planning
│   │   ├── git-worktrees/#   Branch & worktree isolation
│   │   ├── implement-plan/    #   Code implementation
│   │   ├── research/     #   Architecture decision records
│   │   └── commit-research/   #   ADR → spec bridge
│   ├── frontend/     #   Frontend-only skills
│   │   └── create-ux-specs/   #   UX specifications
│   └── backend/      #   Backend-only skills
│       └── design-db/    #   Database schema design
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
./codewiser.sh ./my-project

# 2. Select your AI agents and development mode (Prototype, Spec Driven, or Rigid)
#    The script downloads the relevant skills, spec templates, and creates
#    agent-specific configs with symlinks to the shared `.agents/skills/` directory.

# 3. Start coding — agents read shared context from AGENTS.md (customized with your
#    mode's execution protocol), load skills from `.agents/skills/`, and follow the
#    tailored workflow defined by the selected mode.
```

On Windows (PowerShell):

```powershell
.\codewiser.ps1 .\my-project
```

## Supported Agents

| Agent | Config File | Integration |
|---|---|---|
| **OpenCode** / MiMo / Crush | `opencode.json` | References `.agents/skills/**/SKILL.md` and `AGENTS.md` |
| **Claude Code** | `CLAUDE.md` | `@include AGENTS.md`, symlinked skills at `.claude/skills/` |
| **Cursor** | `.cursor/` | Symlinked skills at `.cursor/skills/` |
| **Antigravity** | `.antigravity/workflows.json` | Workflows reference shared `.agents/skills` |
| **Kilo Code** | `.kilo/config.json` | References `AGENTS.md` and `.agents/skills/*/SKILL.md` |

## How a Workflow Runs

The exact workflow depends on the selected mode (Prototype, Spec Driven, or Rigid). In general, every workflow follows this pattern:

1. **Read phase** — Before any code change, agents read the relevant spec files to understand what needs to change and why.
2. **Plan phase** — Work is broken into incremental, verifiable phases.
3. **Explore & commit** — Design options are researched, tradeoffs documented, and decisions recorded in ADRs.
4. **Implement & sync** — Code is written. Specs are updated **before and after** to catch drift.
5. **Verify** — Tests validate the implementation. Specs are updated to reflect what was actually built.

## Adding a New Skill

Skills are shared across all agents. Create a file at `.agents/skills/<skill-name>/SKILL.md` with instructions for what the skill does. Then add it to the relevant workflow stage's `files` section in `manifest.json` with an initial version. The setup script symlinks this directory into each agent's private config so every agent can load it.

Example: the [git-worktrees skill](.agents/skills/shared/git-worktrees/SKILL.md) was added to teach agents how to isolate feature work using branches and worktrees during concurrent multi-agent development.

## Setup Scripts

| Platform | Script | Source |
|---|---|---|
| Linux / macOS | `codewiser.sh` | Downloads `AGENTS.md`, skills, and specs from `https://github.com/yallma3/codewiser` |
| Windows | `codewiser.ps1` | Same logic via PowerShell with `Invoke-WebRequest` |

Both scripts use `manifest.json` to track artifact versions organized by development modes. During setup, you select which AI agents and which mode (**Prototype**, **Spec Driven**, or **Rigid**) to use. The selected mode determines which skills are downloaded and customizes `AGENTS.md` with the appropriate execution protocol.

## Requirements

- Bash **or** PowerShell 5+
- Git

## License

MIT — see [LICENSE](LICENSE). Copyright (c) 2026 AssemHassan.
