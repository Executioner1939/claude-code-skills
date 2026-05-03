---
name: approved-libraries
description: The bouncer-list of approved third-party libraries for any project the design-storybook-atomic plugin operates on. Centred on the TanStack ecosystem (Query / DB / Form / Table / Virtual / Store / Pacer) for state and primitives, Tailwind 4 (web) and NativeWind (React Native) for styling, Day.js for time, Zod for validation, Motion (motion.dev) for animation, Radix UI + React Aria for headless behavior, Lucide for icons, and Expo + Reanimated + FlashList for native. Documents primary picks per category, approved alternates, forbidden / discouraged choices, and the rationale for each call. Load whenever choosing a library, reviewing a `package.json` for compliance, refactoring a component to a different abstraction, or auditing a codebase for off-policy dependencies. Auto-loads on `package.json`, lockfiles, `*.tsx`, `*.ts`, `*.vue`, `*.svelte`.
when_to_use: Library selection, package.json review, dependency audits, refactoring off legacy libraries, choosing between approved alternates, justifying a library pick to a reviewer.
paths: "**/package.json, **/pnpm-lock.yaml, **/package-lock.json, **/yarn.lock, **/bun.lockb, **/*.tsx, **/*.ts, **/*.vue, **/*.svelte"
---

# Approved Libraries

This is the **policy** for which third-party libraries components in a design system built under this plugin must use, must avoid, and may use as approved alternates. The `library-policy-enforcer` agent and the `/design-storybook-atomic:audit-libraries` workflow grade projects against this list.

The list is opinionated on purpose. The point of a design system is **a single mental model across the codebase** — eight component-state libraries means eight bugs. Picks below are chosen for: type safety, maintenance velocity, ecosystem alignment, cross-platform reach (web ↔ native), and "boring" reliability.

## How to read this skill

- **Primary** = required default. New code uses this unless an approved alternate is justified in writing on the PR.
- **Approved alternates** = acceptable when there's a concrete reason (legacy continuity, narrowly-scoped feature, bundle-size critical path).
- **Forbidden / discouraged** = removed during library audits; new use blocks merge.

Every entry has a one-line **why** explaining the choice. If you disagree with a pick, the path is to propose a swap on a PR, not to silently introduce a forbidden library.

---

## Web stack

### Styling

| Pick | Role | Why |
|---|---|---|
| **Tailwind CSS 4** | Primary | v4 ships native CSS layers + container queries + lightning-css; designer/dev share a vocabulary; massive ecosystem. |
| **CVA** (class-variance-authority) | Primary | Type-safe variants for components — replaces ad-hoc `clsx({...})` ladders. |
| **tailwind-merge** | Primary | Resolves Tailwind class collisions (e.g. parent passes `p-4`, child wants `p-2`) deterministically. |
| **clsx** | Primary | The conditional joiner. Tiny, well-typed. |
| Vanilla CSS modules | Approved alternate | When a component is genuinely unique enough that Tailwind utilities would create noise. Rare. |

**Forbidden / discouraged**: `style={...}` for anything beyond dynamically-computed values that Tailwind can't express; emotion / styled-components / Stitches (runtime cost, SSR pain, Stitches is deprecated); inline `<style>` blocks; Bootstrap.

**Why not Panda CSS / vanilla-extract?** Both are good but smaller communities and no first-class shadcn/Radix integration. Tailwind 4 + CVA covers their use cases.

### Headless behavior primitives

| Pick | Role | Why |
|---|---|---|
| **Radix UI** | Primary | shadcn-blessed, complete widget coverage (Tabs, Dialog, Popover, Menu, Select, etc.), accessibility-first, well-typed compound components. |
| **React Aria** (Adobe) | Approved alternate | Use when Radix lacks coverage (advanced i18n, complex date-time pickers, virtualized listboxes). Powerful but more ceremony. |
| **Vaul** | Primary (drawers) | Emil Kowalski's iOS-quality drawer with snap points + a11y. |
| **cmdk** | Primary (command palette) | shadcn-blessed; used by Vercel, Linear; fast and accessible. |

**Forbidden / discouraged**: Headless UI (Tailwind-only ecosystem, smaller surface, slower release cadence); Ark UI (newer, less proven); Bootstrap / MUI / Chakra UI / Mantine (opinionated visuals — defeats the point of a headless layer).

**Why not Headless UI?** Tighter coupling to Tailwind Labs' release timing; Radix's Compound Component API composes more cleanly into our atomic-design layout.

### Server state

