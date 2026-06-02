# Changelog

All notable changes to the `oracle-rust` plugin are documented in this file.

The format is based on [Keep a Changelog 1.1.0](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning 2.0.0](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2026-06-02

### Added
- SessionStart LSP onboarding (`hooks/hooks.json` + `scripts/lsp-onboard.py`).
  When `rust-analyzer` is not on PATH and the project contains `.rs` files, the
  hook injects context asking Claude to offer installation via the user's
  detected tooling (mise, rustup, cargo, brew) or the official route, then
  records the decision under `${CLAUDE_PLUGIN_DATA}` so the prompt never
  repeats. Silent and walk-free when the binary is already installed; never
  installs anything itself; fails open.

### Changed
- LSP declaration moved to a plugin-root `.lsp.json` (the documented mechanism),
  replacing the inline `lspServers` block that previously lived only in the
  marketplace entry. Behaviour unchanged: `rust-analyzer` for `.rs` files.

## [1.0.0] - 2026-05-16

### Added
- Initial release.
- `skills/rust-utoipa/` folded in from the former `rust-utoipa` plugin
  (utoipa v5.4 OpenAPI documentation macros for Rust, with framework
  integrations for Axum, Actix-web, and Rocket).
- LSP server declaration in `marketplace.json` wires `rust-analyzer`
  for `.rs` files. Equivalent to `rust-analyzer-lsp@claude-plugins-official`
  but baked into this plugin so you don't need that marketplace
  registered.

### Prerequisites
- `rust-analyzer` on PATH. Install via mise:
  ```bash
  mise use rust-analyzer@latest
  ```
  or via rustup component:
  ```bash
  rustup component add rust-analyzer
  ```

### Provenance
- `rust-utoipa` skill content moved from the `rust-utoipa` plugin in
  this same marketplace (no upstream change; just renamed and re-homed
  under the oracle umbrella).
- LSP config replicates `anthropics/claude-plugins-official`'s
  `rust-analyzer-lsp` plugin marketplace entry.
