---
name: storybook-authoring
description: Storybook 10 authoring — CSF Factories (`preview.meta` / `meta.story`) as the only accepted format. Covers `defineMain` / `definePreview` config, framework-specific packages (`@storybook/react-vite`, `@storybook/nextjs-vite`, etc.), MDX docs with `@storybook/addon-docs/blocks`, autodocs, args, argTypes, controls, decorators, parameters, `play` and `.test()` interaction tests with `@storybook/test`, the official `@storybook/addon-a11y`, `@storybook/addon-vitest` browser-mode testing, and portable stories via `composeStories`. Load on any `*.stories.*`, `*.mdx`, or `.storybook/**` file. Projects on Storybook 7 / 8 or CSF3 — see `_migration/migration-storybook-7-to-10.md`.
when_to_use: Writing CSF Factories stories, configuring `defineMain` / `definePreview`, addon-vitest setup, addon-a11y setup, portable stories, choosing args vs argTypes, decorators / parameters, theming the canvas, organizing the sidebar.
paths: "**/*.stories.@(ts|tsx|js|jsx), **/*.mdx, **/.storybook/**, **/storybook.config.*, **/vitest.config.*"
allowed-tools: Read, Grep, Glob
---

# Storybook authoring

**Storybook 10** with **CSF Factories** is the only accepted format under this design system. Pre-Factories formats (CSF3 object syntax, CSF2 `Template.bind`, `storiesOf`) are migration targets — see `_migration/migration-storybook-7-to-10.md`. Audits in this plugin auto-fail on CSF2; downgrade on CSF3.

This skill is the overview. Five depth references live in this same plugin and load alongside on the right files:

- **`storybook-story-writing`** — factory-chain patterns, `.test()`, extension, loaders, decorator stacks, sidebar conventions.
- **`storybook-args-controls`** — argTypes, Controls, Actions, conditional controls, table grouping, `fn()` spies.
- **`storybook-component-documentation`** — MDX with `@storybook/addon-docs/blocks`, per-atomic-level templates.
- **`storybook-play-functions`** — interaction tests with the SB 9+ pre-bound `canvas`.
- **`storybook-configuration`** — `defineMain` / `definePreview`, addon registration, MSW, manager UI.

## CSF Factories — the format

Three function calls form the chain: `definePreview` (in `.storybook/preview.ts`) → `preview.meta(...)` (per stories file) → `meta.story(...)` (per story).

```tsx
// .storybook/preview.ts
import { definePreview } from '@storybook/react-vite';
import * as a11yAddon from '@storybook/addon-a11y/preview';
import * as testAddon from '@storybook/addon-vitest/preview';

export default definePreview({
  addons: [a11yAddon, testAddon],
  parameters: {
    a11y: { test: 'error' },
    layout: 'centered',
  },
});
```

```tsx
// Button.stories.tsx
import preview from '../.storybook/preview';
import { Button } from './Button';

const meta = preview.meta({
  title: 'Atoms/Button',
  component: Button,
  tags: ['autodocs'],
  args: { children: 'Click me', variant: 'primary' },
  argTypes: {
    variant: { control: 'select', options: ['primary', 'secondary', 'ghost'] },
    size:    { control: 'radio',  options: ['sm', 'md', 'lg'] },
    onClick: { action: 'clicked' },
  },
});

export const Default    = meta.story({ args: { variant: 'primary' } });
export const Secondary  = meta.story({ args: { variant: 'secondary' } });
export const Loading    = meta.story({ args: { loading: true } });
export const Disabled   = meta.story({ args: { disabled: true } });
```

`Default` is the first export, by convention.

## Inline tests with `.test()`

A factory story can attach a Vitest browser-mode test directly:

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

Use `.test()` when the story exists primarily to verify behavior; use `play` when the story is a normal demo with an interaction. Both work in factories.

## `.storybook/main.ts` with `defineMain`

```ts
import { defineMain } from '@storybook/react-vite';

export default defineMain({
  framework: '@storybook/react-vite',
  stories: ['../src/**/*.stories.@(ts|tsx|mdx)'],
  addons: ['@storybook/addon-a11y', '@storybook/addon-vitest', '@storybook/addon-docs'],
});
```

`framework` is mandatory. Pick the framework package matching the bundler:

| Bundler / runtime | Framework package |
|---|---|
| React + Vite | `@storybook/react-vite` |
| Next.js (modern) | `@storybook/nextjs-vite` |
| Vue 3 + Vite | `@storybook/vue3-vite` |
| Svelte + Vite | `@storybook/svelte-vite` |
| SvelteKit | `@storybook/sveltekit` |
| Angular | `@storybook/angular` |
| Web Components + Vite | `@storybook/web-components-vite` |

Type imports come from this same package: `import type { Meta, StoryObj } from '@storybook/react-vite'` (or your framework). **Never** import from generic `@storybook/react`.

## meta fields

