---
name: accessibility-stories
description: Accessibility for Storybook — the official `@storybook/addon-a11y` configuration playbook (axe-core integration, rule overrides, WCAG tagging, fail-on-violation), per-story a11y patterns (focus stories, keyboard interaction stories, contrast stories, screen-reader stories, reduced-motion stories), the WAI-ARIA patterns reference, and the manual checks axe cannot perform. Load whenever writing or auditing stories with a11y in mind, configuring addon-a11y, integrating axe-core into CI / Vitest browser mode, or reviewing a component for WCAG 2.2 AA compliance.
when_to_use: Configuring or troubleshooting addon-a11y, writing accessibility-focused stories, reviewing a component for WCAG 2.2 AA, choosing ARIA roles/states/properties, building keyboard navigation tests, contrast audits, focus management.
paths: "**/*.stories.*, **/.storybook/**, **/a11y*, **/axe*"
---

# Accessibility in Storybook

Reference for **accessibility-focused Storybook authoring** — the addon-a11y config, the per-story patterns that catch real defects, and the rules of WAI-ARIA you can't get from automated checks alone.

## The official a11y addon — `@storybook/addon-a11y`

Runs `axe-core` against every story and reports violations in the a11y panel. **In Storybook 10, paired with `@storybook/addon-vitest`, axe violations fail Vitest browser-mode tests when `parameters.a11y.test === 'error'`.**

### Install

```bash
pnpm add -D @storybook/addon-a11y @storybook/addon-vitest
```

```ts
// .storybook/main.ts
import { defineMain } from '@storybook/react-vite';

export default defineMain({
  framework: '@storybook/react-vite',
  stories: ['../src/**/*.stories.@(ts|tsx|mdx)'],
  addons: ['@storybook/addon-a11y', '@storybook/addon-vitest', '@storybook/addon-docs'],
});
```

### Configure (meta level)

```ts
// per-story or per-meta `parameters`
parameters: {
  a11y: {
    // Axe configuration
    config: {
      rules: [
        // disable a rule that fires false-positively in stories
        { id: 'color-contrast', enabled: true },
        { id: 'region', enabled: false }, // story root isn't a landmark
      ],
    },
    // Axe runtime options
    options: {
      runOnly: {
        type: 'tag',
        values: ['wcag2a', 'wcag2aa', 'wcag22aa', 'best-practice'],
      },
      // exclude problematic story roots
      // include: '#root',
    },
    // Failure mode
    test: 'error',  // 'off' | 'todo' | 'error'
  },
}
```

`test: 'error'` makes Vitest browser-mode story tests fail on a11y violations (requires `@storybook/addon-vitest`). `'todo'` reports without failing — useful while migrating. `'off'` disables axe for that story / meta.

You can also set the baseline at the project level via `definePreview`:

```ts
// .storybook/preview.ts
import { definePreview } from '@storybook/react-vite';

export default definePreview({
  parameters: {
    a11y: {
      test: 'error',
      options: { runOnly: { type: 'tag', values: ['wcag2a', 'wcag2aa', 'wcag22aa'] } },
    },
  },
});
```

### Per-story override

Disable axe for a story that is intentionally exercising a non-accessible state (e.g. a "before" story showing a defect):

```tsx
export const BadContrast: Story = {
  args: { /* ... */ },
  parameters: { a11y: { test: 'off' } },
};
```

### Suppress a single rule per story

```tsx
parameters: {
  a11y: {
    config: { rules: [{ id: 'color-contrast', enabled: false }] },
  },
}
```

Suppression with reason — leave a comment:

```tsx
// Disabled: this story demonstrates the loading skeleton, which intentionally has no role="status"
parameters: { a11y: { config: { rules: [{ id: 'aria-roles', enabled: false }] } } },
```

## Required a11y stories per atomic level

These stories are not optional. They catch defects automated audits miss.

### For atoms (interactive)

