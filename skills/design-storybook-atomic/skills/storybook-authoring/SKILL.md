---
name: storybook-authoring
description: Storybook 9 / 10 authoring expertise — CSF Factories (the modern preview.meta / meta.story pattern), classic CSF3 object syntax, MDX docs, autodocs, args, argTypes, controls, decorators, parameters, play functions, interaction tests, the official addon-a11y, addon-vitest browser-mode testing, and portable stories via composeStories. Load whenever editing or creating any *.stories.* or *.mdx file, configuring Storybook (.storybook/main.ts, preview.ts), upgrading Storybook major versions, writing interaction tests, or designing the story hierarchy. Covers CSF Factories as the recommended modern pattern and the still-supported CSF3 object form.
when_to_use: Writing or auditing CSF Factories or CSF3 stories, MDX docs, configuring Storybook 9/10, addon-vitest browser-mode tests, addon-a11y configuration, portable stories, composeStories, choosing args vs argTypes, decorators/parameters, theming Storybook, organizing the sidebar.
paths: "**/*.stories.*, **/*.mdx, **/.storybook/**, **/storybook.config.*, **/vitest.config.*"
allowed-tools: Read, Grep, Glob
---

# Storybook Authoring

Reference for writing high-quality Storybook stories. **Storybook 10** (2026) is the current major; **Storybook 9** is widely deployed. Both support two story formats:

- **CSF Factories** (recommended for new projects on Storybook 9+, React-only at the time of writing — Vue/Angular/Web Components factories land in the 10.x line). Provides better type inference and a `.test()` method for inline component tests.
- **CSF3 object syntax** (default export `meta` + named export stories). Fully supported on 9/10. Still the most universal form across frameworks.

Both formats coexist in the same project. **`storiesOf` and CSF2 `Template.bind()` are removed/discouraged** — migrate.

## CSF Factories (modern — Storybook 9+, React)

A factory chain of three functions: `definePreview` → `preview.meta` → `meta.story`. Each step has full type safety; you don't repeat the component type.

```ts
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

export const Primary    = meta.story({ args: { variant: 'primary' } });
export const Secondary  = meta.story({ args: { variant: 'secondary' } });
export const Loading    = meta.story({ args: { loading: true } });
export const Disabled   = meta.story({ args: { disabled: true } });
```

### Inline tests with `.test()`

A factory story can attach a Vitest browser-mode test directly:

```ts
import { expect, userEvent, within } from '@storybook/test';

export const SubmitsForm = meta.story({
  args: { onSubmit: fn() },
}).test(async ({ canvas, args }) => {
  await userEvent.type(canvas.getByLabelText(/email/i), 'a@b.co');
  await userEvent.click(canvas.getByRole('button', { name: /sign in/i }));
  await expect(args.onSubmit).toHaveBeenCalledOnce();
});
```

Equivalent to a `play` function but runs natively under `addon-vitest`.

### `.storybook/main.ts` with `defineMain`

```ts
import { defineMain } from '@storybook/react-vite';

export default defineMain({
  framework: '@storybook/react-vite',
  stories: ['../src/**/*.stories.@(ts|tsx|mdx)'],
  addons: ['@storybook/addon-a11y', '@storybook/addon-vitest', '@storybook/addon-docs'],
});
```

The `framework` field is **mandatory** in 9/10. Pick the framework package that matches your bundler:

- React + Vite → `@storybook/react-vite`
- React + Webpack5 → `@storybook/react-webpack5` (legacy path)
- Next.js → `@storybook/nextjs-vite` (Vite preset; legacy `@storybook/nextjs` for Webpack)
- Vue + Vite → `@storybook/vue3-vite`
- Svelte + Vite → `@storybook/sveltekit` or `@storybook/svelte-vite`
- Angular → `@storybook/angular`

## CSF3 object syntax (universal — works on all frameworks, 7+)

CSF3 is **a default export with `meta`** describing the component, plus **named exports** that are stories. Each story is a plain object — no functions required for the simple case.

```tsx
// Button.stories.tsx
import type { Meta, StoryObj } from '@storybook/react-vite';
import { Button } from './Button';

const meta: Meta<typeof Button> = {
  title: 'Atoms/Button',
  component: Button,
  tags: ['autodocs'],
  args: {
    children: 'Click me',
    variant: 'primary',
  },
  argTypes: {
    variant: { control: 'select', options: ['primary', 'secondary', 'ghost'] },
    size:    { control: 'radio',  options: ['sm', 'md', 'lg'] },
    onClick: { action: 'clicked' },
  },
};
export default meta;

type Story = StoryObj<typeof Button>;

export const Primary: Story = { args: { variant: 'primary' } };
export const Secondary: Story = { args: { variant: 'secondary' } };
export const Loading: Story = { args: { loading: true } };
export const Disabled: Story = { args: { disabled: true } };
```

