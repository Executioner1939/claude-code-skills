# Migration: Storybook 7 / 8 → 10 (and CSF2 → CSF Factories)

Single migration reference for projects upgrading off Storybook 7 / 8 to **Storybook 10** (current major) and from any pre-Factories CSF format to **CSF Factories**. The integrated `storybook-authoring` skill assumes you're already on the latest; this doc is the bridge for projects that aren't.

This is not a SKILL.md and does not auto-load. It's referenced by the `storybook-authoring`, `storybook-configuration`, `audit-atomic`, `audit-molecules`, `audit-organisms`, and `add-component` skills when a project is detected on a legacy version.

> **Scope of "latest"**: Storybook 10 (released March 2026), CSF Factories (React, with Vue / Angular / Web Components factories rolling through 10.x), `@storybook/addon-vitest`, `@storybook/addon-docs/blocks`, framework-specific packages like `@storybook/react-vite`.

## Why migrate

- **CSF Factories** removes most of the type ceremony of CSF3 (`Meta<typeof X>` / `StoryObj<typeof meta>`) by wiring component types through `preview.meta(...).story(...)`.
- **`@storybook/addon-vitest`** replaces `@storybook/test-runner` and `@storybook/experimental-addon-test`. Stories become Vitest browser-mode tests; `play` and `.test()` are picked up automatically.
- **`@storybook/addon-docs/blocks`** consolidates the doc-block imports that used to live in `@storybook/blocks`.
- **Framework-specific packages** (`@storybook/react-vite`, `@storybook/nextjs-vite`, etc.) replace the generic `@storybook/react` for type imports and config.
- The legacy `storiesOf` API and CSF2 `Template.bind({})` pattern are removed in 8+ — your project may already be broken on 9/10 even if it hasn't started migrating.

## Pre-flight

Before changing any code:

```bash
# 1. Confirm current Storybook major.
node -p "require('./package.json').devDependencies?.storybook"

# 2. Confirm framework package in use.
cat .storybook/main.ts                  # look for `framework` field

# 3. Inventory the work.
grep -RnE "Template\.bind|storiesOf|@storybook/react['\"]|@storybook/blocks['\"]|@storybook/experimental-addon-test|ComponentStory|ComponentMeta" \
  --include="*.{ts,tsx,js,jsx,mdx}" src/ .storybook/ | wc -l
```

If the count is high (> 50), plan to migrate **per atomic level**: atoms first (lowest blast radius), molecules next, organisms last. Run the project's Storybook after each atomic level migrates to surface failures early.

## Step 1 — Upgrade Storybook to 10

```bash
npx storybook@latest upgrade
```

The upgrade tool handles most package renames, the `main.ts` `framework` field migration, and the addon list. Review the diff before committing — it occasionally rewrites custom config in surprising ways.

## Step 2 — Switch all imports to the framework package

Find:
```ts
import type { Meta, StoryObj } from '@storybook/react';
```

Replace with the framework package matching your bundler:
```ts
// Vite + React
import type { Meta, StoryObj } from '@storybook/react-vite';

// Next.js (Vite preset)
import type { Meta, StoryObj } from '@storybook/nextjs-vite';

// Vue + Vite
import type { Meta, StoryObj } from '@storybook/vue3-vite';

// Svelte + Vite
import type { Meta, StoryObj } from '@storybook/sveltekit';
```

Codemod (ripgrep + sed):

```bash
# Detect bundler — assume react-vite for this example.
NEW='@storybook/react-vite'
grep -RlE "from ['\"]@storybook/react['\"]" --include="*.{ts,tsx,mdx}" src/ \
  | xargs -I{} sed -i "s|from ['\"]@storybook/react['\"]|from '${NEW}'|g" {}
```

## Step 3 — CSF2 `Template.bind({})` → CSF3 object syntax

CSF2:
```tsx
const Template: ComponentStory<typeof Button> = (args) => <Button {...args} />;
export const Primary = Template.bind({});
Primary.args = { variant: 'primary' };
```

CSF3:
```tsx
import type { Meta, StoryObj } from '@storybook/react-vite';
const meta: Meta<typeof Button> = { component: Button, tags: ['autodocs'] };
export default meta;
type Story = StoryObj<typeof Button>;
export const Primary: Story = { args: { variant: 'primary' } };
```

CSF3 is fine as an intermediate stop — it works on 10.x. The next step takes it to Factories.

## Step 4 — CSF3 → CSF Factories (React; Vue / Angular / WC follow in 10.x)

