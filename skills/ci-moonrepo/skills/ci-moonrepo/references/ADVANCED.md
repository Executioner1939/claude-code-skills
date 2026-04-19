# Advanced Topics Reference

MQL queries, project/action graphs, git hooks, environment variables, token functions, MCP integration, and debugging.

## Table of Contents
- [MQL (Moon Query Language)](#mql-moon-query-language)
- [Project and action graphs](#project-and-action-graphs)
- [Git hooks](#git-hooks)
- [Environment variables](#environment-variables)
- [Project configuration](#project-configuration)
- [MCP integration](#mcp-integration)
- [Debugging](#debugging)
- [Release history](#release-history)

## MQL (Moon Query Language)

MQL is a query language for filtering projects and tasks.

### Comparison operators

| Operator | Description | Example |
|----------|-------------|---------|
| `=` | Equals | `language=typescript` |
| `!=` | Not equals | `language!=javascript` |
| `~` | Like (glob) | `projectSource~packages/*` |
| `!~` | Not like | `tag!~*-app` |

### List syntax

```
language=[javascript, typescript]
```

### Logical operators

| Operator | Description |
|----------|-------------|
| `&&` or `AND` | Logical AND |
| `\|\|` or `OR` | Logical OR |

Cannot mix `&&` and `||` without parentheses.

### Grouping

```
(tag=react || tag=vue) && taskType=test
```

Groups can be nested.

### Available fields

| Field | Description |
|-------|-------------|
| `language` | Programming language |
| `project` | Project name or alias |
| `projectAlias` | Project alias |
| `projectId` | Project identifier |
| `projectLayer` | Project layer (renamed from `projectType` in v1) |
| `projectSource` | Relative file path |
| `projectStack` | Project stack |
| `tag` | Project tag |
| `task` | Task ID |
| `taskToolchain` | Task toolchain (renamed from `taskPlatform` in v1) |
| `taskType` | Task type (build, test, run) |

### Examples

```bash
moon run :build --query "language=typescript"
moon run :test --query "projectLayer=library"
moon run :lint --query "tag=react"
moon run :build --query "language=typescript && projectStack=frontend"
moon run :test --query "projectLayer=library || projectLayer=tool"
moon run :lint --query "(tag=react || tag=vue) && taskType=test"
moon run :build --query "projectSource~packages/*"
moon run :test --query "project~*-app"
moon query projects "tag=[frontend, backend]"
```

## Project and Action Graphs

### Project graph

DAG of all projects and their dependencies. Used for dependency resolution and build order.

```bash
moon project-graph                    # All projects
moon project-graph app --dependents   # Specific project + dependents
moon project-graph --dot              # DOT format for external tools
moon project-graph --json             # JSON format
```

### Task graph

DAG of all tasks and their dependencies, derived from the project graph.

```bash
moon task-graph
moon task-graph app:build
```

### Action graph

DAG of actions executed when running tasks. Includes:

1. `SyncWorkspace` -- Health checks
2. `SetupToolchain` -- Download/install tools
3. `InstallDeps` -- Install dependencies
4. `SyncProject` -- Sync project state
5. `RunTask` -- Execute task

v2 applies "transitive reduction" to the graph, removing unnecessary edges for better performance.

```bash
moon action-graph
moon action-graph app:build
```

## Git Hooks

### Configuration

```yaml
# .moon/workspace.yml
vcs:
  hooks:
    pre-commit:
      - 'moon run :lint :format --affected --status=staged'
    commit-msg:
      - 'commitlint --edit $ARG1'
    pre-push:
      - 'moon run :test --affected'
  sync: true                     # Auto-generate hooks
  hookFormat: 'native'           # 'native' or 'bash'
```

### How it works

- Hooks generated as scripts in `.moon/hooks/`
- Git configured with `core.hooksPath` pointing to `.moon/hooks/`
- Unix: Bash scripts (`.sh`), Windows: PowerShell (`.ps1`)
- Commands execute from repository root
- Arguments: `$ARG0` (script path), `$ARG1`, `$ARG2`, etc.
- Supports worktrees

### Managing hooks

- **Auto-generate**: Set `vcs.sync: true` (regenerated on every task run)
- **Manual sync**: `moon sync vcs-hooks`
- **Disable**: `vcs.sync: false` + `moon sync vcs-hooks --clean`

## Environment Variables

### Moon environment variables

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
| `MOON_INCLUDE_RELATIONS` | Include graph relations (v2.0.3+) |
| `MOON_BASE` | Override base revision for affected detection |
| `MOON_HEAD` | Override head revision for affected detection |
| `MOON_NODE_VERSION` | Override Node.js version |
| `MOON_AFFECTED_FILES` | List of affected files (OS path separator) |
| `CI` | Auto-detected; `--ci` flag to force |
| `PROTO_OFFLINE` | Force offline mode |

## Project Configuration

### Core metadata

```yaml
# <project>/moon.yml
id: 'web-app'                    # Override inferred ID
language: 'typescript'           # bash, batch, go, javascript, php, python, ruby, rust, typescript, unknown
layer: 'application'             # application, automation, configuration, library, scaffolding, tool, unknown
stack: 'frontend'                # backend, data (new in v2), frontend, infrastructure, systems, unknown

project:
  title: 'Web Application'      # Human-readable name (renamed from name in v1)
  description: 'Main web app'
  owner: '@frontend-team'
  channel: '#web-app'
  maintainers:
    - 'alice'
    - 'bob'
  customField: 'value'          # Custom metadata (v2.0.0+)

tags:
  - 'react'
  - 'typescript'
  - 'frontend-team'
```

### Dependencies

```yaml
dependsOn:
  - 'shared-utils'                  # Simple reference
  - id: 'api-client'
    scope: 'production'             # production, development, build, peer
```

### Code owners (project-level)

```yaml
owners:
  defaultOwner: '@frontend'
  requiredApprovals: 2
  optional: false                    # GitLab only
  paths:
    'src/': ['@frontend']
    '*.config.js': ['@frontend-infra']
  customGroups:                      # Bitbucket
    frontend: ['user1', 'user2']
```

### Toolchain overrides

```yaml
toolchains:
  default: 'node'
  node:
    version: '20.0.0'
  typescript:
    syncProjectReferences: false
```

### Workspace inheritance control

```yaml
workspace:
  inheritedTasks:
    include: ['lint', 'test']
    exclude: ['deploy']
    rename:
      buildApplication: 'build'
```

## MCP Integration

Moon includes a built-in MCP (Model Context Protocol) server for AI integrations.

### Setup

```bash
claude mcp add moon -s project \
  -e MOON_WORKSPACE_ROOT=/path/to/workspace \
  -- moon mcp
```

### Available MCP tools

| Tool | Description |
|------|-------------|
| `get_project` | Get project details |
| `get_projects` | List all projects (returns fragments for smaller payloads) |
| `get_task` | Get task details |
| `get_tasks` | List all tasks (returns fragments) |
| `get_changed_files` | Get VCS changes |
| `sync_projects` | Sync projects |
| `sync_workspace` | Sync workspace |
| `generate` | Run code generator (v2+, JSON schema fixed in v2.1.0) |

## Debugging

```bash
# Verbose logging
MOON_LOG=trace moon run app:build
MOON_DEBUG_PROCESS_ENV=true moon run app:build

# Inspect task configuration
moon task app:build --json

# Inspect hash
moon hash abc123

# Compare two hashes
moon hash abc123 def456

# Query affected
moon query affected
moon query changed-files --status modified

# Visualize graphs
moon action-graph app:build
moon project-graph
moon task-graph app:build
```

## Release History

### v2.1.0 (March 16, 2026) -- Latest

- Improved local/remote environment detection (GitHub Codespaces, Gitpod)
- Duplicate project aliases no longer hard error
- 3 new `affectedFiles` settings: `filter`, `ignoreProjectBoundary`, `passDotWhenNoResults`
- New `runInSyncPhase` task option
- New `inheritAliases` and `installDependencies` per-toolchain settings
- `--plan` option for `moon exec`
- Go: `go list --deps` for project relationships
- Python: Normalized package names to PEP 503
- TypeScript: `pruneProjectReferences` setting
- Fixed JSON schema in MCP `generate` tool
- Fixed `$projectTitle` and `$projectAliases` token substitution
- Fixed `bash` availability fallback (falls back to `sh`)

### v2.0.4 (March 6, 2026)

- JavaScript: `*` version support, reworked dedup detection
- Python: `pyproject.toml` dependency reading

### v2.0.3 (February 26, 2026)

- Re-release of failed v2.0.2
- Disabled shallow checkout hard error in CI
- Added `MOON_INCLUDE_RELATIONS` env var
- Added `.env`/`.env.*` to default `hasher.ignoreMissingPatterns`

### v2.0.1 (February 20, 2026)

- Fixed `moon upgrade` to use proto if moon managed by proto
- Fixed WASM serialization errors

### v2.0.0 (February 18, 2026)

- Major release "Phobos"
- WASM plugin toolchain system
- Multiple config format support (JSON, TOML, HCL, Pkl)
- Task `script` field for complex commands
- Deep merge for task inheritance
- `utility` preset, `data` stack
- Stabilized remote caching and `moonx`
- Interactive prompts for commands without identifiers
