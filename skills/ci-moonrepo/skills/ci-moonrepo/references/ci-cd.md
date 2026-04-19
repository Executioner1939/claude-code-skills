# CI/CD Integration Reference

How to set up moon in continuous integration pipelines, including provider configs, parallelization, caching strategies, and affected detection.

## Table of Contents
- [How moon ci works](#how-moon-ci-works)
- [GitHub Actions](#github-actions)
- [GitLab CI](#gitlab-ci)
- [CircleCI](#circleci)
- [Azure Pipelines](#azure-pipelines)
- [Parallelization / sharding](#parallelization--sharding)
- [Caching strategies](#caching-strategies)
- [Remote caching in CI](#remote-caching-in-ci)
- [Run reports](#run-reports)
- [Affected detection](#affected-detection)
- [v2 CI changes](#v2-ci-changes)

## How moon ci Works

`moon ci` runs affected tasks in CI environments. Internally it uses `moon exec` with these defaults: `--affected`, `--ci`, `--on-failure=continue`, `--summary=detailed`, `--upstream=deep`, `--downstream=direct`.

The workflow:

1. Determines changed files by comparing HEAD against base revision
2. Identifies affected targets and their dependencies
3. Generates action and dependency graphs
4. Installs toolchain and dependencies
5. Runs affected tasks with `runInCI` enabled
6. Reports pass/fail statistics

```bash
moon ci                              # All affected CI tasks
moon ci :build :lint                 # Specific affected task types
moon ci --base main                  # Compare against main branch
moon ci --job 0 --job-total 4        # Shard across CI jobs
moon ci --include-relations          # Include dependency/dependent tasks
```

## GitHub Actions

```yaml
name: CI
on:
  push:
    branches: [main]
  pull_request:

jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0                   # REQUIRED for affected detection
      - uses: moonrepo/setup-toolchain@v1  # Installs both moon and proto
        with:
          auto-install: true
      - run: moon ci
```

`fetch-depth: 0` is critical -- without full history, moon cannot determine which files changed.

## GitLab CI

```yaml
ci:
  image: node:22
  before_script:
    - curl -fsSL https://moonrepo.dev/install/moon.sh | bash
    - export PATH="$HOME/.moon/bin:$PATH"
  script:
    - moon ci
  variables:
    GIT_DEPTH: 0                         # Full history for affected detection
```

## CircleCI

```yaml
version: 2.1
jobs:
  ci:
    docker:
      - image: cimg/node:22.0
    steps:
      - checkout
      - run:
          name: Install moon
          command: curl -fsSL https://moonrepo.dev/install/moon.sh | bash
      - run:
          name: Run CI
          command: |
            export PATH="$HOME/.moon/bin:$PATH"
            moon ci
```

## Azure Pipelines

```yaml
steps:
  - checkout: self
    fetchDepth: 0                        # Full history
  - script: curl -fsSL https://moonrepo.dev/install/moon.sh | bash
    displayName: Install moon
  - script: |
      export PATH="$HOME/.moon/bin:$PATH"
      moon ci
    displayName: Run CI
```

## Parallelization / Sharding

Use `--job` and `--job-total` to shard tasks across multiple CI jobs. Moon distributes tasks evenly across the total number of jobs.

### GitHub Actions

```yaml
jobs:
  ci:
    strategy:
      matrix:
        index: [0, 1, 2, 3]
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - uses: moonrepo/setup-toolchain@v1
        with:
          auto-install: true
      - run: moon ci --job ${{ matrix.index }} --job-total 4
```

### Provider-specific variables

Some CI providers expose job indices automatically:

| Provider | Job Index | Job Total |
|----------|-----------|-----------|
| CircleCI | `CIRCLE_NODE_INDEX` | `CIRCLE_NODE_TOTAL` |
| Buildkite | `BUILDKITE_PARALLEL_JOB` | `BUILDKITE_PARALLEL_JOB_COUNT` |
| GitLab | `CI_NODE_INDEX` | `CI_NODE_TOTAL` |

## Caching Strategies

Control cache behavior via the `--cache` flag:

| Mode | Description | Use case |
|------|-------------|----------|
| `read-write` (default) | Read and write cache | Normal CI runs |
| `read` | Read-only | Deploy builds (don't pollute cache) |
| `write` | Write-only | Cache warming |
| `off` | No caching | Debugging |

```bash
moon ci --cache read               # Read-only for deploy
moon ci --cache write              # Cache warming run
```

Use `--force` (or `-f`) to bypass cache entirely and re-run all tasks.

## Remote Caching in CI

Configure remote caching in `.moon/workspace.yml`:

```yaml
remote:
  host: 'grpcs://cache.depot.dev'
  auth:
    token: 'DEPOT_TOKEN'               # Env var name
    headers:
      'X-Depot-Org': 'my-org'
  cache:
    compression: 'zstd'
```

Or enable conditionally via environment variable:

```bash
MOON_REMOTE_HOST=grpc://cache:9092 moon ci
```

What gets cached:
- Task outputs (as defined in config)
- stdout and stderr
- Identified by moon-generated hash
- Source code is NOT stored

### Self-hosted (bazel-remote)

```bash
docker run -p 9092:9092 \
  -v /data/moon-cache:/data \
  buchgr/bazel-remote-cache \
  --dir=/data \
  --max_size=50 \
  --storage_mode uncompressed \
  --grpc_address=0.0.0.0:9092
```

```yaml
remote:
  host: 'grpc://cache.internal:9092'
```

## Run Reports

### GitHub Actions

Post a summary of the CI run as a PR comment:

```yaml
- uses: moonrepo/run-report-action@v1
  if: success() || failure()
  with:
    access-token: ${{ secrets.GITHUB_TOKEN }}
```

## Affected Detection

Moon determines affected projects/tasks by comparing changed files against project source directories and task inputs.

### Environment variables for affected detection

| Variable | Description |
|----------|-------------|
| `MOON_BASE` | Override base revision |
| `MOON_HEAD` | Override head revision |

### CLI flags

```bash
moon ci --base main                  # Compare against main
moon ci --affected local             # Use local changes
moon ci --affected remote            # Use remote changes
moon ci --status staged              # Only staged changes
```

## v2 CI Changes

Key differences from v1:

1. **Graph relations excluded by default**: Use `--include-relations` or `MOON_INCLUDE_RELATIONS` env var to restore v1 behavior
2. **`--update-cache` removed**: Use `--force` instead
3. **`moon ci` uses `moon exec` internally**: All exec options available
4. **Shallow checkout errors**: v2.0.3 temporarily disabled the hard error for shallow checkouts
5. **"run" type tasks**: Fixed in v2.0.3 to execute correctly in CI