| Field | Purpose |
|---|---|
| `title` | Sidebar path, slash-separated. `Atoms/Button` puts it under "Atoms". |
| `component` | The component under test. Powers autodocs args table and type inference for `meta.story`. |
| `subcomponents` | Map of related components rendered on the same docs page. |
| `tags` | `['autodocs']` enables auto-generated docs. `['!autodocs']` excludes. `['test']` / `['!test']` filter test runs. |
| `args` | Default args inherited by every story. Stories override per-story. |
| `argTypes` | Argument metadata — `control`, `options`, `description`, `table`, `if`. Drives Controls. |
| `parameters` | Addon configuration — backgrounds, viewports, layout, a11y, docs, msw. |
| `decorators` | Wrappers applied to every story. Provider, theme, router, locale. |
| `play` | Function run after render — runs as a Vitest browser-mode test. |
| `loaders` | Async data loaders. Output available via `loaded`. |
| `render` | Custom render function. Use sparingly — prefer args. |

## story object fields

| Field | Purpose |
|---|---|
| `args` | Per-story args, merged on top of `meta.args`. |
| `argTypes` | Per-story argTypes overrides. |
| `parameters` | Per-story parameter overrides. |
| `decorators` | Per-story decorators (run inside meta decorators). |
| `play` | Per-story interaction. Receives `{ canvas, canvasElement, args, step, loaded }`. |
| `render` | Per-story custom render. |
| `name` | Display name. Defaults to the export name, prettified. |
| `tags` | Per-story tags. |

`canvas` is pre-bound in Storybook 9+ — equivalent to `within(canvasElement)`. Use it.

## argTypes — controls and tables

```ts
argTypes: {
  variant:  { control: 'select', options: ['primary', 'secondary'] },
  size:     { control: 'radio',  options: ['sm', 'md', 'lg'] },
  disabled: { control: 'boolean' },
  count:    { control: { type: 'number', min: 0, max: 100, step: 1 } },
  color:    { control: 'color' },
  onClick:  { action: 'clicked' },
  data:     { control: false },              // hidden from Controls
  className:{ table: { disable: true } },    // hidden from Controls AND props table
}
```

Conditional controls:

```ts
spinner: { control: 'boolean', if: { arg: 'loading' } }
```

See `storybook-args-controls` for the full reference.

## Decorators

Wrap every story. Use for theme / router / store / locale.

```tsx
const meta = preview.meta({
  // ...
  decorators: [
    (Story, ctx) => (
      <ThemeProvider theme={ctx.globals.theme === 'dark' ? darkTheme : lightTheme}>
        <Story />
      </ThemeProvider>
    ),
  ],
});
```

Globals live in `.storybook/preview.ts`:

```ts
export default definePreview({
  initialGlobals: { theme: 'light' },
  globalTypes: {
    theme: {
      description: 'Theme',
      toolbar: {
        title: 'Theme',
        items: [{ value: 'light', title: 'Light' }, { value: 'dark', title: 'Dark' }],
        dynamicTitle: true,
      },
    },
  },
});
```

## Parameters

```ts
parameters: {
  layout: 'centered',           // 'centered' | 'fullscreen' | 'padded'
  backgrounds: {
    default: 'dark',
    values: [{ name: 'dark', value: '#0a0a0a' }, { name: 'light', value: '#fff' }],
  },
  viewport: {
    defaultViewport: 'mobile1',
  },
  a11y: { test: 'error' },                          // see accessibility-stories
  docs: {
    description: { story: 'Use the **primary** variant for the main action.' },
  },
  msw: {                                            // see storybook-configuration
    handlers: [/* msw handlers */],
  },
}
```

## Autodocs

Add `tags: ['autodocs']` at the meta level. Storybook reads:

- The component's prop types (TypeScript / PropTypes / JSDoc)
- The `argTypes` you declare
- JSDoc above props
- `parameters.docs.description.component` for the overview
- Each story (rendered in the docs page in declaration order)

Override the auto-page with custom MDX (see `storybook-component-documentation`).

## MDX docs pages

Imports come from `@storybook/addon-docs/blocks`:

```mdx
{/* Button.mdx */}
import { Meta, Title, Subtitle, Description, Primary, Controls, Stories, Canvas, ArgTypes } from '@storybook/addon-docs/blocks';
import * as ButtonStories from './Button.stories';

<Meta of={ButtonStories} />

<Title />
<Subtitle>The primary clickable element.</Subtitle>
<Description of={ButtonStories} />

## Anatomy
A single `<button>` with optional leading icon, label, and trailing icon.

## Usage
<Canvas of={ButtonStories.Default} />
<Controls of={ButtonStories.Default} />

## All stories
<Stories includePrimary={false} />

## Props
<ArgTypes of={ButtonStories} />

## Design tokens
- `--color-action-primary`
- `--space-button-padding-x`

## Accessibility
- Native `<button>`. Visible focus ring. `aria-pressed` when toggleable.

## Do / Don't
- ✅ One primary button per surface.
- ❌ Don't use a button for navigation.
```

Per-atomic-level MDX templates live in `storybook-component-documentation`.

## Play / `.test()` and Vitest browser-mode

