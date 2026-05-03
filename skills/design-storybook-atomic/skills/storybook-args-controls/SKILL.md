---
name: storybook-args-controls
user-invocable: false
description: argTypes, Controls, Actions, and arg inheritance in CSF Factories on Storybook 10. Auto-loads on `*.stories.*` files. Covers control-type selection, conditional controls (`if: { arg: ... }`), table grouping, action wiring (`{ action: 'clicked' }`) vs `fn()` spies from `@storybook/test`, dynamic argTypes, and the patterns that make Controls the most useful debug surface in the dev loop.
when_to_use: Choosing control types, configuring argTypes, wiring action callbacks, grouping props in the Controls table, debouncing expensive arg changes, deciding `fn()` vs `action()`.
paths: "**/*.stories.@(ts|tsx|js|jsx)"
---

# Storybook args & controls

Args are the inputs to a component. Controls is the addon that lets you edit them in the toolbar live. argTypes is how you tell Storybook what each arg means.

This skill is the depth reference. The 30-second overview lives in `storybook-authoring`.

## Args vs argTypes vs parameters

- **args** — actual values. Drive the component. Inherited from `meta` to each story; per-story args merge on top.
- **argTypes** — metadata about each arg. What control to show. Whether to log it. Whether to hide it from Controls. Description text.
- **parameters** — story-level config that isn't args. Layout, viewport, backgrounds, a11y, msw.

In CSF Factories:

```tsx
const meta = preview.meta({
  component: Button,
  args: { children: 'Click me' },                    // values
  argTypes: { variant: { control: 'select', … } },   // metadata
  parameters: { layout: 'centered' },                // config
});
```

## Control types

