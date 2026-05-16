# oracle-devops

DevOps sub-plugin of the oracle harness. Bundles Terraform/OpenTofu skill
expertise with four DevOps-flavoured Firecrawl workflow skills.

## What you get

- **`terraform-skill`** — repackaged from `antonbabenko/terraform-skill@v1.8.0`.
  Covers Terraform / OpenTofu modules, native testing (terraform test framework)
  + Terratest, CI/CD pipelines, security scanning (trivy, checkov), state
  operations, and architecture decisions. Version-aware guards diagnose
  identity churn, secrets, blast radius, CI drift, and state corruption.

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
