# Plan: Restructure manifest.json by Workflows (Date: 270626)
- **Agent**: big-pickle
- **Reference**: User request to organize manifest.json by workflows (product-mvp -> ux -> plan -> implement) instead of flat files list

## Goal
Restructure `manifest.json` from a flat `files` dictionary to a `workflows`-based grouping where each workflow has stages containing relevant files, and update both init scripts to parse the new structure.

## Current State
- `manifest.json` has a flat `files` object mapping file paths -> versions
- `codewiser-init.sh` and `codewiser-init.ps1` iterate over `files` to check/update versions
- `get_manifest_version` in bash uses grep-based JSON parsing (fragile)
- Skills live flat in `.agents/skills/<name>/SKILL.md`

## Target State
- `manifest.json` has a `workflows` object where each workflow contains stages (product-mvp, ux, plan, implement), each stage has `files` with per-file versions
- Top-level `version` bumped to `2.0.0`
- Init scripts traverse workflows -> stages -> files using proper JSON parsing
- Skills remain flat on disk; only the manifest grouping changes

## Phases

### Phase 1: Restructure root `manifest.json`
- **Risk**: low
- **Complexity**: medium
- **Gate**: `cat manifest.json | jq '.workflows | keys'` succeeds
- **Steps**:
  1. Rewrite `manifest.json` with `workflows` top-level key containing `frontend` and `backend` workflows
  2. Each workflow has `version`, `description`, and `stages` (product-mvp, ux, plan, implement)
  3. Each stage has `description`, `version`, and `files` (path -> version)
  4. Keep `$schema` and top-level `description` and `version`
- **Files affected**: `manifest.json`
- **Deliverable**: Valid JSON with at least one workflow containing all 4 stages and all existing files assigned to appropriate stages

### Phase 2: Update `codewiser-init.sh`
- **Risk**: medium (bash JSON parsing)
- **Complexity**: high
- **Gate**: `bash codewiser-init.sh /tmp/test-init` completes without error
- **Steps**:
  1. Replace grep-based JSON parsing with `jq` (gracefully fall back if missing)
  2. Change PATH iteration from `files` keys to recursive traversal of `workflows[].stages[].files`
  3. Update `get_manifest_version` to search nested structure
  4. Verify download/overwrite logic still works per-file
- **Files affected**: `codewiser-init.sh`
- **Deliverable**: Init script correctly downloads files listed in the new nested manifest

### Phase 3: Update `codewiser-init.ps1`
- **Risk**: low
- **Complexity**: medium
- **Gate**: PowerShell syntax check with no errors
- **Steps**:
  1. Change iteration from `$remoteManifestObj.files` to nested traversal of `workflows`
  2. Update local manifest reading to match new structure
  3. Verify save logic writes the new structure
- **Files affected**: `codewiser-init.ps1`
- **Deliverable**: PowerShell script correctly reads the new manifest and downloads files

### Phase 4: Sync `my-project/.agents/manifest.json`
- **Risk**: low
- **Complexity**: low
- **Gate**: diff between root and my-project manifests shows identical content
- **Steps**:
  1. Copy restructured `manifest.json` to `my-project/.agents/manifest.json`
- **Files affected**: `my-project/.agents/manifest.json`
- **Deliverable**: Both manifests are in sync

### Phase 5: Update `README.md` and verify
- **Risk**: low
- **Complexity**: low
- **Gate**: `grep -c manifest README.md` matches expected references
- **Steps**:
  1. Update README.md references from "flat files list" to "workflow-based grouping"
  2. Verify manifest.json is valid JSON
- **Files affected**: `README.md`
- **Deliverable**: Documentation reflects new structure

## Success Criteria
- `manifest.json` is valid JSON with workflows structure
- Both init scripts can read the new structure and download files correctly
- No regression in file version-checking logic
- Skills remain on disk at same paths as before

## Risks
- Bash script currently uses grep-based JSON parsing; switching to `jq` adds a dependency. Fallback needed for systems without `jq`.
- If `jq` is unavailable on the remote system, the script should degrade gracefully and print a clear error message.

## Resumption Notes
- Last completed phase:
- Next step to start:
