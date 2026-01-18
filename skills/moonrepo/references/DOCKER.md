# Moon Docker Integration

Complete guide to using moon with Docker for optimized builds.

## Overview

Moon provides Docker integration for:
- **Scaffolding:** Generate minimal file skeletons for layer caching
- **Dockerfile generation:** Multi-stage builds with best practices
- **Pruning:** Remove dev dependencies for smaller images

## Basic Workflow

### 1. Add to .dockerignore

```text
# .dockerignore
.moon/cache
node_modules
dist
.git
```

### 2. Scaffold Project

```bash
moon docker scaffold <project>
```

Creates:
- `.moon/docker/configs/` - Workspace skeleton (manifests, lockfiles, configs)
- `.moon/docker/sources/` - Project sources and dependencies

### 3. Generate Dockerfile (Optional)

```bash
moon docker file <project>
```

Generates multi-stage Dockerfile with:
- `base` - Install moon
- `skeleton` - Copy workspace skeleton
- `build` - Build project
- `start` - Run project

### 4. Build Image

```bash
docker build -t myapp .
```

## Manual Dockerfile

### Non-Staged Build

```dockerfile
FROM node:22-alpine
WORKDIR /app

# Install moon
RUN npm install -g @moonrepo/cli

# Copy workspace skeleton (manifests, configs)
COPY ./.moon/docker/configs .

# Install dependencies
RUN moon docker setup

# Copy source files
COPY ./.moon/docker/sources .

# Build project
RUN moon run app:build

# Prune dev dependencies
RUN moon docker prune

# Start
CMD ["node", "apps/app/dist/index.js"]
```

### Multi-Stage Build

```dockerfile
# Base stage
FROM node:22-alpine AS base
WORKDIR /app
RUN npm install -g @moonrepo/cli

# Skeleton stage - scaffold files
FROM base AS skeleton
COPY . .
RUN moon docker scaffold app

# Build stage
FROM base AS build

# Copy workspace skeleton
COPY --from=skeleton /app/.moon/docker/configs .

# Install dependencies (cached layer)
RUN moon docker setup

# Copy sources
COPY --from=skeleton /app/.moon/docker/sources .

# Build
RUN moon run app:build

# Prune
RUN moon docker prune

# Start stage (minimal)
FROM node:22-alpine AS start
WORKDIR /app

COPY --from=build /app .

CMD ["node", "apps/app/dist/index.js"]
```

### Without Toolchain (System Binaries)

```dockerfile
FROM node:22-alpine AS base
WORKDIR /app

# Use system node instead of toolchain
ENV MOON_TOOLCHAIN_FORCE_GLOBALS=true

RUN npm install -g @moonrepo/cli

# ... rest of Dockerfile
```

## Docker Commands

### `moon docker scaffold`

Create repository skeletons for layer caching.

```bash
moon docker scaffold <...projects>
```

**What it creates:**

`.moon/docker/configs/`:
- `.moon/` configuration
- Root `package.json`, lockfiles
- Tool configs (`.npmrc`, `tsconfig.json`, etc.)

`.moon/docker/sources/`:
- Project source files
- Project dependencies (other projects)

### `moon docker setup`

Install tools and dependencies in Docker context.

```bash
moon docker setup
```

Replaces `npm install`, `pnpm install`, etc. Understands which projects are scaffolded.

### `moon docker prune`

Remove dev dependencies and extraneous files.

```bash
moon docker prune
```

- Installs production-only dependencies
- Removes `node_modules` for non-production projects
- Cleans temp files

### `moon docker file`

Generate optimized Dockerfile.

```bash
moon docker file <project> [destination]
```

**Options:**

| Option | Description |
|--------|-------------|
| `--defaults` | Use defaults, skip prompts |
| `--build-task` | Task to build project |
| `--start-task` | Task to start project |
| `--image` | Base Docker image |
| `--no-prune` | Don't prune in build stage |
| `--no-toolchain` | Use system binaries |

**Examples:**
```bash
# Interactive
moon docker file app

# Non-interactive
moon docker file app ./Dockerfile \
  --defaults \
  --build-task build \
  --start-task start \
  --image node:22-alpine
```

## Configuration

### Workspace Configuration

