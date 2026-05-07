# Inter-Agent HANDOFF Template

Every multi-agent slash command in `rust-monorepo-orchestrator` writes one handoff doc per phase boundary. The next agent reads it as its **first input**. If missing or incomplete, the next phase **halts** and surfaces the gap to the caller.

## Storage path

```
<scope>/.refactor/handoffs/<workflow>-<run-id>/phase-<NN>-<from>-to-<to>.md
```

`<scope>` MUST be absolute. Resolve relative scopes before writing or printing.

- `<workflow>` -- slash command name (`init`, `audit-domain`, `plan-refactor`, `run-wave`).
- `<run-id>` -- short ULID or ISO timestamp (`20260507-1422-3a1b`).
- `<NN>` -- zero-padded phase number (`01`, `02`, ...).
- `<from>` / `<to>` -- agent names (`stack-detective-to-reference-ingester`).

A run-id directory accumulates one handoff per phase boundary, so a fresh agent picking up mid-run can read every prior handoff in order.

## When to write

Write a HANDOFF.md when an agent finishes a phase that is part of a chain.

| Situation | Write? |
|---|---|
| Single-agent command | No |
| Another agent depends on this agent's output | Yes |
| Workflow paused for user confirmation between phases | Yes |
| Agent exiting due to a blocker | Yes (write a "blocked" handoff) |

## Template (copy verbatim, fill every section)

```markdown
# HANDOFF -- <workflow> / Phase <N>: <from> -> <to>

> Run-id: <run-id> | Scope: <absolute-scope-path> | Date: <ISO 8601>
> Cold-start instruction: read this file, then the files under "Read first",
> then begin "Next steps" item 1. Do not ask clarifying questions --
> if a blocker prevents starting, write a blocked handoff and exit.

---

## Mission (workflow-level)

One paragraph. The user's intent for the WHOLE workflow run, not just this
phase. Inherit verbatim from prior handoff if one exists.

---

## Phase status

| # | Phase | Agent | Status | Output artifact |
|---|---|---|---|---|
| 1 | <name> | <agent-name> | done | <path> |
| 2 | <name> | <agent-name> | in-progress | (this handoff) |
| 3 | <name> | <agent-name> | pending | -- |

Statuses: `done`, `in-progress`, `pending`, `blocked`. Use ASCII text, not emojis.

---

## What this agent did

One paragraph describing the work just completed. State results, not effort.

---

## Read first (for the next agent)

Files the next agent must read before doing anything. In order. The "why it matters" is mandatory; do not list a path without context.

1. `path/to/file` -- why it matters.
2. `path/to/file` -- why it matters.

---

## Inputs to the next agent

Concrete data the next agent operates on. Include verbatim where small; otherwise reference the artifact path.

- `target_domain`: orders
- `inventory_summary`: 12 commands, 24 events, 8 views.
- `parameters`: { mode: "default", overrides: ".refactor/standard.md present" }

---

## Decisions made (do not reverse)

Decisions taken in this phase that subsequent phases must respect.

### <Decision title>

- Decision: what was decided.
- Why: the reasoning (constraints, observed signals, tradeoffs).
- Implications: what subsequent phases must do or avoid.

---

## Dead ends (do not retry)

Approaches tried this phase that failed. Subsequent agents must not repeat.

### <Approach name>

- Tried: specific description.
- Failed because: root cause.
- Evidence: file:line, error string, or grep result.

---

## Blockers

Anything that prevented this phase from completing fully.

- <blocker> -- waiting on: <what>. Owner: <agent / user>.

If this handoff is itself a "blocked" handoff, the Phase status table marks this phase `blocked` and the Next steps section instructs the next agent to retry, escalate, or skip.

---

## Next steps (for the next agent)

Ordered. Item 1 is what to start immediately. Each item is specific enough that no clarification is required.

1. <Verb + specific task> -- input: `path`. Context: one sentence.
2. <Verb + specific task> -- input: `path`. Context: one sentence.
3. <Verb + specific task> -- context: one sentence.

---

## Session notes

Gotchas, repo-specific quirks, useful greps, environment caveats.

```bash
# greps that worked well for this scope
grep -RnE 'use crate::infrastructure' src/domain
```
```

## Conventions

1. **Mission is workflow-level, not phase-level.** Every handoff in a run carries the same Mission, copied forward verbatim.
2. **Phase status is a running table.** Each handoff updates the same table -- marks the just-completed phase `done`, marks the next phase `in-progress`, leaves later phases `pending`. Subsequent agents update further rows.
3. **Read first lists are exclusive.** The next agent reads only what is listed. If the agent needs more, it stops and writes a blocked handoff.
4. **Decisions don't reverse without escalation.** A subsequent agent that needs to reverse a decision must produce a blocked handoff and surface to the user; never quietly override.
5. **Dead ends are gold.** A workflow that runs three times wastes weeks re-discovering the same dead end. Always log them.
6. **Blocker resolution is its own phase.** A workflow blocked between phases can resume by spawning a "resolve-blocker" sub-step that writes its own handoff before continuing the chain.

## Validation contract

Before ending its turn, an agent in a chain MUST:

1. Write the HANDOFF.md to the storage path above.
2. Verify the file exists (re-read it).
3. Print one line to stdout: `HANDOFF: <absolute path>`.

If the orchestrator does not see that line, the workflow halts. No silent handoffs.
