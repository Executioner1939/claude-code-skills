---
name: ci-moonrepo
description: |
  moonrepo (moon) v2 expert -- workspace, tasks, CI/CD, Docker, remote caching, codegen, WASM toolchains, v1-to-v2 migration, plus six guards: affected-detection no-ops, runInCI inheritance traps, project-id / Cargo / Docker name drift, prototools-setup-toolchain churn, remote-cache and sccache flakiness, [[bin]] name collisions.
  Keywords: moon, moonrepo, moon.yml, .moon/, moon ci/run/exec/query/migrate, runInCI, MOON_*, .prototools, rust-toolchain.toml, setup-toolchain, setup-rust, mozilla-actions/sccache-action, sccache, RUSTC_WRAPPER, SCCACHE_*, Depot, $project, DOCKER_IMAGE, ArgoCD ImageUpdater, kustomize, [[bin]], CARGO_TARGET_DIR per-service.
  Affected-detection: "Resolved targets: 0", "No tasks affected by changed files", "build not started", "shards finish in seconds and nothing gets built or pushed", "task inheritance not granular enough".
  runInCI: "missing releases", "turn on fail fast for Moon", "separate moon job for PRs and one for builds", "build-release fires on PR".
  Name drift: "build green but prod unchanged", "CI went green but dev env still serving old behaviour", "argocd image updater not picking up new images".
  Toolchain: "linker not found", "rustc mismatch", "sccache: command not found".
  Cache: "CI hanging", "shard 1 hangs", "builds 8 min now 45+", "cache server unreachable", "oscillating", "we keep flipping this on and off".
  Binary collision: "wrong projection_worker", "[[bin]] name already defined", "link error in CI", "duplicate symbol".
paths:
  - "**/moon.yml"
  - "**/.moon/**"
  - "**/.prototools"
  - "**/rust-toolchain.toml"
  - "**/Cargo.toml"
  - "**/.github/workflows/*.yml"
  - "**/.github/workflows/*.yaml"
  - "**/argocd/**"
---

# moonrepo v2

moon is a monorepo management, orchestration, and build system written in Rust. Current latest is **v2.2.4** (April 2026), per `npm view @moonrepo/cli version` on 2026-05-14. v2.2 introduces the unstable background daemon and experimental async graph building; v2.1 introduced `moon exec --plan`, new `affectedFiles` settings, and `runInSyncPhase`. See `references/advanced.md` "Release notes" for the full v2.1 + v2.2 surface.

Target **v2 syntax** unless the user explicitly mentions v1. If v1-style config appears (`toolchain.yml` singular, `node.npm`, camelCase flags, `runner` instead of `pipeline`), flag it and point at `references/migration-v1-to-v2.md`.

Before debugging confusing moon behaviour, check `references/real-world-gotchas.md` for the catalogued landmines and `references/ci-guide.md` for the comprehensive moon-ci walkthrough (seven steps, runInCI semantics, revision comparison, parallelism, caching, toolchain strategies, worked examples, and the six failure modes mapped to anti-patterns).

## Production Failure-Mode Rules

These six rules are anchored on clustered failure modes mined from real transcripts and commit history across three production Rust monorepos. Each rule body is the one-sentence load-bearing directive; the full diagnostic procedure lives in `references/ci-guide.md` at the cited anchor.

### Rule 1 -- Verify `moon ci` actually resolved targets; never accept "Resolved targets: 0" on a real diff

[failure-mode: moon-affected-detection-misses-targets]