| Control | Use for |
|---|---|
| `'text'` | Strings. Default for `string` props if no `argTypes` declared. |
| `'number'` | Numbers, with optional `{ min, max, step }`. |
| `'boolean'` | Booleans. Renders as toggle. |
| `'color'` | Color picker. |
| `'date'` | Date picker. Returns a `Date` object. |
| `'select'` | Dropdown. Requires `options`. |
| `'multi-select'` | Multi-select. Requires `options`. |
| `'radio'` | Radio buttons. Requires `options`. Better than select for small enums. |
| `'inline-radio'` | Radios laid out horizontally. Best for 2–4 options. |
| `'check'` | Checkboxes for arrays. Requires `options`. |
| `'inline-check'` | Inline checkboxes. |
| `'range'` | Slider. Requires `{ min, max, step }`. |
| `'object'` | JSON editor. For nested objects / arrays. |
| `'file'` | File picker (for `File` / `FileList` props). |
| `false` | Disable the control entirely (use when a prop is set in args but shouldn't be editable). |

```tsx
argTypes: {
  variant:  { control: 'select', options: ['primary', 'secondary', 'ghost'] },
  size:     { control: 'inline-radio', options: ['sm', 'md', 'lg'] },
  count:    { control: { type: 'number', min: 0, max: 100, step: 1 } },
  color:    { control: 'color' },
  metadata: { control: 'object' },
  onClick:  { action: 'clicked' },
  data:     { control: false },                                 // hidden from Controls (set in args)
  className:{ table: { disable: true } },                       // hidden from Controls AND from props table
}
```

## Inferring controls from TypeScript

Storybook's react-docgen-typescript reads the prop interface and infers controls. You don't have to declare argTypes for every prop — only override when the inference is wrong or when you want a tighter control type.

```tsx
type ButtonProps = {
  variant?: 'primary' | 'secondary' | 'ghost';
  size?: 'sm' | 'md' | 'lg';
  disabled?: boolean;
  onClick?: () => void;
};
```

Inferred controls:
- `variant` → `select` with options inferred from the union.
- `size` → `select`, same.
- `disabled` → `boolean`.
- `onClick` → no control (callbacks aren't editable).

You'd still add `argTypes.onClick: { action: 'clicked' }` to log fires in the Actions panel — see below.

## Conditional controls (`if`)

Show a control only when another arg has a particular value:

```tsx
argTypes: {
  type: { control: 'select', options: ['text', 'number', 'password'] },
  min:  { control: 'number', if: { arg: 'type', eq: 'number' } },
  max:  { control: 'number', if: { arg: 'type', eq: 'number' } },
  showPasswordToggle: { control: 'boolean', if: { arg: 'type', eq: 'password' } },
}
```

Operators: `eq`, `neq`, `truthy`, `exists`. Use `truthy` for "any non-falsy value":

```tsx
errorMessage: { control: 'text', if: { arg: 'isInvalid', truthy: true } },
```

## Table grouping

Group related props under the Controls / Docs table:

```tsx
argTypes: {
  // Appearance
  variant: { control: 'select', options: [...], table: { category: 'Appearance' } },
  size:    { control: 'radio',  options: [...], table: { category: 'Appearance' } },

  // Behavior
  closeOnEscape: { control: 'boolean', table: { category: 'Behavior' } },
  closeOnOverlayClick: { control: 'boolean', table: { category: 'Behavior' } },

  // Events
  onClose: { action: 'closed', table: { category: 'Events' } },
  onOpen:  { action: 'opened', table: { category: 'Events' } },
}
```

Grouping is essential for components with > 8 props. Without it, the Controls panel becomes unscannable.

## Actions: `{ action }` vs `fn()`

Two ways to log callback fires:

### `{ action: 'name' }` argType — UI-only logging

```tsx
argTypes: {
  onClick: { action: 'clicked' },
}
```

Fires get logged to the Actions panel. Good enough when you only need to *see* that the callback fired.

### `fn()` from `@storybook/test` — spy + logging + assertable

```tsx
import { fn } from '@storybook/test';

const meta = preview.meta({
  component: Button,
  args: { onClick: fn() },
});

// In a play function or .test():
await userEvent.click(canvas.getByRole('button'));
await expect(args.onClick).toHaveBeenCalledOnce();
await expect(args.onClick).toHaveBeenCalledWith(expect.any(Object));
```

`fn()` is a real Vitest spy. It logs to the Actions panel AND can be asserted in `.test()` / `play`. Use `fn()` whenever a story will be tested.

**Rule of thumb**: prefer `fn()` in `args`. Use `{ action: 'name' }` only for "drive-by" callbacks you don't want to ship a default for.

## Disabling controls vs disabling table entries

```tsx
argTypes: {
  // Hidden from Controls (no editor), still shown in props table:
  data: { control: false },

  // Hidden from BOTH Controls and props table (use for internal / spread props):
  className: { table: { disable: true } },

  // Marked deprecated in props table, still editable:
  legacyProp: { table: { type: { summary: 'string', detail: '@deprecated since v2' } } },
}
```

## argType `description` and `table.type`

Override the inferred type display in the props table:

```tsx
argTypes: {
  data: {
    description: 'Array of records to render. Each record must have a unique id.',
    table: {
      type: { summary: 'Item[]', detail: 'type Item = { id: string; name: string; … }' },
      defaultValue: { summary: '[]' },
    },
  },
}
```

JSDoc on the prop interface is preferred (single source of truth) — this override is for cases where docgen can't extract the relevant type from a complex generic.

## Dynamic argTypes

`argTypes` can be a function that receives the args:

```tsx
const meta = preview.meta({
  component: Slider,
  args: { min: 0, max: 100, value: 50 },
  argTypes: (args) => ({
    value: { control: { type: 'range', min: args.min, max: args.max, step: 1 } },
  }),
});
```

The slider control adjusts as `min` / `max` change.

## `parameters.controls`

Project-wide control behavior tweaks (set in `definePreview` or per-meta):

```tsx
parameters: {
  controls: {
    expanded: true,                                 // expand the Controls panel by default
    sort: 'requiredFirst',                          // sort: 'alpha' | 'requiredFirst' | 'none'
    matchers: {
      color: /(background|color)$/i,               // auto-detect color controls by name
      date: /Date$/i,
    },
    exclude: ['className', 'style'],                // hide these props globally
    include: ['variant', 'size', 'children'],       // OR show only these
  },
}
```

Set the matchers in `.storybook/preview.ts` once. Saves declaring `control: 'color'` on every color prop in every component.

## Anti-patterns

### ❌ Logging via `console.log` in story args

```tsx
// BAD
args: { onClick: () => console.log('clicked') },
```

Use `fn()` or `{ action: 'clicked' }`. Console logs are invisible in Storybook's UI.

### ❌ Mock data in `control: 'object'`

Editable objects + 1000-row datasets = the editor freezes. Set `control: false` on big mock data:

```tsx
argTypes: { items: { control: false } },
args: { items: largeMockDataset },
```

### ❌ argTypes that duplicate TypeScript types

If your prop is `variant?: 'primary' | 'secondary'`, Storybook infers the control. Adding `argTypes.variant.options: ['primary', 'secondary']` is redundant and drifts when you add a third variant. Only override when you need control type, description, or grouping.

### ❌ Per-story argTypes that vary from meta-level

If every story has its own argTypes overrides, the meta-level argTypes is wrong. Update meta.

## What the audit checks

`/design-storybook-atomic:audit-*` verify:

- ✅ Every prop has at least an inferred argType (i.e. a docgen-readable interface).
- ✅ Callbacks use `fn()` (preferred) or `{ action: 'name' }`.
- ✅ Mock data / large objects are not editable in Controls (`control: false`).
- ✅ argType `description` exists for any prop whose name isn't self-explanatory.
- ✅ Components with > 8 props use `table.category` grouping.

## Relationship to other skills in this plugin

- **`storybook-story-writing`** — the broader story patterns this skill complements.
- **`storybook-component-documentation`** — argTypes feed the auto-generated props table in MDX.
- **`storybook-play-functions`** — `fn()` spies are asserted there.
