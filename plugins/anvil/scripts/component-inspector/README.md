# @anvil/inspector

Structural inspector for atomic-design component libraries. Builds per-component cards (props, stories, variants, consumers, tokens) and a full design-system inventory using the **TypeScript Compiler API** + **ast-grep**.

This package replaces `plugins/anvil/scripts/inventory.py` (regex-based). The TS implementation is structurally precise — it does not match strings, comments, or fixture data when the target is an AST node, which prevents the rename-stomp class of failure.

## Why this exists

Three failures in real refactoring sessions kept biting:

1. **Regex-based bulk renames stomped fixture data.** A `sed`-like pass aimed at `meta.title` matched the first `title:` in each file — which was inside a fixture object, not the meta. Real content (`"Casual range session"`, `"Email verified"`, `"Order shipped"`) got overwritten with taxonomy strings.
2. **Subagents had no shared component model.** Each agent re-discovered the component graph from source, costing tokens and time. The cartographer agent re-walked the tree on every audit.
3. **No visibility into per-component story args, variants, or token usage.** Cards were assembled by hand each time someone asked "what props does X take, who uses it, what tokens does it consume."

`@anvil/inspector` fixes all three with one parser.

## Install

```bash
cd plugins/anvil/scripts/component-inspector
pnpm install
```

Optional: install `@ast-grep/napi` if you want the structural consumer scan (recommended for large repos). The text fallback works without it.

## CLI

```bash
# Render a markdown card for one component
pnpm exec tsx src/cli.ts card path/to/Button.tsx --root path/to/project

# Same card as JSON
pnpm exec tsx src/cli.ts json path/to/Button.tsx --root path/to/project

# Full design-system inventory
pnpm exec tsx src/cli.ts inventory path/to/project --out inventory.json

# File discovery only (debug)
pnpm exec tsx src/cli.ts discover path/to/project

# Who imports this component?
pnpm exec tsx src/cli.ts consumers Button --root path/to/project --self path/to/Button.tsx

# Token-usage report for one file
pnpm exec tsx src/cli.ts tokens path/to/Button.tsx --root path/to/project

# Structural rename (the operation that bit hardest in regex form). Dry-run by default.
pnpm exec tsx src/cli.ts rename-story-title path/to/Button.stories.tsx "Atoms/Actions/Button" --apply
```

After `pnpm build`, the same commands run via `node dist/cli.js …`.

## Programmatic API

```ts
import {
  buildCard,
  buildInventory,
  parseComponent,
  parseStories,
  findConsumers,
  extractTokens,
  renameStoryTitle,
  renderCardMarkdown,
} from "@anvil/inspector";

const card = await buildCard({
  projectRoot: "/path/to/project",
  componentPath: "/path/to/project/src/components/atoms/Button/Button.tsx",
});

console.log(renderCardMarkdown(card));

// Structural rename — never touches fixture data, comments, or non-meta `title:` properties.
await renameStoryTitle(
  "/path/to/project/src/components/atoms/Button/Button.stories.tsx",
  "Atoms/Actions/Button",
  { apply: true },
);
```

## Card shape

```ts
{
  name: "Button",
  tier: "atom",
  fullSortedName: "Atoms/Actions/Button",
  filePath: "src/components/atoms/Button/Button.tsx",
  exports: { names: ["Button", "ButtonProps"], forwardsRef: true, hasDisplayName: false, directive: "use client" },
  props: [
    { name: "variant", type: '"primary" | "secondary" | "ghost"', default: '"primary"', required: false, doc: "..." },
    ...
  ],
  stories: {
    filePath: "src/components/atoms/Button/Button.stories.tsx",
    format: "csf3",
    metaTitle: "Atoms/Actions/Button",
    metaTags: ["autodocs"],
    metaArgs: { variant: "primary", size: "md" },
    argTypes: { variant: { control: "select", options: [...] } },
    variants: [
      { exportName: "Default", storyName: "Default", hasPlay: false, renderShape: "single" },
      { exportName: "Sizes", storyName: "Showcase/All sizes", hasPlay: false, renderShape: "matrix" },
      ...
    ],
  },
  consumers: [{ path: "src/.../CartLineItem.tsx", kind: "import-and-jsx" }, ...],
  tokens: {
    cssVars: ["--color-text-inverse"],
    tailwindAliases: ["bg-accent", "text-text-inverse", "rounded-sm"],
    literals: [],
  },
  issues: [
    { level: "info", rule: "forward-ref-no-display-name", message: "..." },
    ...
  ],
  lastModified: "2026-05-06T..."
}
```

