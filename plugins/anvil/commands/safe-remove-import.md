---
name: safe-remove-import
description: Strip a named identifier from every `import` statement that mentions it, repo-wide. Removes the entire import statement when the name was the only specifier; preserves the rest when other names remain. Use after deleting a component (or paired with `/anvil:safe-delete`) to clean up orphan imports without `sed`. Backed by `@anvil/inspector` (TS Compiler API). Dry-run by default; `--apply` to write. Invoke as `/anvil:safe-remove-import --name <Identifier> [--apply]`.
argument-hint: "--name <Identifier> [--apply]"
arguments: args
allowed-tools: Read, Bash
model: claude-sonnet-4-6
---

# Safe remove-import

Strip a name from every `import` statement that mentions it. Type-only imports follow the same rules. The module specifier is preserved verbatim.

## When to use

- After `/anvil:safe-delete` confirms a file is unreachable -- but `safe-delete` won't remove imports for you, this command does.
- When migrating from one component name to another and the old name's imports linger in stories or showcase files.
- During a deletion pass where multiple files re-export the deleted name.

## Argument shape

`$args` carries `--name <Identifier>`, optionally `--apply`.

## Steps

### 1. Parse flags

```!
set -e
NAME=$(printf "%s" "$args" | sed -n 's/.*--name[ =]\([^ ]*\).*/\1/p')
APPLY=""
if printf "%s" "$args" | grep -q -- "--apply"; then APPLY="--apply"; fi

echo "NAME=$NAME"
echo "APPLY=$APPLY"
```

If `NAME` is empty, ask the user and stop.

### 2. Run the rewrite

```!
INSPECTOR_DIR="${CLAUDE_PLUGIN_ROOT}/scripts/component-inspector"
cd "$INSPECTOR_DIR"
PROJECT_ROOT="$(pwd)"
while [ "$PROJECT_ROOT" != "/" ] && [ ! -f "$PROJECT_ROOT/pnpm-workspace.yaml" ] && [ ! -f "$PROJECT_ROOT/package.json" ]; do
  PROJECT_ROOT="$(dirname "$PROJECT_ROOT")"
done

pnpm exec tsx src/cli.ts remove-import --name "$NAME" --root "$PROJECT_ROOT" $APPLY
```

The CLI tags each hit `[removed-statement]` (the entire `import` line was dropped) or `[stripped-specifier]` (the name was removed but other specifiers in the same statement remained).

### 3. Verify

After applying, run the project's typecheck. Removing an import that was actually used -- because the JSX usage wasn't migrated first -- will surface as `'Foo' is not defined`. That's the correct order: migrate JSX with `/anvil:safe-rename-jsx-prop` first, then strip imports last.
