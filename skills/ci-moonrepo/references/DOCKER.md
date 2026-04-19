# Docker Integration Reference

Moon provides first-class Docker support with commands to scaffold workspaces, generate Dockerfiles, set up dependencies, and prune for production.

## Table of Contents
- [Workflow overview](#workflow-overview)
- [moon docker scaffold](#moon-docker-scaffold)
- [moon docker file](#moon-docker-file)
- [moon docker setup](#moon-docker-setup)
- [moon docker prune](#moon-docker-prune)
- [Multi-stage Dockerfile pattern](#multi-stage-dockerfile-pattern)
- [Alpine compatibility](#alpine-compatibility)
- [Remote caching in Docker](#remote-caching-in-docker)
- [Custom Dockerfile templates](#custom-dockerfile-templates)
- [Workspace-level Docker config](#workspace-level-docker-config)
- [Project-level Docker config](#project-level-docker-config)
- [v2 Docker changes](#v2-docker-changes)

## Workflow Overview

The Docker integration follows a layered approach for optimal Docker layer caching:

1. **Scaffold** -- `moon docker scaffold <project>` -- create minimal workspace skeleton
2. **Copy configs** -- Copy workspace configs (Docker layer cached)
3. **Setup** -- `moon docker setup` -- install toolchain + deps (layer cached if configs unchanged)
4. **Copy sources** -- Copy source files
5. **Build** -- Run build tasks
6. **Prune** -- `moon docker prune` -- remove dev dependencies

## moon docker scaffold

Create a minimal workspace skeleton for a project and its dependencies. Output goes to `.moon/docker/` with two subdirectories:

- `configs/` -- workspace config files (package.json, lockfiles, moon configs)
- `sources/` -- source files for the target project and its dependencies

```bash
moon docker scaffold <...projects>
```

## moon docker file

Generate a multi-stage Dockerfile for a project.

```bash
moon docker file <project> [dest]
```

| Option | Description |
|--------|-------------|
| `--defaults` | Use default options, skip prompts |
| `--build-task <task>` | Task to build the project |
| `--start-task <task>` | Task to start the project |
| `--image <image>` | Base Docker image |
| `--no-prune` | Skip dependency pruning |
| `--no-setup` | Skip dependency setup (v2.0.0+) |
| `--no-toolchain` | Use system binaries instead of toolchain |
| `--template <path>` | Custom Tera template for Dockerfile (v2.0.0+) |

**Example:**
```bash
moon docker file web-app --image node:22-alpine --build-task build --start-task start
```

## moon docker setup

Install toolchain and dependencies inside a Docker container. Run this after copying the scaffolded configs.

```bash
moon docker setup
```

## moon docker prune

Remove extraneous dependencies and install production-only packages. Run after building.

```bash
moon docker prune
```

## Multi-Stage Dockerfile Pattern

```dockerfile
# Stage 1: Base
FROM node:22 AS base
WORKDIR /app

# Stage 2: Skeleton (dependency install -- layer cached)
FROM base AS skeleton
COPY .moon/docker/configs/ .
RUN moon docker setup

# Stage 3: Build
FROM skeleton AS build
COPY .moon/docker/sources/ .
RUN moon run app:build

# Stage 4: Production
FROM base AS production
COPY --from=build /app .
RUN moon docker prune
CMD ["node", "dist/index.js"]
```

The key insight: by copying configs first and running `moon docker setup`, Docker caches the dependency layer. Source changes only invalidate the build stage, not the dependency install.

## Alpine Compatibility

Alpine Linux uses musl libc which can cause issues with precompiled binaries. Set this env var to use system-installed tools instead of proto-managed ones:

```dockerfile
ENV MOON_TOOLCHAIN_FORCE_GLOBALS=true
```

## Remote Caching in Docker

Use Docker build secrets to pass cache tokens:

```dockerfile
RUN --mount=type=secret,id=cache_token \
  REMOTE_CACHE_TOKEN=$(cat /run/secrets/cache_token) \
  moon run app:build
```

Build with:
```bash
docker build --secret id=cache_token,env=REMOTE_CACHE_TOKEN .
```

## Custom Dockerfile Templates

Moon uses the Tera template engine for Dockerfile generation. Provide a custom template:

### Via workspace config

```yaml
# .moon/workspace.yml
docker:
  file:
    template: './docker/Dockerfile.tera'
```

### Via CLI

```bash
moon docker file app --template ./Dockerfile.tera
```

## Workspace-Level Docker Config

```yaml
# .moon/workspace.yml
docker:
  file:
    template: './docker/Dockerfile.tera'     # Custom Tera template
  scaffold:
    configsPhaseGlobs:                       # Extra files for configs phase
      - '*.config.js'
      - '.browserslistrc'
  prune:
    installToolchainDependencies: true       # Reinstall prod deps (default: true)
    deleteVendorDirectories: true            # Remove node_modules, etc. (default: true)
```

## Project-Level Docker Config

```yaml
# <project>/moon.yml
docker:
  file:
    buildTask: 'build'
    startTask: 'start'
    image: 'node:22-alpine'
    template: './custom-Dockerfile.tera'
    runSetup: true                           # v2.0.0+
    runPrune: true                           # v2.0.0+
  scaffold:
    sourcesPhaseGlobs:
      - 'src/**/*'
      - 'assets/**/*'
    configsPhaseGlobs:
      - '*.config.js'
```

## v2 Docker Changes

- `docker.scaffold.include` renamed to `docker.scaffold.configsPhaseGlobs` (workspace) and `docker.scaffold.sourcesPhaseGlobs` (project)
- `docker.prune.installToolchainDeps` renamed to `docker.prune.installToolchainDependencies`
- `.moon/docker/workspace` directory renamed to `.moon/docker/configs`
- `docker.scaffold.copyToolchainFiles` removed
- `--no-setup` option added to `moon docker file`
- `--template` option added for custom Tera templates
- `runSetup` and `runPrune` options added to project-level config
