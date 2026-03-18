# Task System Reference

Tasks are the core unit of work in moon -- a command or script run as a child process within a project's directory.

## Table of Contents
- [Defining tasks](#defining-tasks)
- [command vs script](#command-vs-script)
- [Task types](#task-types)
- [All task fields](#all-task-fields)
- [Presets](#presets)
- [Dependencies (deps)](#dependencies-deps)
- [Inputs and caching](#inputs-and-caching)
- [Outputs](#outputs)
- [Environment variables](#environment-variables)
- [File groups](#file-groups)
- [Token variables and functions](#token-variables-and-functions)
- [Task extends](#task-extends)
- [All task options](#all-task-options)
- [Task inheritance](#task-inheritance)
- [Inherited task file schema](#inherited-task-file-schema)

## Defining Tasks

Tasks are defined in two places:

- **Project-level**: `<project>/moon.*` -- unique to that project
- **Global/inherited**: `.moon/tasks/**/*.yml` -- inherited by matching projects

```yaml
# In moon.yml (project) or .moon/tasks/node.yml (global)
tasks:
  build:
    command: 'tsc --build'
    inputs:
      - 'src/**/*'
    outputs:
      - 'dist'
```

## command vs script

This distinction is a key v2 change. Complex commands (pipes, redirects, `&&`, `||`) are no longer allowed in `command`.

| Aspect | `command` | `script` |
|--------|-----------|----------|
| Format | String or array | String only |
| Inheritance | Merges via `mergeArgs` | Always replaces |
| Additional arguments | Via `args` | Not supported |
| Passthrough arguments | Supported (`-- <args>`) | Not supported |
| Pipes, redirects | Not allowed | Allowed |
| Chaining (`&&`, `||`, `;`) | Not allowed | Allowed |
| Shell required | No | Yes |
| Token functions | Supported | Supported |

```yaml
tasks:
  # Simple command -- use command
  lint:
    command: 'eslint src/'

  # Complex operations -- use script
  validate:
    script: 'eslint . && prettier --check . && tsc --noEmit'

  report:
    script: 'jest --json > test-results.json | tee /dev/stderr'
```

If you see pipes or `&&` in a `command` field, it needs to be moved to `script`.

## Task Types

| Type | Description | How Derived |
|------|-------------|-------------|
| `build` | Generates artifacts | Has `outputs` defined |
| `run` | Long-running/persistent process | Has `preset: 'server'` or `options.persistent: true` |
| `test` | Linting, typechecking, unit tests | Default type |

## All Task Fields

| Field | Type | Description |
|-------|------|-------------|
| `command` | string | Simple command (no pipes/redirects/chains) |
| `script` | string | Complex shell command (pipes, redirects, chains) |
| `args` | string or list | Additional arguments appended to command |
| `deps` | list | Tasks that must run first |
| `inputs` | list | Files/globs/env vars for cache key |
| `outputs` | list | Files/dirs produced by the task |
| `env` | map | Environment variables |
| `extends` | string | Extend another task's config |
| `preset` | string | Apply preset configuration (`server`, `utility`) |
| `toolchains` | list | Associate with specific toolchains |
| `description` | string | Human-readable purpose |
| `options` | map | Task behavior options (see below) |

## Presets

Presets apply a bundle of default options.

### `server` (replaces v1's `local: true`)

- Disables caching
- Enables interactivity and persistence
- Streams output
- Skips CI execution
- Use for `dev`, `start`, `serve` type tasks

### `utility` (new in v2)

- Disables caching
- Enables interactivity
- Streams output
- Skips CI execution
- For one-off commands, database seeds, migrations

```yaml
tasks:
  dev:
    command: 'vite'
    preset: 'server'

  db-seed:
    command: 'prisma db seed'
    preset: 'utility'
```

## Dependencies (deps)

Tasks can depend on other tasks using target syntax:

| Pattern | Description | Where usable |
|---------|-------------|--------------|
| `app:build` | Specific project | Anywhere |
| `#tag:build` | Projects with tag | CLI, deps |
| `:build` | All projects | CLI only |
| `~:build` | Same/closest project | CLI, deps |
| `^:build` | Dependency projects | Config only |

```yaml
tasks:
  build:
    deps:
      - '~:typecheck'           # Same project
      - '^:build'               # All dependency projects
      - 'shared:build'          # Specific project

  # With args and env (v2 requires args as list of strings)
  build-with-options:
    deps:
      - target: '~:generate'
        args: ['--watch', 'false']
        env:
          TARGET_ENV: 'production'

  # Optional dependencies (may not exist)
  build-optional:
    deps:
      - target: '^:build'
        optional: true
```

## Inputs and Caching

Inputs determine the cache key. If inputs haven't changed since the last run, moon returns the cached result.

```yaml
tasks:
  build:
    inputs:
      - 'src/**/*'                 # File globs (project-relative)
      - 'tsconfig.json'           # Specific file
      - '/tsconfig.base.json'     # Workspace root file (prefix with /)
      - '@globs(sources)'         # Reference file group globs
      - '@group(configs)'         # File group items as-is
      - '$NODE_ENV'               # Environment variable
```

`inferInputs` defaults to `false` in v2 (was `true` in v1). To auto-detect inputs:
```yaml
options:
  inferInputs: true
```

## Outputs

Outputs are files/dirs produced by the task. Declaring outputs enables output caching -- moon restores them from cache on cache hits.

```yaml
tasks:
  build:
    outputs:
      - 'dist'                    # Directory
      - 'build/bundle.js'        # Specific file
```

## Environment Variables

```yaml
tasks:
  build:
    env:
      NODE_ENV: 'production'
      VERSION: '$vcsRevision'
      API_URL: '${API_BASE:-http://localhost:3000}'    # Default value syntax
      REMOVED_VAR: null                                # Remove inherited var (v2)
```

### Substitution Syntax (v2)

| Syntax | Behavior |
|--------|----------|
| `$VAR` | Empty string if not set |
| `${VAR?}` | Keep literal if not set |
| `${VAR:-default}` | Use `default` if not set or empty |
| `${VAR+alternate}` | Use `alternate` if set and non-empty |

### .env File Loading Order

1. `/.env` (workspace root)
2. `/.env.local` (workspace root)
3. `.env` (project root)
4. `.env.local` (project root)
5. `.env.<task_id>` (project root)
6. `.env.<task_id>.local` (project root)

`.local` files are NOT loaded when `CI=true`. Loading happens just before task execution (not during graph creation).

### Precedence (lowest to highest)

1. `.env` files
2. Task `env` setting
3. System environment variables

## File Groups

Reusable glob patterns defined at project or global level to reduce repetition:

```yaml
fileGroups:
  sources:
    - 'src/**/*'
    - 'types/**/*'
  tests:
    - 'tests/**/*'
    - '**/*.test.ts'
  configs:
    - '*.config.{js,ts,json}'

tasks:
  test:
    inputs:
      - '@globs(sources)'
      - '@globs(tests)'
```

## Token Variables and Functions

### Token Variables (`$variableName`)

Can appear anywhere within a value. Multiple per value supported.

**Environment:**
`$arch`, `$os`, `$osFamily`

**Workspace:**
`$workingDir`, `$workspaceRoot`

**Project:**
`$project`, `$projectAlias`, `$projectAliases` (v2), `$projectChannel`, `$projectLayer`, `$projectTitle` (renamed from `$projectName`), `$projectOwner`, `$projectRoot`, `$projectSource`, `$projectStack`, `$language`

**Task:**
`$target`, `$task`, `$taskToolchain` (renamed from `$taskPlatform`), `$taskToolchains` (v2), `$taskType`

**Date/Time:**
`$date` (YYYY-MM-DD), `$datetime` (YYYY-MM-DD_HH:MM:SS), `$time` (HH:MM:SS), `$timestamp`

**VCS:**
`$vcsBranch`, `$vcsRepository`, `$vcsRevision`

### Token Functions (`@name(arg)`)

Must be the sole content in a value. Expands to multiple values.

| Function | Description | Usable In |
|----------|-------------|-----------|
| `@group(name)` | File group items as-is | args, env, inputs, outputs |
| `@files(name)` | Expanded file paths | args, env, inputs, outputs |
| `@dirs(name)` | Expanded directory paths | args, env, inputs, outputs |
| `@globs(name)` | Glob patterns only | args, env, inputs, outputs |
| `@root(name)` | Lowest common directory | args, env, inputs, outputs |
| `@envs(name)` | Environment variables from group | inputs only |
| `@in(index)` | Input path by index | script, args |
| `@out(index)` | Output path by index | script, args |
| `@meta(key)` | Project metadata value | command, script, args, env, inputs, outputs |

**Example:**
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

## Task Extends

Extend another task's configuration within the same scope:

```yaml
tasks:
  build:
    command: 'vite build'
    env:
      NODE_ENV: 'production'

  build:staging:
    extends: 'build'
    env:
      NODE_ENV: 'staging'
      API_URL: 'https://staging-api.example.com'
```

## All Task Options

```yaml
tasks:
  example:
    command: 'cmd'
    options:
      # Caching
      cache: true                    # true, false, 'local', 'remote'
      cacheKey: 'v1'                 # Custom cache invalidation key
      cacheLifetime: '1 day'         # Duration before cache stales

      # Execution
      shell: true                    # Run in shell (default: true in v2)
      unixShell: 'bash'             # Default shell on Unix (default: 'bash')
      windowsShell: 'pwsh'          # Default shell on Windows (default: 'pwsh')
      runFromWorkspaceRoot: false    # Execute from workspace root
      timeout: 300                   # Max seconds
      retryCount: 0                  # Retry on failure

      # CI
      runInCI: true                  # true, false, 'always', 'affected', 'only', 'skip'

      # Behavior
      persistent: false              # Never-ending process (servers, watchers)
      interactive: false             # Requires stdin
      internal: false                # Only as dependency, not direct invocation
      allowFailure: false            # Don't fail pipeline on task failure

      # Affected files
      affectedFiles: false           # true, 'args', 'env', or object (v2.1.0+):
      # affectedFiles:
      #   passInputsWhenNoMatch: true
      #   filter: ['**/*.ts']
      #   ignoreProjectBoundary: false
      #   passDotWhenNoResults: false

      # Dependencies
      runDepsInParallel: true
      mutex: 'resource-name'         # Exclusive lock

      # Platform
      os: ['linux', 'macos']         # Restrict to specific OS

      # Output
      outputStyle: 'stream'          # 'buffer', 'buffer-only-failure', 'hash', 'none', 'stream'

      # Env files
      envFile: true                  # true, '.env.local', ['.env', '.env.local']

      # Inference
      inferInputs: false             # Auto-detect inputs (default: false in v2)

      # Priority (v2)
      priority: 'normal'            # 'critical', 'high', 'normal', 'low'

      # Sync phase (v2.1.0+)
      runInSyncPhase: false          # Run during moon sync commands

      # Merge strategies (for inheritance)
      merge: 'append'                # append, prepend, preserve, replace
      mergeArgs: 'append'
      mergeDeps: 'append'
      mergeEnv: 'append'
      mergeInputs: 'append'
      mergeOutputs: 'append'
      mergeToolchains: 'append'      # v2
```

### `runInCI` Values

| Value | Description |
|-------|-------------|
| `true` | Run when affected (default) |
| `false` | Never run in CI |
| `'always'` | Always run, even if not affected |
| `'affected'` | Same as `true` |
| `'only'` | Only in CI, not locally |
| `'skip'` | Same as `false` |

## Task Inheritance

Global tasks in `.moon/tasks/**/*.yml` are inherited by projects based on the `inheritedBy` setting.

### inheritedBy conditions

```yaml
# .moon/tasks/frontend.yml
inheritedBy:
  toolchains:
    or: ['javascript', 'typescript']    # Match ANY
  stacks: ['frontend']                  # Match ALL conditions
  layers: ['library', 'application']
  tags:
    or: ['react', 'vue']                # or, and, not operators
    not: ['deprecated']
  files: ['package.json']               # Projects containing this file (no globs)
  languages: ['typescript']             # Projects with specific language
```

All top-level conditions must be met (AND logic). Within `tags` and `toolchains`, supports `or` (default), `and`, and `not`. If `inheritedBy` is omitted, tasks are inherited by ALL projects.

### Merge strategies

When a project defines a task that also exists globally, they merge:

| Strategy | Behavior |
|----------|----------|
| `append` (default) | Local values added after global |
| `prepend` | Local values added before global |
| `preserve` | Keep global, ignore local |
| `replace` | Local completely overrides global |

Applies to: `args`, `deps`, `env`, `inputs`, `outputs`, `toolchains`.

```yaml
# In project moon.yml
tasks:
  lint:
    args:
      - '--fix'
    options:
      mergeArgs: 'append'      # Adds --fix after global args
      mergeDeps: 'replace'     # Completely replaces global deps
```

### Project-level inheritance control

```yaml
# In project moon.yml
workspace:
  inheritedTasks:
    include: ['lint', 'test']            # Only inherit these
    exclude: ['deploy']                  # Don't inherit these
    rename:
      buildLibrary: 'build'             # Rename inherited task
```

## Inherited Task File Schema

```yaml
# .moon/tasks/node.yml
extends: 'https://example.com/shared-tasks.yml'

inheritedBy:
  toolchains:
    or: ['javascript', 'typescript']

fileGroups:
  sources:
    - 'src/**/*'
  tests:
    - 'tests/**/*'

implicitDeps:                            # Auto-inserted deps (bypass mergeDeps)
  - '^:build'

implicitInputs:                          # Auto-included inputs (bypass mergeInputs)
  - 'package.json'

taskOptions:                             # Default options for all tasks in this file
  cache: true
  runInCI: true

tasks:
  lint:
    command: 'eslint .'
    inputs:
      - '@group(sources)'

  test:
    command: 'vitest run'
    inputs:
      - '@group(sources)'
      - '@group(tests)'
```
