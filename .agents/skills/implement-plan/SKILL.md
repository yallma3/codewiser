---
name: implement-plan
description: Guidelines for writing, reviewing, and refactoring code. Use when implementing features, fixing bugs, or making changes to reduce common mistakes and ensure alignment with plans.
license: MIT
---

# Implementation Guidelines

Derived from [Andrej Karpathy's observations](https://x.com/karpathy/status/2015883857489522876) on LLM coding pitfalls. These bias toward caution over speed — for trivial tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

- State assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them — don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it — don't delete it.
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the request.

## 4. Verification & Retry

**Responsible for executing verification criteria defined in the plan. Iterate until all gates pass.**

- Run the verification commands specified in each plan phase step (e.g., `npm run lint && npm test`).
- If verification fails, diagnose the issue, fix it, and retry.
- Retry up to **5 times** by default unless the plan specifies a different limit.
- If all retries are exhausted without passing, stop and document the failure in the status file.

## 5. Update Specs on Success

**After all verification gates pass, update the spec files to reflect what was built.**

- Update `.agents/specs/spec-index.json` — add an entry linking the implemented source files to their test files and the plan that drove the work.
- Update `.agents/specs/product.md` if the implementation added, removed, or changed any user-facing behavior, acceptance criteria, or business logic.
- Update `.agents/specs/system.md` and any related `.agents/specs/system_*<topic>*.md` files to reflect architectural changes, new modules, data model additions, or dependency changes — follow the specific update instructions defined in the plan's spec-update section.

## 6. Read the Project Conventions

**Before writing any code, read `README.md` to understand:**

- Language and framework choices
- Coding standards and style
- Project-specific patterns and constraints
- Available scripts (lint, test, build, typecheck)

If the README references other documentation files, read those too. Your implementation must match the project's established conventions.

## 7. Plan Integration

**Every implementation must be traceable to a plan.**

- Reference the related plan file by path (e.g., `.agents/plans/plan_YYMMDD_<name>.md`).
- Include the plan reference in commit messages and status updates.
- If no plan exists for the work, create one first using the planning skill.

## 8. Track Status

**After completing any implementation phase, update the plan's status.**

- Create or update a status file at `.agents/status/status_YYMMDD_<subject>.md`.
- Document what was completed, what was deferred, and any deviations from the plan.
- Record the agent and LLM model used.

## 9. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```
