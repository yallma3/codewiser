---
name: explore-design-options
description: Structured exploration of design options from spec-based baseline analysis to solution option generation and evaluation.
license: MIT
---

# Skill: explore-design-options

## Purpose

Structured exploration of architectural options — from spec-based baseline analysis through option generation and evaluation — before making design decisions.

## When to Use

Before making architectural decisions, when:

- Before implementing a new feature
- Before performing refactoring that spans multiple files or modules
- A problem has multiple valid approaches
- Creative solutions are needed beyond obvious choices

## Process: Structured Options Exploration

### 1. Clarify Request & Define Problem

Frame the core problem clearly while ensuring the request is well-understood and actionable:

- **Ask clarifying questions** — What exactly needs to be done? What is the scope? What motivated this request? Is there a specific problem, or is this exploratory?
- **Problem statement** — A concise, user-centered problem definition.
- **Design parameters** — Explicitly define the key design dimensions that will differentiate options (e.g., read vs write optimization, coupling vs cohesion, flexibility vs simplicity). Use expertise to suggest parameters the user may not have considered.
- **Agreed constraints** — The finalized set of constraints after discovery, discussion, and narrowing. These bound the solution space (e.g., time, budget, technology, compatibility limitations).
- **Success criteria** — How will we know a solution is good? Be specific and measurable where possible.
- **Stop if nothing to do** — If the request is already satisfied, out of scope, or not actionable, clearly state why and stop. Do not proceed unless there is a real design decision to be made.
- **Confirm understanding** — Summarize the request back to the user and confirm alignment before proceeding.

### 2. Establish Baseline & Target

Clarify the change from the current state to the desired state:

- **Read current specs** — Review `README.md` and `.agents/specs/product.md` and `.agents/specs/system.md` (and any `system_<area>.md` relevant to the domain) to understand the project conventions, current architecture, contracts, and product context.
- **Capture Design Concept** — If `system.md` specifies a "Design Concept" section, record it. The Design Concept informs the Design Parameters in Step 3.
- **Define the baseline** — Summarize the relevant current state; reference specific spec sections.
- **Define the design goal** — Articulate the target state: what specific problem is being solved, what new capability is needed, or what improvement is sought. This is the "to-be" state.
- **Identify the gap** — What changes are needed to move from baseline to target? These are the dimensions along which options will be evaluated.

### 3. Identify Scope, Constraints & Design Parameters

Understand what is in scope and what bounds the decision:

- **Scope** — Identify the personas affected, other systems involved, and the relevant features, modules, and components of this system that are in scope.
- **Discover Design Parameters** — Use the Design Concept (captured in Step 2) as a foundation to derive concrete Design Parameters — measurable criteria that will evaluate options. Supplement with software design expertise to surface relevant parameters from the problem space. Consider and ask the user about: scalability, performance, maintainability, security, operability, cost, time-to-market, team skills, technology maturity, integration complexity, and compliance requirements. This is an open-ended discovery pass — not all will make the final cut.
- **Agent expert opinion** — Do not passively collect Design Parameters. Apply expert judgment: point out missing or implicit constraints, challenge assumptions, and recommend which Design Parameters matter most for this specific context. If the user's stated constraints or Design Parameters conflict, flag the tension.

### 4. Generate & Specify Options

Generate top 2-3 distinct approaches that achieve the goal (defined in Step 1), then document each:

**Simplicity First** — Bias toward simpler options during generation:
- Prefer approaches with fewer new abstractions, modules, or dependencies.
- If an option introduces configurability or flexibility that wasn't explicitly requested, flag it as a cost, not a feature.
- A simpler option that mostly works is better than an elegant one that requires new infrastructure.
- If an option feels over-engineered for the stated problem, simplify it or drop it.

```markdown
### Option <letter>: <name>

- **Approach**: How it works
- **Pros**: Advantages specific to this project and specified Design Parameters
- **Cons**: Disadvantages, trade-offs, risks, Design Parameters
- **Fit**: Alignment with existing architecture
- **Impact**: Change scope, including affected components, functions/methods and files
```

### 5. Evaluate Options

Score each option (1-5) against the following weighted criteria:

| Criterion | Weight | Description |
|-----------|--------|-------------|
| Technical feasibility | 25% | Ensure achieving the goal with minimal effort |
| Design parameters fit | 25% | Balance the design options against chosen design dimensions (derived from Design Concept) |
| Keeping things simple | 10% | Favor simplicity and clarity |
| Reduce dependencies | 10% | Minimize external and internal coupling |
| Following software design best practices | 10% | Adhere to established patterns and principles |
| Effort/cost to implement | 10% | Resource and time requirements |
| Risks and side effects | 10% | Potential negative consequences and mitigation |

**Design parameters fit** — How well does each option satisfy the chosen design dimensions (derived from Design Concept)? This implicitly ensures alignment with the Design Concept.

### 6. Recommend

Recommend an option based on the evaluation, explicitly referencing how it fits the design parameters and why it outperforms alternatives on the general criteria. Acknowledge trade-offs. Present all options for the user to review. The user makes the final decision — they may accept the recommendation or select another. After a choice is made, use **commit-design** to record the decision.

## Output

A self-contained design options document saved to `.agents/design-options/design-options_YYMMDD_<topic>.md` containing:

### YAML Header

```markdown
---
purpose: "<explicit purpose>"
agent: "<agent name>"
llm: "<model name>"
date: "<YYMMDD>"
ticket: "<optional ticket or issue reference>"
---
```

### Document Sections

- **Context** — baseline (from specs), design goal, gap analysis
- **Options** — structured Option A, B, C... with approach, pros, cons, and fit
- **Evaluation** — assessment of each option against the chosen design parameters, plus general criteria (feasibility, simplicity, dependencies, best practices, effort, risk)
- **Recommendation** — recommended option with rationale referencing design parameters and trade-offs acknowledged
