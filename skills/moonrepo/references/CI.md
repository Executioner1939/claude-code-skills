# Moon CI/CD Integration

Complete guide to integrating moon with CI/CD pipelines.

## How `moon ci` Works

The `moon ci` command:
1. Determines changed files by comparing HEAD against base revision
2. Identifies affected targets and their dependencies
3. Generates action and dependency graphs
4. Installs toolchain and dependencies
5. Runs affected tasks with `runInCI` enabled
6. Reports pass/fail statistics

## Basic Setup

### GitHub Actions

```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: ['main']
  pull_request:

jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0  # Required for affected detection

      - uses: moonrepo/setup-toolchain@v0
        with:
          auto-install: true

      - run: moon ci
```

### GitLab CI

```yaml
# .gitlab-ci.yml
stages:
  - ci

ci:
  stage: ci
  image: node:22
  before_script:
    - curl -fsSL https://moonrepo.dev/install/moon.sh | bash
    - export PATH="$HOME/.moon/bin:$PATH"
  script:
    - moon ci
  variables:
    GIT_DEPTH: 0
```

### CircleCI

```yaml
# .circleci/config.yml
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

workflows:
  main:
    jobs:
      - ci
```

### Azure Pipelines

```yaml
# azure-pipelines.yml
trigger:
  - main

pool:
  vmImage: ubuntu-latest

steps:
  - checkout: self
    fetchDepth: 0

  - script: curl -fsSL https://moonrepo.dev/install/moon.sh | bash
    displayName: Install moon

  - script: |
      export PATH="$HOME/.moon/bin:$PATH"
      moon ci
    displayName: Run CI
```

## Task CI Configuration

### Enable/Disable CI

```yaml
tasks:
  build:
    command: 'npm run build'
    options:
      runInCI: true  # Run in CI (default)

  dev:
    command: 'npm run dev'
    options:
      runInCI: false  # Never run in CI

  deploy:
    command: 'npm run deploy'
    options:
      runInCI: 'only'  # Only run in CI, not locally
```

### `runInCI` Values

| Value | Description |
|-------|-------------|
| `true` | Run when affected (default) |
| `false` | Never run in CI |
| `'always'` | Always run, even if not affected |
| `'affected'` | Only when affected (same as `true`) |
| `'only'` | Only in CI, not locally |
| `'skip'` | Same as `false` |

## Affected Detection

### Base/Head Comparison

```bash
# Default: compare against default branch
moon ci

# Explicit comparison
moon ci --base main --head HEAD

# Compare against specific commit
moon ci --base abc123

# For PRs, CI providers usually set these automatically
```

### Filter by Status

```bash
# Only staged files
moon ci --status staged

# Only modified files
moon ci --status modified

# Multiple statuses
moon ci --status added --status modified
```

## Parallelization

### Job Distribution

Split work across multiple CI jobs:

```yaml
# GitHub Actions matrix
jobs:
  ci:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        index: [0, 1, 2, 3]
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - uses: moonrepo/setup-toolchain@v0
      - run: moon ci --job ${{ matrix.index }} --job-total 4
```

### How It Works

- `--job-total` splits affected tasks evenly
- `--job` (0-indexed) runs only that job's tasks
- Tasks distributed based on estimated duration

## Remote Caching

### Self-Hosted (Bazel Remote)

```yaml
# .moon/workspace.yml
remote:
  host: 'grpc://cache.example.com:9092'
```

### Cloud-Hosted (Depot)

```yaml
# .moon/workspace.yml
remote:
  host: 'grpcs://cache.depot.dev'
  auth:
    token: 'DEPOT_TOKEN'
    headers:
      'X-Depot-Org': 'your-org-id'
```

### GitHub Actions with Remote Cache

```yaml
jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - uses: moonrepo/setup-toolchain@v0
      - run: moon ci
        env:
          DEPOT_TOKEN: ${{ secrets.DEPOT_TOKEN }}
```

## Run Reports

### GitHub Actions Report

```yaml
jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - uses: moonrepo/setup-toolchain@v0
      - run: moon ci
      - uses: moonrepo/run-report-action@v1
        if: success() || failure()
        with:
          access-token: ${{ secrets.GITHUB_TOKEN }}
```

This adds a comment to PRs showing:
- Pass/fail status for each task
- Duration of each task
- Cache hit/miss statistics

## Advanced Patterns

### Conditional Task Execution

```yaml
tasks:
  deploy-staging:
    command: 'deploy --env staging'
    options:
      runInCI: 'only'  # Only in CI

  deploy-prod:
    command: 'deploy --env production'
    options:
      runInCI: false  # Manual only
```

### Environment-Specific CI

```yaml
# .github/workflows/ci.yml
jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - uses: moonrepo/setup-toolchain@v0
      - run: moon ci :lint :test
        if: github.event_name == 'pull_request'
      - run: moon ci :lint :test :build
        if: github.ref == 'refs/heads/main'
```

### Caching Node Modules

```yaml
jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - uses: moonrepo/setup-toolchain@v0

      - uses: actions/cache@v4
        with:
          path: |
            ~/.proto
            node_modules
            .moon/cache
          key: ${{ runner.os }}-moon-${{ hashFiles('**/package-lock.json', '.moon/**/*.yml') }}

      - run: moon ci
```

### Multi-OS Testing

```yaml
jobs:
  ci:
    strategy:
      matrix:
        os: [ubuntu-latest, macos-latest, windows-latest]
    runs-on: ${{ matrix.os }}
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - uses: moonrepo/setup-toolchain@v0
      - run: moon ci
```

### Version Matrix Testing

```yaml
jobs:
  ci:
    strategy:
      matrix:
        node-version: [18, 20, 22]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - uses: moonrepo/setup-toolchain@v0
      - run: moon ci
        env:
          MOON_NODE_VERSION: ${{ matrix.node-version }}
```

## Debugging CI

### Verbose Logging

```yaml
- run: moon ci --log debug
  env:
    MOON_DEBUG_PROCESS_ENV: 'true'
    MOON_DEBUG_PROCESS_INPUT: 'true'
```

### Query Affected

```yaml
- name: Show affected
  run: |
    moon query affected
    moon query changed-files
```

### Force Run

```bash
# Bypass affected detection
moon ci --force

# Run specific tasks regardless of affected
moon run :build :test --force
```

## Best Practices

1. **Always use `fetch-depth: 0`** for full Git history
2. **Enable remote caching** for large pipelines
3. **Use `runInCI: false`** for dev servers and watch modes
4. **Parallelize with job matrix** for faster CI
5. **Add run reports** for visibility
6. **Cache dependencies** across runs
7. **Use `--base` and `--head`** for explicit comparisons
8. **Set appropriate timeouts** on long tasks
