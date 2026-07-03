---
name: bugfix
description: 'This skill should be used when the user explicitly invokes `/oracle:bugfix <bug report>` to diagnose and fix a reported bug end-to-end, or when a message reads as an unambiguous bug report paired with a request to fix and ship it -- a pasted error or Slack/issue-tracker message, a described regression, "X is broken", "why does Y do Z", "is this intentional". Grounds in git history and project context before touching code, distinguishes an accidental regression from a deliberate design decision that is now wrong for a changed requirement, fixes the root cause with Boy Scout cleanup of directly-adjacent gaps, adds regression/unit test coverage, and lands the change as a hotfix -- branch, PR, merge -- by default, unless the user specifies a different flow.'
argument-hint: <bug report text, or blank to diagnose from the current conversation>
allowed-tools: Bash, Read, Edit, Write, Grep, Glob, Skill, Agent
---

# /oracle:bugfix

## Mission

A bug report is incomplete by construction — it describes a symptom, not
a cause. Find the cause before writing a single line of fix. Distinguish
"broken" from "deliberate, but wrong for a requirement that changed since
it was written." Land a change someone else can trust without re-deriving
your reasoning. Every version of this workflow that has gone wrong did so
at the front: skipping the git-history check, assuming a filter or guard
was accidental when it was a same-day design decision, or not noticing
that someone else — another session, another engineer — was already
working the same code path. Slow down at diagnosis; move fast at
everything after.

Default to fixing what's reported plus what's Boy-Scout-obviously broken
in the same code path — not more, not less. Ship via the hotfix flow
(§4) unless the user names a different path.

## Preload

Before acting, treat `path-preflight` (verify a path exists before
reading or editing it — don't guess file locations from convention) and
`parallel-tools` (batch independent reads/greps into one turn rather than
serialising them) as binding for this workflow; both auto-trigger on
their own conditions but are especially load-bearing during diagnosis,
where you'll be reading many files fast. If a claim in your diagnosis
rests on something externally-grounded — a library's documented
behavior, a changelog entry, a CVE — route it through the oracle
verification cascade (`/oracle:verify` or the auto-triggering
`verification-protocol`) rather than asserting it from memory.

## 0. Parse the report

Bug reports routinely arrive as pasted messages bundling two or more
distinct symptoms, sometimes with an abrupt topic switch mid-message.
Mirror them back as a numbered list before doing anything — don't
silently collapse multiple asks into one composite response; confirm the
list captures everything, then work through it. If a report asks "is
this intentional?", treat that as a real question you must answer from
git history (§1), not rhetorical framing.

## 1. Ground yourself in context — before touching any code

This is the step every failed run of this workflow skipped. Work through
it fully before writing a fix.

1. **Confirm the repository and the exact subtree you're in.**
   `git remote -v`, and if the project is a monorepo, identify the
   specific package/service actually touched (workspace manifest, Cargo
   workspace members, `package.json` workspaces, a Makefile module list).
   A directory that looks like a standalone project can be a subtree of
   a larger repo with its own remote and CI — verify before assuming
   scope.
2. **Check for a live parallel effort first.** Run `gh pr list --state
   open` (or the host-equivalent) filtered to the touched area, and check
   sibling checkouts or worktrees for a dirty tree or fresh unpushed
   commits touching the same files. In any environment where more than
   one agent or engineer can be working the same repo concurrently, "fix
   this" may already be in flight elsewhere. If you find a parallel
   implementation, converge on one contract before anything lands on the
   target branch — don't duplicate the work or race a second variant in.
   See `references/known-gotchas.md#parallel-work`.
3. **Read the git history of the touched code, not just its current
   state.** `git log -p` / `git blame` the exact lines. Three outcomes
   are possible and they demand different responses:
   - **Accidental regression** — a change broke something nobody
     intended to change. Fix it.
   - **A deliberate, recent design decision that's now wrong for a
     requirement that has since changed.** Say so explicitly: cite the
     commit that made the choice and the reasoning it recorded, then
     explain why the requirement has moved. Treat reversing it as a real
     decision you're stating out loud, not a silent revert. (Illustrative
     shape: a filter gets added to a list or query specifically to keep
     certain items out of a view; the very next bug report is that
     exclusion being wrong for a workflow the original change didn't
     anticipate. Reverting is correct — but only after reading why it
     was added, and saying so.)
   - **Someone else's legitimate in-flight work that merely looks like
     scope creep.** STOP. Surface it to the user — "commit X adds Y, not
     part of my task, keep it or remove it?" — rather than assuming and
     reverting. Only revert commits you authored yourself, autonomously.
     See `references/known-gotchas.md#dont-revert`.
4. **Check the project's own record of known quirks before diagnosing
   something as novel.** Its CLAUDE.md/AGENTS.md, README troubleshooting
   section, issue tracker, or your own memory/notes on this project may
   already document the exact trap you're looking at.
   `references/known-gotchas.md` also catalogs recurring *classes* of
   gotcha worth checking generically (config that's a silent no-op in
   one build mode, infra fields that are immutable once created, dual
   lockfiles in a workspace, deploy pipelines that wedge on an
   unreachable health check) — several "new" bugs are one of these in
   disguise.
