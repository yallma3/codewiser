# code-agent-setup-files

A **multi-agent AI development framework bootstrapper** — scaffolding and setup tooling for running multiple AI coding agents (OpenCode, Claude Code, Cursor, Antigravity, Kilo Code) on the same repository with **shared context, shared skills, and a spec-driven execution protocol**.

## Problem

When multiple AI coding agents work on the same codebase, each agent has its own private config, instructions, and context. Work done by one agent is invisible to the next, leading to context loss, duplicated effort, and conflicting changes.

## Solution

A centralized `.agents/` directory and a universal `AGENTS.md` instruction file that every agent reads. Agents use a **spec-driven protocol**: before modifying code, they read product and system specs to ensure alignment. If the design changes, specs are updated first.

```
.agents/
├── skills/           # What agents can do (commands/capabilities)
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
# 1. Run the interactive setup script
./setup.sh

# 2. Select your AI agents (OpenCode, Claude Code, Cursor, etc.)
#    The script creates the .agents/ directory structure, writes
#    agent-specific configs, and symlinks skills into each agent's
#    private config directory.

# 3. Start coding — agents read shared context from AGENTS.md,
#    load skills from .agents/skills/, and follow spec-driven protocol.
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
2. **Update specs first** — If an implementation changes the design, update specs before writing production code
3. **Document decisions** — Architecture rationale goes in `.agents/research/` as ADRs
4. **Plan execution** — Task breakdowns go in `.agents/plans/` (naming: `plan_YYMMDD_<name>.md`)

## Adding a New Skill

Skills are shared across all agents. Create a file at `.agents/skills/<skill-name>/SKILL.md` with instructions for what the skill does. The setup script symlinks this directory into each agent's private config so every agent can load it.

## Requirements

- Bash shell
- Git

## License

MIT — see [LICENSE](LICENSE). Copyright (c) 2026 AssemHassan.
