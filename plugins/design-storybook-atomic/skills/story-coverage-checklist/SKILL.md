---
name: story-coverage-checklist
description: The graded rubric for "complete" Storybook coverage by atomic level. Defines per-component required stories, parameters, decorators, MDX sections, a11y artifacts, and the scoring used by the audit workflows. Load whenever grading a component's coverage, deciding if a component is "ship-ready" in the design system, generating a coverage report, or filing a defect against missing stories.
when_to_use: Grading individual component coverage, generating coverage matrices, filing missing-story defects, deciding ship-readiness, computing the design-system completeness score.
paths: "**/atoms/**/*.stories.*, **/molecules/**/*.stories.*, **/organisms/**/*.stories.*, **/templates/**/*.stories.*, **/pages/**/*.stories.*"
---

# Story Coverage Checklist

The **graded rubric** every component is held to. Used by:

- `/design-storybook-atomic:audit-atomic` (and the equivalent for molecules / organisms / templates / pages)
- `/design-storybook-atomic:coverage-report`
- `atomic-auditor` and `storybook-coverage-analyst` subagents

## Scoring model

For each component, compute three scores out of 100:

- **Coverage score** — % of required stories present (with weighted importance).
- **Quality score** — checklist of qualitative items (decorators, parameters, MDX sections, accessibility, prop documentation).
- **Hygiene score** — uniqueness, token compliance, naming, folder/title alignment.

Composite grade = average of the three. Letter grade: A ≥ 90, B ≥ 80, C ≥ 70, D ≥ 60, F < 60.

A component is **ship-ready** when:
- Coverage ≥ 90
- Quality ≥ 80
- Hygiene = 100 (hygiene is binary; any defect = block)

## Per-level coverage rubric

Weights are points-per-story-out-of-100. Sum the weights of stories present.

### Atoms

| Story | Weight | Required? |
|---|---|---|
| `Default` | 15 | ✅ |
| One per `variant` | 10 each (cap 30) | ✅ if `variant` prop exists |
| One per `size` | 5 each (cap 15) | ✅ if `size` prop exists |
| `Disabled` | 10 | ✅ if `disabled` prop exists |
| `Loading` | 8 | ✅ if `loading` prop exists |
| `WithIcon` (or named slot fill) | 7 | ✅ if slot exists |
| `LongText` / `Truncation` | 5 | ✅ if renders text |
| `RTL` | 5 | ✅ |
| `Focus` | 5 | ✅ if focusable |

Cap: 100. Components without applicable props get those points redistributed evenly across the present stories.

### Molecules

| Story | Weight |
|---|---|
| `Default` | 12 |
| Per state (`Empty`, `Filled`, `WithError`, `Success`) | 10 each (cap 30) |
| Primary interaction (`play`) | 15 |
| Secondary interaction (`play`) | 8 |
| `Truncated` / `Overflow` | 6 |
| `LoadingSlot` | 5 |
| `LongLabel` / `LongValue` | 5 |
| `RTL` | 5 |
| `KeyboardFlow` | 7 |
| `WithError` (a11y announcement check) | 7 |

### Organisms

| Story | Weight |
|---|---|
| `Default` (with realistic data) | 10 |
| `Empty` | 12 |
| `Loading` | 12 |
| `Error` | 12 |
| `Partial` | 7 |
| `LongData` / `ManyItems` | 7 |
| Per state-machine state | 8 each (cap 16) |
| Per role / permission | 8 each (cap 16) |
| Primary `play` interaction | 10 |
| `KeyboardOperated` `play` | 5 |
| `ScreenReaderText` | 3 |

### Templates

| Story | Weight |
|---|---|
| `Default` (all slots filled) | 30 |
| `MinimalContent` (only required slots) | 25 |
| `MaxContent` (every slot, longest content) | 20 |
| Per major breakpoint (mobile, tablet, desktop) | 8 each (cap 24) |
| `RTL` | 5 |

### Pages

