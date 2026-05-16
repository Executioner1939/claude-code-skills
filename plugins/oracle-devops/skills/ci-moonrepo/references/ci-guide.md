# moon ci Comprehensive Guide

This guide weaves the six production failure modes catalogued in
`SKILL.md` into prescriptive `moon ci` patterns, grounded in the
canonical moon v2 docs (https://moonrepo.dev/docs/guides/ci) and the
user's incident corpus across three Rust monorepos.

Every prescriptive pattern is anchored either to (a) a moon docs URL,
or (b) a failure-mode id and the commit/transcript reference that
demonstrates the failure. Where canon and corpus disagree, both are
noted.

## Table of Contents

1. [The seven steps of `moon ci`](#1-the-seven-steps-of-moon-ci-what-actually-happens)
2. [When to set `runInCI` and what the defaults mean](#2-when-to-set-runinci-and-what-the-defaults-mean)
3. [MANDATORY: explicit task inheritance via `inheritedBy` and tags](#3-mandatory-explicit-task-inheritance-via-inheritedby-and-tags)
4. [The explicit-target filtering rule](#4-the-explicit-target-filtering-rule)
5. [Revision comparison: MOON_BASE, MOON_HEAD, github.event.before](#5-revision-comparison-moon_base-moon_head-githubeventbefore)
6. [Affected-detection: edges, propagation, the `^:check` primitive](#6-affected-detection-edges-propagation-and-the-check-primitive)
7. [Parallelism via `--job` / `--job-total` and GitHub matrix](#7-parallelism-via---job-and---job-total)
8. [Remote caching configuration and fail-fast probes](#8-remote-caching-configuration-and-fail-fast-probes)
9. [Toolchain install: prototools, setup-toolchain, three strategies](#9-the-toolchain-install-step-prototools-setup-toolchain-the-three-strategies)
10. [Reporting and observability](#10-reporting-and-observability-run-report-action-ci-retrospect-ci-booster)
11. [v2.1 and v2.2 features that replace older patterns](#11-v21-and-v22-features-that-replace-older-patterns)
12. [Worked example: PR validate workflow for a Rust monorepo](#12-worked-example-pr-validate-workflow)
13. [Worked example: deploy workflow with image-push + ArgoCD sync](#13-worked-example-deploy-workflow)
14. [Anti-patterns observed in production (the six failure modes)](#14-anti-patterns-observed-in-production)

---

## 1. The seven steps of `moon ci` (what actually happens)

Source: https://moonrepo.dev/docs/guides/ci ("How it works"), captured
2026-05-14.

`moon ci` is a single command that internally orchestrates seven steps,
in order:

1. **Determine changed files** by comparing the current `HEAD` against a
   base revision. Base detection is powered by the `ci_env` Rust crate
   and falls back to `vcs.defaultBranch` if the provider is not
   recognised.
2. **Determine all targets that need to run** based on those changed
   files. This is the affected-set computation. Tasks with
   `runInCI: false` are excluded here; tasks with `runInCI: 'affected'`
   are included only if their project is in the affected set.
3. **Walk dependencies and dependents** of the affected targets. By
   default, dependencies (`^:check`) are walked deeply and dependents
   (`:downstream`) are walked one hop. This is configurable via the
   `--upstream` and `--downstream` flags on `moon exec`, which
   `moon ci` shells through to.
4. **Generate an action and dependency graph.** Every action becomes a
   node: `SyncWorkspace`, `SetupToolchain`, `InstallDeps`,
   `SyncProject`, `RunTask`. v2 applies transitive reduction to the
   graph for performance.
5. **Install the toolchain and applicable dependencies.** This is where
   `setup-toolchain` (the GHA action) and proto's auto-install
   interact. See section 9.
6. **Run all actions within the graph using a thread pool.** Concurrency
   defaults to the number of cores; override via `MOON_CONCURRENCY` or
   `--concurrency`.
7. **Display stats** about passing, failed, and invalid actions.
   `moonrepo/run-report-action@v1` consumes these stats for PR comments
   and workflow summaries.

Steps 1, 2, 3 are where five of the six failure modes manifest. Steps
4, 5, 6 are where the sixth (cache / sccache flakiness) manifests.

### Internal default flags

Source: SKILL.md transcripts + canonical docs.

When you type `moon ci`, moon internally invokes `moon exec` with these
defaults:

- `--affected` — only run tasks affected by changed files
- `--ci` — force CI behaviour even when `CI` env var is unset
- `--on-failure=continue` — keep going after a failed task to surface
  all failures in one run
- `--summary=detailed` — verbose summary for log scraping
- `--upstream=deep` — walk dependencies (`^:check`) all the way up
- `--downstream=direct` — walk dependents one hop

`moon ci :build` is exactly equivalent to `moon exec :build` plus those
defaults plus the `runInCI` filter described in section 4.

---

## 2. When to set `runInCI` and what the defaults mean

Source: https://moonrepo.dev/docs/guides/ci ("Configuring tasks") and
https://moonrepo.dev/docs/config/project#runinci.

Every task has an implicit `runInCI: true` unless one of these
conditions overrides it:

- The task name is `dev`, `start`, or `serve` — these default to
  `false` because they typically spawn long-running processes.
- The task explicitly sets `options.runInCI` to `false` or `'affected'`.

The accepted values are:

| Value | Semantics |
|---|---|
| `true` (default for most tasks) | Always run in `moon ci`, every CI invocation, regardless of affected status. |
| `false` | Never run in `moon ci`. Use `moon run` or `moon exec` instead. |
| `'affected'` | Run in `moon ci` only when the project is affected by changed files. The task is effectively gated on the affected check. |

### Choosing the right value

These rules are repo-policy for the canonical
Rust-service-deploys-via-image-push topology in this user's corpus.
Other topologies may legitimately differ.

| Task type | Recommended `runInCI` | Why |
|---|---|---|
| `check`, `lint`, `test --lib` | `true` | Cheap; run on every PR. |
| `build-release` (release binary) | `'affected'` | Expensive; only build on the push that produced an affected diff. Failure mode `moon-task-run-in-ci-misconfiguration` shows `true` causes PR-validate to schedule release builds, exhausting disk and wasting hours. |
| `docker-push`, `deploy` | `false` | Never run inside `moon ci` — they require credentials and side-effect-free runs. Invoke them via `moon run` / `moon exec` from a separate deploy lane. |
| `dev`, `serve`, integration tests | `false` | Long-running or require infra. |

Failure-mode anchor `moon-task-run-in-ci-misconfiguration`: every task
in `.moon/tasks/<lang>.yml` and per-project `moon.yml` should set
`runInCI` explicitly. Inheritance silence is the bug — when somebody
later edits `.moon/tasks/rust.yml` to add a new task, the inherited
`true` default may not be what they meant.

### `mergeArgs` / `mergeOutputs` and override semantics

When a per-project `moon.yml` overrides a task inherited from
`.moon/tasks/<lang>.yml`, the default merge strategy is **append**, not
**replace**. This bites:

```yaml
# .moon/tasks/rust.yml
tasks:
  build-release:
    command: 'cargo build --release'

# services/users/moon.yml
tasks:
  build-release:
    command: 'cargo build --release --package users-service'
```

Default merge produces argv:
`cargo build --release --package users-service --release` — duplicated
`--release` because the inherited args were not replaced.

Fix:

```yaml
# services/users/moon.yml
tasks:
  build-release:
    command: 'cargo build --release --package users-service'
    options:
      mergeArgs: 'replace'
      mergeOutputs: 'replace'
```

See `references/real-world-gotchas.md` "Task-inheritance override
mechanics" for the full mechanics including `mergeDeps`, `mergeEnv`,
`mergeInputs`.

---

## 3. MANDATORY: explicit task inheritance via `inheritedBy` and tags

> **Rule (mandatory, repo-wide).** Every file under `.moon/tasks/**/*` MUST begin with an `inheritedBy:` block declaring at least one condition (`tags`, `toolchains`, `layers`, `stacks`, `languages`, or `files`). Projects opt in to a tag-conditioned task file by listing the tag in their `moon.yml` `tags:` array -- **never** by language match alone, never by implicit toolchain. A `.moon/tasks/*.yml` file without `inheritedBy:` is forbidden because it inherits to every project in the workspace.

Source: https://moonrepo.dev/docs/concepts/task-inheritance and https://moonrepo.dev/docs/config/tasks#inheritedby (v2.0.0+).

### Why this is mandatory

Implicit inheritance creates compounding chaos that the failure-mode corpus has paid for repeatedly:

1. **You cannot read a single project's `moon.yml` and know which tasks fire.** The actual task set is a fan-in from (top-level `.moon/tasks.yml`, every `.moon/tasks/<anything>.yml` that matches the project's language / toolchain / stack / layer / tags / files, and the project's own `moon.yml`). Each contributor is then merged according to `mergeArgs`, `mergeDeps`, `mergeEnv`, `mergeInputs`, `mergeOutputs`, `mergeToolchains` -- six independent merge axes, each defaulting to `append`. Tracing a "where did `build-release` get `--release` from?" question becomes a six-file archaeology pass.
2. **`runInCI` inheritance silently flips polarity per merge.** A task that's `runInCI: 'affected'` globally and `runInCI: true` locally collapses to the local value because `runInCI` is scalar (the per-key merge strategies apply to maps and arrays, not scalars). A reader who only sees the global file assumes `'affected'` and is wrong; a reader who only sees the local does not know the global ever set anything. Both produce silent over-fire (PR validate schedules `docker-push`) or silent skip (`moon ci :build-release` returns success without running) -- exactly the failure modes anchored by `moon-task-run-in-ci-misconfiguration`.
3. **Affected detection traverses the merged graph, not the file you're reading.** If `build-release`'s `deps: ['^:check']` is inherited from a global file and the project's local override uses `mergeDeps: 'replace'`, the propagation edge silently disappears -- and the `moon-affected-detection-misses-targets` failure mode fires.

Explicit `inheritedBy:` + explicit `tags:` reverses every one of these: the project's `tags:` line is the single source of truth for what files inherit to it, and the file's `inheritedBy:` is the single source of truth for which projects it applies to. The mental model collapses to one direction, both ends typed.

### The architecture: workspace orchestration via CI tags; developer commands via toolchain

The policy: configure as much as possible at workspace level via **CI-lane tags**; only developer ergonomic commands (`dev`, `lint`, `build`, `check`) ride on toolchain conditions because those are language-shaped, not lane-shaped.

#### Prebuilt CI-lane tag files (one per CI lane)

```yaml
# .moon/tasks/ci-pull-request.yml
inheritedBy:
  tags: ['ci-pull-request']
tasks:
  lint:
    command: 'cargo clippy --all-targets -- -D warnings'
    runInCI: 'affected'
  typecheck:
    command: 'cargo check --all-targets --workspace'
    runInCI: 'affected'
  test-unit:
    command: 'cargo nextest run --lib'
    runInCI: 'affected'
```

```yaml
# .moon/tasks/ci-merge-develop.yml
inheritedBy:
  tags: ['ci-merge-develop']
tasks:
  test-integration:
    command: 'cargo nextest run --test "*"'
    runInCI: 'affected'
  build-debug:
    command: 'cargo build --workspace'
    runInCI: 'affected'
  docker-push-dev:
    command: 'docker buildx build --push --tag $DOCKER_IMAGE:dev-$MOON_HEAD .'
    runInCI: 'affected'
    deps: ['^:check', '~:build-debug']
```

```yaml
# .moon/tasks/ci-merge-production.yml
inheritedBy:
  tags: ['ci-merge-production']
tasks:
  build-release:
    command: 'cargo build --release --workspace'
    runInCI: 'affected'
    deps: ['^:check']
    options:
      mergeArgs: 'replace'   # never accumulate args across inheritance
  docker-push-prod:
    command: 'docker buildx build --push --tag $DOCKER_IMAGE:prod-$MOON_HEAD .'
    runInCI: 'affected'
    deps: ['^:check', '~:build-release']
  argocd-sync:
    command: '.ci/argocd-sync.sh $DOCKER_IMAGE prod-$MOON_HEAD'
    runInCI: 'affected'
    deps: ['~:docker-push-prod']
```

#### Developer-command tag files (one per toolchain)

```yaml
# .moon/tasks/rust-developer.yml
inheritedBy:
  toolchains: ['rust']
tasks:
  dev:
    command: 'cargo watch -x run'
    runInCI: false           # explicit; never inherit
  build:
    command: 'cargo build'
    runInCI: false
  lint:
    command: 'cargo clippy'
    runInCI: false           # the CI lane has its own stricter `lint`
  check:
    command: 'cargo check'
    runInCI: false
```

Same shape for `.moon/tasks/typescript-developer.yml` with `inheritedBy: { toolchains: ['node'] }` (or `deno`), `.moon/tasks/python-developer.yml`, etc.

#### Per-project `moon.yml` -- the only file a reader needs

```yaml
# services/users/moon.yml
tags:
  - 'ci-pull-request'
  - 'ci-merge-develop'
  - 'ci-merge-production'

toolchain:
  default: 'rust'

# That's it. No `tasks:` block. No overrides. The `tags` + `toolchain`
# are the complete declaration of what this project does in CI and at
# the developer command line. Tasks live in workspace tag files.
```

Reading the four lines above tells you: this project runs the full PR / develop / prod CI lane and inherits Rust developer commands. To find out exactly which tasks fire, you read four workspace files (three CI lanes + one toolchain) -- never six.

### Forbidden patterns

| Pattern | Why forbidden | What to do instead |
|---|---|---|
| `.moon/tasks.yml` (top-level shared file) | Applies to every project; no opt-out without per-project exclude lists | Split into tag-conditioned files under `.moon/tasks/*.yml` with explicit `inheritedBy:` |
| `.moon/tasks/rust.yml` (toolchain-named, no `inheritedBy:` block) | Matches every project with `toolchain: rust` whether they want it or not | Rename to `rust-developer.yml` AND add `inheritedBy: { toolchains: ['rust'] }`; restrict its scope to developer commands only |
| Any task with `runInCI:` unset | Inheritance silence -- defaults to `true` for non-`dev/start/serve` task names; produces "Resolved targets: 0" surprises when combined with affected detection | Set `runInCI` explicitly to `true`, `false`, or `'affected'` on every task |
| Project `moon.yml` with `tasks:` overrides of inherited tasks | Each override is a new merge axis; one slip on `mergeArgs` / `mergeDeps` and the graph silently changes | Move the override into a new tag-conditioned file; have the project opt in via tag |

### Per-project opt-out for one-off cases

When a project legitimately needs to skip one inherited task (e.g. a no-test library that should not get `test-integration` from `ci-merge-develop`):

```yaml
# libs/shared-types/moon.yml
tags:
  - 'ci-pull-request'
  - 'ci-merge-develop'
workspace:
  inheritedTasks:
    exclude: ['test-integration']
```

`workspace.inheritedTasks` supports `include` (whitelist), `exclude` (denylist), `rename` (map). Source: https://moonrepo.dev/docs/config/project#inheritedtasks.

### Smoke test: enumerate what a project will actually run

```bash
# What tasks does this project have (after inheritance)?
moon project users --json | jq '.tasks | keys'

# What tasks will moon ci actually run for this project on the current diff?
moon query tasks --affected --json | jq '.tasks[] | select(.project.id == "users") | .id'
```

If either output surprises you, the inheritance is doing something you did not declare. That is the bug, not the symptom.

---

## 4. The explicit-target filtering rule

Source: https://moonrepo.dev/docs/guides/ci ("Choosing targets"),
captured verbatim 2026-05-14:

> "When providing targets, `moon ci` will still only run them if
> affected by changed files, but will still filter with the `runInCI`
> option."

This is the load-bearing semantic that produces the two failure shapes
in failure mode `moon-task-run-in-ci-misconfiguration`:

### Failure shape A — "moon ci :build runs nothing"

`moon ci :build-release` returns success without running anything
because:

- `build-release` is set `runInCI: false` (intentional — deploy lanes
  invoke it separately), AND
- The explicit-target filter does not override the `runInCI` filter.

The user expected explicit-target to mean "run this regardless". Canon
says: explicit-target narrows the set; `runInCI` then filters again.
Both filters apply. Result: the deploy silently no-ops.

**Right pattern.** Use `moon run` or `moon exec` to invoke
`runInCI: false` tasks on the deploy lane:

```yaml
# Deploy job
- run: moon run :build-release --affected
- run: moon run :docker-push --affected
```

Or, if you want `moon ci`'s affected-detection plumbing, use
`moon ci`'s shell-through to `moon exec`:

```yaml
- run: moon exec :build-release --affected --ci
```

Anchor: an observed production incident — "restore deploy image
builds — moon ci filters runInCI on explicit targets".

### Failure shape B — "PR validate fires build-release"

Bare `moon ci` runs every affected task with `runInCI: true`. If
`build-release` is `runInCI: true` (a common mistake), every PR with
any affected service schedules a release build. The user observed
this as 45-minute PR validations and disk exhaustion.

**Right pattern.** `build-release: { options: { runInCI: 'affected' } }`
is wrong here — `'affected'` still runs in `moon ci`. What you want is
`runInCI: false` if you never want PRs to fire it, OR keep
`'affected'` and accept that affected-diff PRs will rebuild. The user's
corpus settled on `'affected'` for the canonical topology because the
post-merge push lane and the PR lane both run `moon ci` and the
affected-only gate is the cheapest filter that lets `build-release`
fire on the right side.

Anchor: an observed production incident — "exclude build tasks
from moon ci to prevent disk exhaustion".

---

## 5. Revision comparison: MOON_BASE, MOON_HEAD, github.event.before

Source: https://moonrepo.dev/docs/guides/ci ("Comparing revisions").

`moon ci` detects base and head automatically from the CI provider
(via the `ci_env` Rust crate). If detection fails, it falls back to
`vcs.defaultBranch` for base and `HEAD` for head.

Override precedence (highest first):

1. `MOON_BASE` and `MOON_HEAD` environment variables.
2. `--base <ref>` and `--head <ref>` CLI flags.
3. Auto-detected from CI provider.
4. `vcs.defaultBranch` + `HEAD`.

### Rule: always be explicit; never rely on auto-detection

The auto-detection tier silently picks `github.event.before` on GitHub,
which is the empty string or the all-zero SHA on first push to a new
branch and on force-pushes — both produce the `Resolved targets: 0`
silent no-op. The implicit pattern is a load-bearing bug source.

**Always pass `--base` and `--head` to `moon ci` explicitly, OR set
`MOON_BASE` and `MOON_HEAD` env vars before the invocation.** The
explicit pattern sidesteps the entire `github.event.before` trap class.

```yaml
- name: 'moon ci (always explicit)'
  env:
    MOON_BASE: ${{ env.RESOLVED_BASE }}   # computed in a prior step
    MOON_HEAD: ${{ github.sha }}
  run: 'moon ci --base "$MOON_BASE" --head "$MOON_HEAD"'
```

Use env vars when the same base/head pair feeds multiple `moon`
invocations in one job (compose, query, ci); use CLI flags when only
one invocation needs them. The two mechanisms are interchangeable; the
load-bearing rule is "never let moon auto-detect on GitHub".

### The github.event.before trap (when you must resolve it)

If you compute the base from `github.event.before` in a prior step
(e.g. to feed `RESOLVED_BASE` above), guard both edge cases:

GitHub Actions exposes `github.event.before` as the previous commit on
`push` events. Two values silently break affected detection:

1. **Empty string** — happens when the event payload omits `before`.
2. **All-zero SHA** `0000000000000000000000000000000000000000` —
   happens on the first push to a new branch and on force-pushes.

If you assign `MOON_BASE: ${{ github.event.before }}` without
guarding both cases, moon either crashes or computes `HEAD..HEAD` and
reports `Resolved targets: 0`.

**Right pattern** (GHA expression with double fallback):

```yaml
env:
  ZERO_SHA: '0000000000000000000000000000000000000000'
  MOON_BASE: >-
    ${{
      (github.event_name == 'pull_request' && github.event.pull_request.base.sha) ||
      (github.event_name == 'push' && github.event.before != '' && github.event.before != '0000000000000000000000000000000000000000' && github.event.before) ||
      'main'
    }}
  MOON_HEAD: ${{ github.sha }}
```

### Per-event-type recommendations

| Event | MOON_BASE | MOON_HEAD |
|---|---|---|
| `pull_request` | `github.event.pull_request.base.sha` (the pre-merge parent, NOT the merge commit's first parent) | `github.event.pull_request.head.sha` |
| `push` (regular) | `github.event.before`, guarded against empty and zero-SHA | `github.sha` |
| `push` (first push / force-push) | Default branch tip (`main`) or `HEAD~1` if you need a deterministic single-commit diff | `github.sha` |
| `workflow_dispatch` | Default branch tip | `HEAD` |

### Fetch-depth: 0 is mandatory

Without full git history, moon cannot diff `MOON_BASE..MOON_HEAD`.
`actions/checkout` defaults to shallow (depth 1).

```yaml
- uses: actions/checkout@v4
  with:
    fetch-depth: 0
```

v2.0.3 disabled the hard error for shallow checkouts, but moon still
cannot compute a correct affected set without history. The error
becomes a silent `Resolved targets: 0`.

---

## 6. Affected-detection: edges, propagation, and the `^:check` primitive

Source: https://moonrepo.dev/docs/concepts/project#dependson and the
graph behaviour documented at
https://moonrepo.dev/docs/how-it-works/action-graph.

Affected detection answers: "given these changed files, which tasks
need to run?" The answer flows through three graphs:

1. **File-to-project graph.** A changed file under `services/users/`
   marks the `users-service` project as affected. Workspace-level
   config files (`.moon/workspace.yml`, `.moon/tasks/*.yml`,
   `.moon/toolchains.yml`) mark *every* project as affected — this is
   the workspace-config canary.
2. **Project-to-project graph** (`dependsOn` edges). If
   `users-service.dependsOn: ['shared-types']` and `shared-types` is
   affected, `users-service` becomes transitively affected.
3. **Task-to-task graph** (`deps:` on each task). Within an affected
   project, only the tasks whose `inputs:` matched the changed files
   are affected — unless task-level deps pull in others.

### The `^:check` primitive

Failure-mode anchor: `moon-affected-detection-misses-targets`,
an observed production incident — "propagate affected detection
through task graph".

A common bug: editing a library crate produces `Resolved targets: 0`
for downstream services. Why? Because the service's `build-release`
task does not declare a task-graph dependency on the library's check
task. Project-graph dependsOn alone is not sufficient — moon walks
the task graph, not the project graph, for affected-task selection.

**Right pattern.** Add `^:check` to every `build-release` task:

```yaml
# .moon/tasks/rust.yml
tasks:
  check:
    command: 'cargo check'
    options: { runInCI: true }

  build-release:
    command: 'cargo build --release --package $project'
    deps: ['^:check']    # <-- this is the load-bearing edge
    outputs: ['target/release/$project']
    options: { runInCI: 'affected' }
```

`^:check` means "run check for all `dependsOn` projects first". This
pulls the dependency projects into the affected set as participants,
even if their files did not change in isolation, when a downstream
service requests a build.

### Materialise the affected set with moon query

`moon query projects --affected` is the documented primitive for
producing the affected project list. It emits JSON by default —
there is no `--json` flag, and the page synopsis never lists one.
It is the canonical replacement for `moon exec --downstream` when
you need to know "which projects to deploy". Sources:

- https://moonrepo.dev/docs/commands/query/projects — `--affected`,
  `--upstream`, `--downstream` flags documented; output schema is
  `{ projects: Project[], options: QueryOptions }`.
- https://moonrepo.dev/docs/commands/query/tasks — `--affected` plus
  filter flags for task-level enumeration; JSON also default.
- https://moonrepo.dev/docs/commands/query/changed-files — file-level
  enumeration with `--base`, `--head`, `--status`, `--local`,
  `--remote`. JSON also default.

Failure-mode anchor: an observed production incident — "use moon
query for deploy target detection instead of moon exec --downstream".
`moon exec --downstream` was anecdotally returning empty answers under
merge-commit bases [unverified-canon — community reports, no matching
upstream issue found on https://github.com/moonrepo/moon/issues as of
2026-05-14]; `moon query` is the documented primitive that has not
been observed to exhibit that surface.

```bash
# Materialise affected projects for the deploy lane.
# moon query projects emits JSON by default; no --json flag needed.
affected=$(moon query projects --affected | jq -r '.projects[].id')

# Fail fast if affected is empty on a non-empty diff.
if [[ -z "$affected" && -n "$(git diff --name-only "$MOON_BASE..$MOON_HEAD")" ]]; then
  echo "ERROR: changed files exist but no projects resolved as affected"
  exit 1
fi

# Then drive deploy targets explicitly.
for project in $affected; do
  moon run "$project:build-release"
  moon run "$project:docker-push"
done
```

### Workspace-config canary

Editing `.moon/workspace.yml` should mark every project affected. If
it does not, the inheritance mechanism is broken at the graph level.
This is a useful smoke test:

```bash
# In a branch off main, append a comment to .moon/workspace.yml.
echo "# canary" >> .moon/workspace.yml
git commit -am "canary"
moon query projects --affected | jq '.projects | length'
# Expect: total project count.
```

---

## 7. Parallelism via `--job` and `--job-total`

Source: https://moonrepo.dev/docs/guides/ci ("Parallelizing tasks").

`moon ci --job <index> --job-total <total>` shards the affected target
set across N CI jobs. `--job` is 0-indexed.

```yaml
jobs:
  ci:
    strategy:
      matrix:
        index: [0, 1, 2, 3]
    steps:
      - uses: actions/checkout@v4
        with: { fetch-depth: 0 }
      - uses: moonrepo/setup-toolchain@v0
      - run: moon ci --job ${{ matrix.index }} --job-total 4
```

### Provider-specific shard variables

| Provider | Job index env | Job total env |
|---|---|---|
| CircleCI | `CIRCLE_NODE_INDEX` | `CIRCLE_NODE_TOTAL` |
| Buildkite | `BUILDKITE_PARALLEL_JOB` | `BUILDKITE_PARALLEL_JOB_COUNT` |
| GitLab | `CI_NODE_INDEX` | `CI_NODE_TOTAL` |

GitHub Actions has no native parallelism env vars — use `matrix.index`
as above.

### Sharding caveats

- Each shard re-runs steps 1-4 of `moon ci`, including changed-file
  detection and graph build. That work is duplicated across shards.
- Remote caching is what makes sharding pay off — without it, each
  shard repeats toolchain install and step-graph generation.
- If one shard runs zero affected tasks, it still consumes a runner.
  Failure-mode anchor: the production transcript corpus — "shards finish in
  seconds and nothing gets built or pushed" — this can be either
  affected-detection miss (section 6) or `moon ci` correctly reporting
  no affected work for that shard. Distinguish by checking the other
  shards in the same run.

---

## 8. Remote caching configuration and fail-fast probes

Source: https://moonrepo.dev/docs/config/workspace#remote (workspace.yml
remote block) and https://moonrepo.dev/docs/guides/remote-cache.

### Configuration schema

```yaml
# .moon/workspace.yml
remote:
  host: 'grpcs://cache.depot.dev'        # gRPC over TLS, or grpc:// for plaintext
  auth:
    token: 'DEPOT_TOKEN'                  # env var name (NOT the token itself)
    headers:
      'X-Depot-Org': 'my-org'
  cache:
    compression: 'zstd'
    localReadOnly: false                  # v1.40.0+. true = use remote as fallback only.
```

Supported backends per the v2 docs:

- **gRPC** to any Bazel Remote Execution (REAPI) compliant server
  (`grpcs://`, `grpc://`).
- **Self-hosted bazel-remote** (`buchgr/bazel-remote-cache`).
- **Depot** (managed; uses `grpcs://cache.depot.dev`).
- **GHA cache service** for sccache layer (separate from moon's
  remote cache).

S3-compat and GCS backends are NOT in the moon canon; they would
typically be exposed via a bazel-remote front-end. `[unverified]` for
direct S3/GCS support in v2.2.4.

### Conditional enable via env var

```bash
MOON_REMOTE_HOST=grpcs://cache.depot.dev moon ci
```

This is useful for self-hosted runners where the cache URL differs
from what is in `workspace.yml`. The env var takes precedence over
the file.

### Fast-fail probe (recommended)

Failure-mode anchor: `moon-remote-cache-and-sccache-flakiness`,
commits incident references in in production — three
disable-then-re-enable toggles in ~6 weeks of oscillation.

The right move is NOT to toggle the cache. It is to keep the cache
configured and add a probe that fails fast when the cache is
unreachable, then degrades to local-only.

```yaml
- name: Probe moon remote cache
  run: |
    if ! timeout 25 grpcurl -plaintext "${MOON_REMOTE_HOST#grpcs://}" \
        grpc.health.v1.Health/Check 2>/dev/null; then
      echo "moon remote cache unreachable; falling back to local"
      unset MOON_REMOTE_HOST MOON_REMOTE_TOKEN
      echo "MOON_REMOTE_HOST=" >> $GITHUB_ENV
      echo "MOON_REMOTE_TOKEN=" >> $GITHUB_ENV
    fi
```

Alternatives when `grpcurl` is not installed:

```bash
nc -zw5 cache.depot.dev 443     # tcp probe, 5s timeout
```

The `localReadOnly: true` setting in `workspace.yml` is the
documented fallback when the cache is healthy but you want builds to
read from remote without polluting it.

### sccache vs moon remote cache

These are two distinct caches that often get conflated:

- **moon remote cache** caches task outputs (binaries, test artifacts)
  keyed by moon's hash of inputs + command + toolchain.
- **sccache** caches rustc compilation artifacts (object files) keyed
  by source hash + flags.

Both can be enabled. They cache at different layers.

### sccache + GHA cache service

The GHA cache service backs sccache when `SCCACHE_GHA_ENABLED=true`.
When GHA cache 503s, sccache fails save/restore with HTTP errors from
`https://acghub*.actions.githubusercontent.com/`. This is a separate
failure from moon remote cache being unreachable.

Failure-mode anchor: an observed production incident — "remove
sccache (GHA cache service unavailable)" — disable was the
expedient unblock, but the right fix is to keep sccache configured
and let it degrade silently when GHA cache 5xxs.

### sccache + release LTO

Anecdotally (sccache community, `[unverified]` against moon canon),
sccache cannot cache the link/LTO step in release builds, so the
wrapper adds overhead without proportional savings on link-heavy
crates. The pattern in this user's corpus is to unset
`RUSTC_WRAPPER` for `build-release` specifically:

```yaml
# .moon/tasks/rust.yml
tasks:
  build-release:
    command: 'cargo build --release'
    env:
      RUSTC_WRAPPER: ''       # unset for release
```

### SCCACHE_IDLE_TIMEOUT at workflow level

The sccache server default idle timeout is 10 minutes. Long-running
release LTO links exceed that and kill the sccache server
mid-stream. Set `SCCACHE_IDLE_TIMEOUT=0` at workflow level, not task
level — release LTO links run inside the `cargo` invocation, not as
a separate moon task, so task-level env does not reach the link
step:

```yaml
env:
  SCCACHE_IDLE_TIMEOUT: '0'
jobs:
  ci:
    steps:
      - run: moon ci
```

---

## 9. The toolchain-install step: prototools, setup-toolchain, the three strategies

Source: https://moonrepo.dev/docs/proto + https://moonrepo.dev/docs/config/toolchain
+ https://github.com/moonrepo/setup-toolchain.

Failure-mode anchor: `moon-toolchain-prototools-drift`. in production
on 2026-03-19 had five toolchain churn commits in one hour.

There are three documented bootstrap strategies. Mixing them is the
cause of the churn.

### Strategy A — Manual rustup before moon

```yaml
- uses: actions/checkout@v4
  with: { fetch-depth: 0 }
- uses: dtolnay/rust-toolchain@stable
  with:
    toolchain: '1.90.0'
    components: 'clippy, rustfmt'
- uses: moonrepo/setup-toolchain@v0
  with:
    auto-install: false
  env:
    MOON_SKIP_SETUP_TOOLCHAIN: 'rust'
    MOON_TOOLCHAIN_FORCE_GLOBALS: 'rust'
- run: moon ci
```

Use when: you have a hard pinning requirement that proto's resolution
does not satisfy, or when sccache + rustup tighter coupling matters.

### Strategy B — Proto auto-install (the v2 default)

```yaml
- uses: actions/checkout@v4
  with: { fetch-depth: 0 }
- uses: moonrepo/setup-toolchain@v0
  with:
    auto-install: true
- run: moon ci
```

With `.prototools` as the source of truth:

```toml
# .prototools
rust = "1.90.0"
node = "22.14.0"
pnpm = "10.0.0"
```

Use when: you want the simplest possible CI surface and `.prototools`
is the workspace version pin everyone agrees on.

### Strategy C — moon v2 native toolchain config

```yaml
- uses: actions/checkout@v4
  with: { fetch-depth: 0 }
- uses: moonrepo/setup-toolchain@v0
- run: moon ci
```

With `.moon/toolchains.yml` as the source of truth:

```yaml
# .moon/toolchains.yml
rust:
  version: '1.90.0'
  components: ['clippy', 'rustfmt']
node:
  version: '22.14.0'
```

Use when: you want moon to own toolchain provisioning end-to-end.

### Detection grep — run before editing anything

```bash
grep -l setup-rust .github/workflows/    # is strategy A in play?
cat .prototools 2>/dev/null              # is .prototools the pin?
cat .moon/toolchains.yml 2>/dev/null     # is toolchains.yml the pin?
cat rust-toolchain.toml 2>/dev/null      # rustup will honour this regardless
```

The combination identifies the active strategy. Editing across
strategies is a migration, not a one-line fix.

### Single source of truth

The Rust toolchain version lives in exactly one of:

- `.prototools`
- `.moon/toolchains.yml`
- `rust-toolchain.toml` (rustup honours this independently of moon)

If two or more exist with different pins, that is the bug. Resolve
before doing anything else.

### Env vars

Source: https://moonrepo.dev/docs/how-it-works/action-graph.

- `MOON_SKIP_SETUP_TOOLCHAIN=true` — skip the `SetupToolchain` action
  entirely.
- `MOON_SKIP_SETUP_TOOLCHAIN=<tool>` (e.g., `rust`, `node`) — skip
  for a specific toolchain only.
- `MOON_SKIP_SETUP_TOOLCHAIN=<tool>:<version>` — scope by version.
- `MOON_TOOLCHAIN_FORCE_GLOBALS=<tool>` — force moon to use the
  globally-installed binary on PATH rather than the proto-installed
  version. Useful inside Alpine Docker layers and Strategy A.

`MOON_SKIP_SETUP_RUST` is NOT a documented form. It does not take
effect. Use `MOON_SKIP_SETUP_TOOLCHAIN=rust`.

### sccache install step

If `RUSTC_WRAPPER=sccache` is set anywhere, add this step before
`moon ci`:

```yaml
- uses: mozilla-actions/sccache-action@v0.0.9
```

Evidence the cache is intentional: presence of `SCCACHE_GCS_*`,
`SCCACHE_S3_*`, or `SCCACHE_REDIS_*` env blocks in workflow or task
env. If you see these, the fix when sccache breaks is to install
sccache, not to unset `RUSTC_WRAPPER`.

---

## 10. Reporting and observability (run-report-action, ci-retrospect, ci-booster)

Source: https://moonrepo.dev/docs/guides/ci ("Reporting run
results") + https://github.com/moonrepo/run-report-action.

### moonrepo/run-report-action

Posts a `moon ci` summary as a PR comment and workflow summary. Runs
regardless of overall job result.

```yaml
- run: moon ci
- uses: moonrepo/run-report-action@v1
  if: success() || failure()
  with:
    access-token: ${{ secrets.GITHUB_TOKEN }}
```

### Community alternatives

Documented at the bottom of the canon CI page:

- `appthrust/moon-ci-retrospect` — Displays the results of a moon ci
  run in a more readable fashion.
- `kymckay/moon-ci-booster` — Displays failing moon ci tasks as
  comments with error logs directly on the pull request.

These are community-maintained; vet versions and supply chain before
adoption.

### Local diagnostic commands

When the agent needs to understand a CI failure from a transcript:

```bash
# What did affected detection compute? (moon query emits JSON by default)
moon query projects --affected --base "$MOON_BASE" --head "$MOON_HEAD" | jq

# What is the action graph for a specific target?
moon action-graph users-service:build-release --json | jq

# What is the resolved task config (after inheritance)?
moon task users-service:build-release --json | jq

# What changed? (--json is not a moon query flag; output is already JSON)
moon query changed-files --status modified | jq
```

---

## 11. v2.1 and v2.2 features that replace older patterns

Sources verified via npm + https://moonrepo.dev/blog/moon-v2.1 (March
16, 2026) and https://moonrepo.dev/blog/moon-v2.2 (April 13, 2026).
Latest version as of 2026-05-14 is **2.2.4** per
`npm view @moonrepo/cli version`.

### v2.1 highlights (2.1.0 - 2.1.4, March 2026)

| Feature | Replaces / addresses | Failure mode |
|---|---|---|
| `moon exec --plan` | Hand-rolled dry-run scripts | `moon-affected-detection-misses-targets` — use `--plan` to see what `moon ci` would do before it runs. |
| `affectedFiles.filter`, `ignoreProjectBoundary`, `passDotWhenNoResults` (3 new settings) | Per-task manual gating | Refines step-2 affected computation. Especially `passDotWhenNoResults: true` for tasks that should run on the whole repo when no affected files are detected. |
| `runInSyncPhase` task option | Pre-task setup tasks bolted into `deps` | Cleaner toolchain bootstrap, less inheritance abuse. |
| `inheritAliases` and `installDependencies` per-toolchain | Cross-language toolchain interference | Reduces toolchain-drift surface in monorepos. |
| Improved local/remote env detection (Codespaces, Gitpod) | Hard-coded `CI=true` exports | Step 1 base-detection improvements. |
| Duplicate project aliases no longer hard error | Workspace-onboarding friction | — |
| Fixed MCP `generate` tool JSON schema | Codegen integration breakage | — |

### v2.2 highlights (2.2.0 - 2.2.4, April 2026)

| Feature | Replaces / addresses | Failure mode |
|---|---|---|
| **Background daemon** (`unstable_daemon`, `moon daemon {start,stop,status}`) | Cold-start project-graph rebuild on every invocation | Latency in step 4 (action graph generation). Opt-in while unstable. |
| **`experiments.asyncGraphBuilding`** | Single-threaded graph build | 100-170% faster graph builds on large monorepos. |
| **`experiments.asyncAffectedTracking`** | Sequential affected computation | Reduces step 2 latency. |
| `MOON_PIPELINE_AUTO_CLEAN_CACHE`, `MOON_PIPELINE_CACHE_LIFETIME`, `MOON_PIPELINE_KILL_PROCESS_THRESHOLD` (new pipeline env vars) | Hand-rolled cache cleanup scripts | Step 7 stats and step 6 process management. |
| Graph JSON format changed (integer node IDs + separate `data` object) | Old shape for `moon action-graph --json` etc. | Any tooling parsing the old shape needs updating. |
| Proto 0.56.x bundled; automatic retry on transient rate-limit errors (3x exponential backoff) | Manual retry loops on flaky proto installs | Step 5 toolchain install reliability. |
| PowerShell tasks use `-EncodedCommand` rather than `-Command` | Special-char escaping bugs on Windows | Affects `windowsShell: 'pwsh'` users only. |
| pnpm v10 multi-document lockfile parsing fixed in 2.2.1 | Frontend monorepo break on pnpm 10 | Affects pnpm-10 frontends in same workspace. |
| Older `experiments.fasterGlobWalk` and `experiments.gitV2` stabilised and removed | Opt-in experiment flags | Cleanup. |

### Features verified absent via the cascade on 2026-05-14

The four claims below were each checked against the canonical command
references and the CHANGELOG / release pages for 2.1.0–2.2.4. All
four are **rebutted**: moon does not ship these as of 2.2.4.

- **`moon ci --fail-on-no-affected`** — **rebutted**. Not listed on
  https://moonrepo.dev/docs/commands/ci nor on
  https://moonrepo.dev/docs/commands/exec (where most `moon ci` flags
  are inherited from); not in the CHANGELOG for 2.1.0–2.2.4. The
  fail-fast contract for affected-detection no-ops remains a
  CI-wrapper concern (see Rule 1, fix #4): emit `exit 1` from the CI
  script when `moon query projects --affected | jq '.projects | length'`
  is `0` on a non-empty diff.
- **`moon ci --explain` / `moon ci --dry-run`** — **rebutted**. Neither
  flag is listed on the `moon ci` or `moon exec` command pages. The
  closest documented equivalent is `moon exec --plan <path>` (v2.1.0+),
  which loads an execution plan from a JSON file rather than emitting
  one for dry-run inspection. For "what would moon do?" diagnostics,
  the canonical primitives remain `moon query projects --affected`,
  `moon query tasks --affected`, `moon action-graph <target> --json`,
  and `moon task <project>:<task> --json`.
- **New `moon query` schema in 2.1/2.2** — **rebutted**. Release notes
  for 2.1.0–2.2.4 call out no `moon query` subcommand or schema
  additions (CHANGELOG mentions only the 2.2.1 graph-visualizer fix
  after the v2.2 action-graph JSON change). The output schema of
  `moon query projects` remains `{ projects: Project[], options:
  QueryOptions }`. Important correction: **there is no `--json` flag
  on any `moon query` subcommand**. JSON is the default output. Prior
  drafts of this skill referenced `--json` repeatedly; this has been
  corrected throughout.
- **Direct S3 / GCS remote-cache backends without bazel-remote in
  front** — **rebutted, but with a refinement**. The
  `.moon/workspace.yml::remote.api` setting accepts two values:
  `grpc` (default, gRPC REAPI per
  https://github.com/bazelbuild/remote-apis) and `http` (Bazel HTTP
  caching protocol per https://bazel.build/remote/caching#http-caching).
  The `host:` setting accepts `grpc(s)://` and `http(s)://` schemes.
  Neither value exposes S3, GCS, or other cloud-object-store backends
  natively in moon 2.2.4; if those are the required transport,
  bazel-remote (`buchgr/bazel-remote-cache`) is the canonical
  front-end that bridges them to one of the two supported protocols.

### Pattern replacements

- **Old**: hand-rolled bash to enumerate affected projects via
  `git diff` and parse paths. **New**: `moon query projects --affected`
  (canonical, JSON-by-default, present since at least v2.0). The fact
  that this remains "new to users" is an ergonomics problem, not a
  missing feature.
- **Old**: rebuild project graph on every `moon` invocation.
  **New (opt-in)**: `unstable_daemon` keeps the graph warm.
- **Old**: parse `moon action-graph --json` with the old node shape.
  **New (required in 2.2)**: update parsers to the integer-id +
  separate-`data` shape.

---

## 12. Worked example: PR validate workflow

A real PR-validate workflow for a Rust monorepo, drawn from the
canonical docs and adapted to the user's Rust-service-deploys-via-image-push
topology. Demonstrates: explicit MOON_BASE, fetch-depth: 0, sccache
install, fast-fail probe, run-report-action.

```yaml
# .github/workflows/pr-validate.yml
name: 'PR Validate'

on:
  pull_request:

concurrency:
  group: pr-${{ github.event.pull_request.number }}
  cancel-in-progress: true

env:
  MOON_BASE: ${{ github.event.pull_request.base.sha }}
  MOON_HEAD: ${{ github.event.pull_request.head.sha }}
  CARGO_TERM_COLOR: 'always'
  SCCACHE_GHA_ENABLED: 'true'
  SCCACHE_IDLE_TIMEOUT: '0'
  RUSTC_WRAPPER: 'sccache'
  MOON_REMOTE_HOST: 'grpcs://cache.depot.dev'

jobs:
  validate:
    name: 'Validate (shard ${{ matrix.shard }})'
    runs-on: 'ubuntu-latest'
    strategy:
      fail-fast: false
      matrix:
        shard: [0, 1, 2, 3]
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - uses: mozilla-actions/sccache-action@v0.0.9

      - uses: moonrepo/setup-toolchain@v0
        with:
          auto-install: true

      - name: 'Probe moon remote cache'
        run: |
          if ! timeout 25 grpcurl -plaintext "${MOON_REMOTE_HOST#grpcs://}" \
              grpc.health.v1.Health/Check 2>/dev/null; then
            echo "moon remote cache unreachable; falling back to local"
            echo "MOON_REMOTE_HOST=" >> $GITHUB_ENV
            echo "MOON_REMOTE_TOKEN=" >> $GITHUB_ENV
          fi

      - name: 'Fail-fast on no affected with non-empty diff'
        run: |
          changed=$(git diff --name-only "$MOON_BASE..$MOON_HEAD" | wc -l)
          affected=$(moon query projects --affected | jq '.projects | length')
          if [[ "$changed" -gt 0 && "$affected" -eq 0 ]]; then
            echo "ERROR: $changed file(s) changed but moon resolved 0 affected projects."
            echo "This is failure mode moon-affected-detection-misses-targets."
            exit 1
          fi

      - name: 'moon ci'
        run: moon ci --job ${{ matrix.shard }} --job-total 4

      - uses: moonrepo/run-report-action@v1
        if: success() || failure()
        with:
          access-token: ${{ secrets.GITHUB_TOKEN }}
```

`.moon/tasks/rust.yml` for this workflow:

```yaml
tasks:
  check:
    command: 'cargo check --all-features'
    options: { runInCI: true }

  lint:
    command: 'cargo clippy --all-targets --all-features -- -D warnings'
    options: { runInCI: true }

  test:
    command: 'cargo nextest run --lib'   # unit only; integration tests live elsewhere
    options: { runInCI: true }

  fmt:
    command: 'cargo fmt --check'
    options: { runInCI: true }

  build-release:
    command: 'cargo build --release --package $project'
    deps: ['^:check']
    outputs: ['target/release/$project']
    options:
      runInCI: 'affected'
      mergeArgs: 'replace'

  docker-push:
    command: 'bash scripts/docker-push.sh $project'
    deps: ['~:build-release']
    options:
      runInCI: false           # deploy lane only
```

---

## 13. Worked example: deploy workflow

The deploy lane runs on push to `main`. It must NOT use bare `moon ci`
because `docker-push` is `runInCI: false`. It uses `moon run` after
materialising the affected set via `moon query`. After image push,
ArgoCD ImageUpdater detects the new tag and syncs.

```yaml
# .github/workflows/deploy.yml
name: 'Deploy'

on:
  push:
    branches: [main]

env:
  ZERO_SHA: '0000000000000000000000000000000000000000'
  MOON_BASE: >-
    ${{
      (github.event.before != '' && github.event.before != '0000000000000000000000000000000000000000' && github.event.before) ||
      'origin/main~1'
    }}
  MOON_HEAD: ${{ github.sha }}

jobs:
  resolve-affected:
    name: 'Resolve affected services'
    runs-on: 'ubuntu-latest'
    outputs:
      affected: ${{ steps.q.outputs.affected }}
    steps:
      - uses: actions/checkout@v4
        with: { fetch-depth: 0 }
      - uses: moonrepo/setup-toolchain@v0
      - id: q
        name: 'moon query'
        run: |
          affected=$(moon query projects --affected \
            | jq -c '[.projects[] | select(.layer == "application") | .id]')
          echo "affected=$affected" >> $GITHUB_OUTPUT
          echo "Affected: $affected"

  build-and-push:
    name: 'Build & push ${{ matrix.service }}'
    needs: resolve-affected
    if: needs.resolve-affected.outputs.affected != '[]'
    runs-on: 'ubuntu-latest'
    strategy:
      fail-fast: false
      matrix:
        service: ${{ fromJSON(needs.resolve-affected.outputs.affected) }}
    steps:
      - uses: actions/checkout@v4
        with: { fetch-depth: 0 }
      - uses: moonrepo/setup-toolchain@v0
        with:
          auto-install: true

      - name: 'Build release binary'
        run: moon run ${{ matrix.service }}:build-release

      - name: 'Docker push'
        env:
          REGISTRY: ghcr.io/acme
          ENV: prod
          DOCKER_IMAGE: ghcr.io/acme/prod/acme-${{ matrix.service }}
        run: moon run ${{ matrix.service }}:docker-push

      - name: 'Verify pushed tag matches deploy manifest'
        run: |
          # Failure-mode anchor: moon-project-id-image-name-divergence.
          # ArgoCD app manifest must reference the same last-segment image name.
          deployed=$(yq '.spec.source.kustomize.images[0]' \
            argocd/applications/${{ matrix.service }}/application.yaml \
            | awk -F: '{print $1}' | awk -F/ '{print $NF}')
          built="acme-${{ matrix.service }}"
          if [[ "$deployed" != "$built" ]]; then
            echo "ERROR: deploy manifest references '$deployed', built '$built'"
            exit 1
          fi

  notify-argocd:
    needs: build-and-push
    if: needs.resolve-affected.outputs.affected != '[]'
    runs-on: 'ubuntu-latest'
    steps:
      - name: 'Wait for ArgoCD ImageUpdater sync'
        run: |
          # ImageUpdater polls every 2 min by default; bound the wait.
          sleep 180
          echo "ArgoCD ImageUpdater should have picked up the new tag."
```

`services/users/moon.yml`:

```yaml
id: 'users-service'
layer: 'application'
stack: 'backend'
dependsOn: ['shared-types', 'shared-events']
tasks:
  build-release:
    command: 'cargo build --release --package users-service'
    deps: ['^:check']
    outputs: ['target/release/users-service']
    options:
      runInCI: 'affected'
      mergeArgs: 'replace'

  docker-push:
    command: 'bash scripts/docker-push.sh $project'
    deps: ['~:build-release']
    env:
      DOCKER_IMAGE: '${REGISTRY}/${ENV}/acme-$project'   # canonical materialisation site
    options:
      runInCI: false
```

Note: `$project` resolves to the moon `id:` (`users-service`), not the
Cargo `[package].name`. If they diverge, override `--package` in the
task explicitly.

---

## 14. Anti-patterns observed in production

Each row maps a failure mode from the user's corpus to the wrong
pattern, the right pattern from this guide, and a smoke-test diff
that proves the fix.

### Anti-pattern 1: `Resolved targets: 0` ignored on a real diff

- **Failure mode**: `moon-affected-detection-misses-targets`.
- **Evidence**: a production transcript, a service
  service did not rebuild despite changed files (observed in production).
- **Wrong pattern**: silent rerun, or `if: success()` swallowing the
  empty resolve.
- **Right pattern**: section 6 + section 12 fail-fast snippet. If
  `git diff` is non-empty AND `moon query projects --affected` returns
  `[]`, `exit 1`.
- **Smoke test**: locally run
  `moon query projects --affected --base <ci-base> --head <ci-head>`
  with the exact SHAs CI saw; resolved list must be non-empty.

### Anti-pattern 2: bare `moon ci` over-fires `build-release` on every PR

- **Failure mode**: `moon-task-run-in-ci-misconfiguration`.
- **Evidence**: an observed production incident — "exclude build
  tasks from moon ci to prevent disk exhaustion".
- **Wrong pattern**: `build-release` inherits `runInCI: true` from
  `.moon/tasks/rust.yml`.
- **Right pattern**: section 2. Set `runInCI: 'affected'` for
  `build-release` (this user's topology) so it only fires when the
  service is actually affected. Or `runInCI: false` and invoke from a
  separate deploy lane.
- **Smoke test**: open a no-op docs-only PR; `moon ci --plan` should
  not list any `build-release` action.

### Anti-pattern 3: `moon ci :build-release` runs nothing

- **Failure mode**: `moon-task-run-in-ci-misconfiguration` (silent-skip
  shape).
- **Evidence**: an observed production incident — "restore deploy
  image builds — moon ci filters runInCI on explicit targets".
- **Wrong pattern**: `moon ci :build-release` on the deploy lane,
  expecting it to bypass `runInCI: false`. It does not. Canon:
  "moon ci will still only run them if affected by changed files, but
  will still filter with the runInCI option."
- **Right pattern**: section 4. Use `moon run :build-release
  --affected` or `moon exec :build-release --affected --ci` from the
  deploy lane.
- **Smoke test**: deploy lane should run at least one build per
  affected service; check `moon run` logs, not `moon ci` logs.

### Anti-pattern 4: deploy manifest references a stale image name

- **Failure mode**: `moon-project-id-image-name-divergence`.
- **Evidence**: an observed production incident — three image-name realignments over six weeks.
- **Wrong pattern**: assume `id:` in `moon.yml` automatically matches
  the Cargo `[package].name` and the ArgoCD `kustomize.images` entry.
- **Right pattern**: section 13 "Verify pushed tag matches deploy
  manifest" step. Grep all four names at PR-merge time; assert
  equality.
- **Smoke test**:
  ```bash
  grep -RH '^id:' services/*/moon.yml \
    | awk -F: '{print $3}' | sort -u > /tmp/moon-ids
  grep -A1 '^\[package\]' services/*/Cargo.toml \
    | grep '^name = ' | awk -F\" '{print $2}' | sort -u > /tmp/cargo-names
  diff /tmp/moon-ids /tmp/cargo-names
  ```
  Empty diff is the pass condition (modulo `_` vs `-`).

### Anti-pattern 5: toolchain churn from mixing bootstrap strategies

- **Failure mode**: `moon-toolchain-prototools-drift`.
- **Evidence**: in production, five churn commits in one
  hour (incident references, ...).
- **Wrong pattern**: drop `setup-rust`, re-add it, set
  `MOON_SKIP_SETUP_TOOLCHAIN`, change `.prototools`, change
  `.moon/toolchains.yml`, all in a 60-minute panic.
- **Right pattern**: section 9 detection grep first. Identify which
  of the three strategies the repo is on. Commit to one. Migrate
  explicitly, not as a "fix".
- **Smoke test**: only one of `.prototools`, `.moon/toolchains.yml`,
  `rust-toolchain.toml` has a Rust pin (or all three agree).

### Anti-pattern 6: oscillating cache toggle

- **Failure mode**: `moon-remote-cache-and-sccache-flakiness`.
- **Evidence**: an in-corpus incident —
  disable-then-re-enable cycle.
- **Wrong pattern**: cache flake -> disable cache -> build slows ->
  re-enable cache -> next flake -> disable again. Each toggle is a
  commit; over six weeks this generates noise without fixing anything.
- **Right pattern**: section 8 fast-fail probe. Keep cache
  configured. Probe before `moon ci`. Unset env vars on probe
  failure. Build degrades silently to local-only.
- **Smoke test**: kill the cache server temporarily, push a branch;
  CI should complete with a single warning, not hang for 45 minutes.

### Anti-pattern 7: workspace `[[bin]]` collision

- **Failure mode**: `rust-workspace-binary-name-collision`.
- **Evidence**: an in-corpus incident —
  three rename commits, the third 28 minutes after the second.
- **Wrong pattern**: name every service's worker binary
  `projection_worker`. Workspace builds collide at link time. The
  symptom is "rename one, discover two more" — fix one binary, the
  next conflict surfaces.
- **Right pattern**: service-prefix every `[[bin]]` name —
  `users_projection_worker`, not `projection_worker`. Same for
  `event_worker`, `consumer`, `migrator`, etc.
- **Smoke test**:
  ```bash
  cargo metadata --format-version 1 \
    | jq -r '.packages[].targets[] | select(.kind[] == "bin") | .name' \
    | sort | uniq -d
  # Empty output is the pass condition.
  ```

### Anti-pattern 8: per-service `CARGO_TARGET_DIR` to dodge collisions

- **Failure mode**: corollary of `rust-workspace-binary-name-collision`.
- **Wrong pattern**: set per-service `CARGO_TARGET_DIR` overrides to
  isolate each service's build artifacts. Defeats workspace
  incremental compilation, defeats remote-cache reuse, and leaves the
  binary-name collision live in any single-service build.
- **Right pattern**: fix the names. Service-prefix all `[[bin]]`.
- **Smoke test**: removing per-service `CARGO_TARGET_DIR` overrides
  does not produce link errors in `cargo build --workspace --bins`.

---

## Quick-reference cheat sheet

| Need | Command / config |
|---|---|
| What did moon think changed? | `git diff --name-only "$MOON_BASE..$MOON_HEAD"` |
| What did moon decide is affected? | `moon query projects --affected` (JSON by default) |
| What would `moon ci` do? | `moon exec :<task> --affected --plan` (v2.1.0+) |
| What is the resolved task config? | `moon task <project>:<task> --json` |
| Why did this action run? | `moon action-graph <project>:<task> --json` |
| Inspect a cache hash | `moon hash <hash>` |
| Compare two cache hashes | `moon hash <hash1> <hash2>` |
| Shard across N jobs | `moon ci --job <i> --job-total <N>` |
| Override base/head | `MOON_BASE=<ref> MOON_HEAD=<ref> moon ci` or `--base` / `--head` |
| Skip toolchain bootstrap for one tool | `MOON_SKIP_SETUP_TOOLCHAIN=rust` |
| Force PATH binaries | `MOON_TOOLCHAIN_FORCE_GLOBALS=rust` |
| Include graph relations (v1 behaviour) | `MOON_INCLUDE_RELATIONS=true` or `--include-relations` |
| Enable async graph (v2.2+) | `experiments.asyncGraphBuilding: true` in `.moon/workspace.yml` |
| Daemon (v2.2+, unstable) | `moon daemon start` / `unstable_daemon: true` |