```yaml
# .moon/workspace.yml
docker:
  prune:
    # Delete vendor directories (node_modules, etc.)
    deleteVendorDirectories: true
    # Install production dependencies
    installToolchainDependencies: true

  scaffold:
    # Additional files to copy in configs phase
    configsPhaseGlobs:
      - '*.config.js'
      - 'patches/**/*'
```

### Project Configuration

```yaml
# moon.yml
docker:
  file:
    buildTask: 'build'
    startTask: 'start'
    image: 'node:22-alpine'

  scaffold:
    # Additional files to copy in sources phase
    sourcesPhaseGlobs:
      - 'public/**/*'
      - 'assets/**/*'
```

## Layer Caching Strategy

Docker caches layers based on file changes. Moon's scaffold separates:

1. **Configs layer** (changes rarely):
   - Package manifests
   - Lockfiles
   - Tool configs
   - Moon configuration

2. **Sources layer** (changes often):
   - Source code
   - Tests
   - Assets

This means dependency installation is cached until lockfile changes.

## Framework Examples

### Next.js

```dockerfile
FROM node:22-alpine AS base
WORKDIR /app
RUN npm install -g @moonrepo/cli

FROM base AS skeleton
COPY . .
RUN moon docker scaffold web

FROM base AS build
COPY --from=skeleton /app/.moon/docker/configs .
RUN moon docker setup
COPY --from=skeleton /app/.moon/docker/sources .
RUN moon run web:build
RUN moon docker prune

FROM node:22-alpine AS start
WORKDIR /app
ENV NODE_ENV=production
COPY --from=build /app .
CMD ["npm", "start", "--prefix", "apps/web"]
```

### NestJS

```dockerfile
FROM node:22-alpine AS base
WORKDIR /app
RUN npm install -g @moonrepo/cli

FROM base AS skeleton
COPY . .
RUN moon docker scaffold api

FROM base AS build
COPY --from=skeleton /app/.moon/docker/configs .
RUN moon docker setup
COPY --from=skeleton /app/.moon/docker/sources .
RUN moon run api:build
RUN moon docker prune

FROM node:22-alpine AS start
WORKDIR /app
ENV NODE_ENV=production
COPY --from=build /app .
CMD ["node", "apps/api/dist/main.js"]
```

### Rust

```dockerfile
FROM rust:1.75 AS base
WORKDIR /app
RUN curl -fsSL https://moonrepo.dev/install/moon.sh | bash
ENV PATH="/root/.moon/bin:$PATH"

FROM base AS skeleton
COPY . .
RUN moon docker scaffold api

FROM base AS build
COPY --from=skeleton /app/.moon/docker/configs .
COPY --from=skeleton /app/.moon/docker/sources .
RUN moon run api:build --release

FROM debian:bookworm-slim AS start
COPY --from=build /app/target/release/api /usr/local/bin/
CMD ["api"]
```

## Multi-Project Builds

```bash
# Scaffold multiple projects
moon docker scaffold app api worker

# Each gets included in sources
```

```dockerfile
FROM base AS skeleton
COPY . .
RUN moon docker scaffold app api worker

FROM base AS build
COPY --from=skeleton /app/.moon/docker/configs .
RUN moon docker setup
COPY --from=skeleton /app/.moon/docker/sources .

# Build all
RUN moon run app:build api:build worker:build

RUN moon docker prune
```

## Troubleshooting

### Alpine Images

For Alpine-based images, use system binaries:

```dockerfile
ENV MOON_TOOLCHAIN_FORCE_GLOBALS=true
```

### Missing Files

Add to scaffold config:

```yaml
# .moon/workspace.yml
docker:
  scaffold:
    configsPhaseGlobs:
      - 'patches/**/*'
      - '.npmrc'
```

### Large Images

1. Use multi-stage builds
2. Enable pruning: `moon docker prune`
3. Use slim base images
4. Add to `.dockerignore`:
   ```text
   .git
   .moon/cache
   **/node_modules
   **/dist
   **/*.log
   ```

### Build Context

Always run docker commands from workspace root:

```bash
# From workspace root
docker build -t app .

# NOT from project directory
# cd apps/app && docker build .  # Wrong!
```
