# terraform-audit

Brutal, structured audit of a Terraform or OpenTofu module repository. Produces an 8-section critique with per-module letter grades, a concrete defect list, and an optional baseline diff.

## What it does

Detects design and composition flaws across a whole Terraform repo, not just per-module hygiene:

- **Cross-module composition smells** — overlap, duplication, thin wrappers, scope-discriminator primitives, copy-pasted module blocks, tier misplacement, compositions that overlap with primitives.
- **Cross-project / cross-account linking flaws** — missing `configuration_aliases`, modules that conflate scopes, opportunities for thin `links/` modules.
- **Per-module hygiene** — variable validation, output sensitivity, block ordering, `count`-vs-`for_each` misuse, dead code.
- **Provider-specific landing-zone gaps** — what a real GCP / AWS / Azure / OCI landing zone must contain that the repo is missing.
- **Repo-level gaps** — README, examples, tests, CI, bootstrap, lockfiles.

Each run can be diffed against a stored baseline at `<repo>/.terraform-audit/baseline.md`.

## Invocation

```
/terraform-audit:audit [path-to-repo]
```

If `[path-to-repo]` is omitted, the current working directory is audited.

The command file lives at `commands/audit.md`; the methodology + smells catalog + 8-section template live at `skills/terraform-audit/SKILL.md`. The skill auto-loads on natural-language triggers (`audit terraform`, `review terraform`, etc.) so you can also start the workflow from prose.

## Baseline diffs

If `<repo-path>/.terraform-audit/baseline.md` exists, the audit emits a `## 9. Diff vs baseline` section listing **Fixed**, **Regressed**, and **New** defects. After each run, the workflow asks (in plain text) whether to overwrite the baseline.

## Bundled `terraform-skill` (Apache-2.0, Anton Babenko)

The audit ships with Anton Babenko's `terraform-skill` v1.6.0 bundled at `skills/terraform-skill/`. It provides canonical Terraform best-practices guidance:

- Module hierarchy and file layout
- Variable / output / resource patterns
- Testing approaches (validate, plan, native test framework, Terratest)
- CI/CD workflow templates
- Security scanning (trivy, checkov)
- Quick reference cards

The bundled skill auto-loads on natural-language triggers (`creating terraform`, `terraform tests`, etc.) and is referenced by the audit workflow during Phase 2 (raw extraction subagent).

**License:** Apache-2.0. The license text is preserved at `skills/_terraform-skill-license/LICENSE-Apache-2.0`. The `terraform-skill` SKILL.md frontmatter retains author and version metadata. Source: https://github.com/antonbabenko/terraform-skill — `terraform-best-practices.com`.

## Layout

```
terraform-audit/
├── .claude-plugin/plugin.json
├── LICENSE                            # MIT (original content)
├── README.md
├── commands/
│   └── audit.md                       # /terraform-audit:audit -- workflow
└── skills/
    ├── terraform-audit/
    │   ├── SKILL.md                   # methodology + 8-section template + smells catalog
    │   └── references/
    │       ├── composition-analysis.md       # 7 cross-module smells + detection scripts
    │       ├── workflow.md                   # large repos, monorepo / multi-cloud, grading rubric, baseline-diff
    │       ├── landing-zone-checklists.md    # GCP / AWS / Azure / OCI / multi-cloud
    │       └── example-gcp-landing-zone.md   # worked example
    ├── terraform-skill/                # Apache-2.0, Anton Babenko, v1.6.0 -- bundled
    │   ├── SKILL.md
    │   ├── references/                 # 6 canonical references
    │   └── tests/                      # 3 test scenarios
    └── _terraform-skill-license/
        └── LICENSE-Apache-2.0
```

## License

The original audit content (this README, `commands/audit.md`, the `terraform-audit` skill, and its references) is **MIT** — see `LICENSE`.

The bundled `terraform-skill` content under `skills/terraform-skill/` is **Apache-2.0** by Anton Babenko — license preserved at `skills/_terraform-skill-license/LICENSE-Apache-2.0`. No modifications were made to the bundled content; it is a verbatim copy of `antonbabenko/terraform-skill` v1.6.0.