## What's structurally precise (and why it matters)

- **`meta.title` location.** Only matches the `title:` property inside `const meta = {...} satisfies Meta<...>` (or the equivalent type-annotated / cast variants). Will not match fixture `title:` properties, story-level `title:` overrides, or comments.
- **Story exports.** Only matches `export const X = {...}` where `X` is a top-level binding. Filters `__FOO__` private fixtures by convention.
- **Component props.** Reads the conventional `<ComponentName>Props` interface or type alias. Walks `ts.PropertySignature` members, prints each type via the TS printer (faithful to source spelling).
- **Defaults.** Walks the principal component's first parameter (`forwardRef(({ size = "md", ... }) => ...)` or `function Button({ size = "md" }: ButtonProps)`).
- **Consumers.** Uses `@ast-grep/napi` patterns when available (`<Name $$$ />`, `<Name $$$>$$$</Name>`, `import { Name } from "$_"`) — falls back to comment-stripped regex otherwise.

## What's intentionally not done in v1

- Tailwind config resolution (`bg-accent` → `var(--color-accent-default)`). The class is recorded; the resolution happens in a follow-on.
- Cross-file type expansion (`extends ImportedFooProps`). The unresolved branch is noted; props aren't expanded.
- Generic substitution in props (`Component<T>`). The printer emits the unsubstituted spelling.
- More structural mutations (`renameProp`, `renameComponent`, `removeImport`). The pattern is established by `renameStoryTitle`; others land as needed.

## Subagent integration

Skills and agents that previously regex-grepped or shelled out to `inventory.py` should call this package instead:

- `component-cartographer` — replace the audit-time tree walk with `buildInventory({ projectRoot })`.
- `atomic-auditor` — consume the per-component `card.issues` list directly.
- `story-writer` — read `card.stories.variants` to know what coverage already exists.
- `mdx-doc-writer` — read `card.stories.variants[*].exportName` to verify `<Canvas of={Stories.X}>` references resolve.
- `design-token-enforcer` — consume `card.tokens.literals` for hardcoded violations.
- `component-deduplicator` — use `card.consumers` to know who must migrate.

## Refusal contract

Any agent that mutates code should refuse to use `sed`, `awk`, or `Edit replace_all=true` on `.ts/.tsx/.jsx/.vue/.svelte` files. The `safe-code-mutation` skill encodes the rule. Mutations go through this package's `mutate/*` API or through `ast-grep` rules (also documented in that skill).

## Archaeology pipeline

Beyond per-component cards, the inspector ships a unix-style pipeline of small composable verbs for design-system archaeology. NDJSON in, NDJSON out. Pipe a producer into one or more filters into a sink:

```bash
# Every component using a raw <section>:
anvil-inspect trees src/ \
  | anvil-inspect find-jsx --tag section \
  | anvil-inspect paths

# Every arbitrary-value class (m-[3px], gap-[7px], bg-[#hex], …):
anvil-inspect trees src/ \
  | anvil-inspect archaeology hardcoded-spacing --root . \
  | anvil-inspect format

# Untokenised classes per tier:
anvil-inspect trees . --tier organism \
  | anvil-inspect find-untokened-classes \
  | anvil-inspect count
```

Bundled presets:

| Preset | Surfaces |
| --- | --- |
| `raw-html-containers` | `<section>`, `<article>`, `<aside>`, `<header>`, `<footer>`, `<main>`, `<nav>` — recommend layout-primitive composition. |
| `raw-list-containers` | `<ul>`, `<ol>`, `<dl>` — recommend `<Stack as="ul">` / list molecules. |
| `raw-flex-layout` | `flex flex-col`, `flex flex-row`, `grid grid-cols-N` in className — recommend `<Stack>` / `<Row>` / `<Grid>`. |
| `hardcoded-spacing` | `m-[N]`, `p-[N]`, `gap-[N]`, `space-x-[N]`, position offsets with arbitrary values. |
| `hardcoded-color` | `bg-[#hex]`, `text-[#hex]`, `border-[#hex]`, `fill-[#hex]`, `stroke-[#hex]`. |
| `inline-style` | Any `style={{ ... }}` prop. |

Run `anvil-inspect archaeology` (no args) to list every preset including project overlays.

Project-extensible: drop a JSON preset under `<projectRoot>/.anvil/archaeology/queries/<name>.json` and it loads alongside the defaults. Same name overrides the default. See `archaeology/pipelines.md` for the full DSL and recipe cookbook.
