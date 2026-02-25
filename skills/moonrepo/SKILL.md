---
name: moonrepo-v2
description: |
  **moonrepo v2 Expert**: Comprehensive guide for moon v2.0 "Phobos" — the Rust-based monorepo management, task orchestration, and build system for the web ecosystem. Covers workspace setup, task configuration, CI/CD pipelines, Docker integration, remote caching, code generation/templates, WASM plugin toolchains, and migration from v1.
  - MANDATORY TRIGGERS: moon, moonrepo, monorepo task runner, moon.yml, .moon/workspace, moon ci, moon docker, moon generate, moon run, moon check, moonrepo caching, moonrepo templates, moonrepo toolchain, moonrepo plugin, proto toolchain
  - Also trigger when users ask about: monorepo orchestration with moon, task inheritance, smart hashing, incremental builds, affected task detection, project graphs, workspace configuration for moon, or anything related to the moonrepo ecosystem. Even if the user doesn't say "moon" explicitly, if they describe a Rust-based monorepo build tool or reference moon-specific concepts like "project graph", "action graph", or ".moon directory", use this skill.
---

# moonrepo v2.0 "Phobos"

moon is a repository management, orchestration, and build tool for the web ecosystem, written in Rust. It sits between Bazel (high complexity) and make/just (low complexity), providing structure without overwhelming overhead. v2.0 "Phobos" was released February 18, 2026 and is a major rewrite with breaking changes.

When helping with moonrepo, always target **v2 syntax and conventions** unless the user explicitly mentions v1. If they share v1-style config (e.g., `toolchain.yml` singular, `node.npm`, camelCase flags), flag it and offer migration guidance.

For detailed reference material on specific topics, read the appropriate file from `references/`:

| Topic | File | When to read |
|-------|------|--------------|
| Workspace config | `references/workspace-config.md` | Setting up `.moon/workspace.*`, project discovery, pipeline, VCS, remote caching, docker, notifier |
| Task system | `references/tasks.md` | Defining tasks, inheritance, presets, inputs/outputs, deps, caching, env vars, `script` vs `command` |
| CI/CD | `references/ci-cd.md` | `moon ci`, provider setup, parallelism, caching strategies, affected detection |
| Docker | `references/docker.md` | `moon docker scaffold/file/setup/prune`, layer caching, multi-stage builds, Alpine |
| Code generation | `references/codegen.md` | `moon generate`, templates, Tera engine, variables, sharing templates |
| Toolchains & plugins | `references/toolchains.md` | WASM plugin system, toolchain config, supported languages, extensions |
| Migration from v1 | `references/migration-v1-to-v2.md` | Breaking changes, renamed settings, `moon migrate v2` |

## Core Concepts

### Workspace
The workspace is the root of a moon-managed repository, identified by the `.moon` (or `.config/moon`) directory. It houses all configuration and is responsible for project discovery, VCS integration, and the action pipeline.

Initialize with:
```bash
moon init
```

### Projects
Projects are directories registered in `.moon/workspace.*` via the `projects` setting — either as a manual map, glob patterns, or both. Each project gets a `moon.*` config file for project-specific tasks and metadata.

### Tasks
Tasks are the core unit of work — a command or script run as a child process within a project's directory. They can be:
- **Project-level**: defined in `<project>/moon.*`
- **Global/inherited**: defined in `.moon/tasks/**/*.yml` and inherited by matching projects
- **Inferred**: auto-detected from package.json scripts (for JS ecosystem)

### Smart Hashing & Caching
moon calculates a hash from task inputs (files, globs, env vars) and caches outputs. If inputs haven't changed, the cached result is returned instantly. This enables incremental builds and dramatic CI speedups.

### Project & Action Graphs
moon builds a project dependency graph and an action dependency graph to determine execution order, parallelism, and affected task detection.

## Configuration File Formats

v2 supports multiple formats for all config files: **YAML**, **JSON**, **JSONC**, **TOML**, **HCL**, and **Pkl**. The `.moon/` directory (or `.config/moon/`) contains:

```
.moon/
├── workspace.yml        # Required — project discovery, pipeline, VCS, remote cache
├── toolchains.yml       # Optional — language versions, package managers
├── extensions.yml       # Optional — WASM extension configs
├── tasks/               # Optional — global inherited task definitions
│   ├── node.yml         #   tasks inherited by node projects
│   ├── rust.yml         #   tasks inherited by rust projects
│   └── all.yml          #   tasks inherited by all projects
└── hooks/               # Optional — git hooks (managed by moon)
```

## Quick Reference: Common Commands

```bash
# Workspace
moon init                          # Initialize workspace
moon setup                         # Install toolchain + deps

# Running tasks
moon run <project>:<task>          # Run a specific task
moon run :build                    # Run "build" in default project
moon run ~:test                    # Run "test" in closest project
moon check                         # Run all build/test/lint for a project
moonx <command> [args]             # Execute via moon exec shorthand

# CI
moon ci                            # Run affected tasks in CI
moon ci :build :test :lint         # Run specific task types in CI
moon ci --job 0 --job-total 4      # Shard across CI jobs

# Docker
moon docker scaffold <project>     # Generate Docker workspace skeleton
moon docker file                   # Generate Dockerfile
moon docker setup                  # Install toolchain + deps in container
moon docker prune                  # Remove non-production deps

# Code generation
moon generate <template>           # Scaffold from template
moon templates                     # List available templates

# Inspection
moon project <name>                # Show project details
moon projects                      # List all projects
moon tasks                         # List all tasks
moon action-graph                  # Visualize action graph
moon project-graph                 # Visualize project graph

# Queries
moon query affected                # Show affected projects/tasks
moon query changed-files           # Show changed files
moon query projects                # Query projects with MQL
moon query tasks                   # Query tasks with MQL
```

## Task Definition Quick Reference

In `moon.*` (project) or `.moon/tasks/*.yml` (global):

```yaml
tasks:
  build:
    command: 'vite build'           # Simple command (no pipes/redirects)
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
    preset: 'server'               # No cache, interactive, not in CI

  complex-pipeline:
    script: 'eslint . && prettier --check .'   # Use script for pipes/chains
    inputs:
      - 'src/**/*'
      - '@globs(configs)'
```

The `command` field only supports simple commands. For pipes (`|`), redirects (`>`), or chaining (`&&`, `||`), use `script` instead.

## Key v2 Changes from v1

If you encounter v1-style configuration, the most common things to flag:

1. **`.moon/toolchain.yml`** → **`.moon/toolchains.yml`** (plural)
2. **`node.npm/pnpm/yarn`** → promoted to top-level `npm`/`pnpm`/`yarn` toolchains
3. **`node.*` shared settings** → moved to `javascript` toolchain
4. **CLI flags**: camelCase → kebab-case (e.g., `--logLevel` → `--log-level`)
5. **`runner`** section → renamed to **`pipeline`**
6. **`type`** (project) → **`layer`**; **`platform`** → **`toolchains`**
7. **Complex commands** in `command` → must use `script` field
8. **`.moon/tasks.yml`** (single file) → **`.moon/tasks/all.yml`**
9. **Task `shell` option** defaults to `true` (was `false`)
10. **Task `inferInputs`** defaults to `false` (was `true`)

Run `moon migrate v2` to automate what it can, then consult `references/migration-v1-to-v2.md` for the full list.
