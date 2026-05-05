# Cross-module composition analysis

The single highest-value part of the audit. Most reviewers stop at per-module hygiene. You must go further: read **the whole module set as one design**, and find the smells that only appear when you compare modules to each other.

## The seven cross-module smells

Look for each of these explicitly. Every instance must be reported with the modules involved and a recommended fix.

### 1. Two modules that do the same thing at different scopes

Example: `modules/firewall-vpc-rule` (a primitive) **and** `modules/composed/network-baseline/main.tf:31-67` which inlines a `google_compute_firewall` resource. Both produce the same kind of resource; one is reusable, one is buried.

**Diagnosis**: the inlined resource is a missing primitive. Whoever wrote the composition didn't see the existing primitive, or the primitive came later. Either way, the composition is now lying about what it does.

**Fix**: extract the inlined resource into the existing primitive (or create one) and have the composition call it.

### 2. A composed module that is a thin wrapper around one primitive

Example: `composed/secrets-infra` calls `primitives/kms-keyring` and adds 5 lines of IAM. It declares `var.labels` that's never used and an output that echoes `var.project_id`.

**Diagnosis**: the composition adds nothing. Callers who use it are paying for a layer of indirection with zero benefit. Worse, the *name* of the composition lies — `secrets-infra` doesn't create any secrets.

**Fix**: delete the composition. If the IAM glue is genuinely shared, move it into the primitive as an optional block. If the composition's name describes a real concept (secrets infrastructure), implement that concept — actually create `secret_manager_secret` resources, factory pattern, KMS binding.

### 3. A primitive with a discriminator variable that flips between scopes

Example: `primitives/log-sink` with `var.sink_level = "org" | "folder" | "project"` and three `count`-gated `google_logging_*_sink` resources. The `outputs.tf` does `coalesce(try(...))` to pick the right writer identity.

**Diagnosis**: this is three primitives wearing a trench coat. The discriminator forces every consumer to know about scopes they don't use. The fragile `coalesce(try(...))` output proves the abstraction is wrong.

**Fix**: split into three primitives (`log-sink-org`, `log-sink-folder`, `log-sink-project`). They share zero variables apart from `name` and `destination`. Don't unify what isn't unified.

### 4. N nearly-identical module blocks instead of `for_each` over a map

Example: `composed/security-baseline/main.tf` instantiates `module "policy_X" { source = "../../primitives/org-policy" ... }` ten times with copy-pasted variables. Adding a constraint = 10 new lines + a variable + an output.

**Diagnosis**: this is the loudest "your composition is wrong" signal in any Terraform repo. Copy-paste at the composition layer means you've conflated configuration with code.

**Fix**:
```hcl
locals {
  policies = {
    domain_restricted_sharing = { constraint = "iam.allowedPolicyMemberDomains", values = {...} }
    disable_sa_keys           = { constraint = "iam.disableServiceAccountKeyCreation", enforce = "TRUE" }
    # ...
  }
}

module "policies" {
  for_each = { for k, v in local.policies : k => v if try(var.enabled[k], true) }
  source   = "../../primitives/org-policy"
  rule     = each.value
}
```

Adding a constraint becomes one map entry.

### 5. Inlined resources in compositions that should be primitives

Example: `composed/environment-network/main.tf:31-67` declares `google_compute_firewall` directly. If a different composition ever needs the same firewall pattern, it has to duplicate the block.

**Diagnosis**: compositions should compose. The moment a resource is needed in two compositions, it must be a primitive.

**Fix**: extract every inlined resource that has any chance of reuse. Only leave inline what is genuinely one-off (e.g. the wiring between two specific other primitives).

### 6. A composition that overlaps with what its primitive callers already do

Example: `composed/organization-hierarchy` creates folders + a "shared project" per BU. But the project options are limited (no budget, no default-SA removal, no IAM). Real callers end up using `organization-hierarchy` **and** `primitives/project` together.

**Diagnosis**: the composition isn't pulling its weight. Callers always reach past it. The composition has become a partial implementation of what it should fully own.

**Fix**: take a richer input map (`projects = map({ budget, host, iam, apis, ... })`) so the composition is the project factory. Or split: one composition owns folders, another owns projects. Don't ship a half-version.

