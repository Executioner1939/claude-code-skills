---
name: component-composition
description: Composition patterns for assembling higher-level components from lower-level ones — slots / children / compound components / render props / polymorphic `as` / asChild (Radix-style) / headless + skin. Covers when each pattern is right, prop-drilling vs context, controlled vs uncontrolled, and the API design moves that keep composition flexible without leaking implementation. Load whenever building a molecule from atoms, an organism from molecules, deciding component API shape, refactoring a tightly-coupled component into a flexible one, or designing a public component library API.
when_to_use: API design for new components, refactoring rigid components into flexible ones, deciding between props vs slots vs render props vs compound components, building primitives that downstream apps can restyle, choosing controlled/uncontrolled, deciding when to expose context.
paths: "**/components/**, **/atoms/**, **/molecules/**, **/organisms/**, **/templates/**"
---

# Component Composition

Reference for **composition patterns** in component libraries — the API moves that decide whether a component is rigid or flexible, easy to use or easy to misuse.

The atomic-design hierarchy works only if each level **composes** the level below it cleanly. This skill is the toolbox for that.

## The seven patterns

### 1. Plain props

The default. Pass values, render output. Use for atoms and simple molecules where every variant is bounded.

```tsx
<Button variant="primary" size="md" disabled>Save</Button>
```

When it stops working: too many props, too many "if X then Y" combinations, props that are really shaping the *internals* (e.g. `iconBefore`, `iconAfter`, `iconBeforeColor`).

### 2. `children` slot

The single-slot escape hatch. Anything passed as `children` renders inside.

```tsx
<Card>
  <h3>Title</h3>
  <p>Body</p>
</Card>
```

Use when: there's exactly one variable region, and consumers need full control over its contents.

### 3. Named slots (multi-`children`)

When more than one region varies, expose **named slots** as props.

```tsx
<Card
  header={<CardHeader title="Hello" />}
  footer={<Button>Save</Button>}
>
  Card body content here.
</Card>
```

Or, equivalently, with a slot object:

```tsx
<Card slots={{ header: <CardHeader />, footer: <Button>Save</Button> }}>
  Card body
</Card>
```

Use when: the structure is fixed but each region varies. Avoid when: regions are siblings of each other and order matters — that's compound components.

### 4. Compound components

Multiple components share implicit state via context. The parent is the "shell"; children are named pieces.

```tsx
<Tabs defaultValue="overview">
  <Tabs.List>
    <Tabs.Trigger value="overview">Overview</Tabs.Trigger>
    <Tabs.Trigger value="details">Details</Tabs.Trigger>
  </Tabs.List>
  <Tabs.Panel value="overview">…</Tabs.Panel>
  <Tabs.Panel value="details">…</Tabs.Panel>
</Tabs>
```

Use when: structure has variable order, repetition, or omission of pieces. Tabs, Accordion, Menu, RadioGroup, Tooltip, Form, Table.

Implementation:

```tsx
const TabsCtx = React.createContext<TabsState | null>(null);

export function Tabs({ defaultValue, children }: TabsProps) {
  const [value, setValue] = React.useState(defaultValue);
  return <TabsCtx.Provider value={{ value, setValue }}>{children}</TabsCtx.Provider>;
}
Tabs.List = TabsList;
Tabs.Trigger = TabsTrigger;
Tabs.Panel = TabsPanel;
```

### 5. Render props / function children

The component owns logic; the consumer owns rendering.

```tsx
<Combobox items={items}>
  {({ getInputProps, getMenuProps, isOpen, highlighted, items }) => (
    <>
      <input {...getInputProps()} />
      {isOpen && <ul {...getMenuProps()}>{items.map(...)}</ul>}
    </>
  )}
</Combobox>
```

Use when: behavior is generic, presentation is wildly variable per consumer (downshift-style headless components). Often called **headless components**.

### 6. Polymorphic `as` / `asChild`

Let the consumer choose the underlying element while preserving styles and behavior.

**`as` prop**:
```tsx
<Button as="a" href="/profile">View profile</Button>
```

