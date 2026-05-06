---
name: safe-code-mutation
description: How to safely rename, refactor, or rewrite TypeScript / TSX / JSX / Vue / Svelte code at scale. The rule is structural, not textual. Loads when the task is a cross-file rename (component, prop, story title, import path), a JSX prop rewrite, an import-path migration, a deletion + cleanup of consumers, or any "find and replace" that touches `.ts` / `.tsx` / `.jsx` / `.mjs` / `.vue` / `.svelte`. Auto-engages on phrases like "rename component", "rewrite imports", "swap prop", "bulk refactor", "find every usage", "mass update", "migrate from X to Y", or whenever an agent is about to reach for `sed`, `awk`, `find -exec`, Python `re`, or `Edit` with `replace_all=true` against a code file.
when_to_use: Cross-file renames, prop migrations, import rewrites, deleting a component and cleaning up its consumers, restructuring JSX trees, renaming Storybook meta titles, swapping one hook for another, migrating between component libraries. Whenever the change is structural in code, never text-only.
paths: "**/*.ts, **/*.tsx, **/*.jsx, **/*.mjs, **/*.cjs, **/*.vue, **/*.svelte"
---

# Safe Code Mutation

The rule for changing code across many files: **mutate by AST node, not by text match.**

This skill exists because regex-based bulk renames (sed, Python `re`, `Edit` with `replace_all`) have a known failure mode: they match the first lexical occurrence, not the semantically right node. The transcript that motivated this skill stomped real fixture content (`title: "Casual range session"`, `title: "Visa"`, `title: "Order shipped"`) when a rename script aimed at `meta.title` matched the first `title:` in each story file — which was inside a fixture object, not the meta object.

## The hard rules

1. **Never use `sed`, `awk`, `find -exec sed`, or Python `re.sub` on `.ts`, `.tsx`, `.jsx`, `.mjs`, `.cjs`, `.vue`, or `.svelte` files.** These tools cannot tell strings, comments, fixture data, and target nodes apart.
2. **Never use `Edit` with `replace_all: true` on a code file** unless the `old_string` is a unique exported identifier and you have already verified — by inspecting the AST — that it appears in only one structural role.
3. **For prose, JSON, YAML, Markdown, CSS, and config files, regex tools are fine.** Code is the carve-out.
4. **Always dry-run a structural rule before applying it.** `ast-grep` has `--update-all` (apply) and the default (preview). Use the default first; verify the matches; only then apply.
5. **When an agent is about to do a bulk rename, the agent must declare which mechanism it will use** before running it. If the answer is "sed" or "Python regex", stop and re-tool.

## Tool stack

| Job | Tool | Why |
| --- | --- | --- |
| Match a structural pattern across a tree | `ast-grep` (CLI: `sg`) | Tree-sitter under the hood, declarative YAML rules, dry-run by default. |
| Programmatic AST queries from Node | `@ast-grep/napi` | Same engine, scriptable. Used by `@anvil/inspector`. |
| Type-aware refactors (rename a symbol with all its references, change a prop signature, follow imports) | TypeScript Compiler API (`typescript` npm package) | Resolves types, symbols, and cross-file references. The right tool when "rename" means "rename the symbol and every import of it". |
| Heavy multi-file codemods (rare) | `jscodeshift` | Mature codemod runner. Use when `ast-grep --rewrite` isn't expressive enough. |

Reach for `ast-grep` first — most jobs fit it. Drop to the Compiler API or `jscodeshift` only when the rewrite needs type information or multiple coordinated edits per file.

## ast-grep cookbook

Every example below is preview-by-default. Add `--update-all` to apply.

### Rename a Storybook meta title (the failure that motivated this skill)

The mistake was matching `title:` anywhere. The correct target is the `title:` property of the object literal assigned to a `meta` const that satisfies a `Meta<...>` constraint.

```bash
sg --lang tsx -p '
const meta = {
  $$$BEFORE,
  title: "Atoms/Form/Button",
  $$$AFTER,
} satisfies Meta<$T>
' --rewrite '
const meta = {
  $$$BEFORE,
  title: "Atoms/Actions/Button",
  $$$AFTER,
} satisfies Meta<$T>
' .storybook/ src/components/
```

The `$$$BEFORE` / `$$$AFTER` placeholders capture every other property in the meta object, leaving them intact. A `title:` inside a fixture array does not match this rule because it isn't inside a `const meta = {...} satisfies Meta<...>` shape.

### Rename a JSX component

```bash
sg --lang tsx -p '<Drawer $$$ATTRS>$$$CHILDREN</Drawer>' \
  --rewrite '<ContextSheet $$$ATTRS>$$$CHILDREN</ContextSheet>' src/

# Self-closing variant
sg --lang tsx -p '<Drawer $$$ATTRS />' \
  --rewrite '<ContextSheet $$$ATTRS />' src/
```

You also need to rewrite imports separately (see below). Or use the Compiler API path, which does both in one operation.

### Remove every import of a deleted component

