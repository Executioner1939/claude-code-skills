---
name: safe-rename-jsx-prop
description: Rename a JSX attribute on every usage of a component, repo-wide. Touches only the named JSX attribute on the matching component -- never `className` strings, comments, type aliases, or props on other components. Backed by `@anvil/inspector`'s structural rewriter (TS Compiler API). Dry-run by default; `--apply` to write. Use this whenever a component prop is renamed (e.g. `<Button pip={x} />` → `<Button badge={x} />`) so consumers update structurally rather than by `sed`. Invoke as `/anvil:safe-rename-jsx-prop --component <Name> --from <oldProp> --to <newProp> [--apply]`.
argument-hint: "--component <Name> --from <oldProp> --to <newProp> [--apply]"
arguments: args
allowed-tools: Read, Bash
model: claude-sonnet-4-6
---

# Safe rename: JSX attribute on a component

Renames `<Button pip={x}>` → `<Button badge={x}>` (or any equivalent) across the whole repo using the TS AST. Spread props (`{...rest}`) are intentionally left untouched -- analysing them would require dataflow tracking. The component's TypeScript prop declaration is also not modified by this command; rename it on the interface as a separate step.

## Argument shape

`$args` carries `--component <Name> --from <oldProp> --to <newProp>`, optionally `--apply`.

## Steps

### 1. Parse flags

```!
set -e
extract() {
  printf "%s" "$args" | sed -n "s/.*--$1[ =]\\([^ ]*\\).*/\\1/p"
}

COMPONENT=$(extract component)
FROM=$(extract from)
TO=$(extract to)
APPLY=""
if printf "%s" "$args" | grep -q -- "--apply"; then APPLY="--apply"; fi

echo "COMPONENT=$COMPONENT"
echo "FROM=$FROM"
echo "TO=$TO"
echo "APPLY=$APPLY"
```

If any of `COMPONENT` / `FROM` / `TO` is empty, ask the user and stop.

### 2. Run the rename

```!
INSPECTOR_DIR="${CLAUDE_PLUGIN_ROOT}/scripts/component-inspector"
cd "$INSPECTOR_DIR"
PROJECT_ROOT="$(pwd)"
while [ "$PROJECT_ROOT" != "/" ] && [ ! -f "$PROJECT_ROOT/pnpm-workspace.yaml" ] && [ ! -f "$PROJECT_ROOT/package.json" ]; do
  PROJECT_ROOT="$(dirname "$PROJECT_ROOT")"
done

pnpm exec tsx src/cli.ts rename-jsx-prop \
  --component "$COMPONENT" \
  --from "$FROM" \
  --to "$TO" \
  --root "$PROJECT_ROOT" \
  $APPLY
```

The CLI lists each rewritten file with the line numbers it touched. Without `--apply`, no files change -- the user reviews the dry-run and re-invokes with `--apply`.

### 3. Recommend follow-up

After the rewrite, two things still need attention:

1. **The component's prop declaration.** The interface still names the old prop. Edit the source by hand, or ask the user to. (A future `/anvil:rename-prop` will do this in one shot; for v1 this is split.)
2. **TypeScript check.** Run `pnpm typecheck` from the project root. If the component's type still requires the old name, the rewritten consumers will surface as type errors -- that's the correct order of fixing (consumers first, declaration second), since otherwise the declaration change cascades into hundreds of unfixed callsites.
