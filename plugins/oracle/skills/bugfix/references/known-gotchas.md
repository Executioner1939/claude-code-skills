# Known gotcha classes

Recurring traps that have each cost a full diagnosis cycle at least once.
Check this list during grounding (§1 of SKILL.md) before treating a
symptom as a novel bug. These are generic classes, not project-specific
facts — the point is to recognize the *shape* of each trap quickly in
whatever codebase you're actually in, then verify against that codebase's
real state before acting on the pattern-match.

## Concurrent work on the same code path {#parallel-work}

In any environment where more than one agent, session, or engineer can
touch the same repo at once, a "fix this" instruction may already be in
flight elsewhere. Two independent implementations of the same fix landing
close together is a classic failure mode: one gets pushed directly, the
other opens a PR, and the direct push has to be reverted once the PR
merges — a wasted cycle and a noisy history. Before implementing *and
again right before pushing*, check for open PRs touching the same area
and for sibling checkouts with a dirty tree or fresh unpushed commits. If
a parallel implementation exists, converge on one contract before
anything lands on the shared branch.

## Don't revert commits you didn't author {#dont-revert}

An unexpected commit on a shared branch is not automatically scope creep.
Assuming an unfamiliar commit is stalled or abandoned work and reverting
it is a common overreach — it can just as easily be someone else's
legitimate parallel contribution, and the revert then has to be
discovered and reapplied. Only revert your own mistaken commits
autonomously; for anything else, surface it and ask.

## Config that's a silent no-op in one build mode

A config value (env var, feature flag, compile-time constant) can be read
only under one build profile — debug, dev, test — and silently ignored in
the profile that actually ships. A value that "does nothing" in
production can be entirely expected rather than a bug: check the actual
read site for the build mode you're diagnosing, not just that the
variable is declared somewhere in config. The same audit often turns up
the inverse too — config entries with zero code references anywhere,
carried forward out of habit and safe to ignore or remove.

## Stale-state markers not cleared on every transition

When a status/marker/cache field gates behavior (a lane marker, a
"completed" flag, a denormalized copy of some other table's state), check
whether the write path actually updates or clears it on *every* relevant
state transition — not just the one it was originally built for. A marker
written once at creation and never revisited is a common source of "this
worked right after creation but is wrong once the object changes state
again" bugs.

## Immutable fields in declarative infrastructure

Declarative infra tooling (Kubernetes CRDs with admission webhooks,
Terraform resources with `ForceNew`/`create_before_destroy` semantics)
often has fields that are rejected on update once the underlying object
exists — even when the real external resource behind it was never
actually created (e.g. from an invalid generated name). Merging a
manifest fix alone is not enough in that case; the reconciler's apply
keeps failing with the old value. The fix is usually to delete and let
the controller recreate the object from the corrected spec — but check
first whether the *real* external resource exists; if it does, mark it
for adoption/retention (most tools have an "abandon on delete" style
annotation) before deleting the object that manages it, so the delete
doesn't destroy real infrastructure.

## Deploy pipeline wedged on a health check that can never pass

If a GitOps/CD sync hangs indefinitely waiting for some resource to
report healthy, check whether that resource's health check can *ever*
succeed in this environment — e.g. a resource whose supporting
infrastructure is denied by a cluster policy, so it never reaches ready
state and the default health check reports "progressing" forever.
Self-healing reconciliation does not un-stick an already-running
operation; it needs to be cleared explicitly, and the underlying fix is
either removing the permanently-unhealthy resource or adding a custom
health check override for its kind before reintroducing it.

## Workspace/monorepo lockfile divergence

A package built via its own standalone Docker/CI pipeline (rather than
from the monorepo root) can resolve dependencies from a package-local
lockfile that a plain `install` run from inside that package's directory
does not update — because the install walks up and updates the
*workspace* lockfile instead. The result: the package-local lockfile goes
stale, and a frozen-lockfile CI install fails even though "everything
was installed fine locally." After changing dependencies in a
workspace-member package, verify which lockfile its actual build/deploy
path consumes and regenerate that one explicitly (most package managers
support a lockfile-only, ignore-workspace regenerate mode).

## Sandboxed-shell permission limits {#shell-limits}

An agent's shell may authenticate with narrower permissions than the
user's own terminal — a service-account identity that can read but not
mutate live infrastructure, or that can't complete an interactive
re-auth. Retrying the same privileged command in a loop won't fix this.
Recognize the limit, then hand the user the exact command to run
themselves in their own terminal rather than looping on a call that will
never succeed from this shell.

## Squash-merging a branch that will be diffed against later {#squash-ancestry}

If a long-lived integration branch is merged into another long-lived
branch via squash, the target branch gets one new commit with no shared
history past that point — `merge-base` freezes at the pre-squash commit.
Every later compare between the two branches then re-diffs the *entire*
subsequent history of the source branch, so a genuine one-file follow-up
fix can show as thousands of files changed. Any merge between two
branches that will be diff-compared again later should be a true merge
commit, not a squash. If ancestry has already severed: identify content
that's genuinely unique to the target branch (`git diff --numstat` /
`--diff-filter=A` against the source), cherry-pick just that back onto
the source, then re-link ancestry with an ours-strategy merge
(`git merge -s ours --no-ff <target>`) so future diffs collapse back to
the real delta.
