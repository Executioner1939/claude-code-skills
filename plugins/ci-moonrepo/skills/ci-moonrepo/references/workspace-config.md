# Workspace Configuration Reference

The `.moon/workspace.*` file is the only required config file and controls the entire workspace. Supports YAML, JSON, JSONC, TOML, HCL, and Pkl formats.

## Table of Contents
- [extends](#extends)
- [projects](#projects)
- [defaultProject](#defaultproject)
- [codeowners](#codeowners)
- [constraints](#constraints)
- [docker](#docker)
- [generator](#generator)
- [hasher](#hasher)
- [pipeline](#pipeline)
- [notifier](#notifier)
- [remote](#remote)
- [vcs](#vcs)
- [experiments](#experiments)
- [telemetry](#telemetry)
- [versionConstraint](#versionconstraint)
- [Complete example](#complete-example)

## extends

Inherit settings from an external workspace config. Accepts HTTPS URLs or relative file paths. Local settings override inherited ones.

```yaml
extends: 'https://raw.githubusercontent.com/org/shared-configs/main/.moon/workspace.yml'
# or
extends: '../shared/.moon/workspace.yml'
```

## projects

**Required.** Defines where projects live. Three forms:

```yaml
# Manual map -- project ID to path
projects:
  app: 'apps/frontend'
  api: 'apps/backend'
  shared: 'packages/shared'

# Glob patterns -- auto-discover projects
projects:
  - 'apps/*'
  - 'packages/*'

# Combined globs and explicit sources
projects:
  globs:
    - 'apps/*'
    - 'packages/*'
  sources:
    root: '.'
    app: 'apps/frontend'

# Source-path based IDs (prevents name collisions)
projects:
  globs:
    - 'apps/*'
    - 'packages/*'
  globFormat: 'source-path'   # Uses full path as ID, e.g., "apps/web"
```

## defaultProject

Fallback project when no scope is provided on the command line. Useful for single-project repos or repos with a primary app.

```yaml
defaultProject: 'app'
```

## codeowners

Auto-generate a `CODEOWNERS` file from project configuration.

```yaml
codeowners:
  sync: true                          # Regenerate on target runs (default: false)
  orderBy: 'project-id'              # 'file-source' (default) or 'project-id'
  globalPaths:
    '*': ['@admins']
    '/.github/': ['@infra']
    '*.rs': ['@rust-team']
```

## constraints

Enforce dependency rules between projects based on layers and tags.

```yaml
constraints:
  enforceLayerRelationships: true     # Validates hierarchy: automation > application > tool > library > scaffolding > configuration
  tagRelationships:
    next: ['react']
    frontend: ['shared', 'ui']
    backend: ['shared', 'db']
```

## docker

Workspace-level Docker defaults for scaffold, file generation, and prune operations.

```yaml
docker:
  file:
    template: './docker/Dockerfile.tera'     # Custom Tera template
  scaffold:
    configsPhaseGlobs:                       # Extra files for the configs phase
      - '*.config.js'
      - '.browserslistrc'
  prune:
    installToolchainDependencies: true       # Reinstall prod deps (default: true)
    deleteVendorDirectories: true            # Remove node_modules, etc. (default: true)
```

## generator

Configure template locations for code generation (`moon generate`).

```yaml
generator:
  templates:
    - './templates'                                 # Local directory
    - 'file://./shared-templates'                   # Explicit file path
    - 'git://github.com/org/templates#main'         # Git repo + branch/tag
    - 'npm://@company/moon-templates#2.0.0'         # npm package + version
    - 'https://example.com/templates.tar.gz'        # Remote archive
    - 'glob://projects/*/templates/*'               # Glob pattern
```

## hasher

Controls how moon hashes inputs for cache key determination.

```yaml
hasher:
  optimization: 'accuracy'        # 'accuracy' (default, parses lockfile) or 'performance' (uses manifest)
  walkStrategy: 'vcs'             # 'vcs' (default, uses git) or 'glob' (filesystem walk)
  warnOnMissingInputs: true       # default: true
  ignorePatterns:
    - '**/*.log'
  ignoreMissingPatterns:           # default: ['**/.env', '**/.env.*']
    - 'optional/**/*'
```

- `accuracy` parses lockfiles for precise dependency hashing
- `performance` uses manifests (faster but less precise)
- `vcs` walk uses git to enumerate files (faster); `glob` does a filesystem walk

## pipeline

Controls the task execution pipeline. Renamed from `runner` in v1.

```yaml
pipeline:
  autoCleanCache: true                     # default: true
  cacheLifetime: '7 days'                  # default: '7 days'
  installDependencies: true                # true, false, or list of toolchain IDs
  syncProjects: true                       # true, false, or list of project IDs
  syncWorkspace: true                      # default: true
  inheritColorsForPipedTasks: true         # default: true
  logRunningCommand: false                 # default: false -- log resolved command + args
  killProcessThreshold: 2000              # ms, default: 2000
```

## notifier

Configure webhook and terminal notifications for pipeline events.

```yaml
notifier:
  webhookUrl: 'https://hooks.example.com/moon'
  webhookAcknowledge: false               # Wait for webhook response (default: false)
  terminalNotifications: 'always'         # 'always', 'failure', 'success', 'task-failure'
```

Webhook events: `pipeline.started`, `pipeline.finished`, `pipeline.aborted`, `task.running`, `task.ran`, `dependencies.installing`, `dependencies.installed`, `toolchain.*`

## remote

Configure remote caching. Compatible with any Bazel Remote Execution v2 API service.

```yaml
remote:
  host: 'grpcs://cache.example.com:9092'  # Required. grpc://, grpcs://, http://, https://
  api: 'grpc'                             # 'grpc' (default) or 'http'

  auth:
    token: 'CACHE_TOKEN'                  # Env var name for Bearer token
    headers:
      'X-Custom-Header': 'value'

  cache:
    compression: 'zstd'                   # 'none' (default) or 'zstd'
    instanceName: 'moon-outputs'          # Cache partition identifier
    localReadOnly: false                  # Download-only locally, upload in CI
    verifyIntegrity: false                # Validate blob digests

  tls:
    cert: 'certs/ca.pem'
    domain: 'cache.example.com'
    assumeHttp2: false

  mtls:
    caCert: 'certs/ca.pem'
    clientCert: 'certs/client.pem'
    clientKey: 'certs/client.key'
    domain: 'cache.example.com'
    assumeHttp2: false
```

Can be conditionally enabled via `MOON_REMOTE_HOST` environment variable.

### Depot (managed cloud service)

```yaml
remote:
  host: 'grpcs://cache.depot.dev'
  auth:
    token: 'DEPOT_TOKEN'
    headers:
      'X-Depot-Org': '<your-org-id>'
```

## vcs

Version control system configuration, including git hooks.

```yaml
vcs:
  client: 'git'                          # default: 'git'
  provider: 'github'                     # 'github' (default), 'gitlab', 'bitbucket', 'other'
  defaultBranch: 'main'                  # default: 'master'
  remoteCandidates:                      # default: ['origin', 'upstream']
    - 'origin'
    - 'upstream'
  sync: true                             # Auto-generate + link hooks (default: false)
  hookFormat: 'native'                   # 'native' (default) or 'bash'

  hooks:
    pre-commit:
      - 'moon run :lint :format --affected --status=staged'
    commit-msg:
      - 'commitlint --edit $ARG1'
    pre-push:
      - 'moon run :test --affected'
```

Hooks are written to `.moon/hooks/` (not `.git/hooks/`). Git is configured with `core.hooksPath`. Supports worktrees. Scripts: `.sh` on Unix, `.ps1` on Windows. Arguments: `$ARG0` (script), `$ARG1`, `$ARG2`, etc.

## experiments

```yaml
experiments:
  fasterGlobWalk: true                   # Concurrent glob with caching (default: true)
  gitV2: true                            # Improved Git handling (default: true in v2)
```

## telemetry

```yaml
telemetry: true                          # default: true
```

## versionConstraint

Enforce a minimum moon version across your team.

```yaml
versionConstraint: '>=2.0.0'
```

## Complete Example

```yaml
# .moon/workspace.yml
extends: 'https://raw.githubusercontent.com/org/configs/main/.moon/workspace.yml'

projects:
  - 'apps/*'
  - 'packages/*'

defaultProject: 'web-app'

vcs:
  provider: 'github'
  defaultBranch: 'main'
  hooks:
    pre-commit:
      - 'moon run :lint :format --affected --status=staged'
  sync: true

pipeline:
  cacheLifetime: '7 days'
  logRunningCommand: true

remote:
  host: 'grpcs://cache.depot.dev'
  auth:
    token: 'DEPOT_TOKEN'
    headers:
      'X-Depot-Org': 'my-org'
  cache:
    compression: 'zstd'

generator:
  templates:
    - './templates'
    - 'git://github.com/org/templates#main'

codeowners:
  sync: true
  orderBy: 'project-id'

constraints:
  enforceLayerRelationships: true

hasher:
  optimization: 'accuracy'

versionConstraint: '>=2.0.0'
```