### 7. Tier misplacement — composed-as-primitive or primitive-as-composed

Example: `composed/monitoring-baseline` has zero `module "..."` blocks. It directly creates `google_monitoring_notification_channel` and `_uptime_check_config`. It is a primitive, mislabeled.

Inverse: `primitives/something-baseline` that calls three other primitives and wires them together. That's a composition wearing the primitive label.

**Diagnosis**: the tier name lies. Future readers cannot trust the directory layout.

**Fix**: move the file. Keep the public name stable via `moved` blocks if it's already in use. **Do not rename the public module key without a `moved` block** — that's a destroy/recreate.

## How to detect each smell mechanically

Use these as a first pass; confirm with file reads.

```bash
# Smell 7a: composed modules with zero `module` blocks (fake compositions)
for d in $REPO/modules/composed/*/; do
  count=$(grep -c '^module ' $d/main.tf 2>/dev/null || echo 0)
  echo "$d  modules=$count"
done | awk '$2 == "modules=0"'

# Smell 2: thin wrappers (composed with exactly 1 module block)
for d in $REPO/modules/composed/*/; do
  count=$(grep -c '^module ' $d/main.tf 2>/dev/null || echo 0)
  echo "$d  modules=$count"
done | awk '$2 == "modules=1"'

# Smell 4: composed modules with >3 module blocks pointing to the same source
for d in $REPO/modules/composed/*/; do
  awk '/^module / { in_block=1 } in_block && /source\s*=/ { print FILENAME":"$0; in_block=0 }' $d/main.tf 2>/dev/null \
    | sed -E 's/.*source\s*=\s*"([^"]+)".*/\1/' | sort | uniq -c | awk '$1 > 3'
done

# Smell 5: inlined resources in composed modules
for d in $REPO/modules/composed/*/; do
  res=$(grep -c '^resource ' $d/main.tf 2>/dev/null || echo 0)
  echo "$d  inlined_resources=$res"
done | awk '$2 != "inlined_resources=0"'

# Smell 3: primitives with scope discriminators
grep -rl 'count\s*=\s*var\.' $REPO/modules/primitives/ \
  | xargs grep -l 'sink_level\|scope\|level\|tier' 2>/dev/null

# Dead variables (unused in main.tf)
for d in $REPO/modules/{primitives,composed,infrastructure}/*/; do
  test -f $d/variables.tf || continue
  awk '/^variable / { match($0, /"[^"]+"/); print substr($0, RSTART+1, RLENGTH-2) }' $d/variables.tf | while read v; do
    if ! grep -q "var\.$v\b" $d/main.tf 2>/dev/null; then
      echo "$d variables.tf: $v never referenced in main.tf"
    fi
  done
done

# Echo outputs (output that returns var.x verbatim)
for d in $REPO/modules/**/*/; do
  test -f $d/outputs.tf || continue
  awk '/value\s*=\s*var\.[a-z_]+\s*$/ { print FILENAME":"NR": "$0 }' $d/outputs.tf
done
```

Run these in Step 1, then read the suspect files in Step 2.

## The "opportunities" output

A smell points at something broken. An **opportunity** points at something missing — patterns the repo could express but doesn't. Always include an opportunities subsection. Examples:

- "Three different modules grant `roles/X` to a remote SA. Extract a `links/grant-remote-sa-role` linking module."
- "Five primitives accept `var.labels`. None enforce mandatory labels. Add a shared `validation` block via a thin `_label-policy` module that all primitives reference."
- "The `examples/` directory is empty. Each composition's variable schema is a perfect fit for `examples/<name>/`; running `terraform plan` against them gives you free regression tests via `terraform test`."
- "All modules pin `~> 6.14` of the provider. The provider is now at 6.20. Open a single PR bumping the lock file — the audit baseline catches any drift."

Opportunities go in Section 8 (the next-pass plan), prioritized by ratio of value to blast radius.

## What this section is NOT for

- Per-module hygiene (variables missing descriptions, outputs missing `sensitive`). That belongs in Section 5.
- Provider-specific gaps (no VPC-SC, no WIF). That belongs in Section 6.
- Repo-level gaps (no README, no CI). That belongs in Section 7.

If a finding is about how *this* module is written, it's not a composition smell. If a finding is about how *this* module relates to *other* modules, it is.
