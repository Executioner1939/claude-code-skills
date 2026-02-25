# Workspace Configuration Reference

The `.moon/workspace.*` file is required and configures the entire workspace. It supports YAML, JSON, JSONC, TOML, HCL, and Pkl formats.

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
- [telemetry](#telemetry)
- [vcs](#vcs)
- [versionConstraint](#versionconstraint)

## extends

Inherit settings from external workspace configs. Accepts HTTPS URLs or relative file paths. Local settings take precedence over inherited ones.

```yaml
extends: 'https://raw.githubusercontent.com/org/shared-configs/main/.moon/workspace.yml'
```

## projects

**Required.** Defines where projects live. Three forms:

```yaml
# Manual map
projects:
  app: 'apps/frontend'
  api: 'apps/backend'
  shared: 'packages/shared'

# Glob patterns (auto-discover)
projects:
  - 'apps/*'
  - 'packages/*'

# Both
projects:
  sources:
    - 'apps/*'
    - 'packages/*'
  app: 'apps/frontend'   # explicit override
```

Use `globFormat: 'source-path'` in cases where directory names collide (uses full relative path as project ID).

## defaultProject

When no project scope is provided on the command line, moon uses this project. Useful for single-project repos or repos with a primary app.

```yaml
defaultProject: 'app'
```

## codeowners

Auto-generates a `CODEOWNERS` file.

```yaml
codeowners:
  globalPaths:
    '*': ['@org/platform-team']
    '*.rs': ['@org/rust-team']
  orderBy: 'project-id'   # or 'file-source' (default)
  sync: true               # regenerate when targets run
```

## constraints

Enforce project relationship rules.

```yaml
constraints:
  enforceLayerRelationships: true   # layers: automation > application > tool > library > scaffolding > configuration
  tagRelationships:
    frontend:
      - 'shared'
      - 'ui'
    backend:
      - 'shared'
      - 'db'
```

## docker

Workspace-level Docker defaults for scaffold and prune operations.

```yaml
docker:
  file:
    template: './docker/Dockerfile.tera'   # custom Tera template
  scaffold:
    configsPhaseGlobs:
      - '*.config.js'
      - 'tsconfig.json'
  prune:
    installToolchainDependencies: true
    deleteVendorDirectories: true
```

## generator

Configure template locations for code generation.

```yaml
generator:
  templates:
    - './templates'                              # local directory
    - 'git://github.com/org/templates#main'      # git repo
    - 'npm://@company/templates#1.0.0'           # npm package
    - 'https://example.com/templates.zip'        # remote archive
    - 'glob://projects/*/templates/*'            # glob pattern
```

## hasher

Controls how moon hashes inputs for cache determination.

```yaml
hasher:
  optimization: 'accuracy'        # 'accuracy' (default) or 'performance'
  walkStrategy: 'vcs'             # 'vcs' (default) or 'glob'
  ignoreMissingPatterns: false
  ignorePatterns:
    - '**/*.test.*'
  warnOnMissingInputs: true
```

- `accuracy` uses lockfiles for dependency hashing
- `performance` uses manifests (faster but less precise)
- `vcs` walk strategy uses git to find files (faster), `glob` walks the filesystem

## pipeline

Controls the task execution pipeline (renamed from `runner` in v1).

```yaml
pipeline:
  autoCleanCache: true
  cacheLifetime: '7 days'
  installDependencies: true
  logRunningCommand: false
  syncWorkspace: true
  syncProjects: true
```

- `cacheLifetime`: how long cached artifacts persist before cleanup
- `installDependencies`: auto-run InstallWorkspaceDeps/InstallProjectDeps before tasks
- `logRunningCommand`: log the resolved command, args, and working directory

## notifier

Configure notifications for pipeline events.

```yaml
notifier:
  terminalNotifications: true      # OS-level notifications
  webhookUrl: 'https://hooks.example.com/moon'
```

Webhook events are fired for pipeline start/finish, task start/finish, tool installs, etc.

## remote

Configure remote caching. Supports any Bazel Remote Execution v2 API compatible service.

```yaml
remote:
  host: 'grpcs://cache.example.com:9092'    # required
  api: 'grpc'                                # 'grpc' (default) or 'http'
  auth:
    token: '$REMOTE_CACHE_TOKEN'             # Bearer token
    headers:
      x-org-id: 'my-org'
  cache:
    compression: 'zstd'
    instanceName: 'moon-cache'
    checkIntegrity: true
  tls:
    cert: '/path/to/cert.pem'
    domain: 'cache.example.com'
  mtls:
    caCert: '/path/to/ca.pem'
    clientCert: '/path/to/client-cert.pem'
    clientKey: '/path/to/client-key.pem'
```

Can also be enabled conditionally via `MOON_REMOTE_HOST` environment variable.

### Depot (managed service)

```yaml
remote:
  host: 'grpcs://cache.depot.dev'
  auth:
    headers:
      x-depot-org: '$DEPOT_ORG_ID'
    token: '$DEPOT_TOKEN'
```

## vcs

Version control system configuration.

```yaml
vcs:
  client: 'git'
  provider: 'github'           # 'github', 'gitlab', 'bitbucket', 'other'
  defaultBranch: 'main'
  hooks:
    pre-commit:
      - 'moon run :lint'
    pre-push:
      - 'moon run :test'
  sync: true                   # auto-generate hook scripts in .moon/hooks
```

Hooks are now written to `.moon/hooks/` (not `.git/hooks/`), and git is configured to use `core.hooksPath`. This supports worktrees.

## versionConstraint

Enforce a minimum moon version across your team.

```yaml
versionConstraint: '>=2.0.0'
```