**`asChild` (Radix-style)** — render the styles onto the consumer's child element:
```tsx
<Button asChild>
  <Link href="/profile">View profile</Link>
</Button>
```

`asChild` is generally cleaner because it avoids the prop-forwarding gymnastics of `as`. Use Radix's `Slot` primitive (or a clone) to implement it.

### 7. Headless + skin

Split the component in two: a **headless** package owns logic and accessibility, a **skin** package owns visuals. The most flexible (and most expensive to build) pattern.

Use when: you ship a public component library that downstream apps want to restyle without forking. Examples: Radix UI + Radix Themes, Headless UI + Tailwind UI, React Aria + your design system.

## Choosing a pattern by atomic level

| Level | Default pattern | When to upgrade |
|---|---|---|
| Atoms | Plain props | Add `asChild` if it might polymorph (Button → Link). |
| Molecules | Plain props + `children` for one slot | Named slots when ≥2 regions vary. |
| Organisms | Compound components OR named slots | Render props / headless when behavior is generic but presentation isn't. |
| Templates | Named slots | Always. Templates are slot machines. |
| Pages | Direct composition of organisms | No abstraction needed — pages are the bottom of the tree. |

## Controlled vs uncontrolled

Every interactive component has internal state (open, selected, value). API design choice: who owns it?

- **Uncontrolled**: component owns state. `defaultValue` initializes, `onChange` reports. Simpler for consumers.
- **Controlled**: consumer owns state. `value` + `onChange`. Necessary when state is derived or shared.
- **Hybrid (recommended)**: support both. If `value` is provided, controlled; else, internal `useState` initialized by `defaultValue`.

```tsx
function useControllableState<T>({ value, defaultValue, onChange }: {
  value?: T; defaultValue: T; onChange?: (v: T) => void;
}) {
  const [internal, setInternal] = React.useState(defaultValue);
  const isControlled = value !== undefined;
  const current = isControlled ? value : internal;
  const setCurrent = (next: T) => {
    if (!isControlled) setInternal(next);
    onChange?.(next);
  };
  return [current, setCurrent] as const;
}
```

Document which mode each component supports.

## Forwarding refs and props

Atoms and small molecules **must forward refs** so consumers can manage focus, measure, attach observers.

```tsx
export const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
  ({ children, ...rest }, ref) => <button ref={ref} {...rest}>{children}</button>
);
```

If you spread unknown props onto the underlying element, declare so in types and behavior. Either spread fully (`...rest`) or filter explicitly — never silently drop props.

## API design heuristics

1. **Small surface area first.** Prefer 5 props that compose well over 25 props that try to cover every case.
2. **Booleans for binary state, enums for variants.** Never `primary={true}`. Use `variant="primary"` so it scales.
3. **Slots beat 10 boolean props.** If you have `iconBefore` *and* `iconAfter` *and* `subtitle` *and* `meta` *and* `footer`, the answer is named slots, not more props.
4. **Don't expose internals through props.** `headerStyle`, `headerClassName`, `headerComponent` are smells. Use slots and let the consumer pass a styled child.
5. **No "kitchen sink" props.** A `config` prop that takes 30 fields is a class definition, not a component.
6. **Return primitives, not strings.** `onChange(value, event)`, not `onChange(JSON.stringify(value))`. Consumers serialize.
7. **Provide hooks for headless logic.** A `useDisclosure()` hook can power `Modal`, `Drawer`, `Popover`. Don't build three near-identical components — share the hook, vary the skin.

## Avoiding "prop tunneling"

When a parent renders an organism deep through layers, and a leaf needs a value, you have two bad choices: drill the prop, or reach for global state. The third option:

- **Compound components with context**: parent puts state in context; leaves read it. Encapsulated to the component, not global.
- **Slot exposure**: instead of leaf-level configuration, let the consumer pass a configured leaf as a slot.

```tsx
// bad: prop tunneling
<DataTable density="compact" />
  // …passes density to TableRow, then to TableCell, then to TableCellContent…

// good: compound + context
<DataTable density="compact">
  <DataTable.Row>…</DataTable.Row>
</DataTable>
```