- `Default` — must pass axe (color contrast, role, name).
- `Focus` — render with the atom focused via a decorator that calls `.focus()`. Demonstrates the focus ring.
- `KeyboardActivated` — `play` story that uses `userEvent.tab()` then `userEvent.keyboard('{Enter}')` (and `' '` for buttons). Asserts the `onClick` fires.
- `Disabled` — confirms `aria-disabled` or `disabled` attribute, and that the focus ring is suppressed.
- `RTL` — wrap in `<div dir="rtl">` decorator. Visual + focus-order check.
- `ReducedMotion` — wrap in a decorator that sets `prefers-reduced-motion`, confirm animations are skipped.

### For atoms (non-interactive)

- Same except keyboard / disabled.
- `LongText` story for text atoms — verifies overflow doesn't clip into other content.

### For molecules

Everything atoms need, plus:

- `KeyboardFlow` — `play` story that tabs through every focusable, asserting order and visible focus.
- `WithError` — verifies error is announced (`aria-invalid`, `aria-describedby`, `role="alert"` for live error toasts).
- `LabelledCorrectly` — verifies every form control has a programmatic label (`htmlFor`, `aria-label`, or `aria-labelledby`).

### For organisms

- `Empty`, `Loading`, `Error` — each tested for a11y. Loading must announce (`aria-busy="true"` or `role="status"`). Error must use `role="alert"` or live region.
- `KeyboardOperated` — `play` story that performs the full primary task with keyboard only.
- `ScreenReaderText` — story that exposes any visually-hidden text and labels for screen readers (use a `.sr-only` class, verify it's in the DOM).
- `ColorBlindSafe` — when meaning is conveyed by color (status badges, chart legends), verify a non-color signal exists.

### For templates / pages

- Landmark structure: header / nav / main / footer all present, each appears once or has a unique label.
- `SkipLink` story exercises the skip-to-main-content link.
- `HeadingHierarchy` — verify exactly one `<h1>` and that h2/h3/etc. don't skip levels.

## Patterns that axe cannot detect — manual checks

Axe is rules-based. These require human (or agent) review:

1. **Did the focus go where the user expected after this action?** Opening a modal should move focus into it; closing it should return focus to the trigger.
2. **Is the focus *trap* correct?** In modals/popovers/menus, tabbing must cycle within the element, never escape behind it.
3. **Does the announcement make sense?** "Submitted" is a fine label for a button but a useless live-region announcement. Try "Form submitted successfully."
4. **Is the keyboard model correct for the widget?** Tabs use Left/Right; menus use Up/Down; comboboxes use Down/Up + Home/End + typeahead. See WAI-ARIA Authoring Practices.
5. **Are state changes announced?** A toggle that doesn't update its `aria-pressed` is silent to screen readers.
6. **Is content order correct in the DOM, regardless of CSS?** Flex `order:` and `grid-area` reorder visually; screen readers follow DOM. Check both.
7. **Are videos / animations actually pausable?**
8. **Does the touch target meet 44×44 px?** Required at WCAG 2.2 AA (Target Size, Minimum).

The audit workflows in this plugin enforce these via the `accessibility-reviewer` subagent.

## ARIA cheatsheet — the patterns most components need

| Widget | Role | Required state/props | Keyboard |
|---|---|---|---|
| Button | `button` (native) | `aria-disabled`, `aria-pressed` (toggle) | Enter, Space |
| Toggle | `button` + `aria-pressed` | — | Enter, Space |
| Link | `link` (native `<a>`) | — | Enter |
| Disclosure | `button` + `aria-expanded` + `aria-controls` | — | Enter, Space |
| Tabs | `tablist` / `tab` / `tabpanel` | `aria-selected`, `aria-controls`, `tabindex=-1` on inactive | Left/Right, Home/End |
| Menu / Menubar | `menu`, `menuitem` | — | Up/Down, Home/End, type-ahead, Esc |
| Combobox | `combobox` + `aria-expanded` + `aria-controls` + `aria-activedescendant` | — | Down to open, Up/Down, Enter, Esc |
| Listbox | `listbox`, `option` + `aria-selected` | — | Up/Down, Home/End, type-ahead |
| Modal dialog | `dialog` + `aria-modal="true"` + `aria-labelledby` | focus trap | Esc to close |
| Tooltip | `tooltip` (often visible on `:hover` and focus) | `aria-describedby` from trigger | — |
| Switch | `switch` + `aria-checked` | — | Enter, Space |
| Slider | `slider` + `aria-valuemin/max/now` + `aria-valuetext` | — | Left/Right, Home/End, PgUp/PgDn |
| Progressbar | `progressbar` + `aria-valuemin/max/now` | — | — |
| Status (live region) | `status` (polite) or `alert` (assertive) | — | — |

The full reference is the **WAI-ARIA Authoring Practices Guide** — https://www.w3.org/WAI/ARIA/apg/patterns/

## Common pitfalls

- **`role="button"` on a `<div>` that lacks keyboard handlers.** Use a real `<button>`. If you must, you need `tabindex="0"`, `keydown` for Enter and Space, and `role="button"`.
- **`aria-label` overriding the visible text.** If the label says "Save" but `aria-label="Submit"`, screen readers say "Submit" — confusing if a user voice-controls "click Save". Make them match or omit `aria-label`.
- **Disabled buttons that aren't `aria-disabled`.** `disabled` is fine for native buttons. For `<div role="button">` use `aria-disabled="true"` and skip `tabindex`.
- **Color-only state.** Red error border with no text. Add a textual cue (`!` icon with `aria-label`, `aria-invalid="true"`, error text linked via `aria-describedby`).
- **Live region at the wrong level.** A new toast appearing inside a `role="alert"` *that didn't exist before* might not announce. Have the live region pre-rendered and update its contents.
- **Focus on body after close.** A modal that closes and lets focus fall to `<body>`. Always restore focus to the trigger.
- **Skipped headings.** Going from `h1` to `h3` because `h2` "looked too big". Style with classes; semantics are independent of size.
- **Too-small targets.** `<button class="p-0">` in a dense table. WCAG 2.2 requires 24×24 (AA Target Size, Minimum) for most cases; 44×44 is the practical bar.
- **`aria-hidden` on focusable content.** A focusable element inside `aria-hidden="true"` is a screen-reader trap — focus lands on it, but it's "hidden". Either remove `aria-hidden` or `tabindex="-1"` the descendant.

## Vitest browser-mode integration

In Storybook 10, `@storybook/addon-vitest` and `@storybook/addon-a11y` integrate by default. Each story becomes a Vitest browser-mode test; axe violations fail the test if `parameters.a11y.test === 'error'`.

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
// .storybook/preview.ts — recommended baseline
import { definePreview } from '@storybook/react-vite';

export default definePreview({
  parameters: {
    a11y: {
      test: 'error',
      options: {
        runOnly: { type: 'tag', values: ['wcag2a', 'wcag2aa', 'wcag22aa'] },
      },
    },
  },
});
```

This makes the *entire* story library an a11y regression suite. To opt a single story out (e.g. a "before" demo), set `parameters: { a11y: { test: 'off' } }` on it.

## Manual / assistive testing matrix

For ship-blocking review, run a component through:

| Tool | What to check |
|---|---|
| Keyboard only (no mouse) | Reach + activate every interactive. Order + visible focus. |
| Screen reader (VoiceOver, NVDA, JAWS) | Names, roles, states announced. Live regions speak. |
| Browser zoom 200% | No horizontal scroll; no clipped text. |
| Forced colors mode (Windows High Contrast) | Borders + focus visible. No background-image-only icons. |
| `prefers-reduced-motion: reduce` | Animations skip or shorten. |
| `prefers-contrast: more` | Borders/dividers strengthen. |
| Touch (Devtools) | 24×24+ targets. No hover-only affordances. |

## Relationship to other skills in this plugin

- **`storybook-authoring`** — for the Storybook config and CSF Factories syntax this skill builds on.
- **`storybook-atomic-integration`** — for which a11y stories are required at each atomic level.
- **`accessibility-reviewer` (subagent)** — runs the manual-check matrix and produces a defect list.

## Further reading

- WAI-ARIA Authoring Practices (APG) — https://www.w3.org/WAI/ARIA/apg/patterns/
- WCAG 2.2 quick reference — https://www.w3.org/WAI/WCAG22/quickref/
- axe-core rules reference — https://dequeuniversity.com/rules/axe/
- Storybook a11y addon docs — https://storybook.js.org/addons/@storybook/addon-a11y
