---
name: inspect
description: Print a structured component card -- props, story variants, args, consumers, tokens, and lint-style issues -- for the component at the given path. Backed by `@anvil/inspector` (TypeScript Compiler API + ast-grep), so the data is structurally precise rather than regex-derived. Use this whenever an agent or user needs to know "what does this component look like, who uses it, what tokens does it touch" -- before authoring a story, before refactoring, before deleting, or as input to any other audit. Invoke as `/anvil:inspect <path-to-component>` (e.g. `/anvil:inspect src/components/atoms/Button/Button.tsx`).
argument-hint: "<component-path> [--json] [--no-consumers]"
arguments: component_path
allowed-tools: Read, Bash
model: claude-sonnet-4-6
---

# Inspect: structured card for one component

Prints a markdown component card built from the TypeScript AST and the project's import graph. Useful as a pre-flight before any modification, and as input to `/anvil:audit-component` and the audit subagents.

Argument: `$component_path` -- repo-relative or absolute path to a component implementation file (`.tsx`, `.ts`, `.jsx`).

Optional mode flags (parsed from `$component_path` if present):

- `--json` -- emit JSON instead of markdown.
- `--no-consumers` -- skip the consumer scan (faster on cold runs; the rest of the card still renders).

## Steps

### 1. Locate the project root

The inspector needs a project root to anchor relative paths and run the consumer scan. Detect it from the component path:

```!
set -e
COMPONENT_ARG="$component_path"
# Strip any --json / --no-consumers flags for the path detection.
COMPONENT_PATH=$(printf "%s" "$COMPONENT_ARG" | awk '{print $1}')
# Resolve to absolute.
if [ "${COMPONENT_PATH#/}" = "$COMPONENT_PATH" ]; then
  COMPONENT_PATH="$(pwd)/$COMPONENT_PATH"
fi
COMPONENT_PATH="$(cd "$(dirname "$COMPONENT_PATH")" && pwd)/$(basename "$COMPONENT_PATH")"

# Walk up from the component until we find a `package.json` or a `pnpm-workspace.yaml`.
PROJECT_ROOT="$(dirname "$COMPONENT_PATH")"
while [ "$PROJECT_ROOT" != "/" ]; do
  if [ -f "$PROJECT_ROOT/package.json" ] || [ -f "$PROJECT_ROOT/pnpm-workspace.yaml" ]; then
    break
  fi
  PROJECT_ROOT="$(dirname "$PROJECT_ROOT")"
done

echo "COMPONENT_PATH=$COMPONENT_PATH"
echo "PROJECT_ROOT=$PROJECT_ROOT"
```

If `PROJECT_ROOT` is `/`, ask the user for the project root and stop.

### 2. Run the inspector

Use the bundled `@anvil/inspector` package. Output format follows the flag:

```!
INSPECTOR_DIR="${CLAUDE_PLUGIN_ROOT}/scripts/component-inspector"
cd "$INSPECTOR_DIR"

# Pass-through args:
EXTRA_FLAGS=""
if printf "%s" "$component_path" | grep -q -- "--no-consumers"; then EXTRA_FLAGS="$EXTRA_FLAGS --no-consumers"; fi

if printf "%s" "$component_path" | grep -q -- "--json"; then
  pnpm exec tsx src/cli.ts json "$COMPONENT_PATH" --root "$PROJECT_ROOT" $EXTRA_FLAGS
else
  pnpm exec tsx src/cli.ts card "$COMPONENT_PATH" --root "$PROJECT_ROOT" $EXTRA_FLAGS
fi
```

If the inspector exits non-zero, surface the error and stop. Common failure modes:

- The path is not a component file -- ask the user to point at `<Name>.tsx`, not the directory.
- `pnpm install` hasn't been run inside `scripts/component-inspector`. Install:

  ```bash
  cd "${CLAUDE_PLUGIN_ROOT}/scripts/component-inspector" && pnpm install
  ```

### 3. Surface the card

Print the inspector's stdout verbatim. When the card carries `Issues`, mention each one in a one-line summary at the end so the user sees the headline findings even if they skim the table.

The card's `Tokens` section lists the CSS variables, Tailwind aliases, and any literal violations (hex colours, raw lengths, hardcoded easings). The `Issues` section flags `raw-tailwind-layout`, `process-env-in-browser-code`, `missing-stories`, `forward-ref-no-display-name`, and `hardcoded-token-literal`.

When chained from `/anvil:audit-component`, drop the verbose props table and surface just `Issues` + `Consumers` -- those are the only sections that drive audit decisions.