That's the whole shape.

> **Type imports** in Storybook 9/10 come from your **framework package**, not the generic `@storybook/react`. Use `@storybook/react-vite`, `@storybook/nextjs-vite`, `@storybook/vue3-vite`, etc. — matching the `framework` field in `main.ts`.

## The `meta` object — what each field does

| Field | Purpose |
|---|---|
| `title` | Sidebar path. `Atoms/Button` puts the component under "Atoms". Omit to let CSF infer from filesystem (with `storyStoreV7`). |
| `component` | The component under test. Powers autodocs args table and `StoryObj<typeof X>`. |
| `subcomponents` | A map of related components rendered in the same docs page. |
| `tags` | `['autodocs']` enables auto-generated docs. Custom tags can be filtered in the sidebar. |
| `args` | Default args inherited by every story. Stories can override per-story. |
| `argTypes` | Argument metadata — `control`, `options`, `description`, `table`, `if`. Drives the Controls addon. |
| `parameters` | Addon configuration — backgrounds, viewports, layout, a11y, docs. |
| `decorators` | Wrappers applied to every story. Provider, theme, router, locale, etc. |
| `play` | A function run after render — interactions, assertions. Inherited unless overridden. |
| `loaders` | Async data loaders. Result available via `loaded` in `play`. |
| `render` | Custom render function. Use when you can't drive the component purely with `args`. |

## Story object — what each field does

| Field | Purpose |
|---|---|
| `args` | Per-story args. Merged on top of `meta.args`. |
| `argTypes` | Per-story argTypes overrides. |
| `parameters` | Per-story parameter overrides. |
| `decorators` | Per-story decorators (run inside the meta decorators). |
| `play` | Per-story interaction. Receives `{ canvas, canvasElement, args, step }`. (Storybook 9+ adds `canvas` — a pre-bound `within(canvasElement)`.) |
| `render` | Per-story custom render. Use sparingly. |
| `name` | Story display name. Defaults to the export name, prettified. |
| `tags` | Per-story tags. Common: `['!autodocs']` excludes from docs · `['test']` includes in test runs · `['!test']` excludes from test runs · `['stable']` / custom tags filter the sidebar. |

## `argTypes` — controls and tables

Common controls:

```ts
argTypes: {
  variant:  { control: 'select', options: ['primary', 'secondary'] },
  size:     { control: 'radio',  options: ['sm', 'md', 'lg'] },
  disabled: { control: 'boolean' },
  count:    { control: { type: 'number', min: 0, max: 100, step: 1 } },
  color:    { control: 'color' },
  date:     { control: 'date' },
  onClick:  { action: 'clicked' },     // logs to Actions panel
  onClick:  { table: { disable: true } }, // hide from controls
  className:{ table: { category: 'HTML' } }, // group in the table
  size:     { description: 'Visual size of the button' },
}
```

Use `if` for conditional controls (e.g. `loading` only if `disabled` is false):
```ts
spinner: { control: 'boolean', if: { arg: 'loading' } }
```

## Decorators

Decorators wrap every story. Use them to provide context, apply themes, set up routers, mock data, force layout.

```tsx
// at meta level
decorators: [
  (Story, ctx) => (
    <ThemeProvider theme={ctx.globals.theme === 'dark' ? darkTheme : lightTheme}>
      <Story />
    </ThemeProvider>
  ),
],
```

Globals (set in `.storybook/preview.tsx`) let users toggle theme/locale/etc. from the toolbar:

```tsx
// .storybook/preview.tsx
export const globalTypes = {
  theme: {
    name: 'Theme',
    toolbar: { icon: 'circlehollow', items: ['light', 'dark'], dynamicTitle: true },
  },
};
```

## Parameters

Common parameters:

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
  a11y: { /* see accessibility-stories skill */ },
  docs: {
    description: { story: 'Use the **primary** variant for the main action.' },
    source: { type: 'code' },           // show source as JSX code (not dynamic)
  },
}
```

## Autodocs

Add `tags: ['autodocs']` at the meta level to generate a Docs page automatically. Storybook reads:

- The component's prop types (TypeScript / PropTypes / JSDoc)
- The `argTypes` you declare
- JSDoc comments above props
- The `parameters.docs.description.component` for the component overview
- Each story (rendered in the docs page in declaration order)

Override autodocs with an MDX file (see below) when you need long-form docs.

## MDX docs pages

For richer documentation, write an MDX file alongside the stories. **In Storybook 9/10**, Doc Blocks ship with `@storybook/addon-docs` (the legacy `@storybook/blocks` package was folded in). Import from `@storybook/addon-docs/blocks`:

```mdx
{/* Button.mdx */}
import { Meta, Title, Subtitle, Description, Primary, Controls, Stories, Canvas, ArgTypes } from '@storybook/addon-docs/blocks';
import * as ButtonStories from './Button.stories';

