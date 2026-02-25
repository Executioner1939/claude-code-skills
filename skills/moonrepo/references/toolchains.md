# Toolchains & Plugin System Reference

v2's biggest architectural change: toolchains are now powered by WASM plugins instead of being hard-coded. This enables community-created toolchains and far more flexibility.

## Table of Contents
- [Overview](#overview)
- [Configuration](#configuration)
- [Supported languages](#supported-languages)
- [JavaScript ecosystem](#javascript-ecosystem)
- [Other toolchains](#other-toolchains)
- [WASM plugin system](#wasm-plugin-system)
- [Extensions](#extensions)

## Overview

The toolchain system manages language runtimes, package managers, and build tools. It ensures every developer, CI runner, and production machine uses identical versions — powered by **proto**, moon's companion version manager.

Configuration lives in `.moon/toolchains.*` (note: plural in v2, renamed from `toolchain.*`).

## Configuration

```yaml
# .moon/toolchains.yml

# JavaScript ecosystem (required if using node/bun/deno)
javascript:
  packageManager: 'pnpm'
  inferTasksFromScripts: false
  syncProjectWorkspaceDependencies: true
  dependencyVersionFormat: 'workspace'
  syncPackageManagerField: true
  rootPackageDependenciesOnly: false

# Node.js runtime
node:
  version: '20.11.0'

# Package managers (promoted to top-level in v2)
pnpm:
  version: '9.1.0'

npm:
  version: '10.5.0'

yarn:
  version: '4.1.0'

# Other runtimes
bun:
  version: '1.0.0'

deno:
  version: '1.40.0'

rust:
  version: '1.75.0'
  components: ['clippy', 'rustfmt']
  targets: ['wasm32-unknown-unknown']

go:
  version: '1.22.0'

# Unstable
unstable_python:
  version: '3.12.0'
```

## Supported languages

moon has a 4-tier language support system:

| Tier | Languages | Description |
|------|-----------|-------------|
| Tier 1 | Node.js, Bun, Deno | Full support — toolchain, tasks, deps, caching |
| Tier 2 | Rust, Go | Strong support — toolchain, tasks, some dep management |
| Tier 3 | Python, PHP, Ruby | Partial — basic toolchain, task execution |
| Tier 4 | Everything else | System-level execution (no toolchain management) |

## JavaScript ecosystem

The JavaScript toolchain was significantly restructured in v2.

### Key changes from v1
- Shared settings moved from `node` to `javascript` toolchain
- Package managers (`npm`, `pnpm`, `yarn`, `bun`) promoted to top-level
- `bun`, `deno`, and `node` all require `javascript` to be defined
- Language is auto-detected from toolchains (no explicit `language` setting needed)

### javascript toolchain settings

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `packageManager` | string | `'npm'` | Which package manager to use |
| `inferTasksFromScripts` | boolean | `false` | Auto-create tasks from package.json scripts |
| `syncProjectWorkspaceDependencies` | boolean | `true` | Sync deps to match project graph |
| `dependencyVersionFormat` | string | `'workspace'` | Version format for synced deps |
| `syncPackageManagerField` | boolean | `true` | Sync `packageManager` field in root package.json |
| `rootPackageDependenciesOnly` | boolean | `false` | Only install root package deps |

### Yarn v4 catalogs

v2 added support for Yarn v4.10 catalogs for dependency deduplication.

## Other toolchains

### Rust

```yaml
rust:
  version: '1.75.0'
  components:
    - 'clippy'
    - 'rustfmt'
  targets:
    - 'wasm32-unknown-unknown'
```

### Go

```yaml
go:
  version: '1.22.0'
```

### Python (unstable)

Python remains unstable in v2. Pip and uv are also under `unstable_` prefix:

```yaml
unstable_python:
  version: '3.12.0'

unstable_pip: {}
# or
unstable_uv:
  version: '0.1.0'
```

## WASM plugin system

v2 replaces the old hard-coded "platform" system with WASM plugins. This means:

- Toolchains are loaded dynamically
- Community members can create custom toolchains
- Plugins can extend the project graph, modify tasks, integrate with Docker, handle dependency installation, and participate in hashing

### Plugin capabilities

WASM toolchain plugins can:
- Extend the project graph
- Modify task commands and scripts
- Integrate with Docker (pruning, scaffolding)
- Auto-install dependencies
- Participate in task hashing
- Manage tools via proto

### PATH handling

v2 introduced strict operational ordering for `PATH` and environment variable inheritance across command execution, ensuring deterministic behavior.

## Extensions

Extensions are WASM plugins that add custom CLI commands and workspace functionality. They live in `.moon/extensions.*` (separate file in v2, was part of workspace config in v1).

```yaml
# .moon/extensions.yml
download: {}                    # built-in: download files
migrate-nx: {}                  # built-in: migrate from Nx
migrate-turborepo: {}           # built-in: migrate from Turborepo

# Custom extension
my-extension:
  plugin: 'https://example.com/my-extension.wasm'
  config:
    setting1: 'value'
```

Built-in extensions must be explicitly enabled in v2 (they were implicit in v1).

### Extension management commands

```bash
moon extension add <name>       # add an extension
moon extension info <name>      # show extension details
moon extension <name>           # run an extension command
```

### Extension plugin API

Extensions can implement:
- `define_extension_config` — define configuration schema
- `initialize_extension` — setup logic
- `extend_command` — add CLI commands
- Various utility functions for project/workspace interaction
