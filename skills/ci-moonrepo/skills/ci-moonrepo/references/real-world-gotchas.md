# moon Real-World Gotchas

Hard-won lessons from running moon at scale in large Rust monorepos. These are things the docs either don't say or bury. If you hit any of these symptoms, reach for this file first — you are very likely re-encountering a known problem.

Organised by theme, in rough order of how often they bite.

---

## Affected detection and `moon ci`

### Affected does not propagate through `dependsOn` by default

**Symptom.** You edit a library; `moon ci :build-release :docker-push` reports *"No tasks affected by changed files"*; downstream services that depend on the library don't rebuild.

**Cause.** moon's default affected resolution does **not** walk `dependsOn` edges. Library-only changes never schedule downstream service tasks.

**Fix.** Add `--include-relations` (`-g`) **plus** `--downstream deep`:

```bash
moon ci :check :lint -g --downstream deep --job $JOB --job-total $TOTAL
```

`-g` alone only includes direct relations. You need `--downstream deep` to walk the full dependency fan-out.

Also, make the graph reflect reality: if a service's `build-release` requires a library to compile, add `deps: ['^:check']` (or similar) so moon's task graph encodes the edge.

### `moon ci <targets>` is additive, not narrowing

**Symptom.** PR validate job unexpectedly runs `build-release`/`docker-push` and fails because those tasks expect secrets the validate job doesn't have.

**Cause.** `moon ci :check :lint` doesn't mean "only run check/lint". It runs:
- All *affected* tasks with `runInCI: true`, **plus**
- The explicit targets you listed (also filtered by `runInCI`)

With `--downstream deep` added, the cascade pulls in heavy release tasks.

**Fix.** For strict PR validation, use `moon run :check :lint --affected` — this runs only the explicit targets and their upstream deps, nothing more. Reserve `moon ci ... -g --downstream deep` for deploy jobs where the cascade is desired.

### Merge-commit base SHA is a trap

**Symptom.** After a PR merges, moon schedules nothing and releases are missed.

**Cause.** On merge commits, `github.event.before` points to the *old* target-branch HEAD, which is the wrong base for the diff.

**Fix.** In a "meta" CI step, detect merge commits and compute the correct base:

```bash
PARENTS=$(git rev-list --count HEAD~1..HEAD --parents | head -1 | wc -w)
if [ "$PARENTS" -ge 3 ]; then
  MOON_BASE=$(git rev-parse HEAD~1)   # first parent for merges
else
  MOON_BASE=${{ github.event.before }}
fi
```

Then pass `--base "$MOON_BASE"` to `moon ci`. Also expose a `workflow_dispatch` input for manual-rebuild overrides.

### CI-written files corrupt affected detection

**Symptom.** moon reports unrelated files as "changed" (e.g. `gha-creds-*.json`, `.argocd-source-*.yaml`).

**Cause.** moon diffs the working tree, not the git index. Any untracked file CI writes into the repo before `moon ci` runs appears in the changed-file list.

**Fix.** Gitignore everything CI writes. Common offenders: `gha-creds-*.json` from `google-github-actions/auth`, generated Argo/Helm files, build outputs written to the repo root.

---

## Task configuration

### `$project` token is the moon project ID, not the Cargo package name

**Symptom.** `cargo build --package $project` fails with *"package ID specification 'X' did not match any packages"*.

**Cause.** `$project` resolves to the moon project ID (directory name by default). If it diverges from the Cargo `package.name` (common: `users` vs `users-service`, underscores vs dashes), it breaks.

**Fix.** Either:
- Make them match. Keep moon project ID identical to Cargo `package.name`.
- Or set `id:` explicitly in the service's `moon.yml` to force alignment.

When overriding a task for a service whose binary name differs from `$project`, override `command` **and** `outputs` explicitly — and verify `check`, `test`, `lint`, `build-release` *all* use the new package name. Easy to fix three and miss the fourth.

### Task field overrides merge by default — you usually want `replace`

**Symptom.** You override `outputs:` on a service to match its real binary path, but the build-release task still fails the output-existence check on the inherited (wrong) path.

**Cause.** Task fields *merge* with the inherited definition by default. The old outputs entries are still present.

**Fix.** Use explicit merge strategies:

```yaml
tasks:
  build-release:
    command: 'cargo build --release --package users-service'
    outputs:
      - '/target/release/users-service'
    options:
      mergeArgs: replace
      mergeOutputs: replace
      mergeInputs: replace
      mergeDeps: replace
```

### Workspace-wide cargo commands turn library edits into O(N) builds

**Symptom.** Editing one library triggers 4+ sequential full-workspace builds; CI runs over an hour.

