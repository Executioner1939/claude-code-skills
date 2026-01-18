# Advanced Moon Patterns

Advanced techniques, automation, and best practices.

## Task Inheritance Patterns

### Conditional Inheritance by Toolchain

```yaml
# .moon/tasks/javascript.yml
inheritedBy:
  toolchains:
    or: ['javascript', 'typescript']

tasks:
  lint:
    command: 'eslint .'
  test:
    command: 'jest'
```

### Conditional Inheritance by Tag

```yaml
# .moon/tasks/react.yml
inheritedBy:
  tags: ['react']

tasks:
  lint:
    args:
      - '--ext'
      - '.tsx'
    options:
      mergeArgs: 'prepend'
```

### Conditional Inheritance by Layer

```yaml
# .moon/tasks/library.yml
inheritedBy:
  layers: ['library']

tasks:
  build:
    command: 'tsc --build'
    outputs:
      - 'dist'
```

### Multi-Condition Inheritance

```yaml
# .moon/tasks/frontend-lib.yml
inheritedBy:
  toolchains:
    or: ['javascript', 'typescript']
  stacks: ['frontend']
  layers: ['library']
```

## Dynamic Task Generation with Pkl

```pkl
# moon.pkl
tasks {
  // Generate OS-specific build tasks
  for (_os in List("linux", "macos", "windows")) {
    ["build-\(_os)"] {
      command = "cargo"
      args = List(
        "build",
        "--release",
        "--target",
        if (_os == "linux") "x86_64-unknown-linux-gnu"
          else if (_os == "macos") "x86_64-apple-darwin"
          else "x86_64-pc-windows-msvc"
      )
      options {
        os = _os
      }
    }
  }
}
```

## Complex Dependency Graphs

### Build Order with Dependencies

```yaml
tasks:
  generate:
    command: 'prisma generate'
    outputs:
      - 'node_modules/.prisma'

  build:
    command: 'tsc'
    deps:
      - '~:generate'
      - '^:build'  # All project dependencies
    outputs:
      - 'dist'

  test:
    command: 'jest'
    deps:
      - '~:build'

  deploy:
    command: 'deploy.sh'
    deps:
      - '~:test'
    options:
      runInCI: 'only'
```

### Optional Dependencies

```yaml
tasks:
  build:
    deps:
      - target: '^:build'
        optional: true  # May not exist
```

### Passing Args to Dependencies

```yaml
tasks:
  build:
    deps:
      - target: 'codegen:generate'
        args: '--env production'
        env:
          TARGET_ENV: 'production'
```

## Environment Management

### Per-Environment Tasks

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

  build:dev:
    extends: 'build'
    env:
      NODE_ENV: 'development'
```

### Environment Files

```yaml
tasks:
  build:
    command: 'vite build'
    options:
      # Load multiple env files (later overrides earlier)
      envFile:
        - '.env'
        - '.env.local'
        - '.env.production'
```

### Dynamic Environment Variables

```yaml
tasks:
  deploy:
    command: 'deploy.sh'
    env:
      VERSION: '$vcsRevision'
      BRANCH: '$vcsBranch'
      BUILD_DATE: '$datetime'
```

## Caching Strategies

### Cache by Environment

```yaml
tasks:
  build:
    command: 'vite build'
    options:
      cacheKey: 'v1-$vcsBranch'  # Different cache per branch
```

### Skip Cache for Specific Tasks

```yaml
tasks:
  deploy:
    command: 'deploy.sh'
    options:
      cache: false
```

### Local-Only Caching

```yaml
tasks:
  build:
    options:
      cache: 'local'  # Don't use remote cache
```

## Workspace Organization

### Monorepo Structure

```
workspace/
├── .moon/
│   ├── workspace.yml
│   ├── toolchains.yml
│   └── tasks/
│       ├── all.yml          # Universal tasks
│       ├── javascript.yml   # JS/TS projects
│       ├── rust.yml         # Rust projects
│       └── react.yml        # React projects
├── apps/
│   ├── web/                 # Frontend app
│   └── api/                 # Backend app
├── packages/
│   ├── ui/                  # Shared UI
│   └── utils/               # Shared utilities
└── tools/
    └── scripts/             # Build scripts
```

### Project Tags Strategy

```yaml
# Use tags for:
# - Framework: react, vue, svelte
# - Feature: auth, payments, analytics
# - Team: frontend, backend, platform

tags:
  - 'react'
  - 'payments'
  - 'frontend-team'
```

### Running by Tags

```bash
# All frontend tasks
moon run '#frontend-team:lint'

# All React projects
moon run '#react:test'
```

## Code Generation

### Template with Variables

```yaml
# templates/component/template.yml
title: 'React Component'
description: 'Create a React component'
destination: 'src/components/[name]'

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
    prompt: 'Styling?'
    values: ['css', 'styled', 'tailwind']
    default: 'css'
