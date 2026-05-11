---
description: Production-gate Kubernetes readiness check. Strictest gate -- full LearnKube checklist including admission control, multi-zone, PDBs, runbooks, DR, cost, image digest pinning, and the multi-burn-rate SLO alerting wired to PagerDuty. Two-agent (deployment-verifier + observability-auditor) read-only audit of application code, manifests, Helm/Kustomize, Terraform, and GitOps configs. Use immediately before a production cutover.
argument-hint: "[path] [--no-iac]"
disable-model-invocation: true
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash(mkdir:*)
  - Bash(date:*)
  - Bash(pwd)
  - Bash(test:*)
  - Bash(echo:*)
  - Bash(awk:*)
  - Bash(grep:*)
  - Bash(printf:*)
  - Bash(cut:*)
  - Bash(jq:*)
  - Agent(deployment-verifier)
  - Agent(observability-auditor)
model: claude-opus-4-7
---

# Production-gate readiness check

You orchestrate the production go-live gate. This is the strictest of the
three gates: every checklist item is in scope, every `FAIL` blocks
promotion, every `WARN` needs an explicit acknowledgement.

The agents auto-load their skills. Do not restate methodology.

## Inputs

`$ARGUMENTS` is `[path] [--no-iac]`.

```!
PATH_ARG=$(printf '%s' "$ARGUMENTS" | awk '{print $1}')
case "$PATH_ARG" in ''|--*) PATH_ARG="$(pwd)";; esac
SKIP_IAC=$(printf '%s' "$ARGUMENTS" | grep -oE -- '--no-iac' | head -n1)
test -d "$PATH_ARG" || { echo "ERROR: $PATH_ARG is not a directory"; exit 1; }
TIMESTAMP=$(date +%Y%m%dT%H%M%S)
OUTDIR="$PATH_ARG/.k8s-readiness/$TIMESTAMP-production"
mkdir -p "$OUTDIR/verifier" "$OUTDIR/observability"
echo "PATH=$PATH_ARG"
echo "GATE=production"
echo "OUTDIR=$OUTDIR"
echo "SKIP_IAC=${SKIP_IAC:-no}"
```

## Phase 0 — Confirm go-live posture

Before dispatching, ask the user once (with the AskUserQuestion tool when
available, otherwise stop and ask in chat):

- **What is the workload's SLO?** (e.g. 99.9, 99.95). The observability
  auditor needs this to compute multi-burn-rate thresholds. If unstated,
  it will appear as `DECISION_REQUIRED` in the report — surfacing it now
  saves a round-trip.
- **Rollback or roll-forward posture?** The LearnKube checklist item
  "rollback vs roll-forward has been decided" cannot be inferred; it must
  be stated.
- **Cost ceiling per month (USD)?** Otherwise "cost reviewed, workload
  right-sized" cannot be evaluated.

Record the answers; thread them into the envelopes below as
`stated_slo`, `rollback_posture`, `cost_ceiling`.

## Phase 1 — Dispatch deployment-verifier

```
## goal
Run the production-gate readiness check against <PATH_ARG>. Apply the full
production column of the gate matrix. Every FAIL is a go-live blocker.

## inputs
- path: { type: path, value: <PATH_ARG> }
- gate: { type: enum<develop|staging|production>, value: production }
- output_dir: { type: path, value: <OUTDIR>/verifier }
- scope_hint: { type: list<string>, value: [<scope list>] }
- stated_slo: { type: string, value: <SLO from Phase 0> }
- rollback_posture: { type: enum<rollback|roll-forward>, value: <answer> }
- cost_ceiling_usd: { type: number?, value: <answer> }

## constraints
must:
  - apply the production column of the gate matrix in full
  - cite file:line for every finding
  - require admission policies (Kyverno / Gatekeeper / ValidatingAdmissionPolicy)
  - require image digest pinning (not just tags)
  - require PodDisruptionBudget on every Deployment with >1 replica
  - require topology spread by zone for tier-1/tier-2 workloads
  - require workload identity for any cloud-resource access -- no static
    credentials in Secrets
  - require external secret store reference (sealed-secrets, SOPS, ESO,
    Vault) for every credential-shaped secret
  - require runbook URL annotation on every workload
    (e.g. ops.k8s.io/runbook)
  - confirm rollback-vs-roll-forward decision is documented somewhere in
    the repo (README, RUNBOOK, or commit message of the release tag)
must_not:
  - allow ":latest" or unsigned images
  - downgrade FAIL -> WARN for "this is staging-good-enough"

## acceptance
- every production gate-matrix row evaluated (or marked N/A with reason)
- <OUTDIR>/verifier/findings.md exists with PASS/PASS_WITH_WARNINGS/FAIL
- <OUTDIR>/verifier/findings.json exists

## handoff
write_to: <OUTDIR>/verifier/findings.md
```