<Meta of={ButtonStories} />

<Title />
<Subtitle>The primary clickable element.</Subtitle>
<Description of={ButtonStories} />

## Anatomy

A button is a single `<button>` element with optional leading icon, text, and trailing icon.

## Usage

<Canvas of={ButtonStories.Primary} />
<Controls of={ButtonStories.Primary} />

## All stories

<Stories />

## Do / Don't

- ✅ One primary button per surface.
- ✅ Use sentence case for labels.
- ❌ Don't use a button for navigation. Use a Link.
- ❌ Don't use color alone to communicate state.
```

`@storybook/addon-docs/blocks` exposes the Doc Blocks. Common ones:
- `<Meta of={...}/>` — connect docs page to a CSF file
- `<Primary />` / `<Stories />` / `<Story of={...}/>` — render stories
- `<Canvas of={...}/>` / `<Controls of={...}/>` / `<ArgTypes of={...}/>`
- `<Source of={...}/>` — code block of a story
- `<Markdown>...</Markdown>` for raw markdown.

> Migration note: any existing imports from `@storybook/blocks` keep working through a re-export shim, but the canonical import in 9/10 is `@storybook/addon-docs/blocks`.

## Play functions and interaction tests

`play` runs after render. Use it for interactions and assertions. **Storybook 9+ passes a pre-bound `canvas`** (equivalent to `within(canvasElement)`) so you don't have to `within()` yourself.

```tsx
import { userEvent, expect } from '@storybook/test';

export const SubmitsForm: Story = {
  args: { /* ... */ },
  play: async ({ canvas, step }) => {
    await step('fill the form', async () => {
      await userEvent.type(canvas.getByLabelText(/email/i), 'user@example.com');
      await userEvent.type(canvas.getByLabelText(/password/i), 'hunter2');
    });

    await step('submit', async () => {
      await userEvent.click(canvas.getByRole('button', { name: /sign in/i }));
    });

    await expect(canvas.getByText(/welcome/i)).toBeInTheDocument();
  },
};
```

`@storybook/test` exposes `userEvent`, `within`, `expect`, `fn` (spy mocks), `waitFor`, `screen`. It's a Storybook-instrumented wrapper around Testing Library and Vitest's `expect` — uses `@vitest/expect` under the hood.

## Vitest browser-mode (Storybook 9 / 10)

Storybook 9 graduated the experimental Vitest integration into the official **`@storybook/addon-vitest`**. (`@storybook/experimental-addon-test` is the older 8.x name — migrate.)

Setup:

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

Every story with a `play` (or a CSF-Factory `.test()`) becomes a Vitest test. Stories without `play` become smoke tests (render-only). Story-level `tags: ['!test']` excludes a story from the test run.

Run them like any other Vitest suite:
```bash
pnpm vitest --project=storybook
```

## Portable stories — `composeStories`

You can import a story directly into any test runner (Vitest, Jest, Playwright Test) by composing it. **In Storybook 9/10, `composeStories` is exported from your framework package**, not a separate `@storybook/testing-react`.

```ts
// Button.test.tsx
import { composeStories } from '@storybook/react-vite';
import * as stories from './Button.stories';
import { render, screen } from '@testing-library/react';

const { Primary, Disabled } = composeStories(stories);

