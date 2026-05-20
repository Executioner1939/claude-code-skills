# oracle-devops

DevOps sub-plugin of the oracle harness. Bundles Terraform/OpenTofu skill
expertise with four DevOps-flavoured Firecrawl workflow skills.

## What you get

- **`terraform-skill`** — repackaged from `antonbabenko/terraform-skill@v1.8.0`.
  Covers Terraform / OpenTofu modules, native testing (terraform test framework)
  + Terratest, CI/CD pipelines, security scanning (trivy, checkov), state
  operations, and architecture decisions. Version-aware guards diagnose
  identity churn, secrets, blast radius, CI drift, and state corruption.

- **`ci-moonrepo`** — moonrepo (moon) v2 expert. Workspace, tasks, CI/CD,
  Docker, remote caching, codegen, WASM toolchains, v1-to-v2 migration. Six
  production-derived failure modes (affected-detection no-ops, runInCI
  inheritance traps, project-id/Cargo/Docker name drift, toolchain bootstrap
  churn, remote-cache flakiness, `[[bin]]` collisions) each have a symptom-keyed
  workflow and a smoke-test script. Ships reactive hooks (`SessionStart`,
  `PreToolUse` edit/bash guards, `UserPromptSubmit` tagger).

- **`openapi-rust-gen`** — regenerate a Rust client crate from an OpenAPI spec
  via the pinned `openapitools/openapi-generator-cli` Docker image. Bundles a
  reusable shell script (`scripts/openapi-rust-gen.sh`) that handles URL or
  local-path specs, atomic snapshot writes under `docker/<provider>/`, and
  docker-pre-flight checks. Body documents the standard moon-task wiring so
  consuming repos get `moon run <crate>:gen-<provider>`.

- **Four Firecrawl workflow skills**, cherry-picked for DevOps work:
  - `firecrawl-knowledge-base` — build a searchable KB from scraped sources
  - `firecrawl-knowledge-ingest` — feed content into an existing KB
  - `firecrawl-qa` — QA pass over extracted web content
  - `firecrawl-website-design-clone` — extract a target site's design system
    (tokens, layouts, components) for reference or migration

## Install

Per DevOps repo (recommended), at project scope:

```bash
cd path/to/your/terraform-repo
claude plugin install oracle-devops@skunkworks --scope project
```

For a whole org tree (e.g. all `~/Documents/Work/Contactable/DevOps/*`):

```bash
cd ~/Documents/Work/Contactable/DevOps
claude plugin install oracle-devops@skunkworks --scope project
```

Child repos inherit via cwd walk-up.

## Provenance and licensing

- `skills/terraform-skill/` is Apache-2.0, copyright Anton Babenko. Upstream
  LICENSE is preserved at the plugin root as
  `UPSTREAM-LICENSE-terraform-skill`. No content changes.
- Firecrawl workflow skills carry their upstream licensing from
  `firecrawl/firecrawl-workflows`.
- This plugin's metadata (`plugin.json`, this README, `CHANGELOG.md`) is MIT.
