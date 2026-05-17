# Advanced moon topics

MQL queries, project / task / action graphs, git hooks, environment variables, MCP integration, debugging. Reference material for when the surface in `moon-cheatsheet.md` is not enough.

For configuration schemas and CLI flags, see `moon-cheatsheet.md`. For failure-mode workflows, see `workflows.md`. For release-note details, run `npm view @moonrepo/cli versions` and read https://moonrepo.dev/blog directly -- release notes go stale fast and the verification cascade is the right surface to consult them.

## MQL (Moon Query Language)

A query language for filtering projects and tasks via `--query` (on `moon run`, `moon exec`, etc.) or as the first positional arg to `moon query`.

### Operators

| Operator | Description | Example |
|---|---|---|
| `=` / `!=` | Equals / not equals | `language=typescript` |
| `~` / `!~` | Like / not like (glob) | `projectSource~packages/*` |
| `&&` / `AND` | Logical AND | `language=typescript && projectStack=frontend` |
| `\|\|` / `OR` | Logical OR | `projectLayer=library \|\| projectLayer=tool` |
| `[...]` | List membership | `language=[javascript, typescript]` |

Cannot mix `&&` and `||` without parentheses.

### Fields

| Field | Description |
|---|---|
| `language` | Programming language |
| `project` / `projectAlias` / `projectId` | Project identifiers |
| `projectLayer` | Project layer (renamed from `projectType` in v1) |
| `projectSource` | Relative file path |
| `projectStack` | Project stack (`backend`, `data`, `frontend`, `infrastructure`, `systems`) |
| `tag` | Project tag |
| `task` | Task ID |
| `taskToolchain` | Task toolchain (renamed from `taskPlatform` in v1) |
| `taskType` | Task type (`build`, `test`, `run`) |

### Examples

```bash
moon run :build --query "language=typescript"
moon run :test --query "projectLayer=library"
moon run :lint --query "tag=react"
moon run :build --query "language=typescript && projectStack=frontend"
moon run :test --query "projectLayer=library || projectLayer=tool"
moon run :lint --query "(tag=react || tag=vue) && taskType=test"
moon run :build --query "projectSource~packages/*"
moon query projects "tag=[frontend, backend]"
```

## Project and action graphs

**Important.** `moon project-graph`, `moon task-graph`, and `moon action-graph` are **interactive by default** -- they open a browser to render the DAG. **Always pass `--json` or `--dot`** when scripting. The skill bundles `scripts/graph-json.sh` as the safe wrapper.

### Project graph

DAG of all projects and their dependencies. Used for dependency resolution and build order.

```bash
moon project-graph --json
moon project-graph app --dependents --json
moon project-graph --dot                  # for external graph tools
```

### Task graph

DAG of all tasks and their dependencies, derived from the project graph.

```bash
moon task-graph --json
moon task-graph app:build --json
```

### Action graph

DAG of actions executed when running tasks. Each action is one of:

1. `SyncWorkspace` -- health checks
2. `SetupToolchain` -- download / install tools
3. `InstallDeps` -- install dependencies
4. `SyncProject` -- sync project state
5. `RunTask` -- execute task

v2 applies transitive reduction to the graph, removing unnecessary edges for performance.

```bash
moon action-graph --json
moon action-graph app:build --json
```

v2.2 changed the JSON format: integer node IDs + separate `data` object. Update parsers accordingly.

## Git hooks

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
  sync: true                     # auto-generate hooks on every task run
  hookFormat: 'native'           # 'native' or 'bash'
```

Hooks are generated as scripts in `.moon/hooks/`; git is configured with `core.hooksPath` pointing there. Unix uses bash (`.sh`); Windows uses PowerShell (`.ps1`). Arguments come through as `$ARG0` (script path), `$ARG1`, etc. Supports git worktrees.

Manual sync: `moon sync vcs-hooks`. To disable: set `vcs.sync: false` and `moon sync vcs-hooks --clean`.

The canonical pre-commit pattern for moon repos is `moon run :format --affected --status=staged` -- this is the one that actually works with moon's affected resolution against the git index. Don't invent alternatives.

## Environment variables

| Variable | Description |
|---|---|
| `MOON_BASE` / `MOON_HEAD` | Override base / head revision for affected detection |
| `MOON_CACHE` | Override cache mode (`off`, `read`, `read-write`, `write`) |
| `MOON_LOG` | Log level (`off`, `error`, `warn`, `info`, `debug`, `trace`) |
| `MOON_CONCURRENCY` | Thread pool size |
| `MOON_TOOLCHAIN_FORCE_GLOBALS` | Use PATH binary for the named tool (Docker/Alpine) |
| `MOON_SKIP_SETUP_TOOLCHAIN` | `true`, `<tool>`, or `<tool>:<version>` |
| `MOON_REMOTE_HOST` | Conditionally enable remote caching |
| `MOON_INCLUDE_RELATIONS` | Include graph relations (v2.0.3+) |
| `MOON_AFFECTED_FILES` | List of affected files (OS path separator) |
| `MOON_DEBUG_PROCESS_ENV` | Reveal process env vars |
| `MOON_DEBUG_PROCESS_INPUT` | Reveal process stdin |
| `MOON_PIPELINE_AUTO_CLEAN_CACHE` | v2.2+ |
| `MOON_PIPELINE_CACHE_LIFETIME` | v2.2+ |
| `MOON_PIPELINE_KILL_PROCESS_THRESHOLD` | v2.2+ |
| `CI` | Auto-detected; `--ci` flag to force |
| `PROTO_OFFLINE` | Force proto offline mode |

`MOON_SKIP_SETUP_RUST` is **not** a real env var; it is silently ignored. Use `MOON_SKIP_SETUP_TOOLCHAIN=rust`.

## MCP integration

moon includes a built-in MCP (Model Context Protocol) server.

```bash
claude mcp add moon -s project \
  -e MOON_WORKSPACE_ROOT=/path/to/workspace \
  -- moon mcp
```

Available tools: `get_project`, `get_projects` (returns fragments for smaller payloads), `get_task`, `get_tasks`, `get_changed_files`, `sync_projects`, `sync_workspace`, `generate`.

## Debugging recipes

```bash
# Verbose logging
MOON_LOG=trace moon run app:build
MOON_DEBUG_PROCESS_ENV=true moon run app:build

# Resolved task / project after inheritance
moon task app:build --json
moon project app --json

# Cache hash inspection
moon hash <hash>
moon hash <hash> <other-hash>

# Affected enumeration
moon query projects --affected
moon query tasks --affected
moon query changed-files --status modified

# Graph visualisation (ALWAYS pass --json or --dot for non-interactive)
moon action-graph app:build --json
moon project-graph --json
moon task-graph app:build --json
```

When something looks wrong with task resolution, run `moon task <project>:<task> --json` and read the resolved config. Most "why did this task fire / not fire" questions answer themselves once you see the post-inheritance shape.

## Project-level configuration extras

### Code owners

```yaml
# <project>/moon.yml
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