test('Primary renders text', () => {
  render(<Primary />);
  expect(screen.getByRole('button')).toHaveTextContent('Click me');
});
```

`composeStories` runs all decorators, args, loaders, and play functions exactly as they run in Storybook itself — so the test exercises the same surface as the canvas.

## addon-a11y

The official accessibility addon runs `axe-core` against every story. **In Storybook 9/10, `parameters.a11y.test` (`'off' | 'todo' | 'error'`) integrates with `@storybook/addon-vitest` to fail the test run on violations.** See the **`accessibility-stories`** skill for the full playbook. Minimum:

```ts
// per-story or per-meta
parameters: {
  a11y: {
    config: { rules: [/* axe rule overrides */] },
    options: { runOnly: { type: 'tag', values: ['wcag2a', 'wcag2aa', 'wcag22aa'] } },
    test: 'error', // 'off' | 'todo' | 'error'
  },
}
```

## Sidebar organization (`title`)

The `title` field is `/`-separated and produces nested sidebar entries.

Recommended convention for atomic design:

```
Atoms/Button
Atoms/Input
Atoms/Icon
Molecules/SearchBar
Molecules/FormField
Organisms/Header
Organisms/DataTable
Templates/DashboardTemplate
Pages/UserDashboard
```

Capitalize each segment. Keep depth ≤ 3 levels (Level/Component or Level/Subgroup/Component).

## Naming conventions

- Story export name = PascalCase, describes the **state or scenario**: `Default`, `Primary`, `Loading`, `Disabled`, `WithIcon`, `LongText`, `EmptyState`, `ErrorState`, `RTL`.
- Story display name (auto-derived) becomes "Default", "With Icon", "Empty State" — readable in the sidebar.
- Reserve `Default` for the canonical example, listed first.
- Prefix interaction-only stories with a verb: `Submits`, `OpensMenu`, `CancelsConfirmation`.

## Common pitfalls

- **`render` everywhere.** If you have `render` in every story, your component probably shouldn't be CSF3 yet — fix the API or use composition. CSF3 should rely on `args`.
- **Hardcoded children in stories.** Drives Controls useless. Put text in `args` so it's editable.
- **Decorators inside `render`.** Put providers in `decorators`, not `render`. Otherwise they're invisible to addons.
- **Stories that only differ in `parameters.docs`.** Combine them; use docs blocks instead.
- **`storiesOf` API.** Removed in Storybook 8+. Migrate to CSF3 or CSF Factories.
- **One story per file with `Default`.** If a component has variants, write a story per variant. The Controls addon does not substitute for variant stories.
- **Mocking via decorator with no cleanup.** Side-effects in decorators leak across stories. Reset in `parameters.beforeEach` or use loaders.
- **Importing types from `@storybook/react`** in a Vite project on 9/10. Use the framework package — `@storybook/react-vite` (etc.). Same for `@storybook/blocks` → `@storybook/addon-docs/blocks`.
- **`@storybook/experimental-addon-test`** still in `vitest.config`. Migrate to `@storybook/addon-vitest`.
- **Mixing CSF Factories and CSF3 in the same file.** Pick one form per file. They can coexist file-to-file.

## Migration cheatsheet

### CSF2 → CSF3

```diff
- export const Primary = Template.bind({});
- Primary.args = { variant: 'primary' };
+ export const Primary: Story = { args: { variant: 'primary' } };
```

```diff
- import { ComponentStory, ComponentMeta } from '@storybook/react';
+ import type { Meta, StoryObj } from '@storybook/react-vite';
```

```diff
- export default { title: 'Button', component: Button } as ComponentMeta<typeof Button>;
+ const meta: Meta<typeof Button> = { title: 'Atoms/Button', component: Button, tags: ['autodocs'] };
+ export default meta;
+ type Story = StoryObj<typeof Button>;
```

### Storybook 8 → 9 / 10

```diff
- import { Meta, StoryObj } from '@storybook/react';
+ import { Meta, StoryObj } from '@storybook/react-vite';

- import { Meta, Story } from '@storybook/blocks';
+ import { Meta, Story } from '@storybook/addon-docs/blocks';

- import { storybookTest } from '@storybook/experimental-addon-test/vitest-plugin';
+ import { storybookTest } from '@storybook/addon-vitest/vitest-plugin';

- import { composeStories } from '@storybook/testing-react';
+ import { composeStories } from '@storybook/react-vite';
```

`main.ts` / `preview.ts` should adopt `defineMain` / `definePreview` for typed config. `framework` becomes mandatory.

### CSF3 → CSF Factories (React, opt-in)

```diff
- import type { Meta, StoryObj } from '@storybook/react-vite';
- import { Button } from './Button';
-
- const meta: Meta<typeof Button> = { component: Button, tags: ['autodocs'] };
- export default meta;
- type Story = StoryObj<typeof Button>;
- export const Primary: Story = { args: { variant: 'primary' } };
+ import preview from '../.storybook/preview';
+ import { Button } from './Button';
+
+ const meta = preview.meta({ component: Button, tags: ['autodocs'] });
+ export const Primary = meta.story({ args: { variant: 'primary' } });
```

## Relationship to other skills in this plugin

- **`atomic-design`** — for *where* a component sits and what its `title` should be.
- **`storybook-atomic-integration`** — for *what stories every component must have*, broken out by level.
- **`accessibility-stories`** — for the addon-a11y configuration playbook and per-story a11y patterns.
- **`story-coverage-checklist`** — the per-level coverage rubric.

## Further reading

- Storybook docs — https://storybook.js.org/docs
- Storybook 10 release — https://storybook.js.org/blog/storybook-10/
- Storybook 9 release — https://storybook.js.org/blog/storybook-9/
- CSF Factories (CSF Next) — https://storybook.js.org/docs/api/csf/csf-next
- CSF3 RFC (legacy reading) — https://storybook.js.org/blog/component-story-format-3-0/
- Vitest addon — https://storybook.js.org/docs/writing-tests/integrations/vitest-addon
- Portable stories (Vitest) — https://storybook.js.org/docs/api/portable-stories/portable-stories-vitest
- Component Driven UI — https://www.componentdriven.org/
