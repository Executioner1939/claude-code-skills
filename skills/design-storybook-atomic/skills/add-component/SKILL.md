---
name: add-component
description: Interactive workflow to add a new component to the design system. Asks for the spec (intent, props, states, variants, web/native target); accepts written briefs / screenshots / design URLs; inventories every existing atom / molecule / organism in the codebase; decides whether the new component is REUSE / EXTEND / COMPOSE / BUILD-NEW; spawns specialized subagents to assemble it (component-composer, story-writer, mdx-doc-writer, design-token-enforcer, accessibility-reviewer, library-policy-enforcer); writes the final files. Inter-agent HANDOFF contract — every phase boundary writes a HANDOFF.md the next agent reads cold. Storybook 10 / CSF Factories only. Tan­Stack-aware (atom contract, molecule field, organism table / DB collection). Invoke as `/design-storybook-atomic:add-component`.
disable-model-invocation: true
argument-hint: "[name] [brief|path|url]"
arguments: component_name brief
allowed-tools: Read, Grep, Glob, Bash, Agent, Write, Edit, AskUserQuestion
---

# Add Component

End-to-end workflow for adding a new component to the design system. The output is a fully-classified component, a working implementation, complete CSF Factories stories, an MDX docs page, token-compliant styles, an a11y review, and library-policy compliance — *or* a clear plan that proves the component already exists or can be assembled from existing parts.

## Step 0 — Load context + spec

### 0a — References
Acceptance criteria for "ship-ready" come from `story-coverage-checklist`, `approved-libraries`, `tanstack-integration`, `accessibility-stories`, `design-tokens`. (Auto-preloaded into the chained subagents via their `skills:` frontmatter.)

### 0b — Spec gathering

Spawn `ui-spec-interpreter` with `$component_name` and `$brief`. The interpreter:
- Reads any provided screenshots (Read tool reads images).
- Asks up to 4 clarifying questions in one round if the brief is too thin.
- Produces the structured SPEC block.

The interpreter writes a HANDOFF.md to:

```text
<scope>/.design-storybook-atomic/handoffs/add-component-<run>/phase-00-spec-to-cartography.md
```

**Validation contract**: do not proceed until `HANDOFF: <path>` is printed.

Show the SPEC to the user; ask "Does this match your intent? (y / n / edit)". **Do not proceed to Step 1 (cartography) until the user replies `y`.** The HANDOFF.md being on disk is necessary but not sufficient — user confirmation gates the cartography phase.

## Step 1 — Inventory (cartography)

Spawn `component-cartographer` to inventory **every component** in the codebase, classified by atomic level. The HANDOFF passes the inventory artifact path to the next agent.

HANDOFF: `<scope>/.design-storybook-atomic/handoffs/add-component-<run>/phase-01-cartography-to-composer.md`.

Print: `Inventoried <n> components.`

## Step 2 — Reuse / Extend / Compose / Build decision

Spawn `component-composer` (mode `decide`) with two inputs: the SPEC and the inventory. Returns a verdict with evidence:

- **REUSE** — existing component already does this. Path + props mapping. **Stop here**, propose the user use it.
- **EXTEND** — existing component is 80%+ there; an additive prop / variant / slot covers the gap.
- **COMPOSE** — assemble from existing lower-level components.
- **BUILD-NEW** — no good fit.

HANDOFF: `<scope>/.design-storybook-atomic/handoffs/add-component-<run>/phase-02-decision-to-build.md`.

**Print the verdict and ask the user to confirm before proceeding.** This is the most consequential decision in the workflow. If REUSE, stop. If EXTEND, switch to refactor mode on the existing component. If COMPOSE / BUILD-NEW, continue.

## Step 3 — Atomic-level placement

If the user disagreed with the spec interpreter's hypothesis, the composer's verdict resolves the question. Re-classify per `atomic-design` decision rules. Print and confirm.

## Step 4 — Build (orchestrated subagent chain)

### 4a — Implementation (sequential)

Spawn `component-composer` (mode `implement`) with:
- the SPEC
- the chosen atomic level
- the composition tree (which lower-level components to use)
- the prop API (must satisfy `tanstack-integration` for the level — atom contract / molecule field / etc.)
- forwardRef, controlled+uncontrolled patterns.
- web target, native target, or both (per SPEC).

The composer reads 3 sibling components first to absorb local conventions (file structure, naming, type imports, prop helpers), then writes the component file(s). For cross-platform components, writes the `Component.tsx` (web) and `Component.native.tsx` (RN) split.

HANDOFF: `<scope>/.design-storybook-atomic/handoffs/add-component-<run>/phase-04a-implement-to-tokens.md`.

### 4b — Token-correctness (sequential, after 4a)

Spawn `design-token-enforcer` (mode `apply`, scope: the new component file(s)). It rewrites any inline values it can map to tokens with HIGH confidence; flags any it can't.

HANDOFF: `<scope>/.design-storybook-atomic/handoffs/add-component-<run>/phase-04b-tokens-to-stories.md`.

