# moon CI long-form walkthrough

Worked examples and deep-dive material for the patterns referenced from `workflows.md`. The six symptom-keyed workflows are the entry point; this guide expands on the load-bearing patterns when more detail is helpful.

Contents:

1. [Task inheritance via `inheritedBy` and CI-lane tags](#1-task-inheritance-via-inheritedby-and-ci-lane-tags)
2. [Revision comparison: MOON_BASE, MOON_HEAD, github.event.before](#2-revision-comparison-moon_base-moon_head-githubeventbefore)
3. [Remote caching configuration and fail-fast probes](#3-remote-caching-configuration-and-fail-fast-probes)
4. [Toolchain install: prototools, setup-toolchain, three strategies](#4-toolchain-install-prototools-setup-toolchain-three-strategies)
5. [Worked example: PR validate workflow](#5-worked-example-pr-validate-workflow)
6. [Worked example: deploy workflow with image-push + ArgoCD sync](#6-worked-example-deploy-workflow-with-image-push--argocd-sync)

---

## 1. Task inheritance via `inheritedBy` and CI-lane tags

> **Rule (mandatory, repo-wide).** Every file under `.moon/tasks/**/*` MUST begin with an `inheritedBy:` block declaring at least one condition. Projects opt in via explicit `tags:` in their `moon.yml`. No top-level `.moon/tasks.yml`. No toolchain-named files without an `inheritedBy:` block.

Source: https://moonrepo.dev/docs/concepts/task-inheritance and https://moonrepo.dev/docs/config/tasks#inheritedby (v2.0.0+).

### Why mandatory

Implicit inheritance creates compounding chaos:

1. **You cannot read a single project's `moon.yml` and know which tasks fire.** The actual task set is a fan-in from `.moon/tasks.yml`, every `.moon/tasks/<anything>.yml` that matches the project's language / toolchain / stack / layer / tags / files, and the project's own `moon.yml`. Each contributor is merged across six axes (`mergeArgs`, `mergeDeps`, `mergeEnv`, `mergeInputs`, `mergeOutputs`, `mergeToolchains`), each defaulting to append. Tracing "where did `build-release` get `--release` from?" becomes a six-file archaeology pass.
2. **`runInCI` inheritance silently flips polarity per merge.** A task that's `runInCI: 'affected'` globally and `runInCI: true` locally collapses to the local value because `runInCI` is scalar. A reader who only sees the global file assumes `'affected'` and is wrong; a reader who only sees the local does not know the global ever set anything. Both produce silent over-fire (PR validate schedules `docker-push`) or silent skip (`moon ci :build-release` returns success without running).
3. **Affected detection traverses the merged graph, not the file you're reading.** If `build-release`'s `deps: ['^:check']` is inherited globally and the project's local override uses `mergeDeps: 'replace'`, the propagation edge silently disappears.

Explicit `inheritedBy:` + explicit `tags:` reverses every one of these. The project's `tags:` line is the single source of truth for what files inherit to it, and the file's `inheritedBy:` is the single source of truth for which projects it applies to. The mental model collapses to one direction, both ends typed.

### The architecture: CI-lane tags for orchestration, toolchain conditions for developer ergonomics

The policy: configure as much as possible at workspace level via **CI-lane tags**; only developer ergonomic commands (`dev`, `lint`, `build`, `check`) ride on toolchain conditions because those are language-shaped, not lane-shaped.

#### Prebuilt CI-lane tag files (one per CI lane)

```yaml
# .moon/tasks/ci-pull-request.yml
inheritedBy:
  tags: ['ci-pull-request']
tasks:
  lint:
    command: 'cargo clippy --all-targets -- -D warnings'
    options: { runInCI: 'affected' }
  typecheck:
    command: 'cargo check --all-targets --workspace'
    options: { runInCI: 'affected' }
  test-unit:
    command: 'cargo nextest run --lib'
    options: { runInCI: 'affected' }
```

```yaml
# .moon/tasks/ci-merge-develop.yml
inheritedBy:
  tags: ['ci-merge-develop']
tasks:
  test-integration:
    command: 'cargo nextest run --test "*"'
    options: { runInCI: 'affected' }
  build-debug:
    command: 'cargo build --workspace'
    options: { runInCI: 'affected' }
  docker-push-dev:
    command: 'docker buildx build --push --tag $DOCKER_IMAGE:develop-$MOON_HEAD .'
    deps: ['^:check', '~:build-debug']
    options: { runInCI: 'affected' }
```

```yaml
# .moon/tasks/ci-merge-production.yml
inheritedBy:
  tags: ['ci-merge-production']
tasks:
  build-release:
    command: 'cargo build --release --workspace'
    deps: ['^:check']
    options:
      runInCI: 'affected'
      mergeArgs: 'replace'   # never accumulate args across inheritance
  docker-push-prod:
    command: 'docker buildx build --push --tag $DOCKER_IMAGE:production-$MOON_HEAD .'
    deps: ['^:check', '~:build-release']
    options: { runInCI: 'affected' }
  argocd-sync:
    command: '.ci/argocd-sync.sh $DOCKER_IMAGE production-$MOON_HEAD'
    deps: ['~:docker-push-prod']
    options: { runInCI: 'affected' }
```

#### Developer-command tag files (one per toolchain)

```yaml
# .moon/tasks/rust-developer.yml
inheritedBy:
  toolchains: ['rust']
tasks:
  dev:
    command: 'cargo watch -x run'
    options: { runInCI: false }   # explicit; never inherit
  build:
    command: 'cargo build'
    options: { runInCI: false }
  lint:
    command: 'cargo clippy'
    options: { runInCI: false }   # the CI lane has its own stricter `lint`
  check:
    command: 'cargo check'
    options: { runInCI: false }
```

Same shape for `.moon/tasks/typescript-developer.yml` with `inheritedBy: { toolchains: ['node'] }`, `.moon/tasks/python-developer.yml`, etc.

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
# the developer command line.
```

Reading the four lines above tells you: this project runs the full PR / develop / prod CI lane and inherits Rust developer commands. To find out exactly which tasks fire, you read four workspace files (three CI lanes + one toolchain) -- never six.

### Forbidden patterns

| Pattern | Why forbidden | What to do instead |
|---|---|---|
| `.moon/tasks.yml` (top-level shared file) | Applies to every project; no opt-out without per-project exclude lists | Split into tag-conditioned files with explicit `inheritedBy:` |
| `.moon/tasks/rust.yml` (toolchain-named, no `inheritedBy:` block) | Matches every project with `toolchain: rust` whether they want it or not | Rename to `rust-developer.yml` AND add `inheritedBy: { toolchains: ['rust'] }`; restrict scope to developer commands |
| Any task with `runInCI:` unset | Inheritance silence -- defaults to `true`; produces "Resolved targets: 0" surprises | Set `runInCI` explicitly to `true`, `false`, or `'affected'` |
| Project `moon.yml` with `tasks:` overrides of inherited tasks | Each override is a new merge axis; one slip on `mergeArgs` and the graph silently changes | Move the override into a new tag-conditioned file; project opts in via tag |

### Per-project opt-out

When a project legitimately needs to skip one inherited task:

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

### Smoke test

```bash
# 1. Forbidden-default check: every file under .moon/tasks/ must declare inheritedBy
scripts/audit-inheritance.sh

# 2. What tasks does this project have after inheritance?
moon project users --json | jq '.tasks | keys'

# 3. What tasks will moon ci actually run on the current diff?
moon query tasks --affected | jq '.tasks[] | select(.project.id == "users") | .id'
```

If either output surprises you, the inheritance is doing something you did not declare. That is the bug, not the symptom.

### Merge mechanics: the duplicate-args trap

When a per-project `moon.yml` overrides a task inherited from `.moon/tasks/<lang>.yml`, the default merge strategy is **append**, not **replace**.

```yaml
# .moon/tasks/rust.yml (or workspace tag file)
tasks:
  build-release:
    command: 'cargo build --release'

# services/users/moon.yml
tasks:
  build-release:
    command: 'cargo build --release --package users-service'
```

Default merge produces argv: `cargo build --release --package users-service --release` -- duplicated `--release`.

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

A duplicate `mergeOutputs:` key inside `options:` -- typed twice by accident in the same file -- has caused real silent-override incidents. YAML parsers take the last value with no warning.

---

## 2. Revision comparison: MOON_BASE, MOON_HEAD, github.event.before

Source: https://moonrepo.dev/docs/guides/ci ("Comparing revisions").

`moon ci` detects base and head automatically from the CI provider (via the `ci_env` Rust crate). If detection fails, it falls back to `vcs.defaultBranch` for base and `HEAD` for head.

Override precedence (highest first):

1. `MOON_BASE` / `MOON_HEAD` environment variables.
2. `--base <ref>` / `--head <ref>` CLI flags.
3. Auto-detected from CI provider.
4. `vcs.defaultBranch` + `HEAD`.

### Rule: always be explicit; never rely on auto-detection

The auto-detection tier silently picks `github.event.before` on GitHub, which is empty or the all-zero SHA on first push to a new branch and on force-pushes -- both produce the `Resolved targets: 0` silent no-op.

**Always pass `--base` and `--head` to `moon ci` explicitly, OR set `MOON_BASE` and `MOON_HEAD` env vars before the invocation.**

```yaml
- name: 'moon ci (always explicit)'
  env:
    MOON_BASE: ${{ env.RESOLVED_BASE }}   # computed in a prior step
    MOON_HEAD: ${{ github.sha }}
  run: 'moon ci --base "$MOON_BASE" --head "$MOON_HEAD"'
```

Use env vars when the same base/head feeds multiple `moon` invocations in one job; use CLI flags when only one invocation needs them. The two mechanisms are interchangeable; the load-bearing rule is "never let moon auto-detect on GitHub".

### The github.event.before trap

GitHub Actions exposes `github.event.before` as the previous commit on `push` events. Two values silently break affected detection:

1. **Empty string** -- happens when the event payload omits `before`.
2. **All-zero SHA** `0000000000000000000000000000000000000000` -- happens on first push to a new branch and on force-pushes.

If you assign `MOON_BASE: ${{ github.event.before }}` without guarding both cases, moon either crashes or computes `HEAD..HEAD` and reports `Resolved targets: 0`.

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

### Per-event-type recommendations

| Event | MOON_BASE | MOON_HEAD |
|---|---|---|
| `pull_request` | `github.event.pull_request.base.sha` | `github.event.pull_request.head.sha` |
| `push` (regular) | `github.event.before`, guarded against empty AND zero-SHA | `github.sha` |
| `push` (first / force) | Default branch tip (`main`) or `HEAD~1` | `github.sha` |
| `workflow_dispatch` | Default branch tip | `HEAD` |

### Merge commits need first-parent

On merge commits, `github.event.before` points to the *old* target-branch HEAD, which is the wrong base. Detect merge commits and use `HEAD~1`:

```bash
PARENTS=$(git rev-list --count HEAD~1..HEAD --parents | head -1 | wc -w)
if [ "$PARENTS" -ge 3 ]; then
  MOON_BASE=$(git rev-parse HEAD~1)
else
  MOON_BASE=${{ github.event.before }}
fi
```

### Fetch-depth: 0 is mandatory

Without full git history moon cannot diff `MOON_BASE..MOON_HEAD`. `actions/checkout` defaults to depth 1. v2.0.3 disabled the hard error for shallow checkouts; the error became a silent `Resolved targets: 0`.

```yaml
- uses: actions/checkout@v4
  with: { fetch-depth: 0 }
```

---

## 3. Remote caching configuration and fail-fast probes

Source: https://moonrepo.dev/docs/config/workspace#remote and https://moonrepo.dev/docs/guides/remote-cache.

### Configuration schema

```yaml
# .moon/workspace.yml
remote:
  host: 'grpcs://cache.depot.dev'        # grpc(s):// or http(s)://
  auth:
    token: 'DEPOT_TOKEN'                  # env var name (NOT the literal token)
    headers:
      'X-Depot-Org': 'my-org'
  cache:
    compression: 'zstd'
    localReadOnly: false                  # v1.40.0+
```

Supported backends per v2 docs:

- **gRPC** to any Bazel Remote Execution (REAPI) compliant server (`grpcs://`, `grpc://`).
- **Bazel HTTP caching** protocol (`http(s)://`).
- **Self-hosted bazel-remote** (`buchgr/bazel-remote-cache`).
- **Depot** (managed; `grpcs://cache.depot.dev`).

Direct S3 / GCS / Redis backends are NOT in the documented schema as of 2.2.4. If those are the required transport, bazel-remote is the canonical front-end.

### Conditional enable via env var

```bash
MOON_REMOTE_HOST=grpcs://cache.depot.dev moon ci
```

The env var takes precedence over the file. Useful for self-hosted runners where the cache URL differs from what's in `workspace.yml`.

### Fast-fail probe (recommended)

Keep the cache configured. Add a probe that fails fast when the cache is unreachable, then degrades to local-only. Do **not** toggle the cache config across commits -- oscillation evidence is a bug signal, not a fix.

```yaml
- name: 'Probe moon remote cache'
  run: |
    if ! timeout 25 grpcurl -plaintext "${MOON_REMOTE_HOST#grpcs://}" \
        grpc.health.v1.Health/Check 2>/dev/null; then
      echo "moon remote cache unreachable; falling back to local"
      echo "MOON_REMOTE_HOST=" >> $GITHUB_ENV
      echo "MOON_REMOTE_TOKEN=" >> $GITHUB_ENV
    fi
```

Alternatives when `grpcurl` is unavailable: `nc -zw5 cache.depot.dev 443`.

`localReadOnly: true` (camelCase, per https://moonrepo.dev/docs/config/workspace#localreadonly) is the documented fallback when the cache is healthy but you want builds to read from remote without writing.

### sccache vs moon remote cache

Two distinct caches that often get conflated:

- **moon remote cache** caches task outputs (binaries, test artifacts) keyed by moon's hash of inputs + command + toolchain.
- **sccache** caches rustc compilation artifacts (object files) keyed by source hash + flags.

Both can be enabled simultaneously; they cache at different layers.

### sccache + GHA cache service

`SCCACHE_GHA_ENABLED=true` backs sccache with the GitHub Actions cache. When GHA cache returns 503, sccache fails save/restore with HTTP errors from `https://acghub*.actions.githubusercontent.com/`. This is a separate failure from moon remote cache being unreachable.

The right fix is to keep sccache configured and let it degrade silently when GHA cache 5xxs -- not to remove `RUSTC_WRAPPER=sccache`.

### sccache + release LTO

`[unverified-canon]` -- sccache wraps `rustc`, not the linker. LTO work happens at link time; sccache cannot cache it, so the wrapper adds overhead without proportional savings on link-heavy crates. Moon's docs do not characterise this trade-off; the rule is corpus-grounded.

```yaml
# Unset for release builds; LTO link time is paid only once
tasks:
  build-release:
    command: 'cargo build --release'
    env:
      RUSTC_WRAPPER: ''
```

### SCCACHE_IDLE_TIMEOUT at workflow level

Default is 10 minutes; long-running release-LTO links exceed it and kill the sccache server mid-stream. Set at workflow level -- release-LTO links run inside the `cargo` invocation, not as a separate moon task, so task-level env does not reach the link step:

```yaml
env:
  SCCACHE_IDLE_TIMEOUT: '0'
```

---

## 4. Toolchain install: prototools, setup-toolchain, three strategies

Source: https://moonrepo.dev/docs/proto, https://moonrepo.dev/docs/config/toolchain, https://github.com/moonrepo/setup-toolchain.

There are three documented bootstrap strategies for Rust in moon CI. Mixing them is the cause of the churn.

### Strategy A -- Manual rustup before moon

```yaml
- uses: actions/checkout@v4
  with: { fetch-depth: 0 }
- uses: dtolnay/rust-toolchain@1.90.0     # no semver tags on this action; pin by channel or version
  with:
    components: 'clippy, rustfmt'
- uses: moonrepo/setup-toolchain@v0
  with:
    auto-install: false
- name: 'Tell downstream moon invocations not to re-install rust'
  run: |
    echo "MOON_SKIP_SETUP_TOOLCHAIN=rust" >> $GITHUB_ENV
    echo "MOON_TOOLCHAIN_FORCE_GLOBALS=true" >> $GITHUB_ENV    # boolean, NOT a tool name
- run: moon ci
```

Use when: hard pinning requirement that proto's resolution does not satisfy, or sccache + rustup tighter coupling matters.

### Strategy B -- Proto auto-install (the v2 default)

```yaml
- uses: actions/checkout@v4
  with: { fetch-depth: 0 }
- uses: moonrepo/setup-toolchain@v0
  with:
    auto-install: true
- run: moon ci
```

With `.prototools` as source of truth:

```toml
rust = "1.90.0"
node = "22.14.0"
pnpm = "10.0.0"
```

Use when: simplest CI surface; `.prototools` is the workspace pin everyone agrees on.

### Strategy C -- moon v2 native

```yaml
- uses: actions/checkout@v4
  with: { fetch-depth: 0 }
- uses: moonrepo/setup-toolchain@v0
- run: moon ci
```

With `.moon/toolchains.yml` as source of truth:

```yaml
rust:
  version: '1.90.0'
  components: ['clippy', 'rustfmt']
node:
  version: '22.14.0'
```

Use when: moon owns toolchain provisioning end-to-end.

### Detection grep -- run before editing anything

```bash
scripts/audit-toolchain.sh
# or manually:
grep -l setup-rust .github/workflows/    # is strategy A in play?
cat .prototools 2>/dev/null              # is .prototools the pin?
cat .moon/toolchains.yml 2>/dev/null     # is toolchains.yml the pin?
cat rust-toolchain.toml 2>/dev/null      # rustup honours this regardless of moon
```

Editing across strategies is a migration, not a one-line fix.

### Single source of truth

The Rust toolchain version lives in exactly one of `.prototools`, `.moon/toolchains.yml`, `rust-toolchain.toml`. If two or more exist with different pins, that is the bug.

### Env vars

These are moon-CLI env vars (consumed by the moon binary in `crates/actions/src/actions/setup_toolchain.rs` and `crates/toolchain/src/lib.rs`); they take effect when downstream `moon` invocations run, not when `setup-toolchain` runs as a standalone CI step.

| Env var | Effect |
|---|---|
| `MOON_SKIP_SETUP_TOOLCHAIN=true` | Skip the `SetupToolchain` action entirely. |
| `MOON_SKIP_SETUP_TOOLCHAIN=<tool>` (e.g. `rust`, `node`) | Skip for a specific toolchain. |
| `MOON_SKIP_SETUP_TOOLCHAIN=<tool>:<version>` | Scope by version. |
| `MOON_TOOLCHAIN_FORCE_GLOBALS=true` | Force moon to use PATH binaries rather than proto-installed ones. Parsed as boolean (`as_bool`); `=true` or `=1`. **Setting to a tool name like `=rust` parses as falsy** -- common bug. |

`MOON_SKIP_SETUP_RUST` is NOT a documented form; verified absent from the moon source. Use `MOON_SKIP_SETUP_TOOLCHAIN=rust`.

### sccache install step

If `RUSTC_WRAPPER=sccache` is set anywhere, add the install step **before** `moon ci`. `mozilla-actions/sccache-action` does **not** auto-set `RUSTC_WRAPPER=sccache` -- it only installs the binary and exports `SCCACHE_PATH` and GHA cache tokens. Export the wrapper explicitly:

```yaml
- uses: mozilla-actions/sccache-action@v0.0.10
- run: echo "RUSTC_WRAPPER=sccache" >> $GITHUB_ENV
```

Evidence the cache is intentional: presence of `SCCACHE_GCS_*`, `SCCACHE_S3_*`, or `SCCACHE_REDIS_*` env blocks in workflow or task env. If you see these, the fix when sccache breaks is to install sccache, not to unset `RUSTC_WRAPPER`.

---

## 5. Worked example: PR validate workflow

A complete PR-validate workflow for a Rust monorepo. Demonstrates: explicit MOON_BASE, fetch-depth: 0, sccache install, fast-fail cache probe, fail-fast on no-affected, sharding, run-report-action.

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
  SCCACHE_IDLE_TIMEOUT: '0'        # workflow-level: release-LTO links exceed the 600s default and would kill the server
  RUSTC_WRAPPER: 'sccache'         # sccache-action does NOT set this automatically
  MOON_REMOTE_HOST: 'grpcs://cache.depot.dev'

jobs:
  validate:
    name: 'Validate (shard ${{ matrix.shard }})'
    runs-on: 'ubuntu-latest'
    strategy:
      fail-fast: false        # do not let one shard kill siblings on the PR lane
      matrix:
        shard: [0, 1, 2, 3]
    steps:
      - uses: actions/checkout@v4
        with: { fetch-depth: 0 }

      - uses: mozilla-actions/sccache-action@v0.0.10

      - uses: moonrepo/setup-toolchain@v0
        with: { auto-install: true }

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
            echo "Failure mode: moon-affected-detection-misses-targets."
            exit 1
          fi

      - name: 'moon ci'
        run: moon ci --job ${{ matrix.shard }} --job-total 4

      - uses: moonrepo/run-report-action@v1
        if: success() || failure()
        with: { access-token: ${{ secrets.GITHUB_TOKEN }} }
```

`.moon/tasks/ci-pull-request.yml`:

```yaml
inheritedBy:
  tags: ['ci-pull-request']

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
```

---

## 6. Worked example: deploy workflow with image-push + ArgoCD sync

The deploy lane runs on push to `main`. It must NOT use bare `moon ci` because `docker-push` is `runInCI: false`. It uses `moon run` after materialising the affected set via `moon query`. After image push, ArgoCD ImageUpdater detects the new tag and syncs.

```yaml
# .github/workflows/deploy.yml
name: 'Deploy'

on:
  push:
    branches: [main]

env:
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
      fail-fast: false        # one shard's flake should not kill siblings on a release
      matrix:
        service: ${{ fromJSON(needs.resolve-affected.outputs.affected) }}
    steps:
      - uses: actions/checkout@v4
        with: { fetch-depth: 0 }
      - uses: moonrepo/setup-toolchain@v0
        with: { auto-install: true }

      - name: 'Build release binary'
        run: moon run ${{ matrix.service }}:build-release

      - name: 'Docker push'
        env:
          REGISTRY: ghcr.io/acme
          ENV: production
          DOCKER_IMAGE: ghcr.io/acme/production/acme-${{ matrix.service }}
        run: moon run ${{ matrix.service }}:docker-push

      - name: 'Verify pushed tag matches deploy manifest'
        run: |
          # Failure-mode: moon-project-id-image-name-divergence
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
          sleep 180     # ImageUpdater polls every 2 min by default
          echo "ArgoCD ImageUpdater should have picked up the new tag."
```

`services/users/moon.yml`:

```yaml
id: 'users-service'
layer: 'application'
stack: 'backend'
dependsOn: ['shared-types', 'shared-events']

tags:
  - 'ci-pull-request'
  - 'ci-merge-develop'
  - 'ci-merge-production'

toolchain:
  default: 'rust'

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
      runInCI: false           # deploy lane only; never moon ci
```

Note: `$project` resolves to the moon `id:` (`users-service`), not the Cargo `[package].name`. If they diverge, override `--package` in the task command and grep all four name sites with `scripts/audit-name-drift.sh`.

### CI workflow shape rules

- `cancel-in-progress: true` on `pull_request` only -- never on `push` to default branches, or rapid merges cancel in-flight release jobs.
- `fail-fast: false` on deploy matrices -- one shard's flake should not kill the others mid-release.
- Shards are not load-balanced. `moon ci --job N --job-total T` splits work into shards but does not balance cost. Don't size shard count by *number of projects*; think about expected *wall time per shard*.
- Do not run raw `cargo` alongside moon in the same pipeline. A shadow `pr-ci.yml` using direct `cargo` + `Swatinem/rust-cache` next to a moon pipeline causes duplicated work, divergent caching, and confusion about which checks are authoritative.

For pre-commit hooks, the canonical pattern is `moon run :format --affected --status staged` -- this is the one that actually works with moon's affected resolution against the git index.
