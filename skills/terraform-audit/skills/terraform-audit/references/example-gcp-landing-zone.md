# Seed audit: terraform-gcp-landing-zone (2026-05-01)

This is the verbatim critique produced on the first run of the audit skill,
captured against the original repo at
`/Users/skunkworks/Documents/Work/Personal/Protoworks/devops/terraform-gcp-landing-zone`.

Use it as:
- A baseline diff target for the next audit pass.
- An example of the expected output structure (8 sections + per-module grade table + concrete defect list).
- A regression check: when the agent expanding the repo claims a defect is fixed, verify by re-running the audit and comparing to this file.

Repo state at time of audit: 20 modules (14 primitives, 6 composed). Zero README,
zero examples, zero tests, zero environments, zero CI, zero bootstrap.

---

# Brutal review: terraform-gcp-landing-zone

Repo state: **20 modules** (14 primitives, 6 composed). Zero README, zero examples, zero tests, zero environments, zero CI, zero bootstrap. As an "initial repo for all GCP work" — **it's not ready**. Below is the actionable critique, organized so you can fix it in passes.

---

## 1. Composition smell: overlap and duplication that proves the design is wrong

The overlaps are diagnostic — each one points to a missing primitive, a wrongly-scoped composed module, or an abstraction that leaked. Concrete instances:

### A. `org-firewall-policy` (primitive) vs inline firewall in `environment-network`
- `composed/environment-network/main.tf:31-67` inlines `google_compute_firewall` (legacy VPC firewall).
- `primitives/org-firewall-policy/` is a `google_compute_network_firewall_policy` (modern, network-scoped — also misnamed; it is **not** org-scoped).
- **Overlap signals**: there are *three* firewall layers in GCP (org hierarchical, network policy, legacy VPC FW) and your repo has one of each, two of which collide on intent.
- **Fix**: introduce three distinct primitives — `firewall-hierarchical` (org/folder), `firewall-network-policy` (rename current `org-firewall-policy`), `firewall-vpc` (extract the inlined one). `environment-network` then composes whichever the caller wants.

### B. `kms-keyring` is duplicated by `secrets-infrastructure`
- `composed/secrets-infrastructure/main.tf` is a 16-line wrapper around `kms-keyring` plus 5 lines of `google_project_iam_member`. It does **not actually create any `google_secret_manager_secret`**.
- The `labels` variable (line 34) is unused. The `project_id` output just echoes input.
- **Overlap signals**: the composed module has nothing to compose — it duplicates a primitive.
- **Fix**: either (a) delete it and call `kms-keyring` directly, or (b) make it actually create a secret-manager backbone (`google_secret_manager_secret` factory keyed by a map, plus the keyring + IAM grants between the two).

### C. `shared-vpc-network` + `shared-vpc-attachment` + `environment-network` — three views of one concept
- `shared-vpc-network` is the host side. `shared-vpc-attachment` is the service side. `environment-network` calls `shared-vpc-network` (so it *is* a host), but a real env can also be a service project — there's no composed module for that.
- **Overlap signals**: the host vs service distinction is not modeled at the composed layer; you can either be a host or you can't have a network at all.
- **Fix**: split `environment-network` into `environment-network-host` (creates VPC + NAT + spoke + grants xpnHost) and `environment-network-service` (only attaches to a remote host VPC and sets up routes/firewall in service-project scope).

### D. `org-policy` (primitive) vs 10 nearly-identical wrapper blocks in `security-baseline`
- `composed/security-baseline/main.tf` instantiates `org-policy` ten times with copy-pasted variables.
- **Overlap signals**: copy-paste is the loudest "your composition is wrong" signal in the repo.
- **Fix**:
  ```hcl
  locals {
    policies = {
      domain_restricted_sharing       = { constraint = "iam.allowedPolicyMemberDomains", values = { allowed_values = var.allowed_member_domains } }
      disable_sa_key_creation         = { constraint = "iam.disableServiceAccountKeyCreation", enforce = "TRUE" }
      # ...
    }
  }
  module "policies" {
    for_each = { for k, v in local.policies : k => v if try(var.enabled[k], true) }
    source   = "../../primitives/org-policy"
    parent   = var.parent
    rule     = each.value
  }
  ```
  Adding a constraint becomes one map entry, not 10 lines + a variable + an output.

### E. `log-sink` (primitive) hardcodes three scopes via `count`
- `primitives/log-sink/main.tf` uses `count = var.sink_level == "X" ? 1 : 0` three times (org / folder / project), then `outputs.tf` does `coalesce(try(...))` to pick the writer identity.
- **Overlap signals**: one primitive doing three jobs because the scope dimension wasn't modeled cleanly.
- **Fix**: split into three primitives (`log-sink-org`, `log-sink-folder`, `log-sink-project`) or model scope as a discriminated union and pick on `var.sink_level` directly. Either way, kill the `coalesce(try())` output.

