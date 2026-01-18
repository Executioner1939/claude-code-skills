# Moon Configuration Reference

Complete configuration schemas for all moon config files.

## File Overview

| File | Location | Required | Purpose |
|------|----------|----------|---------|
| `workspace.yml` | `.moon/` | Yes | Workspace settings |
| `toolchains.yml` | `.moon/` | No | Language/runtime config |
| `extensions.yml` | `.moon/` | No | WASM extensions |
| `tasks/*.yml` | `.moon/tasks/` | No | Inherited tasks |
| `moon.yml` | Project root | No | Project config |
| `template.yml` | Template folder | Yes* | Template config |

## Workspace Configuration (`.moon/workspace.yml`)

### Projects

```yaml
# Map format (explicit IDs)
projects:
  app: 'apps/web'
  api: 'apps/api'
  shared: 'packages/shared'

# Glob format (IDs from folder names)
projects:
  - 'apps/*'
  - 'packages/*'

# Combined format
projects:
  globs:
    - 'apps/*'
    - 'packages/*'
  sources:
    root: '.'
```

### VCS Configuration

```yaml
vcs:
  defaultBranch: 'main'
  provider: 'github'  # github, gitlab, bitbucket, other
  client: 'git'

  # VCS Hooks
  hooks:
    pre-commit:
      - 'moon run :lint :format --affected --status=staged'
    commit-msg:
      - 'commitlint --edit $ARG1'

  sync: true  # Auto-generate hooks
  hookFormat: 'native'  # native, bash
```

### Pipeline Configuration

```yaml
pipeline:
  autoCleanCache: true
  cacheLifetime: '7 days'
  installDependencies: true  # or ['node']
  syncProjects: true         # or ['app', 'lib']
  syncWorkspace: true
  inheritColorsForPipedTasks: true
  logRunningCommand: false
  killProcessThreshold: 2000  # ms
```

### Remote Caching

```yaml
remote:
  host: 'grpcs://cache.example.com:9092'
  api: 'grpc'  # grpc, http

  auth:
    token: 'CACHE_TOKEN'  # env var name
    headers:
      'X-Custom-Header': 'value'

  cache:
    compression: 'zstd'  # none, zstd
    instanceName: 'moon-outputs'
    localReadOnly: false
    verifyIntegrity: false

  tls:
    cert: 'certs/ca.pem'
    domain: 'cache.example.com'

  mtls:
    caCert: 'certs/ca.pem'
    clientCert: 'certs/client.pem'
    clientKey: 'certs/client.key'
```

### Code Owners

```yaml
codeowners:
  sync: true
  orderBy: 'project-id'  # project-id, file-source
  globalPaths:
    '*': ['@admins']
    '/.github/': ['@infra']
```

### Generator

```yaml
generator:
  templates:
    - './templates'
    - 'git://github.com/org/templates#main'
    - 'npm://@company/templates#1.0.0'
```

### Hasher

```yaml
hasher:
  optimization: 'accuracy'  # accuracy, performance
  walkStrategy: 'vcs'       # vcs, glob
  warnOnMissingInputs: true
  ignorePatterns:
    - '**/*.log'
  ignoreMissingPatterns:
    - 'optional/**/*'
```

### Constraints

```yaml
constraints:
  enforceLayerRelationships: true
  tagRelationships:
    react: ['typescript']
    next: ['react']
```

### Docker

```yaml
docker:
  prune:
    deleteVendorDirectories: true
    installToolchainDependencies: true
  scaffold:
    configsPhaseGlobs:
      - '*.config.js'
```

### Notifications

```yaml
notifier:
  webhookUrl: 'https://hooks.example.com/moon'
  terminalNotifications: 'always'  # always, failure, success
  acknowledge: false
```

## Toolchain Configuration (`.moon/toolchains.yml`)

### JavaScript/Node.js

```yaml
javascript:
  packageManager: 'pnpm'  # npm, pnpm, yarn, bun
  inferTasksFromScripts: false
  syncPackageManagerField: true
  syncProjectWorkspaceDependencies: true
  dependencyVersionFormat: 'workspace'

node:
  version: '22.14.0'
  executeArgs:
    - '--experimental-specifier-resolution=node'

npm:
  version: '10.0.0'

pnpm:
  version: '9.0.0'

yarn:
  version: '4.0.0'
```

### Bun

```yaml
javascript:
  packageManager: 'bun'

bun:
  version: '1.0.0'
```

### Deno

```yaml
deno:
  version: '1.40.0'
```

### Rust

```yaml
rust:
  version: 'stable'
  components:
    - 'clippy'
    - 'rustfmt'
  targets:
    - 'wasm32-unknown-unknown'
  bins:
    - 'cargo-nextest'
```

### Python

```yaml
python:
  version: '3.12.0'
```

### TypeScript

```yaml
typescript:
  syncProjectReferences: true
  syncProjectReferencesToPaths: true
  includeProjectReferenceSources: true
  includeSharedTypes: true
  routeOutDirToCache: false
  rootConfigFileName: 'tsconfig.json'
```

### Proto Integration

```yaml
proto:
  version: '0.51.0'

moon:
  manifestUrl: 'https://proxy.corp.net/moon/version'
  downloadUrl: 'https://github.com/moonrepo/moon/releases/latest/download'
```

## Project Configuration (`moon.yml`)

### Project Metadata

