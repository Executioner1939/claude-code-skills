---
description: Develop-gate Kubernetes readiness check. Inner-loop verification of application code, container image, and basic manifests against the foundational items of the LearnKube production checklist. Single-agent, fast feedback. Use while a feature branch is open, before opening a PR.
argument-hint: "[path]"
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
  - Bash(printf:*)
  - Bash(sed:*)
  - Agent(deployment-verifier)
model: claude-opus-4-7
---

# Develop-gate readiness check

You orchestrate a fast, single-agent readiness sweep. The goal is to catch
the **contract-level** problems in the inner loop, so they don't escape to
staging.

The agent (`deployment-verifier`) auto-loads the skills it needs. Do not
restate methodology in your envelope — the agent already has it.

## Inputs

`$ARGUMENTS` is `[path]` (defaults to `pwd`).

```!
PATH_ARG=$(printf '%s' "$ARGUMENTS" | sed -E 's/[[:space:]]+--.*$//')
case "$PATH_ARG" in ''|--*) PATH_ARG="$(pwd)";; esac
test -d "$PATH_ARG" || { echo "ERROR: $PATH_ARG is not a directory"; exit 1; }
TIMESTAMP=$(date +%Y%m%dT%H%M%S)
OUTDIR="$PATH_ARG/.k8s-readiness/$TIMESTAMP-develop"
mkdir -p "$OUTDIR"
echo "PATH=$PATH_ARG"
echo "GATE=develop"
echo "OUTDIR=$OUTDIR"
```

## Phase 1 — Dispatch deployment-verifier

Use the Task tool to dispatch agent `deployment-verifier` with this
envelope verbatim:

```md
## goal
Run the develop-gate readiness check against <PATH_ARG>. Catch
contract-level violations that should not escape to staging.

## inputs
- path: { type: path, value: <PATH_ARG> }
- gate: { type: enum<develop|staging|production>, value: develop }
- output_dir: { type: path, value: <OUTDIR> }
- scope_hint: { type: list<string>, value: [app, manifests, helm] }

## constraints
must:
  - apply only the develop-gate column of the gate matrix
  - cite file:line for every finding
  - classify FAIL / WARN / INFO per the agent's rules
  - keep the report tight -- this is the inner-loop gate
must_not:
  - run any cluster-touching command
  - flag items outside the develop-gate column as FAIL (they belong to
    later gates)

## out_of_scope
- Terraform / GitOps scanning (those are staging+ concerns; if the user
  wants them, they will run /staging or /production)
- observability audit (handled by observability-auditor at later gates)
- modifying any file

## acceptance
- <OUTDIR>/findings.md exists with the agent's standard shape
- <OUTDIR>/findings.json exists
- every FAIL/WARN row carries a file:line citation

## output_format
markdown_sections:
  - Verdict
  - Blockers (FAIL)
  - Warnings (WARN)
  - Notes (INFO)
  - Decisions required
  - Items skipped (out-of-gate)

## handoff
write_to: <OUTDIR>/findings.md
```

## Phase 2 — Synthesize for the user

Read `<OUTDIR>/findings.md` and print to chat:

1. The verdict line.
2. Counts per severity.
3. The top three blockers (with file:line).
4. Any `DECISION_REQUIRED` entries verbatim.
5. The next command to run when blockers are clear:
   `/k8s-deployment-readiness:staging <PATH_ARG>`.

Do **not** re-paste the full findings — the user opens the file.

## Whole-workflow constraints

- Read-only. The command is read-only. The agent is read-only.
- Develop is intentionally narrower than staging or production. Do not let
  the agent expand the gate matrix; the wider checks are not yet
  actionable for a feature in active development.
- If `<PATH_ARG>` is empty or has no Kubernetes/app signal, the agent
  reports that explicitly. Do not invent findings.
