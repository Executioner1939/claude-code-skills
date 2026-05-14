# moon Core Concepts

One-paragraph mental models for the moon primitives the failure-mode rules reference. Lifted from the SKILL.md body in v3.4.0 as part of the progressive-disclosure pass.

## Workspace

The workspace root is identified by a `.moon/` (or `.config/moon/`) directory containing configuration files. Initialize with `moon init`. Every moon command resolves the workspace root by walking up from `cwd` until it finds `.moon/`.

## Projects

Projects are directories registered via the `projects` setting in `.moon/workspace.*` -- either as a manual map, glob patterns, or both. Each project has its own `moon.*` config file. A project's identifier (the `id:` in `moon.yml`, defaulting to the directory name) is the key moon uses everywhere: `moon run <id>:<task>`, the `$project` token, dependsOn edges, and affected-detection output.

## Tasks

Tasks are the core unit of work -- a command or script run within a project's directory. They can be project-level (in `<project>/moon.*`), global/inherited (in `.moon/tasks/**/*.yml`), or inferred from package.json scripts. Tasks inherit by language, by stack, and by tag; the resolved set per project can be inspected with `moon project <id>`.

## Smart hashing and caching

moon hashes task inputs (files, globs, env vars, command, args) and caches outputs. Unchanged inputs mean instant cached results. This powers incremental builds and CI speedups. Remote caching (`remote:` in workspace.yml) shares the cache across machines; the cache server speaks gRPC.

## Project graph and action graph

moon builds a DAG of projects and their dependencies (the project graph), then an action graph that determines execution order, parallelism, and affected-task detection. The project graph is hashed; the action graph is per-invocation. The asynchronous-tracking experiments in v2.2 operate on the action-graph layer.
