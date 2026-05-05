# Audit workflow — long form

Loaded only when the default flow doesn't fit (multi-cloud repos, monorepos, very large module counts, mixed Terraform/OpenTofu).

## When to deviate from the SKILL.md default flow

### Very large repos (>50 modules)

The single-subagent deep dive will run out of useful output. Split it:

1. First subagent: read every `versions.tf`, every `variables.tf`, every `outputs.tf`. Reports on hygiene + version constraints + output contracts. Cheap, structured.
2. Second subagent: read every `main.tf`. Reports on resource patterns + composition smells. Expensive.
3. Third subagent: read only composed/infrastructure modules. Reports on whether composition is real or fake.

Synthesise across the three reports yourself.

### Multi-cloud repos

If `versions.tf` declares more than one cloud provider (e.g. both `hashicorp/aws` and `hashicorp/google`), do **not** treat it as one repo. Audit each cloud separately and emit a Section 6 ("landing-zone gaps") per cloud. The cross-project section becomes "cross-cloud linking" — usually missing entirely.

### Monorepo layout (Terragrunt / Terramate / scalr / spacelift stacks)

Look for `terragrunt.hcl`, `terramate.tm.hcl`, or stack manifests. The audit shifts from "module quality" to "stack composition":

- Are there `_envcommon` / shared inputs files? Are they consistent?
- Do environments (dev/staging/prod) actually differ in inputs, or are they copy-pasted?
- Is state isolated per stack, or do they share a backend prefix?
- Is dependency-passing done via remote state (fragile) or explicit dependency blocks?

Add a **Stack composition** section between sections 1 and 2 of the report.

### OpenTofu vs Terraform

Both use the same skill. Differences to flag:

- `required_version` may use either tool. If `~> 1.6` and the workflow uses `tofu` (check CI), call out OpenTofu specifically.
- OpenTofu 1.7+ has `state encryption` — flag missing config in state-sensitive contexts.
- OpenTofu 1.8+ has provider-defined functions — flag if the repo uses HashiCorp providers exclusively despite using `tofu`.

## How to detect provider

```bash
grep -rh '^\s*source\s*=\s*"' --include='versions.tf' $REPO/modules \
  | sed -E 's/.*"([^"]+)".*/\1/' | sort -u
```

Expected matches:
- `hashicorp/google`, `hashicorp/google-beta` → GCP
- `hashicorp/aws` → AWS
- `hashicorp/azurerm`, `hashicorp/azuread` → Azure
- `oracle/oci` → OCI
- `hashicorp/kubernetes`, `hashicorp/helm` → K8s (often paired with cloud)
- `cloudflare/cloudflare` → Cloudflare
- `digitalocean/digitalocean` → DO

## How to detect "fake" composition

A composed module is **fake** if any of these hold:

1. It declares zero `module "..."` blocks (it's a flat primitive in the wrong tier).
2. It declares one `module "..."` block plus 1-2 trivial resources (it's a thin wrapper).
3. It has variables that are unused inside `main.tf` (`grep -c 'var.<name>' main.tf == 0`).
4. It has outputs that echo inputs verbatim (`output "x" { value = var.x }`).
5. Multiple consecutive `module "..."` blocks differ only in the value of one variable (should be `for_each` over a map).

Fake compositions are the highest-priority refactor — they actively mislead callers about what the module does.

## How to write the per-module grade table

Grades are not vibes. Use this rubric:

| Grade | Meaning |
|---|---|
| **A** | Variables validated; outputs structured + descriptions; no hardcoded values; correct provider aliases for cross-scope; no dead code; uses for_each where keys exist; ready to publish. |
| **A-** | A with one minor issue (e.g. one missing `nullable = false`). |
| **B** | Generally well-shaped, but missing 2-3 hygiene items (validations, sensitive flags, structured outputs). No bugs. |
| **B-** | B with one hardcoded-value-that-should-be-a-variable. |
| **C** | Bug present (silent footgun, fragile expression, wrong default), or significant hygiene gap, or naming collision. Will produce confusing user errors. |
| **D** | Module is misnamed, unused, or fundamentally broken (doesn't do what its name says). Cross-scope module without provider aliases lands here. |
| **F** | Module will not apply, or apply will leave the system in a worse state than before. Rare; reserve for genuinely dangerous code. |

Always state the **single worst issue** in the table — not a list. The defect list (Section 4) holds everything else.

## How to handle the baseline

The baseline lives at `<repo>/.terraform-audit/baseline.md`. The diff is computed by you, not by `git diff` — defects move around (line numbers shift) so a textual diff is noisy. Instead:

1. Read the baseline's Section 4 (concrete defect list).
2. For each numbered defect, check whether it still exists in the current repo. If the file/symbol was renamed, follow the rename.
3. Emit `## 9. Diff vs baseline` with subsections **Fixed**, **Regressed**, and **New**.

Do not silently update the baseline. Always confirm.

## What to do if the user says "fix what you found"

Stop. The audit skill produces findings; it does not apply fixes. Tell the user:

> The audit is complete. To apply fixes, ask me to start on a specific section
> (e.g. "fix the dead variables in section 4" or "do pass 1 of the next-pass plan").
> One pass at a time keeps blast radius small.

This is the rule: audit and fix are separate sessions. A single session that does both will skip findings to make the diff smaller.
