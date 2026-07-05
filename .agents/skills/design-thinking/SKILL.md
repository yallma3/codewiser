---
name: design-thinking
description: Design thinking methodology and practices for generating solution options.
license: MIT
---

# Skill: design-thinking

## Purpose

Use design thinking methodology to systematically explore solution options before making architectural decisions. This skill feeds into the **analyze** skill by generating the "Alternatives & Options" section of an ADR.

## When to Use

Before or during the **analyze** research phase, when:
- A problem has multiple valid approaches
- User needs are unclear or complex
- Creative solutions are needed beyond obvious choices
- The team needs to converge on a shortlist of viable options

## Design Thinking Process for Options Generation

### 1. Empathize
Understand the stakeholders and users affected by the decision:
- Who is impacted by this change?
- What are their pain points, goals, and constraints?
- Gather input from relevant team members

### 2. Define
Frame the core problem clearly:
- **Problem statement**: A concise, user-centered problem definition
- **Constraints**: Time, budget, technology, compatibility limitations
- **Success criteria**: How will we know a solution is good?

### 3. Ideate
Brainstorm solution approaches. Generate at least 2-3 distinct options:
- Diverge — list all possible approaches without judgment
- Categorize — group related ideas
- Converge — select the most viable distinct approaches

### 4. Prototype (Options Specification)
For each selected option, document:
```markdown
### Option <letter>: <name>
- **Approach**: How it works
- **Pros**: Advantages specific to this project
- **Cons**: Disadvantages, trade-offs, risks
- **Fit**: Alignment with existing architecture
```

### 5. Test (Evaluate)
Evaluate each option against:
- Technical feasibility
- Alignment with project goals and architecture
- Effort/cost to implement
- Risks and side effects

## Output

A structured set of options (Option A, B, C...) ready to be inserted into the **analyze** ADR's "Alternatives & Options" section. Present the options to the user for selection.

## Workflow Integration

```
design-thinking ──> analyze ──> commit-design
(generate options)   (document ADR)   (record decision)
```

After this skill produces options, proceed to the **analyze** skill to produce the full ADR, then use **commit-design** to record the chosen option.
