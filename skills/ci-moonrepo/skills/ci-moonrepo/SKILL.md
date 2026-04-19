---
name: ci-moonrepo
description: |
  Guide for moonrepo (moon) v2 -- the Rust-based monorepo management, task orchestration, and build system. Covers workspace setup (.moon/workspace.yml), task configuration (moon.yml), CI/CD pipelines (moon ci), Docker integration, remote caching, code generation, WASM toolchain plugins, and v1-to-v2 migration.
  Use when user mentions: moon, moonrepo, moon.yml, .moon/workspace, moon run, moon ci, moon check, moon docker, moon generate, moon exec, moonx, moon query, moon setup, monorepo task runner, project graph, action graph, task inheritance, smart hashing, affected detection, remote caching, proto toolchain, WASM plugin toolchain, moon migrate v2.
  Also use when user describes a monorepo build tool with concepts like project graphs, task hashing, or inherited tasks, even without saying "moon" explicitly.
paths:
  - "**/moon.yml"
  - "**/.moon/**"
  - "**/.prototools"
---

# moonrepo v2 (latest: v2.2.1)

moon is a monorepo management, orchestration, and build system for the web ecosystem, written in Rust. It provides structure between Bazel (high complexity) and make/just (low complexity). v2.0 "Phobos" shipped February 2026; v2.2.1 is the current release (April 2026), adding an optional background daemon and async graph-building / affected-tracking experiments for significant pipeline speedups.

Always target **v2 syntax** unless the user explicitly mentions v1. If you see v1-style config (e.g., `toolchain.yml` singular, `node.npm`, camelCase CLI flags, `runner` instead of `pipeline`), flag it and offer migration guidance.

Before debugging a confusing moon behaviour, check `references/real-world-gotchas.md` — it catalogues known landmines (affected-detection edges, `$project` vs Cargo package name, `MOON_SKIP_SETUP_RUST` being a no-op, etc.) that cost hours the first time they're hit.

For deep details on any topic, read the appropriate reference file from `references/`:

| Topic | File | When to read |
|-------|------|--------------|
| CLI commands | `references/commands.md` | All commands with flags, options, and examples |
| Workspace config | `references/workspace-config.md` | `.moon/workspace.*` settings: projects, pipeline, VCS, remote cache, docker, notifier |
| Task system | `references/tasks.md` | Task definition, command vs script, presets, inheritance, deps, inputs/outputs, env, caching, all options |
| Toolchains | `references/toolchains.md` | WASM plugins, toolchain config, language support tiers, proto integration, extensions |
| CI/CD | `references/ci-cd.md` | `moon ci`, provider configs (GitHub/GitLab/CircleCI/Azure), sharding, affected detection, remote caching |
| Docker | `references/docker.md` | `moon docker scaffold/file/setup/prune`, multi-stage Dockerfiles, Alpine, layer caching |
| Code generation | `references/codegen.md` | `moon generate`, Tera templates, variables, template sharing |
| Migration v1 to v2 | `references/migration-v1-to-v2.md` | All breaking changes, renamed settings, `moon migrate v2` |
| Advanced topics | `references/advanced.md` | MQL queries, graphs, git hooks, environment variables, token functions, debugging |
| Real-world gotchas | `references/real-world-gotchas.md` | Known landmines: affected-detection edges, `$project` token pitfalls, v2 layer constraints, sccache conflicts, self-hosted cache hangs |

## Core Concepts

### Workspace
The workspace root is identified by a `.moon/` (or `.config/moon/`) directory containing configuration files. Initialize with `moon init`.

### Projects
Projects are directories registered via the `projects` setting in `.moon/workspace.*` -- either as a manual map, glob patterns, or both. Each project has its own `moon.*` config file.

### Tasks
Tasks are the core unit of work -- a command or script run within a project's directory. They can be project-level (in `<project>/moon.*`), global/inherited (in `.moon/tasks/**/*.yml`), or inferred from package.json scripts.

### Smart Hashing and Caching
moon hashes task inputs (files, globs, env vars) and caches outputs. Unchanged inputs mean instant cached results. This powers incremental builds and CI speedups.

### Project and Action Graphs
moon builds a DAG of projects and their dependencies, then an action graph determining execution order, parallelism, and affected task detection.

## Configuration Files

v2 supports YAML, JSON, JSONC, TOML, HCL, and Pkl formats for all config files.

```
.moon/
  workspace.yml        # Required -- project discovery, pipeline, VCS, remote cache
  toolchains.yml       # Optional -- language versions, package managers
  extensions.yml       # Optional -- WASM extension configs
  tasks/               # Optional -- global inherited task definitions
    all.yml            #   inherited by all projects
    node.yml           #   inherited by node projects
  hooks/               # Generated -- git hook scripts
```

Per-project: `<project>/moon.yml` (or `.json`, `.toml`, etc.)

## Quick Reference: Common Commands