| Story | Weight |
|---|---|
| `Default` (success state) | 20 |
| `Empty` | 15 |
| `Loading` | 15 |
| `Error` | 15 |
| `Forbidden` / `Unauthorized` | 8 |
| Per route / query-param variant | 7 each (cap 21) |
| Primary `play` flow | 8 |

## Quality checklist (out of 100)

Score 1 point per item present. Cap at 100.

### File-level (worth 30)
- [ ] **CSF Factories format only** (`preview.meta` / `meta.story`). CSF3 object syntax, CSF2 `Template.bind({})`, or `storiesOf` = **auto-fail** (hygiene FAIL). Migration path: `_migration/migration-storybook-7-to-10.md`.
- [ ] Type imports come from the **framework package** (`@storybook/react-vite`, `@storybook/nextjs-vite`, `@storybook/vue3-vite`, etc.), not the generic `@storybook/react`. (Generic `@storybook/react` import = auto-fail.)
- [ ] MDX Doc Block imports come from `@storybook/addon-docs/blocks`, not the deprecated `@storybook/blocks` shim.
- [ ] Vitest setup uses `@storybook/addon-vitest`, not `@storybook/experimental-addon-test`.
- [ ] `meta.title` matches folder structure (level segment correct).
- [ ] `meta.component` set.
- [ ] `tags: ['autodocs']` present.
- [ ] `meta.args` provides sensible defaults inherited by stories.
- [ ] `meta.argTypes` declares every prop with `control` + `description`.
- [ ] `meta.parameters.layout` set appropriately.
- [ ] `meta.decorators` provides any required theme/router/provider.

### Story-level (worth 30)
- [ ] First export named `Default`.
- [ ] Story names PascalCase, descriptive, no `Story1`/`Test`.
- [ ] Stories use `args` only — no inline children unless required.
- [ ] No `render` overrides except where strictly necessary.
- [ ] `play` functions (or CSF-Factory `.test()`) use `@storybook/test` (`userEvent`, `expect`, `fn`, `within`).
- [ ] `play` functions take the pre-bound `canvas` or use `within(canvasElement)` consistently.
- [ ] `play` functions use `step()` to label phases.
- [ ] Tests can be excluded from the run with `tags: ['!test']` where appropriate (e.g. intentionally-broken demo stories).
- [ ] No console errors / warnings during render.
- [ ] No `console.log` left in stories.

### MDX docs (worth 20)
- [ ] `<Title />`, `<Subtitle>`, `<Description>` blocks present.
- [ ] **Anatomy** section present.
- [ ] **Usage** section with `<Canvas of={Default}/>` and `<Controls/>`.
- [ ] **Props** section with `<ArgTypes/>`.
- [ ] **Design tokens** list of consumed tokens.
- [ ] **Accessibility** section with semantics, keyboard model, ARIA notes.
- [ ] **Do / Don't** section with at least 2 of each.

### Accessibility (worth 20)
- [ ] `parameters.a11y.test = 'error'` (inherited from `definePreview` baseline is fine).
- [ ] `@storybook/addon-a11y` and `@storybook/addon-vitest` both registered in `main.ts`.
- [ ] No story disables a11y rules without an inline comment explaining why.
- [ ] `Focus` story or focused-state coverage.
- [ ] `KeyboardActivated` / `KeyboardFlow` story for interactives.
- [ ] `RTL` story.
- [ ] All form-related molecules have `LabelledCorrectly` story.
- [ ] All organisms have `Empty`/`Loading`/`Error` a11y-passing.

## Hygiene checks (binary — any failure = 0)

