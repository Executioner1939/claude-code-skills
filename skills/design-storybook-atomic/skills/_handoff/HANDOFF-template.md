# Inter-Agent Handoff Template

> Adapted from the `handoff` skill template for *between-session* HANDOFF.md.
> This variant is for **between-agent handoffs within a single workflow run** —
> what one phase passes to the next so the next agent can resume cold.

Every multi-agent slash command in this plugin writes one handoff doc per phase
boundary. The next agent reads that doc as its **first input**. If the doc is
missing or incomplete, the next phase **must stop** and surface the gap to the
caller.

## Storage path convention

```text
<scope>/.design-storybook-atomic/handoffs/<workflow>-<run-id>/phase-<N>-<from>-to-<to>.md
```

`<scope>` MUST be an absolute workspace path. If a workflow passes a relative scope, resolve it before writing or printing (`cd "$scope" && pwd` via Bash, or `realpath -m`).

Where:
- `<scope>` — the audited project root (the path the slash command was invoked against).
- `<workflow>` — the slash command name, e.g. `audit-atomic`, `add-component`, `merge-duplicates`.
- `<run-id>` — short ULID or ISO timestamp (`20260503-1734-43a1`).
- `<N>` — zero-padded phase number (`01`, `02`, …).
- `<from>` / `<to>` — agent names (`cartographer-to-auditor`).

A workflow's run-id directory accumulates one handoff per phase boundary, so a
fresh agent picking up mid-run can read every prior handoff in order.

## When to write a handoff

Write a HANDOFF.md when an agent finishes a phase that is part of a chain.
- **Don't write** for single-agent commands.
- **Always write** when:
  - Another agent depends on this agent's output.
  - The workflow is paused for user confirmation between phases.
  - The agent is exiting due to a blocker (write a "blocked" handoff so a fresh agent can decide whether to retry).

## The template (copy verbatim, fill every section)

```markdown
# HANDOFF — <workflow> / Phase <N>: <from> → <to>
> **Run-id**: <run-id> · **Scope**: <scope path> · **Date**: <ISO 8601>
> **Cold-start instruction**: read this file, then the files under "Read First",
> then begin "Next steps" item 1. Do not ask clarifying questions —
> if a blocker prevents starting, write a blocked handoff and exit.

---

## Mission (workflow-level)

One paragraph. The user's intent for the whole workflow run, not just this
phase. Inherit verbatim from prior handoff if one exists.

---

## Phase status

| # | Phase                  | Agent                     | Status | Output artifact                          |
|---|------------------------|---------------------------|--------|------------------------------------------|
| 1 | Cartography            | component-cartographer    | ✅     | <scope>/.design-storybook-atomic/handoffs/<workflow>-<run-id>/phase-01-cartographer-to-auditor.md |
| 2 | Per-component audit    | atomic-auditor (×N)       | 🔄     | (this handoff)                           |
| 3 | Cross-cutting          | dedup + tokens + a11y     | ⏳     | —                                        |
| 4 | Synthesis              | (orchestrator)            | ⏳     | —                                        |

Statuses: ✅ Done · 🔄 In progress · ⏳ Not started · ❌ Blocked.

---

## What this agent did

One paragraph describing the work just completed. State results, not effort.

---

## Read first (for the next agent)

Files the next agent must read before doing anything. In order.

1. `path/to/file` — why it matters.
2. `path/to/file` — why it matters.

The "why it matters" is mandatory. Don't list a path without context.

---

## Inputs to the next agent

Concrete data the next agent operates on. Include verbatim where small;
otherwise reference the artifact path.

- `target_components`: 24 atoms (full list at `path`).
- `inventory_summary`: SR=22, NEEDS-WORK=2, BLOCKED=0.
- `parameters`: { mode: "default", overrides: ".storybook-atomic.yml present" }.

---

## Decisions made (do not reverse)

Decisions taken in this phase that subsequent phases must respect.

### [Decision title]
- **Decision**: what was decided.
- **Why**: the reasoning (constraints, observed signals, tradeoffs).
- **Implications**: what subsequent phases must do or avoid.

---

## Dead ends (do not retry)

Approaches that were tried this phase and failed. Subsequent agents must not
repeat them.

### [Approach name]
- **Tried**: specific description.
- **Failed because**: root cause.
- **Evidence**: file:line, error string, or grep result.

---

## Blockers

Anything that prevented this phase from completing fully.

- **[blocker]** — waiting on: [what]. Owner: [agent / user].

If this handoff is itself a "blocked" handoff, the Phase status table marks
this phase ❌ and the Next steps section instructs the next agent to either
retry, escalate, or skip.

---

## Next steps (for the next agent)

Ordered. Item 1 is what to start immediately. Each item is specific enough
that no clarification is required.

1. **[Verb + specific task]** — input: `path`. Context: one sentence.
2. **[Verb + specific task]** — input: `path`. Context: one sentence.
3. **[Verb + specific task]** — context: one sentence.

---

## Session notes

Gotchas, repo-specific quirks, useful greps, environment caveats.

```bash
# greps that worked well for this scope
grep -RnE 'var\(--color-' src/components/atoms
```

## Conventions

1. **Mission is workflow-level, not phase-level.** Every handoff in a run
   carries the same Mission, copied forward verbatim.
2. **Phase status is a running table.** Each handoff updates the same table —
   marks the just-completed phase ✅, marks the next phase 🔄, leaves later
   phases ⏳. Subsequent agents update further rows.
3. **Read first lists are exclusive.** The next agent reads only what's listed.
   If the agent needs more, it stops and writes a blocked handoff.
4. **Decisions don't reverse without escalation.** A subsequent agent that
   needs to reverse a decision must produce a blocked handoff and surface to
   the user; never quietly override.
5. **Dead ends are gold.** A workflow that runs three times wastes weeks
   re-discovering the same dead end. Always log them.
6. **Blocker resolution is its own phase.** A workflow blocked between phases
   can resume by spawning a "resolve-blocker" sub-step that writes its own
   handoff before continuing the chain.

## Validation contract

Before ending its turn, an agent in a chain **must**:

1. Write the HANDOFF.md to the storage path above.
2. Verify the file exists (re-read it).
3. Print one line to the orchestrator stdout: `HANDOFF: <absolute path>`.

If the orchestrator does not see that line, the workflow halts and surfaces
the gap to the user. No silent handoffs.