## Composition smells (atomic-design specific)

- **An atom that imports another atom.** Either it's a molecule, or you're working around a missing prop. Investigate.
- **A molecule that imports an organism.** Forbidden. Restructure.
- **A "molecule" with 800 lines and a reducer.** It's an organism. Promote.
- **Two molecules differ only in CSS.** They should be one molecule with a `variant` prop, or share a base via composition.
- **A "compound component" with one child.** It's just a wrapper. Inline it.
- **`<Card><CardHeader/><CardBody/><CardFooter/></Card>` where every consumer always uses all three in order.** That's named slots, not compound. Switch.
- **Polymorphic `as` used to render a `<div>` as a `<button>`.** Use `asChild` and pass a real `<button>`, or accept the `as` and ensure semantic + a11y attributes follow.

## Generic primitive registry

The design system ships a **fixed set of generic primitives**. Before any agent or human concludes "this is a new component," they must check this registry. A candidate whose root element + tree-shape signature matches an entry below is **not** a new component — it is a `variant` of, a composition of, or a domain-named misnomer for, the existing primitive.

The registry is consumed by the `component-composer` agent's "decide" step and by the audit pipeline (`/audit-organisms`, `/audit-molecules`). It is the single source of truth for the question "does a primitive with this shape already exist?"

| Primitive | Tier | Required slots | Variant axis | Tells you to NEW only when… |
|---|---|---|---|---|
| `Text` | atom | (children) | `as` (h1..h6 / p / span), `tone`, `size` | the candidate is not text. |
| `Icon` | atom | (name) | `name`, `size`, `tone` | the candidate is not a single glyph. |
| `Button` | atom | `children` | `variant` (primary / secondary / ghost / destructive), `size`, `asChild` | the candidate is not click-to-act. |
| `IconButton` | atom | `icon` | `variant`, `size`, `aria-label` (required) | the candidate has a text label as well — that's `Button` with `iconBefore`. |
| `Link` | atom | `children` | `variant`, `as`/`asChild` | the candidate is not navigation. |
| `Chip` | atom | `children` | `variant` (filled / outline / soft), `tone`, `removable` | the candidate has interactive sub-regions beyond label + dismiss — that's `ChipBar` row. |
| `Badge` | atom | `children` | `variant`, `tone` | never — `Badge` covers all status pills. |
| `Pip` | atom | — | `tone`, `size` | never — `Pip` covers all single-color status dots. |
| `Divider` | atom | — | `orientation`, `tone` | never. |
| `ListItem` | molecule | `leading`, `body`, `trailing` | `variant` (default / compact / dense), `as` | the candidate is not a row in a vertical list of like items. |
| `MediaCard` | molecule | `media`, `body`, `footer` | `variant` (filled / outline / ghost), `orientation` (vertical / horizontal), `aspect` | the candidate is not a media-plus-text card. **All `*Card`-suffixed candidates (BrandCard, LicenceCard, PricingTier, MarketingFeatureTile, PlatformCard, etc.) collapse here.** |
| `SummaryCard` | molecule | `title`, `body`, `actions` | `variant`, `tone` | the candidate is not a labelled summary block. |
| `LineItemList` | molecule | `items[]` (each with `label`, `value`) | `variant`, `dense` | the candidate is not a label-value table-like list. |
| `TotalRow` | molecule | `label`, `value` | `variant` (subtotal / total / discount), `tone` | never — every total/subtotal/footer-row is this. |
| `OptionPicker` | molecule | `options[]` (each with `value`, `label`, optional `icon`/`description`) | `variant` (segmented / radio-card / chip-grid), `multiple` | the candidate is not "pick 1+ from N visible options." **All `*Picker` and visible-radio-set candidates collapse here.** |
| `LogoStrip` | molecule | `items[]` (each: `src`/`logo`, optional `href`) | `variant` (rail / wall / scroll), `density` | the candidate is not a row of logos. **`BrandStrip`, `EcosystemRail`, `TrustStrip` all collapse here.** |
| `ChipBar` | molecule | `chips[]` | `variant`, `scrollable` | the candidate is not a horizontal row of `Chip`s. |
| `FilterPanel` | organism | `filters[]`, `actions` | `variant` (sidebar / drawer / popover), `collapsible` | the candidate is not a group of filter controls. |
| `Card` | molecule | `header`, `body`, `footer` | `variant`, `tone`, `interactive` | the candidate is not a bounded content surface. Prefer `MediaCard` / `SummaryCard` first. |
| `Hero` | organism | `eyebrow`, `headline`, `body`, `media`, `actions` | `variant` (centered / split / stacked), `tone` | the candidate is not a top-of-page banner. |
| `Stepper` | molecule | `steps[]` | `variant` (numbered / dotted / progress), `orientation` | the candidate is not "show ordered progress through N steps." |
| `Wizard` | organism | `Stepper`, `Panel` (current step body), `actions` | `variant`, `linear` (boolean) | the candidate is not "multi-step form/flow with navigation." |
| `Modal` | organism | `header`, `body`, `footer` | `size`, `dismissible` | the candidate is not a focus-trapped centered overlay. |
| `Drawer` | organism | `header`, `body`, `footer` | `side` (left / right / top / bottom), `size` | the candidate is not an edge-anchored overlay. |
| `Sheet` | organism | `header`, `body`, `footer` | `variant` (bottom / side), `snapPoints` | the candidate is not a draggable/snappable surface (mobile-leaning). Prefer `Drawer` on web. |

