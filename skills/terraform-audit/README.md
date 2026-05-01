# terraform-audit

Brutal, structured audit of a Terraform or OpenTofu module repository.

## What it does

Detects design and composition flaws across a whole Terraform repo, not just per-module hygiene:

- **Cross-module composition smells** — overlap, duplication, thin wrappers, scope-discriminator primitives, copy-pasted module blocks, tier misplacement, compositions that overlap with primitives.
- **Cross-project / cross-account linking flaws** — missing `configuration_aliases`, modules that conflate scopes, opportunities for thin `links/` modules.
- **Per-module hygiene** — variable validation, output sensitivity, block ordering, `count`-vs-`for_each` misuse, dead code.
- **Provider-specific landing-zone gaps** — what a real GCP / AWS / Azure / OCI landing zone must contain that the repo is missing.
- **Repo-level gaps** — README, examples, tests, CI, bootstrap, lockfiles.

Produces an 8-section critique with per-module letter grades and a numbered defect list. Each run can be diffed against a stored baseline.

## Invocation

```
/terraform-audit:terraform-audit [repo-path]
```

If `[repo-path]` is omitted, the current working directory is audited.

## Baseline diffs

If `<repo-path>/.terraform-audit/baseline.md` exists, the audit emits a `## 9. Diff vs baseline` section listing **Fixed**, **Regressed**, and **New** defects. After each run, the skill asks (in plain text) whether to overwrite the baseline.

## Optional dependency

If Anton Babenko's `terraform-skill` is installed as a personal skill at `~/.claude/skills/terraform-skill/`, the audit invokes it for canonical Terraform best-practices context. If absent, the bundled `references/terraform-best-practices-cheatsheet.md` is used instead — no functional loss.

## Layout

```
terraform-audit/
├── .claude-plugin/plugin.json
├── LICENSE
├── README.md
└── skills/terraform-audit/
    ├── SKILL.md
    └── references/
        ├── composition-analysis.md           # 7 cross-module smells + detection scripts
        ├── workflow.md                       # large repos, monorepo, multi-cloud, grading rubric
        ├── landing-zone-checklists.md        # GCP / AWS / Azure / OCI / multi-cloud
        ├── terraform-best-practices-cheatsheet.md
        └── example-gcp-landing-zone.md       # worked example showing expected output shape
```

## License

MIT — see `LICENSE`.
