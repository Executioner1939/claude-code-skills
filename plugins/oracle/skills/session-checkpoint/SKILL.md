---
name: session-checkpoint
description: 'This skill should be used whenever a session has accumulated meaningful work — typically twenty or more tool calls, or a sequence that has touched three or more distinct subsystems, or has crossed a phase boundary (research finished, build started; build finished, validation started; validation finished, commit imminent). Triggers on long monorepo refactors, multi-package Rust workspaces, multi-step terraform plans, anything where the user has asked for several things in one message and the agent is mid-execution. Transcript-corpus evidence on this machine shows 676 user interrupts across 221 sessions concentrated in long Rust and TS sessions; one RedactedCo services-parties session received 24 interrupts. The pattern is drift — the agent loses thread of the original asks and the user has to halt and re-orient. This skill encodes the mirror-back-progress habit so the agent self-checkpoints before drift accumulates into a forced interrupt.'
---

# Session checkpoint

Pause and mirror back what has been done, what is in flight, and
what is next, whenever the session has accumulated enough work that
the user might be losing thread. The checkpoint is the agent's
self-correction mechanism; it costs one short paragraph and prevents
the much more expensive user-interrupt-mid-build cycle.

## When to checkpoint

Checkpoint whenever any one of these is true:

- Twenty or more tool calls since the last checkpoint or user message.
- Crossed a phase boundary: research -> design, design -> build,
  build -> validate, validate -> commit, commit -> review.
- About to take an irreversible action (commit, push, deploy, delete,
  destructive migration). This is also a confirmation gate.
- The user's last message contained more than one ask and you have
  finished at least one of them.
- You've discovered something that changes the plan (a dependency
  doesn't exist, a library is deprecated, a test reveals a wrong
  assumption).

## Checkpoint shape

A checkpoint is three short blocks. Do not pad them.

1. **Done.** What landed since the last checkpoint, in past tense,
   one line per item.
2. **In flight.** What is currently running or about to run.
3. **Next.** What comes after, in the order it will happen.

If the session has multiple asks from a single user message, end the
checkpoint with a one-line restatement of the remaining asks so the
user can redirect cheaply.

## When NOT to checkpoint

- The work is trivially short (under five tool calls).
- The user just gave a single-step instruction and the answer is
  one tool call.
- A checkpoint was already issued less than ten tool calls ago.

## Why this matters

The transcript-corpus evidence on this machine across 1,186 sessions
shows interrupts cluster in long monorepo sessions: one RedactedCo
services-parties session received 24 user interrupts; 221 sessions
have at least one interrupt; 676 interrupts total. Each interrupt is
the user halting work that drifted from intent. A checkpoint at the
right moment is cheap; an interrupt forces the user to absorb context
they shouldn't have to track.

## Composition with other oracle skills

- `parallel-tools` -- the checkpoint may identify multiple
  independent next steps. Dispatch them as a parallel batch.
- `path-preflight` -- before the next phase begins, surface the paths
  involved and pre-flight them.
- `verification-protocol` -- if the next phase makes claims, run the
  verification cascade as part of the phase opener.

## Edge case: the checkpoint reveals a wrong direction

If the act of writing the "Done" block reveals that the work has
drifted from the user's original ask, name the drift and propose two
next moves. Do not silently re-plan and continue; that's the exact
spiral the checkpoint is meant to prevent.
