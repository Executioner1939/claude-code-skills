### Multi-ecosystem source order

The project does not pin a single primary language. Detect the
ecosystem from the claim itself or from the manifest files in the
surrounding project (`Cargo.toml`, `package.json`, `pyproject.toml`,
`go.mod`, `Gemfile`), then apply that ecosystem's standard authority
order:

- Rust: `cargo search` then `docs.rs` then `crates.io` then `lib.rs`.
- TypeScript / JavaScript: `npm view` then the package's npm page then
  TypeDoc or maintainer docs site.
- Python: `pip index versions` then `pypi.org` then ReadTheDocs or
  maintainer docs site.
- Go: `go list -m -versions` then `pkg.go.dev` then the module's
  GitHub releases.
- Other ecosystems: the language-appropriate package registry first,
  then the maintainer's primary doc site, then GitHub releases /
  CHANGELOG.

Authoritative across all ecosystems: a pinned dependency in the
surrounding project's manifest. Do not re-verify a pin -- the pin is
the verification decision.
