---
name: create-ux-specs
description: Guidelines for producing UX specifications. Use when designing or documenting user experience, design systems, personas, and information architecture for the project.
license: MIT
---

# UX Specs Guidelines

## Purpose

The `ux.md` spec defines the user experience vision for the product — who the users are, how they interact with the system, and the design principles that guide those interactions. It serves as the single source of truth for all UX decisions.

## Procedure

### 1. Read Existing Specs

Before creating UX specs, read:
- `.agents/specs/product.md` — understand user stories and acceptance criteria
- `.agents/specs/system.md` — understand architecture constraints, interfaces, and database schemas (column types, row volumes, and entity relationships inform UI patterns like pagination, infinite scroll, or search)
- Existing BRDs (`.agents/specs/product_<domain>.md`) — identify new features or domains that introduce UX gaps not yet covered in `ux.md`
- `.agents/specs/ux.md` — check for existing UX decisions to avoid duplication

### 2. Ask Questions for Gaps

Interview the user to fill in unknowns. Only ask what isn't already clear from the existing specs.

#### Personas

- Who are the primary user groups? (roles, goals, technical proficiency)
- What is each persona's environment? (desktop, mobile, kiosk, offline)
- What are their pain points with current solutions?
- What are the accessibility requirements? (WCAG level, screen reader support, keyboard navigation)
- What languages/locales must be supported?

#### Design System

- Does an existing design system or component library exist? (name, version, link)
- What UI framework is used? (e.g., Material Design, Ant Design, Shadcn, Tailwind, custom)
- What visual brand assets exist? (colors, typography, logo, icons)
- Are there brand guidelines or style guides to follow?
- What are the core interactive components? (buttons, forms, tables, modals, navigation, etc.)
- What are the spacing, grid, and layout conventions?

#### Information Architecture

- What are the main sections or modules of the application?
- What is the navigation structure? (top-level, nested, contextual)
- What is the content hierarchy? (landing → feature → detail → action)
- How do users search, filter, or browse content?
- What are the key user flows? (onboarding, core task, error recovery)
- What data is displayed on each screen? (tables, charts, cards, lists)
- What forms or data entry points exist? (fields, validation, submission)
- What error, empty, and loading states exist for each screen?

Consider how **information volume** from the database schema impacts UX decisions:
- High row counts → pagination, infinite scroll, or search-based discovery
- Large text/BLOB data → lazy loading, expandable sections, or download patterns
- Frequent updates → real-time indicators, polling intervals, or push notifications
- Multi-tenant data → permission-aware navigation, scoped search, filtered lists

#### UX Requirements per Persona

- What are the top 3 tasks each persona must complete?
- What is the acceptable time or number of steps for each task?
- What feedback does each persona need after an action? (toast, notification, email)
- What are the must-have vs nice-to-have features per persona?

### 3. Define the Design System Section

Document the design system decisions:

- **Design tokens** — color palette (primary, secondary, accent, semantic), typography scale (headings, body, mono), spacing scale, border radii, shadows, breakpoints
- **Component library** — list of shared components, their states (default, hover, active, disabled, error), usage rules
- **Layout patterns** — page layout (sidebar, top nav, centered), responsive behavior (mobile, tablet, desktop), grid system
- **Motion & animation** — transition durations, easing curves, allowed motion types (parallax, loading, page transitions)
- **Accessibility** — minimum contrast ratios, focus indicators, aria patterns, reduced motion support

### 4. Define the Information Architecture Section

Document the structural decisions:

- **Site map** — hierarchy of all screens/routes, parent-child relationships
- **Navigation model** — main navigation, secondary navigation, breadcrumbs, contextual links
- **Content types** — page templates (landing, detail, form, list, dashboard), reusable content patterns
- **Search & discovery** — search scope, filter taxonomy, sort options, result display
- **User flows** — step-by-step paths for each major persona goal, including happy path, edge cases, and error recovery

### 5. Create Persona Profiles

For each persona, document:

- **Name & role** — identifier and job title
- **Technical proficiency** — beginner / intermediate / expert
- **Goals** — what they need to accomplish
- **Pain points** — current frustrations
- **Environment** — device, browser, connectivity, location
- **Frequency** — daily / weekly / monthly / occasional use
- **Key tasks** — the critical workflows they perform
- **Accessibility needs** — specific accommodations required

### 6. Capture Artifact Links

Collect links to online tools where UX artifacts are hosted:

- **Design files** — Figma, Sketch, or Adobe XD links to wireframes, mockups, prototypes
- **User research** — survey results, interview notes, analytics dashboards, usability test recordings
- **Design system** — component library documentation (Storybook, Zeroheight), brand guidelines, icon repositories
- **Collaboration boards** — Miro, Mural, or Notion boards with user flows, journey maps, or brainstorming
- **Prototypes** — clickable prototype links (Figma, InVision) for each key user flow

These links become part of `ux.md` so they are discoverable by all agents.

### 7. Write `ux.md`

Structure the output as:

```markdown
# UX Specifications

## Design System
- **Design tokens**: ...
- **Component library**: ...
- **Layout patterns**: ...
- **Motion & animation**: ...
- **Accessibility**: ...

## Information Architecture
- **Site map**: ...
- **Navigation model**: ...
- **Content types**: ...
- **Search & discovery**: ...
- **User flows**: ...

## Personas
### Persona 1: <name>
- **Role**: ...
- **Technical proficiency**: ...
- **Goals**: ...
- **Pain points**: ...
- **Environment**: ...
- **Frequency**: ...
- **Key tasks**: ...
- **Accessibility needs**: ...

### Persona 2: <name>
- ...

## Artifacts
- **Design files**: [Figma](link) | [Storybook](link)
- **User research**: [Survey results](link) | [Analytics](link)
- **Prototypes**: [Onboarding flow](link) | [Checkout flow](link)

## Change Log
- **YYYY-MM-DD**: Initial UX spec. (Reference: <BRD or plan>)
```

## Best Practices

- **Start from real research** — prefer user interviews, analytics data, or stakeholder input over assumptions. Document the source of each decision.
- **One persona per distinct role** — avoid creating personas that differ only in name. Each should have unique goals and workflows.
- **Define states upfront** — for every component and screen, define loading, empty, error, and edge case states. Don't leave them to implementation.
- **Keep design system independent of implementation** — document design intent (e.g., "primary action button is bold and full width on mobile") rather than binding to a specific framework class.
- **Use examples** — include wireframes, mock references, or competing product patterns to clarify intent.
- **Prioritize by persona** — label features and requirements by which persona they serve, so trade-off decisions are clear.
- **Review with stakeholders** — validate personas and flows with actual users or domain experts before finalizing.
- **Version the spec** — note changes over time with date, scope, and reference in the Change Log section when creating or updating `ux.md`.
