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

## Testing composition

- A component's stories should include each composition pattern it supports — see `storybook-atomic-integration` for required stories.
- Compound components need a story that uses *all* sub-components, and one that uses *only some* (omits panels, etc.) to prove the API isn't load-bearing on full use.
- Headless components need stories that demonstrate at least two visually different skins.

## Relationship to other skills in this plugin

- **`atomic-design`** — the level boundaries this skill respects.
- **`storybook-atomic-integration`** — the story coverage that *demonstrates* each composition.
- **`design-tokens`** — the styling layer composition routes around.
