---
description: Run a brutal, structured audit of a Terraform or OpenTofu module repository. Detects cross-module composition smells (overlap, duplication, thin wrappers, scope-discriminator primitives, copy-pasted module blocks, tier misplacement), cross-project / cross-account linking flaws, missing validations, dead code, version-pinning drift, hardcoded values that should be variables, and provider-specific landing-zone gaps (GCP / AWS / Azure / OCI / multi-cloud). Produces an 8-section critique with per-module letter grades and a numbered defect list. Diffs against a stored baseline if one exists. Use when the user wants a tear-down audit of an IaC repo, a compliance review, due-diligence on inherited Terraform, or a baseline-vs-now comparison.
argument-hint: "[path-to-repo]"
disable-model-invocation: true
allowed-tools:
  - Read
  - Glob
  - Grep
  - Write
  - Bash(mkdir:*)
  - Bash(date:*)
  - Bash(pwd)
  - Bash(test:*)
  - Bash(ls:*)
  - Bash(echo:*)
  - Bash(find:*)
  - Bash(wc:*)
  - Bash(awk:*)
  - Bash(sed:*)
  - Bash(grep:*)
  - Bash(xargs:*)
  - Bash(basename:*)
  - Bash(dirname:*)
  - Bash(head:*)
  - Bash(tr:*)
  - Bash(cut:*)
  - Agent(general-purpose)
model: claude-opus-4-7
---

# Terraform module audit

You are running a brutal, structured audit. The output must follow the 8-section structure documented in the `terraform-audit` skill so each run can be diffed against prior runs.

The `terraform-audit` skill (loaded via your context) holds the smells catalog, output template, and discipline rules. The bundled `terraform-skill` skill (Anton Babenko, Apache-2.0) holds canonical Terraform best-practices guidance — auto-loaded on natural-language match. Do not re-derive their content here.

## Bootstrap

```!
set -e

REPO_PATH=$(printf '%s' "$ARGUMENTS" | awk '{print $1}')
[ -z "$REPO_PATH" ] && REPO_PATH="$(pwd)"
test -d "$REPO_PATH" || { echo "ABORT: path is not a directory: $REPO_PATH"; exit 0; }

TF_COUNT=$(find "$REPO_PATH" -name '*.tf' -not -path '*/.terraform/*' 2>/dev/null | wc -l | tr -d ' ')
[ "$TF_COUNT" = "0" ] && { echo "ABORT: zero .tf files under $REPO_PATH -- audit cannot proceed. Verify the path is a Terraform repo root."; exit 0; }

AUDIT_DIR="$REPO_PATH/.terraform-audit"
TODAY=$(date +%F)
BASELINE_PATH="$AUDIT_DIR/baseline.md"
REPORT_PATH="$AUDIT_DIR/audit-$TODAY.md"
mkdir -p "$AUDIT_DIR"

if test -f "$BASELINE_PATH"; then
  HAS_BASELINE=1
else
  HAS_BASELINE=0
fi

cat <<EOF
BOOTSTRAP_OK=1
REPO_PATH=$REPO_PATH
TF_COUNT=$TF_COUNT
AUDIT_DIR=$AUDIT_DIR
BASELINE_PATH=$BASELINE_PATH
REPORT_PATH=$REPORT_PATH
HAS_BASELINE=$HAS_BASELINE
TODAY=$TODAY
EOF
```

If the bootstrap output begins with `ABORT:`, halt and print the message verbatim.

If `BOOTSTRAP_OK=1`, capture the variables (`REPO_PATH`, `TF_COUNT`, `BASELINE_PATH`, `REPORT_PATH`, `HAS_BASELINE`, `TODAY`) as **literal values** for use below. Use them as absolute strings in every Bash and Task call.

## Phase 1 -- Map the repo

Run a fast structural pass without reading file contents (use the Bash tool):

```
find <REPO_PATH> -name '*.tf' -not -path '*/.terraform/*' | wc -l
find <REPO_PATH> -type d \( -name modules -o -name primitives -o -name composed -o -name infrastructure -o -name links -o -name environments -o -name examples -o -name tests \) -not -path '*/.terraform/*'
find <REPO_PATH> -maxdepth 4 -name 'versions.tf' -not -path '*/.terraform/*' -exec grep -l 'hashicorp/google\|hashicorp/aws\|hashicorp/azurerm\|oracle/oci' {} \;
test -f <REPO_PATH>/README.md && echo "README:yes" || echo "README:no"
test -d <REPO_PATH>/examples && echo "examples:yes" || echo "examples:no"
test -d <REPO_PATH>/tests && echo "tests:yes" || echo "tests:no"
ls -la <REPO_PATH>/.github/workflows 2>/dev/null
```