### 4c — Stories + MDX (parallel)

Spawn two subagents in the same message:

1. **`story-writer`** — writes the `.stories.tsx` file. **CSF Factories** only. Required stories per `story-coverage-checklist` for the chosen atomic level (Default + variants + states + interactions + RTL + Focus etc.).
2. **`mdx-doc-writer`** — writes the `.mdx` docs page following the level-specific MDX template from `storybook-component-documentation`. Imports from `@storybook/addon-docs/blocks`.

Each writes its own HANDOFF:
- `<scope>/.design-storybook-atomic/handoffs/add-component-<run>/phase-04c-stories-to-a11y.md`
- `<scope>/.design-storybook-atomic/handoffs/add-component-<run>/phase-04c-mdx-to-a11y.md`

### 4d — Library-policy + a11y review (parallel, after 4c)

Spawn two subagents:

1. **`library-policy-enforcer`** (mode `audit-imports + audit-integrations`, scope: the new files) — confirms the component satisfies the field-friendly atom contract / molecule-accepts-field / organism-accepts-Table / etc.
2. **`accessibility-reviewer`** (scope: the new files) — runs the manual-check matrix.

If defects exist:
- **Critical** → fix before merge. Spawn `component-composer` (mode `fix`) with the defect list.
  - The fix invocation MUST write a HANDOFF.md and print `HANDOFF: <abs path>` like every other phase.
  - After the fix HANDOFF lands, **re-run the dependent phases in order**:
    1. **4b** — token-correctness (the fix may have introduced new literals).
    2. **4c** — stories + MDX (the prop API or behavior may have changed).
    3. **4d** — review (policy + a11y) on the regenerated artifacts.
  - Only after the second 4d pass clears all Critical findings does the workflow proceed to Step 5.
- **High** → fix or open follow-ups; surface to user. Re-run is optional per user decision.
- **Medium / Low** → log; user decides.

HANDOFF: `<scope>/.design-storybook-atomic/handoffs/add-component-<run>/phase-04d-review-to-final.md`.

## Step 5 — Final review

Print:

```text
ADDED COMPONENT — <level>/<Name>
Run-id : <run-id>
Files written:
  src/components/<level>/<Name>/<Name>.tsx
  src/components/<level>/<Name>/<Name>.native.tsx     (if cross-platform)
  src/components/<level>/<Name>/<Name>.stories.tsx
  src/components/<level>/<Name>/<Name>.mdx

Composition:
  imports: <list of lower-level components used>

TanStack contract:
  ✅ <verified contract — atom field-friendly / molecule field / organism Table or DB collection>

Coverage:
  required stories  : <n> present / <n> total
  MDX sections      : complete
  token compliance  : 100
  library policy    : pass
  a11y              : pass | <outstanding defects>

Handoffs written:
  <list of HANDOFF.md files in handoffs dir>

NEXT
  - Run /design-storybook-atomic:audit-<level> <Name> to grade against the rubric.
  - Capture visual baseline in Chromatic / Playwright.
  - Add to barrel exports if not already.
```

## Operating rules

1. **Always inventory first.** Never propose new code before Step 1 completes.
2. **REUSE is the best outcome.** If REUSE is viable, championing it is correct even if the user pushed for new code.
3. **No auto-write of component / story / MDX files before Step 4 confirmation.** The user must confirm verdict + level before any *implementation* file is written. Exception: HANDOFF.md phase artifacts under `.design-storybook-atomic/handoffs/` and agent-memory snapshots are allowed throughout (Steps 0–3) — these are workflow artifacts, not implementation.
4. **Each subagent gets minimum context.** Pass only the inventory slice + spec slice the agent needs.
5. **Token-enforce before stories.** Stories rendered against hardcoded values pollute MDX too.
6. **Surface dependencies.** If BUILD-NEW requires a missing token (e.g. `motion.feedback`), pause and ask whether to add the token first (run `/design-storybook-atomic:audit-tokens` Block 1).
7. **HANDOFF contract** — every subagent invocation writes a HANDOFF.md and prints `HANDOFF: <path>`. Halt if missing.
8. **CSF Factories only.** No CSF3 generated for new components. Project on legacy? Refuse and link to migration guide.

## Failure modes

- **No design system structure exists.** Walk the user through bootstrapping `atoms/` / `molecules/` / `organisms/` / `templates/` / `pages/` before adding the component.
- **Inventory finds wildly inconsistent classifications.** Recommend running `/design-storybook-atomic:audit-atomic` first.
- **Spec changes mid-flow.** Restart from Step 0 with the new spec.
- **Multi-framework repo.** Confirm which framework / build the new component targets and pick the correct `@storybook/<framework>-vite` package.
- **Library-policy failure during 4d.** Halt the workflow; the component file is written but stories / MDX are blocked until the policy violation resolves.

## Memory

Append summary line to `.claude/agent-memory/add-component/history.log`.
