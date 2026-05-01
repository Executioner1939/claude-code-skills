---
name: terraform-audit
description: Run a brutal, structured audit of a Terraform or OpenTofu module repository. Detects composition smells (overlap and duplication that prove the design is wrong), cross-project / cross-account linking flaws, missing validations, dead code, version-pinning drift, hardcoded values that should be variables, and provider-specific landing-zone gaps (GCP / AWS / Azure / OCI). Produces an 8-section critique with per-module grades and a concrete defect list. Use when reviewing a Terraform repo, when the user asks for a "harsh review" / "tear apart" / "critique" / "tech-debt audit" of IaC, or when the user wants to compare current repo state against a prior baseline. Invoke directly with /terraform-audit:terraform-audit [path].
argument-hint: [path-to-repo]
allowed-tools: Bash(find *) Bash(ls *) Bash(wc *) Bash(grep *) Bash(test *) Read Glob Grep Skill Agent
disable-model-invocation: false
---

# Terraform module audit

You are running a brutal, structured audit of a Terraform / OpenTofu module repository. Your output must match the format of `references/example-gcp-landing-zone.md` so it can be diffed against prior runs.

## Inputs

- `$1` — repo path. If empty, default to the current working directory.
- If a baseline file exists at `$1/.terraform-audit/baseline.md`, treat it as the prior audit and call out **what changed since baseline** in a final section.

## Step 0: Reference the Terraform best-practices skill

Before reading any code, invoke the `terraform-skill` skill (Apache-2.0, by Anton Babenko) to load the canonical best-practices reference. It is a *personal* skill (`~/.claude/skills/terraform-skill/`) and is not bundled here, so it may not be installed everywhere. If unavailable, fall back to the inline cheat-sheet in `references/terraform-best-practices-cheatsheet.md`.

```
Skill(skill: "terraform-skill")
```

If the skill is missing, say so once in your final report and continue using the cheat-sheet — do not abort.

## Step 1: Map the repo

Run a small, fast pass to discover structure. Do not read file contents yet. Use Bash:

```
find $1 -name '*.tf' -not -path '*/.terraform/*' | wc -l
find $1 -type d \( -name modules -o -name primitives -o -name composed -o -name infrastructure -o -name links -o -name environments -o -name examples -o -name tests \) -not -path '*/.terraform/*'
find $1 -maxdepth 4 -name 'versions.tf' -not -path '*/.terraform/*'
test -f $1/README.md && echo "README:yes" || echo "README:no"
test -d $1/examples && echo "examples:yes" || echo "examples:no"
test -d $1/tests && echo "tests:yes" || echo "tests:no"
ls -la $1/.github/workflows 2>/dev/null
```

From that output, write down:
- module count (primitives, composed/infrastructure, links, environments)
- whether README / examples / tests / CI exist
- which cloud provider(s) are in use (look at `versions.tf` `required_providers` — `hashicorp/google`, `hashicorp/aws`, `hashicorp/azurerm`, `oracle/oci`, etc.)

## Step 2: Delegate the deep dive to a subagent

The deep file read is the expensive part. Hand it to a `general-purpose` subagent with this exact prompt template (adjust the bracketed parts for the actual repo). **Do not summarise — pass through the subagent's findings verbatim.**

```
Read every .tf file under <REPO_PATH>/modules/ — there are <N> modules
(<P> primitives, <C> composed). Each module has main.tf, variables.tf,
outputs.tf, versions.tf.

I'm doing a hard review of this repo as a <PROVIDER> <PURPOSE>. I need
you to extract concrete findings. Report back with:

1. Provider/version constraints across all modules — list any
   inconsistencies. Are they pinning major or minor? Is there a
   required_providers block in every versions.tf? Are alpha/beta provider
   variants declared where needed?

2. Variable hygiene — note modules where variables lack description, type,
   or validation. Note overly loose types like any or map(any). Note
   missing nullable = false / sensitive = true where it would matter.

3. Output hygiene — note modules where outputs lack descriptions, where
   sensitive outputs aren't marked, where outputs return raw resource
   attributes instead of structured objects.

4. Resource patterns — note misuse of count vs for_each (especially for
   things keyed by name/string that should be for_each), use of "this"
   naming, block ordering (count/for_each first, tags, lifecycle), and
   duplicated logic that should be locals.

5. Cross-project / cross-account linking — any module that connects two
   accounts/projects/subscriptions. Are they properly designed for
   cross-scope use? Do they accept remote IDs as inputs cleanly? Do they
   declare provider configuration_aliases?

6. Provider-specific landing-zone gaps — for the detected provider
   (<PROVIDER>), what's MISSING that you'd expect in a landing zone? See
   references/landing-zone-checklists.md for the per-provider list.

7. Composed module quality — read each composed module carefully. Are
   they thin wrappers, or do they actually compose multiple primitives
   meaningfully? Do they leak primitive abstraction? Do they pass
   tags/labels through? Are any composed modules just renamed
   primitives?

8. Repo-level gaps — README, examples/, tests/, environments/,
   bootstrap, CI workflow, backend.tf template, .tflint.hcl,
   pre-commit, terraform-docs config, CODEOWNERS, LICENSE.

For each module, give it a one-line grade (A/B/C/D/F) with the worst
issue. Be brutal but specific — quote line numbers and exact
variable/resource names. List every concrete defect — dead code, unused
variables, hardcoded values that should be variables, fragile
expressions like coalesce(try(...)). Write up to 1500 words. Don't
summarize at the end with "overall this looks good". Don't omit
findings to be polite.
```