### F. `monitoring-baseline` is mislabeled — it's a primitive, not a composition
- It's a flat module that creates `google_monitoring_notification_channel` + `_uptime_check_config`. No submodule composition. It also has zero `google_monitoring_alert_policy` — a "monitoring baseline" with no alerts.
- **Overlap signals**: file lives under `composed/` but doesn't compose anything. The "composed" tier is being used as "things that take many variables" rather than "things that wire primitives together."
- **Fix**: move to `primitives/notification-channels` and `primitives/uptime-checks`, then build a real `composed/observability-baseline` that wires channels + uptime + alert policies + log-based metrics.

### G. `organization-hierarchy` overlaps with what `project` and `folder` already do
- It loops over BU/env to create folders + a "shared" project per BU. But the per-project options are limited (no budget hookup, no default-SA removal). To do anything more, you have to instantiate `project` separately with the folder ID — meaning the composed module isn't really doing the composition, it's doing a *subset*.
- **Overlap signals**: callers will use `organization-hierarchy` *and* `project` together, which means the composed module isn't actually pulling its weight.
- **Fix**: take a richer `projects` input map per env (with budget, host/service flag, IAM, APIs) so `organization-hierarchy` is actually the project factory.

---

## 2. The cross-project linking problem

Goal: "linking modules" — e.g., a GKE cluster in project-A registered with ArgoCD in project-B. **The repo cannot do this today.** Reasons:

1. **No provider aliases anywhere.** Every module silently inherits the caller's default `google` provider. Cross-project resources require explicit aliases:
   ```hcl
   # versions.tf in any cross-project module:
   required_providers {
     google = {
       source                = "hashicorp/google"
       version               = "~> 6.14"
       configuration_aliases = [google.host, google.service]
     }
   }
   ```
   Then in `main.tf`, host-side resources use `provider = google.host`, service-side use `provider = google.service`. The only module in the repo with the right *shape* for cross-project is `ncc-vpc-spoke` (it accepts a remote `hub_id` as a string), but even it doesn't declare aliases.

2. **`shared-vpc-attachment` is the canonical broken case.** It writes both host-project IAM (`subnet.role/networkUser`) and the service-project attachment under one provider. That works only if the caller's SA has both `xpnHost` on the host project and `xpnAdmin` on the service project — i.e. broad org rights. Not a clean two-provider design.

3. **`logging-infrastructure` is the second.** Org-level sinks plus project-level BQ/GCS plus IAM grants on the BQ dataset — three scopes, one provider.

### The pattern for "linking modules" (the table-style cross-project glue)

