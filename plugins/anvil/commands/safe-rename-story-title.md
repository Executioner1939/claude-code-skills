---
name: safe-rename-story-title
description: Structurally rename `meta.title` in a Storybook CSF3 stories file. Touches ONLY the title property of the meta object -- never `title:` properties inside fixture data, args, or arbitrary object literals. Backed by `@anvil/inspector`'s AST-anchored locator; this is the canonical replacement for `sed`-style bulk title renames, which have a documented failure mode of stomping fixture content (the original transcript that motivated this work overwrote `"Casual range session"`, `"Email verified"`, `"Visa"`, and `"Order shipped"` because regex matched the first `title:` lexically). Dry-run by default; pass `--apply` to write. Invoke as `/anvil:safe-rename-story-title <story-path> "<new-title>" [--apply]`.
argument-hint: "<story-path> <new-title> [--apply]"
arguments: args
allowed-tools: Read, Bash
model: claude-sonnet-4-6
---

# Safe rename: Storybook meta.title

Renames the `meta.title` property of a CSF3 stories file using a structural locator. Refuses to touch any other `title:` literal in the file.

## Why this command exists

A regex aimed at `title:` matches the first lexical occurrence in each file. When the file has a fixture array like:

```tsx
const FIXTURE_LINKS = [
  { title: "Casual range session", href: "/book/casual" },
  { title: "Email verified", href: "/account" },
];

const meta = {
  title: "Atoms/Form/Button",
  // ...
};
```

…the regex lands on `"Casual range session"`, not on `"Atoms/Form/Button"`. This command's locator targets only the `title:` property of the object literal that is `export default`-ed and either `satisfies Meta<...>` / `: Meta<...>` typed -- structurally bounded, not text-bounded.

## Argument shape

`$args` carries the positional `story-path` and `new-title`, optionally followed by `--apply`. Example:

```
src/components/atoms/Button/Button.stories.tsx "Atoms/Actions/Button" --apply
```

Parse `$args` so:
- The first whitespace-separated token is the story path.
- The remaining tokens up to `--apply` (or end of string) form the new title; preserve quotes if the user wrapped the title in `"..."`.
- The `--apply` flag is detected anywhere in `$args`.

## Steps

### 1. Resolve story path

```!
set -e
PARSED_ARGS="$args"
APPLY=""
if printf "%s" "$PARSED_ARGS" | grep -q -- "--apply"; then
  APPLY="--apply"
  PARSED_ARGS=$(printf "%s" "$PARSED_ARGS" | sed 's/--apply//g')
fi

# First word: story path. Remainder: new title (strip optional surrounding quotes).
STORY_PATH=$(printf "%s" "$PARSED_ARGS" | awk '{print $1}')
NEW_TITLE=$(printf "%s" "$PARSED_ARGS" | sed 's/^[^ ]* *//' | sed 's/^["'"'"']//;s/["'"'"']$//')

# Resolve to absolute.
if [ "${STORY_PATH#/}" = "$STORY_PATH" ]; then
  STORY_PATH="$(pwd)/$STORY_PATH"
fi

echo "STORY_PATH=$STORY_PATH"
echo "NEW_TITLE=$NEW_TITLE"
echo "APPLY=$APPLY"
```

If `STORY_PATH` doesn't end in `.stories.tsx`, `.stories.ts`, `.stories.jsx`, or `.stories.js`, ask the user for the correct path and stop.

If `NEW_TITLE` is empty, ask the user for it and stop.

### 2. Run the structural rename

```!
INSPECTOR_DIR="${CLAUDE_PLUGIN_ROOT}/scripts/component-inspector"
cd "$INSPECTOR_DIR"

pnpm exec tsx src/cli.ts rename-story-title "$STORY_PATH" "$NEW_TITLE" $APPLY
```

The CLI prints the byte range it located, the old value, and the new value. When run without `--apply`, it does NOT write -- the user reviews the dry-run, then re-invokes with `--apply`.

### 3. Verify

After applying, confirm the file still typechecks. The rename only swaps a string literal so this is usually a no-op, but a stale `as const` or template-literal type elsewhere can flag:

```bash
# Run from the project root that owns the stories file:
pnpm typecheck
```

If the file contains `as const` constraints on the title, surface the diagnostic and offer to revert.
