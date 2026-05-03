---
name: storybook-play-functions
user-invocable: false
description: Interaction tests in CSF Factories — `play` functions and `.test()` inline tests, the pre-bound `canvas` (Storybook 9+), `userEvent` / `expect` / `fn` / `waitFor` from `@storybook/test`, `step()` for labelled phases, async / loading / error patterns, keyboard navigation tests, drag-and-drop, file uploads, multi-step forms, and how every story becomes a Vitest browser-mode test under `@storybook/addon-vitest`. Auto-loads on `*.stories.*`.
when_to_use: Writing interaction tests, deciding `play` vs `.test()`, asserting against `fn()` spies, simulating keyboard / pointer / drag, testing async loading states, testing focus / a11y interactions, debugging flaky interaction tests.
paths: "**/*.stories.@(ts|tsx|js|jsx)"
---

# Storybook play functions and interaction tests

Storybook 9 / 10 with `@storybook/addon-vitest`. Every story with a `play` or `.test()` runs as a Vitest browser-mode test against a real headless browser (Playwright provider).

## Anatomy

```tsx
import { userEvent, expect, fn } from '@storybook/test';

export const SubmitsForm = meta.story({
  args: { onSubmit: fn() },
}).test(async ({ canvas, args, step }) => {
  await step('fill the form', async () => {
    await userEvent.type(canvas.getByLabelText(/email/i), 'a@b.co');
    await userEvent.type(canvas.getByLabelText(/password/i), 'hunter2');
  });

  await step('submit', async () => {
    await userEvent.click(canvas.getByRole('button', { name: /sign in/i }));
  });

  await expect(args.onSubmit).toHaveBeenCalledOnce();
  await expect(args.onSubmit).toHaveBeenCalledWith({ email: 'a@b.co', password: 'hunter2' });
});
```

## `.test()` vs `play`

Both run after render. Both have the same signature and access to `canvas` / `args` / `step` / `loaded`.

| | `.test()` | `play` |
|---|---|---|
| **Purpose** | The story is primarily a test. | The story is a demo with an interaction. |
| **Vitest behavior** | Treated as a test case (named like the story). | Treated as a "play" (still runs as a test, but reported as a playback). |
| **Idiomatic** | Storybook 9+ Factories. | Inherited from CSF3. |

In Factories, prefer `.test()` for tests-as-tests; `play` for "show the user how the interaction looks".

## The function context

```tsx
.test(async ({ canvas, canvasElement, args, step, loaded, userEvent, mount }) => { … })
```

| Field | Description |
|---|---|
| `canvas` | A pre-bound `within(canvasElement)`. Use this. **Storybook 9+ only.** |
| `canvasElement` | The HTMLElement root of the rendered story. Use only when you need raw DOM. |
| `args` | The story's args, including `fn()` spies you can assert on. |
| `step` | `step(name, fn)` — labels a phase in the trace. Use generously. |
| `loaded` | Loader output (if `loaders` is set on the story). |
| `userEvent` | Pre-bound `@storybook/test` userEvent. (You can also import it.) |
| `mount` | Rare — manually mount the story (used in advanced render strategies). |

## Imports from `@storybook/test`

```tsx
import {
  userEvent,
  within,
  expect,
  fn,
  waitFor,
  screen,
  spyOn,
} from '@storybook/test';
```

`@storybook/test` is the Storybook-instrumented wrapper around Testing Library + Vitest's `expect` + Vitest's `vi.fn`. Use it instead of importing `vitest` and `@testing-library/*` directly — the wrapper handles cleanup and traces interactions in the Storybook UI.

## Patterns

### Form interactions

```tsx
.test(async ({ canvas, args, step }) => {
  await step('fill required fields', async () => {
    await userEvent.type(canvas.getByLabelText(/name/i), 'Ada Lovelace');
    await userEvent.selectOptions(canvas.getByLabelText(/country/i), 'United Kingdom');
  });
  await step('submit', async () => {
    await userEvent.click(canvas.getByRole('button', { name: /save/i }));
  });
  await expect(args.onSave).toHaveBeenCalled();
});
```

### Keyboard navigation

```tsx
.test(async ({ canvas, step }) => {
  await step('tab to first interactive', async () => {
    await userEvent.tab();
    await expect(canvas.getByRole('textbox', { name: /search/i })).toHaveFocus();
  });
  await step('arrow down through menu', async () => {
    await userEvent.keyboard('{ArrowDown}');
    await expect(canvas.getAllByRole('menuitem')[0]).toHaveFocus();
    await userEvent.keyboard('{ArrowDown}');
    await expect(canvas.getAllByRole('menuitem')[1]).toHaveFocus();
  });
  await step('select with Enter', async () => {
    await userEvent.keyboard('{Enter}');
    await expect(canvas.getByText(/option 2 selected/i)).toBeInTheDocument();
  });
});
```

### Async / loading / error states

```tsx
.test(async ({ canvas, step }) => {
  await step('trigger async load', async () => {
    await userEvent.click(canvas.getByRole('button', { name: /load/i }));
  });
  await step('wait for loading', async () => {
    await waitFor(() => expect(canvas.getByRole('status')).toHaveTextContent(/loading/i));
  });
  await step('wait for data', async () => {
    await waitFor(
      () => expect(canvas.getAllByRole('listitem')).toHaveLength(5),
      { timeout: 3000 },
    );
  });
});
```

`waitFor` retries the assertion until it passes or times out (default 1000ms). Set `{ timeout: N }` for slower paths.

### Drag and drop (pointer API)

