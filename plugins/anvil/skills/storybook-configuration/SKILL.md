---
name: storybook-configuration
user-invocable: false
description: `.storybook/main.ts` and `.storybook/preview.ts` configuration for Storybook 10. `defineMain` and `definePreview` factories, framework-specific packages (`@storybook/react-vite`, `@storybook/nextjs-vite`, `@storybook/vue3-vite`, etc.), addon registration (`@storybook/addon-a11y`, `@storybook/addon-vitest`, `@storybook/addon-docs`), `globalTypes` and `initialGlobals` for toolbar globals, decorator stacks, viewport configuration, theme switching, MSW integration, custom builders. Auto-loads on `.storybook/**`.
when_to_use: Setting up Storybook on a new project, upgrading config to 9 / 10 conventions, registering addons, wiring theme switching, configuring viewports / backgrounds, integrating MSW, customizing the builder.
paths: "**/.storybook/**, **/storybook.config.*"
---

# Storybook configuration

Storybook 10 uses **factory functions** (`defineMain` / `definePreview`) for typed config. The framework field is mandatory; the framework package determines bundler, type imports, and CSF Factories support.

## `.storybook/main.ts`

```ts
import { defineMain } from '@storybook/react-vite';

export default defineMain({
  framework: '@storybook/react-vite',
  stories: ['../src/**/*.stories.@(ts|tsx|mdx)', '../src/**/*.mdx'],
  addons: [
    '@storybook/addon-a11y',
    '@storybook/addon-vitest',
    '@storybook/addon-docs',
  ],
  staticDirs: ['../public'],
  typescript: {
    reactDocgen: 'react-docgen-typescript',
    reactDocgenTypescriptOptions: {
      shouldExtractLiteralValuesFromEnum: true,
      propFilter: (prop) =>
        prop.parent ? !/node_modules/.test(prop.parent.fileName) : true,
    },
  },
});
```

### Framework packages — pick one

| Package | When |
|---|---|
| `@storybook/react-vite` | React + Vite (the default for new projects). |
| `@storybook/nextjs-vite` | Next.js — the modern Vite-based preset. |
| `@storybook/nextjs` | Next.js + Webpack — legacy projects only. |
| `@storybook/react-webpack5` | React + Webpack — legacy. |
| `@storybook/vue3-vite` | Vue 3 + Vite. |
| `@storybook/sveltekit` | SvelteKit. |
| `@storybook/svelte-vite` | Svelte + Vite (no SvelteKit). |
| `@storybook/angular` | Angular. |
| `@storybook/web-components-vite` | Lit / web components + Vite. |

Type imports come from the same package: `import type { Meta, StoryObj } from '@storybook/react-vite'`.

### Addons — minimum recommended

| Addon | Purpose |
|---|---|
| `@storybook/addon-a11y` | Runs axe-core against every story; reports violations in the a11y panel and fails Vitest tests when `parameters.a11y.test === 'error'`. |
| `@storybook/addon-vitest` | Turns every story with a `play` / `.test()` into a Vitest browser-mode test. Runs interactions, asserts spies. |
| `@storybook/addon-docs` | MDX docs pages + autodocs + Doc Blocks (`@storybook/addon-docs/blocks`). |

These three are the latest-conventions baseline. Most other addons (controls, actions, viewport, backgrounds, measure, outline) are now bundled into core or `@storybook/addon-docs` — don't add them separately.

> **Storybook 9 removed `@storybook/addon-essentials`.** If you see it in `addons`, remove it — its content is now in core.

### Custom Vite config

```ts
import { defineMain } from '@storybook/react-vite';
import { mergeConfig } from 'vite';
import path from 'node:path';

export default defineMain({
  framework: '@storybook/react-vite',
  stories: ['../src/**/*.stories.@(ts|tsx|mdx)'],
  addons: ['@storybook/addon-a11y', '@storybook/addon-vitest', '@storybook/addon-docs'],
  async viteFinal(config) {
    return mergeConfig(config, {
      resolve: {
        alias: {
          '@': path.resolve(__dirname, '../src'),
        },
      },
      define: {
        'process.env.STORYBOOK': JSON.stringify(true),
      },
    });
  },
});
```

## `.storybook/preview.ts`