CSF3:
```tsx
import type { Meta, StoryObj } from '@storybook/react-vite';
import { Button } from './Button';

const meta: Meta<typeof Button> = { component: Button, tags: ['autodocs'] };
export default meta;
type Story = StoryObj<typeof Button>;

export const Primary: Story = { args: { variant: 'primary' } };
export const Secondary: Story = { args: { variant: 'secondary' } };
```

CSF Factories:
```tsx
import preview from '../.storybook/preview';
import { Button } from './Button';

const meta = preview.meta({ component: Button, tags: ['autodocs'] });

export const Primary = meta.story({ args: { variant: 'primary' } });
export const Secondary = meta.story({ args: { variant: 'secondary' } });
```

The `meta` and `Story` types are inferred from `preview` and the `component`. Renaming `defaultValues` keys propagates through every story automatically.

### Inline test attachment

Where you had a `play` function, the `.test()` method on a factory story attaches a Vitest browser-mode test directly:

```tsx
import { userEvent, expect, fn } from '@storybook/test';

export const SubmitsForm = meta.story({
  args: { onSubmit: fn() },
}).test(async ({ canvas, args }) => {
  await userEvent.type(canvas.getByLabelText(/email/i), 'a@b.co');
  await userEvent.click(canvas.getByRole('button', { name: /submit/i }));
  await expect(args.onSubmit).toHaveBeenCalledOnce();
});
```

A `play` function still works (factory stories support both); `.test()` is the modern form for tests specifically.

## Step 5 — `.storybook/main.ts` → `defineMain`

Before:
```ts
import type { StorybookConfig } from '@storybook/react-vite';
const config: StorybookConfig = {
  framework: { name: '@storybook/react-vite', options: {} },
  stories: [...],
  addons: [...],
};
export default config;
```

After:
```ts
import { defineMain } from '@storybook/react-vite';
export default defineMain({
  framework: '@storybook/react-vite',
  stories: ['../src/**/*.stories.@(ts|tsx|mdx)'],
  addons: ['@storybook/addon-a11y', '@storybook/addon-vitest', '@storybook/addon-docs'],
});
```

## Step 6 — `.storybook/preview.ts` → `definePreview`

Before:
```ts
import type { Preview } from '@storybook/react';
const preview: Preview = {
  parameters: { ... },
  decorators: [ ... ],
};
export default preview;
```

After:
```ts
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

The `preview` export feeds CSF Factories' `preview.meta(...)` chain. Without it, factories don't compile.

## Step 7 — `@storybook/blocks` → `@storybook/addon-docs/blocks`

In every `.mdx`:
```diff
- import { Meta, Title, Subtitle, Description, Primary, Controls, Stories, Canvas, ArgTypes } from '@storybook/blocks';
+ import { Meta, Title, Subtitle, Description, Primary, Controls, Stories, Canvas, ArgTypes } from '@storybook/addon-docs/blocks';
```

A re-export shim still works in 10.x but is deprecated.

## Step 8 — `@storybook/experimental-addon-test` → `@storybook/addon-vitest`

In `vitest.config.ts`:
```diff
- import { storybookTest } from '@storybook/experimental-addon-test/vitest-plugin';
+ import { storybookTest } from '@storybook/addon-vitest/vitest-plugin';
```

In `.storybook/vitest.setup.ts`:
```ts
import { beforeAll } from 'vitest';
import { setProjectAnnotations } from '@storybook/react-vite';
import * as previewAnnotations from './preview';

const project = setProjectAnnotations([previewAnnotations]);
beforeAll(project.beforeAll);
```

## Step 9 — `composeStories` (portable stories)

Two paths in Storybook 10 depending on the target story format:

### CSF Factories (preferred)

CSF Factories **don't need `composeStories`**. Each factory story exposes the composed behavior directly:

```ts
import { Primary } from './Button.stories';

// Run the story's interactions / play / .test() in any test runner:
await Primary.run();

