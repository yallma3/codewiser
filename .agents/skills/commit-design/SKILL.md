---
name: commit-design
description: Procedures for formally recording and tracking design decisions after user selection.
license: MIT
---

# Skill: commit-design

## Purpose

After the **explore-design-options** skill produces options and the user selects one, this skill formally records the decision — committing it to version control and bridging the ADR into actionable specifications.

## When to Use

After completing the **analyze** ADR and the user has explicitly chosen an option.

## Procedure

### 1. Confirm the User's Choice
Ensure the user has selected a specific option (A, B, etc.) before proceeding.

### 2. Finalize the ADR
Ensure the ADR research document is complete with:
- **Decision section** filled: selected option, rationale, rejected alternatives, impact, risks
- A reference to the user's explicit choice

### 3. Update Specs (Bridge to Actionable Specs)
Update the relevant spec files to reflect the decision:
- `.agents/specs/product.md` — if the decision affects product requirements
- `.agents/specs/system.md` — if the decision affects architecture or design
- `.agents/specs/system_<module>.md` — for module-specific changes
- `.agents/specs/spec-index.json` — update the spec index

Each update should include a reference back to the research document.

### 4. Commit the Decision
```bash
# Stage all changes
git add .agents/specs/  # any updated spec files

# Commit with a descriptive message
git commit -m "docs: record design decision for <topic>

- Researched alternatives using analyze skill
- Generated options using explore-design-options skill
- Selected: <option> - <name>
- Rationale: <brief rationale>"
```

### 5. Verify
- Confirm the commit was created successfully
- Ensure spec files are up to date

## Workflow Integration

```
explore-design-options ──> analyze ──> commit-design
(generate options)   (document ADR)   (record decision)
```

This skill is the final step — it locks in the decision and makes it traceable.
