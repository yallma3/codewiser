# Plan: Workflow-Scoped Skills Restructure (Date: 270626)
- **Agent**: OpenCode
- **LLM**: big-pickle
- **Reference**: User request to isolate skills per workflow (frontend/backend)

## Goal
Restructure skills directory so selecting "frontend" workflow only installs frontend-relevant skills, and "backend" only backend-relevant skills.

## Current State
All skills live flat under `.agents/skills/`. Both workflows in `manifest.json` reference the same files. Agent configs use `**/SKILL.md` which picks up everything.

## Phases

### Phase 1: Restructure skills directory
- **Risk**: medium
- **Complexity**: medium
- **Gate**: `ls .agents/skills/*/`
- **Steps**:
  - Create `shared/`, `frontend/`, `backend/` dirs under `.agents/skills/`
  - Move bootstrap, create-brd, create-plan, implement-plan, research, commit-research, git-worktrees → `shared/`
  - Move create-ux-specs → `frontend/`
  - Move design-db → `backend/`
- **Files affected**: All skills under `.agents/skills/`
- **Deliverable**: Skills organized in scoped directories

### Phase 2: Update manifest.json (root + interactive)
- **Risk**: medium
- **Complexity**: low
- **Gate**: `python3 -c "import json; json.load(open('manifest.json'))"`
- **Steps**:
  - Update file paths in `manifest.json` to reflect new directory structure
  - Assign shared skills to both workflows, frontend skills only to frontend, backend skills only to backend
  - Repeat for `interactive/.agents/manifest.json`
- **Files affected**: `manifest.json`, `interactive/.agents/manifest.json`
- **Deliverable**: Each workflow lists only its relevant files

### Phase 3: Update setup script agent config generation
- **Risk**: medium
- **Complexity**: medium
- **Gate**: `bash codewiser-init.sh /tmp/test-codewiser 2>&1 | head -20`
- **Steps**:
  - Make generated `opencode.json` reference workflow-scoped skill paths based on selected workflows
  - Other agent configs (CLAUDE.md, etc.) should similarly scope
- **Files affected**: `codewiser-init.sh`
- **Deliverable**: Generated configs only point to installed skill directories

### Phase 4: Update system spec
- **Risk**: low
- **Complexity**: low
- **Gate**: File reads correctly
- **Steps**:
  - Document the new `.agents/skills/{shared,frontend,backend}/` structure in `system.md`
- **Files affected**: `.agents/specs/system.md`
- **Deliverable**: Spec reflects new architecture

## Success Criteria
- Selecting only "frontend" workflow downloads: shared/ + frontend/ skills, NOT backend/ skills
- Selecting only "backend" workflow downloads: shared/ + backend/ skills, NOT frontend/ skills
- Selecting both downloads everything
- Generated agent configs only reference the directories that were actually installed

## Risks
- Moving skill files could break external references if anyone has hardcoded paths (but this is the source repo, consumers download via manifest)
- The `interactive/` copy must stay in sync with root

## Resumption Notes
- Last completed phase:
- Next step to start: Phase 1