When `moon ci` reports `CAUTION No tasks affected by changed files` or `Resolved targets: 0` on a diff that obviously changed source code, treat it as a propagation bug, not as "nothing to do". `moon query projects --affected` is the canonical primitive for materialising the affected set (the subcommand emits JSON by default per https://moonrepo.dev/docs/commands/query/projects -- there is no `--json` flag). `moon exec --downstream` (documented at https://moonrepo.dev/docs/commands/exec, defaults to `--downstream=direct` when invoked via `moon ci`) has been anecdotally observed to return empty answers under merge-commit bases in the user's transcript corpus; canon does not address that specific failure surface and a targeted search of moonrepo/moon issues turned up no matching report [unverified-canon].

**Load-bearing fixes** (full diagnostic in `references/ci-guide.md` sections 4 and 5):

1. **Always pass `--base` and `--head` explicitly (or set `MOON_BASE` / `MOON_HEAD`); never rely on auto-detection.** The moon ci override precedence (per https://moonrepo.dev/docs/v2/guides/ci#comparing-revisions) is: (i) `MOON_BASE` / `MOON_HEAD` env vars, (ii) `--base <ref>` / `--head <ref>` CLI flags, (iii) auto-detected from the CI provider via the `ci_env` Rust crate, (iv) `vcs.defaultBranch` + `HEAD`. Auto-detection on GitHub resolves to `github.event.before`, which is the empty string or the all-zero SHA `0000000000000000000000000000000000000000` on first push to a new branch and on force-pushes -- both produce the "Resolved targets: 0" silent no-op. Always-explicit sidesteps the entire class of bugs. On `pull_request`, use `github.event.pull_request.base.sha`. On `push`, guard against empty AND zero-SHA before passing the value, or fall back to `vcs.defaultBranch`.
2. **Pin the task-graph edge with `^:check`.** A library touch will not propagate to a service's `build-release` unless `build-release` declares `deps: ['^:check']` (or equivalent dependency-pinning edge) in `.moon/tasks/<lang>.yml` or per-service `moon.yml`.
3. **Materialise the affected set** with `moon query projects --affected` before invoking deploy targets (output is JSON by default). Pass the result to `moon run` / `moon exec` explicitly rather than relying on `moon exec --downstream` chains.
4. **Fail-fast contract.** If `moon query projects --affected` returns an empty `projects` array on a non-empty changed-files list, the CI step must `exit 1`, not log a warning. (As of 2.2.4 moon ships no built-in `--fail-on-no-affected` flag -- the fail-fast contract is a CI-wrapper concern.)

Smoke test: run `moon query projects --affected --base <ci-base-sha> --head <ci-head-sha>` locally with the exact SHA pair CI saw, and confirm the resolved list matches expectation.

### Rule 2 -- Make every task's `runInCI` explicit; never inherit it by accident

[failure-mode: moon-task-run-in-ci-misconfiguration]

`moon ci <targets>` is **additive, not narrowing**. Canon: "When providing targets, `moon ci` will still only run them if affected by changed files, but will still filter with the `runInCI` option." (https://moonrepo.dev/docs/v2/guides/ci). Two failure shapes follow:

- **Over-fire**: PR validate accidentally schedules `build-release` / `docker-push` because they inherit `runInCI: true` from `.moon/tasks/rust.yml` and the PR diff is "affected".
- **Silent skip**: `moon ci :build-release` returns success without running because the explicit target has `runInCI: false` and nothing else is affected -- deploy silently no-ops.

**Rules**:

1. Every task in `.moon/tasks/<lang>.yml` and every per-project `moon.yml` must set `runInCI` explicitly to one of `true | false | 'affected'`. No inheritance silence.
2. For the canonical Rust-service-deploys-via-image-push topology in this user's repos, the convention is `runInCI: 'affected'` for `build-release` -- the moon docs accept `true`/`false`/`'affected'` and do not endorse one universally, so this is repo-policy, not canonical guidance.
3. Tests in the PR-validate `moon ci` lane should be unit-only (`cargo test --lib` or `cargo nextest run --lib`). Integration tests require infra and belong in a separate job invoked outside `moon ci`.
4. For `runInCI: false` tasks on a deploy lane, use `moon run` or `moon exec`, never `moon ci :<task>` -- the filter still applies.

Before changing inheritance, use `moon query tasks --affected | jq` (canonical primitive per https://moonrepo.dev/docs/commands/query/tasks; JSON is the default output, there is no `--json` flag) to enumerate which tasks are actually scheduled across affected projects, or `moon project <id> --json` for single-project introspection. "Why did this task fire?" is a graph question, not a YAML question.

Full mechanics (mergeArgs / mergeOutputs, the cargo-argv duplication shape, the bare-`moon ci` vs explicit-target pattern) are in `references/ci-guide.md` sections 2 and 3, and `references/real-world-gotchas.md` "Task-inheritance override mechanics".

### Rule 3 -- Treat (moon id, Cargo name, Docker image, ArgoCD app) as a single tuple

[failure-mode: moon-project-id-image-name-divergence]

Scoped to the canonical Rust-service-deploys-via-image-push topology. When adding, renaming, or migrating a service, four names must line up:

- `id:` in `moon.yml` (or directory name if `id:` is omitted)
- `[package].name` in `Cargo.toml`
- The Docker image tag's last path segment (what CI's `docker-push` actually pushes)
- The deploy manifest's image reference (Kustomize `kustomize.images`, ArgoCD ImageUpdater `imageName`, Helm `image.repository` last segment)

The `$project` token resolves to (1), not (2). If they diverge, `cargo build --package $project` fails; bare `cargo build` may succeed with a stale binary if a `[[bin]]` override is in play -- green build, broken deploy.

**Canonical materialisation site:** `DOCKER_IMAGE` env on the `docker-push` task in per-project `moon.yml` (e.g. `DOCKER_IMAGE: '${REGISTRY}/${ENV}/acme-$project'`). The last path segment after the final `/` is the canonical name the deploy manifest must reference.

**Directory layout to grep:** `argocd/applications/<app>/` for `Application` manifests and `argocd/image-updaters/<env>-<svc>.yaml` for image-updater configs.

When scaffolding or renaming: grep all four locations before merging, set `id:` explicitly in `moon.yml` if names cannot be identical, override the `build-release` task's `command` with `--package <cargo-name>` and `outputs` to the right binary path, and verify all four task overrides (`check` / `test` / `lint` / `build-release`). Smoke-test by confirming the pushed image tag matches what the deploy manifest references -- "build green" is not evidence; "the new image SHA shows up in prod" is. Full walkthrough in `references/ci-guide.md` section 12.

### Rule 4 -- State the toolchain-bootstrap strategy before changing any toolchain config

[failure-mode: moon-toolchain-prototools-drift]

There are three documented bootstrap strategies for Rust in moon CI; mixing them is the cause of the churn (in production five toolchain churn commits in one hour on 2026-03-19):

1. **Manual rustup**: `actions/checkout` -> `dtolnay/rust-toolchain` (or `moonrepo/setup-rust`) -> `moonrepo/setup-toolchain@v0` with `auto-install: false` and (often) `MOON_SKIP_SETUP_TOOLCHAIN=rust` + `MOON_TOOLCHAIN_FORCE_GLOBALS=rust`.
2. **Proto auto-install**: `moonrepo/setup-toolchain@v0` with `auto-install: true`, `.prototools` as the version source of truth.
3. **Moon v2 native**: `.moon/toolchains.yml` declares the rust toolchain; `setup-toolchain` provisions it.

**Detection grep -- run this first to identify the active strategy:**

```bash
grep -l setup-rust .github/workflows/ ; \
cat .prototools 2>/dev/null ; \
cat .moon/toolchains.yml 2>/dev/null ; \
cat rust-toolchain.toml 2>/dev/null
```

Before proposing any edit to `.prototools`, `.moon/toolchains.yml`, the `setup-toolchain` invocation, or any `MOON_SKIP_*` / `MOON_TOOLCHAIN_*` env var, state which strategy the repo is on. Cross-strategy changes are migrations, not one-line fixes.

**Single-source-of-truth rules** (full schema and worked Strategy A/B/C examples in `references/ci-guide.md` section 8):

- The Rust toolchain version lives in exactly one of: `.prototools`, `.moon/toolchains.yml`, or `rust-toolchain.toml` (rustup honours this regardless of moon). If two or more exist with different pins, that is the bug; resolve before doing anything else.
- `MOON_SKIP_SETUP_RUST` is not a documented env var; per https://moonrepo.dev/docs/how-it-works/action-graph the documented form is `MOON_SKIP_SETUP_TOOLCHAIN=true` (scoped per-tool by setting the value to the tool name, e.g. `rust` or `node:20.0.0`).
- `toolchains.yml` `bins:` duplicates `.prototools` and `moonrepo/setup-rust`. In CI keep `bins:` minimal or empty.

**sccache prerequisite:** if `RUSTC_WRAPPER=sccache` is set anywhere, add `mozilla-actions/sccache-action@v0.0.9` as a workflow step before `moon ci`. Presence of `SCCACHE_GCS_*` / `SCCACHE_S3_*` / `SCCACHE_REDIS_*` env blocks is evidence the cache is intentional -- install sccache, do not unset the wrapper.

### Rule 5 -- Treat cache-toggle commits as evidence of oscillation, not as a fix

[failure-mode: moon-remote-cache-and-sccache-flakiness]

Three sub-symptoms get conflated and toggled blindly:

1. **Remote moon cache server unreachable / slow** -- `moon ci` hangs on gRPC connect for minutes; build wall time jumps from 8 to 45+ minutes.
2. **GHA cache service 5xx** -- sccache save/restore fails with HTTP 503 from `https://acghub*.actions.githubusercontent.com/`; `SCCACHE_GHA_ENABLED=true` is the gating env var.
3. **`RUSTC_WRAPPER=sccache` set without sccache installed** -- every `cargo` invocation fails with "no such file or directory".

Name the symptom precisely before toggling. The wrong toggle re-triggers the same symptom hours later. A cache-toggle commit on a recently-toggled config is oscillation evidence (in production three disable/re-enable commits in ~6 weeks); read the previous toggle's commit message before proposing the inverse toggle.

**Right pattern.** Keep the cache configured. Add a fast-fail probe before `moon ci`. Full schema for `.moon/workspace.yml::remote` -- `api: grpc | http` (gRPC default per https://moonrepo.dev/docs/config/workspace, with `host:` accepting `grpc(s)://` or `http(s)://` per Bazel REAPI / Bazel HTTP caching), `auth`, `cache.compression`, `cache.localReadOnly` (added in v1.40.0) -- is in `references/ci-guide.md` section 7. Direct S3 or GCS backends are NOT in the documented schema; if those are required, front them with bazel-remote. Inline probe snippet:

```bash
if ! timeout 25 grpcurl -plaintext "${MOON_REMOTE_HOST#grpcs://}" \
    grpc.health.v1.Health/Check 2>/dev/null; then
  echo "moon remote cache unreachable; falling back to local"
  unset MOON_REMOTE_HOST MOON_REMOTE_TOKEN
fi
```

`nc -zw5 host port` is the alternative when grpcurl is unavailable. `localReadOnly: true` (camelCase, per https://moonrepo.dev/docs/config/workspace#localreadonly) is the supported workspace.yml fallback when the cache is healthy but you want builds to read from remote without writing.

**Additional rules**:

- `RUSTC_WRAPPER` must be unset OR set to a binary the runner has installed. Assert with `command -v sccache && sccache --version` before any cargo invocation.
- For release-LTO builds, sccache cannot cache the linker invocation (sccache wraps `rustc`, not the linker; LTO work happens at link time -- see https://github.com/rust-lang/rust/issues/71850 for the broader "LTO products are not reusable across incremental builds" discussion). Moon's docs do not characterise this trade-off [unverified-canon]; the corpus pattern is to `unset RUSTC_WRAPPER` in the `build-release` task's env so LTO link time is not paid twice (once to wrap, once to link).
- `SCCACHE_IDLE_TIMEOUT=0` belongs at workflow-level, not task-level -- release-LTO links run inside the `cargo` invocation, so a task-level setting does not apply.
- If the runner provider is Depot (or any cache-coupled runner), abandoning the runner also abandons the cache. Verify which subsystem is the actual flake before swapping.

### Rule 6 -- Service-scope Rust workspace binary names; never ship a generic `[[bin]]` name

[failure-mode: rust-workspace-binary-name-collision]

**Runtime-symptom path.** If a service deploys cleanly but the running pod produces wrong behaviour for *its own domain* (a users-service pod emitting achievements logic, friend-request black holes, missing-profile rows from the wrong handler), suspect a workspace `[[bin]]` collision before blaming the deploy manifest.

When scaffolding a new Rust service or worker:

1. Prefix every `[[bin]]` name in `Cargo.toml` with the service name. `name = "users_projection_worker"`, not `name = "projection_worker"`. Same for `event_worker`, `consumer`, `migrator`, and any other boilerplate name.
2. Before merging a service-scaffold PR, run `cargo build --workspace --bins` (not just `--package <new-service>`) and assert binary-name uniqueness:

   ```bash
   grep -nH '^\[\[bin\]\]' services/*/Cargo.toml
   cargo metadata --format-version 1 \
     | jq -r '.packages[].targets[] | select(.kind[] == "bin") | .name' \
     | sort | uniq -d
   find . -name moon.yml -exec grep -H '^id:' {} \; | awk -F: '{print $3}' | sort | uniq -d
   ```

   Empty output from both `uniq -d` checks is the pass condition.
3. **Anti-pattern preempt:** per-service `CARGO_TARGET_DIR` overrides do **not** fix this. They defeat workspace incremental compilation and remote-cache reuse, and leave the binary-name collision live in any single-service build. Fix the names.

The pattern "rename one colliding binary, build, discover two more colliding binaries" has happened (an in-corpus incident — three rename commits, the third 28 minutes after the second). Fix the whole class in one PR.

## Cross-skill defences

For invariants that defend better at a different layer of the stack:

- **`rust-monorepo-orchestrator`** is the right scaffold-time home for the binary-name collision rule (Rule 6) and the toolchain-bootstrap three-strategy framing (Rule 4). An ast-grep / `cargo metadata` lint there fires at service-creation time rather than at break-time.
- **`oracle:verification-protocol`** is mandatory for any moon-CLI version-dependent claim in this skill -- the remaining `[unverified-canon]` markers on Rules 1 (the `moon exec --downstream` empty-result behavioural report on merge-commit bases) and 5 (the sccache + release-LTO trade-off) are the call sites where the user's transcript corpus is the only ground; assert them as universal only after the three-tier cascade lands a more authoritative source.
- **`k8s-deployment-readiness`** is the natural home for the four-name-tuple invariant at deploy-readiness time -- assert the deploy manifest's image-repository last segment matches what the build pipeline emits.

## Reference files

For deep details on any topic, read the matching reference file:

| Topic | File |
|-------|------|
| **Comprehensive moon-ci walkthrough** (seven steps, runInCI semantics, MOON_BASE/HEAD discipline, parallelism, remote caching, toolchain strategies, two worked examples, six anti-patterns) | **`references/ci-guide.md`** |
| Core concepts (workspace, project, task, smart hashing, graphs) | `references/concepts.md` |
| CLI commands | `references/commands.md` |
| Workspace config | `references/workspace-config.md` |
| Task system (command vs script, presets, inheritance, deps, inputs/outputs) | `references/tasks.md` |
| Toolchains (WASM plugins, language tiers, proto, extensions) | `references/toolchains.md` |
| CI/CD (provider configs, `moon ci` flag reference) | `references/ci-cd.md` |
| Docker (`moon docker scaffold/file/setup/prune`, multi-stage, Alpine) | `references/docker.md` |
| Code generation (`moon generate`, Tera templates) | `references/codegen.md` |
| v1-to-v2 migration (all breaking changes, `moon migrate v2`) | `references/migration-v1-to-v2.md` |
| Advanced topics (MQL, graphs, hooks, env vars, debugging, v2.1 + v2.2 release notes) | `references/advanced.md` |
| Real-world gotchas (affected-detection edges, `$project` pitfalls, sccache conflicts, task-inheritance override mechanics) | `references/real-world-gotchas.md` |

## Config skeleton

```yaml
# .moon/workspace.yml -- see references/workspace-config.md
projects: ['apps/*', 'packages/*', 'services/*']
vcs: { provider: github, defaultBranch: main }
pipeline: { cacheLifetime: '7 days' }
remote:
  host: 'grpcs://cache.depot.dev'
  auth: { token: DEPOT_TOKEN }
```

```yaml
# .moon/toolchains.yml -- see references/toolchains.md
javascript: { packageManager: pnpm }
node: { version: '22.14.0' }
rust: { version: '1.90.0' }
```

```yaml
# <project>/moon.yml -- see references/tasks.md
id: 'users-service'
layer: 'application'
stack: 'backend'
dependsOn: ['shared-types']
tasks:
  build-release:
    command: 'cargo build --release --package users-service'
    deps: ['^:check']
    outputs: ['target/release/users-service']
    options:
      runInCI: 'affected'
      mergeArgs: 'replace'
```

## Quick reference -- commands

```bash
# Initialize and setup
moon init                          # Initialize workspace
moon setup                         # Install toolchain + deps

# Running tasks
moon run <project>:<task>          # Run a specific task
moon run :build                    # Run "build" across all projects
moon run ~:test                    # Run "test" in closest project
moon run '#tag:lint'               # Run by tag

# CI
moon ci                            # Run affected tasks in CI (additive, not narrowing)
moon ci :build :test :lint         # Filter by runInCI on explicit targets
moon ci --job 0 --job-total 4      # Shard across CI jobs

# Affected detection (canonical primitives; JSON is the default output)
moon query projects --affected           # Materialise affected projects (emits JSON)
moon query tasks --affected              # Materialise affected tasks (emits JSON)
moon exec :<task> --affected --plan      # v2.1.0+ -- pass a plan JSON; closest to a dry-run

# Introspection
moon project <id> --json           # Resolved project config
moon task <project>:<task> --json  # Resolved task config (post-inheritance)
moon action-graph <project>:<task> --json
moon hash <hash> [<other-hash>]    # Inspect / diff cache hashes
```

For `moon docker`, `moon generate`, and other commands, see `references/commands.md`.

## Task definition quick reference

```yaml
tasks:
  build:
    command: 'vite build'           # Simple command only (no pipes/redirects)
    inputs: ['src/**/*', 'tsconfig.json']
    outputs: ['dist']
    deps:
      - '~:typecheck'              # Same project
      - '^:build'                  # Dependency projects (load-bearing for Rule 1)
    env: { NODE_ENV: 'production' }
    options: { cache: true, runInCI: true }

  dev:
    command: 'vite'
    preset: 'server'                # No cache, interactive, persistent, skip CI

  validate:
    script: 'eslint . && prettier --check .'   # Use script for pipes/chains/redirects
    inputs: ['src/**/*']
```

Use `command` for single commands. Use `script` for pipes (`|`), redirects (`>`), or chaining (`&&`, `||`). Strict v2 requirement.

## Dependency syntax

| Pattern | Meaning | Where |
|---------|---------|-------|
| `app:build` | Specific project + task | Anywhere |
| `#tag:build` | Projects with tag | CLI, deps |
| `:build` | All projects | CLI only |
| `~:build` | Same/closest project | CLI, deps |
| `^:build` | Dependency projects | Config only |

## v1 to v2

If v1-style config is encountered (`toolchain.yml` singular, `node.npm`, camelCase flags, `runner` instead of `pipeline`, `type:` instead of `layer:`, `platform:` instead of `toolchains:`, complex commands in `command:` instead of `script:`, `.moon/tasks.yml` instead of `.moon/tasks/all.yml`), flag it and consult `references/migration-v1-to-v2.md`. Run `moon migrate v2` to automate what it can (documented at https://moonrepo.dev/docs/migrate/2.0).
