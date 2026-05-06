---
name: archaeology
description: Run a structural archaeology preset across the project's component bodies. Backed by `@anvil/inspector`'s body-tree pipeline -- structural, not regex. Surfaces raw HTML containers (`<section>`, `<aside>`, `<header>`), arbitrary-value classes (`m-[3px]`, `bg-[#hex]`), inline `style` props, raw flex/grid layout utilities (where `<Stack>` / `<Row>` / `<Grid>` should be composed), and untokenised className tokens. Project-extensible: drop a JSON preset under `<projectRoot>/.anvil/archaeology/queries/<name>.json` and it loads alongside the defaults. Invoke as `/anvil:archaeology` (no args = list available presets) or `/anvil:archaeology <preset> [--out <file>] [--format paths|format|count]`.
argument-hint: "[<preset>] [--root <dir>] [--format paths|format|count] [--out <file>]"
arguments: args
allowed-tools: Read, Bash, Write
model: claude-sonnet-4-6
---

# Archaeology: structural sweep across the design system

Runs the `@anvil/inspector` body-tree pipeline against the project, applying a named preset. Use it before refactors ("how many places do this?"), during audits (token compliance, layout-primitive composition), or after a major change (verify nothing leaked back).

## Why this exists

A regex sweep over `.tsx` source can't tell `<section>` inside JSX from the string `"section"` in a comment, can't see `clsx` args that resolve to a token alias, can't follow `<MotionDiv as="section">` past the layer of indirection. The body-tree pipeline parses each component into an AST, walks renderable JSX recursively, and applies structural predicates -- so what you get back is what the component actually renders.

## Usage

`$args` carries the optional preset name and flags. Examples the user might type:

- `/anvil:archaeology` -- list every preset (defaults + project overlays).
- `/anvil:archaeology raw-html-containers` -- run the bundled preset, show formatted output.
- `/anvil:archaeology hardcoded-spacing --format paths` -- grep-friendly output, easy to pipe.
- `/anvil:archaeology raw-html-containers --out /tmp/raw-html.txt` -- write to file.
- `/anvil:archaeology my-org-rule --root /path/to/repo` -- run a project overlay rule.

## Steps

### 1. Locate project root + parse flags

```!
set -e
PARSED="$args"
PRESET=""
ROOT=""
FORMAT="format"
OUT=""

# Pull off flags first.
extract() { printf "%s" "$PARSED" | sed -n "s/.*--$1[ =]\\([^ ]*\\).*/\\1/p"; }

ROOT=$(extract root); ROOT=${ROOT:-}
FORMAT_FLAG=$(extract format); [ -n "$FORMAT_FLAG" ] && FORMAT="$FORMAT_FLAG"
OUT=$(extract out); OUT=${OUT:-}

# Strip flags so the leading positional is the preset name.
STRIPPED=$(printf "%s" "$PARSED" | sed 's/--root[ =][^ ]*//; s/--format[ =][^ ]*//; s/--out[ =][^ ]*//')
PRESET=$(printf "%s" "$STRIPPED" | awk '{print $1}')

if [ -z "$ROOT" ]; then
  ROOT="$(pwd)"
  while [ "$ROOT" != "/" ] && [ ! -f "$ROOT/pnpm-workspace.yaml" ] && [ ! -f "$ROOT/package.json" ]; do
    ROOT="$(dirname "$ROOT")"
  done
fi

echo "ROOT=$ROOT"
echo "PRESET=$PRESET"
echo "FORMAT=$FORMAT"
echo "OUT=$OUT"
```

### 2. List or run

If `PRESET` is empty, list available presets:

```bash
INSPECTOR_DIR="${CLAUDE_PLUGIN_ROOT}/scripts/component-inspector"
cd "$INSPECTOR_DIR"
pnpm exec tsx src/cli.ts archaeology --root "$ROOT"
```

Otherwise pipe `trees` through the preset and the chosen sink:

```bash
INSPECTOR_DIR="${CLAUDE_PLUGIN_ROOT}/scripts/component-inspector"
cd "$INSPECTOR_DIR"

# Snapshot trees once -- iterating on a preset against a saved snapshot is
# instant; re-walking the tree is not.
SNAPSHOT="$ROOT/.anvil/trees.ndjson"
mkdir -p "$(dirname "$SNAPSHOT")"
pnpm exec tsx src/cli.ts trees "$ROOT" > "$SNAPSHOT"

CMD="cat \"$SNAPSHOT\" | pnpm exec tsx src/cli.ts archaeology \"$PRESET\" --root \"$ROOT\""
case "$FORMAT" in
  paths) CMD="$CMD | pnpm exec tsx src/cli.ts paths" ;;
  count) CMD="$CMD | pnpm exec tsx src/cli.ts count" ;;
  format|*) CMD="$CMD | pnpm exec tsx src/cli.ts format" ;;
esac
if [ -n "$OUT" ]; then
  CMD="$CMD > \"$OUT\""
fi
eval "$CMD"
```

### 3. Recommend follow-ups

After the sweep, surface the structural takeaways:

- If the preset returned 0 matches, say so and stop.
- If matches cluster in one tier, mention it ("12 of 14 matches are at organism tier — consider whether the molecule layer is missing a primitive").
- If the preset is `raw-html-containers` or `raw-flex-layout`, recommend `/anvil:safe-rename-jsx-prop` or a hand migration to the project's layout primitives (`<Stack>`, `<Row>`, `<Grid>`, `<Section>`).
- If the preset is `hardcoded-spacing` / `hardcoded-color`, hand off to `/anvil:audit-tokens` (the design-token-enforcer agent) for the literal → token mapping.
- If a project overlay is the source of the rule (`source: <projectRoot>/.anvil/...`), point the user at it so they know to maintain the overlay alongside their rule.

## Authoring a project overlay

To add a project-specific rule:

1. Drop a JSON file under `<projectRoot>/.anvil/archaeology/queries/<name>.json`.
2. Use the predicate DSL documented in `${CLAUDE_PLUGIN_ROOT}/scripts/component-inspector/archaeology/pipelines.md`.
3. Run `/anvil:archaeology` (no args) to confirm it loaded.

The same file name overrides a bundled default. Use this to relax a rule in a specific project (e.g. allow inline-style on Three.js components by wrapping the `attr: style` predicate in `not: { tagPattern: "^HeroGlobe" }`).