| Pick | Role | Why |
|---|---|---|
| **TanStack Query** v5+ | Primary | Undisputed standard. Stale-while-revalidate, query invalidation, mutations with optimistic updates, devtools, framework-agnostic. |

**Forbidden / discouraged**: SWR (smaller surface, fewer caching primitives); Apollo Client / urql (GraphQL lock-in for server state we typically read as REST/RPC); raw `fetch + useEffect` for any non-trivial fetch (no caching, no dedup, no invalidation).

### Local reactive store (the data layer)

| Pick | Role | Why |
|---|---|---|
| **TanStack DB** v0.6+ | Primary | Reactive client store layered on Query. Differential dataflow = sub-millisecond live queries on 100k-row collections. Optimistic mutations, persistence + offline (March 2026). Lists / grids / infinite scrolls feed from collections rather than `useState([])` for fetched data. |

**Forbidden / discouraged**: bespoke caches (you reinvent reactivity badly); Redux normalised state for live data (no live queries); Recoil (Meta-deprecated).

**Why TanStack DB AND TanStack Query?** Query handles the network (fetch / cache / revalidate / mutate against the server). DB handles the local query (live cross-collection joins, derived state, persistence). They compose: Query feeds DB, components subscribe to DB live queries.

### UI state (non-server, non-form)

| Pick | Role | Why |
|---|---|---|
| **TanStack Store** v1+ | Primary | 1KB, integrates with the rest of the TanStack ecosystem, devtools, framework-agnostic. |
| **Zustand** | Approved alternate | The most popular fallback when teams already know it. Same mental model as TanStack Store. |

