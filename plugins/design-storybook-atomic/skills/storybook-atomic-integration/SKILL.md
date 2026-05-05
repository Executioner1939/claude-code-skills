---
name: storybook-atomic-integration
description: Bridge between atomic design and Storybook authoring — the conventions for organizing stories by atomic level, the per-level minimum-required story set, sidebar hierarchy, story naming, MDX docs structure, and how component scope determines which addons matter. Load whenever organizing the Storybook sidebar, deciding what stories a component needs, naming stories, structuring an MDX docs page, or deciding whether a Storybook entry is "complete enough to ship". Auto-activates on *.stories.* and *.mdx files inside an atomic-design layout (atoms/, molecules/, organisms/, templates/, pages/).
when_to_use: Choosing the `title` for a story, deciding whether a component has enough story coverage, structuring MDX docs by atomic level, designing the Storybook sidebar, mapping atoms→molecules→organisms in stories, naming variant stories, deciding which addons are relevant for which level.
paths: "**/atoms/**/*.stories.*, **/molecules/**/*.stories.*, **/organisms/**/*.stories.*, **/templates/**/*.stories.*, **/pages/**/*.stories.*, **/atoms/**/*.mdx, **/molecules/**/*.mdx, **/organisms/**/*.mdx, **/templates/**/*.mdx, **/pages/**/*.mdx"
---

# Storybook ↔ Atomic Design Integration

How to wire the **atomic design** methodology to **Storybook** conventions so that every component has predictable, complete coverage.

This skill defines: sidebar layout, the minimum required story set per atomic level, the MDX docs structure per level, and which addons matter at which level.

## Sidebar layout

Use the atomic level as the **first segment** of `title`. Capitalize that level segment and pluralize it (`Atoms` not `Atom`; `Molecules` not `Molecule`). The component-name segment that follows is **not** pluralized — it's the component's class name (`Button`, `SearchBar`).

```text
Atoms/Button
Atoms/Icon
Atoms/Input
Molecules/SearchBar
Molecules/FormField
Organisms/Header
Organisms/DataTable
Templates/DashboardTemplate
Pages/UserDashboard
```

Group sub-categories with a second segment when an atomic level has many items:

```text
Atoms/Form/Input
Atoms/Form/Checkbox
Atoms/Form/Radio
Atoms/Typography/Heading
Atoms/Typography/Text
```

Stop at three segments. Beyond that, the sidebar gets unscannable — split the design system instead.

## The minimum required story set per level

Every component **must** ship with the following stories. Anything missing is a defect.

### Atoms — required stories

| Story | Purpose |
|---|---|
| `Default` | The canonical example. First in the file. |
| One per variant | E.g. `Primary`, `Secondary`, `Ghost`, `Destructive`. One named export each. |
| One per size | `Small`, `Medium`, `Large` — if size is a prop. |
| `Disabled` | If the atom can be disabled. |
| `Loading` | If the atom can show a loading state. |
| `WithIcon` (or equivalent) | If a slot exists, demonstrate it filled. |
| `LongText` / `Truncation` | For atoms that render text — demonstrate overflow behavior. |
| `RTL` | When direction matters (most atoms). Use a decorator. |
| `Focus` | Visible focus state, ideally via a story-level decorator. |

Atoms must **not** have stories that depend on application data. If you find yourself reaching for a fixture, you're probably looking at a molecule.

### Molecules — required stories

Everything an atom needs, **plus**:

| Story | Purpose |
|---|---|
| `Default` | Canonical composed state. |
| One per **state** | E.g. `Empty`, `Filled`, `WithError`, `Success`. |
| One per **interaction** | At least one `play` story exercising the primary interaction (clicking, typing, opening). |
| `Truncated` / `Overflow` | What happens with too-long content. |
| `LoadingSlot` | If any slot can be loading. |
| `LongLabel` / `LongValue` | Stress test composition with realistic-but-long content. |

