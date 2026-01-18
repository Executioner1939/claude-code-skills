# Proto Toolchain Manager

Proto is moon's underlying version manager for languages and tools.

## Overview

Proto provides:
- Multi-language version management
- Unified CLI for all tools
- Cross-platform support
- WASM-based plugins
- Checksum verification

## Installation

```bash
# Linux/macOS/WSL
curl -fsSL https://moonrepo.dev/install/proto.sh | bash

# Windows PowerShell
irm https://moonrepo.dev/install/proto.ps1 | iex

# Upgrade
proto upgrade
```

## Configuration (.prototools)

### File Locations

| Location | Path | Priority |
|----------|------|----------|
| Local | `./.prototools` | Highest |
| User | `~/.prototools` | Medium |
| Global | `~/.proto/.prototools` | Lowest |

### Version Pinning

```toml
# .prototools
node = "22.14.0"
npm = "10"
pnpm = "9.0.0"
bun = "1.0.0"
go = "~1.22"
rust = "stable"
python = "3.12"
```

### Environment Variables

```toml
[env]
NODE_ENV = "development"
DEBUG = "*"
file = ".env"  # Load from dotenv
```

### Settings

```toml
[settings]
auto-install = true        # Install missing versions
auto-clean = true          # Clean old versions
detect-strategy = "first-available"  # or prefer-prototools, only-prototools
pin-latest = "local"       # Where to pin: local, global, user
telemetry = false

[settings.http]
allow-invalid-certs = false
proxies = ["https://proxy.corp.com"]
```

### Tool Configuration

```toml
[tools.node]
bundled-npm = false

[tools.node.aliases]
lts = "22"
work = "20"

[tools.node.env]
NODE_OPTIONS = "--max-old-space-size=4096"
```

## Essential Commands

### Install Tools

```bash
# Install all from .prototools
proto install

# Install specific tool
proto install node 22.14.0

# Install and pin
proto install node --pin

# Install canary/nightly
proto install bun canary
```

### Run Tools

```bash
# Run with version detection
proto run node

# Run specific version
proto run node 20.0.0

# Pass arguments
proto run node -- script.js --flag
```

### Version Management

```bash
# Pin version
proto pin node 22.14.0
proto pin node 22 --resolve  # Resolve to full version

# Unpin version
proto unpin node

# List versions
proto versions node
proto versions node --installed

# Check outdated
proto outdated
proto outdated --update  # Update configs
```

### Aliases

```bash
# Create alias
proto alias node lts 22
proto alias node work 20.0.0

# Remove alias
proto unalias node work
```

### Utility Commands

```bash
# Get binary path
proto bin node
proto bin node 20.0.0

# Tool status
proto status

# Clean old versions
proto clean
proto clean --days 30

# Regenerate shims
proto regen
```

## Workflows

### 1. Shims Workflow

Shims wrap `proto run` for automatic version detection.

**Setup (in shell profile):**
```bash
# Add shims to PATH (before bin)
export PATH="$HOME/.proto/shims:$HOME/.proto/bin:$PATH"
```

**Usage:**
```bash
node --version  # Uses version from .prototools
```

### 2. Shell Activation

Hook into shell for directory-aware version switching.

**Setup:**
```bash
# Bash (~/.bashrc)
eval "$(proto activate bash)"

# Zsh (~/.zshrc)
eval "$(proto activate zsh)"

# Fish (~/.config/fish/config.fish)
proto activate fish | source
```

**Features:**
- Auto-loads `.prototools` on `cd`
- Exports environment variables
- Prepends tool paths to PATH

### 3. Binary Linking

Direct symlinks to specific versions.

```bash
# ~/.proto/bin contains:
node      # Highest installed version
node-22   # Highest in v22.x
node-22.14  # Highest in v22.14.x
```

## Version Detection Order

1. Command line argument: `proto run node 20`
2. Environment variable: `PROTO_NODE_VERSION=20`
3. `.prototools` files (upward from cwd)
4. Tool-specific files (`.nvmrc`, `.node-version`)
5. Global `.prototools` (`~/.proto/.prototools`)

## Built-in Tools

**Languages:**
- `node` - Node.js
- `bun` - Bun
- `deno` - Deno
- `go` - Go
- `python` - Python
- `ruby` - Ruby
- `rust` - Rust

**Package Managers:**
- `npm`, `pnpm`, `yarn` - Node.js
- `pip`, `poetry`, `uv` - Python

**Tools:**
- `moon` - Moon build system

## Plugins

### Add Plugin

```bash
# WASM plugin
proto plugin add tool-name "https://example.com/plugin.wasm"

# Source plugin (TOML)
proto plugin add tool-name "source:https://example.com/plugin.toml"

# GitHub release
proto plugin add tool-name "github://user/repo"
```

### List Plugins

```bash
proto plugin list
proto plugin list --versions
```

### Search Plugins

```bash
proto plugin search zig
```

## Integration with Moon

### Toolchain Configuration

```yaml
# .moon/toolchains.yml
proto:
  version: '0.51.0'

node:
  version: '22.14.0'

pnpm:
  version: '9.0.0'

typescript: {}  # Managed by package.json
```

### How Moon Uses Proto

1. Moon reads `.moon/toolchains.yml`
2. Proto downloads/installs specified versions
3. Tools stored in `~/.proto/tools/<name>/<version>`
4. Moon uses proto-managed binaries for tasks

### Override Version

```bash
# Environment variable override
MOON_NODE_VERSION=20.0.0 moon run app:build

# Or PROTO_ prefix
PROTO_NODE_VERSION=20.0.0 moon run app:build
```

## Offline Mode

Proto auto-detects connectivity. Force offline:

```bash
PROTO_OFFLINE=true moon run app:build
```

Requirements for offline:
- Tools pre-installed
- Or available on system PATH

## Debugging

```bash
# Debug environment
proto debug env

# Debug configuration
proto debug config

# Diagnose issues
proto diagnose

# Verbose logging
proto --log trace install node
```

## CI Usage

### GitHub Actions

```yaml
- uses: moonrepo/setup-toolchain@v0
  with:
    auto-install: true
```

### Manual Setup

```yaml
- name: Install proto
  run: curl -fsSL https://moonrepo.dev/install/proto.sh | bash

- name: Install tools
  run: |
    export PATH="$HOME/.proto/shims:$HOME/.proto/bin:$PATH"
    proto install
```

## Common Patterns

### Project-Specific Versions

```toml
# apps/legacy/.prototools
node = "18.0.0"

# apps/modern/.prototools
node = "22.0.0"
```

### Team Standardization

```toml
# Root .prototools (committed)
node = "22.14.0"
pnpm = "9.0.0"

[settings]
auto-install = true
```

### Multiple Runtime Support

```toml
# .prototools
node = "22.14.0"
bun = "1.1.0"

# Use node for most, bun for specific projects
```
