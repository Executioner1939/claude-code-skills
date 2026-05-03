---
name: storybook-story-writing
user-invocable: false
description: Deeper-dive companion to `storybook-authoring`. Patterns for writing CSF Factories stories at depth — `preview.meta` / `meta.story` factory chain, `.test()` inline tests, story extension patterns, `loaders` for async setup, default vs per-story decorators, render-fn escape hatches, naming for sidebar scannability, and the anti-patterns that make stories drift over time. Storybook 10 (React). CSF3 patterns are not in this skill; see `_migration/migration-storybook-7-to-10.md` for upgrades. Auto-loads on `*.stories.*` files.
when_to_use: Writing CSF Factories stories at depth, refactoring CSF3 to Factories, deciding when to use `.test()` vs `play`, structuring story extensions, applying decorators per-story, naming conventions.
paths: "**/*.stories.@(ts|tsx|js|jsx)"
---

# Storybook story writing (CSF Factories)

Storybook 10 on React. (Vue / Angular / Web Components factories rolled out across the 10.x line.) This skill covers the patterns deeper than the overview in `storybook-authoring`.

## The factory chain

CSF Factories is a chain of three function calls:

```text
definePreview  →  preview.meta  →  meta.story
```

- `definePreview` lives in `.storybook/preview.ts`. Sets project-wide addons, parameters, decorators.
- `preview.meta(...)` is called once per stories file. Defines the component-level meta. Returns a `meta` object whose types are inferred from the `component`.
- `meta.story(...)` produces each named story.

Every layer feeds the next — no repeated type imports, no `Meta<typeof X>` ceremony.

## Minimal example

```tsx
import preview from '../.storybook/preview';
import { Button } from './Button';

const meta = preview.meta({
  title: 'Atoms/Button',
  component: Button,
  tags: ['autodocs'],
  args: { children: 'Click me' },
  argTypes: {
    variant: { control: 'select', options: ['primary', 'secondary', 'ghost'] },
    size:    { control: 'radio',  options: ['sm', 'md', 'lg'] },
    onClick: { action: 'clicked' },
  },
  parameters: { layout: 'centered' },
});

export const Primary    = meta.story({ args: { variant: 'primary' } });
export const Secondary  = meta.story({ args: { variant: 'secondary' } });
export const Ghost      = meta.story({ args: { variant: 'ghost' } });
export const Loading    = meta.story({ args: { loading: true } });
export const Disabled   = meta.story({ args: { disabled: true } });
```

`Default` is the convention for the canonical example — by convention the **first export**. Either name a story `Default` (clearer in the sidebar) or rename `Primary` to `Default` if there's no variant axis.

## `.test()` — inline test attachment

A factory story can attach a Vitest browser-mode test directly via `.test()`:

```tsx
import { userEvent, expect, fn } from '@storybook/test';

export const SubmitsForm = meta.story({
  args: { onSubmit: fn() },
}).test(async ({ canvas, args, step }) => {
  await step('fill the form', async () => {
    await userEvent.type(canvas.getByLabelText(/email/i), 'a@b.co');
  });
  await step('submit', async () => {
    await userEvent.click(canvas.getByRole('button', { name: /submit/i }));
  });
  await expect(args.onSubmit).toHaveBeenCalledOnce();
});
```

`.test()` and `play` are functionally similar; `.test()` is the modern form for tests *specifically* (Vitest treats it as a test, not just a playbook). Use `.test()` when the story exists primarily to verify behavior; use `play` when the story is a normal demo with an interaction.

## Extending a story (avoid duplicating args)

Stories share defaults via meta. When a single story has a near-duplicate, extend the source story rather than copy-pasting args:

```tsx
const Base = meta.story({
  args: { label: 'Save', variant: 'primary' },
});

export const SaveDestructive = Base.extend({
  args: { variant: 'destructive', label: 'Delete account' },
});
```

`.extend()` shallow-merges args / parameters / decorators / tags. Use it when:
- A story differs from another by 1–2 props.
- You want a "states" pair (default + hover) without duplicating the base.

## Loaders — async setup before render

When a story needs data loaded before render (mock fixtures, async permission checks, MSW seeding), use `loaders`:

```tsx
export const PopulatedTable = meta.story({
  loaders: [
    async () => ({
      users: await fetch('/mock/users.json').then((r) => r.json()),
    }),
  ],
  render: (args, { loaded }) => <UserTable users={loaded.users} {...args} />,
});
```

Loader output is available in `play` / `.test()` and `render` via the `loaded` field.

## Decorators — meta-level vs per-story

Meta-level decorators wrap **every** story. Use for theme / router / store / locale providers:

```tsx
const meta = preview.meta({
  component: Modal,
  decorators: [
    (Story) => (
      <ThemeProvider theme={lightTheme}>
        <Story />
      </ThemeProvider>
    ),
  ],
});
```

Per-story decorators run **inside** meta decorators. Use for story-specific context (a different theme, a route override, a fixture provider):

```tsx
export const Dark = meta.story({
  decorators: [(Story) => <ThemeProvider theme={darkTheme}><Story /></ThemeProvider>],
});
```

## Render escape hatch — use sparingly

