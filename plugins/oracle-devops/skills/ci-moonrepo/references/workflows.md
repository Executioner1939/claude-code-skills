# moon CI failure-mode workflows

Six symptom-keyed decision trees mined from production incidents across three Rust monorepos. Each workflow names the failure mode, lists the trigger keywords / log lines, walks the diagnosis as a sequence of conditional steps, and ends with a smoke test that proves the fix.

These workflows are scoped to the canonical "Rust services deployed via image push, ArgoCD ImageUpdater syncs the cluster" topology. Other topologies may legitimately differ; flag the assumption when it bites.

---

## §1 -- Affected-detection no-op

**Failure mode id:** `moon-affected-detection-misses-targets`

**Symptoms.** `Resolved targets: 0`; `CAUTION No tasks affected by changed files`; "build not started"; "shards finish in seconds and nothing gets built or pushed"; missed releases after a force-push or first-push to a branch; library edits that don't rebuild downstream services.

### Diagnosis

**Step 1 -- check whether base/head are explicit.**

Read the workflow that invokes `moon ci`. If it relies on auto-detection (no `--base`/`--head` flag, no `MOON_BASE`/`MOON_HEAD` env), that is almost certainly the bug.

Why: auto-detection on GitHub resolves to `github.event.before`. On first push to a new branch and on force-pushes this is empty or the all-zero SHA `0000000000000000000000000000000000000000`. Both produce a silent `HEAD..HEAD` diff and `Resolved targets: 0`.

**Fix:** make base/head explicit. Per event type:

| Event | MOON_BASE | MOON_HEAD |
|---|---|---|
| `pull_request` | `github.event.pull_request.base.sha` | `github.event.pull_request.head.sha` |
| `push` (regular) | `github.event.before`, guarded against empty AND zero-SHA | `github.sha` |
| `push` (first / force) | default-branch tip | `github.sha` |
| `workflow_dispatch` | default-branch tip | `HEAD` |

The guarded `push` expression in GitHub Actions:

```yaml
env:
  MOON_BASE: >-
    ${{
      (github.event_name == 'pull_request' && github.event.pull_request.base.sha) ||
      (github.event_name == 'push' && github.event.before != '' && github.event.before != '0000000000000000000000000000000000000000' && github.event.before) ||
      'main'
    }}
  MOON_HEAD: ${{ github.sha }}
```

**Step 2 -- check `fetch-depth`.**

`actions/checkout` defaults to depth 1. Without history moon cannot diff `MOON_BASE..MOON_HEAD`. v2.0.3 disabled the hard error for shallow checkouts, so the symptom is now silent `Resolved targets: 0` rather than a clear failure.

**Fix:** `actions/checkout@v4` with `fetch-depth: 0`.

**Step 3 -- materialise the affected set locally with the SHAs CI saw.**

```bash
moon query projects --affected --base <ci-base-sha> --head <ci-head-sha>
```

`moon query` emits JSON by default. There is no `--json` flag; using one is silently ignored. If the resolved list is non-empty here but empty in CI, the bug is upstream of moon (probably `fetch-depth` or base/head resolution). If empty locally too, go to step 4.

**Step 4 -- check the task-graph propagation edge.**

A library edit will not propagate to a downstream service's `build-release` unless the task graph declares the edge. Read the relevant task file:

```bash
moon task <service>:build-release --json | jq '.deps'
```

If the result does not include `^:check` (or an equivalent upstream-walking dep), affected-detection cannot reach the library from the service's task.

**Fix:** add `^:check` to the load-bearing tasks in `.moon/tasks/<tag>.yml` or per-project `moon.yml`:

```yaml
tasks:
  build-release:
    command: 'cargo build --release --package $project'
    deps: ['^:check']    # this is the load-bearing edge
```

**Step 5 -- check for CI-written files that pollute the working tree.**

moon diffs the working tree, not the git index. If CI writes `gha-creds-*.json` (from `google-github-actions/auth`), `.argocd-source-*.yaml`, or any other untracked file before `moon ci` runs, those land in the changed-file list and skew affected resolution.

**Fix:** gitignore everything CI writes.