A linking module is a thin module that takes:
- An ID emitted by a producer module (e.g., a GKE cluster's endpoint + CA cert + WI pool from project-A).
- An ID emitted by a consumer module (e.g., an ArgoCD KSA in project-B).
- Two provider aliases.

And produces:
- The IAM grants on both sides.
- Any SA / WI binding that connects them.
- Output of a connection descriptor (kubeconfig blob, registration manifest).

Recommended new tier: `modules/links/` with submodules like:

| Link module | Producer | Consumer | What it creates |
|---|---|---|---|
| `gke-to-argocd` | GKE cluster (project-A) | ArgoCD KSA (project-B) | WIF binding A→B, RBAC ClusterRoleBinding, Argo `Cluster` Secret |
| `service-to-host-vpc` | Service project | Host project (Shared VPC) | xpn attachment + per-subnet networkUser IAM |
| `app-to-secret` | Application SA (project-A) | Secret Manager secret (project-B) | `secretAccessor` binding on the secret |
| `gke-to-artifact-registry` | GKE node SA (project-A) | AR repo (project-B) | `artifactregistry.reader` on the repo |
| `bq-sink-to-source` | Log sink writer (org/project) | BQ dataset (project-B) | `bigquery.dataEditor` on the dataset |
| `psc-consumer-to-producer` | PSC endpoint (project-A) | Service attachment (project-B) | `forwardingRule` + accept-list |

Every link module is short (≤30 lines), takes two provider aliases, and is *the only place* cross-project IAM happens. This eliminates the "single super-provider" smell across the whole repo.

---

## 3. Per-module grades (worst issue per module)

| Module | Grade | Worst single issue |
|---|---|---|
| primitives/budget-alert | B | `amount` typed `string`; only project scope (no folder/org/billing-account) |
| primitives/cloud-nat | C | `count`-keyed static IPs cause shrink-time churn (main.tf:8-16) |
| primitives/dns-zone | C | DNSSEC strictly tied to `visibility`; no `dns_name` trailing-dot validation |
| primitives/folder | C | No folder-level IAM; output naming collision (`id` vs `folder_id`) |
| primitives/kms-keyring | B | No `version_template` (HSM/algorithm), no `destroy_scheduled_duration` |
| primitives/log-sink | C | `coalesce(try(...))` writer-identity output; one primitive, three scopes |
| primitives/ncc-hub | B | Minimal; no policy_mode/preset_topology controls |
| primitives/ncc-vpc-spoke | A- | The only module with the right cross-project shape |
| primitives/org-firewall-policy | C | Misnamed (it's *network*-scoped); rules keyed by priority drop collisions |
| primitives/org-policy | C | No validation that exactly one of allow/deny/enforce/values is set |
| primitives/project | B | `disable_on_destroy=false` and `disable_dependent_services=false` hardcoded |
| primitives/service-account | B | No WIF provider integration; key creation not blocked at module level |
| primitives/shared-vpc-attachment | D | No provider aliases; cannot cleanly target two projects |
| primitives/shared-vpc-network | B- | `private_ip_google_access=true` and flow-log params hardcoded |
| composed/environment-network | B- | Inlines firewall resource; `enable_ncc_spoke=true` with empty hub_id is silent footgun |
| composed/logging-infrastructure | C | Mixes org+project scope under one provider; archive bucket lacks locked retention and CMEK |
| composed/monitoring-baseline | C | "Baseline" with zero alert policies; not actually composed |
| composed/organization-hierarchy | B- | Dead `root_folder_name` variable; no folder IAM bootstrap |
| composed/secrets-infrastructure | D | Doesn't create any Secret Manager secrets; falsely named |
| composed/security-baseline | D | Three constraints unconditional; copy-pasted modules instead of `for_each`; `restrictSharedVpcSubnetworks` with `allow_all="TRUE"` is wrong intent; contradicts absent WIF |

---

## 4. Concrete defect list

Bugs, dead code, footguns — fix these first:

1. `organization-hierarchy/variables.tf:6-9` — `root_folder_name` declared, never used.
2. `security-baseline/variables.tf:6-9` — `org_domain` declared, never used.
3. `security-baseline/variables.tf:47-51` — `allowed_external_ip_projects` declared, never used.
4. `secrets-infrastructure/variables.tf:34-38` — `labels` declared, never used.
5. `secrets-infrastructure/outputs.tf:11-14` — output echoes input.
6. `security-baseline/main.tf:103-110` — `restrictSharedVpcSubnetworks` set to `allow_all="TRUE"` defeats the constraint's intent.
7. `security-baseline/main.tf:73-101` — three constraints applied with no enable flag.
8. `environment-network/main.tf:31-67` — firewall inlined; should be a primitive.
9. `environment-network/variables.tf:54-58` — `ncc_hub_id` defaults to `""`; `enable_ncc_spoke=true` would silently send empty hub.
10. `environment-network/outputs.tf:21-23` — bare `module.cloud_nat[0].nat_ips` faults if module not instantiated; use `one(...)` or `try(..., [])`.
11. `cloud-nat/main.tf:8-16` — `count`-keyed IPs cause IP churn on shrink.
12. `org-firewall-policy/main.tf:17` — keying rules by priority drops collisions silently.
13. `org-firewall-policy/main.tf:29-30` — `["0.0.0.0/0"]` default for src/dest ranges; require explicit ranges.
14. `log-sink/outputs.tf:3-7` — fragile `coalesce(try(...))`; select on `var.sink_level`.
15. `dns-zone/main.tf:20-22` — DNSSEC tied solely to visibility; no override.
16. `monitoring-baseline/main.tf` — no `google_monitoring_alert_policy` resources.
17. `logging-infrastructure/main.tf:14-36` — archive bucket lacks `retention_policy { is_locked = true }`, versioning, CMEK.
18. `logging-infrastructure/main.tf:45` — filter only catches `cloudaudit`; no Data Access audit log config (`google_organization_iam_audit_config`).
19. `kms-keyring/main.tf:7-18` — no `version_template` (HSM, algorithm).
20. `project/main.tf:14-22` — `disable_*_services` flags hardcoded.
21. `shared-vpc-network/main.tf:41` — `private_ip_google_access=true` hardcoded.
22. `shared-vpc-network/main.tf:35-37` — flow-log params hardcoded.
23. `shared-vpc-attachment/*` — no provider aliases.
24. `logging-infrastructure/*` — no provider aliases; mixes org+project scope.
25. **All modules** — no `validation` blocks except `log-sink/sink_level`.
26. **All required-string variables** — no `nullable = false`.

---

## 5. Variable, output, and resource hygiene

- All 20 `versions.tf` are byte-identical (`required_version = ">= 1.9"`, `google ~> 6.14`) — good consistency, but **no `google-beta` declared anywhere**, which blocks VPC-SC, Access Context Manager, Essential Contacts, SCC, Assured Workloads, etc.
- No `random` / `time` / `null` providers declared even though `kms-keyring` and `monitoring-baseline` would benefit (collision-safe naming).
- `~> 6.14` floats minor; for modules `>= 6.14, < 7.0` is clearer.
- Block ordering inconsistent: most resources put `project`/`name` before `count`/`for_each` (e.g., `cloud-nat/main.tf:11-12`, `kms-keyring/main.tf:8`). Convention is meta-args (`count`, `for_each`, `provider`, `depends_on`, `lifecycle`) at top.
- "this" vs descriptive names mixed within the same module (e.g., `cloud-nat`: `google_compute_router.this` + `google_compute_address.nat`).
- No output is ever marked `sensitive = true`. `cloud-nat.nat_ips`, `service-account.email`, `log-sink.writer_identity` are all reasonable candidates.

---

## 6. GCP landing-zone gaps (entirely missing)

For an "initial repo for all GCP work" to deserve the name "landing zone," these are non-optional:

- **VPC Service Controls** (`google_access_context_manager_*`, `_service_perimeter`) — none.
- **Access Context Manager** — none.
- **Folder-level IAM** (`google_folder_iam_member`) — none. `folder` primitive has no IAM at all.
- **Org-level IAM** — none.
- **Workload Identity Federation pool + provider** — none. Yet `security-baseline` blocks SA key creation, leaving CI with no auth path. **Self-contradicting baseline.**
- **Hierarchical firewall policies** — `org-firewall-policy` is *network*-scoped, not org-scoped. The org/folder layer is missing.
- **Tag-based IAM and tag-based org policies** (`google_tags_tag_key/_tag_value/_tag_binding`) — none. This is the modern pattern.
- **Project factory pattern** — `project` primitive doesn't take per-project budget, default-SA removal, default-network deletion, OS Login enforcement, or default IAM.
- **Host vs service project distinction** — not modeled at the composed layer.
- **Private Service Connect** — none.
- **IAP / BeyondCorp** — no `google_iap_brand`, no `google_iap_tunnel_iam_member`. SSH-via-IAP is the canonical bastion-less pattern.
- **Security Command Center enrollment** — none.
- **Essential Contacts** — none.
- **Cloud Armor**, **Certificate Manager**, **log-analytics buckets** — none.
- **Data Access audit log config** — `logging-infrastructure` only catches Admin Activity; `google_organization_iam_audit_config` not set.
- **DNS policy** (`google_dns_policy`) for forwarding/logging — none.
- **Org-/folder-level budget** — `budget-alert` is project-only.

---

## 7. Repo-level gaps

Confirmed empty: no `README.md`, no `examples/`, no `tests/` (no `*.tftest.hcl`), no `environments/`, no bootstrap module (state bucket + first SA + WIF for CI), no CI workflow, no `backend.tf` template, no `.tflint.hcl`, no `.pre-commit-config.yaml`, no `.terraform-docs.yml`, no `CODEOWNERS`, no `LICENSE`. Without bootstrap + examples + tests, this is a code dump, not a landing zone.

---

## 8. Recommended next-pass plan

Order matters — do these in order so each pass cleans the foundation for the next:

1. **Bootstrap module + tier rename.** Add `modules/bootstrap/` (state bucket with versioning + locked retention, KMS-encrypted, CI SA, WIF pool/provider). Rename `modules/composed/` → `modules/infrastructure/` and add `modules/links/` for cross-project glue.
2. **Provider aliasing pass.** Every primitive that touches more than one project declares `configuration_aliases`. Refactor `shared-vpc-attachment`, `log-sink`, `logging-infrastructure` accordingly.
3. **Kill duplication.** Refactor `security-baseline` to a `for_each` map. Delete `secrets-infrastructure` (or make it actually do secrets). Promote inline firewall to `firewall-vpc` primitive. Split `log-sink` by scope.
4. **Validation pass.** Add `validation` blocks and `nullable = false` everywhere; remove dead variables.
5. **Hierarchical FW + tag-based IAM + WIF + folder IAM** primitives. These four unlock most of the missing landing-zone capabilities at once.
6. **Examples + tests.** One `examples/` directory per primitive (minimal + complete), one `examples/landing-zone/` showing org-hierarchy + security-baseline + logging-infra + WIF wired together. Add `tests/*.tftest.hcl` running `command = plan` against each example.
7. **CI.** GitHub Actions: fmt → validate → tflint → trivy → checkov → terraform test → terraform-docs check. WIF auth, no SA keys.
8. **Linking modules.** Build the table from §2 — start with `service-to-host-vpc`, `app-to-secret`, `gke-to-argocd`. These prove the cross-project pattern works end to end.