Storybook 9 graduated the experimental Vitest integration into the official `@storybook/addon-vitest`. Setup:

```ts
// vitest.config.ts
import { defineConfig } from 'vitest/config';
import { storybookTest } from '@storybook/addon-vitest/vitest-plugin';

export default defineConfig({
  plugins: [storybookTest({ configDir: '.storybook' })],
  test: {
    browser: {
      enabled: true,
      provider: 'playwright',
      headless: true,
      instances: [{ browser: 'chromium' }],
    },
    setupFiles: ['./.storybook/vitest.setup.ts'],
  },
});
```

```ts
// .storybook/vitest.setup.ts
import { beforeAll } from 'vitest';
import { setProjectAnnotations } from '@storybook/react-vite';
import * as previewAnnotations from './preview';

const project = setProjectAnnotations([previewAnnotations]);
beforeAll(project.beforeAll);
```

Run: `pnpm vitest --project=storybook`.

Story-level `tags: ['!test']` excludes a story from the test run.

## addon-a11y

Runs axe-core against every story. With `parameters.a11y.test === 'error'` and `@storybook/addon-vitest`, axe violations fail the test run.

Minimum config (set in `definePreview`):

```ts
parameters: {
  a11y: {
    test: 'error',
    options: { runOnly: { type: 'tag', values: ['wcag2a', 'wcag2aa', 'wcag22aa'] } },
  },
}
```

The full a11y playbook lives in `accessibility-stories`.

## Portable stories — `composeStories`

Import stories into any test runner. **`composeStories` is exported from your framework package**, not a separate `@storybook/testing-react`:

```ts
import { composeStories } from '@storybook/react-vite';
import * as stories from './Button.stories';
import { render, screen } from '@testing-library/react';

const { Primary, Disabled } = composeStories(stories);

test('Primary renders text', () => {
  render(<Primary />);
  expect(screen.getByRole('button')).toHaveTextContent('Click me');
});
```

`composeStories` runs all decorators, args, loaders, and play / `.test()` exactly as they run in Storybook.

## Sidebar organization

Use the atomic level as the first segment of `title`:

```
Atoms/Button
Atoms/Form/Input            # 2nd-level grouping when an atomic level is busy
Molecules/SearchBar
Organisms/DataTable
Templates/DashboardTemplate
Pages/UserDashboard
```

Cap at 3 segments. Capitalize each. Pluralize the atomic-level segment.

## Story naming

| Pattern | Example | When |
|---|---|---|
| Canonical | `Default` | First export. Always. |
| Variant | `Primary`, `Secondary`, `Ghost` | One per `variant` value. |
| Size | `Small`, `Medium`, `Large` | One per `size` value. |
| State | `Disabled`, `Loading`, `Empty`, `Error` | Per discrete state. |
| Slot | `WithIcon`, `WithCaption` | Demonstrates a filled slot. |
| Stress | `LongText`, `LongLabel`, `ManyItems`, `Truncated`, `RTL` | Robustness. |
| Interaction | `SubmitsForm`, `OpensMenu`, `Cancels` | Verb-prefixed. Has `.test()` or `play`. |

PascalCase. No `Story1` / `Test`.

## Anti-patterns

- **`render` everywhere.** If every story needs `render`, your component isn't args-driven. Fix the component.
- **Hardcoded children in stories.** Drives Controls useless. Put text in `args`.
- **Decorators inside `render`.** Put providers in `decorators`. Otherwise they're invisible to addons.
- **`@storybook/react`** type imports. Use the framework package.
- **`@storybook/blocks`** in MDX. Use `@storybook/addon-docs/blocks`.
- **`@storybook/experimental-addon-test`** in `vitest.config`. Use `@storybook/addon-vitest`.
- **CSF3 object syntax in new files.** Use Factories. (Existing CSF3 files: see `_migration/migration-storybook-7-to-10.md`.)
- **`storiesOf`** anywhere. Removed in 8+; auto-fail in audits.

## Relationship to other skills in this plugin

- **`storybook-story-writing`** — depth on factory-chain patterns.
- **`storybook-args-controls`** — depth on argTypes and Controls.
- **`storybook-component-documentation`** — MDX in depth.
- **`storybook-play-functions`** — interaction-test patterns.
- **`storybook-configuration`** — `.storybook/main.ts` / preview / addons.
- **`storybook-atomic-integration`** — required-stories table per atomic level.
- **`accessibility-stories`** — addon-a11y configuration.
- **`tanstack-integration`** — how stories integrate with TanStack Form / Table / DB.
- **`_migration/migration-storybook-7-to-10`** — upgrade procedure for legacy projects.

## Further reading

- Storybook 10 release — https://storybook.js.org/blog/storybook-10/
- Storybook 9 release — https://storybook.js.org/blog/storybook-9/
- CSF Factories (CSF Next) — https://storybook.js.org/docs/api/csf/csf-next
- Vitest addon — https://storybook.js.org/docs/writing-tests/integrations/vitest-addon
- Portable stories — https://storybook.js.org/docs/api/portable-stories/portable-stories-vitest