## Phase 2 — Dispatch observability-auditor (parallel)

```
## goal
Audit the production observability posture against the k8s-observability-
metrics skill. The stated SLO is <stated_slo>; verify multi-burn-rate
alerts are wired at the thresholds derived from it.

## inputs
- path: { type: path, value: <PATH_ARG> }
- gate: { type: enum<staging|production>, value: production }
- output_dir: { type: path, value: <OUTDIR>/observability }
- stated_slo: { type: string, value: <stated_slo> }

## constraints
must:
  - verify the multi-burn-rate alert pair (1h ∧ 5m, 6h ∧ 30m) per Table 5-8
    with thresholds = burn_rate * (1 - SLO) for the stated SLO
  - verify the slow-burn ticket alert (3d ∧ 6h)
  - verify exemplars are wired end-to-end SDK → Collector → Prometheus →
    Grafana (or equivalent) -- without exemplars, the alert annotation
    cannot deep-link to a trace
  - verify tail sampling retains 100% of error traces (status_code: ERROR)
    and a tunable fraction of slow traces (latency policy)
  - verify trace affinity (loadbalancing exporter or per-namespace gateway)
  - produce two tailored deep-dives modeled on §6.3 and §6.4 -- one for
    the highest-traffic service, one for the most error-prone (or, if no
    error stats, the most latency-sensitive)
must_not:
  - synthesize a default SLO

## acceptance
- <OUTDIR>/observability/observability-audit.md exists
- <OUTDIR>/observability/observability-audit.json exists
- the two tailored deep-dives are present (not the canonical generic ones)

## handoff
write_to: <OUTDIR>/observability/observability-audit.md
```

Dispatch Phase 1 and Phase 2 **in parallel**.

## Phase 3 — Synthesize go-live verdict

Write `<OUTDIR>/index.md`:

```markdown
# Production readiness — <TIMESTAMP>

**Path:** <PATH_ARG>
**SLO:** <stated_slo>
**Rollback posture:** <rollback|roll-forward>
**Cost ceiling:** $<cost_ceiling_usd>/mo (or "not stated")

## GO / NO-GO

**Verdict:** GO | GO_WITH_ACK | NO-GO

GO requires:
- Both audits PASS or PASS_WITH_WARNINGS with explicit acknowledgement of
  every WARN.
- No FAIL in either audit.
- All Phase 0 questions answered.

## Audit summary

| Audit | Verdict | FAIL | WARN | INFO |
|---|---|---|---|---|
| Deployment verifier | <verdict> | <n> | <n> | <n> |
| Observability auditor | <verdict> | <n> | <n> | <n> |

## Blocking findings

(every FAIL from both audits, one row each)

| ID | Audit | Title | File:line |
|---|---|---|---|

## Warnings requiring acknowledgement

(every WARN -- the user must check off each one for GO_WITH_ACK)

- [ ] <ID> — <title> — <file:line>
- [ ] ...

## Decisions still required

(any DECISION_REQUIRED that the Phase 0 answers did not resolve)

## Artifacts

- [Deployment findings](verifier/findings.md)
- [Observability audit](observability/observability-audit.md)
```

Print to chat:

- The GO/NO-GO verdict
- Counts per severity
- Top three blockers
- Remaining decisions

Do not re-paste full reports.

## Whole-workflow constraints

- Read-only end to end.
- The two agents are dispatched in parallel.
- The Phase 0 questions are mandatory — do not infer answers.
- A `FAIL` in either audit forces `NO-GO` regardless of severity counts.
- "GO_WITH_ACK" requires the human to acknowledge every WARN; this command
  does not auto-acknowledge.