```

### Template Files

```twig
{# templates/component/files/[name].tsx.tera #}
---
to: {{ name | pascal_case }}.tsx
---

import styles from './{{ name | pascal_case }}.module.css';

export interface {{ name | pascal_case }}Props {
  children?: React.ReactNode;
}

export function {{ name | pascal_case }}({ children }: {{ name | pascal_case }}Props) {
  return (
    <div className={styles.root}>
      {children}
    </div>
  );
}
```

```twig
{# templates/component/files/[name].test.tsx.tera #}
---
to: {{ name | pascal_case }}.test.tsx
skip: {{ not withTests }}
---

import { render, screen } from '@testing-library/react';
import { {{ name | pascal_case }} } from './{{ name | pascal_case }}';

describe('{{ name | pascal_case }}', () => {
  it('renders children', () => {
    render(<{{ name | pascal_case }}>Hello</{{ name | pascal_case }}>);
    expect(screen.getByText('Hello')).toBeInTheDocument();
  });
});
```

### Generate Command

```bash
moon generate component --to packages/ui -- --name Button --withTests
```

## VCS Hooks

### Pre-commit Hook

```yaml
# .moon/workspace.yml
vcs:
  hooks:
    pre-commit:
      - 'moon run :lint :format --affected --status=staged'
```

### Commit Message Validation

```yaml
vcs:
  hooks:
    commit-msg:
      - 'commitlint --edit $ARG1'
```

### Pre-push Hook

```yaml
vcs:
  hooks:
    pre-push:
      - 'moon run :test --affected'
```

## Remote Caching Setup

### Self-Hosted with bazel-remote

```bash
# Start cache server
docker run -p 9092:9092 \
  -v /data/moon-cache:/data \
  buchgr/bazel-remote-cache \
  --dir=/data \
  --max_size=50 \
  --grpc_address=0.0.0.0:9092
```

```yaml
# .moon/workspace.yml
remote:
  host: 'grpc://cache.internal:9092'
```

### With Authentication

```yaml
remote:
  host: 'grpcs://cache.example.com:9092'
  auth:
    token: 'CACHE_AUTH_TOKEN'  # Env var name
  tls:
    cert: 'certs/ca.pem'
```

## Webhook Integration

### Slack Notifications

```yaml
# .moon/workspace.yml
notifier:
  webhookUrl: 'https://hooks.slack.com/services/...'
```

### Custom Webhook Handler

```yaml
notifier:
  webhookUrl: 'https://api.example.com/moon-webhook'
  acknowledge: true  # Wait for response
```

Events sent:
- `pipeline.started`, `pipeline.finished`, `pipeline.aborted`
- `task.running`, `task.ran`
- `dependencies.installing`, `dependencies.installed`

## Parallelization Patterns

### CI Job Distribution

```yaml
# GitHub Actions
jobs:
  ci:
    strategy:
      matrix:
        job: [0, 1, 2, 3]
    steps:
      - run: moon ci --job ${{ matrix.job }} --job-total 4
```

### Sequential Dependencies, Parallel Tasks

```yaml
tasks:
  build:
    deps:
      - '^:build'  # Wait for dependencies
    options:
      runDepsInParallel: true  # Run deps in parallel
```

### Mutex for Shared Resources

```yaml
tasks:
  migrate:
    command: 'prisma migrate deploy'
    options:
      mutex: 'database'  # Only one at a time

  seed:
    command: 'prisma db seed'
    options:
      mutex: 'database'
```

## Debugging

### Inspect Task Configuration

```bash
moon task app:build --json
```

### Compare Hash Changes

```bash
# After running task, find hash in output
moon hash abc123

# Compare two runs
moon hash abc123 def456
```

### Verbose Logging

```bash
MOON_LOG=trace moon run app:build
MOON_DEBUG_PROCESS_ENV=true moon run app:build
```

### Query Affected

```bash
moon query affected
moon query changed-files --status modified
```

## Extension Development

### Custom Extension

```rust
// src/lib.rs
use moon_pdk::*;

#[plugin_fn]
pub fn register_extension(
    Json(input): Json<ExtensionMetadataInput>
) -> FnResult<Json<ExtensionMetadataOutput>> {
    Ok(Json(ExtensionMetadataOutput {
        name: "my-extension".into(),
        description: Some("Custom extension".into()),
        ..Default::default()
    }))
}

#[plugin_fn]
pub fn execute_extension(
    Json(input): Json<ExecuteExtensionInput>
) -> FnResult<()> {
    // Extension logic
    Ok(())
}
```

### Configuration

```yaml
# .moon/extensions.yml
my-extension:
  plugin: 'file://./extensions/my-extension.wasm'
  customSetting: true
```

### Usage

```bash
moon ext my-extension -- --arg1 value
```

## MCP Integration for AI

### Claude Code Setup

```bash
claude mcp add moon -s project \
  -e MOON_WORKSPACE_ROOT=/path/to/workspace \
  -- moon mcp
```

### Available Tools

- `get_project` - Get project details
- `get_projects` - List all projects
- `get_task` - Get task details
- `get_tasks` - List all tasks
- `get_changed_files` - Get VCS changes
- `sync_projects` - Sync projects
- `sync_workspace` - Sync workspace
