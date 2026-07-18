---
name: commit-design
description: Procedures for formally recording and tracking design decisions after user selection.
license: MIT
---

# Skill: commit-design

## Purpose

After the **explore-design-options** skill produces design options and the user selects one, this skill formally records the decision in the design-options file.

```
explore-design-options ──> commit-design
   (generate options)       (record decision)
```

## When to Use

After the user has explicitly chosen an option from a design-options file produced by `explore-design-options`.

## Procedure

### 1. Identify the Design-Options File

If it is not clear from context which design-options file is under discussion, **ask the user to specify the file path** (e.g., `.agents/design-options/design-option_YYMMDD_<topic>.md`).

### 2. Confirm the User's Choice

Ensure the user has explicitly selected a specific option (e.g., "Option B") before proceeding.

### 3. Update the Design-Options File

Append a **Selected Option** section to the design-options file:

```markdown
## Selected Option

- **Option**: <Option Letter/Name> — <Option Title>
- **Selected By**: <agent name> (<LLM model>, e.g., opencode/nemotron-3-ultra)
- **Timestamp**: <ISO 8601 timestamp>
- **User**: <system username if available>
- **Rationale**: <brief rationale — especially if different from the original recommendation in explore-design-options>
- **Reference**: <link or reference to the explore-design-options output that produced the options>
- **Spec Update Plan**: <bullet list of spec files that need updating and what changes are needed, e.g.:
  - product.md: add user story X.Y
  - system.md: architecture section Z
  - spec-index.json: add entry for new module>
```

This section records the *actual* decision, its rationale (which may differ from the original recommendation), and a **plan for spec updates** — but does **not** perform the spec updates.

### 4. Commit the Decision

```bash
# Stage all changes
git add .agents/design-options/  # the updated design-options file

# Commit with a descriptive message
git commit -m "docs: record design decision for <topic>

- Generated options using explore-design-options skill
- Selected: <option> - <name>
- Rationale: <brief rationale>"
```

### 5. Verify

- Confirm the commit was created successfully
- Confirm the design-options file contains the Selected Option section with Spec Update Plan

## Workflow Integration

```
explore-design-options ──> commit-design ──> create-plan ──> implement-plan
   (generate options)       (record decision)   (plan specs)    (update specs)
```

The `commit-design` skill only records the decision in the design-options file and includes a **Spec Update Plan**. The actual spec updates are handled by `create-plan` (which references the plan) and `implement-plan` (which executes it).