```ts
import { definePreview } from '@storybook/react-vite';
import * as a11yAddon from '@storybook/addon-a11y/preview';
import * as testAddon from '@storybook/addon-vitest/preview';
import { ThemeDecorator } from './decorators/ThemeDecorator';
import '../src/index.css';

export default definePreview({
  addons: [a11yAddon, testAddon],
  parameters: {
    layout: 'centered',
    a11y: {
      test: 'error',                                  // fail Vitest tests on violations
      options: {
        runOnly: { type: 'tag', values: ['wcag2a', 'wcag2aa', 'wcag22aa'] },
      },
    },
    backgrounds: {
      default: 'light',
      values: [
        { name: 'light', value: 'var(--surface-canvas)' },
        { name: 'dark',  value: '#0a0a0a' },
      ],
    },
    viewport: {
      viewports: {
        mobile:  { name: 'Mobile',  styles: { width: '375px',  height: '667px' } },
        tablet:  { name: 'Tablet',  styles: { width: '768px',  height: '1024px' } },
        desktop: { name: 'Desktop', styles: { width: '1280px', height: '800px' } },
      },
    },
    controls: {
      sort: 'requiredFirst',
      matchers: {
        color: /(background|color)$/i,
        date:  /Date$/i,
      },
    },
  },
  initialGlobals: {
    theme: 'light',
    locale: 'en',
  },
  globalTypes: {
    theme: {
      description: 'Theme',
      toolbar: {
        title: 'Theme',
        icon: 'circlehollow',
        items: [
          { value: 'light', title: 'Light' },
          { value: 'dark',  title: 'Dark'  },
        ],
        dynamicTitle: true,
      },
    },
    locale: {
      description: 'Locale',
      toolbar: {
        title: 'Locale',
        icon: 'globe',
        items: [
          { value: 'en',    title: 'English' },
          { value: 'es-ES', title: 'Español' },
        ],
        dynamicTitle: true,
      },
    },
  },
  decorators: [ThemeDecorator],
});
```

> **`globalTypes` vs `initialGlobals`** (Storybook 10): `globalTypes` describes the toolbar (title, icon, options); `initialGlobals` sets the default value. Older configs put defaults in `globalTypes.<name>.defaultValue` — that's deprecated.

## Decorators

A decorator wraps every story with context.

```tsx
// .storybook/decorators/ThemeDecorator.tsx
import type { Decorator } from '@storybook/react-vite';
import { ThemeProvider, lightTheme, darkTheme } from '../../src/theme';

export const ThemeDecorator: Decorator = (Story, ctx) => {
  const theme = ctx.globals.theme === 'dark' ? darkTheme : lightTheme;
  return (
    <ThemeProvider theme={theme}>
      <div data-theme={ctx.globals.theme} className="p-4">
        <Story />
      </div>
    </ThemeProvider>
  );
};
```

Decorators run **bottom-up** — the last decorator in the array wraps closest to the story.

## TanStack integration in preview

Most TanStack abstractions are framework-level (set up at the consumer / page level), not Storybook-level. But two need decorators:

### `QueryClientProvider` decorator

Create a **fresh `QueryClient` per story** so cache state from one story doesn't leak into another (cross-story cache pollution makes Empty/Loading/Error stories flaky and Vitest browser-mode tests non-deterministic). TanStack Query's official testing guidance is per-test isolation; the same applies to per-story isolation.

```tsx
import type { Decorator } from '@storybook/react-vite';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';

export const QueryDecorator: Decorator = (Story) => {
  const queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false, staleTime: Infinity } },
  });
  return (
    <QueryClientProvider client={queryClient}>
      <Story />
    </QueryClientProvider>
  );
};
```

### `RouterProvider` decorator (TanStack Router)

```tsx
import type { Decorator } from '@storybook/react-vite';
import { createRouter, RouterProvider, createMemoryHistory } from '@tanstack/react-router';
import { routeTree } from '../../src/routeTree.gen';

export const RouterDecorator: Decorator = (Story) => {
  const router = createRouter({
    routeTree,
    history: createMemoryHistory({ initialEntries: ['/storybook'] }),
  });
  return <RouterProvider router={router} />;
};
```

## MSW integration (mock API for organism / page stories)

```bash
pnpm add -D msw msw-storybook-addon
npx msw init public --save
```

```ts
// .storybook/preview.ts
import { initialize, mswLoader } from 'msw-storybook-addon';

initialize();

export default definePreview({
  // …
  loaders: [mswLoader],
  parameters: {
    msw: {
      handlers: [],   // overridden per-story
    },
  },
});
```

