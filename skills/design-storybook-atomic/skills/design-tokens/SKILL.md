---
name: design-tokens
description: Design tokens — primitive vs semantic vs component layers, the W3C Design Tokens Community Group draft format, Style Dictionary, Tokens Studio, theming with tokens (light/dark/brand), CSS custom properties vs Tailwind theme vs CSS-in-JS, naming conventions, and refactoring hardcoded values to tokens. Load whenever working with `tokens.json`, Style Dictionary configs (`config.cjs`), Tokens Studio output, theme files, CSS variables, Tailwind `theme.extend`, or whenever a component contains hardcoded color/spacing/typography/radius/shadow/motion values that should be tokens.
when_to_use: Auditing components for hardcoded values, designing or refactoring a token taxonomy, setting up Style Dictionary, integrating Tokens Studio, building theme switching, choosing between CSS variables vs Tailwind config vs CSS-in-JS, naming tokens, splitting primitives from semantics, mapping Figma variables to code tokens.
paths: "**/tokens.json, **/tokens/**, **/style-dictionary*, **/theme.*, **/themes/**, **/tailwind.config.*, **/*.tokens.json"
---

# Design Tokens

Reference for **design tokens** — the named, machine-readable values (color, spacing, typography, radius, shadow, motion, opacity, z-index, durations) that a design system uses to stay consistent across products, themes, and platforms.

## The three-tier model

A robust token system has **three layers**. Atoms and molecules consume only the upper layers; the lower layer exists only as a vocabulary.

### Tier 1 — Primitive tokens (a.k.a. "global", "core", "raw")

The full palette of values, named by **what they are**. No meaning, no context.

```
color.blue.500     = #3B82F6
color.gray.900     = #0F172A
space.4            = 16px
space.6            = 24px
font.size.16       = 1rem
font.weight.semibold = 600
radius.md          = 8px
shadow.lg          = 0 10px 15px -3px rgba(0,0,0,0.1)
duration.fast      = 150ms
ease.standard      = cubic-bezier(0.4, 0, 0.2, 1)
```

You **never** consume primitives directly in components. They exist for semantics to reference.

### Tier 2 — Semantic tokens (a.k.a. "alias", "intent")

Named by **what they mean** in your interface.

```
color.text.primary           → color.gray.900
color.text.secondary         → color.gray.600
color.text.inverse           → color.white
color.surface.canvas         → color.white
color.surface.raised         → color.white
color.surface.sunken         → color.gray.50
color.border.subtle          → color.gray.200
color.feedback.danger        → color.red.600
color.feedback.success       → color.green.600
color.action.primary         → color.blue.600
color.action.primary.hover   → color.blue.700
space.gutter.sm              → space.4
space.stack.md               → space.6
font.body.md                 → font.size.16
radius.control               → radius.md
shadow.elevation.1           → shadow.sm
duration.feedback            → duration.fast
```

Components consume semantics. **Never primitives directly.**

When you switch to dark mode, only this layer's mappings change. Components don't move.

### Tier 3 — Component tokens (optional, scoped)

For components with unique surface area, you can publish a third layer scoped per component.

```
button.bg.primary            → color.action.primary
button.bg.primary.hover      → color.action.primary.hover
button.text.primary          → color.text.inverse
button.padding.x.md          → space.4
button.radius                → radius.control
input.border.idle            → color.border.subtle
input.border.focus           → color.action.primary
```

Component tokens are optional. They're useful when:
- A component's value diverges from generic semantics (e.g. a button's hover ≠ generic hover).
- You want a single point of override for white-labeling.
- Multiple themes need to override different things per component.

## Token taxonomy by category

### Color
- Brand: `brand.primary`, `brand.secondary`, …
- Text: `text.primary`, `text.secondary`, `text.disabled`, `text.inverse`, `text.link`
- Surface: `surface.canvas`, `surface.raised`, `surface.sunken`, `surface.overlay`
- Border: `border.subtle`, `border.strong`, `border.focus`
- Action: `action.primary`, `action.secondary`, `action.danger` (each with `default`, `hover`, `active`, `disabled`)
- Feedback: `feedback.danger`, `feedback.warning`, `feedback.success`, `feedback.info`

### Space
Use a consistent scale. Recommended: 4-base ratio (4, 8, 12, 16, 24, 32, 48, 64, 96).
- Stack (vertical between siblings): `stack.xs|sm|md|lg|xl`
- Inline (horizontal between siblings): `inline.xs|sm|md|lg|xl`
- Inset (padding inside a container): `inset.xs|sm|md|lg|xl`
- Squish (asymmetric inset): `inset.squish.sm|md` (vertical < horizontal)