```bash
# Named import
sg --lang ts -p 'import { Drawer } from "$SRC"' --rewrite '' src/

# Mixed: only Drawer in a multi-import — strip just that specifier
sg --lang ts -p 'import { Drawer, $$$REST } from "$SRC"' \
  --rewrite 'import { $$$REST } from "$SRC"' src/

sg --lang ts -p 'import { $$$REST, Drawer } from "$SRC"' \
  --rewrite 'import { $$$REST } from "$SRC"' src/

sg --lang ts -p 'import { $$$BEFORE, Drawer, $$$AFTER } from "$SRC"' \
  --rewrite 'import { $$$BEFORE, $$$AFTER } from "$SRC"' src/
```

After running these, search for any remaining `Drawer` JSX usages — those are the consumers you need to migrate before deleting:

```bash
sg --lang tsx -p '<Drawer />' src/   # plus the variants above
```

### Rename a prop on a JSX element

```bash
sg --lang tsx -p '<Button pip={$V} $$$REST />' \
  --rewrite '<Button badge={$V} $$$REST />' src/

sg --lang tsx -p '<Button $$$BEFORE pip={$V} $$$AFTER>$$$C</Button>' \
  --rewrite '<Button $$$BEFORE badge={$V} $$$AFTER>$$$C</Button>' src/
```

Run the self-closing form first, then the wrapped form. Apply `--update-all` after preview.

### Find every consumer of a component

Read-only — for inventory or pre-delete checks:

```bash
sg --lang tsx -p '<TargetComponent $$$ />' src/
sg --lang tsx -p '<TargetComponent $$$>$$$</TargetComponent>' src/
sg --lang ts  -p 'import { TargetComponent } from "$_"' src/
```

`@anvil/inspector consumers <Component>` wraps these into a single deduped list — prefer that.

### Replace a hook usage

```bash
sg --lang tsx -p 'const { open, close } = useDrawer($$$)' \
  --rewrite 'const { open, close } = useOverlay($$$)' src/
```

### Find `process.env` references in browser code

The pattern that surfaced as a runtime crash in the rebuild transcript:

```bash
sg --lang tsx -p 'process.env[$_]' src/components/
sg --lang tsx -p 'process.env.$_'   src/components/
```

Either pattern in `src/components/` is suspicious — DS code ships to non-Node runtimes (Vite, Next.js client bundles, React Native) where `process` is not guaranteed defined.

## TypeScript Compiler API path

When the rename needs type-awareness — for example, renaming a symbol and every consuming import statement in one pass, or changing a prop's TypeScript type — use the Compiler API. The pattern is:

```ts
import ts from "typescript";

const program = ts.createProgram([entry], compilerOptions);
const checker = program.getTypeChecker();

for (const sourceFile of program.getSourceFiles()) {
  if (sourceFile.isDeclarationFile) continue;
  ts.forEachChild(sourceFile, function visit(node) {
    // Match the precise node shape; emit edits via a transformer or text replacer
    // anchored to node.getStart() / node.getEnd().
    ts.forEachChild(node, visit);
  });
}
```

`@anvil/inspector` exposes `inspector.rename({ kind, target, to })` for the common cases (story title, prop rename, hook swap, component rename + import rewrite). Reach for the raw Compiler API only for one-off bespoke refactors that don't fit those shapes.

## Verification protocol

After any structural rewrite, run these checks before committing:

1. **Typecheck.** `tsc --noEmit` — surfaces broken imports, missing exports, prop mismatches.
2. **Lint.** Project `eslint`. Catches removed-but-still-imported, unused vars from a partial migration.
3. **Build.** Storybook build, app build, or unit tests — whichever is the project's smallest reliable signal.
4. **Diff a known fixture.** Pick one file you remember the contents of. Confirm the change is what you intended and *only* what you intended.

Step 4 is non-negotiable. The fixture-stomp failure was undetected by typecheck (the literal types were string-compatible) and lint (nothing illegal about a different string). Only a human eyeball on the diff would have caught it — automate the eyeball by pulling one or two fixture files into the dry-run report.

## When mutation must be regex

Some files genuinely need text rewrites (prose with no AST, generated content). Allowed targets:

- `.md`, `.mdx` (text content, but **not** the embedded code blocks if those are runnable — extract code first)
- `.json`, `.yaml`, `.toml`, `.env`
- `.css`, `.scss`, `.html` (no JSX) — though `ast-grep` supports these too and is preferable
- Inline strings inside source files when matched **as a single unique literal** with `Edit` (default `replace_all: false`)

If the file is `.ts` / `.tsx` / `.jsx` / `.vue` / `.svelte`, the answer is structural.

## Agent integration

Subagents that mutate code should:

1. State the mutation tool in their first response: "I'll rename `Drawer` → `ContextSheet` using `ast-grep` rules X, Y, Z."
2. Run the rules in preview mode and report the match count + a sample.
3. Apply only after the user (or the parent agent) sees the preview.
4. Run the verification protocol above before claiming done.

Agents that violate this — by reaching for `sed`, `Edit` with `replace_all`, or Python regex on a code file — should be corrected immediately, not after the damage.
