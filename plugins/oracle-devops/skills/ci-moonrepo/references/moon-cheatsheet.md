# moon v2 cheat-sheet

Consolidated quick-reference for moon v2 (latest **2.2.4**, April 2026). Configuration schemas, CLI commands, task fields, MQL syntax, env vars, v1→v2 migration table. Use this when you need a fact about moon, not a workflow; for failure-mode diagnosis go to `workflows.md`.

For canonical depth, the moon docs at https://moonrepo.dev/docs are the source of truth -- run the verification cascade (`firecrawl-search` against moonrepo.dev) before asserting any version-dependent claim.

## Config skeletons

### `.moon/workspace.yml`

```yaml
projects:
  # Map form is safer than glob form when nested dirs share basenames
  common: 'common'
  social-media-common: 'social_media/common'
  order-service: 'apps/order-service'

vcs:
  provider: github
  defaultBranch: main
  hooks:
    pre-commit:
      - 'moon run :lint :format --affected --status=staged'
  sync: true
  hookFormat: 'native'

pipeline:
  cacheLifetime: '7 days'

remote:
  host: 'grpcs://cache.depot.dev'        # grpc(s):// or http(s)://
  auth: { token: DEPOT_TOKEN }            # env var name, NOT the literal token
  cache:
    compression: 'zstd'
    localReadOnly: false                  # v1.40.0+

experiments:
  asyncGraphBuilding: true                # v2.2+: 100-170% faster on large monorepos
  asyncAffectedTracking: true             # v2.2+

unstable_daemon: false                    # v2.2+, opt-in
```

### `.moon/toolchains.yml`

```yaml
javascript:
  packageManager: pnpm
node: { version: '22.14.0' }
pnpm: { version: '10.0.0' }
rust:
  version: '1.90.0'
  components: ['clippy', 'rustfmt']
```

### `.prototools`

```toml
rust = "1.90.0"
node = "22.14.0"
pnpm = "10.0.0"
```

Pick **one** of `.prototools`, `.moon/toolchains.yml`, `rust-toolchain.toml` as the source of truth for a given toolchain. Two divergent pins is a bug; resolve before doing anything else.

### Per-project `moon.yml`

```yaml
id: 'users-service'         # explicit override of inferred dir name
layer: 'application'        # application | automation | configuration | library | scaffolding | tool | unknown
stack: 'backend'            # backend | data | frontend | infrastructure | systems | unknown

project:
  title: 'Users Service'
  description: '...'
  owner: '@backend-team'

tags:
  - 'ci-pull-request'
  - 'ci-merge-develop'
  - 'ci-merge-production'

toolchain:
  default: 'rust'

dependsOn:
  - 'shared-types'
  - id: 'api-client'
    scope: 'production'     # production | development | build | peer

tasks:
  build-release:
    command: 'cargo build --release --package users-service'
    deps: ['^:check']
    outputs: ['target/release/users-service']
    options:
      runInCI: 'affected'
      mergeArgs: 'replace'
```

## CLI commands

Global flags available on every command: `--cache <off|read|read-write|write>`, `-c/--concurrency <N>`, `--log <off|error|warn|info|debug|trace>`, `--log-file <path>`, `-q/--quiet`, `--theme <dark|light>`, `--dump`.

### Running tasks

```bash
moon run app:build                 # one target
moon run client:dev server:dev     # multiple
moon run :test                     # all projects
moon run '#frontend:lint'          # by tag (quote it)
moon run ~:build                   # closest project
moon run :build --query "language=typescript"
moon run app:test -- --coverage    # pass args through
```

`moon run` aliases to `moon r`. `moon exec` is the low-level base command (alias `moonx`); `moon run`, `moon ci`, `moon check` all shell through to it.

### CI

```bash
moon ci                            # affected tasks; additive, not narrowing
moon ci --base "$MOON_BASE" --head "$MOON_HEAD"
moon ci :build :test :lint         # explicit targets STILL filtered by runInCI
moon ci --job 0 --job-total 4      # shard 0-indexed across 4 jobs
moon ci -g --downstream deep       # walk graph (v1 default behaviour; opt-in in v2)
```

### Affected detection (canonical primitives -- JSON is the default output, no `--json` flag)

```bash
moon query projects --affected
moon query tasks --affected
moon query changed-files --status modified
moon query changed-files --base $BASE --head $HEAD --local
moon exec :<task> --affected --plan      # v2.1.0+: dry-run preview
```

### Introspection

