# Changelog

All notable changes to the `oracle-devops` plugin are documented in this file.

The format is based on [Keep a Changelog 1.1.0](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning 2.0.0](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-05-16

### Added
- Initial release.
- `skills/terraform-skill/` repackaged verbatim from
  `antonbabenko/terraform-skill@v1.8.0` (Apache-2.0 upstream; see
  `UPSTREAM-LICENSE-terraform-skill`). Covers Terraform / OpenTofu
  modules, native testing + Terratest, CI pipelines, security scanning
  (trivy, checkov), and state ops with version-aware guards.
- Four cherry-picked dev workflow skills repackaged from
  `firecrawl/firecrawl-workflows@main`:
  - `firecrawl-knowledge-base` — build searchable knowledge bases
  - `firecrawl-knowledge-ingest` — ingest content into a knowledge base
  - `firecrawl-qa` — QA on extracted web content
  - `firecrawl-website-design-clone` — extract design systems from running sites
- `assets/` and `tests/` directories carried over from the terraform-skill
  upstream so the skill's references and self-tests still resolve.

### Provenance
- `terraform-skill` is Apache-2.0 (Anton Babenko). The upstream LICENSE
  is preserved at the plugin root as `UPSTREAM-LICENSE-terraform-skill`.
- Firecrawl workflow skills are sourced from `firecrawl/firecrawl-workflows@main`.
