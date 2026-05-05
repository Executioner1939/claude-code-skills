---
name: storybook-component-documentation
user-invocable: false
description: MDX docs pages with `@storybook/addon-docs/blocks` (Storybook 10 import path). Doc Block reference (Meta, Title, Subtitle, Description, Primary, Stories, Canvas, Controls, ArgTypes, Source, Markdown, ColorPalette, Typeset). Per-atomic-level MDX templates. Auto-generated docs vs custom MDX. Inline rich-text patterns for usage, anatomy, do/don't, design-tokens, accessibility, composition. Auto-loads on `*.mdx`.
when_to_use: Writing or auditing MDX docs pages, choosing between autodocs and custom MDX, structuring docs sections per atomic level, embedding usage examples, documenting design tokens consumed by a component.
paths: "**/*.mdx"
---

# Storybook component documentation (MDX)

Storybook 10 ships docs as MDX with Doc Blocks imported from `@storybook/addon-docs/blocks`. The legacy `@storybook/blocks` path still works as a re-export shim but is deprecated — use the new path in all new files.

## Two paths: autodocs or custom MDX

### Autodocs

Adding `tags: ['autodocs']` at the meta level generates a Docs page automatically. Storybook reads the component's prop interface, the argTypes you declared, and renders every story in declaration order.

```tsx
const meta = preview.meta({
  component: Button,
  tags: ['autodocs'],                                       // ← this
  parameters: {
    docs: {
      description: { component: 'Primary clickable element.' },
    },
  },
});
```

Use autodocs when the component is simple enough that the auto-generated layout (Title / Description / Primary / Stories / ArgTypes) is sufficient. Atoms typically qualify.

### Custom MDX

