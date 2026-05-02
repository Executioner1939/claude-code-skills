---
name: add-component
description: Interactive workflow to add a new component to the design system. Asks for the spec (intent, props, states, variants); accepts screenshots, design URLs (Figma / Penpot / Sketch), or written briefs; inventories every existing atom / molecule / organism in the codebase; decides whether the new component is reuse / extend / compose / build-new; spawns specialized subagents to assemble it (component-composer, story-writer, mdx-doc-writer, design-token-enforcer, accessibility-reviewer); and writes the final files. Invoke as `/design-storybook-atomic:add-component`.
disable-model-invocation: true
argument-hint: "[name] [brief|path|url]"
arguments: component_name brief
allowed-tools: Read, Grep, Glob, Bash, Agent, Write, Edit
---

# Add Component

You are walking the user through adding a new component to the design system, end to end. The output is: a fully-classified component, a working implementation, complete CSF Factories / CSF3 stories, an MDX docs page, token-compliant styles, and an a11y review — *or* a clear plan that proves the component already exists or can be assembled from existing parts without new code.

## Phase 0 — Gather the spec

Look at `$component_name` and `$brief`. The brief might be a sentence, a path to a screenshot, a URL to a design tool, or empty.

If the brief is missing or thin, ask the user up to **four** focused questions using the AskUserQuestion tool. Drive toward this minimum spec:

1. **Intent.** What is the component for, in one sentence? Where does it appear?
2. **Atomic level (preliminary).** Is it likely an atom, molecule, organism, template, or page? You'll re-classify after the inventory.
3. **Props / API surface.** What does the user pass in — variants, sizes, states, slots, callbacks?
4. **States.** Default, hover, focus, active, disabled, loading, empty, error, RTL — which apply?
5. **Visual references.** Screenshot path(s), Figma/Penpot/Sketch URL(s), or "no design yet — propose one".
6. **Constraints.** Required tokens to consume, accessibility patterns required (ARIA roles), any framework / styling constraints, theming needs.

If a screenshot path is provided, **read the image** to extract layout, palette mapping, type scale, spacing rhythm. If a Figma URL is provided, ask the user to paste exported tokens or the relevant frame description; you cannot fetch authenticated design URLs directly.

Don't proceed to Phase 1 until you can write down a structured spec. Show the spec to the user and ask "Does this match your intent? (y / n / edit)".

## Phase 1 — Inventory existing components

Spawn `component-cartographer` to inventory **every component** in the codebase, classified by atomic level. Output: a structured map.

Print a one-line summary: "Inventoried N components (A atoms, M molecules, O organisms, T templates, P pages)."

## Phase 2 — Reuse / Extend / Compose / Build decision

Spawn `component-composer` with two inputs: the spec from Phase 0 and the inventory from Phase 1. The composer returns one of four verdicts with evidence:

- **REUSE** — an existing component already does this. Path + props mapping. Stop here, propose the user use it.
- **EXTEND** — an existing component is 80%+ there; a prop / variant / slot addition covers the gap. Propose the prop, the API change, and the migration impact (where else this component is used).
- **COMPOSE** — assemble from existing lower-level components. Propose the composition tree and which slots / props / state belong to the new component.
- **BUILD-NEW** — no good fit. Propose the new component's atomic level, file path, dependencies, and rough implementation plan.

**Print the verdict and ask the user to confirm before proceeding.** This is the single most important decision in the workflow — adding code that already exists is the #1 failure mode of design systems.

If the verdict is REUSE, stop after printing usage instructions.

If EXTEND, switch into refactor mode (Phase 4) on the existing component instead of creating a new one.

If COMPOSE or BUILD-NEW, proceed to Phase 3.

## Phase 3 — Atomic-level placement

If the user disagreed with the preliminary level in Phase 0, the composer's verdict resolves the question. Re-classify by these rules (see `atomic-design` skill):

- Single element with one concern → atom
- Small group of atoms with one job → molecule
- Standalone section composed of molecules / atoms → organism
- Page-shaped layout with slots → template
- Routed, data-connected, specific instance → page

Print the chosen level with reasoning. Ask the user to confirm.

## Phase 4 — Build (parallel where safe)

For COMPOSE / BUILD-NEW, spawn the build subagents in this orchestration:

### 4a. Implementation (sequential)

Spawn `component-composer --mode=implement` to write the component file. Inputs:
- the spec
- the chosen atomic level
- the composition tree (which lower-level components to use)
- the prop API
- forwarded refs, controlled/uncontrolled handling per the `component-composition` skill

Output: the component file + any minor barrel-export updates.

### 4b. Token-correctness (sequential, after 4a)

Spawn `design-token-enforcer --mode=apply --scope=<file>` against the new component. It rewrites any inline values it can map to tokens; flags any it can't.

### 4c. Stories + MDX (parallel)

Spawn two subagents at the same time:

1. `story-writer` — writes the `.stories.tsx` file. Uses CSF Factories on Storybook 9+ React; CSF3 otherwise. Includes the **required stories for this atomic level** per `story-coverage-checklist`.
2. `mdx-doc-writer` — writes the `.mdx` docs page following the level-specific MDX template from `storybook-atomic-integration`.

### 4d. Accessibility review (sequential, after 4c)

Spawn `accessibility-reviewer` to run the a11y matrix from `accessibility-stories` against the new component + stories. Returns a defect list.

If defects exist:
- Critical → fix before merge. Spawn `component-composer --mode=fix` with the defect list.
- High → fix or open follow-ups. Surface to user.
- Medium / Low → log; user decides.

## Phase 5 — Final review

Print:

```text
ADDED COMPONENT — <level>/<Name>
Files written:
  src/components/<level>/<Name>/<Name>.tsx
  src/components/<level>/<Name>/<Name>.stories.tsx
  src/components/<level>/<Name>/<Name>.mdx

Composition:
  imports: <list of lower-level components used>

Coverage:
  required stories: <n> present / <n> total
  MDX sections: complete
  token compliance: 100
  a11y: <pass / outstanding defects>

NEXT
  - Run /design-storybook-atomic:audit-<level> <Name> to grade against the rubric.
  - Visual regression: capture baseline in Chromatic / Playwright if applicable.
  - Add to barrel exports if not already.
```

## Operating rules

1. **Always inventory first.** Never propose new code before the inventory completes. The whole point is to avoid duplication.
2. **REUSE is the best outcome.** If REUSE is viable, championing it is the correct answer even if the user pushed for new code.
3. **Don't auto-write without explicit Phase 4 approval.** The user must say "go" after seeing the verdict and chosen atomic level.
4. **Each subagent gets the minimum context it needs.** The cartography map is large; pass only the relevant slice to the composer.
5. **Token-enforce before stories.** Stories rendered against hardcoded values pass-through to MDX, which pollutes the docs. Token-clean first.
6. **Surface dependencies.** If BUILD-NEW requires a missing token (e.g. `motion.feedback`), pause and ask whether to add the token first — see `/design-storybook-atomic:audit-tokens` Block 1.

## Failure modes

- **No design system structure exists.** No `atoms/`, `molecules/`, etc. Walk the user through bootstrapping the layout before adding the component.
- **Inventory finds wildly inconsistent classifications.** Recommend running `/design-storybook-atomic:audit-atomic` first; new components added to a broken system inherit the brokenness.
- **Spec changes mid-flow.** Restart from Phase 0 with the new spec; never partial-overwrite a half-written component.
- **Multi-framework repo.** Confirm which framework / build the new component targets and pick the correct `@storybook/<framework>-vite` package for stories.
