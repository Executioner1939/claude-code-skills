---
name: setup
description: 'This skill should be used when the user explicitly invokes `/oracle:setup` to wire the oracle plugins preferred-search-workflows reference into the user-level CLAUDE.md as a one-line @-import. Idempotent -- safe to re-run; the line is appended only if it is not already present. Reversible -- the user can remove the line at any time. Triggers on the literal slash-command form. Also reports whether FIRECRAWL_API_KEY is set so the bundled MCP server can function.'
argument-hint: (no arguments)
allowed-tools: Bash, Read
---

# /oracle:setup

One-time, idempotent setup for the oracle plugin. Wires the
`docs/SEARCH-WORKFLOWS.md` reference into the user-level
`~/.claude/CLAUDE.md` as an `@-import` line, and reports on the
`FIRECRAWL_API_KEY` environment.

## Inputs

`$ARGUMENTS` is ignored.

## What this skill does

Run the steps below in order. State what is being done at each
step so the user can stop you if anything looks wrong.

### Step 1 -- Locate the plugin docs file

Use `Bash` to resolve the absolute path of the docs file:

```bash
# Find any installed oracle plugin cache, prefer the highest version
PLUGIN_PATH=$(find "$HOME/.claude/plugins/cache/skunkworks/oracle" -maxdepth 1 -mindepth 1 -type d 2>/dev/null | sort -V | tail -1)
DOC_PATH="${PLUGIN_PATH}/docs/SEARCH-WORKFLOWS.md"
```

If the docs file is not at that path (because the plugin is
loaded via `--plugin-dir` rather than a marketplace install),
resolve the path from `$CLAUDE_PLUGIN_ROOT/docs/SEARCH-WORKFLOWS.md`
if that environment variable is set, otherwise ask the user to
provide the absolute path manually.

State the resolved absolute path before proceeding.

### Step 2 -- Check whether the @-import is already present

```bash
CLAUDE_MD="$HOME/.claude/CLAUDE.md"
LINE="@${DOC_PATH}"

if [ -f "$CLAUDE_MD" ] && grep -Fxq "$LINE" "$CLAUDE_MD"; then
  echo "ALREADY PRESENT"
else
  echo "WILL ADD"
fi
```

If `ALREADY PRESENT`, skip to Step 4. Do not duplicate the line.

### Step 3 -- Append the @-import line (only if not present)

Before writing, state explicitly what is about to be appended:

```
The following one line will be appended to ~/.claude/CLAUDE.md:

  @<resolved-docs-path>

This is reversible -- remove the line at any time to undo.
```

Then append idempotently:

```bash
# Ensure the file ends with a newline before appending
if [ -f "$CLAUDE_MD" ] && [ -n "$(tail -c 1 "$CLAUDE_MD")" ]; then
  printf '\n' >> "$CLAUDE_MD"
fi
printf '\n# Oracle plugin preferred-search-workflows reference\n%s\n' "$LINE" >> "$CLAUDE_MD"
```

If `~/.claude/CLAUDE.md` does not exist, create it with just the
section header and the `@-import` line. Do not invent other
content.

### Step 4 -- Report on FIRECRAWL_API_KEY

```bash
if [ -n "${FIRECRAWL_API_KEY:-}" ]; then
  echo "FIRECRAWL_API_KEY is set (length: ${#FIRECRAWL_API_KEY} chars). MCP server should function."
else
  echo "FIRECRAWL_API_KEY is UNSET. The bundled firecrawl MCP server will not function until you export it."
  echo "Get a key at https://firecrawl.dev and add to your shell profile:"
  echo "  export FIRECRAWL_API_KEY=fc-..."
fi
```

### Step 5 -- Final report

Print a compact verdict:

```
oracle setup complete

- CLAUDE.md @-import: <added | already-present | created-new-file>
- Docs path: <resolved absolute path>
- FIRECRAWL_API_KEY: <set | unset>

The plugin will pick up the new @-import on the next session.
Restart Claude Code if you want it active immediately.
```

## Rules

- **Never modify any line of CLAUDE.md other than appending the
  designated @-import.** No reformatting, no removing existing
  content, no edits to other entries.
- **Always show the exact line before adding it.** The user must
  see what is about to change in their durable config.
- **Idempotent.** Re-running this command after it has already
  been applied is a no-op except for the report.
- **Reversible.** State explicitly in the final report how to
  remove the line.
- **Never write FIRECRAWL_API_KEY into any file.** Detect it from
  the environment only.

## Edge cases

- **`~/.claude/CLAUDE.md` does not exist.** Create it. Include
  only a comment header and the `@-import` line; no other content.
- **Plugin loaded via `--plugin-dir`, not a marketplace install.**
  Resolve the docs path from `$CLAUDE_PLUGIN_ROOT` if set.
- **Multiple oracle versions in the cache.** Use the highest
  version (the `sort -V | tail -1` pattern above).
- **The user has already added an `@-import` to a different path
  for the same docs file (older oracle version).** Detect via a
  fuzzy match on `oracle/.*/docs/SEARCH-WORKFLOWS.md`; offer to
  update the path rather than appending a duplicate.
