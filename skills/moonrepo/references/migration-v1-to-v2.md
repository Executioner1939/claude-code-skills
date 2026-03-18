# Migration from v1 to v2 Reference

Complete guide to migrating from moon v1 to v2 "Phobos". Includes all breaking changes, renamed settings, and migration steps.

## Table of Contents
- [Automated migration](#automated-migration)
- [Installation](#installation)
- [CLI changes](#cli-changes)
- [Workspace config changes](#workspace-config-changes)
- [Toolchain config changes](#toolchain-config-changes)
- [Project config changes](#project-config-changes)
- [Task changes](#task-changes)
- [Changed defaults](#changed-defaults)
- [Environment variable changes](#environment-variable-changes)
- [MQL field renames](#mql-field-renames)
- [Other breaking changes](#other-breaking-changes)

## Automated Migration

```bash
moon migrate v2
```

This automates common renames and restructuring. Manual review is still required for everything it cannot handle.

## Installation

`moon upgrade` does NOT work from v1 to v2 because the distribution format changed (archives instead of direct executables). Install fresh:

```bash
proto install moon 2.0.0
# or
curl -fsSL https://moonrepo.dev/install/moon.sh | bash
```

Intel Mac (`x86_64-apple-darwin`) support was removed in v2.

## CLI Changes

| Change | Details |
|--------|---------|
| Naming convention | All flags changed from camelCase to kebab-case (`--logLevel` becomes `--log-level`) |
| `--platform` | Renamed to `--toolchain` |
| Removed commands | `moon node`, `moon migrate from-package-json`, `moon query hash`, `moon query hash-diff` |
| `moon check` | Uses `moon exec` internally; `--update-cache` becomes `--force`; added `--closest` |
| `moon ci` | Relations excluded by default; use `--include-relations` for v1 behavior |
| `moon generate` | Destination changed from positional argument to `--to` option |
| `moon run` | `--dependents` requires a value; removed `--no-bail`, `--profile`, `--remote` |
| `moon run` (no scope) | No longer auto-finds closest project; use `~:` prefix |
| Interactive selection | Multiple commands now prompt when no identifier provided |

### New commands in v2

- `moon exec` -- low-level task execution
- `moon extension` -- extension management
- `moon hash` -- hash inspection and comparison
- `moon projects` -- list all projects as table
- `moon tasks` -- list all tasks
- `moon template` -- template info
- `moon query affected` -- affected projects/tasks
- `moonx` -- stabilized as dedicated binary

## Workspace Config Changes

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
| `extensions` (in workspace file) | Moved to separate `.moon/extensions.*` file |

**Removed settings:** `docker.scaffold.copyToolchainFiles`, `experiments.*`, `hasher.batchSize`, `pipeline.archivableTargets`

## Toolchain Config Changes

The file is renamed from `.moon/toolchain.*` (singular) to `.moon/toolchains.*` (plural).

| v1 | v2 |
|----|-----|
| `node.dependencyVersionFormat` | `javascript.dependencyVersionFormat` |
| `node.inferTasksFromScripts` | `javascript.inferTasksFromScripts` |
| `node.packageManager` | `javascript.packageManager` |
| `node.rootPackageOnly` | `javascript.rootPackageDependenciesOnly` |
| `node.syncPackageManagerField` | `javascript.syncPackageManagerField` |
| `node.syncProjectWorkspaceDependencies` | `javascript.syncProjectWorkspaceDependencies` |
| `node.bun` | `bun` (top-level) |
| `node.npm` | `npm` (top-level) |
| `node.pnpm` | `pnpm` (top-level) |
| `node.yarn` | `yarn` (top-level) |

`bun`, `deno`, and `node` now require `javascript` to be defined.

**Removed settings:** `bun.packagesRoot`, `deno.depsFile`, `deno.lockfile`, `node.addEnginesConstraint`, `node.packagesRoot`

## Project Config Changes

| v1 | v2 |
|----|-----|
| `docker.scaffold.include` | `docker.scaffold.sourcesPhaseGlobs` |
| `project.name` | `project.title` |
| `project.metadata` | Custom fields moved to root of `project` |
| `type` | `layer` |
| `toolchain` | `toolchains` |
| `platform` | `toolchains.default` |

## Task Changes

| v1 | v2 |
|----|-----|
| `.moon/tasks.yml` (single file) | `.moon/tasks/all.yml` (directory-based) |
| Complex commands in `command` | Must use `script` field |
| `tasks.*.local` | `tasks.*.preset: 'server'` |
| `tasks.*.platform` | `tasks.*.toolchains` |
| `tasks.*.options.affectedPassInputs` | `tasks.*.options.affectedFiles.passInputsWhenNoMatch` |
| `$projectName` | `$projectTitle` |
| `$projectType` | `$projectLayer` |
| `$taskPlatform` | `$taskToolchain` |

## Changed Defaults

| Option | v1 Default | v2 Default |
|--------|------------|------------|
| `inferInputs` | `true` | `false` |
| `shell` | `false` | `true` |
| `unixShell` | (none) | `bash` |
| `windowsShell` | (none) | `pwsh` |

## Environment Variable Changes

| Syntax | v1 Behavior | v2 Behavior |
|--------|-------------|-------------|
| `$VAR` | Keep literal if empty | Empty string if empty |
| `$VAR!` | Don't substitute | Removed |
| `$VAR?` | Empty string if empty | Removed |
| `${VAR?}` | (not available) | Keep literal if empty |
| `${VAR:-default}` | (not available) | Use default if empty |
| `${VAR+alternate}` | (not available) | Use alternate if non-empty |

## MQL Field Renames

| v1 | v2 |
|----|-----|
| `projectName` | `projectId` |
| `projectType` | `projectLayer` |
| `taskPlatform` | `taskToolchain` |

## Other Breaking Changes

- `.env` loading moved to just before execution (was during graph creation in v1)
- `MOON_AFFECTED_FILES` uses OS path separator (`:` on Unix, `;` on Windows)
- Docker: `.moon/docker/workspace` renamed to `.moon/docker/configs`
- VCS hooks: `.moon/hooks/` instead of `.git/hooks/`; `core.hooksPath` used
- Dep args: `tasks.deps.*.args` now requires a list of strings, not a single string
- Webhooks: `tool.*` events removed (use `toolchain.*`); `runtime` field removed (use `toolchain`)
- `watcher` preset removed
- Task inheritance now deep merges (was shallow in v1)
- Env `null` values can remove inherited vars
- `...` syntax available in targets (Bazel-style)
- Interactive prompt added for commands without identifiers
