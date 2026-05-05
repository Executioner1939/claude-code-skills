---
name: terraform-audit
description: This skill should be used when the user asks to "audit", "review", "critique", "tear apart", "harshly review", or "tech-debt audit" a Terraform or OpenTofu module repository, or when the user wants to compare a repo's current state against a prior baseline. Detects cross-module composition smells (overlap, duplication, thin wrappers, scope-discriminator primitives, copy-pasted module blocks, tier misplacement), cross-project / cross-account linking flaws, missing validations, dead code, version-pinning drift, hardcoded values that should be variables, and provider-specific landing-zone gaps (GCP, AWS, Azure, OCI). Produces an 8-section critique with per-module grades and a concrete defect list. Invoke directly with /terraform-audit:terraform-audit [repo-path].
arguments: [repo_path]
argument-hint: [path-to-repo]
allowed-tools: Read Glob Grep Write Skill Agent Bash(find *) Bash(ls *) Bash(wc *) Bash(test *) Bash(mkdir *) Bash(awk *) Bash(sed *) Bash(xargs *)
---

# Terraform module audit

Run a brutal, structured audit of a Terraform or OpenTofu module repository. The output must follow the 8-section structure documented below so each run can be diffed against prior runs.

## Inputs

- `$repo_path` — repository root. If empty, default to the current working directory. Quote the value in shell expansions to handle paths with spaces.
- If `$repo_path/.terraform-audit/baseline.md` exists, treat it as the prior audit and emit a Section 9 "Diff vs baseline".

## Step 0: Load best-practices context

Invoke the `terraform-skill` skill via the Skill tool to load Anton Babenko's canonical Terraform best-practices reference (Apache-2.0). It is a personal skill at `~/.claude/skills/terraform-skill/` and may not be installed everywhere.

If invocation fails, fall back to [`references/terraform-best-practices-cheatsheet.md`](references/terraform-best-practices-cheatsheet.md) and note the fallback once in the final report. Do not abort.

## Step 1: Map the repo

Run a fast structural pass without reading file contents:

```bash
find "$repo_path" -name '*.tf' -not -path '*/.terraform/*' | wc -l
find "$repo_path" -type d \( -name modules -o -name primitives -o -name composed \
  -o -name infrastructure -o -name links -o -name environments \
  -o -name examples -o -name tests \) -not -path '*/.terraform/*'
find "$repo_path" -maxdepth 4 -name 'versions.tf' -not -path '*/.terraform/*'
test -f "$repo_path/README.md" && echo README:yes || echo README:no
test -d "$repo_path/examples"   && echo examples:yes || echo examples:no
test -d "$repo_path/tests"      && echo tests:yes    || echo tests:no
ls -la "$repo_path/.github/workflows" 2>/dev/null
```

Record: module count by tier, presence of README/examples/tests/CI, and the cloud provider(s) declared in `versions.tf` (`hashicorp/google`, `hashicorp/aws`, `hashicorp/azurerm`, `oracle/oci`, etc.).

## Step 2: Delegate raw extraction to a subagent

The deep file read consumes context that synthesis needs. Delegate to a `general-purpose` subagent that produces **raw findings only**, not synthesis. The subagent's job is to read every `.tf` file under `modules/` and report concrete observations across these areas:

- Provider/version constraints across all modules — note inconsistencies, missing `required_providers` blocks, missing alpha/beta provider variants.
- Variable hygiene — missing `description`/`type`/`validation`, loose types (`any`, `map(any)`), missing `nullable = false` and `sensitive = true` where it would matter.
- Output hygiene — missing descriptions, unmarked sensitive outputs, raw resource attributes returned where structured objects would be clearer, outputs that echo inputs verbatim.
- Resource patterns — `count`-vs-`for_each` misuse (especially items keyed by name/string), block ordering (meta-args first), and duplicated logic that should be locals.
- Cross-project / cross-account modules — list every module that touches more than one project/account/subscription. For each, report whether `versions.tf` declares `configuration_aliases`, whether `provider = ...` is set on cross-scope resources, and whether remote IDs come in as strings or via `data` lookups.

**The subagent must not synthesize.** It must not produce per-module grades, a defect list, or composition-smell analysis — those are the main agent's job. Quote `file:line` references for every finding.

Pass the discovered repo path, module counts, and detected provider as parameters in the subagent prompt. Include `references/landing-zone-checklists.md` as required reading so the subagent knows which resources to look for.

## Step 3: Cross-module composition analysis