**Naming rule that follows from the registry:** primitives are domain-agnostic nouns (`Card`, `LogoStrip`, `OptionPicker`). A name like `BrandCard`, `PricingTier`, or `LicenceCard` encodes a **domain** in the component identifier and is therefore a smell — see the pre-flight below.

## REUSE-vs-EXTEND-vs-NEW pre-flight

Before any agent or human concludes verdict `BUILD-NEW`, run this rubric. The `component-composer` agent applies it as a hard gate: a `BUILD-NEW` verdict that did not pass all four checks is rejected.

### (a) Structural-shape lookup

Compute the candidate's structural signature: `{ root_element, ordered_child_kinds, slot_count, has_media, has_actions, repetition_axis }`.

Match against every row of the **Generic primitive registry** above. If the signature matches an entry's `Required slots` + `Variant axis` envelope, the registry entry **owns that shape**.

### (b) If shape matches → EXTEND or COMPOSE

When the lookup hits an existing primitive:

- If the candidate differs from the matched primitive only in **one bounded dimension** (visual variant, density, orientation, tone) → verdict is **EXTEND** the matched primitive with a new value on its `variant` (or other variant-axis) prop. Adding the value must be additive — no rename of existing values, no breaking signature change.
- If the candidate differs by **populating slots with specific children** (e.g., a media block + a body block + an actions block) → verdict is **COMPOSE**: instantiate the matched primitive with those slots filled. Do not create a new component; create a **story** (or, if the composition is reused ≥ 3 times, a thin domain-named wrapper that *only* fills slots — never re-implements the primitive's internals).

### (c) Domain-prefix rename check

If the candidate's name fits the pattern `<Domain><PrimitiveSuffix>` (e.g., `BrandCard`, `LicenceCard`, `MarketingFeatureTile`, `PlatformCard`, `PricingTier`, `BrandStrip`, `EcosystemRail`, `TrustStrip`, `*Picker`, `*Row`, `*Item`) **and** a registry entry exists with that suffix (or a synonym: `Tile` → `MediaCard`, `Strip` / `Rail` → `LogoStrip`, `Tier` → `MediaCard`/`SummaryCard`, `Row` → `ListItem` / `TotalRow`, `Picker` → `OptionPicker`) → verdict is **RENAME-AND-COMPOSE**:

1. Drop the domain prefix from the component identifier.
2. Realise the candidate as a story (or, if reused ≥ 3 times, a thin wrapper named after the *use-case* in the consumer app — not in the design system).
3. The verdict is **never** `BUILD-NEW` in this branch. Even if the consumer wants a different look, that is an EXTEND on the matched primitive's variant axis.

### (d) BUILD-NEW only when both checks miss

`BUILD-NEW` is permitted **only** when:

1. The structural-shape lookup (a) returns no match in the registry, **and**
2. The domain-prefix rename check (c) returns no match, **and**
3. The proposed new component itself satisfies the **genericness rubric** (see the `genericness-rubric` skill): no domain prefix in the name, accepts slots over per-internal-region props, exposes a `variant` axis if it has > 1 visual mode, ships at the lowest atomic tier its responsibilities allow.

A `BUILD-NEW` verdict that fails any of (1)–(3) is invalid and the composer must downgrade to EXTEND, COMPOSE, or RENAME-AND-COMPOSE.

### Pre-flight worked examples

- `BrandCard` (image + title + body + CTA) → (a) matches `MediaCard`; (c) `Brand` + `Card` is a domain prefix on the `Card` family → verdict **RENAME-AND-COMPOSE** as `<MediaCard variant="brand">…</MediaCard>` (or just a story over `MediaCard`).
- `EcosystemRail` (horizontal row of logos) → (a) matches `LogoStrip`; (c) `Ecosystem` + `Rail` matches the `Strip`/`Rail` synonym → verdict **RENAME-AND-COMPOSE** as `<LogoStrip variant="rail" items={…} />`.
- `TimelineDial` (radial concentric step indicator with tick marks at angular positions) → (a) no row's signature matches a radial layout; (c) no registry suffix matches `Dial` → verdict **BUILD-NEW** is permitted, provided the new component is named `Dial` (no domain prefix) and accepts slots.

## Testing composition

- A component's stories should include each composition pattern it supports — see `storybook-atomic-integration` for required stories.
- Compound components need a story that uses *all* sub-components, and one that uses *only some* (omits panels, etc.) to prove the API isn't load-bearing on full use.
- Headless components need stories that demonstrate at least two visually different skins.

## Composition + TanStack abstractions

Composition patterns and TanStack abstractions stack rather than compete. The `tanstack-integration` skill specifies the prop shapes; the patterns here say *how* a component exposes those props through composition:

- A **field-friendly atom** (Input / Checkbox / Select / Slider) uses **plain props + forwarded refs** — the simplest pattern. Its `value` / `onChange` / `onBlur` props match TanStack Form's `field`.
- A **`FormField` molecule** uses **named slots** (`label`, `helper`, error rendering) and accepts a TanStack Form `field` as its primary prop. Its `as` prop is **polymorphic** (defaulting to `Input`) so the same molecule wraps different field-friendly atoms.
- A **`DataTable` organism** uses **plain props** to receive a TanStack Table `table` instance — never raw `data + columns`. The columns themselves use **render props** for cell content (TanStack Table's `flexRender`).
- A **list / grid organism** uses **plain props** to receive a TanStack DB collection's live-query result. Pagination / virtualization wrap with **compound components** (`<List.Header />`, `<List.Empty />`, `<List.Row />`).
- A **headless wrapper** for behavior (e.g. drag + drop with @dnd-kit) uses **render props or compound components** so consumers own the visual layer.

The audit workflows verify the composition pattern matches the TanStack abstraction at the right level.

## Relationship to other skills in this plugin

- **`atomic-design`** — the level boundaries this skill respects.
- **`storybook-atomic-integration`** — the story coverage that *demonstrates* each composition.
- **`design-tokens`** — the styling layer composition routes around.
- **`approved-libraries`** — the bouncer-list of libraries the composition routes around.
- **`tanstack-integration`** — the prop shapes that make composition compose with TanStack Form / Table / DB.
- **`genericness-rubric`** — the per-component test for "is this name and shape generic enough to ship?" The pre-flight above defers to this skill for clause (d)(3); load it whenever you are evaluating a `BUILD-NEW` candidate on its own terms.
