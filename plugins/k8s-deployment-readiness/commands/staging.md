---
description: Staging/UAT-gate Kubernetes readiness check. Two-agent verification of application code, manifests, Helm/Kustomize, Terraform, and GitOps configs against the full pre-production checklist from learnkube.com/production-best-practices. Also runs the observability audit (RED, USE, exemplars, sampling, multi-burn-rate SLO alerts). Use before promoting a release candidate to UAT.
argument-hint: "[path] [--no-iac] [--no-observability]"
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
  - Agent(deployment-verifier)
  - Agent(observability-auditor)
model: claude-opus-4-7
---

# Staging / UAT-gate readiness check

You orchestrate a two-agent readiness audit suited to the pre-production
promotion. Both agents are read-only.

The agents auto-load their skills. Do not restate methodology in envelopes.

## Inputs

`$ARGUMENTS` is `[path] [--no-iac] [--no-observability]`.

```!
PATH_ARG=$(printf '%s' "$ARGUMENTS" | awk '{print $1}')
case "$PATH_ARG" in ''|--*) PATH_ARG="$(pwd)";; esac
SKIP_IAC=$(printf '%s' "$ARGUMENTS" | grep -oE -- '--no-iac' | head -n1)
SKIP_OBS=$(printf '%s' "$ARGUMENTS" | grep -oE -- '--no-observability' | head -n1)
test -d "$PATH_ARG" || { echo "ERROR: $PATH_ARG is not a directory"; exit 1; }
TIMESTAMP=$(date +%Y%m%dT%H%M%S)
OUTDIR="$PATH_ARG/.k8s-readiness/$TIMESTAMP-staging"
mkdir -p "$OUTDIR/verifier" "$OUTDIR/observability"
echo "PATH=$PATH_ARG"
echo "GATE=staging"
echo "OUTDIR=$OUTDIR"
echo "SKIP_IAC=${SKIP_IAC:-no}"
echo "SKIP_OBS=${SKIP_OBS:-no}"
```

## Phase 1 — Dispatch deployment-verifier

Use the Task tool. If `SKIP_IAC` is set, narrow `scope_hint` to
`[app, manifests, helm]`; otherwise include `terraform` and `gitops`.

```
## goal
Run the staging-gate readiness check against <PATH_ARG>. Verify the full
staging column of the gate matrix, including Helm/Kustomize/Terraform/
GitOps when present.

## inputs
- path: { type: path, value: <PATH_ARG> }
- gate: { type: enum<develop|staging|production>, value: staging }
- output_dir: { type: path, value: <OUTDIR>/verifier }
- scope_hint: { type: list<string>, value: [<scope list above>] }

## constraints
must:
  - apply the staging column of the gate matrix
  - cite file:line for every finding
  - classify FAIL / WARN / INFO
  - when Terraform / GitOps is in scope, cross-check IRSA / Workload
    Identity trust scoping per k8s-iac-compliance §2
must_not:
  - run any cluster-touching command
  - apply production-only items (PDB-must-exist may still WARN, but
    "admission policies validate every manifest" is production-only)

## out_of_scope
- write/edit anything
- observability audit (that runs in parallel via observability-auditor)

## acceptance
- <OUTDIR>/verifier/findings.md exists
- <OUTDIR>/verifier/findings.json exists
- every FAIL/WARN row carries a file:line citation
- DECISIONS_REQUIRED listed prominently

## handoff
write_to: <OUTDIR>/verifier/findings.md
```

## Phase 2 — Dispatch observability-auditor (parallel)

Skip Phase 2 if `SKIP_OBS` was set. Otherwise dispatch in **parallel** with
Phase 1 — they don't depend on each other.

```
## goal
Audit the microservice observability posture of <PATH_ARG> against the
k8s-observability-metrics skill's checklist (semantic conventions,
exemplars, tail sampling, multi-burn-rate SLO alerts).

## inputs
- path: { type: path, value: <PATH_ARG> }
- gate: { type: enum<staging|production>, value: staging }
- output_dir: { type: path, value: <OUTDIR>/observability }
- services: { type: list<string>?, value: null }

## constraints
must:
  - detect SDK usage by language, collector configs, prometheus rules,
    grafana dashboards, alertmanager routes
  - produce a per-service scorecard
  - produce a worked example tailored to the highest-traffic service
    (model §6.3 exemplar-driven or §6.4 tail-sampled + multi-burn-rate)
  - cite file:line for every finding
must_not:
  - query a live backend
  - invent an SLO -- if unstated, raise as DECISION_REQUIRED

## acceptance
- <OUTDIR>/observability/observability-audit.md exists with per-service
  scorecard and at least one tailored deep-dive
- <OUTDIR>/observability/observability-audit.json exists

## handoff
write_to: <OUTDIR>/observability/observability-audit.md
```

## Phase 3 — Synthesize index

Write `<OUTDIR>/index.md` at the top level:

```markdown
# Staging readiness — <TIMESTAMP>

**Path:** <PATH_ARG>
**Overall verdict:** PASS | PASS_WITH_WARNINGS | FAIL

## Verdicts

| Audit | Verdict | Counts |
|---|---|---|
| Deployment verifier | <verdict> | FAIL=<n>, WARN=<n>, INFO=<n> |
| Observability auditor | <verdict> | FAIL=<n>, WARN=<n>, INFO=<n> |

## Artifacts

- [Deployment findings](verifier/findings.md)
- [Observability audit](observability/observability-audit.md)

## Top blockers

1. <FAIL-ID> — <one-line title> — <file:line>
2. ...
(up to 10)

## Decisions required

(collated verbatim from both reports)

- [ ] <question>
- [ ] <question>

## Next

When blockers are resolved, run:

    /k8s-deployment-readiness:production <PATH_ARG>
```

Print to chat:

- Path to `<OUTDIR>/index.md`
- Overall verdict + counts
- The top three blockers (one line each)
- The full decision queue

Do not re-paste the full reports.

## Whole-workflow constraints

- Read-only.
- Phase 1 and Phase 2 are dispatched **in parallel** unless one is
  disabled.
- If both agents return `FAIL`, the index verdict is `FAIL`.
- If either returns `WARN` and neither is `FAIL`, verdict is
  `PASS_WITH_WARNINGS`.
- If both are `PASS`, verdict is `PASS`.
