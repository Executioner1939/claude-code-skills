# Changelog

All notable changes to the `oracle-frontend` plugin are documented in this file.

The format is based on [Keep a Changelog 1.1.0](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning 2.0.0](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2026-06-02

### Added
- `.lsp.json` wiring `typescript-language-server` as the LSP for
  `.ts`/`.mts`/`.cts`/`.tsx`/`.js`/`.mjs`/`.cjs`/`.jsx` files. This covers
  React, Next.js, Storybook, and Node code intelligence (those are all
  TypeScript/JavaScript and have no dedicated language server of their own).
  Prereq: `typescript-language-server` on PATH
  (`npm i -g typescript-language-server typescript`).

## [1.0.0] - 2026-05-16

### Added
- Initial release.
- Three skills repackaged verbatim from `chakra-ui/chakra-ui@main` under `skills/`:
  - `chakra-ui-builder` (with `references/` subdirectory: charts, component decision tree, theming)
  - `chakra-ui-migrate`
  - `chakra-ui-refactor`
- `.mcp.json` wires the official `@chakra-ui/react-mcp` server as a stdio MCP that
  auto-loads when the plugin is installed at `--scope local` or higher.
- Plugin is intended for per-FE-subdirectory installation
  (`claude plugin install oracle-frontend@skunkworks --scope local` from each
  frontend root or monorepo subdir).

### Notes
- Replaces the `npx skills add chakra-ui/chakra-ui` workflow with a single
  `claude plugin` invocation. Eliminates the TUI prompts and per-skill repo clones.
- Pin Chakra Pro features by setting `CHAKRA_PRO_API_KEY` in the consuming
  project's `.env` (the MCP picks it up via the npx subprocess environment).