```bash
moon project <id> --json           # resolved project config
moon projects                      # list all as table
moon task <project>:<task> --json  # resolved task config (post-inheritance)
moon tasks                         # list all
moon action-graph <project>:<task> --json
moon project-graph --json
moon task-graph <project>:<task> --json
moon hash <hash> [<other-hash>]    # inspect / diff cache hashes
```

**Important:** `moon project-graph`, `moon task-graph`, `moon action-graph` are **interactive by default** -- they open a browser to render the DAG. **Always pass `--json` or `--dot`** when scripting; the skill bundles `scripts/graph-json.sh` as the safe wrapper.

### Docker (sub-commands)

```bash
moon docker scaffold <project>     # produce a minimal copy for Docker context
moon docker file <project>         # generate Dockerfile from template
moon docker setup                  # install toolchain + deps inside image
moon docker prune                  # strip dev dependencies after build
```

### Codegen

```bash
moon generate <template>           # interactive, prompts for variables
moon generate <template> --to apps/new-app --defaults
moon generate <template> --dry-run
```

### Misc

```bash
moon init                          # initialise workspace
moon setup                         # install toolchain + deps
moon migrate v2                    # automated v1→v2 rename pass
moon sync vcs-hooks                # regenerate git hooks
moon daemon start                  # v2.2+, unstable
```

## Task fields

| Field | Type | Notes |
|---|---|---|
| `command` | string | Simple command. **No pipes, redirects, `&&`, `||`** -- use `script` for those. Merges via `mergeArgs`. |
| `script` | string | Shell command; pipes/redirects/chains allowed. Always **replaces** on inheritance. |
| `args` | string or list | Appended to command. v2 deps args must be a list. |
| `deps` | list | Tasks that must run first. See dependency syntax below. |
| `inputs` | list | Files / globs / env vars used to compute the cache key. |
| `outputs` | list | Files / dirs produced; restored from cache on hits. |
| `env` | map | Environment variables. `null` value removes an inherited var. |
| `extends` | string | Extend another task's config. |
| `preset` | string | `server` (long-running) or `utility` (one-off, no cache). |
| `toolchains` | list | Associate with specific toolchains. |
| `options` | map | Task behaviour options -- see below. |

### `options`

| Option | Values | Notes |
|---|---|---|
| `runInCI` | `true` / `false` / `'affected'` | **Must be set explicitly.** Implicit default is `true` for non-`dev/start/serve` task names. |
| `mergeArgs` / `mergeDeps` / `mergeEnv` / `mergeInputs` / `mergeOutputs` / `mergeToolchains` | `append` (default) / `prepend` / `replace` | Per-axis merge strategy when inheriting. |
| `cache` | `true` (default) / `false` | Disable caching for this task. |
| `persistent` | `true` / `false` | Long-running. |
| `interactive` | `true` / `false` | Streams stdio. |
| `inferInputs` | `true` / `false` | Auto-detect inputs. v2 default is `false` (v1 was `true`). |
| `affectedFiles` | object | v2.1+: `filter`, `ignoreProjectBoundary`, `passDotWhenNoResults`, `passInputsWhenNoMatch`. |
| `runInSyncPhase` | `true` / `false` | v2.1+: run as part of the sync phase. |
| `shell` | `true` (default) / `false` | v2 default flipped from `false`. |
| `unixShell` / `windowsShell` | `bash` / `pwsh` / etc. | v2 defaults: `bash` on unix, `pwsh` on windows. |

### Presets

