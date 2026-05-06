---
name: safe-delete
description: Check whether a component file is safe to delete by scanning the project's import graph for remaining consumers. Pre-flight before any component removal. Refuses (exit 2) when consumers exist; lists each consumer file with the named imports it uses, so the agent or user can migrate before the delete. Backed by `@anvil/inspector`'s structural import-graph walk -- catches imports that grep would miss when path aliases (`@/components/...`, `@dsg/ds-web`) are in play. Invoke as `/anvil:safe-delete <component-path> [--export <name>]`.
argument-hint: "<component-path> [--export <exported-name>]"
arguments: args
allowed-tools: Read, Bash
model: claude-sonnet-4-6
---

# Safe-delete: pre-flight before removing a component

Asks the import graph "if I delete this file, what consumers break?" and refuses if any exist. The `--export <name>` filter narrows the check to consumers that import a specific named export -- useful when one export of the file is being removed but the rest survive.

## Why this command exists

When the original chrome rebuild deleted `Drawer`, `NavigationBar`, `MobileNav`, and `Footer` from `src/components/`, the agent missed several consumers in `.storybook/showcase/pages/*.stories.tsx`. Vite caught it after the fact with `Failed to resolve import` errors. The fix is structural: build the project's import graph (resolving tsconfig path aliases) and ask "who imports this file?" before the file disappears.

## Argument shape

`$args` carries the positional `component-path`, optionally followed by `--export <name>`.

## Steps

### 1. Parse arguments

```!
set -e
PARSED_ARGS="$args"
EXPORT_NAME=""
if printf "%s" "$PARSED_ARGS" | grep -q -- "--export"; then
  EXPORT_NAME=$(printf "%s" "$PARSED_ARGS" | sed -n 's/.*--export[ =]\([^ ]*\).*/\1/p')
  PARSED_ARGS=$(printf "%s" "$PARSED_ARGS" | sed 's/--export[ =][^ ]*//')
fi
COMPONENT_PATH=$(printf "%s" "$PARSED_ARGS" | awk '{print $1}')
if [ "${COMPONENT_PATH#/}" = "$COMPONENT_PATH" ]; then
  COMPONENT_PATH="$(pwd)/$COMPONENT_PATH"
fi

PROJECT_ROOT="$(dirname "$COMPONENT_PATH")"
while [ "$PROJECT_ROOT" != "/" ] && [ ! -f "$PROJECT_ROOT/pnpm-workspace.yaml" ] && [ ! -f "$PROJECT_ROOT/package.json" ]; do
  PROJECT_ROOT="$(dirname "$PROJECT_ROOT")"
done

echo "COMPONENT_PATH=$COMPONENT_PATH"
echo "PROJECT_ROOT=$PROJECT_ROOT"
echo "EXPORT_NAME=$EXPORT_NAME"
```

### 2. Run the safe-delete check

```!
INSPECTOR_DIR="${CLAUDE_PLUGIN_ROOT}/scripts/component-inspector"
cd "$INSPECTOR_DIR"

CMD="pnpm exec tsx src/cli.ts safe-delete \"$COMPONENT_PATH\" --root \"$PROJECT_ROOT\""
if [ -n "$EXPORT_NAME" ]; then
  CMD="$CMD --export \"$EXPORT_NAME\""
fi
eval "$CMD" || true
```

The CLI exits `2` when consumers exist. Capture the exit code so the chained workflow can refuse to proceed.

### 3. Recommend a migration plan

When consumers exist:

1. Print each consumer's path and the names it imports.
2. For each consumer, propose either:
   - A migration target (`Drawer` → `ContextSheet`, `NavigationBar` → `<HeaderSurface>`, etc.) drawn from prior project context, or
   - A `/anvil:safe-rename-story-title` / `/anvil:remove-import` chain to clean the consumer up.
3. Refuse to delete the file in this command. Deletion is a separate, deliberate step.

When no consumers exist, surface `safe to delete` and stop -- the user runs `rm` (or whichever tool they prefer) themselves.