**Step 6 -- check for merge-commit base.**

On merge commits, `github.event.before` points to the *old* target-branch HEAD, which is the wrong base. Detect merge commits and use `HEAD~1` (first parent) as the base:

```bash
PARENTS=$(git rev-list --count HEAD~1..HEAD --parents | head -1 | wc -w)
if [ "$PARENTS" -ge 3 ]; then
  MOON_BASE=$(git rev-parse HEAD~1)
else
  MOON_BASE=${{ github.event.before }}
fi
```

### Fail-fast contract

There is no built-in `moon ci --fail-on-no-affected` flag as of 2.2.4. The fail-fast contract is a CI-wrapper concern:

```bash
changed=$(git diff --name-only "$MOON_BASE..$MOON_HEAD" | wc -l)
affected=$(moon query projects --affected | jq '.projects | length')
if [[ "$changed" -gt 0 && "$affected" -eq 0 ]]; then
  echo "ERROR: $changed file(s) changed but moon resolved 0 affected projects."
  exit 1
fi
```

### Smoke test

Locally, with the exact SHA pair CI saw:

```bash
moon query projects --affected --base <ci-base> --head <ci-head> | jq '.projects | length'
```

Non-zero is the pass condition.

### Note on touched-files resolution under merge-commit bases

**Verified primary-source diagnosis** (subagent against moonrepo/moon HEAD on 2026-05-17). The "exec vs query asymmetry" framing in earlier versions of this skill is **wrong** -- both `moon exec --affected` and `moon query projects --affected` flow through `crates/affected/affected_tracker.rs` over the same `changed_files` set produced by `crates/app/src/queries/touched_files.rs`. There is no asymmetry; if touched-files comes back populated, both commands see the same set.

**The real bug surface** is upstream of `--downstream`. `crates/vcs/src/git/git_client.rs:530-548` (`get_changed_files_between_revisions`) resolves a merge-base via `git merge-base <base> <head>`, then runs `exec_diff(merge_base_revision, "")` -- which issues `git diff <merge_base>` (one argument) rather than `git diff <merge_base>..<head>`. The head is silently dropped. On a merge commit with `MOON_BASE = first parent` and `HEAD = merge commit`, `git merge-base` returns the first parent, so the effective diff is `git diff first_parent` -- base vs **working tree**, not base vs merge commit. On a clean CI checkout the working tree equals the merge commit and the diff happens to be correct; on a non-clean tree, or when `--head` is explicitly something other than `HEAD`, the touched-files set drifts.

