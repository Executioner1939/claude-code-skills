# oracle-rust

Rust sub-plugin of the oracle harness. Bundles Rust documentation skill
expertise with rust-analyzer LSP wiring.

## What you get

- **`rust-utoipa` skill** — utoipa v5.4 OpenAPI documentation generator
  reference. Covers `ToSchema` derive, path attributes, security schemes,
  enum handling, validation, and integrations for Axum, Actix-web, Rocket.

- **`rust-analyzer` LSP** declared in the marketplace entry. Claude Code
  routes `.rs` files through `rust-analyzer` on PATH for completion,
  type-checking, refactor, and go-to-definition.

## Install

Per Rust repo (recommended), at project scope:

```bash
cd path/to/your/rust-repo
claude plugin install oracle-rust@skunkworks --scope project
```

## Prerequisite

`rust-analyzer` must be on PATH. Install via mise:

```bash
mise use rust-analyzer@latest
```

Or via rustup component:

```bash
rustup component add rust-analyzer
```

## Provenance

- `rust-utoipa` skill: relocated verbatim from the deprecated `rust-utoipa`
  plugin in this same marketplace.
- LSP config: equivalent to `rust-analyzer-lsp@claude-plugins-official`
  (Anthropic), repackaged here so installing oracle-rust gives you the
  LSP without that marketplace registered.

## License

MIT.
