### Rust ecosystem sources

Authority order for Rust claims:

1. `cargo search <crate> --limit 1` and `cargo info <crate>` for current
   version and metadata.
2. `https://docs.rs/<crate>/latest/<crate>/` for the rendered API. The
   per-version path `https://docs.rs/<crate>/<version>/<crate>/` is the
   correct one to cite when the project pins a non-latest version.
3. `https://crates.io/crates/<crate>` for download counts, dependents,
   and the maintainer-supplied README.
4. `https://lib.rs/crates/<crate>` for the editorial summary and
   alternatives list (lib.rs ranks differently from crates.io and is
   useful for cross-checking popularity claims).
5. `https://this-week-in-rust.org/` for ecosystem-wide announcements,
   stabilisation news, and RFC progress.

For RFCs and language features:

- `https://github.com/rust-lang/rfcs/blob/master/text/<NNNN>-<slug>.md`
  for the RFC text.
- `https://github.com/rust-lang/rust/issues/<N>` for tracking issues.
- The Rust release notes at
  `https://github.com/rust-lang/rust/blob/master/RELEASES.md` for which
  version stabilised what.

Cargo manifest convention: when the surrounding project has a
`Cargo.toml`, treat its `[dependencies]` table as authoritative for
which versions are in use. A pinned dependency is the verification
decision; do not re-verify it.