```bash
# Initialize and setup
moon init                          # Initialize workspace
moon setup                         # Install toolchain + deps

# Running tasks
moon run <project>:<task>          # Run a specific task
moon run :build                    # Run "build" across all projects
moon run ~:test                    # Run "test" in closest project
moon run '#tag:lint'               # Run by tag
moon check                         # Run all build/test/lint for a project
moonx <command>                    # Shorthand for moon exec

# CI
moon ci                            # Run affected tasks in CI
moon ci :build :test :lint         # Specific task types
moon ci --job 0 --job-total 4      # Shard across CI jobs

# Docker
moon docker scaffold <project>     # Generate Docker workspace skeleton
moon docker file <project>         # Generate Dockerfile
moon docker setup                  # Install deps in container
moon docker prune                  # Remove non-production deps

# Code generation
moon generate <template>           # Scaffold from template

# Inspection
moon project <name>                # Show project details
moon query affected                # Show affected projects/tasks
moon action-graph                  # Visualize action graph
```

## Task Definition Quick Reference

In `moon.*` (project) or `.moon/tasks/*.yml` (global):

```yaml
tasks:
  build:
    command: 'vite build'           # Simple command only (no pipes/redirects)
    inputs:
      - 'src/**/*'
      - 'tsconfig.json'
    outputs:
      - 'dist'
    deps:
      - '~:typecheck'              # Same project
      - '^:build'                  # Dependency projects
    env:
      NODE_ENV: 'production'
    options:
      cache: true
      runInCI: true

  dev:
    command: 'vite'
    preset: 'server'               # No cache, interactive, persistent, skip CI

  validate:
    script: 'eslint . && prettier --check .'   # Use script for pipes/chains/redirects
    inputs:
      - 'src/**/*'
```

Use `command` for simple single commands. Use `script` for anything with pipes (`|`), redirects (`>`), or chaining (`&&`, `||`). This is a strict v2 requirement.

## Dependency Syntax

| Pattern | Meaning | Where |
|---------|---------|-------|
| `app:build` | Specific project + task | Anywhere |
| `#tag:build` | Projects with tag | CLI, deps |
| `:build` | All projects | CLI only |
| `~:build` | Same/closest project | CLI, deps |
| `^:build` | Dependency projects | Config only |

## Key v2 Changes from v1

If you encounter v1-style configuration, flag these common issues:

1. **`.moon/toolchain.yml`** (singular) is now **`.moon/toolchains.yml`** (plural)
2. **`node.npm/pnpm/yarn`** nested settings are now top-level `npm`/`pnpm`/`yarn` toolchains
3. **`node.*` shared settings** (like `packageManager`) moved to `javascript` toolchain
4. **CLI flags**: camelCase changed to kebab-case (`--logLevel` becomes `--log-level`)
5. **`runner`** section renamed to **`pipeline`**
6. **`type`** (project) renamed to **`layer`**; **`platform`** renamed to **`toolchains`**
7. **Complex commands** in `command` field must now use `script` field instead
8. **`.moon/tasks.yml`** (single file) replaced by **`.moon/tasks/all.yml`**
9. **Task `shell` option** defaults to `true` (was `false` in v1)
10. **Task `inferInputs`** defaults to `false` (was `true` in v1)

Run `moon migrate v2` to automate what it can, then consult `references/migration-v1-to-v2.md` for the full list.

## What's new in v2.2 (April 2026)

- **Background daemon** (`unstable_daemon` workspace setting, `moon daemon {start,stop,status}`) — long-running service that keeps the project graph warm between invocations. Opt-in while unstable.
- **Async experiments** — `experiments.asyncAffectedTracking` and `experiments.asyncGraphBuilding` (100–170% faster graph builds on large monorepos). Older `experiments.fasterGlobWalk` and `experiments.gitV2` have been stabilised and removed.
- **New pipeline env vars** — `MOON_PIPELINE_AUTO_CLEAN_CACHE`, `MOON_PIPELINE_CACHE_LIFETIME`, `MOON_PIPELINE_KILL_PROCESS_THRESHOLD`.
- **Graph JSON format changed** — `moon action-graph --json`, `project-graph --json`, `task-graph --json` now emit integer node IDs with a separate `data` object. Any tooling parsing the old shape needs updating.
- **Proto 0.56.x** bundled; automatic retry on transient rate-limit errors (3x exponential backoff).
- **PowerShell tasks** now use `-EncodedCommand` rather than `-Command` (affects special-char handling when `windowsShell: 'pwsh'`).
- **pnpm v10 multi-document lockfile parsing** fixed in 2.2.1 — users on pnpm 10 need this version.

## Workspace Config Quick Reference

```yaml
# .moon/workspace.yml
projects:                      # Required
  - 'apps/*'
  - 'packages/*'

vcs:
  provider: 'github'
  defaultBranch: 'main'

pipeline:
  cacheLifetime: '7 days'

remote:                        # Optional remote caching
  host: 'grpcs://cache.depot.dev'
  auth:
    token: 'DEPOT_TOKEN'
```

## Toolchain Config Quick Reference

```yaml
# .moon/toolchains.yml
javascript:
  packageManager: 'pnpm'

node:
  version: '22.14.0'

pnpm:
  version: '9.0.0'

typescript:
  syncProjectReferences: true
```

Remember: `bun`, `deno`, and `node` all require `javascript` to be defined in v2.

## Project Config Quick Reference

```yaml
# <project>/moon.yml
layer: 'application'
stack: 'frontend'
tags: ['react', 'vite']

dependsOn:
  - 'shared-ui'

tasks:
  build:
    command: 'vite build'
    outputs: ['dist']
    deps: ['^:build']
```
