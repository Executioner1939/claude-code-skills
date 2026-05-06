---
name: inventory
description: Build the complete design-system inventory for the current project -- every component, its tier, story file, what it composes from, and who consumes it -- via the structural import graph (`@anvil/inspector`). Replaces the regex-based `inventory.py` and the cartographer agent's discovery walk; the resulting JSON file is the authoritative graph that downstream agents (atomic-auditor, component-deduplicator, story-writer) read instead of re-discovering the tree from source. Invoke as `/anvil:inventory` (defaults to writing `.anvil/inventory.json`) or `/anvil:inventory --out path/to/file.json --tier atom`.
argument-hint: "[--out <file>] [--tier <atom|molecule|organism|surface|template>]"
arguments: flags
allowed-tools: Read, Bash, Write
model: claude-sonnet-4-6
---

# Inventory: full design-system graph

One scan, one JSON file, one source of truth. Every other anvil agent should read this rather than re-walking the tree.

The inventory is built by `@anvil/inspector` using a single-pass import-graph walk. It records:

- Every component file at every atomic tier (`quark`, `atom`, `molecule`, `organism`, `surface`, `template`, `page`).
- The matching `<Name>.stories.{ts,tsx}` file when present.
- `composes`: which other components this one imports.
- `consumers`: which files import this component.
- `orphans`: component-shaped files that don't fit a tier.

## Steps

### 1. Locate the project root

```!
set -e
PROJECT_ROOT="$(pwd)"
# Walk up if cwd looks like a subfolder of a monorepo.
while [ "$PROJECT_ROOT" != "/" ] && [ ! -f "$PROJECT_ROOT/pnpm-workspace.yaml" ] && [ ! -f "$PROJECT_ROOT/package.json" ]; do
  PROJECT_ROOT="$(dirname "$PROJECT_ROOT")"
done
echo "PROJECT_ROOT=$PROJECT_ROOT"
```

### 2. Resolve flags

`$flags` may contain `--out <file>` and/or `--tier <name>`. Defaults:

- `--out` defaults to `${PROJECT_ROOT}/.anvil/inventory.json`. Create the directory if it doesn't exist.
- `--tier` defaults to all tiers (no filter).

Parse the flags and capture them as `OUT_PATH` and `TIER_FILTER`.

### 3. Run the inspector

```!
INSPECTOR_DIR="${CLAUDE_PLUGIN_ROOT}/scripts/component-inspector"
cd "$INSPECTOR_DIR"

mkdir -p "$(dirname "$OUT_PATH")"

CMD="pnpm exec tsx src/cli.ts inventory \"$PROJECT_ROOT\" --out \"$OUT_PATH\""
if [ -n "$TIER_FILTER" ]; then
  CMD="$CMD --tier $TIER_FILTER"
fi
eval "$CMD"
```

### 4. Summarise

After the inventory writes, read the JSON and print a one-screen summary:

- Total component count, broken down by tier.
- Top 5 most-consumed components (by `consumers.length`).
- Orphans (component-shaped files outside the tier tree).
- Path to the inventory file.

Hand the JSON path to the caller. Subagents that need component data should read this file rather than re-running discovery.
