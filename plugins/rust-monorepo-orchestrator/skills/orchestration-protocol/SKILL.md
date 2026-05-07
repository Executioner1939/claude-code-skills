---
name: orchestration-protocol
description: >
  The contract that lets N parallel subagents coordinate via the filesystem
  without colliding, while preserving the cross-phase HANDOFF chain.
  Auto-loaded into every agent in rust-monorepo-orchestrator. Defines the
  ticket inbox lifecycle, atomic claim semantics, path-locking discipline,
  the HANDOFF.md template, the four-element dispatch envelope, the
  RESULT.md mirror contract, automerge + worktree cleanup, dead-letter
  policy, and subagent memory conventions. Read this first; everything
  else in the plugin assumes it.
---

# Orchestration protocol

This skill is the contract. Every agent in this plugin implements it. Two layers:

| Layer | Scope | Pattern |
|---|---|---|
| 1. **HANDOFF.md** | cross-phase, sequential | Phase N writes a handoff file; phase N+1 reads it as its first input. Halts on missing `HANDOFF: <path>` line. |
| 2. **Ticket inbox** | intra-wave, parallel | N workers claim tickets atomically from `pending/`, work in isolated worktrees, write `RESULT.md`, hand back to a verifier. |

The two layers compose: a wave (`/run-wave`) runs at one HANDOFF phase boundary; inside the wave, M parallel ticket implementers coordinate via the inbox.

---

## Layer 1: HANDOFF.md (cross-phase)

### Storage path

```
<scope>/.refactor/handoffs/<workflow>-<run-id>/phase-<NN>-<from>-to-<to>.md
```

- `<scope>` MUST be absolute. Resolve relative paths via `cd "$scope" && pwd` or `realpath -m`.
- `<workflow>` is the slash command name (`init`, `audit-domain`, `plan-refactor`, `run-wave`).
- `<run-id>` is a short ULID or ISO timestamp (`20260507-1422-3a1b`).
- `<NN>` is zero-padded phase number (`01`, `02`, ...).
- `<from>` / `<to>` are agent names.

A run-id directory accumulates one handoff per phase boundary. Fresh agents picking up mid-run read every prior handoff in order.

### Halt-line discipline

Before yielding, an agent in a chain MUST:

1. Write the HANDOFF.md to the storage path above.
2. Verify the file exists by re-reading it.
3. Print one line to stdout: `HANDOFF: <absolute path>`.

If the orchestrator does not see that line, the workflow halts and surfaces the gap to the user. **No silent handoffs.** This rule is non-negotiable.

Read-only agents (those with `disallowedTools: Write, Edit`) write the HANDOFF.md via `Bash` heredoc:

```bash
mkdir -p "$(dirname "$ABSOLUTE_HANDOFF_PATH")"
cat > "$ABSOLUTE_HANDOFF_PATH" <<'HANDOFF_EOF'
# HANDOFF -- <workflow> / Phase <N>: <from> -> <to>
...
HANDOFF_EOF
```

### Template

The full template lives at `<plugin-root>/templates/HANDOFF-template.md`. Sections in order: Mission (workflow-level, inherited verbatim), Phase status table, What this agent did, Read first (for next agent), Inputs to next agent, Decisions made (do not reverse), Dead ends (do not retry), Blockers, Next steps, Session notes.

### Mission inheritance

Every handoff in a run carries the same Mission, copied forward verbatim. The Mission describes the user's intent for the **whole workflow run**, not just the current phase.

### Phase status table

Each handoff updates the same table -- marks the just-completed phase done, marks the next phase in-progress, leaves later phases unstarted. Subsequent agents update further rows.

| Status marker | Meaning |
|---|---|
| `done` | phase complete, output artifact written |
| `in-progress` | currently executing |
| `pending` | not started |
| `blocked` | halted; resolve before continuing |

Use ASCII text, not emojis (per repo convention).

---

## Layer 2: Ticket inbox (intra-wave)

### Layout

```
<scope>/.refactor/inbox/<domain>/
├── _registry.md            # orchestrator-maintained index
├── pending/T-NNN.md        # available for any worker to claim
├── claimed/T-NNN.md        # claimed but not yet done
├── done/T-NNN.md           # passed verifier; merged
├── failed/T-NNN.md         # failed verifier; eligible for retry
└── ../dead-letter/T-NNN.md # exhausted retries; needs human intervention
```

The orchestrator populates `pending/`. Workers move tickets between directories via the scripts described below. Only the orchestrator writes to `_registry.md`.

### Ticket file shape

See `<plugin-root>/templates/ticket.md` for the canonical template. Frontmatter fields:

| Field | Type | Purpose |
|---|---|---|
| `id` | string (`T-NNN`) | unique within domain |
| `domain` | string | the domain this ticket belongs to |
| `created` | ISO8601 | when the planner emitted it |
| `status` | enum | `pending` \| `claimed` \| `in_progress` \| `done` \| `failed` \| `dead-letter` |
| `depends_on` | list[ticket-id] | upstream tickets that must be `done` first |
| `allowed_paths` | list[path] | the only paths the worker may modify -- ENFORCED by verifier |
| `claimed_by` | string \| null | worker agent-id, set on claim |
| `claimed_at` | ISO8601 \| null | set on claim |
| `attempts` | int | starts at 0, incremented on each failure |
| `max_attempts` | int | typically 3; ticket -> dead-letter when exceeded |
| `isolation` | enum | `worktree` (default) or `none` |
| `worker_model` | string | typically `claude-sonnet-4-6` |

Body sections in order: `objective`, `inputs`, `context`, `tools_and_sources`, `boundaries`, `out_of_scope`, `acceptance`, `output_format`, `handoff`. This mirrors the four-element dispatch contract (objective / output_format / tools / boundaries) that Anthropic specifies for Opus 4.x subagent prompts.

### Atomic claim semantics

`scripts/claim.sh` wraps `mv -n` (no-clobber):

```bash
mv -n "$INBOX/pending/$TICKET_ID.md" "$INBOX/claimed/$TICKET_ID.md"
```

POSIX `rename(2)` is atomic on the same filesystem. Two workers can race for the same ticket; only one `mv` succeeds. The loser sees a non-zero exit and picks the next ticket in `pending/`. There are no locks to forget, no liveness probes, no broker.

After claiming, the worker rewrites the ticket frontmatter to set `claimed_by`, `claimed_at`, and `status: claimed`.

### Path-locking (orchestrator-side)

Path-locking is the concurrency boundary. **Before dispatching ticket T**, the orchestrator:

1. Reads every ticket in `claimed/` (currently in-flight).
2. Computes the union of their `allowed_paths`.
3. If T's `allowed_paths` intersects that union, **does not dispatch T this round** -- picks a non-overlapping ticket instead.

This eliminates merge conflicts at dispatch time. Tickets that touch the same file are serialized; tickets that touch disjoint files run in parallel.

The orchestrator may safely dispatch K tickets in parallel where K is bounded by:

- The number of pending tickets with non-overlapping `allowed_paths`.
- A configurable wave width (default: 5).
- Available compute (worktrees + Rust target dirs are heavy; tune per machine).

### RESULT.md contract

The worker writes `<ticket-id>-RESULT.md` inside its worktree before yielding. Sections in order, mirroring the ticket structure (style mirroring per Anthropic Opus 4.7 docs):

```markdown
# RESULT -- T-NNN

## SUMMARY
One paragraph. What was done. Reference the ticket's objective.

## FILES_TOUCHED
- path/to/file.rs (created | modified | deleted)

## TESTS_RUN
- `cargo test -p <crate>` (PASS | FAIL | SKIPPED, with stderr tail if FAIL)
- `cargo clippy -p <crate> -- -D warnings` (PASS | FAIL)
- `ast-grep scan --rule <rule>.yml --error` (PASS | FAIL)

## RULES_PASSED
- <rule-id>: <one-line outcome>

## FOLLOW_UPS
- [ ] <thing the worker noticed but did not fix; future ticket candidate>

HANDOFF: <absolute path of this RESULT.md>
```

The final `HANDOFF:` line is mandatory. The orchestrator halts on missing handoffs.

### Verifier handoff

After a worker yields, the orchestrator dispatches the `verifier` agent with:

- The ticket's `acceptance` criteria (verbatim).
- The path to the worker's worktree.
- The path to `RESULT.md`.

The verifier:

1. Confirms `FILES_TOUCHED` is a subset of `allowed_paths` (refuses out-of-scope edits).
2. Re-runs every check listed in `acceptance`.
3. Re-runs the relevant ast-grep rules to confirm the violations are gone.
4. Issues one of three verdicts:

| Verdict | Action |
|---|---|
| `PASS` | orchestrator runs `automerge.sh`, ticket -> `done/` |
| `FAIL` | ticket -> `failed/`; if `attempts < max_attempts`, append failure note + `attempts++` and move back to `pending/` |
| `RETRY` | same as FAIL but the verifier supplies a hint appended to the ticket's `objective` |

After `max_attempts` failures, the ticket -> `dead-letter/` for human review.

### Auto-merge + worktree cleanup

`scripts/automerge.sh <ticket-id>`:

1. `cd` to the worker's worktree.
2. `git status --porcelain` -- must be empty (worker is responsible for committing).
3. `cd` to the orchestrator's invocation branch.
4. `git merge --ff-only <worker-branch>` if possible; otherwise `git merge --no-ff <worker-branch> -m "ticket: T-NNN -- <objective summary>"`.
5. `git worktree remove --force <worktree-path>`.
6. `rm -rf <worktree-path>` if any residue (Rust `target/` outside the worktree, etc.).

Rationale for force-cleanup: Rust builds eat disk; per-ticket worktrees with their own `target/` would multiply build artefacts by the wave width. Cleanup is mandatory.

On verifier `FAIL`: leave the worktree in place for inspection. `/replay <ticket-id>` may resurrect it; only on `dead-letter` does the orchestrator clean up the failed worktree.

### Dead-letter

A ticket -> `dead-letter/` after `max_attempts` failures. The dead-letter file is the final ticket plus an appended history block:

```markdown
## ATTEMPT HISTORY

### Attempt 1 (claimed_at: <ts>, by: <agent-id>)
- verdict: FAIL
- reason: <verifier verdict reason>
- result: <link to RESULT.md>

### Attempt 2 ...
```

`/replay <ticket-id>` resurrects to `pending/` with optional `--note "<human notes>"` appended to `objective`.

---

## The four-element dispatch envelope

Per Anthropic Opus 4.x prompting docs, every subagent prompt MUST include:

1. **Objective** -- one paragraph, imperative.
2. **Output format** -- exact sections expected back.
3. **Tools and sources** -- which tools and which files / skills to use.
4. **Boundaries** -- what is in scope, what is out of scope.

Without these four, subagents misinterpret tasks or duplicate work (the documented Anthropic failure mode).

This plugin uses the skunkworks structured envelope, which is a strict superset:

```
## goal               # Anthropic's "Objective"
## inputs             # typed key/value pairs
## context            # paths with do_not_re_derive: true (Anthropic's "Sources")
## tools_and_sources  # (Anthropic's "Tools")
## constraints        # must / must_not (Anthropic's "Boundaries")
## out_of_scope       # explicit non-goals
## acceptance         # verifiable criteria
## output_format      # markdown_sections + schema_ref (Anthropic's "Output format")
## handoff            # write_to: <path>
```

Every dispatch in this plugin uses this envelope verbatim -- no free-form prose.

---

## Subagent memory

Per skunkworks convention, every agent in this plugin declares `memory: project`. Mechanics:

- `.claude/agent-memory/<agent>/MEMORY.md` -- first ~200 lines auto-inject into the agent's system prompt at dispatch.
- `.claude/agent-memory/<agent>/activity.log` -- append-one-line on `Stop` hook.
- The orchestrator updates its own `MEMORY.md` after each wave to record decisions worth carrying forward (which patterns recurred, which path-locks bottlenecked, which rules over-fired).

Memory is per-agent, not shared. Agents communicate via the inbox, not via memory.

---

## Failure modes and recovery

| Failure | Recovery |
|---|---|
| Missing HANDOFF line | Orchestrator halts, surfaces gap. User decides retry or abort. |
| Worker exceeds `allowed_paths` | Verifier marks `FAIL` with reason `scope-exceeded`. Ticket retries. |
| Verifier itself fails | Orchestrator escalates to user; no auto-recovery. |
| Orphan worktree (worker crashed mid-claim) | `scripts/cleanup-orphans.sh` sweeps `git worktree list`; tickets in `claimed/` older than threshold revert to `pending/`. |
| Two workers claim same ticket | Cannot happen -- atomic `mv -n` ensures exactly one wins. |
| Two workers edit overlapping paths | Cannot happen -- path-locking prevents dispatch. |
| Merge conflict on automerge | Cannot happen if path-locking is honored. If it does, treat as critical bug -- orchestrator halts. |

---

## Conventions (non-negotiable)

1. Every claim about your monorepo cites `file:line`. Unanchored claims are not allowed.
2. No emojis in any output, ticket, RESULT, or HANDOFF.
3. The structured envelope is the only dispatch shape. No free-form prose envelopes.
4. The HANDOFF halt-line is mandatory. Silent handoffs are forbidden.
5. Tickets declare `allowed_paths`. Workers MUST NOT modify files outside that list.
6. Audit outputs follow Tier-1 baseline + Tier-2 dated history.
7. `_registry.md` is orchestrator-only. Workers read but do not write it.

---

## When to use this skill

Auto-loaded by every agent in `rust-monorepo-orchestrator` via the `skills:` frontmatter list. The protocol is the contract; the agents implement it.

If you are debugging the protocol itself (e.g. a stuck wave), read this skill first, then `references/troubleshooting.md`.