Record (in your scratch context, NOT in the report yet):

- module count by tier (primitives / composed / links / environments)
- presence of README / examples/ / tests/ / .github/workflows/
- detected cloud provider(s) from versions.tf

## Phase 2 -- Delegate raw extraction to a subagent

Deep file-reading consumes context that synthesis needs. Dispatch a `general-purpose` subagent for raw findings only. Pass this prompt verbatim, substituting the literal `REPO_PATH` and the providers you detected:

```
## goal
Produce a raw, structured catalog of observable hygiene issues across every .tf file under modules/ in <REPO_PATH>. NO synthesis -- no per-module grades, no defect list, no composition-smell analysis.

## inputs
- repo_path: { type: path, value: <REPO_PATH> }
- providers_detected: { type: list<string>, value: [<list>] }

## context
- path: ${CLAUDE_PLUGIN_ROOT}/skills/terraform-audit/references/landing-zone-checklists.md
  why: tells you which provider-specific resources to look for
  do_not_re_derive: true
- path: ${CLAUDE_PLUGIN_ROOT}/skills/terraform-skill/SKILL.md
  why: canonical Terraform best-practices reference (Apache-2.0, Anton Babenko)
  do_not_re_derive: true

## constraints
must:
  - quote file:line for every observation
  - cover provider/version constraints across all modules
  - cover variable hygiene (description, type, validation, nullable, sensitive, loose types like any / map(any))
  - cover output hygiene (description, sensitive, returned shape)
  - cover resource patterns (count vs for_each misuse, block ordering, locals candidates)
  - cover cross-project / cross-account modules: list every module that touches >1 project/account, report whether versions.tf declares configuration_aliases, whether provider = ... is set, whether remote IDs come in as strings
must_not:
  - synthesize grades, defects, smells, or composition analysis -- raw observations only
  - read files outside <REPO_PATH>/modules/

## out_of_scope
- writing files
- recommending fixes
- ordering observations by severity

## acceptance
- output is a structured list of observations grouped by area (provider/version | variable hygiene | output hygiene | resource patterns | cross-scope modules)
- every observation cites file:line
- list of cross-scope modules is exhaustive (every module with >1 provider alias)

## output_format
markdown sections:
  - "Provider / version constraints"
  - "Variable hygiene"
  - "Output hygiene"
  - "Resource patterns"
  - "Cross-scope modules"
```

Wait for the subagent to return. Capture its output in your context for synthesis. If the subagent fails or returns empty, retry once with a narrower scope (one tier at a time). If the second attempt fails, fall back to reading files directly in your own turn -- produce a slimmer report and note the fallback.

## Phase 3 -- Cross-module composition analysis

This is the highest-value phase. Read the smells playbook on demand (use the Read tool):

```
${CLAUDE_PLUGIN_ROOT}/skills/terraform-audit/references/composition-analysis.md
```

Run the mechanical detection scripts documented in that reference BEFORE reading suspect files. They take seconds and surface most candidates.

For every smell instance found, record (for the report):

- modules involved with `file:line` references
- diagnosis (why this is a smell, citing the catalog name)
- concrete fix (including `moved` blocks where renames affect public keys)

End the phase with an **Opportunities** subsection: linking modules to extract, shared validation modules, missing `examples/` that would double as `terraform test` fixtures, version drift in the lock file. A smell is something broken; an opportunity is something missing.

If no smells are found, say so explicitly and include the mechanical-detection output as proof. Be sceptical of "no smells found" on a non-trivial repo.

## Phase 4 -- Cross-project / cross-account linking design

For every cross-scope module the Phase-2 subagent flagged:

1. Confirm whether `versions.tf` declares `configuration_aliases`.
2. Confirm whether `main.tf` actually uses `provider = ...` on the cross-scope resources.
3. Determine whether the module takes remote IDs as **string inputs** (correct) or attempts to `data` them (couples to caller's auth).
4. Recommend whether to split into a thin `modules/links/<name>` linking module that takes producer-side and consumer-side IDs and only writes the IAM glue.

Conclude with a table of recommended `links/` modules for the detected provider. Read provider-specific link patterns from:

```
${CLAUDE_PLUGIN_ROOT}/skills/terraform-audit/references/landing-zone-checklists.md
```

## Phase 5 -- Synthesize the 8-section report

Match the template in the `terraform-audit` skill exactly. The worked example at `${CLAUDE_PLUGIN_ROOT}/skills/terraform-audit/references/example-gcp-landing-zone.md` shows the expected output shape against a real GCP landing-zone repo.

Section structure:

```
# Brutal review: <repo-name>

Repo state: <module count and tier breakdown>. <One-line state summary>.

## 1. Composition smell: overlap and duplication that proves the design is wrong
   (one subsection per smell from Phase 3, each with Diagnosis + Fix; cover all
    seven smell categories from composition-analysis.md, not just the loud ones;
    end with an Opportunities subsection)

## 2. The cross-project / cross-account linking problem
   (Phase 4 findings + table of recommended link modules)

## 3. Per-module grades
   (markdown table: Module | Grade | Worst single issue.
    Grading rubric in references/workflow.md.)

## 4. Concrete defect list
   (numbered list, every defect with file:line)

## 5. Variable, output, and resource hygiene
   (per-module hygiene from Phase 2 subagent findings)

## 6. Landing-zone gaps (entirely missing)
   (provider-specific -- pull from landing-zone-checklists.md)

## 7. Repo-level gaps
   (README, examples/, tests/, CI, bootstrap, backend.tf, .tflint.hcl, etc.)

## 8. Recommended next-pass plan
   (numbered, ordered -- each pass cleans the foundation for the next)
```

If `HAS_BASELINE=1`, append `## 9. Diff vs baseline` with three subsections:

- **Fixed** — defects no longer present
- **Regressed** — defects that returned
- **New** — defects that did not exist in baseline

The diff is computed by reading the baseline's Section 4 and re-checking each numbered defect against the current state -- not via textual diff. Read the baseline:

```
Read: <BASELINE_PATH>
```

## Phase 6 -- Save and offer to update baseline

Use the Write tool to save the report to `<REPORT_PATH>`.

Then ask the user (in plain text) whether to overwrite `<BASELINE_PATH>` with this run. Do not overwrite without explicit confirmation -- the baseline is what future runs diff against.

If the user confirms: copy `<REPORT_PATH>` to `<BASELINE_PATH>` (use the Read tool to read the report, then Write tool to write the baseline). Print confirmation.

## Audit-output style requirements

These rules apply to the audit report you produce, not to this command body:

- Quote exact `file:line` references. Reviews without line numbers are useless.
- No emojis. No platitudes. No "overall this looks good" closer -- list every defect.
- Every claim must be substantiated with a code reference.
- If a module is genuinely fine, give it an A and move on without padding.
- The audit is a document, not a conversation -- keep second-person language out of the output.

## Failure modes

Handle each explicitly rather than assuming a happy path:

- **path is not a directory** → bootstrap aborts with the error.
- **zero .tf files** → bootstrap aborts. Audit cannot proceed. Suggest the user verify they pointed at the repo root.
- **Phase-2 subagent returns empty / errors** → retry once with constrained scope (one tier at a time). If retry fails, fall back to direct file reads in your own turn and produce a slimmer report. Note the fallback in the report.
- **Repo uses Terragrunt / Terramate / stack manifests** → see `references/workflow.md` for the monorepo flow; the default flow under-reports stack composition issues.
- **Repo declares multiple cloud providers** → audit each cloud separately and emit a Section 6 per cloud. The cross-cloud linking section becomes its own subsection.

## Whole-workflow constraints

- Read-only on the repo's source files (.tf etc.). Write only to `<AUDIT_DIR>/`.
- The bundled `terraform-skill` (Apache-2.0, Anton Babenko) is auto-loaded by Claude when relevant; do not duplicate its content in the report.
- Do not commit, push, or modify anything outside `<AUDIT_DIR>/`.
- One report per run.

## Acceptance for the whole run

- `<REPORT_PATH>` exists with all 8 sections (and Section 9 if `HAS_BASELINE=1`).
- Every defect in Section 4 cites file:line.
- Per-module grades in Section 3 cover every module under `<REPO_PATH>/modules/`.
- The user has been asked about baseline overwrite (and the answer respected).