5. **Trace the real causal chain, end to end, by reading code.** Never
   assume — verify. Follow the failure from the reported symptom through
   the actual call path to its origin; don't stop at the first
   plausible-looking function. Cite `path:line` for every claim about
   what the code does. Where feasible, reproduce the failure mode
   concretely — a failing test, a repro script, a traced request —
   before writing the fix. A diagnosis you can't demonstrate is a guess.

Only after this step produces a concrete, cited root cause do you move to
a fix. If the report bundles independent bugs, diagnose all of them
before fixing any — the root causes are sometimes shared and sometimes
not, and you won't know which until you've looked.

## 2. Fix the root cause, Boy Scout as you go

- Fix the cause you found in §1, not the symptom the report described.
- If the same gap exists in a sibling code path you're already looking
  at — a second handler, a second service, a second call site with
  provably identical shape — fix it there too and say so explicitly in
  your summary. That's Boy Scout, not scope creep, because you're
  already in the file and the bug is demonstrably the same one. Don't go
  looking for unrelated cleanup elsewhere in the same pass.
- Keep the diff scoped to the bug plus its direct Boy Scout adjacents.
  Don't fold in unrelated refactors, renames, or "while I'm here" changes
  that aren't load-bearing for the fix.
- Leave any unrelated pre-existing dirty working-tree files exactly as
  you found them. Stage files by name; never `git add -A` / `git add .`
  on a tree that has changes you didn't make.

## 3. Test — regression and unit coverage, per stack

Detect the project's own verification commands rather than assuming a
fixed set — read `package.json` scripts, a `Makefile`, the project's
CLAUDE.md/README, or its CI workflow files (`.github/workflows/*`,
`.gitlab-ci.yml`, etc.) for the exact commands it already uses, and run
those. Common ecosystem shapes, as a starting point if nothing else is
documented:

| Ecosystem | Typical commands |
|---|---|
| Rust (Cargo) | `cargo check`, `cargo clippy --all-targets --all-features -- -D warnings`, `cargo test` (or `cargo nextest run` if configured) |
| Node/TS (npm/pnpm/yarn) | `<pm> run typecheck`, `<pm> run lint`, `<pm> test` |
| Python | `pytest`, plus whatever type/lint tooling the project declares (`mypy`, `ruff`, `flake8`) |
| Go | `go build ./...`, `go vet ./...`, `go test ./...` |
| Infra manifests (K8s/Helm/Kustomize) | render/validate before assuming correctness: `kustomize build`, `helm template --validate`, `kubectl diff` if the cluster is reachable |
| Terraform/OpenTofu | `terraform validate`, `terraform plan` — never `apply` without explicit instruction |

Add or extend a test that pins the *specific* bug scenario you diagnosed
— "the build passes" is evidence you didn't break anything else, not
evidence the bug is fixed. Mirror the existing test file's conventions
(stub shape, fixture style, naming) rather than introducing a new
pattern into the suite.

If the affected surface can only be exercised through a browser, a live
cluster, or another system you can't reach from this shell, say so
explicitly in your report rather than claiming full verification — flag
it as a manual step for the user. See
`references/known-gotchas.md#shell-limits`.

## 4. Ship it — hotfix flow is the default

Unless the user specifies a different path (feature branch with normal
review, direct push, hold for later), default to this sequence:

1. Confirm the target branch: don't assume a name — `git symbolic-ref
   refs/remotes/origin/HEAD` or `gh repo view --json defaultBranchRef`
   tells you the actual default. Branch off it: `fix/<slug>` (or whatever
   naming convention recent branches in this repo already use — check
   `git branch -r` / `gh pr list --state merged --limit 20` first and
   match it rather than imposing a new one).
2. Commit with a message that states the root cause, not the symptom —
   someone reading `git log` in a month should understand *why*, not
   just *what*.
3. Push and open a PR with a structured body: what was reported, the
   root cause (cite the commit or decision that produced it), what
   changed, verification run, and a test-plan checklist for anything you
   couldn't verify yourself (e.g. a live-UI check).
4. Determine the repo's merge convention before merging — don't assume.
   Check recent merged-PR history (`gh pr list --state merged --limit 20
   --json mergeCommit,title,mergedAt`) or `git log --merges` for whether
   this repo merges or squashes. Match it, unless there's a concrete
   reason to override (e.g. this branch's ancestry needs to survive a
   later compare against a long-lived release branch, in which case a
   merge commit — never a squash — preserves that; see
   `references/known-gotchas.md#squash-ancestry`). If the target
   requires review and you weren't given explicit authorization to
   bypass it (an "admin merge", "hotfix straight in", or an equivalent
   standing instruction), open the PR and stop there for approval —
   don't assume a review bypass is wanted.
5. If you did merge, confirm it landed: `gh pr view <n> --json
   state,mergedAt,mergeCommit`.

## 5. Report back

State plainly: what was actually wrong (root cause, not symptom), what
you changed and why, what got Boy-Scouted alongside it, what test
coverage you added, and anything still open — a deferred edge case, a
manual verification step the user needs to run themselves, or a sibling
bug you noticed but deliberately left out of scope.

## Reference

`references/known-gotchas.md` — recurring *classes* of gotcha worth
checking before diagnosing something as novel: concurrent-session races,
reverting work you didn't author, build-mode config divergence,
stale-state markers, immutable infra fields, deploy-pipeline health-check
wedges, workspace/monorepo lockfile divergence, sandboxed-shell
permission limits, and the squash-merge ancestry trap.
