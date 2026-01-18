# Moon Core Concepts

Understanding moon's fundamental concepts for effective monorepo management.

## Workspace

A **workspace** is a directory containing projects, managed by moon. The workspace root is marked by the `.moon` folder.

**Responsibilities:**
- VCS integration (Git)
- Workspace-wide configuration
- Housing projects in the project graph
- Running tasks via the action graph

**Configuration:** `.moon/workspace.yml`

## Project

A **project** is a library, application, package, or tool within the workspace containing source files, tests, and resources.

### Project IDs

Unique identifier for referencing projects:
- Supports: camelCase, kebab-case, snake_case
- Characters: unicode letters, 0-9, `_`, `-`, `/`, `.`
- Must start with a letter

### Project Aliases

Secondary names inferred from the language ecosystem:
- JavaScript: `name` field from `package.json`
- Rust: `name` from `Cargo.toml`

### Project Dependencies

**Explicit:** Defined via `dependsOn` in `moon.yml`:
```yaml
dependsOn:
  - 'shared-utils'
  - id: 'api-client'
    scope: 'production'
```

**Implicit:** Auto-discovered from:
- `package.json` dependencies
- `Cargo.toml` dependencies
- Import statements

### Dependency Scopes

| Scope | Description |
|-------|-------------|
| `production` | Required in production |
| `development` | Dev-only, pruned in prod |
| `build` | Build-time only |
| `peer` | Peer requirement |

### Project Layers

| Layer | Description |
|-------|-------------|
| `application` | Runnable applications |
| `library` | Reusable/publishable code |
| `tool` | Internal tools, CLIs |
| `automation` | Testing suites |
| `configuration` | Config/infrastructure |
| `scaffolding` | Templates/generators |

### Project Stacks

| Stack | Description |
|-------|-------------|
| `frontend` | Client-side UIs |
| `backend` | Server-side APIs |
| `infrastructure` | Cloud/server infra |
| `data` | Databases, data sources |
| `systems` | Low-level systems |

## Task

A **task** is a command that runs in a project's context as a child process.

### Task Types

| Type | Description | Derived From |
|------|-------------|--------------|
| `build` | Generates artifacts | Has `outputs` |
| `run` | Long-running process | Has `preset: server` |
| `test` | Assertions (lint, typecheck, unit) | Default |

### Task Modes

**Local Only:** Runs locally, not in CI
```yaml
tasks:
  dev:
    command: 'npm run dev'
    options:
      runInCI: false
```

**Internal Only:** Not for direct invocation, used as dependency
```yaml
tasks:
  internal-build:
    command: 'build-internal'
    options:
      internal: true
```

**Interactive:** Requires stdin
```yaml
tasks:
  prompt:
    command: 'npm init'
    options:
      interactive: true
```

**Persistent:** Never completes (servers, watchers)
```yaml
tasks:
  server:
    command: 'npm run server'
    preset: 'server'
```

### Command vs Script

**Command:** Single binary, supports inheritance merging
```yaml
tasks:
  build:
    command: 'vite'
    args: ['build']
```

**Script:** Multiple commands with pipes/redirects, replaces on inheritance
```yaml
tasks:
  deploy:
    script: 'npm run build && npm run upload'
```

## Target

A **target** pairs a scope to a task: `scope:task`

### Target Scopes

| Pattern | Description | Usage |
|---------|-------------|-------|
| `app:build` | Specific project | Anywhere |
| `#tag:build` | Projects with tag | CLI, deps |
| `:build` | All projects | CLI only |
| `~:build` | Closest project | CLI only |
| `^:build` | Dependencies | Config only |

**Examples:**
```bash
# CLI usage
moon run app:build          # Specific project
moon run :build             # All projects
moon run ~:build            # Closest from cwd
moon run '#frontend:build'  # By tag (quote for shell)

# In task deps
tasks:
  build:
    deps:
      - '^:build'    # All dependencies
      - '~:typecheck' # Self
```

## Tokens

Variables and functions for dynamic task configuration.

### Token Variables

Format: `$variableName`

**Environment:**
| Variable | Description |
|----------|-------------|
| `$arch` | Host architecture |
| `$os` | Operating system |
| `$osFamily` | `unix` or `windows` |

**Workspace:**
| Variable | Description |
|----------|-------------|
| `$workingDir` | Current working directory |
| `$workspaceRoot` | Workspace root path |

**Project:**
| Variable | Description |
|----------|-------------|
| `$project` | Project ID |
| `$projectAlias` | Project alias |
| `$projectRoot` | Project root path |
| `$projectSource` | Relative path from workspace |
| `$projectTitle` | Human-readable name |
| `$projectOwner` | Project owner |
| `$projectLayer` | Project layer |
| `$projectStack` | Project stack |
| `$language` | Primary language |

**Task:**
| Variable | Description |
|----------|-------------|
| `$target` | Full target (project:task) |
| `$task` | Task ID |
| `$taskToolchain` | Task toolchain |
| `$taskType` | Task type |

**Date/Time:**
| Variable | Description |
|----------|-------------|
| `$date` | YYYY-MM-DD |
| `$datetime` | YYYY-MM-DD_HH:MM:SS |
| `$time` | HH:MM:SS |
| `$timestamp` | Unix timestamp |

**VCS:**
| Variable | Description |
|----------|-------------|
| `$vcsBranch` | Current branch |
| `$vcsRepository` | Repository slug |
| `$vcsRevision` | Current commit |

### Token Functions

Format: `@name(arg)` - Must be sole content in value