Molecules **must** include at least one interaction `play` test. Molecules are where users actually do things; a molecule without an interaction story is undertested.

### Organisms — required stories

Everything a molecule needs, **plus**:

| Story | Purpose |
|---|---|
| `Default` | Canonical state, with realistic data. |
| `Empty` | What it looks like with no data. **Mandatory.** |
| `Loading` | What it looks like while data is loading. **Mandatory.** |
| `Error` | What it looks like when data fetch fails. **Mandatory.** |
| `Partial` | Some-but-not-all data (e.g. half the fields populated). |
| `LongData` / `ManyItems` | Stress test with realistic upper-bound dataset. |
| One per **state machine state** | If the organism has discrete states. |
| One per **role / permission** | If it renders differently per role. |
| `Interaction` (`play`) | Exercise the main user flow end-to-end. |

The empty / loading / error trio is **non-negotiable** for organisms. They're the states designers forget and engineers leave broken.

### Templates — required stories

| Story | Purpose |
|---|---|
| `Default` | All slots filled with placeholder content. |
| `MinimalContent` | Only required slots; optional slots empty. |
| `MaxContent` | Every slot filled, longest realistic content. |
| Per breakpoint | One story per major viewport (use `parameters.viewport`). |

Templates are about layout, so the test is **shape**, not data. Use `<Slot />` placeholders or simple boxes — not real organisms — unless the template is tightly bound to specific organisms.

### Pages — required stories

Pages are the hardest to story-test because they're connected to data. Use **MSW (Mock Service Worker)** or Storybook's `loaders` to stub data.

| Story | Purpose |
|---|---|
| `Default` | Successful fetch, full data. |
| `Empty` | Successful fetch, zero results. |
| `Loading` | Pending state. |
| `Error` | Network or 5xx error. |
| `Forbidden` / `Unauthorized` | 401/403 state. |
| Per route variant | Important query-param / route-param branches. |

Pages are also where you turn off most addons (a11y, controls) at the meta level, because pages aren't reusable surfaces — but you keep `viewport` and `chromatic` for visual regression.

## MDX docs structure per level

Every component gets an MDX docs page next to its stories. Use the same structure per level:

### Atom MDX template

```mdx
import { Meta, Title, Subtitle, Description, Primary, Controls, Stories, Canvas, ArgTypes } from '@storybook/addon-docs/blocks';
import * as Stories from './Atom.stories';

<Meta of={Stories} />

<Title />
<Subtitle>One-line description of the atom.</Subtitle>
<Description of={Stories} />

## Anatomy
A single sentence describing the underlying element(s).

## Usage
<Canvas of={Stories.Default} />
<Controls of={Stories.Default} />

## Variants
<Stories includePrimary={false} />

## Props
<ArgTypes of={Stories} />

## Design tokens
- `--color-button-bg-primary`
- `--space-button-padding-x`
- `--font-button`

## Accessibility
- Renders as a native `<button>` with implicit role `button`.
- Has visible focus ring.
- Communicates pressed state via `aria-pressed` when toggleable.

## Do / Don't
- ✅ Use sentence case for labels.
- ❌ Don't disable the button without explaining why elsewhere.
```

### Molecule MDX template

Same as atom, plus:

```mdx
## Composition
This molecule composes:
- `<Atom1 />` — for X
- `<Atom2 />` — for Y

## States
<Canvas of={Stories.Empty} />
<Canvas of={Stories.WithError} />
```

### Organism MDX template

Same as molecule, plus:

```mdx
## Data contract
| Prop | Shape | Required |
|---|---|---|
| `items` | `Item[]` | yes |
| `onSelect` | `(id) => void` | no |

## States
<Canvas of={Stories.Empty} />
<Canvas of={Stories.Loading} />
<Canvas of={Stories.Error} />

## Permissions
This organism renders differently for `admin` vs `viewer` roles. See `RoleAdmin` and `RoleViewer` stories.
```