For richer documentation (Anatomy, Usage, Do/Don't, Design tokens consumed, Accessibility notes), write `<Component>.mdx` next to the stories file. The MDX **replaces** the auto-generated docs page for that component.

```mdx
{/* Button.mdx */}
import { Meta, Title, Subtitle, Description, Primary, Controls, Stories, Canvas, ArgTypes } from '@storybook/addon-docs/blocks';
import * as Stories from './Button.stories';

<Meta of={Stories} />

<Title />
<Subtitle>Primary clickable element.</Subtitle>
<Description of={Stories} />

## Anatomy
A `<button>` with optional leading icon, label, and trailing icon.

## Usage
<Canvas of={Stories.Default} />
<Controls of={Stories.Default} />

## Variants
<Stories includePrimary={false} />

## Props
<ArgTypes of={Stories} />

## Design tokens
- `--color-action-primary`
- `--color-action-primary-hover`
- `--space-button-padding-x`
- `--radius-control`

## Accessibility
- Renders as native `<button>` with implicit role.
- Visible focus ring with sufficient contrast.
- `aria-pressed` when used as toggle.

## Do / Don't
- ✅ One primary button per surface.
- ✅ Use sentence case for labels.
- ❌ Don't use a button for navigation. Use a Link.
- ❌ Don't communicate state with color alone.
```

`<Meta of={Stories} />` connects the MDX to the CSF file; everything else flows from there.

## Doc Blocks reference

All from `@storybook/addon-docs/blocks`:

| Block | Purpose |
|---|---|
| `<Meta of={...}/>` | Connect MDX to CSF file. **Required at top of every MDX.** |
| `<Title />` | Component name (from meta.title). |
| `<Subtitle>...</Subtitle>` | Sub-heading. |
| `<Description of={...}/>` | `parameters.docs.description.component` text. |
| `<Primary />` | The first story, rendered with controls. |
| `<Stories />` | All stories below the primary. Pass `includePrimary={false}` to omit Primary. |
| `<Story of={Stories.X}/>` | A single story. |
| `<Canvas of={Stories.X}/>` | A story with the source-code panel. |
| `<Controls of={Stories.X}/>` | The args editor for one story. |
| `<ArgTypes of={Stories}/>` | The full props table. |
| `<Source of={Stories.X}/>` | Just the source code, no canvas. |
| `<Markdown>...</Markdown>` | Render a string as markdown (useful for dynamic content). |
| `<ColorPalette>` / `<ColorItem>` | Document the color palette. |
| `<Typeset />` | Document the type scale. |
| `<IconGallery>` / `<IconItem>` | Document an icon set. |

## Per-atomic-level MDX templates

### Atom

```mdx
{/* <Atom>.mdx */}
import { Meta, Title, Subtitle, Description, Primary, Controls, Stories, Canvas, ArgTypes } from '@storybook/addon-docs/blocks';
import * as Stories from './<Atom>.stories';

<Meta of={Stories} />

<Title />
<Subtitle><one-line summary></Subtitle>
<Description of={Stories} />

## Anatomy
<one paragraph describing the underlying element(s) and their hierarchy>

## Usage
<Canvas of={Stories.Default} />
<Controls of={Stories.Default} />

## Variants
<Stories includePrimary={false} />

## Props
<ArgTypes of={Stories} />

## Design tokens
- `--color-…`
- `--space-…`
- `--font-…`

## Accessibility
- **Role**: <native or ARIA role>
- **Keyboard**: <key bindings>
- **States**: <focus / disabled / pressed signals>

## Do / Don't
- ✅ <do 1>
- ✅ <do 2>
- ❌ <don't 1>
- ❌ <don't 2>
```

### Molecule

Atom MDX, plus:

```mdx
## Composition
This molecule composes:
- `<AtomA />` — for X
- `<AtomB />` — for Y

## States
<Canvas of={Stories.Empty} />
<Canvas of={Stories.WithError} />
```

### Organism

Molecule MDX, plus:

```mdx
## Data contract
| Prop | Shape | Required | Notes |
|---|---|---|---|
| `items` | `Item[]` | yes | sorted on insertion |
| `onSelect` | `(id: string) => void` | no | called on row click |

## State coverage
<Canvas of={Stories.Empty} />
<Canvas of={Stories.Loading} />
<Canvas of={Stories.Error} />

## TanStack abstraction used
This organism consumes a TanStack Table `table` instance:

\`\`\`tsx
const table = useReactTable({ data, columns, … });
<DataTable table={table} />
\`\`\`

See `tanstack-integration` skill for the contract.

## Permissions / Roles
This organism renders differently for `<role>` vs `<role>`. See `RoleAdmin` and `RoleViewer` stories.
```

### Template / Page

```mdx
## Layout
<diagram or short description of the slot structure>

## Slots
| Slot | Purpose | Required |
|---|---|---|
| `header` | top bar | yes |
| `sidebar` | nav | no |
| `main` | content | yes |
```

## Authoring patterns

### Inline code samples

For copy-paste-ready snippets, use a fenced code block with a language hint:

````mdx
```tsx
import { Button } from '@/components/atoms/Button';

<Button variant="primary" onClick={handleSubmit}>Save</Button>
```
````

### Sourcing live snippets

`<Source of={Stories.X}/>` renders the actual story source — keeps docs in sync as the story evolves. Prefer this over hand-written code blocks when the example is a story.

```mdx
<Source of={Stories.WithIcon} />
```

### Design-system-wide MDX (no `of` target)

For non-component pages (Migration guides, Color palette, Type scale):

```mdx
{/* DesignSystem/Colors.mdx */}
import { Meta, ColorPalette, ColorItem } from '@storybook/addon-docs/blocks';

<Meta title="Design system/Colors" />

# Color palette

## Action

<ColorPalette>
  <ColorItem
    title="Primary"
    subtitle="Main call-to-action color"
    colors={{ Primary: 'var(--color-action-primary)' }}
  />
</ColorPalette>
```

A `<Meta title="...">` without `of` registers a docs-only page in the sidebar.

### Linking to other components

Cross-references in MDX use plain markdown links:

```mdx
This molecule composes [`Button`](?path=/docs/atoms-button--docs)
and [`Icon`](?path=/docs/atoms-icon--docs).
```

`?path=/docs/...` is Storybook's stable docs URL.

## Anti-patterns

### ❌ Generic prop descriptions

```ts
// BAD
/** The label */
label: string;
```

```ts
// GOOD
/** Text displayed on the button. Sentence case. ≤ 30 characters. */
label: string;
```

### ❌ Doc Block imports from `@storybook/blocks`

```mdx
{/* BAD */}
import { Meta } from '@storybook/blocks';

{/* GOOD */}
import { Meta } from '@storybook/addon-docs/blocks';
```

### ❌ Component MDX without `<Meta of={Stories}/>`

For component MDX paired with a CSF stories file, `<Meta of={Stories}/>` is mandatory — it connects the MDX to the CSF file so `<Canvas of={Stories.X}/>` and `<ArgTypes/>` resolve correctly. Without it, the docs page is orphaned.

**Exception**: docs-only pages (Migration guides, Color palette, Type scale) use `<Meta title="Design system/Colors"/>` instead — see the "Design-system-wide MDX" pattern above. Those pages have no CSF file, so `of=` doesn't apply.

### ❌ Out-of-date hand-written code samples

Hand-written code samples drift from the actual stories. Use `<Source of={Stories.X}/>` whenever possible.

### ❌ Stuffing all sections into one MDX when the autodocs page would have done

If your MDX is just `<Title /> + <Description /> + <Primary /> + <Controls /> + <Stories />`, drop the MDX and use `tags: ['autodocs']` instead. Custom MDX is for components that need Anatomy / Do/Don't / Design-token / Accessibility sections.

## What the audit checks

`/anvil:audit-*` verify per component:

- ✅ MDX file exists alongside `.stories.*` for any component above the atom level (atoms may use autodocs).
- ✅ MDX uses `@storybook/addon-docs/blocks` import path (not legacy `@storybook/blocks`).
- ✅ Required sections per level present (Anatomy, Usage, Props, Design tokens, Accessibility, Do/Don't for atoms; plus Composition for molecules; plus Data contract + TanStack abstraction used + State coverage for organisms; plus Layout + Slots for templates/pages).
- ✅ At least 2 do's and 2 don'ts.
- ✅ Design tokens listed are real entries in the project's token files.
- ✅ Accessibility section names role + keyboard + states.

## Relationship to other skills in this plugin

- **`storybook-authoring`** — overview of CSF Factories that this MDX references.
- **`storybook-story-writing`** — story patterns docs blocks render.
- **`storybook-args-controls`** — argTypes feed `<ArgTypes />`.
- **`storybook-atomic-integration`** — required-sections-per-level table this skill operationalizes.
- **`accessibility-stories`** — Accessibility section content.
