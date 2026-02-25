# Migration from v1 to v2 Reference

Run `moon migrate v2` to automate what it can, then review this guide for everything else.

## Table of Contents
- [Installation](#installation)
- [CLI changes](#cli-changes)
- [Workspace config](#workspace-config)
- [Toolchains config](#toolchains-config)
- [Project config](#project-config)
- [Task changes](#task-changes)
- [Environment variables](#environment-variables)
- [VCS & hooks](#vcs--hooks)
- [Docker](#docker)
- [Extensions](#extensions)
- [Query language (MQL)](#query-language-mql)
- [Webhooks](#webhooks)

## Installation

`moon upgrade` does NOT work from v1 → v2 because the distribution format changed. Install fresh:

```bash
proto install moon 2.0.0
# or
curl -fsSL https://moonrepo.dev/install/moon.sh | bash
```

**OS note**: `x86_64-apple-darwin` (Intel Mac) support was removed. Only Apple Silicon (`aarch64-apple-darwin`) is supported.

## CLI changes

### Naming convention
All flags converted to kebab-case:
- `--logLevel` → `--log-level`
- `--platform` → `--toolchain`

### Removed commands
- `moon node` (use toolchain plugins)
- `moon migrate from-package-json`
- `moon query hash` and `moon query hash-diff` (use `moon hash`)

### Command changes

| Command | Change |
|---------|--------|
| `moon check` | Uses `moon exec` internally; `--update-cache` → `--force`; add `--closest` to find nearest project |
| `moon ci` | Relations excluded by default; add `--include-relations` for v1 behavior |
| `moon generate` | Destination changed from positional arg to `--to` option |
| `moon init` | Removed scaffolding functionality |
| `moon run` | `--dependents` requires value (`deep` or `direct`); removed `--no-bail`, `--profile`, `--remote` |
| `moon run` (no scope) | No longer auto-finds closest project; use `~:` prefix |

### New commands
- `moon exec` — low-level task execution
- `moon extension` — extension management
- `moon hash` — hash inspection
- `moon projects` — list all projects as table
- `moon tasks` — list all tasks
- `moon template` — template info
- `moon query affected` — affected projects/tasks

### Interactive selection
`moon check`, `moon run`, and `moon project` now prompt for target selection when no identifier is provided.

### moonx
`moonx` is now stabilized as a dedicated binary for `moon exec` operations.

## Workspace config

File: `.moon/workspace.*`

| v1 | v2 |
|----|-----|
| `codeowners.orderBy: 'project-name'` | `codeowners.orderBy: 'project-id'` |
| `codeowners.syncOnRun` | `codeowners.sync` |
| `constraints.enforceProjectTypeRelationships` | `constraints.enforceLayerRelationships` |
| `docker.prune.installToolchainDeps` | `docker.prune.installToolchainDependencies` |
| `docker.scaffold.include` | `docker.scaffold.configsPhaseGlobs` |
| `runner` | `pipeline` |
| `unstable_remote` | `remote` |
| `vcs.manager` | `vcs.client` |
| `vcs.syncHooks` | `vcs.sync` |

**Removed**: `docker.scaffold.copyToolchainFiles`, `experiments.*`, `hasher.batchSize`, `pipeline.archivableTargets`

## Toolchains config

**File renamed**: `.moon/toolchain.*` → `.moon/toolchains.*` (plural)

Remove `unstable_` prefix from all toolchain identifiers **except Python**.

### JavaScript ecosystem restructuring

| v1 | v2 |
|----|-----|
| `node.dependencyVersionFormat` | `javascript.dependencyVersionFormat` |
| `node.inferTasksFromScripts` | `javascript.inferTasksFromScripts` |
| `node.packageManager` | `javascript.packageManager` |
| `node.rootPackageOnly` | `javascript.rootPackageDependenciesOnly` |
| `node.syncPackageManagerField` | `javascript.syncPackageManagerField` |
| `node.syncProjectWorkspaceDependencies` | `javascript.syncProjectWorkspaceDependencies` |

### Package managers promoted to top-level

| v1 | v2 |
|----|-----|
| `node.bun` | `bun` |
| `node.npm` | `npm` |
| `node.pnpm` | `pnpm` |
| `node.yarn` | `yarn` |

**Important**: `bun`, `deno`, and `node` toolchains now **require** `javascript` to be defined.

**Removed**: `bun.packagesRoot`, `deno.depsFile`, `deno.lockfile`, `node.addEnginesConstraint`, `node.packagesRoot`

### Python
Still unstable: `python.pip` → `unstable_pip`, `python.uv` → `unstable_uv`. Removed `python.rootVenvOnly`.

## Project config

File: `moon.*` (per-project)

| v1 | v2 |
|----|-----|
| `docker.scaffold.include` | `docker.scaffold.sourcesPhaseGlobs` |
| `project.name` | `project.title` |
| `project.metadata` | Move custom fields to root of `project` |
| `type` | `layer` |
| `toolchain` | `toolchains` |
| `platform` | `toolchains.default` |

Language is now auto-detected from toolchains. First toolchain = primary language.

## Task changes

### File organization
- `.moon/tasks.yml` (single file) → `.moon/tasks/all.yml`
- Use subdirectories/files for organization: `.moon/tasks/node.yml`, `.moon/tasks/rust.yml`

### Renamed tokens
| v1 | v2 |
|----|-----|
| `$projectName` | `$projectTitle` |
| `$projectType` | `$projectLayer` |
| `$taskPlatform` | `$taskToolchain` |

### Renamed settings
| v1 | v2 |
|----|-----|
| `tasks.*.local` | `tasks.*.preset: 'server'` |
| `tasks.*.platform` | `tasks.*.toolchains` |
| `tasks.*.options.affectedPassInputs` | `tasks.*.options.affectedFiles.passInputsWhenNoMatch` |

### Changed defaults

| Option | v1 default | v2 default |
|--------|-----------|-----------|
| `inferInputs` | `true` | `false` |
| `shell` | `false` | `true` |
| `unixShell` | — | `bash` |
| `windowsShell` | — | `pwsh` |

### Command syntax
Complex commands (pipes, redirects, `&&`) no longer allowed in `command`. Use `script` instead.

### Dep args format
`tasks.deps.*.args` now requires a **list of strings**, not a single string.

### Removed
- `watcher` preset

## Environment variables

### Substitution syntax changes

| Syntax | v1 behavior | v2 behavior |
|--------|-------------|-------------|
| `$VAR` | Keep if empty | Empty string if empty |
| `$VAR!` | Don't substitute | Removed |
| `$VAR?` | Empty string | Removed |
| `${VAR?}` | Empty string | Keep literal if empty |
| `${VAR:-default}` | Not supported | Use default if empty |
| `${VAR+alternate}` | Not supported | Use alternate if non-empty |

### .env file loading
- Now loaded just before execution (was during graph creation)
- Task `env` overrides `.env` but can no longer reference `.env` values for substitution
- `MOON_AFFECTED_FILES` uses OS path separator (`:` on Unix, `;` on Windows) instead of comma

## VCS & hooks

- Hooks written to `.moon/hooks/` (not `.git/hooks/`)
- Git configured with `core.hooksPath`
- Hook scripts no longer end in `.sh`
- "Touched files" → "changed files" everywhere
- `moon query touched-files` → `moon query changed-files`

## Docker

- `.moon/docker/workspace` directory → `.moon/docker/configs`
- `moon docker file` now loops through toolchains for multi-runtime images

## Extensions

- Moved from `extensions` in `.moon/workspace.*` to separate `.moon/extensions.*` file
- Built-in extensions (`download`, `migrate-nx`, `migrate-turborepo`) must be explicitly enabled

## Query language (MQL)

| v1 | v2 |
|----|-----|
| `projectName` | `projectId` |
| `projectType` | `projectLayer` |
| `taskPlatform` | `taskToolchain` |

## Webhooks

- Removed `tool.*` events → use `toolchain.*`
- Removed `runtime` field from `dependencies.*` events → use `toolchain`