### Template / Page MDX template

```mdx
## Layout
A diagram or description of the slot structure.

## Slots
| Slot | Purpose | Required |
|---|---|---|
| `header` | top bar | yes |
| `sidebar` | nav | no |
| `main` | content | yes |
```

## Which addons matter at which level

| Addon | Atoms | Molecules | Organisms | Templates | Pages |
|---|---|---|---|---|---|
| `@storybook/addon-docs` (Controls/Docs/Args) | ✅ critical | ✅ critical | ✅ | ⚠️ less useful | ⚠️ data-driven |
| `@storybook/addon-a11y` | ✅ critical | ✅ critical | ✅ critical | ✅ | ✅ |
| `@storybook/addon-vitest` (turns stories into tests; runs `play` and `.test()`) | ✅ render-smoke | ✅ required (interaction) | ✅ required (E/L/E + interaction) | ✅ render-smoke | ✅ critical |
| `@storybook/addon-viewport` | ➖ | ⚠️ | ✅ | ✅ critical | ✅ critical |
| `@storybook/addon-backgrounds` | ✅ | ✅ | ✅ | ⚠️ | ⚠️ |
| `@storybook/addon-themes` (light/dark) | ✅ | ✅ | ✅ | ✅ | ✅ |
| `@storybook/addon-measure` / `addon-outline` | ⚠️ | ⚠️ | ⚠️ | ✅ | ✅ |
| Chromatic (visual regression) | ✅ | ✅ | ✅ | ✅ | ✅ |
| `msw-storybook-addon` (network mocking) | ➖ | ➖ | ✅ if data-aware | ➖ | ✅ critical |

> Storybook 9 consolidated several addons into core / `addon-docs`. Notably `addon-controls`, `addon-actions`, `addon-viewport`, and `addon-backgrounds` are bundled with `@storybook/addon-docs` (or core) — you don't install them separately. `addon-a11y` and `addon-vitest` remain explicit installs.

Configure these at the **meta level** for atoms/molecules (uniform), at the **story level** for organisms/pages (varies per state).

## Naming conventions for stories

- `Default` — the canonical example. **First export.** Always.
- Prop-derived names: `Primary`, `Small`, `WithIcon`, `Disabled`, `Loading`.
- State-derived names: `Empty`, `Error`, `Success`, `Partial`, `Forbidden`.
- Interaction names start with a verb: `SubmitsForm`, `OpensMenu`, `Cancels`.
- Visual stress tests: `LongText`, `LongLabel`, `ManyItems`, `RTL`, `Truncated`.
- Hide internal helper stories from autodocs with `tags: ['!autodocs']`.

## Title-prefix rules

Once you set `title: 'Atoms/Button'`, the file's location should match: `src/components/atoms/Button/Button.stories.tsx`.

Mismatches between `title` and folder are a red flag — usually means the component was moved without updating stories. Catch this in CI:

```bash
# pseudo-code: every stories file must declare the same atomic level as its folder
grep -RhE "title:\s*['\"]([A-Za-z]+)/" --include="*.stories.*" src/components/
```

## When something feels wrong

- A story file has no `Default` export → fix it.
- An organism without `Empty`/`Loading`/`Error` → block it from merging.
- An atom with `play` testing complex flows → it's not really an atom.
- A molecule's stories all rely on a global store → it's an organism.
- A component's title is `Misc/X` or `Components/X` → it has not been classified. Block it.
- Two atoms with near-identical stories and props → see `merge-duplicates` workflow.

## Relationship to other skills in this plugin

- **`atomic-design`** — for the level-classification rules.
- **`storybook-authoring`** — for *how to write* CSF Factories stories.
- **`story-coverage-checklist`** — formalizes the "minimum required" tables above into a graded rubric used by the audit workflows.
- **`accessibility-stories`** — addon-a11y configuration per level.