Use the `Agent` tool with `subagent_type: general-purpose`. Do not run the deep dive in your own context — it consumes tokens you need for synthesis.

## Step 3: Cross-module composition analysis (the highest-value phase)

This step is about reading **the whole module set as one design**, not auditing modules one at a time. Per-module hygiene goes in Section 5; this section is for smells that only appear when modules are compared against each other.

Read [`references/composition-analysis.md`](references/composition-analysis.md) for the full playbook. Run the mechanical detection scripts in that file first (they take seconds and surface most candidates), then read the suspect files to confirm.

The seven cross-module smells you must screen for:

1. **Two modules doing the same thing at different scopes** (duplication points at a missing primitive).
2. **Thin-wrapper compositions** that add nothing over a single primitive call.
3. **Discriminator-variable primitives** that flip between scopes via `count` (three primitives wearing a trench coat).
4. **N nearly-identical module blocks** instead of `for_each` over a map.
5. **Inlined resources in compositions** that should be primitives.
6. **Compositions that overlap with what their primitive callers already do**, forcing callers to use both.
7. **Tier misplacement** — composed-as-primitive or primitive-as-composed.

For every instance found:
- Quote the modules involved with `file:line` refs.
- State the **diagnosis** (why this is a smell, not just a stylistic complaint).
- State the **fix** (concrete refactor, including `moved` blocks where renames affect public keys).

Then add an **Opportunities** subsection: patterns the repo could express but doesn't. A smell is something broken; an opportunity is something missing. Examples: linking modules to extract, shared validation modules, missing `examples/` that would double as `terraform test` fixtures, version drift in the lock file. See `composition-analysis.md` § "The opportunities output" for the rubric.

This is the section the user cares about most. Do not shortcut it. If you find no smells, say so explicitly with the mechanical-detection output as proof — but be very sceptical of "no smells found" on a non-trivial repo.

## Step 4: Audit cross-project / cross-account linking specifically

The user cares deeply about this. For every module that touches more than one project / account / subscription, check:

1. Does `versions.tf` declare `configuration_aliases`?
2. Does `main.tf` actually use `provider = ...` on the cross-scope resources?
3. Does the module take remote IDs as **string inputs** (correct) or attempt to `data` them (couples to caller's auth)?
4. Could it be split into a thin "linking module" that takes producer-side and consumer-side IDs and only writes the IAM glue?

Recommend a `modules/links/` tier with one tiny module per cross-scope relationship. Give a table of suggested link modules for the detected provider.

## Step 5: Synthesise the report

Output structure (match `references/example-gcp-landing-zone.md` byte-for-byte except for content):

```
# Brutal review: <repo-name>

Repo state: <module count and tier breakdown>. <One-line state summary
e.g. "Zero README, zero examples, zero tests" if applicable>.

## 1. Composition smell: overlap and duplication that proves the design is wrong
   (subsections A, B, C, ... — one per smell, each with Diagnosis + Fix.
    Cover ALL seven smell categories from composition-analysis.md, not just
    the ones that happen to be visually loud. End with an "Opportunities"
    subsection listing patterns the repo could express but doesn't.)

## 2. The cross-project / cross-account linking problem
   (table of recommended link modules)

## 3. Per-module grades
   (markdown table: Module | Grade | Worst single issue)

## 4. Concrete defect list
   (numbered list, every defect with file:line)

## 5. Variable, output, and resource hygiene

## 6. Landing-zone gaps (entirely missing)
   (provider-specific — pull from references/landing-zone-checklists.md)

## 7. Repo-level gaps

## 8. Recommended next-pass plan
   (numbered, ordered — each pass cleans the foundation for the next)
```

If a baseline exists, append a `## 9. Diff vs baseline` section listing **fixed** defects (great) and **regressions** (defects that returned).

## Step 6: Save the audit and update baseline

Save the full report to `$1/.terraform-audit/audit-<YYYY-MM-DD>.md`. Then ask the user whether to overwrite `$1/.terraform-audit/baseline.md` with the new audit. Do not overwrite without confirmation — the baseline is what future runs diff against.

## Style requirements

- Quote exact `file:line` references. Reviews without line numbers are useless.
- No emojis. No platitudes. Don't end with "overall this looks good" — list every defect.
- "Brutal but specific" — every claim must be substantiated with a code reference.
- If a module is genuinely fine, give it an A and move on; don't pad.
- Use the second-person sparingly. The audit is a document, not a conversation.

## Reference files

- [`references/composition-analysis.md`](references/composition-analysis.md) — the seven cross-module smells, mechanical detection scripts, and the rubric for opportunities. **Read this every run.**
- [`references/workflow.md`](references/workflow.md) — long-form playbook (when to deviate from the default flow, how to handle multi-cloud repos, how to handle monorepo layouts).
- [`references/landing-zone-checklists.md`](references/landing-zone-checklists.md) — per-provider list of what a real landing zone must contain (GCP, AWS, Azure, OCI).
- [`references/terraform-best-practices-cheatsheet.md`](references/terraform-best-practices-cheatsheet.md) — fallback for when the `terraform-skill` skill is not installed.
- [`references/example-gcp-landing-zone.md`](references/example-gcp-landing-zone.md) — the seed audit (a real GCP landing-zone repo) showing the exact output format expected.
