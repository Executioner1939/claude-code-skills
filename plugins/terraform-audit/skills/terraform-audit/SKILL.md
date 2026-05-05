---
name: terraform-audit
description: >
  Methodology and templates for brutal, structured Terraform / OpenTofu module
  audits. Auto-loaded by the /terraform-audit:audit slash command and on
  natural-language match. Provides the cross-module composition-smell catalog,
  the 8-section report template, the per-module grading rubric, the baseline-
  diff contract, and the per-provider landing-zone checklist references.
  Triggers on: audit terraform, review terraform, critique terraform, tear
  apart terraform, harshly review terraform, tech-debt audit terraform,
  baseline diff terraform, terraform module review, opentofu audit. The
  procedural workflow that drives this audit lives in the
  /terraform-audit:audit slash command -- read this skill alongside the
  command body; do not invoke this skill directly to run an audit.
---

# Terraform Audit -- Methodology Reference

This skill is **methodology and templates only**. Two audiences read it:

1. The `/terraform-audit:audit` slash command, which orchestrates the audit and references this skill for the smells catalog, output template, and discipline rules.
2. Claude when natural-language triggers match (`audit terraform`, etc.) -- the description above auto-loads the skill into context.

The bundled `terraform-skill` skill (Apache-2.0, Anton Babenko) at `${CLAUDE_PLUGIN_ROOT}/skills/terraform-skill/` provides canonical Terraform best-practices guidance and auto-loads alongside this skill on every audit run.

If you are a human trying to run an audit, run the slash command -- not this skill.

## Cross-module composition smells (catalog)

Seven categories. The full playbook with mechanical detection scripts lives at `${CLAUDE_PLUGIN_ROOT}/skills/terraform-audit/references/composition-analysis.md`.

| # | Smell | One-line signal |
|---|---|---|
| 1 | Overlap | Two modules wrapping the same primitive resource with different surface APIs |
| 2 | Duplication | Identical or near-identical module bodies under different names |
| 3 | Thin wrapper | A module that adds no value over the underlying provider resource |
| 4 | Scope-discriminator primitive | Primitive module that branches on environment / project / scope flags instead of being parameterised cleanly |
| 5 | Copy-pasted module blocks | Same `module "x"` block repeated across compositions instead of factored into a higher-level composition |
| 6 | Tier misplacement | Primitive that lives in the composed/ tier, or composed module masquerading as a primitive |
| 7 | Composition-overlaps-primitive | A composition that does what a primitive already does (with subtle drift) |

Plus an **Opportunities** subsection (not a smell): linking modules to extract, shared validation modules, missing `examples/` doubling as `terraform test` fixtures, version drift in the lock file.

## 8-section report template

Every audit produces a report in this exact shape. Sections 1-8 always present; Section 9 added when a baseline exists.

```
# Brutal review: <repo-name>

Repo state: <module count and tier breakdown>. <One-line state summary>.

## 1. Composition smell: overlap and duplication that proves the design is wrong
   (one subsection per smell, each with Diagnosis + Fix; cover all seven smell
    categories, not just the loud ones; end with an Opportunities subsection)

## 2. The cross-project / cross-account linking problem
   (cross-scope module findings + table of recommended link modules)

## 3. Per-module grades
   (markdown table: Module | Grade | Worst single issue. Grading rubric in
    references/workflow.md.)

## 4. Concrete defect list
   (numbered list, every defect with file:line)

## 5. Variable, output, and resource hygiene
   (per-module hygiene findings)

## 6. Landing-zone gaps (entirely missing)
   (provider-specific -- pull from references/landing-zone-checklists.md)

## 7. Repo-level gaps
   (README, examples/, tests/, CI, bootstrap, backend.tf, .tflint.hcl, etc.)

## 8. Recommended next-pass plan
   (numbered, ordered -- each pass cleans the foundation for the next)

## 9. Diff vs baseline   (when <repo>/.terraform-audit/baseline.md exists)
   ### Fixed     (defects no longer present)
   ### Regressed (defects that returned)
   ### New       (defects that did not exist in baseline)
```

The Section 9 diff is computed by reading the baseline's Section 4 and re-checking each numbered defect against the current state -- never via textual diff.

## Per-module grading rubric

Five-point letter scale. The full rubric (with weighting and example modules at each tier) is in `${CLAUDE_PLUGIN_ROOT}/skills/terraform-audit/references/workflow.md`.

| Grade | Meaning |
|---|---|
| A | Clean. Variables typed and validated, outputs descriptive, providers pinned, no smells. |
| B | Solid with cosmetic issues -- description gaps, minor block ordering, no missing validation. |
| C | Working but compromised -- some smells present, hygiene gaps that compound. |
| D | Broken composition or systemic hygiene loss. Not safe to extend without reshaping. |
| F | Misplaced tier, fundamental composition smell, or unsafe cross-scope handling. Refactor before reuse. |

If a module is genuinely fine, give it an A and move on without padding. Inflation makes the rubric useless.

## Audit-output discipline

These rules apply to the produced audit report, not to this skill:

- Quote exact `file:line` references. Reviews without line numbers are useless.
- No emojis. No platitudes. No "overall this looks good" closer -- list every defect.
- Every claim must be substantiated with a code reference.
- The audit is a document, not a conversation -- keep second-person language out of the output.
- "N/A -- [reason]" is preferred over silent omission of a section.

## Reference inventory

All references live at `${CLAUDE_PLUGIN_ROOT}/skills/terraform-audit/references/`. Read on demand.

| File | Purpose | When to load |
|---|---|---|
| `composition-analysis.md` | Seven smells, mechanical detection scripts, opportunities rubric | Phase 3 of every audit |
| `workflow.md` | Long-form playbook -- large repos, monorepo / Terragrunt / Terramate, multi-cloud, grading rubric, baseline-diff handling, audit-vs-fix separation rule | When the repo deviates from default shape (Terragrunt, multi-cloud, large) |
| `landing-zone-checklists.md` | Per-provider list of what a landing zone must contain (GCP, AWS, Azure, OCI, multi-cloud) | Phase 2 (pass to subagent) and Section 6 of report |
| `example-gcp-landing-zone.md` | Worked example -- a real GCP landing-zone audit showing the expected output shape | Reference for output style, particularly for first-time contributors |

## Bundled best-practices reference

The `${CLAUDE_PLUGIN_ROOT}/skills/terraform-skill/` skill (Apache-2.0, Anton Babenko, v1.6.0) provides:

- Module hierarchy and file layout conventions
- Variable, output, and resource patterns
- Testing approaches (validate, plan, native test framework, Terratest)
- CI/CD workflow templates
- Security scanning (trivy, checkov)
- Quick reference cards

Auto-loaded on every audit run via natural-language triggers in its description. Do not duplicate its content in audits -- cite it where guidance is being applied.

License preserved at `${CLAUDE_PLUGIN_ROOT}/skills/_terraform-skill-license/LICENSE-Apache-2.0`.
