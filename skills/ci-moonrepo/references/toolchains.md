# Toolchains and Plugin System Reference

v2's biggest architectural change: toolchains are powered by WASM plugins instead of being hard-coded. This enables community-created toolchains and far more flexibility.

## Table of Contents
- [Overview](#overview)
- [Configuration file](#configuration-file)
- [Shared toolchain options](#shared-toolchain-options)
- [JavaScript ecosystem](#javascript-ecosystem)
- [Node.js](#nodejs)
- [Package managers](#package-managers)
- [Deno](#deno)
- [Rust](#rust)
- [Go](#go)
- [Python (unstable)](#python-unstable)
- [TypeScript](#typescript)
- [Language support tiers](#language-support-tiers)
- [WASM plugin system](#wasm-plugin-system)
- [Custom toolchain plugins](#custom-toolchain-plugins)
- [Extensions](#extensions)
- [Proto integration](#proto-integration)

## Overview

The toolchain system manages language runtimes, package managers, and build tools. It ensures every developer, CI runner, and production machine uses identical versions -- powered by **proto**, moon's companion version manager.

Configuration lives in `.moon/toolchains.*` (note: plural in v2, renamed from `.moon/toolchain.*`).

## Configuration File

```yaml
# .moon/toolchains.yml
extends: 'https://raw.githubusercontent.com/org/configs/main/.moon/toolchains.yml'

moon:
  manifestUrl: 'https://proxy.corp.net/moon/version'     # Custom version check URL
  downloadUrl: 'https://github.com/moonrepo/moon/releases/latest/download'

proto:
  version: '0.55.4'
```

## Shared Toolchain Options

Available on every toolchain:

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `inheritAliases` | boolean | `true` | Inherit project aliases during graph extension (v2.1.0+) |
| `installDependencies` | boolean | `true` | Auto-install deps on lockfile/manifest changes (v2.1.0+) |
| `plugin` | string | -- | WASM plugin location (`file://`, `https://`, `github://`) |
| `versionFromPrototools` | boolean/string | `true` | Inherit version from `.prototools` (v2.0.0+) |

## JavaScript Ecosystem

The `javascript` toolchain contains shared settings for the JS/TS ecosystem. It is required when using `node`, `bun`, or `deno`.

```yaml
javascript:
  packageManager: 'pnpm'                          # 'npm' (default), 'pnpm', 'yarn', 'bun'
  inferTasksFromScripts: false                     # Auto-create tasks from package.json scripts (default: false)
  syncProjectWorkspaceDependencies: true           # Sync deps to match project graph (default: true)
  dependencyVersionFormat: 'workspace'             # Version format for synced deps (default: 'workspace')
  syncPackageManagerField: true                    # Sync packageManager field in root package.json (default: true)
  rootPackageDependenciesOnly: false               # Only install root package deps (default: false)
```

### Key v2 changes from v1

- Shared settings moved from `node` to `javascript` toolchain
- Package managers promoted to top-level (no longer nested under `node`)
- `bun`, `deno`, and `node` all require `javascript` to be defined
- Language is auto-detected from toolchains

## Node.js

```yaml
node:
  version: '22.14.0'
  executeArgs:                                     # Args passed to node binary
    - '--experimental-specifier-resolution=node'
```

## Package Managers

All promoted to top-level in v2 (were nested under `node` in v1):

```yaml
npm:
  version: '10.0.0'

pnpm:
  version: '9.0.0'

yarn:
  version: '4.0.0'

bun:
  version: '1.0.0'
```

## Deno

```yaml
deno:
  version: '1.40.0'
```

Requires `javascript` to be defined.

## Rust

```yaml
rust:
  version: 'stable'              # or specific: '1.75.0'
  components:
    - 'clippy'
    - 'rustfmt'
  targets:
    - 'wasm32-unknown-unknown'
  bins:
    - 'cargo-nextest'
```

## Go

```yaml
go:
  version: '1.22.0'
```

v2.1.0: Uses `go list --deps` for automatic project relationship detection.

## Python (unstable)

Still uses the `unstable_` prefix in v2:

```yaml
unstable_python:
  version: '3.12.0'

unstable_pip: {}
# or
unstable_uv:
  version: '0.1.0'
```

v2.0.4: Added `pyproject.toml` dependency reading. v2.1.0: Normalized package names to PEP 503.

## TypeScript

```yaml
typescript:
  syncProjectReferences: true                # Sync project references to tsconfig
  syncProjectReferencesToPaths: true         # Also sync paths mapping
  includeProjectReferenceSources: true       # Include source dirs in references
  includeSharedTypes: true                   # Include shared type declarations
  routeOutDirToCache: false                  # Route outDir to moon cache
  rootConfigFileName: 'tsconfig.json'        # Name of root tsconfig
  pruneProjectReferences: false              # Remove non-moon managed refs (v2.1.0+)
```

## Language Support Tiers

| Tier | Languages | Capabilities |
|------|-----------|-------------|
| Tier 0 | Unsupported | System toolchain only, execute via PATH |
| Tier 1 | Language metadata | Name, binary, file extensions, language detection |
| Tier 2 | Ecosystem | Deep integration: deps, aliases, lockfile parsing, PATH, commands |
| Tier 3 | Toolchain | Proto integration: download, install, version detection |

**Current status:**
- **Full support (Tier 1-3)**: Node.js, Bun, Deno
- **Strong support (Tier 2-3)**: Rust, Go
- **Partial (unstable)**: Python
- **System only (Tier 0)**: PHP, Ruby, everything else

## WASM Plugin System

v2 replaces the old hard-coded "platform" system with WASM plugins:

- Toolchains are loaded dynamically
- Community members can create custom toolchains
- Plugins can extend the project graph, modify tasks, integrate with Docker, handle dependency installation, and participate in hashing

### Plugin capabilities

| Function | Description |
|----------|-------------|
| `register_toolchain` | Provide metadata about the toolchain |
| `detect_toolchain_usage` | Detect if toolchain is used in a project |
| `define_toolchain_config` | Define configuration schema |
| `extend_project_graph` | Add dependencies and aliases |
| `extend_task_command` | Modify task commands |
| `extend_task_script` | Modify task scripts |
| `install_deps` | Install project dependencies |
| `hash_task_contents` | Add items to task hash |
| `sync_project` | Sync project state |

## Custom Toolchain Plugins

```yaml
# .moon/toolchains.yml
my-toolchain:
  plugin: 'file://./plugins/my-toolchain.wasm'
  version: '1.0.0'
```

Plugin sources: `file://` (local), `https://` (URL), `github://user/repo` (GitHub release).

## Extensions

Extensions are WASM plugins that add custom CLI commands and workspace functionality. They live in `.moon/extensions.*` (separate file in v2; was part of workspace config in v1).

```yaml
# .moon/extensions.yml
download: {}                    # Built-in: download files
migrate-nx: {}                  # Built-in: migrate from Nx
migrate-turborepo: {}           # Built-in: migrate from Turborepo
unpack: {}                      # Built-in: unpack archives (new in v2)

# Custom extension
my-extension:
  plugin: 'https://example.com/my-extension.wasm'
  config:
    setting1: 'value'
```

Built-in extensions must be explicitly enabled in v2.

### Extension management

```bash
moon extension add <name>       # Add an extension
moon extension info <name>      # Show extension details
moon ext <name> -- <args>       # Run extension
```

### Extension Plugin API

| Function | Description |
|----------|-------------|
| `register_extension` | Provide metadata |
| `execute_extension` | Main business logic |
| `define_extension_config` | Define configuration schema |
| `initialize_extension` | Setup logic |
| `extend_command` | Add CLI commands |
| `extend_project_graph` | Extend the project graph |
| `sync_project` | Sync project state |
| `sync_workspace` | Sync workspace state |

## Proto Integration

Proto is moon's companion version manager. Moon uses proto to download, install, and manage language runtimes.

### How moon uses proto

1. Moon reads `.moon/toolchains.yml`
2. Proto downloads/installs specified versions
3. Tools stored in `~/.proto/tools/<name>/<version>`
4. Moon uses proto-managed binaries for tasks

### Version detection order

1. Command line argument
2. Environment variable (e.g., `PROTO_NODE_VERSION=20`)
3. `.prototools` files (upward from cwd)
4. Tool-specific files (`.nvmrc`, `.node-version`)
5. Global `.prototools` (`~/.proto/.prototools`)

### `.prototools` example

```toml
node = "22.14.0"
npm = "10"
pnpm = "9.0.0"
go = "~1.22"
rust = "stable"

[settings]
auto-install = true
detect-strategy = "first-available"
pin-latest = "local"
```

### Common proto commands

```bash
proto install                    # Install all from .prototools
proto install node 22.14.0      # Install specific
proto pin node 22.14.0          # Pin version
proto versions node              # List versions
proto outdated                   # Check outdated
proto status                     # Tool status
proto clean --days 30            # Clean old versions
proto regen                      # Regenerate shims
proto diagnose                   # Diagnose issues
```
