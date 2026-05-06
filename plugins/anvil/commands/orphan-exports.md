---
name: orphan-exports
description: Find every exported name in the project that no other file imports. Backed by `@anvil/inspector`'s structural import graph (resolves tsconfig path aliases that grep would miss). Use to surface dead code, accidentally-private exports, and re-export barrels that have outlived their consumers. Read-only. Invoke as `/anvil:orphan-exports [--entry <path>,...] [--out <file>]`.
argument-hint: "[--entry <paths>] [--out <file>]"
arguments: args
allowed-tools: Read, Bash, Write
model: claude-sonnet-4-6
---

# Orphan exports

Surfaces exports the rest of the project doesn't import. Useful before:

- Trimming a design system before a major version cut.
- Refactoring a barrel file to remove dead re-exports.
- Auditing whether a "public API" entry is actually consumed (orphan-exports of `<package>/src/index.ts` indicates a public-facing export with no internal consumer — fine, but worth knowing).

## Argument shape

`$args` carries:

- `--entry <paths>` — comma-separated public-API entry files. Their exports are excluded from the orphan check (since external consumers, not the project itself, import them).
- `--out <file>` — write the JSON report to a file.
- `--root <dir>` — project root (defaults to the closest one).

## Steps

### 1. Parse flags

```!
set -e
extract() { printf "%s" "$args" | sed -n "s/.*--$1[ =]\\([^ ]*\\).*/\\1/p"; }

ENTRY=$(extract entry)
OUT=$(extract out)
ROOT_FLAG=$(extract root)

if [ -z "$ROOT_FLAG" ]; then
  ROOT_FLAG="$(pwd)"
  while [ "$ROOT_FLAG" != "/" ] && [ ! -f "$ROOT_FLAG/pnpm-workspace.yaml" ] && [ ! -f "$ROOT_FLAG/package.json" ]; do
    ROOT_FLAG="$(dirname "$ROOT_FLAG")"
  done
fi

echo "ROOT=$ROOT_FLAG"
echo "ENTRY=$ENTRY"
echo "OUT=$OUT"
```

### 2. Run

```bash
INSPECTOR_DIR="${CLAUDE_PLUGIN_ROOT}/scripts/component-inspector"
cd "$INSPECTOR_DIR"

CMD="pnpm exec tsx src/cli.ts orphan-exports \"$ROOT_FLAG\""
if [ -n "$ENTRY" ]; then CMD="$CMD --entry \"$ENTRY\""; fi
if [ -n "$OUT" ]; then CMD="$CMD --out \"$OUT\""; fi
eval "$CMD"
```

### 3. Recommend follow-ups

For each orphan, decide:

- **Truly dead** — delete via `/anvil:safe-delete <path>` (which checks consumers one more time before the deletion lands).
- **Accidentally private** — the export is part of the intended API but the entry file forgets to re-export it. Add it to the project's barrel.
- **Re-export barrel** with `[re-export]` tag — usually a barrel that re-exports a now-unused name. Trim it.
- **Type-only with phantom usage** — sometimes a type is used inside a `as Foo` cast or `satisfies` constraint that the import-graph walker missed (the graph captures `import type` declarations precisely; runtime-only type assertions inside the same file aren't an import). Spot-check with `Grep` for the name as a final confidence pass.

Default exports are only flagged inside tier folders (`atoms/`, `molecules/`, `organisms/`, `surfaces/`, `templates/`, `pages/`) — page-level default exports are how routers find pages and aren't dead even with no explicit imports.