### Atomic-design discipline
- [ ] Folder atomic level matches `meta.title` first segment.
- [ ] Component name is unique within its level (no near-duplicates).
- [ ] No imports from a higher atomic level (atom doesn't import a molecule, etc.).
- [ ] No imports from a sibling at the same level except utility atoms (Icon-like).

### Storybook discipline (latest-only)
- [ ] **CSF Factories** — CSF3 / CSF2 / `storiesOf` = auto-fail.
- [ ] Framework package import — `@storybook/react` (generic) = auto-fail.
- [ ] MDX uses `@storybook/addon-docs/blocks` — `@storybook/blocks` = auto-fail.
- [ ] Vitest setup uses `@storybook/addon-vitest` — `@storybook/experimental-addon-test` = auto-fail.

### Token discipline (see `design-tokens`)
- [ ] No hardcoded colors / spacing / fonts / radii / shadows / motion — all values are semantic tokens.

### Approved-libraries discipline (see `approved-libraries`)
- [ ] No forbidden libraries imported from this component (e.g. `react-hook-form`, `lodash` debounce, `moment`, `date-fns`, `react-dnd`).

### TanStack-integration discipline (see `tanstack-integration`)
- [ ] **Atom (interactive)** — exposes `value` + `onChange(value)` (NOT `onChange(event)`) + `onBlur` + `aria-invalid` + `aria-describedby`. Forwards refs.
- [ ] **Molecule (form-shaped)** — accepts a TanStack Form `field` as primary prop OR composes only field-friendly atoms (above).
- [ ] **Organism (table-shaped)** — accepts a TanStack Table `table` instance, not raw `data + columns`.
- [ ] **Organism (list / grid with fetched data)** — consumes a TanStack DB collection or a TanStack Query result. No `useState([])` for fetched data.
- [ ] **Animated** — uses Motion (web) or Reanimated (native). Honors `prefers-reduced-motion`.

### Code health
- [ ] Component has at least one stable named export — no default-only exports.
- [ ] No `// TODO` or `// FIXME` comments in the component or its stories.
- [ ] Component is not marked `@deprecated` (if it is, it shouldn't be in the live library).
- [ ] `package.json` exports include this component (if applicable).

## How the audit workflows use this

The audit workflows produce, per component:

```text
COMPONENT: atoms/Button
  Coverage : 84/100 (B)
    + Default, Primary, Secondary, Ghost, Disabled, Loading, RTL, Focus
    - missing: WithIcon (slot exists)
    - missing: LongText
  Quality  : 76/100 (C)
    - no MDX docs
    - missing Anatomy, Do/Don't
    - argTypes missing description on `loading`
  Hygiene  : FAIL
    - hardcoded color #3B82F6 in Button.css line 12
  Composite: 53 (F) — BLOCKED

  RECOMMENDED ACTIONS:
  1. Add WithIcon and LongText stories
  2. Create Button.mdx with Anatomy, Usage, Props, Design tokens, Accessibility, Do/Don't sections
  3. Replace #3B82F6 with var(--color-action-primary)
  4. Re-run /design-storybook-atomic:audit-atomic Button
```

## Configuration overrides

A repo can override weights / required stories by adding a `.storybook-atomic.yml` to the repo root. The audit workflows read it.

```yaml
# .storybook-atomic.yml
overrides:
  atoms:
    rtl_required: false             # we don't ship RTL yet
  molecules:
    primary_interaction_required: true
  hygiene:
    deprecated_blocks_pass: false   # @deprecated allowed
exclude:
  - "src/components/atoms/legacy/**"
```

## Relationship to other skills in this plugin

- **`atomic-design`** — defines the levels this rubric grades.
- **`storybook-atomic-integration`** — defines the required stories table this rubric scores.
- **`storybook-authoring`** — for the syntax and structure quality items reference.
- **`accessibility-stories`** — for the a11y items.
- **`design-tokens`** — for the hygiene "no hardcoded values" check.
- **`approved-libraries`** — for the forbidden-library hygiene checks.
- **`tanstack-integration`** — for the atom-prop-shape, molecule-field, organism-table, organism-collection rules.
- **`_migration/migration-storybook-7-to-10.md`** — when CSF3 / CSF2 / `storiesOf` are detected, the audit links to this guide.