```yaml
id: 'web-app'  # Override inferred ID
language: 'typescript'
layer: 'application'  # application, library, tool, automation, configuration, scaffolding
stack: 'frontend'     # frontend, backend, infrastructure, data, systems

project:
  title: 'Web Application'
  description: 'Main web application'
  channel: '#web-app'
  owner: '@frontend-team'
  maintainers:
    - 'alice'
    - 'bob'
  # Custom metadata
  customField: 'value'

tags:
  - 'react'
  - 'typescript'
```

### Dependencies

```yaml
dependsOn:
  - 'shared-utils'
  - id: 'api-client'
    scope: 'production'  # production, development, build, peer
```

### Code Owners

```yaml
owners:
  defaultOwner: '@frontend'
  requiredApprovals: 2
  paths:
    'src/': ['@frontend']
    '*.config.js': ['@frontend-infra']
```

### File Groups

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
```

### Environment Variables

```yaml
env:
  NODE_ENV: 'development'
  API_URL: '${API_BASE_URL}/v1'
```

### Tasks

```yaml
tasks:
  build:
    command: 'vite build'
    inputs:
      - '@group(sources)'
      - '@group(configs)'
    outputs:
      - 'dist'
    deps:
      - '^:build'  # Build dependencies first
    options:
      cache: true
      runInCI: true

  dev:
    command: 'vite'
    preset: 'server'
    options:
      runInCI: false

  test:
    command: 'vitest'
    inputs:
      - '@group(sources)'
      - '@group(tests)'
    deps:
      - '~:build'
    options:
      retryCount: 2

  lint:
    command: 'eslint'
    args:
      - '--ext'
      - '.ts,.tsx'
      - '.'
    inputs:
      - '@group(sources)'
      - '.eslintrc.*'
      - '/.eslintrc.*'  # Workspace root

  typecheck:
    command: 'tsc'
    args: '--build --pretty'
    inputs:
      - '@group(sources)'
      - 'tsconfig.json'
      - '/tsconfig.options.json'
    outputs:
      - 'lib'
```

### Task Options

```yaml
tasks:
  example:
    command: 'cmd'
    options:
      # Caching
      cache: true           # true, false, 'local', 'remote'
      cacheKey: 'v1'        # Custom cache key
      cacheLifetime: '1 day'

      # Execution
      shell: true
      unixShell: 'bash'
      windowsShell: 'pwsh'
      runFromWorkspaceRoot: false
      timeout: 300          # seconds
      retryCount: 0

      # CI
      runInCI: true         # true, false, 'always', 'affected', 'only', 'skip'

      # Behavior
      persistent: false     # Never-ending process
      interactive: false    # Requires stdin
      internal: false       # Not for direct invocation
      allowFailure: false   # Don't fail pipeline

      # Affected files
      affectedFiles: false  # true, 'args', 'env'
      affectedPassInputs: false

      # Dependencies
      runDepsInParallel: true
      mutex: 'resource-name'  # Exclusive lock

      # Platform
      os: ['linux', 'macos']  # Restrict to OS

      # Output
      outputStyle: 'stream'  # buffer, buffer-only-failure, hash, none, stream

      # Env files
      envFile: true  # true, '.env.local', ['.env', '.env.local']

      # Merge strategies
      merge: 'append'       # append, prepend, preserve, replace
      mergeArgs: 'append'
      mergeDeps: 'append'
      mergeEnv: 'append'
      mergeInputs: 'append'
      mergeOutputs: 'append'
```

### Toolchain Overrides

```yaml
toolchains:
  default: 'node'
  node:
    version: '20.0.0'
  typescript:
    syncProjectReferences: false
```

### Workspace Inheritance Control

```yaml
workspace:
  inheritedTasks:
    include:
      - 'lint'
      - 'test'
    exclude:
      - 'deploy'
    rename:
      buildApplication: 'build'
```

### Docker Configuration

```yaml
docker:
  file:
    buildTask: 'build'
    startTask: 'start'
    image: 'node:22-alpine'
  scaffold:
    sourcesPhaseGlobs:
      - 'src/**/*'
```

## Inherited Tasks (`.moon/tasks/all.yml`)

```yaml
fileGroups:
  sources:
    - 'src/**/*'
  tests:
    - 'tests/**/*'

# Conditional inheritance
inheritedBy:
  toolchains:
    or: ['javascript', 'typescript']
  stacks: ['frontend']
  layers: ['library', 'application']

implicitDeps:
  - '^:build'

implicitInputs:
  - 'package.json'

taskOptions:
  cache: true
  runInCI: true

tasks:
  lint:
    command: 'eslint .'
    inputs:
      - '@group(sources)'

  test:
    command: 'jest'
    inputs:
      - '@group(sources)'
      - '@group(tests)'
```

## Template Configuration (`template.yml`)

```yaml
id: 'react-component'
title: 'React Component'
description: 'Creates a new React component with tests'
destination: 'src/components/[name]'
extends:
  - 'base-template'

variables:
  name:
    type: 'string'
    prompt: 'Component name?'
    required: true

  withTests:
    type: 'boolean'
    prompt: 'Include tests?'
    default: true

  style:
    type: 'enum'
    prompt: 'Styling approach?'
    values:
      - { value: 'css', label: 'CSS Modules' }
      - { value: 'styled', label: 'Styled Components' }
      - { value: 'tailwind', label: 'Tailwind CSS' }
    default: 'css'
```

### Template File Frontmatter

```twig
---
to: {{ name | pascal_case }}.tsx
force: false
skip: {{ not withTests }}
---

export function {{ name | pascal_case }}() {
  return <div />;
}
```
