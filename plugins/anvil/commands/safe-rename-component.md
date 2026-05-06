---
name: safe-rename-component
description: Rename a component identifier across the entire project — every JSX usage, every import specifier, every export specifier, every type reference, plus the declaration's own interface / type-alias / function / variable name. Co-renames the conventional `<Name>Props` type by default. Backed by `@anvil/inspector`'s structural rewriter (TS Compiler API). Dry-run unless `--apply`. Use this whenever a component is being renamed in place of `sed` / `find -exec sed`, which silently match identifiers inside string literals and comments. Invoke as `/anvil:safe-rename-component --from <OldName> --to <NewName> [--no-rename-props] [--apply]`.
argument-hint: "--from <OldName> --to <NewName> [--no-rename-props] [--apply]"
arguments: args
allowed-tools: Read, Bash
model: claude-sonnet-4-6
---

# Safe rename: component identifier (project-wide)

Renames a component across every file in the project. Walked structurally:

| Surface | Rewrite |
| --- | --- |
| JSX usages | `<OldName>`, `<OldName/>`, `</OldName>` → `<NewName>` |
| Import specifiers | `import { OldName }`, `import { OldName as Local }`, `import { Foo as OldName }` |
| Export specifiers | `export { OldName }`, `export { OldName as Foo }` |
| Type references | `Record<OldName>`, `extends OldName`, `: OldName` |
| Declarations | `interface OldName`, `type OldName`, `function OldName`, `export const OldName`, `forwardRef(function OldName(...))` |
| `<OldName>Props` | renamed alongside (opt-out via `--no-rename-props`) |

What it does NOT do:

- Rename the implementation file itself (`Drawer.tsx` → `ContextSheet.tsx`). File renames are a separate, deliberate step (and usually demand a directory rename too).
- Rename string literals or comments mentioning `OldName`.
- Touch `import { Foo as OldName }`-style aliases where `Foo` is unrelated, beyond renaming the local binding.

## Argument shape

`$args` carries:
- `--from <OldName>` (required)
- `--to <NewName>` (required)
- `--root <dir>` (optional; defaults to the closest project root)
- `--no-rename-props` (optional; skip the `<Name>Props` co-rename)
- `--apply` (optional; default is dry-run)

## Steps

### 1. Parse flags

```!
set -e
extract() { printf "%s" "$args" | sed -n "s/.*--$1[ =]\\([^ ]*\\).*/\\1/p"; }

FROM=$(extract from)
TO=$(extract to)
ROOT_FLAG=$(extract root)
APPLY=""
NO_RENAME_PROPS=""
if printf "%s" "$args" | grep -q -- "--apply"; then APPLY="--apply"; fi
if printf "%s" "$args" | grep -q -- "--no-rename-props"; then NO_RENAME_PROPS="--no-rename-props"; fi

if [ -z "$ROOT_FLAG" ]; then
  ROOT_FLAG="$(pwd)"
  while [ "$ROOT_FLAG" != "/" ] && [ ! -f "$ROOT_FLAG/pnpm-workspace.yaml" ] && [ ! -f "$ROOT_FLAG/package.json" ]; do
    ROOT_FLAG="$(dirname "$ROOT_FLAG")"
  done
fi

echo "FROM=$FROM"
echo "TO=$TO"
echo "ROOT=$ROOT_FLAG"
echo "APPLY=$APPLY"
echo "NO_RENAME_PROPS=$NO_RENAME_PROPS"
```

If `FROM` or `TO` is empty, ask the user and stop.

### 2. Run the rename

```bash
INSPECTOR_DIR="${CLAUDE_PLUGIN_ROOT}/scripts/component-inspector"
cd "$INSPECTOR_DIR"

pnpm exec tsx src/cli.ts rename-component \
  --from "$FROM" \
  --to "$TO" \
  --root "$ROOT_FLAG" \
  $NO_RENAME_PROPS \
  $APPLY
```

The CLI prints per-file edit counts (`jsx:N  imports:N  exports:N`) and line numbers. Without `--apply`, no files change.

### 3. Verify

After applying, run the project's typecheck and lint. The rename leaves the source semantically equivalent if every consumer was caught — typecheck failures usually indicate a consumer outside the scanned globs (e.g. a tooling script or a config file that imports the component). Surface those and either (a) widen the include glob via `--root` or `--include`, or (b) edit them by hand.

If the project has MDX docs that reference the old component, also run:

```bash
pnpm exec tsx src/cli.ts verify-mdx "$ROOT_FLAG"
```

— some MDX `import * as Stories` paths may still be fine, but any direct `<OldName>` reference inside MDX prose was not rewritten by this command (MDX prose is text, not JSX, from the parser's perspective). Fix manually.
