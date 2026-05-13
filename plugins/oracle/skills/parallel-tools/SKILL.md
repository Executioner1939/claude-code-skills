---
name: parallel-tools
description: 'This skill should be used whenever Claude is about to issue two or more tool calls that have no data dependency between them. Triggers on situations like reading several files to understand a system, running multiple greps with different patterns, writing several independent files in sequence, gathering metadata from different sources, fetching multiple URLs, running a build plus a typecheck plus a lint, or any other situation where a serial chain of tool calls has no causal ordering. The Opus 4.7 prompting guidance is explicit that Opus under-spawns parallel tool calls by default; transcript-corpus evidence shows zero parallel batches across 3,340 tool-bearing assistant messages in the ten newest sessions on this machine. This skill encodes the parallel-tool discipline so the next batch is dispatched concurrently rather than serially.'
---

# Parallel tool calls

When two or more tool calls have no data dependency between them, issue
them in a single response so the harness dispatches them concurrently.
Opus 4.7 has a documented bias toward serial dispatch; reversing that
bias is the single highest-ROI behavioural change available, because
nothing else compresses wall-clock time anywhere near as cheaply.

## When to parallelise

Parallelise whenever you can answer "yes" to all three:

1. The tool calls share no data flow. Call B does not consume Call A's
   output.
2. None of them mutate state that another one reads. (Two reads of the
   same file are safe; a read after a write is not.)
3. They will all run, regardless of the result of any one of them.

Typical cases:

- Reading several files to understand a system.
- Running multiple `Grep` / `Glob` / `Bash find` queries with different
  patterns against the same tree.
- Writing several independent new files.
- Fetching multiple URLs.
- Running `cargo build`, `cargo clippy`, `cargo nextest`, and `cargo
  fmt --check` together.
- Gathering status from several sources before deciding what to do
  next (`git status`, `git log`, `gh pr view`, `gh run list`).
- Probing for several distinct facts (which Python is on PATH? which
  node? which jq?).

## When NOT to parallelise

- The second call's argument is the first call's result. Example: read
  a config file, then edit it. The edit depends on the read.
- One call mutates a file another call reads.
- The user asked you to pause for confirmation between steps.
- An irreversible action (commit, push, deploy, delete) sits anywhere
  in the batch. Run those alone, with a confirmation gate.

## How to phrase the dispatch

In a single assistant turn, emit all independent tool calls as
siblings, not as separate turns. The harness will fan them out and
return results together. If you find yourself thinking "let me first
do X, then Y", check whether Y actually depends on X. If not, dispatch
them together.

## Why this matters

The transcript-corpus evidence on this machine across 1,186 sessions
shows ~0% parallel-batch rate. Every serial chain that could have been
parallel cost the user real wall-clock latency. The Opus 4.7 prompting
bank in `plugins/harness-tuner/skills/opus-4-7-prompting/SKILL.md`
encodes this as a core directive; this skill is the auto-trigger
companion that fires the discipline at the point of action.

## Edge case: errors in a parallel batch

If one tool in a parallel batch fails, the others still run. Surface
all results in one place, name the failure mode clearly, and decide
whether to retry the failed call alone or with adjusted inputs. Do
not silently absorb the failure.