**Cause.** Base tasks in `.moon/tasks/rust.yml` run workspace-wide (`cargo check --all-targets --all-features` with no `--package`). Combined with a `cargo-target` mutex forcing serial execution, a single library edit compiles every crate once per base task.

**Fix.** Scope every base cargo task with `--package $project`:

```yaml
# .moon/tasks/rust.yml
tasks:
  check:
    command: 'cargo check --all-targets --all-features --package $project'
  test:
    command: 'cargo nextest run --package $project'
  lint:
    command: 'cargo clippy --all-targets --all-features --package $project -- -D warnings'
```

If a library's moon project ID differs from its Cargo package name, override `command` in that library's `moon.yml` (see `$project` gotcha above).

### `test-doc` fails on binary-only crates

**Symptom.** CI red on binary services with *"error: no library targets found"*.

**Cause.** `cargo test --doc` only runs on library crates. Inheriting a `test-doc` task into binary services fails immediately.

**Fix.** Gate `test-doc` on the `library` layer (use tag inheritance: `.moon/tasks/tag-library.yml`) or drop it for binaries. Similarly, `cargo-nextest` exits 1 on *"no tests to run"* — pass `--no-tests=pass` for crates that may legitimately have zero tests.

### Only v1 tokens you can rely on in v2

Supported tokens (verify before using):
`$project`, `$projectAlias`, `$projectTitle`, `$projectSource`, `$projectRoot`, `$projectType`, `$workspaceRoot`, `$language`, `$target`, `$task`, `$taskPlatform`, `$taskType`, `$date`, `$datetime`, `$time`, `$timestamp`.

`$projectDescription` **does not exist** — a Docker label built with it gives you an empty string in production. If you need data moon doesn't expose (description, owner, etc.), pass it via `env:` or Docker `build-arg`.

---

## Toolchain and setup

### `MOON_SKIP_SETUP_RUST` does not exist

**Symptom.** CI runs full proto / rustup / `cargo binstall` setup on every shard even after `moonrepo/setup-rust` already installed the toolchain. Pipelines take 1.5h on library-only PRs.

**Cause.** `MOON_SKIP_SETUP_RUST` is silently ignored — it's not a real env var.

**Fix.** Use the real moon 2.x env vars:

| Env var | Effect |
|---|---|
| `MOON_SKIP_SETUP_TOOLCHAIN=rust` | Skip setup + dep install for Rust specifically |
| `MOON_SKIP_SETUP_TOOLCHAIN=*` | Skip for all toolchains (dangerous — can break sccache resolution) |
| `MOON_TOOLCHAIN_FORCE_GLOBALS=rust` | Force moon to use the PATH binaries installed by setup-rust instead of proto-managed ones |

In GitHub Actions with `moonrepo/setup-rust` + `moonrepo/setup-toolchain`, the right combo is usually:

```yaml
env:
  MOON_SKIP_SETUP_TOOLCHAIN: rust
  MOON_TOOLCHAIN_FORCE_GLOBALS: rust
```

Setting `MOON_SKIP_SETUP_TOOLCHAIN=*` has been observed to leave sccache stuck in `Local disk` mode instead of `ghac` — don't go broader than needed.

### `toolchains.yml` `bins:` duplicates `.prototools`

**Symptom.** Every CI run installs `cargo-watch`, `cargo-nextest`, `sccache`, `cargo-deny`, `cargo-machete` via `cargo binstall`. Frequent 402 Payment Required from `warehouse-clerk-tmp.vercel.app`, slow GitHub fallback.

**Cause.** `.moon/toolchains.yml` with a Rust `bins:` list re-installs tools that `moonrepo/setup-rust` already provides, and duplicates version/components from `.prototools`.

**Fix.**
- Version, components, targets → `.prototools` only.
- Trim `bins:` to dev-only tools, or drop it entirely in CI.
- Never put `cargo-watch` or `sccache` in a CI-visible `bins:` list.

### Moon project ID collisions with list-form `projects:`

**Symptom.** moon refuses to register two projects that share a basename (e.g. `social_media/common` and `common`).

**Fix.** Switch `.moon/workspace.yml` from list form to map form:

```yaml
projects:
  common: 'common'
  social-media-common: 'social_media/common'
  order-service: 'apps/order-service'
  # ...
```

Use map form whenever nested directories share basenames.

---

## v2 migration landmines

v2 accepts a surprising amount of v1 syntax without erroring but silently stops doing what you think. Search-and-replace these before blaming moon:

| v1 | v2 |
|---|---|
| `language: 'rust'` | `toolchains: { rust: {} }` |
| `type: 'library'` | `layer: 'library'` |
| `platform:` | `toolchains:` |
| `.moon/toolchain.yml` (singular) | `.moon/toolchains.yml` |
| `.moon/tasks.yml` | `.moon/tasks/all.yml` |
| `runner:` section | `pipeline:` |
| `project.name` | `project.title` |
| `--logLevel` (camelCase) | `--log-level` (kebab-case) |
| Pipes/redirects in `command:` | Move to `script:` |
| `shell: false` (old default) | `shell: true` is the new default |
| `inferInputs: true` (old default) | `inferInputs: false` is the new default |

Run `moon migrate v2` first — it handles most of these. Then hand-check.

### v2 layer constraints block `application → application` deps

**Symptom.** moon complains an application-layer project cannot depend on another application-layer project.

**Cause.** v2 enforces layer-based dependency rules, and v2 auto-detects Cargo deps — so a service depending on another service via Cargo trips the constraint even if you don't declare it in `moon.yml`.

**Fix.** Either:
- Omit `layer:` on umbrella/aggregator projects.
- Restructure so shared logic moves to a `library` layer.

Hiding the dep in `moon.yml` doesn't help — moon still sees it through Cargo.

---

## Remote cache and sccache

### Self-hosted remote cache is unreachable from GitHub-hosted runners

**Symptom.** `moon ci` hangs indefinitely on gRPC connect when `remote.host` points to an internal cache server.

**Cause.** GitHub-hosted runners live in a different network; moon's gRPC client doesn't fail fast on unreachable hosts.

**Fix options.**
- Make the cache publicly reachable (authenticated).
- Use self-hosted runners in the same VPC.
- Set `localReadOnly: true` and skip writes.
- Switch to Depot.dev's moon-native cache.
- Drop the remote cache entirely and use `sccache` with `ghac` mode for cargo.

Always set a connect timeout so failures surface fast instead of hanging the job.

### sccache pitfalls

Known issues to preempt:

- **Jobserver deadlock** (upstream sccache issue #1011, open 5+ years) — can freeze under moon's parallel executor. Keep shards small; don't assume sccache is safe at high parallelism.
- **`SCCACHE_IDLE_TIMEOUT` default is 10 min** — can kill the server mid-long-link. Set `SCCACHE_IDLE_TIMEOUT=0` in CI.
- **`RUSTC_WRAPPER=sccache` conflicts with moon's own caching for `build-release`** — release LTO saves more than sccache gives back. `unset RUSTC_WRAPPER` in the build-release task's env.
- **Cross/musl release builds** — sccache often makes them slower or breaks them. Disable for those tasks.

Rule of thumb: keep sccache on for `check`/`test`/`lint` (ghac mode, idle timeout 0); turn it off for `build-release`.

---

## CI workflow shape

### `cancel-in-progress: true` on push branches loses releases

Set concurrency `cancel-in-progress: true` only for `pull_request`, never for `push` to default branches. Otherwise rapid merges cancel in-flight release jobs.

### `fail-fast` in release runs kills sibling shards

For deploy matrices, set `fail-fast: false` — one shard's flake shouldn't kill all the others mid-release.

### Shards are not load-balanced

`moon ci --job N --job-total T` splits work into shards, but doesn't balance cost. A heavy `docker-push` target can land entirely on one shard while others finish quickly. Don't size shard count by *number of projects*; think about expected *wall time per shard*.

### Don't run raw cargo alongside moon in the same pipeline

A shadow `pr-ci.yml` using direct `cargo` + `Swatinem/rust-cache` next to a moon pipeline causes duplicated work, divergent caching, and confusion about which checks are authoritative. Unify on moon, or delete the shadow pipeline.

### `moon run :format --affected --status staged`

Canonical pre-commit pattern (husky/lefthook). Don't invent alternatives — this is the one that actually works with moon's affected resolution against the git index.

### `setup-toolchain` 502s

`moonrepo/setup-toolchain@v0` downloads the moon binary at run time; transient 502s from the install CDN are common. Pin a cached version or wrap with a retry.

---

## When in doubt

If a moon behaviour looks wrong — task resolution, affected detection, task inheritance, flag semantics — **read the docs before guessing**. Specifically:
- `references/commands.md` for flag semantics and env vars
- `references/ci-cd.md` for `moon ci` and affected resolution
- `references/tasks.md` for inheritance and merge strategies
- `references/migration-v1-to-v2.md` for anything that looks like v1 syntax

moon has a lot of subtle semantic distinctions (additive vs narrowing, upstream vs downstream, direct vs deep). A minute in the docs beats an hour debugging a silent no-op.
