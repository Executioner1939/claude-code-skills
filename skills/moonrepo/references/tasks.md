# Task System Reference

Tasks are the core unit of work in moon — a command or script run as a child process within a project's context.

## Table of Contents
- [Defining tasks](#defining-tasks)
- [command vs script](#command-vs-script)
- [Task fields](#task-fields)
- [Presets](#presets)
- [Task inheritance](#task-inheritance)
- [Inputs and caching](#inputs-and-caching)
- [Outputs](#outputs)
- [Dependencies (deps)](#dependencies-deps)
- [Environment variables](#environment-variables)
- [File groups](#file-groups)
- [Task options](#task-options)

## Defining tasks

Tasks are defined in two places:
- **Project-level**: `<project>/moon.*` — unique to that project
- **Global/inherited**: `.moon/tasks/**/*.yml` — inherited by matching projects

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

**`command`** — for simple, single commands. No pipes, redirects, or chaining allowed in v2.

```yaml
tasks:
  lint:
    command: 'eslint src/'
```

**`script`** — for complex shell operations with pipes, redirects, `&&`, `||`, etc.

```yaml
tasks:
  validate:
    script: 'eslint . && prettier --check . && tsc --noEmit'

  report:
    script: 'jest --json > test-results.json | tee /dev/stderr'
```

This is a key v2 change. If you see pipes or `&&` in `command`, it needs to be moved to `script`.

## Task fields

| Field | Type | Description |
|-------|------|-------------|
| `command` | string | Simple command to execute |
| `script` | string | Complex shell command (pipes, redirects, chains) |
| `args` | list | Additional arguments appended to command |
| `deps` | list | Tasks that must run first |
| `inputs` | list | Files/globs/env vars that determine cache key |
| `outputs` | list | Files/dirs produced by the task (for caching) |
| `env` | map | Environment variables |
| `extends` | string | Extend another task's config |
| `preset` | string | Apply a preset configuration |
| `toolchains` | list | Associate with specific toolchains |
| `options` | map | Task behavior options |

## Presets

Presets apply a set of default options. Available presets:

**`server`** (replaces v1's `local: true`):
- Disables caching
- Enables interactivity
- Streams output
- Skips CI execution
- Use for `dev`, `start`, `serve` type tasks

**`utility`** (new in v2):
- Disables caching
- Enables interactivity
- Streams output
- Skips CI execution
- For one-off commands and scripts

```yaml
tasks:
  dev:
    command: 'vite'
    preset: 'server'

  db-seed:
    command: 'prisma db seed'
    preset: 'utility'
```

## Task inheritance

Global tasks in `.moon/tasks/**/*.yml` are inherited by projects based on the `inheritedBy` setting.

### inheritedBy conditions

```yaml
# .moon/tasks/node.yml
inheritedBy:
  toolchains: ['node']          # only node projects
  stacks: ['frontend']          # only frontend stack
  layers: ['application']       # only application layer
  tags:
    or: ['web', 'mobile']       # projects tagged web OR mobile
  files: ['package.json']       # projects containing this file

tasks:
  lint:
    command: 'eslint .'
```

If `inheritedBy` is omitted, the tasks are inherited by ALL projects.

### Logical operators for tags/toolchains

- `or` (default): match ANY
- `and`: match ALL
- `not`: match NONE

### Merge strategies

When a project defines a task that also exists globally, they merge. Each field supports a merge strategy:

| Strategy | Behavior |
|----------|----------|
| `append` (default) | Local values added after global |
| `prepend` | Local values added before global |
| `preserve` | Keep global values, ignore local |
| `replace` | Local completely overrides global |

```yaml
# In project moon.yml
tasks:
  lint:
    args:
      - '--fix'
    options:
      mergeArgs: 'append'      # adds --fix after global args
      mergeDeps: 'replace'     # completely replaces global deps
```

### Excluding inherited tasks

```yaml
# In project moon.yml
workspace:
  inheritedTasks:
    exclude: ['typecheck']     # don't inherit this task
```

## Inputs and caching

Inputs determine the cache key. If inputs haven't changed since the last run, moon returns the cached result.

```yaml
tasks:
  build:
    inputs:
      - 'src/**/*'                 # file globs
      - 'tsconfig.json'            # specific files
      - '@globs(sources)'          # reference a file group
      - '$NODE_ENV'                # environment variable (prefix with $)
```

The `inferInputs` option defaults to `false` in v2. If you want moon to auto-detect inputs, set it explicitly:
```yaml
options:
  inferInputs: true
```

## Outputs

Outputs are files/dirs created by the task. Declaring them enables output caching — moon restores them from cache on cache hits.

```yaml
tasks:
  build:
    outputs:
      - 'dist'                    # directory
      - 'build/bundle.js'         # specific file
```

## Dependencies (deps)

Tasks can depend on other tasks using target syntax:

```yaml
tasks:
  build:
    deps:
      - '~:typecheck'            # same project, "typecheck" task
      - '^:build'                # all dependency projects, "build" task
      - 'shared:build'           # specific project "shared", task "build"
```

Dependency args (v2 requires list of strings):
```yaml
deps:
  - target: '~:generate'
    args: ['--watch', 'false']   # must be list, not string
```

## Environment variables

```yaml
tasks:
  build:
    env:
      NODE_ENV: 'production'
      API_URL: '${API_BASE:-http://localhost:3000}'
```

### Substitution syntax (v2)

| Syntax | Behavior |
|--------|----------|
| `$VAR` | Empty string if not set |
| `${VAR?}` | Keep literal `${VAR?}` if not set |
| `${VAR:-default}` | Use `default` if not set or empty |
| `${VAR+alternate}` | Use `alternate` if set and non-empty |

### .env file loading

Moon auto-discovers `.env` files in this order:
1. `.env`
2. `.env.local`
3. `.env.<task_id>`
4. `.env.<task_id>.local`

`.local` files are NOT loaded when `CI=true`. Loading happens just before execution (not during graph creation).

### Precedence (lowest to highest)
1. `.env` files
2. Task `env` setting
3. System environment variables

## File groups

Reusable glob patterns to reduce repetition:

```yaml
fileGroups:
  sources:
    - 'src/**/*'
  tests:
    - 'tests/**/*'
    - '**/*.test.*'
  configs:
    - '*.config.*'
    - 'tsconfig.json'

tasks:
  test:
    inputs:
      - '@globs(sources)'
      - '@globs(tests)'
```

## Task options

```yaml
tasks:
  build:
    options:
      cache: true                    # enable caching (default true)
      runInCI: true                  # run in CI (default true)
      retryCount: 2                  # retry on failure
      outputStyle: 'stream'          # 'buffer', 'stream', 'none'
      persistent: false              # keep running (for servers)
      interactive: false             # stdin forwarding
      shell: true                    # run in shell (default true in v2)
      unixShell: 'bash'             # default shell on unix
      windowsShell: 'pwsh'          # default shell on windows
      affectedFiles:                 # configure affected file handling
        passInputsWhenNoMatch: true
      envFile: true                  # auto-discover .env files (true = standard discovery)
      inferInputs: false             # auto-detect inputs (default false in v2)
```