| Preset | Effect |
|---|---|
| `server` (v1's `local: true`) | No cache, interactive, persistent, streams output, skips CI. Use for `dev`, `start`, `serve`. |
| `utility` (v2 new) | No cache, interactive, streams output, skips CI. Use for one-off commands, migrations, db seeds. |

### `command` vs `script`

If the task contains pipes (`|`), redirects (`>`), or chaining (`&&`, `||`, `;`), it MUST go in `script`. Strict v2 requirement. v1 accepted complex `command:` values; v2 does not.

## Dependency syntax

| Pattern | Meaning | Where |
|---|---|---|
| `app:build` | Specific project + task | Anywhere |
| `#tag:build` | Projects with tag | CLI, deps |
| `:build` | All projects | CLI only |
| `~:build` | Same / closest project | CLI, deps |
| `^:build` | Dependency projects (upstream) | Config only |
| `...` | Bazel-style globs | v2+ |

Advanced dep form with args / env / optional:

```yaml
tasks:
  build:
    deps:
      - target: '~:generate'
        args: ['--watch', 'false']
        env: { TARGET_ENV: 'production' }
      - target: '^:build'
        optional: true
```

## Token reliable list

Tokens you can rely on in v2:

`$project`, `$projectAlias`, `$projectTitle`, `$projectSource`, `$projectRoot`, `$projectType`, `$workspaceRoot`, `$language`, `$target`, `$task`, `$taskPlatform`, `$taskType`, `$date`, `$datetime`, `$time`, `$timestamp`.

**`$projectDescription` does NOT exist.** A Docker label built with it gives you an empty string. Pass arbitrary metadata via `env:` or Docker `--build-arg`.

`$project` resolves to the moon project `id:` (defaulting to directory name), **not** the Cargo `[package].name`. If they diverge, override `--package` explicitly in the task command.

## MQL (Moon Query Language)

Filter projects and tasks via `--query`.

### Operators

| Operator | Description | Example |
|---|---|---|
| `=` / `!=` | Equals / not equals | `language=typescript` |
| `~` / `!~` | Like / not like (glob) | `projectSource~packages/*` |
| `&&` / `AND`, `\|\|` / `OR` | Logical AND / OR (parentheses required when mixing) | `(tag=react \|\| tag=vue) && taskType=test` |
| `[...]` | List membership | `language=[javascript, typescript]` |

### Fields

`language`, `project`, `projectAlias`, `projectId`, `projectLayer` (v1 `projectType`), `projectSource`, `projectStack`, `tag`, `task`, `taskToolchain` (v1 `taskPlatform`), `taskType`.

```bash
moon run :build --query "language=typescript && projectStack=frontend"
moon run :test --query "projectLayer=library || projectLayer=tool"
moon run :build --query "projectSource~packages/*"
moon query projects "tag=[frontend, backend]"
```

## Environment variables

### Moon-side

| Variable | Effect |
|---|---|
| `MOON_BASE` / `MOON_HEAD` | Override base / head revision for affected detection. Always set these explicitly in CI. |
| `MOON_CACHE` | Override cache mode (`off`, `read`, `read-write`, `write`). |
| `MOON_LOG` | Log level. |
| `MOON_CONCURRENCY` | Thread pool size. |
| `MOON_SKIP_SETUP_TOOLCHAIN` | `true` (skip entirely), `<tool>` (per-tool, e.g. `rust`), `<tool>:<version>`. |
| `MOON_TOOLCHAIN_FORCE_GLOBALS` | `true` or `1` -- use PATH binaries instead of proto-installed. Parsed as boolean; **setting it to a tool name parses as falsy** (common bug). |
| `MOON_REMOTE_HOST` | Override `remote.host` from workspace.yml. |
| `MOON_INCLUDE_RELATIONS` | v2.0.3+: include graph relations on affected checks. |
| `MOON_AFFECTED_FILES` | List of affected files (OS path separator: `:` unix, `;` windows). |
| `MOON_DEBUG_PROCESS_ENV` | Reveal child process env. |
| `MOON_DEBUG_PROCESS_INPUT` | Reveal child stdin. |
| `MOON_PIPELINE_AUTO_CLEAN_CACHE` | v2.2+. |
| `MOON_PIPELINE_CACHE_LIFETIME` | v2.2+. |
| `MOON_PIPELINE_KILL_PROCESS_THRESHOLD` | v2.2+. |
| `PROTO_OFFLINE` | Force proto offline mode. |

**`MOON_SKIP_SETUP_RUST` is NOT a real env var.** It is silently ignored. Use `MOON_SKIP_SETUP_TOOLCHAIN=rust`.

### Env substitution syntax (v2)

| Form | Behaviour |
|---|---|
| `$VAR` | Empty string if unset (was "keep literal" in v1). |
| `${VAR?}` | Keep literal if unset. |
| `${VAR:-default}` | Use default if unset. |
| `${VAR+alternate}` | Use alternate if set. |
| `$VAR!` (v1) | Removed in v2. |
| `$VAR?` (v1) | Removed in v2 -- use `${VAR?}`. |

## CI command reference

`moon ci` internally invokes `moon exec` with these defaults: `--affected`, `--ci`, `--on-failure=continue`, `--summary=detailed`, `--upstream=deep`, `--downstream=direct`.

| Need | Command |
|---|---|
| Override base/head | `MOON_BASE=<sha> MOON_HEAD=<sha> moon ci` or `--base/--head` |
| Shard | `moon ci --job <i> --job-total <N>` (0-indexed) |
| Re-enable v1 graph-walk | `-g, --include-relations` plus `--downstream deep` |
| Force CI mode | `--ci` |
| Bypass cache | `-f, --force` |
| Filter by MQL | `--query "..."` |
| Skip sync/setup | `--no-actions` |

Provider parallelism env vars (when not using GHA matrix):

| Provider | Index | Total |
|---|---|---|
| CircleCI | `CIRCLE_NODE_INDEX` | `CIRCLE_NODE_TOTAL` |
| Buildkite | `BUILDKITE_PARALLEL_JOB` | `BUILDKITE_PARALLEL_JOB_COUNT` |
| GitLab | `CI_NODE_INDEX` | `CI_NODE_TOTAL` |
| GitHub | (none -- use `matrix.shard`) | (none) |

## v1 → v2 migration

Run `moon migrate v2` first; it handles most renames. The manual residue:

### Workspace

| v1 | v2 |
|---|---|
| `.moon/toolchain.yml` (singular) | `.moon/toolchains.yml` |
| `.moon/tasks.yml` (single file) | `.moon/tasks/all.yml` (directory) |
| `runner:` | `pipeline:` |
| `unstable_remote:` | `remote:` |
| `vcs.manager` | `vcs.client` |
| `vcs.syncHooks` | `vcs.sync` |
| `constraints.enforceProjectTypeRelationships` | `constraints.enforceLayerRelationships` |

### Project / task

| v1 | v2 |
|---|---|
| `project.name` | `project.title` |
| `type:` | `layer:` |
| `platform:` | `toolchains:` (top-level) / `toolchains.default` |
| `language: 'rust'` | `toolchains: { rust: {} }` |
| Pipes/redirects in `command:` | Move to `script:` |
| `tasks.*.local: true` | `tasks.*.preset: 'server'` |
| `tasks.*.platform` | `tasks.*.toolchains` |
| `tasks.*.options.affectedPassInputs` | `tasks.*.options.affectedFiles.passInputsWhenNoMatch` |
| `$projectName` | `$projectTitle` |
| `$projectType` | `$projectLayer` |
| `$taskPlatform` | `$taskToolchain` |

### Defaults flipped

| Option | v1 | v2 |
|---|---|---|
| `inferInputs` | `true` | `false` |
| `shell` | `false` | `true` |
| `unixShell` | (none) | `bash` |
| `windowsShell` | (none) | `pwsh` |

### CLI

- All flags: camelCase → kebab-case (`--logLevel` → `--log-level`).
- `--platform` → `--toolchain`.
- `moon ci`: relations excluded by default; pass `-g, --include-relations` for v1 behaviour.
- `moon generate`: destination moved from positional arg to `--to`.
- `moon run` (no scope): no longer auto-finds closest project; use `~:` prefix.

### Removed

`moon node`, `moon migrate from-package-json`, `moon query hash`, `moon query hash-diff`. Intel Mac (`x86_64-apple-darwin`) support was dropped in v2.

### Other breaking changes

- Task inheritance deep-merges in v2 (was shallow in v1).
- `.env` loads just before execution (v1 loaded during graph creation).
- VCS hooks live in `.moon/hooks/`; git's `core.hooksPath` is set to point there.
- Webhook `tool.*` events removed -- use `toolchain.*`. `runtime` field removed -- use `toolchain`.
- `watcher` preset removed.
- Bazel-style `...` available in target patterns.

## Docker quick reference

```yaml
# Multi-stage Dockerfile pattern
FROM rust:1.90 AS base
RUN cargo install moon-cli

# Stage 1: scaffold (cacheable layer)
FROM base AS skeleton
WORKDIR /app
COPY . .
RUN moon docker scaffold users-service

# Stage 2: setup (toolchain + deps)
FROM base AS setup
WORKDIR /app
COPY --from=skeleton /app/.moon/docker /app/.moon/docker
RUN moon docker setup

# Stage 3: build
FROM setup AS build
COPY . .
RUN moon run users-service:build-release

# Stage 4: production
FROM debian:bookworm-slim
COPY --from=build /app/target/release/users-service /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/users-service"]
```

Alpine: set `MOON_TOOLCHAIN_FORCE_GLOBALS=rust` to use musl-built toolchain on PATH instead of proto's glibc binaries.

## MCP tools (moon's built-in MCP server)

```bash
claude mcp add moon -s project \
  -e MOON_WORKSPACE_ROOT=/path/to/workspace \
  -- moon mcp
```

Available: `get_project`, `get_projects`, `get_task`, `get_tasks`, `get_changed_files`, `sync_projects`, `sync_workspace`, `generate`.

## Debugging

```bash
MOON_LOG=trace moon run app:build
MOON_DEBUG_PROCESS_ENV=true moon run app:build
moon task app:build --json                  # resolved post-inheritance
moon hash <hash> [<other-hash>]
moon query affected
moon query changed-files --status modified
moon action-graph app:build --json | jq     # ALWAYS pass --json
```