```tsx
.test(async ({ canvas, step }) => {
  const handle = canvas.getByLabelText(/drag handle for item 1/i);
  const target = canvas.getByLabelText(/position 3/i);

  await step('drag', async () => {
    await userEvent.pointer([
      { keys: '[MouseLeft>]', target: handle },
      { coords: { x: 0, y: 100 } },
      { target },
      { keys: '[/MouseLeft]' },
    ]);
  });

  await expect(canvas.getByText(/item 1 at position 3/i)).toBeInTheDocument();
});
```

### File upload

```tsx
.test(async ({ canvas }) => {
  const file = new File(['hello'], 'note.txt', { type: 'text/plain' });
  await userEvent.upload(canvas.getByLabelText(/upload/i), file);
  await expect(canvas.getByText(/note\.txt/)).toBeInTheDocument();
});
```

### Multi-step wizard

```tsx
.test(async ({ canvas, step }) => {
  await step('step 1: name', async () => {
    await userEvent.type(canvas.getByLabelText(/full name/i), 'Ada Lovelace');
    await userEvent.click(canvas.getByRole('button', { name: /next/i }));
  });
  await step('step 2: contact', async () => {
    await expect(canvas.getByText(/step 2 of 3/i)).toBeInTheDocument();
    await userEvent.type(canvas.getByLabelText(/email/i), 'ada@example.com');
    await userEvent.click(canvas.getByRole('button', { name: /next/i }));
  });
  await step('step 3: confirm', async () => {
    await expect(canvas.getByText(/step 3 of 3/i)).toBeInTheDocument();
    await userEvent.click(canvas.getByRole('checkbox', { name: /agree/i }));
    await userEvent.click(canvas.getByRole('button', { name: /submit/i }));
  });
  await expect(canvas.getByText(/registration complete/i)).toBeInTheDocument();
});
```

### Modal focus management (a11y check)

```tsx
.test(async ({ canvas, step }) => {
  await step('open modal', async () => {
    const trigger = canvas.getByRole('button', { name: /open settings/i });
    await userEvent.click(trigger);
  });
  await step('focus moves to dialog', async () => {
    const dialog = canvas.getByRole('dialog');
    await expect(dialog).toBeInTheDocument();
    // First focusable inside dialog should have focus
    const firstInput = within(dialog).getAllByRole('textbox')[0];
    await expect(firstInput).toHaveFocus();
  });
  await step('escape closes and restores focus', async () => {
    await userEvent.keyboard('{Escape}');
    await expect(canvas.queryByRole('dialog')).not.toBeInTheDocument();
    await expect(canvas.getByRole('button', { name: /open settings/i })).toHaveFocus();
  });
});
```

This is the test that the `accessibility-reviewer` agent demands for any modal dialog organism.

## Reusable test helpers

For interactions used across many stories, extract a helper:

```tsx
// test-helpers.ts
import { userEvent, within } from '@storybook/test';

export async function login(canvas: ReturnType<typeof within>) {
  await userEvent.type(canvas.getByLabelText(/email/i), 'a@b.co');
  await userEvent.type(canvas.getByLabelText(/password/i), 'hunter2');
  await userEvent.click(canvas.getByRole('button', { name: /sign in/i }));
}
```

```tsx
// Dashboard.stories.tsx
import { login } from '../test-helpers';

export const AfterLogin = meta.story({}).test(async ({ canvas }) => {
  await login(canvas);
  await expect(canvas.getByText(/welcome/i)).toBeInTheDocument();
});
```

## Vitest browser-mode setup

For tests to actually run as part of `pnpm vitest`, configure `@storybook/addon-vitest`:

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

Run tests: `pnpm vitest --project=storybook`.

## Anti-patterns

### ❌ Direct DOM manipulation

```tsx
// BAD
canvasElement.querySelector('input')!.value = 'x';
```

Use `userEvent.type`. Direct value-setting bypasses React's controlled-input synthetic event handling.

### ❌ Missing `await`

```tsx
// BAD — async without await — assertion runs before click resolves
userEvent.click(canvas.getByRole('button'));
await expect(canvas.getByText(/clicked/i)).toBeInTheDocument();
```

Every `userEvent.*`, `expect`, and `waitFor` is async. `await` all of them.

### ❌ Brittle text selectors

```tsx
// BAD — breaks if button label changes
await userEvent.click(canvas.getByText('Save'));
```

```tsx
// GOOD — semantic role
await userEvent.click(canvas.getByRole('button', { name: /save/i }));
```

### ❌ Not using `step()`

Without `step()`, the trace shows a wall of clicks. With `step()`, failures pinpoint the phase.

### ❌ Asserting before state has updated

```tsx
// BAD
await userEvent.click(canvas.getByRole('button', { name: /load/i }));
await expect(canvas.getByText(/loaded/i)).toBeInTheDocument();   // race
```

```tsx
// GOOD
await userEvent.click(canvas.getByRole('button', { name: /load/i }));
await waitFor(() => expect(canvas.getByText(/loaded/i)).toBeInTheDocument());
```

### ❌ Calling `within(canvasElement)` everywhere instead of using the pre-bound `canvas`

Storybook 9+ provides `canvas` already bound. Use it.

## What the audit checks

`/design-storybook-atomic:audit-*` verify:

- ✅ Required `play` / `.test()` stories exist per atomic level (see `story-coverage-checklist`).
- ✅ Tests use `step()` to label phases.
- ✅ Tests assert `fn()` spies (not just visual changes).
- ✅ No direct DOM manipulation.
- ✅ All async calls awaited.
- ✅ `parameters.a11y.test = 'error'` not disabled silently.

## Relationship to other skills in this plugin

- **`storybook-story-writing`** — the story patterns these tests run against.
- **`storybook-args-controls`** — `fn()` spies declared in args.
- **`accessibility-stories`** — focus-management tests live here; a11y axe checks live in addon-a11y.
- **`storybook-configuration`** — vitest-config + addon-vitest setup.