// Render the composed component (with decorators, args, loaders applied):
render(<Primary.Component />);
```

If you're already on factories, drop `composeStories` from your test files entirely.

### Legacy CSF3 (during migration)

For CSF3 files not yet migrated to factories, `composeStories` is exported from the **framework package** (e.g. `@storybook/react`), not the variant package:

```diff
- import { composeStories } from '@storybook/testing-react';
+ import { composeStories } from '@storybook/react';
```

`@storybook/testing-react` is dead. The framework package owns the API now. Once the file moves to CSF Factories, replace `composeStories(...)` with the per-story `Primary.run()` / `Primary.Component` shape above.

## Step 10 — Remove `storiesOf`

`storiesOf` is removed in 8+. Any remaining call sites must convert to CSF (3 or Factories). Use the codemod:

```bash
npx storybook@latest migrate storiesof-to-csf --glob "**/*.stories.*"
```

If the codemod can't handle a particular file (custom decorators, dynamic story generation), convert it by hand using the patterns above.

## Step 11 — Verify

```bash
# Type check.
pnpm tsc --noEmit

# Storybook dev.
pnpm storybook

# Storybook static build (catches more — run this before pushing).
pnpm build-storybook

# Vitest browser mode (every story becomes a test).
pnpm vitest --project=storybook
```

If a particular story still fails after migration, the audit workflows in this plugin (`/design-storybook-atomic:audit-atomic` etc.) will surface the per-component breakdown.

## Common gotchas

- **`tags: ['autodocs']` lost during upgrade.** The upgrade tool sometimes drops it from individual stories' meta. Re-add per file.
- **`globalTypes` ↔ `initialGlobals`.** SB 9 introduced `initialGlobals` for setting initial values; `globalTypes` still defines the toolbar but no longer carries default state. Move defaults into `initialGlobals`.
- **`@storybook/addon-essentials` removed in 9.** Its addons (Controls / Actions / Viewport / Backgrounds / Toolbars / Measure / Outline) were consolidated into core or `@storybook/addon-docs`. Remove `@storybook/addon-essentials` from the addons list — the upgrade tool occasionally leaves a dangling reference.
- **`parameters.layout` defaults changed.** Some stories inherit a different default layout than they did on 7. Set `layout: 'centered' | 'fullscreen' | 'padded'` explicitly at the meta level if anything looks off.
- **`framework` is mandatory.** A `main.ts` without `framework` (or `defineMain({ framework: ... })`) will not start on 9+.
- **`--no-manager-cache` flag removed.** The manager cache is invalidated automatically.

## Migration completion checklist

- [ ] `package.json` Storybook deps all on the same major (no mixed 7 / 8 / 9 / 10).
- [ ] `package.json` framework package set (e.g. `@storybook/react-vite`), generic `@storybook/react` removed if it was a story-type import.
- [ ] No `from '@storybook/react'` in `*.stories.*` or `*.mdx`.
- [ ] No `Template.bind({})`, no `ComponentStory`, no `ComponentMeta`.
- [ ] No `storiesOf(...)`.
- [ ] No `from '@storybook/blocks'` in MDX (replaced with `@storybook/addon-docs/blocks`).
- [ ] No `@storybook/experimental-addon-test` in `vitest.config.*`.
- [ ] `.storybook/main.ts` uses `defineMain({...})`.
- [ ] `.storybook/preview.ts` uses `definePreview({...})`.
- [ ] `pnpm build-storybook` succeeds with zero warnings.
- [ ] `pnpm vitest --project=storybook` runs every story as a test, including `play` / `.test()` cases.
- [ ] `parameters.a11y.test = 'error'` set at preview level so a11y violations fail tests.
- [ ] At least the atom layer has migrated to **CSF Factories** (or the project has explicitly opted to stay on CSF3 — document that decision in `.storybook-atomic.yml` and accept the audit downgrade).

After all the above, the integrated `storybook-authoring` skill in this plugin (latest-only) is the source of truth, and this migration doc is no longer needed for new work.

## What the audit workflows do during migration

If `audit-atomic` (or the molecule / organism variants) detect a project still on CSF2 or CSF3, they:

1. Lower the file-level quality score to reflect format age (CSF2 = -30, CSF3 = -10).
2. Append a "Migration status" section pointing back to this doc.
3. Suggest the per-component delta (which step from this doc to apply for that specific file).
4. Refuse to apply auto-fixes (additive stories) until the file is on CSF3 or Factories — the orchestrator declines silent format-mixing.

To opt out per-component (e.g. you genuinely can't move a story off CSF3 yet), add to `.storybook-atomic.yml`:

```yaml
migration:
  csf_factories_required: true                         # default
  csf3_grandfather:
    - "src/components/atoms/legacy/**"                 # files exempt from the CSF Factories requirement
  exemptions_sunset: 2026-09-30                        # all exemptions expire after this date
```

Audits warn (not fail) on grandfather entries; warn-then-fail after `exemptions_sunset`.
