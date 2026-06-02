# Changelog

All notable changes to the `carbon-solana` plugin are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Reinstated in the `skunkworks` marketplace (marketplace `5.39.0`) after the
  `5.35.0` consolidation to the four `oracle-*` plugins had removed it. Plugin
  content restored unchanged from the pre-removal tree.

## [0.1.0]

### Added

- Top-level `carbon-solana` skill covering the carbon-core pipeline:
  datasources, the five pipe types, the `Processor` trait, decoders, and
  transaction schema matching.
- 64 per-protocol sub-skills (Raydium, Pumpfun, Meteora, Orca, Phoenix,
  OpenBook, Jupiter, Drift, Zeta, Marginfi, Kamino, Lifinity, SPL Token, MPL,
  and more), each listing instructions, accounts, CPI events, and shared types.
- `scripts/carbon.py`: on-demand extraction of struct fields, discriminators,
  and `ArrangeAccounts` variants from the local cargo registry cache (or
  `$CARBON_SRC`) via ast-grep with a regex fallback, avoiding stale snapshots.