When `args` can't drive the component (e.g. compound children, controlled state owned outside), use `render`:

```tsx
export const ControlledTabs = meta.story({
  render: (args) => {
    const [value, setValue] = React.useState('overview');
    return (
      <Tabs value={value} onValueChange={setValue} {...args}>
        <Tabs.List>
          <Tabs.Trigger value="overview">Overview</Tabs.Trigger>
          <Tabs.Trigger value="details">Details</Tabs.Trigger>
        </Tabs.List>
        <Tabs.Panel value="overview">…</Tabs.Panel>
        <Tabs.Panel value="details">…</Tabs.Panel>
      </Tabs>
    );
  },
});
```

If you find yourself reaching for `render` in every story, your component API isn't args-driven enough. Fix the component, not the stories.

## Sidebar conventions

`title` segments map to the sidebar tree. For atomic design:

```tsx
title: 'Atoms/Button'
title: 'Atoms/Form/Input'         // 2nd-level grouping when a level is busy
title: 'Molecules/SearchBar'
title: 'Organisms/DataTable'
title: 'Templates/DashboardTemplate'
title: 'Pages/UserDashboard'
```

Cap depth at 3 segments. Capitalize each segment. Pluralize the atomic-level segment (`Atoms`, not `Atom`).

## Story export naming

| Pattern | Example | When |
|---|---|---|
| `Default` | `Default` | Canonical example. **First export.** Always. |
| Variant | `Primary`, `Secondary`, `Ghost` | One per `variant` value. |
| Size | `Small`, `Medium`, `Large` | One per `size` value. |
| State | `Disabled`, `Loading`, `Empty`, `Error` | One per discrete component state. |
| Slot | `WithIcon`, `WithCaption`, `WithFooter` | Demonstrates a slot filled. |
| Stress | `LongText`, `LongTitle`, `ManyItems`, `Truncated` | Robustness stress tests. |
| Layout | `RTL`, `Mobile`, `Tablet`, `Desktop` | Wrapped in a viewport / direction decorator. |
| Interaction | `SubmitsForm`, `OpensMenu`, `Cancels` | Verb-prefixed. Has `.test()` or `play`. |
| Permission | `RoleAdmin`, `RoleViewer`, `Forbidden` | Different prop config per permission. |
| Theme | `Dark`, `HighContrast` | Wrapped in a theme decorator. |

PascalCase. No `Story1` / `Test`. No `default` export with a vague name.

## Tags

`tags` filter and group stories.

| Tag | Effect |
|---|---|
| `'autodocs'` | Generates a Docs page from this meta. Set at meta level. |
| `'!autodocs'` | Excludes a single story from the auto-generated Docs page. |
| `'test'` | Includes in test runs (default). |
| `'!test'` | Excludes from test runs (e.g. intentionally-broken demo stories). |
| `'stable'` / `'experimental'` / custom | Sidebar-filterable in the UI. |

## What the audit checks

`/design-storybook-atomic:audit-atomic` (and the molecule / organism variants) verify:

- ✅ File uses **CSF Factories** (`preview.meta` / `meta.story`). CSF3 = downgrade. CSF2 / `storiesOf` = auto-fail.
- ✅ Imports come from the framework package (`@storybook/react-vite`, etc.).
- ✅ `Default` is the first export.
- ✅ Story names match the table above.
- ✅ Decorators handle providers (no inline providers in `render`).
- ✅ No console.log, console.error in stories.
- ✅ `tags: ['autodocs']` present at meta level.
- ✅ Required stories per atomic level are present (see `story-coverage-checklist`).

## Anti-patterns

### ❌ Render in every story

```tsx
// BAD
export const Primary = meta.story({
  render: (args) => <Button {...args} variant="primary" />,
});
```

If you have to render in every story, your component is not args-driven. Either fix the component or use `args` for the variant:

```tsx
// GOOD
export const Primary = meta.story({ args: { variant: 'primary' } });
```

### ❌ Inline children that defeat Controls

```tsx
// BAD — controls show no editable label
export const Primary = meta.story({
  render: (args) => <Button {...args}>Click me</Button>,
});

// GOOD — children in args, editable in Controls
export const Primary = meta.story({
  args: { children: 'Click me', variant: 'primary' },
});
```

### ❌ Decorators that mutate global state

A decorator that calls `localStorage.setItem` or modifies a global store leaks across stories. Set state via `loaders` or `parameters.beforeEach` instead.

### ❌ Stories that only differ in `parameters.docs`

Combine them; use Doc Blocks (Canvas + Source) in MDX instead.

### ❌ One catch-all story with every state stuffed in via Controls

If the component has 5 states, write 5 stories. Controls are for tweaking, not for documenting state coverage.

## Relationship to other skills in this plugin

- **`storybook-authoring`** — the overview that this skill complements.
- **`storybook-args-controls`** — argTypes + Controls in depth.
- **`storybook-component-documentation`** — MDX docs pages.
- **`storybook-play-functions`** — interaction tests.
- **`storybook-configuration`** — `.storybook/main.ts` + preview setup.
- **`storybook-atomic-integration`** — required-story tables per atomic level.