**Upstream tracking**: open issue [moonrepo/moon#2216](https://github.com/moonrepo/moon/issues/2216) "moon query touched-files --base X --head Y silently runs git diff X"; in-flight fix PR [moonrepo/moon#2513](https://github.com/moonrepo/moon/pull/2513) patches `git_client.rs` and `changed_files.rs` to honour both refs. Until the fix lands, **verify with `moon query touched-files --base <BASE> --head <HEAD>`** that the file set matches `git diff --name-only "$BASE..$HEAD"` before relying on any `--affected` / `--downstream` result.

Related earlier precedent: [#2083](https://github.com/moonrepo/moon/issues/2083) (closed in 1.40) -- `MOON_BASE` was silently ignored by `query projects --affected` while honoured by `query touched-files`. Establishes that the two surfaces have desynchronised on base-resolution before, but in the opposite direction to the legacy claim. [#1971](https://github.com/moonrepo/moon/issues/1971) (Azure DevOps detached-HEAD) and [#1412](https://github.com/moonrepo/moon/issues/1412) (Gitlab merge-train) document related CI-provider-specific base-resolution traps.

---

## §2 -- runInCI inheritance trap

**Failure mode id:** `moon-task-run-in-ci-misconfiguration`

**Symptoms.** Either shape:

- **Over-fire**: PR validate accidentally schedules `build-release` / `docker-push`; "exclude build tasks from moon ci to prevent disk exhaustion"; 45-minute PR runs.
- **Silent skip**: `moon ci :build-release` returns success without running the task; "restore deploy image builds -- moon ci filters runInCI on explicit targets"; "missing releases".

### Why this happens

Canon, captured verbatim from https://moonrepo.dev/docs/guides/ci:

> "When providing targets, `moon ci` will still only run them if affected by changed files, but will still filter with the `runInCI` option."

`moon ci <targets>` is **additive, not narrowing**. Two filters apply in sequence: (1) affected-detection, (2) the `runInCI` option per task. Both must accept the task for it to run. Inheritance silence means a task accidentally inherits the wrong polarity.

### Diagnosis

**Step 1 -- enumerate what is actually scheduled.**

```bash
moon query tasks --affected | jq '.tasks[] | {project: .project.id, id: .id, runInCI: .options.runInCI}'
```

If unexpected tasks appear (build-release on PR), go to step 2. If expected tasks are missing (deploy lane no-ops), go to step 3.

**Step 2 -- diagnose the over-fire shape.**

For each surprising task, find the `runInCI` value by reading the resolved config:

```bash
moon task <project>:<task> --json | jq '.options.runInCI'
```

If it returns `true` (or nothing -- the implicit default for non-`dev/start/serve` tasks is `true`), the task fires on every affected PR. That is the bug.

**Fix:** set `runInCI` explicitly on every task in `.moon/tasks/**/*.yml` and per-project `moon.yml`. For the canonical Rust-service-deploys-via-image-push topology, the convention is:

| Task type | `runInCI` |
|---|---|
| `check`, `lint`, `test --lib`, `fmt` | `true` |
| `build-release` | `'affected'` (PR fires only when service affected) |
| `docker-push`, `deploy`, `argocd-sync` | `false` -- invoke from a separate deploy lane via `moon run` / `moon exec` |
| `dev`, `serve`, integration tests | `false` |

**Step 3 -- diagnose the silent-skip shape.**

If a deploy lane runs `moon ci :build-release` and nothing happens, the explicit-target filter does not bypass `runInCI`. Both filters still apply.

**Fix:** use `moon run` or `moon exec` for deploy lanes, never `moon ci :<task>`:

```yaml
# Deploy lane
- run: moon run :build-release --affected
- run: moon run :docker-push --affected
```

Or, if you want `moon ci`'s affected-detection plumbing:

```yaml
- run: moon exec :build-release --affected --ci
```

### Inheritance discipline (load-bearing)

Every file under `.moon/tasks/**/*` must begin with an `inheritedBy:` block declaring at least one condition (`tags`, `toolchains`, `layers`, `stacks`, `languages`, `files`). Projects opt in via explicit `tags:` in their `moon.yml`. No top-level `.moon/tasks.yml`. No toolchain-named files without an `inheritedBy:` block.

Why: implicit inheritance creates compounding chaos. The actual task set per project is a fan-in from multiple files merged across six axes (`mergeArgs`, `mergeDeps`, `mergeEnv`, `mergeInputs`, `mergeOutputs`, `mergeToolchains`), each defaulting to append. Tracing "where did `build-release` get `--release` from?" becomes archaeology.

The architecture: workspace orchestration via **CI-lane tags** (`ci-pull-request`, `ci-merge-develop`, `ci-merge-production`); developer commands via toolchain conditions (`rust-developer.yml` with `inheritedBy: { toolchains: ['rust'] }`).

Forbidden patterns:

| Pattern | Why forbidden |
|---|---|
| `.moon/tasks.yml` (top-level) | Applies to every project; no opt-out without per-project exclude lists |
| `.moon/tasks/rust.yml` without `inheritedBy:` | Matches every Rust project whether they want it or not |
| Any task with `runInCI:` unset | Inheritance silence -- defaults to `true` |
| Per-project `tasks:` overrides of inherited tasks | Each override is a new merge axis; one slip and the graph silently changes. Move the override into a new tag-conditioned file; the project opts in via tag. |

Full inheritance pattern with worked YAML for the three CI lanes is in `ci-guide.md` §3.

### Merge mechanics trap

When a per-project `moon.yml` overrides an inherited task's `args` or `outputs`, the default merge is **append**, not replace:

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

Resolved argv: `cargo build --release --package users-service --release` -- duplicated `--release`.

**Fix:** set explicit merge strategies on the overriding task:

```yaml
tasks:
  build-release:
    command: 'cargo build --release --package users-service'
    options:
      mergeArgs: 'replace'
      mergeOutputs: 'replace'
```

A duplicate `mergeOutputs:` key inside `options:` (typed twice by accident) has caused real silent-override incidents -- YAML parsers take the last value with no warning.

### Smoke test

```bash
# 1. The forbidden-default check
grep -L '^inheritedBy:' .moon/tasks/*.yml   # any output is a violation

# 2. The explicit-runInCI check
moon project <id> --json | jq '.tasks[] | select(.options.runInCI == null)'
# empty output is the pass condition

# 3. The PR no-op check
git checkout -b probe ; touch docs/README.md ; git commit -am probe
moon query tasks --affected | jq '.tasks[] | select(.id == "build-release")'
# empty output is the pass condition for a docs-only diff
```

---

## §3 -- Project-id / Cargo / Docker / ArgoCD name drift

**Failure mode id:** `moon-project-id-image-name-divergence`

**Symptoms.** "Build green but prod still serving old behaviour"; "CI went green but dev env still serving old behaviour"; "ArgoCD ImageUpdater not picking up new images"; `cargo build --package $project` fails with "package ID specification 'X' did not match any packages".

### The invariant

When adding, renaming, or migrating a service, **four** names must line up:

1. `id:` in `moon.yml` (defaults to directory name if omitted)
2. `[package].name` in `Cargo.toml`
3. The Docker image tag's last path segment (what CI's `docker-push` actually pushes)
4. The deploy manifest's image reference (Kustomize `kustomize.images`, ArgoCD ImageUpdater `imageName`, Helm `image.repository` last segment)

The `$project` token resolves to (1), not (2). If they diverge, `cargo build --package $project` fails; bare `cargo build` may succeed with a stale binary if a `[[bin]]` override is in play -- green build, broken deploy.

### Diagnosis

**Step 1 -- grep all four locations.**

```bash
# (1) moon project ids
grep -RH '^id:' services/*/moon.yml \
  | awk -F: '{print $3}' | sort -u > /tmp/moon-ids

# (2) Cargo package names
grep -A1 '^\[package\]' services/*/Cargo.toml \
  | grep '^name = ' | awk -F\" '{print $2}' | sort -u > /tmp/cargo-names

# (3) Docker image last segments -- canonical materialisation site is DOCKER_IMAGE env on docker-push
grep -RH 'DOCKER_IMAGE' services/*/moon.yml \
  | sed 's|.*acme-||; s|"||g' | sort -u > /tmp/docker-names

# (4) Deploy manifest image references
find argocd/applications -name 'application.yaml' -exec \
  yq '.spec.source.kustomize.images[0]' {} \; \
  | awk -F: '{print $1}' | awk -F/ '{print $NF}' | sort -u > /tmp/deploy-names

diff /tmp/moon-ids /tmp/cargo-names
diff /tmp/cargo-names /tmp/docker-names
diff /tmp/docker-names /tmp/deploy-names
```

Empty diffs are the pass condition (modulo `_` vs `-` substitution rules; canonical convention is dashes throughout).

**Step 2 -- canonical materialisation site.**

`DOCKER_IMAGE` env on the `docker-push` task in per-project `moon.yml` is the single source of truth for the image tag:

```yaml
# services/users/moon.yml
tasks:
  docker-push:
    env:
      DOCKER_IMAGE: '${REGISTRY}/${ENV}/acme-$project'
```

The last path segment after the final `/` (here `acme-users-service`, if `id: users-service`) is what the deploy manifest must reference.

**Step 3 -- verify in the deploy lane.**

Add this verification step to the deploy workflow after `docker-push`:

```yaml
- name: 'Verify pushed tag matches deploy manifest'
  run: |
    deployed=$(yq '.spec.source.kustomize.images[0]' \
      argocd/applications/${{ matrix.service }}/application.yaml \
      | awk -F: '{print $1}' | awk -F/ '{print $NF}')
    built="acme-${{ matrix.service }}"
    if [[ "$deployed" != "$built" ]]; then
      echo "ERROR: deploy manifest references '$deployed', built '$built'"
      exit 1
    fi
```

### Scaffold-time discipline

When scaffolding a new service or renaming one:

1. Grep all four locations before merging.
2. If names cannot be identical (e.g. moon convention is dashes, Cargo convention is also dashes but the runtime uses underscores), set `id:` explicitly in `moon.yml` to force alignment.
3. Override the `build-release` task's `command` with `--package <cargo-name>` and `outputs` with the right binary path. Override all four task fields where the name appears: `check`, `test`, `lint`, `build-release`. Easy to fix three and miss the fourth.

### Smoke test

`grep`s above all empty. After deploy: the pushed image SHA shows up in prod, not just "build green".

### $projectDescription does not exist

`$projectDescription` is **not** a real token. A Docker label built with it gives you an empty string in production. If you need data moon doesn't expose, pass it via `env:` or Docker `--build-arg`. Supported tokens are listed in `moon-cheatsheet.md`.

---

## §4 -- Toolchain-bootstrap strategy drift

**Failure mode id:** `moon-toolchain-prototools-drift`

**Symptoms.** `linker not found`; `rustc mismatch`; `sccache: command not found`; oscillating commits flipping `MOON_SKIP_*` / `MOON_TOOLCHAIN_*` env vars (in one production incident, five toolchain churn commits in one hour).

### The three strategies (do not mix)

There are three documented strategies for Rust in moon CI. Mixing them is the cause of the churn.

| Strategy | Workflow shape | Pin location |
|---|---|---|
| **A -- Manual rustup** | `actions/checkout` → `dtolnay/rust-toolchain@<channel-or-version>` (or `moonrepo/setup-rust@v1`) → `moonrepo/setup-toolchain@v0` with `auto-install: false` and (when downstream `moon` invocations are present) `MOON_SKIP_SETUP_TOOLCHAIN=rust` + `MOON_TOOLCHAIN_FORCE_GLOBALS=true` | `rust-toolchain.toml` (rustup's source of truth) or workflow yaml |
| **B -- Proto auto-install** (v2 default) | `actions/checkout` → `moonrepo/setup-toolchain@v0` with `auto-install: true` | `.prototools` |
| **C -- moon v2 native** | `actions/checkout` → `moonrepo/setup-toolchain@v0` | `.moon/toolchains.yml` |

`setup-rust` (latest `v1.3.0`) reads its version from `RUSTUP_TOOLCHAIN`, then `rust-toolchain.toml`, then legacy `rust-toolchain`, then its own inputs. It does **not** read `.prototools`. `dtolnay/rust-toolchain` has no semver tags; pin by channel or version (`@stable`, `@1.89.0`, `@nightly-2025-01-01`). `setup-toolchain` is at `v0.6.4` (also available as branch `v0`).

### Diagnosis

**Step 1 -- run the detection grep first. Identify the active strategy before editing anything.**

```bash
grep -l setup-rust .github/workflows/    # presence => strategy A is in play
cat .prototools 2>/dev/null              # pin source for strategy B
cat .moon/toolchains.yml 2>/dev/null     # pin source for strategy C
cat rust-toolchain.toml 2>/dev/null      # rustup honours this regardless of moon
```

**Step 2 -- single source of truth.**

The Rust toolchain version lives in **exactly one** of: `.prototools`, `.moon/toolchains.yml`, `rust-toolchain.toml`. If two or more exist with different pins, that is the bug; resolve before doing anything else.

**Step 3 -- use the real env-var names.**

`MOON_SKIP_SETUP_RUST` is **not** a real env var; it is silently ignored (verified by grep across `moonrepo/moon` HEAD on 2026-05-17). These are moon-CLI env vars consumed by the moon binary itself (in `crates/actions/src/actions/setup_toolchain.rs` and `crates/toolchain/src/lib.rs`); they take effect when downstream `moon` invocations run, **not** when the setup-toolchain action runs as a standalone CI step.

| Env var | Effect |
|---|---|
| `MOON_SKIP_SETUP_TOOLCHAIN=true` | Skip the SetupToolchain action entirely |
| `MOON_SKIP_SETUP_TOOLCHAIN=rust` (or `node`, etc.) | Skip for a specific toolchain |
| `MOON_SKIP_SETUP_TOOLCHAIN=rust:1.90.0` | Scope by version |
| `MOON_TOOLCHAIN_FORCE_GLOBALS=true` | Force moon to use PATH binaries instead of proto-installed ones. **Parsed as boolean** (`as_bool` in `crates/toolchain/src/lib.rs`); use `true` or `1`, not a tool name |

**Important value correction:** `MOON_TOOLCHAIN_FORCE_GLOBALS=rust` parses as **falsy** because moon's source treats it as a boolean. The skill's earlier drafts used `=rust`; that is wrong. Use `=true`.

Setting `MOON_SKIP_SETUP_TOOLCHAIN=*` (broader than needed) has been observed to leave sccache stuck in `Local disk` mode instead of `ghac`. Don't go broader than necessary.

**Step 4 -- toolchains.yml `bins:` duplicates `.prototools`.**

If `.moon/toolchains.yml` has a Rust `bins:` list re-installing tools that `moonrepo/setup-rust` already provides, every CI run re-installs them via `cargo binstall` (slow, occasional 402 from `warehouse-clerk-tmp.vercel.app`).

**Fix:** version / components / targets in `.prototools` only. Keep `bins:` minimal or empty in CI. Never put `cargo-watch` or `sccache` in a CI-visible `bins:` list.

**Step 5 -- sccache prerequisite.**

If `RUSTC_WRAPPER=sccache` is set anywhere, add `mozilla-actions/sccache-action@v0.0.10` (latest as of 2026-05-17) as a step **before** `moon ci`. The action does **not** auto-set `RUSTC_WRAPPER=sccache`; it only installs the binary and exports `SCCACHE_PATH` and GHA cache tokens. Export `RUSTC_WRAPPER` explicitly:

```yaml
- uses: mozilla-actions/sccache-action@v0.0.10
- run: echo "RUSTC_WRAPPER=sccache" >> $GITHUB_ENV
```

Presence of `SCCACHE_GCS_*` / `SCCACHE_S3_*` / `SCCACHE_REDIS_*` env blocks is evidence the cache is intentional -- install sccache, do not unset the wrapper.

### Before changing any toolchain config

State which strategy the repo is on before proposing an edit. Cross-strategy changes are migrations, not one-line fixes. Worked Strategy A/B/C examples are in `ci-guide.md` §9.

### Smoke test

Only one of `.prototools` / `.moon/toolchains.yml` / `rust-toolchain.toml` has a Rust pin (or all three agree on the version). Detection grep before any edit. No `MOON_SKIP_SETUP_RUST` anywhere -- search-and-replace it to `MOON_SKIP_SETUP_TOOLCHAIN=rust`.

---

## §5 -- Remote cache / sccache flakiness and oscillation

**Failure mode id:** `moon-remote-cache-and-sccache-flakiness`

**Symptoms.** `moon ci` hangs indefinitely on gRPC connect; build wall time jumps from 8 to 45+ minutes; "cache server unreachable"; "we keep flipping this on and off"; sccache save/restore fails with HTTP 503; "no such file or directory" from cargo.

### Name the symptom precisely before toggling

Three sub-symptoms get conflated and toggled blindly. The wrong toggle re-triggers the same symptom hours later. A cache-toggle commit on a recently-toggled config is oscillation evidence (in one production incident, three disable/re-enable cycles in ~6 weeks).

| Sub-symptom | Evidence |
|---|---|
| **Remote moon cache server unreachable / slow** | `moon ci` hangs on gRPC connect for minutes; wall time 8 → 45+ min |
| **GHA cache service 5xx** (`SCCACHE_GHA_ENABLED=true`) | HTTP 503 from `https://acghub*.actions.githubusercontent.com/`; sccache save/restore fails |
| **`RUSTC_WRAPPER=sccache` set without sccache installed** | Every `cargo` invocation fails with "no such file or directory" |

Read the previous toggle's commit message before proposing the inverse toggle.

### Diagnosis

**Step 1 -- keep the cache configured; add a fast-fail probe.**

Right pattern, runs before `moon ci`:

```bash
if ! timeout 25 grpcurl -plaintext "${MOON_REMOTE_HOST#grpcs://}" \
    grpc.health.v1.Health/Check 2>/dev/null; then
  echo "moon remote cache unreachable; falling back to local"
  echo "MOON_REMOTE_HOST=" >> $GITHUB_ENV
  echo "MOON_REMOTE_TOKEN=" >> $GITHUB_ENV
fi
```

`nc -zw5 host port` is the alternative when `grpcurl` is unavailable.

`localReadOnly: true` (camelCase, per https://moonrepo.dev/docs/config/workspace#localreadonly) is the supported workspace.yml fallback when the cache is healthy but you want builds to read without writing.

**Step 2 -- assert sccache before invoking cargo.**

```bash
command -v sccache && sccache --version
```

If absent, either install via `mozilla-actions/sccache-action@v0.0.9` or unset `RUSTC_WRAPPER`. The right move depends on whether `SCCACHE_*` env blocks are present: if so, the cache is intentional and the fix is install; if not, the fix is unset.

**Step 3 -- check for sccache + release-LTO collision.**

sccache is registered as `RUSTC_WRAPPER`; it wraps `rustc`, never the linker. The architectural fact (verified against `mozilla/sccache/src/compiler/rust.rs` and `rust-lang/rust#71850`): sccache rejects the `bin`, `cdylib`, `dylib`, `proc-macro` crate types by design -- those invocations return `cannot_cache("crate-type", ...)` before any work is done. The final-binary crate (where fat/thin LTO actually runs) is therefore never cached, though dependency `rlib` crates still are. Net on a release-LTO build: the wrapper round-trip + hash overhead is paid on every rustc invocation but provides no benefit on the final link step.

The corpus pattern is to unset `RUSTC_WRAPPER` for `build-release` tasks specifically:

```yaml
tasks:
  build-release:
    command: 'cargo build --release --package $project'
    env:
      RUSTC_WRAPPER: ''
```

Keep sccache on for `check` / `test` / `lint` -- those have heavy dep-graph caching value. Turn it off for `build-release` where the unweighted dep-graph savings do not amortise the per-invocation wrapper overhead on link-heavy services.

Upstream issue refs: `rust-lang/rust#71850` is closed (2025-01-30, effectively wontfix for fat-LTO incremental reuse); `mozilla/sccache#236` is open since 2017 ("make sccache aware of incremental compilation").

**Step 4 -- `SCCACHE_IDLE_TIMEOUT` at workflow level, not task level.**

Default is 10 minutes. Release-LTO links exceed it and kill sccache mid-stream. Set `SCCACHE_IDLE_TIMEOUT=0` at workflow level -- release-LTO links run inside the `cargo` invocation, not as a separate moon task, so task-level env does not reach the link step:

```yaml
env:
  SCCACHE_IDLE_TIMEOUT: '0'
```

### Configuration schema

```yaml
# .moon/workspace.yml
remote:
  host: 'grpcs://cache.depot.dev'        # grpc(s):// or http(s)://
  auth:
    token: 'DEPOT_TOKEN'                  # env var name, NOT the token itself
  cache:
    compression: 'zstd'
    localReadOnly: false                  # v1.40.0+
```

Supported backends: gRPC REAPI (default), Bazel HTTP caching, self-hosted bazel-remote, Depot. Direct S3 / GCS backends are **not** in the documented schema as of 2.2.4; if required, front them with `buchgr/bazel-remote-cache`.

### Additional rules

- If the runner provider is Depot (or any cache-coupled runner), abandoning the runner also abandons the cache. Verify which subsystem is the actual flake before swapping.
- `cancel-in-progress: true` on push branches loses releases. Set it only on `pull_request`.
- `fail-fast: false` on deploy matrices -- one shard's flake shouldn't kill all the others mid-release.
- sccache jobserver deadlock (upstream sccache issue #1011, open 5+ years) can freeze under moon's parallel executor at high parallelism. Keep shards small.

### Smoke test

Kill the cache server temporarily, push a branch. CI should complete with a single warning, not hang for 45 minutes. The probe step's exit logs the fallback explicitly.

---

## §6 -- Workspace `[[bin]]` collision

**Failure mode id:** `rust-workspace-binary-name-collision`

**Symptoms.** A service deploys cleanly but the running pod produces wrong behaviour for *its own domain*: a users-service pod emitting achievements logic, friend-request black holes, missing-profile rows handled by the wrong handler. Or at build time: `[[bin]] name already defined`, "link error in CI", "duplicate symbol".

### Runtime-symptom path

If a service deploys cleanly but its pod misbehaves for its own domain, suspect a workspace `[[bin]]` collision **before** blaming the deploy manifest. Cargo's workspace builds resolve `[[bin]]` names in dependency order; a generic name (`projection_worker`, `event_worker`, `consumer`, `migrator`) defined in two crates means one wins and the other silently gets the wrong binary in `target/release/`.

### Diagnosis

**Step 1 -- assert binary-name uniqueness across the workspace.**

```bash
grep -nH '^\[\[bin\]\]' services/*/Cargo.toml
cargo metadata --format-version 1 \
  | jq -r '.packages[].targets[] | select(.kind[] == "bin") | .name' \
  | sort | uniq -d
```

Empty output from `uniq -d` is the pass condition.

**Step 2 -- assert moon project-id uniqueness.**

```bash
find . -name moon.yml -exec grep -H '^id:' {} \; \
  | awk -F: '{print $3}' | sort | uniq -d
```

Empty output is the pass condition.

### Fix

**Service-prefix every `[[bin]]` name in `Cargo.toml`.**

```toml
# services/users/Cargo.toml
[[bin]]
name = "users_projection_worker"   # NOT projection_worker
path = "src/bin/projection_worker.rs"

[[bin]]
name = "users_event_worker"        # NOT event_worker
path = "src/bin/event_worker.rs"
```

Same discipline for `consumer`, `migrator`, and any other boilerplate name.

Before merging a scaffold PR, run `cargo build --workspace --bins` (not just `--package <new-service>`) so the link-time collision is forced to surface.

### Anti-pattern preempt

**Per-service `CARGO_TARGET_DIR` overrides do not fix this.** They defeat workspace incremental compilation and remote-cache reuse, and leave the binary-name collision live in any single-service build. Fix the names.

### Scaffold-time pattern

The pattern "rename one colliding binary, build, discover two more colliding binaries" has happened in production (an in-corpus incident -- three rename commits, the third 28 minutes after the second). Fix the whole class in one PR. A scaffold-time lint (in the `rust-monorepo-orchestrator` sibling skill) catches this at service-creation time rather than at break-time.

### Smoke test

```bash
cargo metadata --format-version 1 \
  | jq -r '.packages[].targets[] | select(.kind[] == "bin") | .name' \
  | sort | uniq -d
```

Empty output is the pass condition. Run this in CI as a guard.

---

## Cross-cutting: when to use which command

| Need | Command |
|---|---|
| What did moon think changed? | `git diff --name-only "$MOON_BASE..$MOON_HEAD"` |
| What did moon decide is affected (projects)? | `moon query projects --affected` (JSON by default) |
| What did moon decide is affected (tasks)? | `moon query tasks --affected` (JSON by default) |
| What would `moon ci` do? | `moon exec :<task> --affected --plan` (v2.1.0+) |
| What is the resolved task config (post-inheritance)? | `moon task <project>:<task> --json` |
| Why did this action run? | `moon action-graph <project>:<task> --json` |
| Inspect / diff cache hashes | `moon hash <hash> [<other-hash>]` |
| Materialise projects for a deploy lane | `moon query projects --affected \| jq -r '.projects[].id'` |

**No `--json` flag on any `moon query` subcommand.** JSON is the default output. Adding `--json` is silently ignored.

## `[unverified-canon]` markers

These rules are corpus-grounded and not addressed by canonical moon docs as of 2026-05-14. Before asserting them as universal, run the verification cascade.

- §1 -- `moon exec --downstream` returning empty answers under merge-commit bases.
- §5 -- sccache cannot cache the release-LTO link step.
