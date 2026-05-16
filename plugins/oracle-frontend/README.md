# oracle-frontend

Frontend-engineering bundle for Claude Code. Ships the three official Chakra UI v3
skills repackaged from `chakra-ui/chakra-ui@main` plus the `@chakra-ui/react-mcp`
server pre-wired.

## What you get

- **`chakra-ui-builder`** — build responsive, accessible Chakra UI v3 components,
  layouts, themes (tokens, semantic tokens, recipes, slot recipes), and charts.
  Includes a `references/` subdirectory with component decision tree, theming
  guide, and chart catalogue.
- **`chakra-ui-migrate`** — migrate Chakra v2 codebases to v3. Covers package
  changes, codemods, provider setup, color mode, prop renames, compound components.
- **`chakra-ui-refactor`** — review and convert plain HTML/CSS, Tailwind,
  CSS Modules, or styled-components to Chakra UI v3.
- **`@chakra-ui/react-mcp` server** — auto-loaded via `.mcp.json`. Exposes
  Chakra docs and Pro blocks as MCP tools to Claude Code.

## Install (per frontend sub-directory)

```bash
cd path/to/your/frontend-subdir
claude plugin install oracle-frontend@skunkworks --scope local
```

The `--scope local` keeps the install confined to that subdir — exactly the
sub-`.claude/` pattern for monorepos with multiple FE workspaces.

## Chakra Pro

Add `CHAKRA_PRO_API_KEY` to the consuming project's `.env` to unlock Pro blocks
through the MCP server.

## Provenance

Skills are sourced verbatim from `chakra-ui/chakra-ui@main` under `skills/`
(commit captured at packaging time). Updates flow through plugin version bumps.

## License

MIT. Skill content remains under the chakra-ui project's original licensing.