**Forbidden / discouraged**: Redux / Redux Toolkit (boilerplate; only acceptable in legacy continuity); Valtio (proxy magic confuses devtools); MobX (decorator-based; heavy); Jotai (atom-pattern only justified when you genuinely need atom composition — usually you don't).

### Forms

| Pick | Role | Why |
|---|---|---|
| **TanStack Form** v1+ | Primary | True type inference — renaming `defaultValues.email` propagates. `form.Subscribe` reactive selector = zero wasted renders. Standard Schema validation natively (Zod / Valibot / ArkType / Effect Schema). Framework-agnostic. |

**Forbidden / discouraged**: React Hook Form (worse TS inference; ref-based reads work less well with our compound components); Formik (effectively unmaintained); Conform (server-first only — useful for Remix, narrow fit elsewhere).

**Why TanStack Form over RHF?** RHF is fine — the swap is about TS inference (TanStack Form is materially better) and consistency with the rest of the TanStack ecosystem already in the stack.

### Tables / DataGrid

| Pick | Role | Why |
|---|---|---|
| **TanStack Table** | Primary | Headless. Sort / filter / group / select / virtualize / expand / column-pinning. You own the UI. |

**Forbidden / discouraged**: AG Grid (commercial license required for the features people actually want); MUI DataGrid (locked into MUI's visuals); react-table v6 (deprecated predecessor).

### Virtualization

| Pick | Role | Why |
|---|---|---|
| **TanStack Virtual** | Primary | Same author as Query/Table, framework-agnostic, supports horizontal/vertical/grid/window-scroll. |

**Forbidden / discouraged**: react-window (smaller surface, abandoned); react-virtualized (legacy v6 of react-window).

### Validation

| Pick | Role | Why |
|---|---|---|
| **Zod** | Primary | Best TS inference, huge ecosystem, Standard Schema-compliant, plays directly with TanStack Form. |
| **Valibot** | Approved alternate | When bundle size is critical (~10× smaller than Zod). |
| **ArkType** | Approved alternate | When you need advanced runtime types (intersections, conditionals, recursive). |
| **Effect Schema** | Approved alternate | Inside an Effect-based codebase. |

**Forbidden / discouraged**: Yup (worse TS inference; older API); Joi (server-only ergonomics); manual validation (always wrong at scale).

### Animation (web)

| Pick | Role | Why |
|---|---|---|
| **Motion** (motion.dev) | Primary | Renamed Framer Motion. Best-in-class gestures + layout animations + Web Animations API support; mature. |
| **AutoAnimate** | Approved alternate | One-liner FLIP animations for list reorder where Motion would be overkill. |
| **Lenis** | Approved alternate | When designers demand iOS-style smooth scroll. Use sparingly. |

**Forbidden / discouraged**: GSAP (commercial license complications for SaaS — use only with explicit license review); React Spring (smaller community now); jQuery animations.

### Drag & drop

| Pick | Role | Why |
|---|---|---|
| **@dnd-kit** | Primary | Modern, accessible-by-default, no HTML5-drag baggage, sensors for keyboard / pointer / touch, sortable + droppable kits. |

**Forbidden / discouraged**: react-dnd (HTML5 backend warts); react-beautiful-dnd (Atlassian deprecated it).

### Icons

| Pick | Role | Why |
|---|---|---|
| **Lucide** | Primary | MIT, 1500+ icons, tree-shakable, consistent visual style, fork of Feather, RN package available. |
| **Phosphor** | Approved alternate | Heavier visual weight; sometimes the brief calls for it. |
| **Tabler** / **Heroicons** | Approved alternate | Niche fits. |

**Forbidden / discouraged**: Font Awesome free + pro split (licensing weirdness); hand-rolled SVGs scattered through the codebase (use a single icon set).

### Charts

| Pick | Role | Why |
|---|---|---|
| **Recharts** | Primary | Declarative, well-documented, fast for ~80% of dashboard cases. |
| **Visx** | Approved alternate | When you need D3-level control without writing D3 directly (Airbnb's wrapper). |
| **Tremor** | Approved alternate | Tailwind-first dashboard kit. |

**Forbidden / discouraged**: D3 directly (use a wrapper unless you have a real reason); Chart.js (canvas-based, harder to style/test in Storybook).

### Date / Time

| Pick | Role | Why |
|---|---|---|
| **Day.js** | Primary | 2KB. MomentJS-compatible API (low cognitive cost for migrating teams). Immutable. Plugin-based: import only what you need. |

**Forbidden / discouraged**: Moment.js (officially deprecated by maintainers); date-fns (~3-4× larger than Day.js when not tree-shaken correctly; per-function imports are easy to get wrong); Luxon (good but heavier and lower adoption); Temporal (not GA in browsers yet — revisit when stable).

### Rate-limit / debounce / throttle / batch

| Pick | Role | Why |
|---|---|---|
| **TanStack Pacer** | Primary | Tree-shakable, typed, hook-friendly. Debounce / throttle / rate-limit / queue / batch primitives — the full set. |

**Forbidden / discouraged**: lodash debounce (50KB+ if imported wrong; no React hook integration); hand-rolled `setTimeout` debounces.

### Testing

| Pick | Role | Why |
|---|---|---|
| **@storybook/test** | Primary | Storybook 9/10 unifies on this — pre-bound `canvas`, `userEvent`, `expect`, `fn`, `waitFor`. |
| **Testing Library** | Primary | The semantic-query layer @storybook/test wraps. |
| **Vitest** | Primary | ESM-native, browser-mode integrates with `@storybook/addon-vitest`. |
| **Playwright** | Primary | E2E, also browser provider for Vitest browser mode. |

**Forbidden / discouraged**: Jest (slower than Vitest, weaker ESM, harder to align with Vite); Enzyme (legacy); Cypress (slower component tests than Vitest browser mode + Playwright; keep only for legacy continuity).

---

## React Native stack

The non-styling parts of the stack are **identical** to web. The picks below differ only where the platform forces a difference (styling, gestures, native-only primitives).

### Runtime / tooling

| Pick | Role | Why |
|---|---|---|
| **Expo** + **expo-router** | Primary | Expo handles native modules without ejecting; Expo Router gives file-based routing identical mental model to Next.js / TanStack Router. |

**Forbidden / discouraged for new projects**: bare React Native (more friction, less ecosystem velocity); Solito (transitional pattern superseded by Expo Router web support).

### Styling (native)

| Pick | Role | Why |
|---|---|---|
| **NativeWind 4+** | Primary | Tailwind-class syntax compiled to RN StyleSheet at build time (zero runtime cost). Same utility vocabulary as web Tailwind = single mental model across platforms. |

**Forbidden / discouraged**: `StyleSheet.create` directly (verbose, no design tokens — except inside NativeWind's compiled output); Tamagui (heavy DSL + tooling, opinionated learning curve); Restyle (smaller community); styled-components/native (runtime cost on the JS thread).

### Animation (native)

| Pick | Role | Why |
|---|---|---|
| **react-native-reanimated** | Primary | Runs on the UI thread (60fps gestures), industry default. |
| **moti** | Approved alternate | Motion-like declarative wrapper over Reanimated for simple cases — same mental model as web's Motion. |

**Forbidden / discouraged**: `LayoutAnimation` (limited); RN's legacy `Animated` API (JS thread, dropped frames).

### Gestures

| Pick | Role | Why |
|---|---|---|
| **react-native-gesture-handler** | Primary | Pairs with Reanimated for native gestures. The default. |

### SVG

| Pick | Role | Why |
|---|---|---|
| **react-native-svg** | Primary | The default. Lucide's RN package (`lucide-react-native`) renders through it. |

### Storage

| Pick | Role | Why |
|---|---|---|
| **react-native-mmkv** | Primary | 30× faster than AsyncStorage, sync API, encrypted. |

**Forbidden / discouraged**: AsyncStorage as the primary store (only for cross-tool compatibility shims).

### Lists

| Pick | Role | Why |
|---|---|---|
| **FlashList** (Shopify) | Primary | Drop-in for FlatList, much better recycling on long lists. |

**Forbidden / discouraged**: FlatList for any list > 50 items.

### Bottom sheets

| Pick | Role | Why |
|---|---|---|
| **@gorhom/bottom-sheet** | Primary | The native equivalent of Vaul. Well-maintained. |

### Date pickers (native)

| Pick | Role | Why |
|---|---|---|
| **react-native-date-picker** | Primary | Native iOS/Android pickers; pairs with Day.js for parsing. |

### Icons (native)

| Pick | Role | Why |
|---|---|---|
| **lucide-react-native** | Primary | Same icon set as web; consistent across platforms. |

### Cross-platform shared (web ↔ native)

These are framework-agnostic and identical on both platforms:
- TanStack **Query**, **DB**, **Form**, **Table**, **Virtual**, **Store**, **Pacer**
- **Zod** (or approved alternate validation)
- **Day.js**

Components targeting both platforms split only at the styling layer. Atom-level types and behavior should compile across both — see the `tanstack-integration` skill for the prop shapes that make this work.

---

## How the audit scores compliance

The `library-policy-enforcer` agent (and `/design-storybook-atomic:audit-libraries`) compute a **compliance score 0–100** per project:

- **100 baseline** if every dependency is Primary or Approved alternate.
- **−15** per Forbidden dependency in `dependencies` or `peerDependencies`.
- **−5** per Forbidden dependency in `devDependencies` only.
- **−10** per category where two competing Primary picks coexist (e.g. RHF AND TanStack Form — pick one).
- **−10** per atomic-level component that bypasses the relevant TanStack abstraction (e.g. organism table that builds its own column model instead of using TanStack Table).

A project with score < 80 is **BLOCKED**: `add-component` and `audit-*` workflows refuse to add new components until the policy gap is resolved or an explicit per-PR exemption is written into `.design-storybook-atomic.yml`.

## Per-PR exemptions

Real codebases sometimes need exceptions. Document them in `.design-storybook-atomic.yml`:

```yaml
library_policy:
  exemptions:
    - dependency: react-hook-form
      reason: "5 forms in /admin/ blocked on TanStack Form's array-field UX; tracked in SHIP-1234"
      sunset: 2026-09-30
      pr: https://github.com/org/repo/pull/1234
```

Exemptions are honored by the audits (no penalty), but **must include a sunset date and a tracking PR**. Audits warn (not fail) on exemptions past their sunset.

## Relationship to other skills in this plugin

- **`tanstack-integration`** — how each TanStack abstraction maps onto each atomic-design level. The "must use" rules in this skill are operationalized there.
- **`atomic-design`** — atoms / molecules / organisms have library obligations that this skill defines.
- **`component-composition`** — the API shapes that make components compatible with TanStack Form / Table / DB.
- **`audit-libraries` (workflow)** — runs the policy enforcement.
- **`library-policy-enforcer` (subagent)** — the engine the audit invokes.

## Why this list, not a different one

The picks above optimize for four things, in order:

1. **One mental model across the codebase.** Atoms, molecules, organisms — and across web and native — should use the same underlying abstractions where possible. TanStack ecosystem dominates for this reason: Query / DB / Form / Table / Virtual / Store / Pacer share design language and types.
2. **Type safety.** Every Primary pick has best-in-class TS inference (Zod over Yup; TanStack Form over RHF; Tailwind + CVA over inline strings).
3. **Maintenance velocity.** Every Primary pick is actively maintained, has a recognizable maintainer or org, and ships releases at a predictable cadence. Recoil, react-beautiful-dnd, and Stitches are not on this list because their maintainers have moved on.
4. **Boring reliability.** No bleeding-edge picks. TanStack DB at v0.6 is the youngest entry on the list and has gone through community use; everything else is v1+ or equivalent.