### Typography
- Font family: `font.family.body`, `font.family.heading`, `font.family.mono`
- Font size: `font.size.xs|sm|md|lg|xl|2xl|3xl|...`
- Font weight: `font.weight.regular|medium|semibold|bold`
- Line height: `font.line.tight|normal|relaxed`
- Letter spacing: `font.tracking.tight|normal|wide`
- Compound: `font.body.sm`, `font.heading.lg` — bundling family/size/weight/line/tracking.

### Radius
`radius.none|sm|md|lg|xl|full`

### Shadow / Elevation
`shadow.elevation.0|1|2|3` — preferred over `shadow.sm|md|lg` because elevation is what designers communicate.

### Motion
- Duration: `duration.instant|fast|moderate|slow`
- Easing: `ease.linear|standard|enter|exit|emphasized`
- Compound: `motion.feedback`, `motion.transition`

### Z-index
`z.base|raised|sticky|overlay|modal|popover|toast`

### Opacity
`opacity.disabled`, `opacity.muted`, `opacity.transparent`

## The W3C Design Tokens format

The **Design Tokens Community Group (DTCG)** draft defines a portable JSON format. Tokens Studio exports it. Style Dictionary consumes it.

```json
{
  "color": {
    "blue": {
      "500": { "$value": "#3B82F6", "$type": "color", "$description": "Primary brand blue" }
    },
    "text": {
      "primary": { "$value": "{color.gray.900}", "$type": "color" }
    }
  },
  "space": {
    "4": { "$value": "16px", "$type": "dimension" }
  },
  "shadow": {
    "elevation": {
      "1": {
        "$value": {
          "color": "{color.gray.900}",
          "offsetX": "0",
          "offsetY": "1px",
          "blur": "2px",
          "spread": "0"
        },
        "$type": "shadow"
      }
    }
  }
}
```

Key conventions:
- `$value` — the token value (literal or `{path.to.other.token}` reference)
- `$type` — `color`, `dimension`, `fontFamily`, `fontWeight`, `duration`, `cubicBezier`, `shadow`, `border`, `gradient`, `transition`, `typography`
- `$description` — human-readable note
- `$extensions` — vendor-specific metadata (e.g. `com.tokens-studio`)
- Group nodes are plain objects without `$value`.

## Style Dictionary

The standard build tool. It transforms the token JSON into platform-specific output (CSS variables, JS/TS, iOS, Android, Tailwind config).

```js
// config.cjs
module.exports = {
  source: ['tokens/**/*.json'],
  platforms: {
    css: {
      transformGroup: 'css',
      buildPath: 'build/css/',
      files: [{
        destination: 'tokens.css',
        format: 'css/variables',
        options: { selector: ':root' }
      }],
    },
    js: {
      transformGroup: 'js',
      buildPath: 'build/js/',
      files: [{ destination: 'tokens.js', format: 'javascript/es6' }],
    },
    ts: {
      transformGroup: 'js',
      buildPath: 'build/ts/',
      files: [{ destination: 'tokens.d.ts', format: 'typescript/es6-declarations' }],
    },
    tailwind: {
      transformGroup: 'js',
      buildPath: 'build/tailwind/',
      files: [{ destination: 'tokens.cjs', format: 'javascript/module' }],
    },
  },
};
```

Output:
```css
:root {
  --color-blue-500: #3B82F6;
  --color-text-primary: var(--color-gray-900);
  --space-4: 16px;
}
```

## Tokens Studio (Figma plugin)

Tokens Studio lives in Figma and exports DTCG JSON. Workflow:

1. Designers maintain primitives + semantics in Tokens Studio.
2. Tokens Studio pushes JSON to a GitHub repo (or a `tokens.json` file in your repo).
3. CI runs Style Dictionary to generate platform outputs.
4. Components consume the outputs (CSS vars, Tailwind classes, TS constants).

This keeps **design tools and code in lockstep**.

## Theming

There are two common patterns:

### Pattern A — CSS variables, swapped at the root

Primitives and component values stay constant. Semantic mappings live under `[data-theme="dark"]`:

```css
:root {
  --color-text-primary: var(--color-gray-900);
  --color-surface-canvas: var(--color-white);
}
[data-theme="dark"] {
  --color-text-primary: var(--color-gray-50);
  --color-surface-canvas: var(--color-gray-950);
}
```

Components reference `var(--color-text-primary)` and stay theme-agnostic.

