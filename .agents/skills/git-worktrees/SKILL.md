---
name: git-worktrees
description: Guidelines for using Git worktrees and branch management to isolate feature work in the spec-driven workflow.
license: MIT
---

# Git Worktrees & Branch Management

## Purpose

Keep feature work isolated and reviewable by using Git branches and worktrees for each independent task or agent-driven effort. This prevents spec, plan, and code changes from mixing across concurrent tasks.

## When to use

- Starting a new feature or bugfix
- Working in parallel on multiple plans
- Preserving a clean main/develop branch
- Reviewing spec-driven changes before merge

## Procedure

1. Identify the base branch for the task (`main`, `develop`, etc.).
2. Create a feature branch:
   - `git checkout -b feature/<short-name> <base-branch>`
3. If you need multiple working copies, create a worktree:
   - `git worktree add ../<short-name> feature/<short-name>`
4. Make all spec, plan, and implementation updates inside that branch or worktree.
5. Commit frequently with clear messages referencing the plan or research documents.
6. When ready, merge through the repository's normal review process.

## Best Practices

- Use one branch/worktree per task or feature.
- Keep unrelated changes off the branch.
- Record the branch name in plan metadata if helpful.
- Avoid modifying the same `.agents/` spec files from multiple concurrent branches without coordination.
- If a branch diverges, rebase or merge sensible updates from the base before finalizing.

## Branch naming

Prefer descriptive, consistent names:

- `feature/<domain>-<short-name>`
- `fix/<short-name>`
- `research/<topic>`
- `chore/<cleanup>`

## Worktree notes

- Worktrees share the same repository object store, so they are lightweight.
- Use worktrees to keep multiple tasks open simultaneously without switching branches in one checkout.
- Clean up worktrees after merge:
  - `git worktree remove ../<short-name>`
