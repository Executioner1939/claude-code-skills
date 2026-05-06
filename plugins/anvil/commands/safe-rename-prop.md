---
name: safe-rename-prop
description: Rename a prop on a component, end-to-end — the declaration interface (`<Component>Props`), the destructured parameter binding, every body reference inside the principal function, and every consumer JSX attribute. Backed by `@anvil/inspector`'s structural rewriter. Dry-run unless `--apply`. Surfaces any nested-closure shadowing risk so the user can review manually. Invoke as `/anvil:safe-rename-prop --component <Name> --declaration <path> --from <oldProp> --to <newProp> [--apply]`.
argument-hint: "--component <Name> --declaration <path> --from <oldProp> --to <newProp> [--apply]"
arguments: args
allowed-tools: Read, Bash
model: claude-sonnet-4-6
---

# Safe rename: prop

Renames a prop on a component in three coordinated passes — declaration, body references, consumer JSX usages.

## What gets rewritten

| Pass | Surface | Example |
| --- | --- | --- |
| 1. Declaration | `<Component>Props` interface or type alias | `interface ButtonProps { pip?: number }` → `{ badge?: number }` |
| 1. Declaration | Destructured first parameter | `function Button({ pip = 0, ... })` → `{ badge = 0, ... }` |
| 1. Declaration | Body references inside the principal function (immediate body only) | `if (pip != null) ...` → `if (badge != null) ...` |
| 2. Consumers | Every `<Component oldProp={...}>` JSX attribute | `<Button pip={3}>` → `<Button badge={3}>` |

What it does NOT do:

- Rewrite body references inside nested closures (a nested function may shadow the prop name with a parameter / variable of the same name; the renamer flags the risk and skips, surfacing a note).
- Rewrite property accesses like `obj.pip` (those are different `pip`s).
- Rewrite shorthand object property keys (`{ pip }` declares a NEW property; left alone, surfaced as a note).
- Rename the prop on a tier-foreign component that happens to share a prop name (e.g. if both `<Button pip>` and `<Card pip>` exist, only `<Component>` consumers get rewritten).

## Argument shape

`$args` carries:
- `--component <Name>` (required)
- `--declaration <path>` (required) — path of the implementation file (e.g. `src/components/atoms/Button/Button.tsx`)
- `--from <oldProp>` (required)
- `--to <newProp>` (required)
- `--root <dir>` (optional; defaults to closest project root)
- `--apply` (optional; default is dry-run)

## Steps

### 1. Parse flags

```!
set -e
extract() { printf "%s" "$args" | sed -n "s/.*--$1[ =]\\([^ ]*\\).*/\\1/p"; }

COMPONENT=$(extract component)
DECLARATION=$(extract declaration)
FROM=$(extract from)
TO=$(extract to)
ROOT_FLAG=$(extract root)
APPLY=""
if printf "%s" "$args" | grep -q -- "--apply"; then APPLY="--apply"; fi

if [ -z "$ROOT_FLAG" ]; then
  ROOT_FLAG="$(pwd)"
  while [ "$ROOT_FLAG" != "/" ] && [ ! -f "$ROOT_FLAG/pnpm-workspace.yaml" ] && [ ! -f "$ROOT_FLAG/package.json" ]; do
    ROOT_FLAG="$(dirname "$ROOT_FLAG")"
  done
fi

if [ "${DECLARATION#/}" = "$DECLARATION" ]; then
  DECLARATION="$ROOT_FLAG/$DECLARATION"
fi

echo "COMPONENT=$COMPONENT"
echo "DECLARATION=$DECLARATION"
echo "FROM=$FROM  TO=$TO"
echo "ROOT=$ROOT_FLAG"
echo "APPLY=$APPLY"
```

If any required field is empty or the declaration path doesn't exist, stop and ask.

### 2. Run the rename

```bash
INSPECTOR_DIR="${CLAUDE_PLUGIN_ROOT}/scripts/component-inspector"
cd "$INSPECTOR_DIR"

pnpm exec tsx src/cli.ts rename-prop \
  --component "$COMPONENT" \
  --declaration "$DECLARATION" \
  --from "$FROM" \
  --to "$TO" \
  --root "$ROOT_FLAG" \
  $APPLY
```

The CLI prints two sections — declaration edits (counts of interface / destructure / bodyReference rewrites) and consumer JSX edits — plus a `Notes:` block when shadowing or unusual destructure shape was detected.

### 3. Review notes carefully

Common notes:

- **`shadowing-detected: a nested function declares 'pip' as a local`** — there's a closure inside the component body that uses `pip` as its own parameter or variable. The rename skipped those references. Open the declaration file, find the nested function, decide whether the inner `pip` should also be renamed, and edit by hand.
- **`prop-pip-not-destructured-from-first-parameter`** — the prop is read via `props.pip` instead of `{ pip }` destructuring. The rename touched the interface and consumers; the body remains using `props.pip`. Either keep that idiom (and `props.pip` will still typecheck since the interface was renamed) or destructure and re-run.
- **`no-<Component>Props-decl-found`** — the component doesn't follow the `<Name>Props` convention. Surface and ask the user where the prop type lives.

### 4. Verify

After applying, run typecheck. Any `Property 'pip' does not exist` error indicates a body reference the renamer missed — usually inside a nested closure. Fix and re-typecheck.
