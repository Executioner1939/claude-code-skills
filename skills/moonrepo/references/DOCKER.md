# Docker Integration Reference

moon provides built-in Docker support to reduce the complexity of containerizing monorepo projects, leveraging layer caching and staged builds.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Commands](#commands)
- [Workflow](#workflow)
- [Multi-stage build pattern](#multi-stage-build-pattern)
- [Configuration](#configuration)
- [Custom Dockerfile templates](#custom-dockerfile-templates)
- [Alpine compatibility](#alpine-compatibility)
- [Remote caching in Docker](#remote-caching-in-docker)

## Prerequisites

1. Add `.moon/cache` to `.dockerignore` — cache files aren't portable across environments
2. Decide on `.git` handling:
   - **Recommended**: Exclude `.git` to reduce image size (some moon features disabled)
   - **Alternative**: Include `.git` + install git in image for full functionality

## Commands

### moon docker scaffold \<project\>

Generates a minimal workspace skeleton containing only the files needed to install dependencies — manifests, lockfiles, and config files. This enables Docker layer caching: the dependency install layer only rebuilds when these files change.

```bash
moon docker scaffold app
```

Output goes to `.moon/docker/` with two phases:
- `configs/` — workspace config files (previously called `workspace/` in v1)
- `sources/` — source files for the target project and its dependencies

### moon docker file

Auto-generates a Dockerfile based on your workspace configuration.

```bash
moon docker file                          # default Dockerfile
moon docker file --template ./Dockerfile.tera   # custom template
```

### moon docker setup

Installs the toolchain and project dependencies inside the container.

```bash
moon docker setup
```

### moon docker prune

Removes extraneous dependencies and installs production-only packages.

```bash
moon docker prune
```

## Workflow

The typical Docker build workflow with moon:

1. **Scaffold** — Generate the minimal skeleton
2. **Copy configs** — Copy workspace configs first (layer cached)
3. **Setup** — Install toolchain and dependencies (layer cached if configs unchanged)
4. **Copy sources** — Copy actual source files
5. **Build** — Run build tasks
6. **Prune** — Remove dev dependencies for production

This approach has O(1) complexity — you don't need to manually list every package.json or manifest file.

## Multi-stage build pattern

```dockerfile
# Stage 1: Base
FROM node:20 AS base
WORKDIR /app

# Stage 2: Skeleton (dependency install)
FROM base AS skeleton
COPY .moon/docker/configs/ .
RUN moon docker setup

# Stage 3: Build
FROM skeleton AS build
COPY .moon/docker/sources/ .
RUN moon run app:build

# Stage 4: Production
FROM base AS production
COPY --from=build /app/.moon/docker/sources/ .
RUN moon docker prune
CMD ["node", "dist/index.js"]
```

## Configuration

### Workspace-level (`.moon/workspace.*`)

```yaml
docker:
  file:
    template: './docker/Dockerfile.tera'     # custom Tera template
  scaffold:
    configsPhaseGlobs:                       # extra files for configs phase
      - '*.config.js'
      - '.browserslistrc'
  prune:
    installToolchainDependencies: true       # reinstall prod deps after prune
    deleteVendorDirectories: true            # remove node_modules, vendor, etc.
```

### Project-level (`moon.*`)

```yaml
docker:
  scaffold:
    sourcesPhaseGlobs:                       # extra files for sources phase
      - 'assets/**/*'
  file:
    template: './custom-project-dockerfile.tera'
```

Project-level settings override workspace-level settings.

## Custom Dockerfile templates

v2 supports Tera-powered custom Dockerfile templates:

```bash
moon docker file --template ./Dockerfile.tera
```

Or configure it:
```yaml
# .moon/workspace.yml
docker:
  file:
    template: './docker/Dockerfile.tera'
```

## Alpine compatibility

Alpine Linux images (e.g., `node:alpine`) lack prebuilt binaries that moon's toolchain expects. Set this env var to use globally installed tools instead:

```dockerfile
ENV MOON_TOOLCHAIN_FORCE_GLOBALS=true
```

## Remote caching in Docker

To benefit from remote caching during Docker builds, you need to pass credentials into the build context:

```dockerfile
# Using Docker secrets (recommended)
RUN --mount=type=secret,id=cache_token \
  REMOTE_CACHE_TOKEN=$(cat /run/secrets/cache_token) \
  moon run app:build
```

Build with:
```bash
docker build --secret id=cache_token,env=REMOTE_CACHE_TOKEN .
```