### Pattern B — JS-side theme objects (CSS-in-JS, Tailwind plugins, etc.)

A `theme.ts` exports a token object; a `<ThemeProvider>` swaps it. Same idea, different mechanism.

## Tailwind integration

Two routes:

**Route A — Generate `tailwind.config.cjs` from tokens** (Style Dictionary `javascript/module` format):

```js
const tokens = require('./build/tailwind/tokens.cjs');
module.exports = {
  theme: {
    extend: {
      colors: tokens.color,
      spacing: tokens.space,
      borderRadius: tokens.radius,
      boxShadow: tokens.shadow,
    },
  },
};
```

**Route B — Reference CSS vars in Tailwind** (Tailwind 3.3+):

```js
theme: {
  extend: {
    colors: {
      'text-primary': 'var(--color-text-primary)',
      'surface-canvas': 'var(--color-surface-canvas)',
    },
  },
}
```

Route A is cleaner; Route B is faster to set up if you already have CSS vars.

## Refactoring hardcoded values to tokens

Common offenders to grep for:

```bash
# colors
grep -RnE '#[0-9a-fA-F]{3,8}\b' src/components/      # hex
grep -RnE 'rgba?\([^)]+\)' src/components/           # rgb / rgba
grep -RnE 'hsla?\([^)]+\)' src/components/           # hsl / hsla

# spacing
grep -RnE ':\s*[0-9]+px\b' src/components/

# font sizes
grep -RnE 'font-size:\s*[0-9]+(\.[0-9]+)?(px|rem|em)\b' src/components/

# z-index
grep -RnE 'z-index:\s*[0-9]+' src/components/

# durations
grep -RnE 'transition[^;]*[0-9]+ms\b' src/components/
```

Refactor heuristic:

1. **Look up the literal in the primitive scale.** If it matches a primitive value, the answer is a semantic token whose value is that primitive.
2. **Find or invent the right semantic.** Ask: "what does this value *mean* in context?" Color of body text → `color.text.primary`. Vertical gap between cards → `space.stack.md`.
3. **If no semantic fits, propose one.** Don't reach down to a primitive in components.
4. **If two literals are close but not equal** (e.g. `15px` and `16px`), they probably should be the same token. Round to the scale.

## Naming rules

- **Lowercase, dot-separated, kebab-allowed.** `color.text.primary`, `font.size.xs`.
- **Group → category → subcategory → modifier.** `color.action.primary.hover`, not `primaryActionHoverColor`.
- **No camelCase.** Cross-platform tools convert; consistency at the source matters.
- **No abbreviations except universally understood ones** (`bg`, `fg`, `xs`, `sm`, `md`, `lg`, `xl`).
- **Numeric scales** start from `0` (or `none`) and can use t-shirt sizes or numeric (`100`-`900`). Pick one and stick with it.
- **State suffixes**: `.hover`, `.active`, `.focus`, `.disabled`, `.selected`. Always at the end.
- **Theme variants** never appear in token names — themes swap mappings, names stay the same.

## Common pitfalls

- **One layer of tokens.** No primitives, only semantics. Then changing the brand requires editing every semantic. Add a primitive layer.
- **Two layers but components reference primitives.** Defeats the purpose. Lint for it.
- **Token names that mean nothing in another theme.** `color.bg.gray-100` looks fine in light mode, nonsense in dark. Use semantics.
- **Untyped tokens.** Without `$type`, tools can't transform them correctly (especially shadows and typography).
- **Tokens Studio out of sync with code.** Establish a single source of truth (usually the JSON file in the repo) and a one-way sync.
- **No "elevation" abstraction.** Designers think in elevation; you publish `shadow.sm/md/lg`. They drift apart. Use `shadow.elevation.0..3`.
- **No motion tokens.** Animations are done with hardcoded ms. Add `duration.*` and `ease.*` and refactor.

## Relationship to other skills in this plugin

- **`atomic-design`** — atoms and molecules must consume tokens, not literals.
- **`audit-tokens` (workflow)** — uses this skill's heuristics to scan for offenders and propose refactors.
- **`design-token-enforcer` (subagent)** — applies the refactors safely.

## Further reading

- W3C Design Tokens CG draft — https://tr.designtokens.org/format/
- Style Dictionary — https://amzn.github.io/style-dictionary/
- Tokens Studio — https://docs.tokens.studio/
- Nathan Curtis on token naming — https://medium.com/eightshapes-llc/naming-tokens-in-design-systems-9e86c7444676
