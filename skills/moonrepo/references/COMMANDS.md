# Moon CLI Commands Reference

Complete reference for all moon v2 CLI commands, flags, and options.

## Table of Contents
- [Global options](#global-options)
- [moon run](#moon-run)
- [moon exec](#moon-exec)
- [moon check](#moon-check)
- [moon ci](#moon-ci)
- [moon project / projects](#moon-project--projects)
- [moon task / tasks](#moon-task--tasks)
- [moon query](#moon-query)
- [moon graph visualization](#moon-graph-visualization)
- [moon docker](#moon-docker)
- [moon generate](#moon-generate)
- [moon sync](#moon-sync)
- [moon toolchain](#moon-toolchain)
- [moon extension](#moon-extension)
- [moon utility commands](#moon-utility-commands)
- [moonx](#moonx)
- [Environment variables](#environment-variables)

## Global Options

Available on every command:

| Option | Description |
|--------|-------------|
| `--cache <mode>` | Cache mode: `off`, `read`, `read-write` (default), `write` |
| `--color` | Force colored output |
| `-c, --concurrency <n>` | Max threads (default: CPU cores) |
| `--dump` | Dump trace profile |
| `--log <level>` | Log level: `off`, `error`, `warn`, `info`, `debug`, `trace` |
| `--log-file <file>` | Write logs to file |
| `-q, --quiet` | Hide non-important output |
| `--theme <theme>` | Terminal theme: `dark`, `light` |

## moon run

Alias: `moon r`. Run one or many targets with caching. Uses `moon exec` internally with `--on-failure=bail` and `--upstream=deep`.

```bash
moon run <...target> [-- <args>]
```

**Examples:**
```bash
moon run app:build                     # Single target
moon run client:dev server:dev         # Multiple targets
moon run :test                         # All projects
moon run '#frontend:lint'              # By tag (quote for shell)
moon run ~:build                       # Closest project
moon run :build --query "language=typescript"  # With MQL filter
moon run app:test -- --coverage        # Pass args through to command
```

**Options:** Inherits all `moon exec` options (see below).

## moon exec

Aliases: `moon x`, `moonx`. Low-level task execution with full control. This is the base command that `moon run`, `moon ci`, and `moon check` all use.

```bash
moon exec <...target> [-- <args>]
```

**Core options:**

| Option | Description |
|--------|-------------|
| `--ci` | Force CI mode |
| `-f, --force` | Bypass cache, ignore changed files, skip affected checks |
| `-i, --interactive` | Run pipeline and tasks interactively |
| `-p, --plan <PATH>` | Path to execution plan JSON file (v2.1.0+) |
| `-s, --summary [LEVEL]` | Print summary of executed actions |

**Workflow options:**

| Option | Description |
|--------|-------------|
| `--ignore-ci-checks` | Ignore "run in CI" task checks |
| `--on-failure <action>` | On failure: `bail` or `continue` |
| `--query <mql>` | Filter tasks based on MQL query |
| `--no-actions` | Skip sync and setup actions |

**Affected options:**

| Option | Description |
|--------|-------------|
| `--affected [by]` | Only affected tasks (`local` or `remote`) |
| `--base <rev>` | Base revision for comparison |
| `--head <rev>` | Head revision for comparison |
| `-g, --include-relations` | Include graph relations for affected checks |
| `--status <status>` | Filter changed files by status |
| `--stdin` | Accept changed files from stdin |

**Graph options:**

| Option | Description |
|--------|-------------|
| `--downstream <depth>` | Include dependents: `none`, `direct`, `deep` |
| `--upstream <depth>` | Include dependencies: `none`, `direct`, `deep` |

**Parallelism options:**

| Option | Description |
|--------|-------------|
| `--job <index>` | Current job index (0-based) |
| `--job-total <total>` | Total number of jobs |

## moon check

Alias: `moon c`. Run all build/test/lint tasks for projects. Uses `moon exec` internally.

```bash
moon check [...projects]
```

| Option | Description |
|--------|-------------|
| `--all` | Check all projects |
| `--closest` | Check closest project from cwd |

**Examples:**
```bash
moon check app                # Check specific project
moon check --all              # Check all projects
moon check --closest          # Check project nearest to cwd
```

## moon ci

Run affected tasks in CI. Uses `moon exec` with `--affected`, `--ci`, `--on-failure=continue`, `--summary=detailed`, `--upstream=deep`, `--downstream=direct`.

```bash
moon ci [...target]
```

**Examples:**
```bash
moon ci                              # All affected CI tasks
moon ci :build :lint                 # Specific affected tasks
moon ci --base main                  # Compare against main
moon ci --job 0 --job-total 4        # Shard across CI jobs
moon ci --include-relations          # Include dependency/dependent tasks
```

In v2, graph relations (dependents) are NOT included by default. Use `--include-relations` to restore v1 behavior. Also settable via `MOON_INCLUDE_RELATIONS` env var (v2.0.3+).

## moon project / projects

### `moon project` (alias: `moon p`)

Display project information. Prompts for selection if no id provided.

```bash
moon project [id] [--json] [--no-tasks]
```

### `moon projects`

List all workspace projects.

```bash
moon projects [--json]
```

## moon task / tasks

### `moon task` (alias: `moon t`)

Display task information. Prompts for selection if no target provided.

```bash
moon task [target] [--json]
```

### `moon tasks`

List all workspace tasks as a table.

```bash
moon tasks [id] [--json]
```

## moon query

### `moon query projects`

```bash
moon query projects [query]
```

| Option | Description |
|--------|-------------|
| `--affected` | Filter affected projects |
| `--id <regex>` | Match project ID |
| `--language <regex>` | Match language |
| `--layer <regex>` | Match layer |
| `--source <regex>` | Match source path |
| `--stack <regex>` | Match stack |
| `--tags <regex>` | Match tags |
| `--tasks <regex>` | Match tasks |
| `--downstream <depth>` | Include dependents |
| `--upstream <depth>` | Include dependencies |

**Examples:**
```bash
moon query projects                      # All projects
moon query projects --id "react"         # Filter by ID regex
moon query projects "project~react"      # MQL query
moon query projects --affected           # Only affected
moon query projects --tasks "lint|build" # Projects with specific tasks
```

### `moon query tasks`

```bash
moon query tasks [query]
```

| Option | Description |
|--------|-------------|
| `--affected` | Filter affected tasks |
| `--command <regex>` | Match command |
| `--id <regex>` | Match task ID |
| `--project <regex>` | Match project |
| `--toolchain <regex>` | Match toolchain |
| `--type <regex>` | Match type |

### `moon query affected`

```bash
moon query affected [--downstream <depth>] [--upstream <depth>]
```

### `moon query changed-files`

```bash
moon query changed-files
```

| Option | Description |
|--------|-------------|
| `--base <rev>` | Base revision |
| `--head <rev>` | Head revision |
| `--local` | Local state (like `git status`) |
| `--remote` | Remote state |
| `--status <type>` | Filter: `all`, `added`, `deleted`, `modified`, `staged`, `unstaged`, `untracked` |

## Moon Graph Visualization

### `moon action-graph` (alias: `moon ag`)

```bash
moon action-graph [target] [--dot] [--json] [--dependents] [--port <port>]
```

### `moon project-graph` (alias: `moon pg`)

```bash
moon project-graph [id] [--dot] [--json] [--dependents] [--port <port>]
```

### `moon task-graph` (alias: `moon tg`)

```bash
moon task-graph [target] [--dot] [--json] [--dependents] [--port <port>]
```

All graph commands launch an interactive visualizer in the browser by default.

## moon docker

### `moon docker scaffold`

Create minimal workspace skeleton for Docker layer caching. Output goes to `.moon/docker/` with two phases: `configs/` (workspace config files) and `sources/` (source files).

```bash
moon docker scaffold <...projects>
```

### `moon docker file`

Generate a multi-stage Dockerfile for a project.

```bash
moon docker file <project> [dest]
```

| Option | Description |
|--------|-------------|
| `--defaults` | Use default options, skip prompts |
| `--build-task <task>` | Task to build the project |
| `--start-task <task>` | Task to start the project |
| `--image <image>` | Base Docker image |
| `--no-prune` | Skip dependency pruning |
| `--no-setup` | Skip dependency setup (v2.0.0+) |
| `--no-toolchain` | Use system binaries instead of toolchain |
| `--template <path>` | Custom Tera template path for Dockerfile (v2.0.0+) |

### `moon docker setup`

Install toolchain and dependencies inside container. Run after `moon docker scaffold`.

```bash
moon docker setup
```

### `moon docker prune`

Remove extraneous dependencies and install production-only packages.

```bash
moon docker prune
```

## moon generate

Alias: `moon g`. Generate code from templates.

```bash
moon generate <id> [-- <vars>]
```

| Option | Description |
|--------|-------------|
| `--defaults` | Use defaults, skip prompts |
| `--dry-run` | Preview without writing |
| `--force` | Overwrite existing files |
| `--template` | Create new template scaffold |
| `--to <path>` | Destination directory |

**Examples:**
```bash
moon generate npm-package --to ./packages/new-pkg
moon generate react-component -- --name Button --withTests true
moon generate my-template --template    # Create template scaffold
moon generate my-template --dry-run     # Preview
```

### `moon template` / `moon templates`

```bash
moon templates [--json]       # List all templates
moon template <id> [--json]   # Show template details
```

## moon sync

```bash
moon sync code-owners [--force] [--clean]     # Generate CODEOWNERS
moon sync config-schemas [--force]             # Generate JSON schemas
moon sync projects                             # Sync all workspace projects
moon sync vcs-hooks [--force] [--clean]        # Sync VCS hooks
```

## moon toolchain

```bash
moon toolchain add <id> [plugin]               # Add toolchain to workspace
moon toolchain info <id> [plugin]              # Display toolchain information
```

## moon extension

```bash
moon ext <id> [-- <args>]                      # Execute WASM extension
moon extension add <id> [plugin]               # Add extension to workspace
moon extension info <id> [plugin]              # Display extension information
```

**Built-in extensions:**
```bash
moon ext download -- --url <url> --dest <path> [--name <name>]
moon ext migrate-nx [-- --bun --cleanup]
moon ext migrate-turborepo [-- --bun --cleanup]
moon ext unpack -- --src <archive> --dest <path> [--prefix <prefix>]
```

## Moon Utility Commands

```bash
moon init [dest] [--minimal] [--yes] [--force]   # Initialize workspace
moon setup                                         # Install toolchain + deps
moon clean [--lifetime <duration>]                 # Clean cache (default 7 days)
moon hash <hash1> [hash2] [--json]                # Inspect/compare hashes
moon bin <toolchain>                               # Get tool binary path
moon upgrade                                       # Upgrade moon binary
moon completions [--shell <shell>]                 # Generate shell completions
moon mcp                                           # Start MCP server for AI
moon teardown                                      # Clean up environments
```

**Installation:**
```bash
# Via proto (recommended)
proto install moon 2.1.0

# Unix / macOS / WSL
curl -fsSL https://moonrepo.dev/install/moon.sh | bash

# Windows PowerShell
irm https://moonrepo.dev/install/moon.ps1 | iex

# Via npm
npm install --save-dev @moonrepo/cli

# Upgrade
moon upgrade
```

Note: `moon upgrade` does NOT work from v1 to v2 (distribution format changed). Install fresh for v1-to-v2 migration.

## moonx

Standalone binary, stabilized in v2. Shorthand for `moon exec`.

```bash
moonx <target> [-- <args>]
```

## Environment Variables

| Variable | Description |
|----------|-------------|
| `MOON_CACHE` | Override cache mode |
| `MOON_LOG` | Override log level |
| `MOON_CONCURRENCY` | Thread pool size |
| `MOON_TOOLCHAIN_FORCE_GLOBALS` | Use PATH binaries (for Docker/Alpine) |
| `MOON_DEBUG_PROCESS_ENV` | Reveal process env vars |
| `MOON_DEBUG_PROCESS_INPUT` | Reveal process stdin |
| `MOON_SKIP_SETUP_TOOLCHAIN` | Skip toolchain setup |
| `MOON_REMOTE_HOST` | Conditionally enable remote caching |
| `MOON_INCLUDE_RELATIONS` | Include graph relations in CI (v2.0.3+) |
| `MOON_BASE` | Override base revision for affected detection |
| `MOON_HEAD` | Override head revision for affected detection |
| `MOON_NODE_VERSION` | Override Node.js version |
| `MOON_AFFECTED_FILES` | List of affected files (OS path separator) |
| `CI` | Auto-detected; `--ci` flag to force |
| `PROTO_OFFLINE` | Force offline mode |