**File Group Functions:**
| Function | Description |
|----------|-------------|
| `@group(name)` | File group items as-is |
| `@files(name)` | Expanded file paths |
| `@dirs(name)` | Expanded directory paths |
| `@globs(name)` | Only glob patterns |
| `@root(name)` | Lowest common directory |
| `@envs(name)` | Environment variables |

**Input/Output Functions:**
| Function | Description |
|----------|-------------|
| `@in(index)` | Input path by index |
| `@out(index)` | Output path by index |

**Metadata Function:**
| Function | Description |
|----------|-------------|
| `@meta(key)` | Project metadata value |

**Examples:**
```yaml
tasks:
  build:
    command: 'build'
    args:
      - '--out'
      - '@out(0)'
    inputs:
      - '@group(sources)'
    outputs:
      - 'dist/$project'
    env:
      VERSION: '$vcsRevision'
```

## MQL (Moon Query Language)

SQL-like syntax for filtering projects and tasks.

### Comparisons

| Operator | Description |
|----------|-------------|
| `=` | Equals |
| `!=` | Not equals |
| `~` | Like (glob matching) |
| `!~` | Not like |

**List syntax:** `field=[value1, value2]`

### Conditions

| Operator | Description |
|----------|-------------|
| `&&` / `AND` | Logical AND |
| `\|\|` / `OR` | Logical OR |

**Note:** Cannot mix `&&` and `||` in same expression without parentheses.

### Fields

| Field | Description |
|-------|-------------|
| `language` | Programming language |
| `project` | Project name or alias |
| `projectAlias` | Project alias |
| `projectId` | Project ID |
| `projectSource` | Project path |
| `projectLayer` | Project layer |
| `projectStack` | Project stack |
| `tag` | Project tag |
| `task` | Task ID |
| `taskToolchain` | Task toolchain |
| `taskType` | Task type |

### Examples

```bash
# Basic queries
moon run :build --query "language=typescript"
moon run :test --query "projectLayer=library"
moon run :lint --query "tag=react"

# Complex queries
moon run :build --query "language=typescript && projectStack=frontend"
moon run :test --query "projectLayer=library || projectLayer=tool"
moon run :lint --query "(tag=react || tag=vue) && taskType=test"

# Glob matching
moon run :build --query "projectSource~packages/*"
moon run :test --query "project~*-app"
```

## File Patterns

Rust-based glob patterns (not JavaScript-based).

### Syntax

| Pattern | Description |
|---------|-------------|
| `*` | 0+ characters (not `/`) |
| `**` | 0+ directories |
| `?` | Exactly 1 character |
| `[abc]` | One of characters |
| `[!abc]` | Not one of characters |
| `[a-z]` | Character range |
| `{a,b}` | Alternation |
| `!` | Negation (at start) |

### Path Resolution

**Project-relative (default):**
```yaml
inputs:
  - 'src/**/*'      # ./project/src/**/*
  - 'package.json'  # ./project/package.json
```

**Workspace-relative (prefix with `/`):**
```yaml
inputs:
  - '/package.json'        # ./package.json (root)
  - '/tsconfig.base.json'  # ./tsconfig.base.json (root)
```

## Task Inheritance

Define tasks once, inherit by many projects.

### Global Tasks

Location: `.moon/tasks/all.yml` (inherited by all projects)

```yaml
tasks:
  lint:
    command: 'eslint .'
  test:
    command: 'jest'
```

### Conditional Inheritance

```yaml
# .moon/tasks/frontend.yml
inheritedBy:
  toolchains:
    or: ['javascript', 'typescript']
  stacks: ['frontend']
  layers: ['library', 'application']
  tags: ['react']

tasks:
  # Only inherited by matching projects
```

### Merge Strategies

| Strategy | Description |
|----------|-------------|
| `append` | Local after global (default) |
| `prepend` | Local before global |
| `preserve` | Keep global values |
| `replace` | Local replaces global |

```yaml
tasks:
  build:
    args:
      - '--production'
    options:
      mergeArgs: 'prepend'  # Prepend to inherited args
```

### Controlling Inheritance

```yaml
# moon.yml
workspace:
  inheritedTasks:
    include:
      - 'lint'
      - 'test'
    exclude:
      - 'deploy'
    rename:
      buildLibrary: 'build'
```

## Graphs

### Project Graph

DAG of all projects and their dependencies.

**Visualize:**
```bash
moon project-graph
moon project-graph app --dependents
```

### Task Graph

DAG of all tasks and their dependencies, derived from project graph.

**Visualize:**
```bash
moon task-graph
moon task-graph app:build
```

### Action Graph

DAG of actions executed when running tasks. Includes:
1. `SyncWorkspace` - Health checks
2. `SetupToolchain` - Download/install tools
3. `InstallDeps` - Install dependencies
4. `SyncProject` - Sync project state
5. `RunTask` - Execute task

**Visualize:**
```bash
moon action-graph
moon action-graph app:build
```

## Caching

Hash-based incremental builds.

### Hash Sources

- Command and arguments
- Input files
- Output targets
- Environment variables
- Project dependencies
- Task dependencies
- Language-specific configs (tsconfig, package.json)

### Cache Structure

```
.moon/cache/
  hashes/<hash>.json      # Hash manifests
  outputs/<hash>.tar.gz   # Task output archives
  states/<project>/
    snapshot.json         # Project state
    <task>/
      lastRun.json        # Last run info
      stdout.log          # Task output
```

### Cache Operations

```bash
# Inspect hash
moon hash <hash>

# Compare hashes
moon hash <hash1> <hash2>

# Clean cache
moon clean --lifetime "7 days"
```