This is the highest-value phase. Read [`references/composition-analysis.md`](references/composition-analysis.md) for the full playbook — it documents seven cross-module smells, mechanical detection scripts, and the rubric for "opportunities" (patterns the repo could express but doesn't). Run the detection scripts before reading suspect files; they take seconds and surface most candidates.

For every smell instance found, produce: the modules involved with `file:line` refs, the diagnosis (why this is a smell), and the concrete fix (including `moved` blocks where renames affect public keys).

Conclude this step with an **Opportunities** subsection: linking modules to extract, shared validation modules, missing `examples/` that would double as `terraform test` fixtures, version drift in the lock file. A smell is something broken; an opportunity is something missing.

If no smells are found, say so explicitly and include the mechanical-detection output as proof. Be sceptical of "no smells found" on a non-trivial repo.

## Step 4: Cross-project / cross-account linking design

For every cross-scope module identified by the subagent in Step 2:

1. Confirm whether `versions.tf` declares `configuration_aliases`.
2. Confirm whether `main.tf` actually uses `provider = ...` on the cross-scope resources.
3. Determine whether the module takes remote IDs as **string inputs** (correct) or attempts to `data` them (couples to caller's auth).
4. Recommend whether to split into a thin `modules/links/<name>` linking module that takes producer-side and consumer-side IDs and only writes the IAM glue.

Conclude with a table of recommended `links/` modules for the detected provider. See [`references/landing-zone-checklists.md`](references/landing-zone-checklists.md) for provider-specific link patterns.

## Step 5: Synthesise the 8-section report

Match the section structure exactly. The example at [`references/example-gcp-landing-zone.md`](references/example-gcp-landing-zone.md) shows the expected shape against a real GCP landing-zone repo.

```
# Brutal review: <repo-name>

Repo state: <module count and tier breakdown>. <One-line state summary>.

## 1. Composition smell: overlap and duplication that proves the design is wrong
   (one subsection per smell, each with Diagnosis + Fix; cover all seven smell
    categories from composition-analysis.md, not just the loud ones; end with
    an Opportunities subsection)

## 2. The cross-project / cross-account linking problem
   (Step 4 findings + table of recommended link modules)

## 3. Per-module grades
   (markdown table: Module | Grade | Worst single issue. Grading rubric in
    references/workflow.md.)

## 4. Concrete defect list
   (numbered list, every defect with file:line)

## 5. Variable, output, and resource hygiene
   (per-module hygiene from Step 2 subagent findings)

## 6. Landing-zone gaps (entirely missing)
   (provider-specific — pull from references/landing-zone-checklists.md)

## 7. Repo-level gaps
   (README, examples/, tests/, CI, bootstrap, backend.tf, .tflint.hcl, etc.)

## 8. Recommended next-pass plan
   (numbered, ordered — each pass cleans the foundation for the next)
```

If a baseline exists at `$repo_path/.terraform-audit/baseline.md`, append `## 9. Diff vs baseline` with subsections **Fixed** (defects no longer present), **Regressed** (defects that returned), and **New** (defects that did not exist in baseline). The diff is computed by reading the baseline's Section 4 and re-checking each numbered defect — not via textual diff.

## Step 6: Save and offer to update baseline

Create the audit directory and save the report:

```bash
mkdir -p "$repo_path/.terraform-audit"
```

Save to `$repo_path/.terraform-audit/audit-$(date +%F).md` using the Write tool.

After saving, ask the user (in plain text) whether to overwrite `$repo_path/.terraform-audit/baseline.md` with this run. Do not overwrite without confirmation — the baseline is what future runs diff against.

## Failure modes

Handle these explicitly rather than assuming a happy path:

- **`$repo_path` does not exist or is not a directory** → report the error, ask the user to confirm the path, and stop.
- **Zero `.tf` files found** → state this directly; the audit cannot proceed without Terraform code. Suggest the user verify they pointed at the repo root.
- **Subagent (Step 2) returns an error or empty findings** → re-run once with a more constrained prompt (e.g. one tier at a time). If the second attempt also fails, fall back to reading files in the main agent and produce a slimmer report.
- **`terraform-skill` skill not installed** → use the bundled cheatsheet, mention the fallback once in the final report, continue.
- **Repo uses Terragrunt / Terramate / stack manifests** → see `references/workflow.md` for the monorepo flow; the default flow under-reports stack composition issues.
- **Repo declares multiple cloud providers** → audit each cloud separately and emit a Section 6 per cloud. The cross-cloud linking section becomes its own subsection.

## Audit-output style requirements

These rules apply to the **audit report produced by this skill**, not to this SKILL.md itself.

- Quote exact `file:line` references. Reviews without line numbers are useless.
- No emojis. No platitudes. No "overall this looks good" closer — list every defect.
- Every claim must be substantiated with a code reference.
- If a module is genuinely fine, give it an A and move on without padding.
- The audit is a document, not a conversation — keep second-person language out of the output.

## Reference files

- [`references/composition-analysis.md`](references/composition-analysis.md) — seven cross-module smells, mechanical detection scripts, opportunities rubric. **Read this every run before Step 3.**
- [`references/workflow.md`](references/workflow.md) — long-form playbook (large repos, monorepo / Terragrunt / Terramate, multi-cloud, grading rubric, baseline-diff handling, audit-vs-fix separation rule).
- [`references/landing-zone-checklists.md`](references/landing-zone-checklists.md) — per-provider list of what a landing zone must contain (GCP, AWS, Azure, OCI, multi-cloud).
- [`references/terraform-best-practices-cheatsheet.md`](references/terraform-best-practices-cheatsheet.md) — fallback when the `terraform-skill` skill is unavailable.
- [`references/example-gcp-landing-zone.md`](references/example-gcp-landing-zone.md) — worked example: a real GCP landing-zone audit showing the expected output shape.
