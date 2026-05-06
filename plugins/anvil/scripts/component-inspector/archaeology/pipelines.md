# Archaeology pipelines — cookbook

Every verb reads NDJSON from stdin (when applicable) and writes NDJSON to stdout. Sinks (`format`, `count`, `paths`) terminate the pipeline.

## Producers

| Producer | Output |
| --- | --- |
| `anvil-inspect tree <path>` | One body-tree record. |
| `anvil-inspect trees [root]` | Body-tree per component, parallel. NDJSON, one tree per line. |
| `anvil-inspect inventory [root]` | Project-wide inventory JSON (single document — not NDJSON). |

## Filters (NDJSON in, NDJSON out)

| Filter | Behaviour |
| --- | --- |
| `find-jsx --tag <name>` | Keep `<Name>` matches. Also `--tag-pattern <regex>`, `--tag-kind <html\|component\|member\|dynamic>`. |
| `find-class --pattern <regex>` | Keep elements where any `className` token matches. `--raw` searches unresolved expressions instead. |
| `find-attr --name <attr> [--value <regex>]` | Keep elements with the named attribute (and optional value match). |
| `find-untokened-classes [--allow x,y] [--ignore-arbitrary]` | Surface arbitrary-value classes, unrecognised utilities, unresolvable className expressions. |
| `archaeology <preset>` | Run a named preset (default or project overlay). Preset filter compiles to the same DSL the `find-*` verbs use. |

Filters chain. The second filter searches inside the first filter's matched subtrees.

## Sinks (NDJSON in, text/number out)

| Sink | Behaviour |
| --- | --- |
| `format` | Pretty per-file blocks with `line:col [rule] <tag>  — reason`. |
| `count` | Total match count. |
| `paths` | `path:line:col  rule: reason` lines, one per match. Grep-friendly; useful for piping into editors / fzf. |

## Recipes

### Find every raw HTML container in DS code

```bash
anvil-inspect trees src/components/ | anvil-inspect archaeology raw-html-containers --root . | anvil-inspect format
```

### Find every component using `<section>` and arbitrary spacing

```bash
anvil-inspect trees src/ \
  | anvil-inspect find-jsx --tag section \
  | anvil-inspect find-class --pattern 'm-\[|p-\[|gap-\[' \
  | anvil-inspect paths
```

### Count untokenised classes per tier

```bash
for tier in atom molecule organism surface; do
  count=$(anvil-inspect trees . --tier "$tier" \
    | anvil-inspect find-untokened-classes \
    | anvil-inspect count)
  printf "%-12s %s\n" "$tier" "$count"
done
```

### Find every component that imports a deleted name (use the consumers verb, not the trees pipeline)

```bash
anvil-inspect consumers Drawer --root . --self packages/ds-web/src/components/organisms/Drawer/Drawer.tsx
```

### Surface every inline style in DS code, except in globe / canvas allow-list

Project overlay at `<projectRoot>/.anvil/archaeology/queries/inline-style.json`:

```json
{
  "name": "inline-style",
  "description": "Inline styles in DS — Three.js / canvas exempted.",
  "filter": {
    "allOf": [
      { "attr": "style" },
      { "not": { "tagPattern": "^(canvas|HeroGlobe)" } }
    ],
    "ruleId": "inline-style-prop",
    "reason": "Inline style bypasses the token system."
  }
}
```

Then:

```bash
anvil-inspect trees . | anvil-inspect archaeology inline-style --root . | anvil-inspect format
```

### Pre-flight before deleting a component

```bash
anvil-inspect safe-delete packages/ds-web/src/components/organisms/Drawer/Drawer.tsx --root .
```

### Verify MDX docs after a story-export rename

```bash
anvil-inspect verify-mdx .
```

### Custom rule via JSON

A project that wants to enforce "every `<button>` has either `aria-label` or `children`" can add:

```json
{
  "name": "button-needs-label",
  "description": "Buttons need an aria-label or visible text content.",
  "filter": {
    "allOf": [
      { "tag": "button" },
      { "not": { "attr": "aria-label" } }
    ],
    "ruleId": "button-no-label",
    "reason": "Add aria-label or ensure children render text."
  }
}
```

Save under `.anvil/archaeology/queries/button-needs-label.json`. The next `anvil-inspect archaeology` (with no args) lists it; pass the name to run it. Same DSL the bundled defaults use.

## Predicate DSL

```ts
type Predicate =
  | { tag: string }
  | { tagPattern: string }                            // regex
  | { tagKind: "html" | "component" | "member" | "dynamic" }
  | { classPattern: string }                          // regex against any className token
  | { rawClassPattern: string }                       // regex against raw clsx expressions
  | { attr: string }
  | { attrValue: { name: string; pattern: string } }
  | { anyOf: Predicate[] }
  | { allOf: Predicate[] }
  | { not: Predicate };

// Any predicate may also carry `ruleId` and `reason` — these annotate the
// match record so `format` / `paths` show them.
```

Compositors propagate the matched branch's annotations unless the wrapper sets its own.

## Performance

`trees` parallelises with `--concurrency` (default 8). For a 200-component DS this completes in a few seconds on warm caches. Filters and sinks stream — they don't hold the whole project in memory.

If you're iterating on a rule, snapshot once:

```bash
anvil-inspect trees . > .anvil/trees.ndjson
cat .anvil/trees.ndjson | anvil-inspect archaeology raw-html-containers --root . | anvil-inspect format
```

…then iterate against the snapshot.