```tsx
// UserList.stories.tsx
import { http, HttpResponse } from 'msw';

export const Populated = meta.story({
  parameters: {
    msw: {
      handlers: [
        http.get('/api/users', () =>
          HttpResponse.json([
            { id: '1', name: 'Ada Lovelace' },
            { id: '2', name: 'Grace Hopper' },
          ]),
        ),
      ],
    },
  },
});

export const Empty = meta.story({
  parameters: {
    msw: { handlers: [http.get('/api/users', () => HttpResponse.json([]))] },
  },
});

export const Error = meta.story({
  parameters: {
    msw: { handlers: [http.get('/api/users', () => new HttpResponse(null, { status: 500 }))] },
  },
});
```

This is how organism / page stories get the `Empty` / `Loading` / `Error` triad without real backends.

## Manager UI customization

`.storybook/manager.ts`:

```ts
import { addons } from 'storybook/manager-api';
import { themes, create } from 'storybook/theming';

const yourTheme = create({
  base: 'light',
  brandTitle: 'Your Design System',
  brandUrl: 'https://design.your-org.com',
  brandImage: 'https://design.your-org.com/logo.svg',
});

addons.setConfig({
  theme: yourTheme,
  panelPosition: 'right',
  showPanel: true,
  selectedPanel: 'storybook/controls/panel',
  sidebar: {
    showRoots: true,
  },
});
```

## Storybook 10 import path map

| Old (7 / 8) | New (9 / 10) |
|---|---|
| `@storybook/react` | `@storybook/react-vite` (or framework-specific) |
| `@storybook/blocks` | `@storybook/addon-docs/blocks` |
| `@storybook/experimental-addon-test` | `@storybook/addon-vitest` |
| `@storybook/testing-react` (composeStories) | `@storybook/react-vite` |
| `@storybook/addon-essentials` | (removed — content in core / addon-docs) |
| `@storybook/addon-actions` | (in core) |
| `@storybook/addon-controls` | (in core) |
| `@storybook/addon-viewport` | (in addon-docs) |
| `@storybook/addon-backgrounds` | (in addon-docs) |
| `@storybook/manager-api` | `storybook/manager-api` |
| `@storybook/theming` | `storybook/theming` |

See `_migration/migration-storybook-7-to-10.md` for the upgrade procedure.

## Anti-patterns

### ❌ `@storybook/react` import in `main.ts` or `preview.ts`

Use `@storybook/react-vite` (or your framework package). The generic `@storybook/react` is a CSF type re-export; for config it's wrong.

### ❌ Missing `framework` field in `main.ts`

Required since Storybook 7. `defineMain({ framework: '...' })` is the modern signature.

### ❌ Decorator that mutates global state without cleanup

```ts
// BAD
const Decorator: Decorator = (Story) => {
  localStorage.setItem('mock', 'true');                  // leaks across stories
  return <Story />;
};
```

Use `parameters.beforeEach` / `parameters.afterEach` instead, or use loaders.

### ❌ `@storybook/addon-essentials` in addons

Removed in 9. Remove the entry.

### ❌ Inline runtime providers in stories instead of decorators

If you have `<ThemeProvider>` inside `render` in many stories, hoist it to a decorator.

## What the audit checks

`/anvil:audit-*` and `/anvil:audit-libraries` verify:

- ✅ `main.ts` uses `defineMain({...})` with explicit `framework`.
- ✅ `preview.ts` uses `definePreview({...})`.
- ✅ Imports come from the framework package, not generic `@storybook/react`.
- ✅ Addons list includes `@storybook/addon-a11y` and `@storybook/addon-vitest`.
- ✅ `parameters.a11y.test` is `'error'` (not `'todo'` / `'off'` without explicit reason in `.storybook-atomic.yml`).
- ✅ No `@storybook/addon-essentials`, no `@storybook/blocks`, no `@storybook/experimental-addon-test`.
- ✅ TanStack Query / Router decorators registered if those libraries are in use.

## Relationship to other skills in this plugin

- **`storybook-authoring`** — overview that this skill underpins.
- **`storybook-story-writing`** — story patterns built on this config.
- **`storybook-component-documentation`** — `@storybook/addon-docs` is registered here.
- **`storybook-play-functions`** — `@storybook/addon-vitest` is registered here.
- **`accessibility-stories`** — `@storybook/addon-a11y` config lives in preview.
- **`_migration/migration-storybook-7-to-10`** — upgrade procedure if config is on legacy versions.
