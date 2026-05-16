# Changelog

All notable changes to the `oracle-rust` plugin are documented in this file.

The format is based on [Keep a Changelog 1.1.0](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning 2.0.0](https://semver.org/spec/v2.0.0.html).

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
