# CI/CD Integration Reference

moon provides first-class CI support through the `moon ci` command, which automates change detection, task selection, and parallel execution.

## Table of Contents
- [moon ci command](#moon-ci-command)
- [How it works](#how-it-works)
- [Revision comparison](#revision-comparison)
- [Target selection](#target-selection)
- [Parallel distribution](#parallel-distribution)
- [Caching in CI](#caching-in-ci)
- [Provider setup](#provider-setup)

## moon ci command

```bash
moon ci                                # run all affected tasks
moon ci :build :test :lint             # run specific task types
moon ci --base main --head HEAD        # explicit revision range
moon ci --job 0 --job-total 4          # shard across jobs
moon ci --include-relations            # include dependency/dependent tasks
```

## How it works

When `moon ci` runs, it automatically:

1. Determines changed files by comparing HEAD against a base revision
2. Identifies all tasks affected by those changes
3. Additionally runs affected tasks' dependencies (and dependents if `--include-relations`)
4. Generates an action and dependency graph
5. Installs the toolchain and dependencies
6. Executes all actions using a thread pool (parallel by default)
7. Reports pass/fail statistics

In v2, graph relations (dependents) are **not** included by default. Use `--include-relations` to restore v1 behavior.

## Revision comparison

moon auto-detects base/head based on CI provider. Fallback is `vcs.defaultBranch` → `HEAD`.

Override with:
```bash
moon ci --base origin/main --head HEAD
```

Or environment variables (highest precedence):
```bash
MOON_BASE=origin/main
MOON_HEAD=HEAD
```

## Target selection

By default, `moon ci` runs ALL affected tasks. You can filter:

```bash
moon ci :build :test            # only "build" and "test" tasks
moon ci app:build api:test      # specific project:task pairs
```

Tasks with `runInCI: false` are excluded. Tasks named `dev`, `start`, or `serve` are excluded by default.

The `runInCI` option is now respected across `moon ci`, `moon check`, `moon run`, and `moon exec`. Commands also respect the `CI` environment variable — use `--ci` to force CI mode or `--ignore-ci-checks` to override.

## Parallel distribution

For CI environments with matrix/sharding support:

```bash
moon ci --job-total 4 --job 0    # job 0 of 4
moon ci --job-total 4 --job 1    # job 1 of 4
```

moon distributes tasks evenly across jobs. Each job independently determines which tasks it owns.

### GitHub Actions example

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
      - run: moon ci --job-total 4 --job ${{ matrix.index }}
```

### Other providers

- **CircleCI**: Use `parallelism` + `CIRCLE_NODE_INDEX`/`CIRCLE_NODE_TOTAL`
- **Buildkite**: Use `parallelism` + `BUILDKITE_PARALLEL_JOB`/`BUILDKITE_PARALLEL_JOB_COUNT`
- **GitLab CI**: Use `parallel` + `CI_NODE_INDEX`/`CI_NODE_TOTAL`

## Caching in CI

### Remote caching (recommended)

Configure in `.moon/workspace.*`:

```yaml
remote:
  host: 'grpcs://cache.example.com:9092'
  auth:
    token: '$REMOTE_CACHE_TOKEN'
```

Cache strategies via CLI:
- `--cache read-write` — default, read and write to cache
- `--cache read` — read-only, useful for deploy builds
- `--cache write` — write-only, useful for cache warming
- `--update-cache` — force cache refresh

### Manual caching (alternative)

If not using remote caching, persist these directories in your CI cache:
- `.moon/cache/hashes`
- `.moon/cache/outputs`

Do NOT persist other `.moon/cache/` directories — they aren't portable.

Since tasks can generate different hashes each run, you'll need to handle invalidation manually. This is why remote caching is recommended.

## Provider setup

### GitHub Actions

```yaml
jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0          # full history for change detection
      - uses: moonrepo/setup-toolchain@v1
        with:
          auto-install: true
      - run: moon ci
```

The `moonrepo/setup-toolchain` action installs both moon and proto.

### Other providers

Install moon via npm or the install script:

```bash
# Via npm (add to devDependencies)
npx moon ci

# Via install script
curl -fsSL https://moonrepo.dev/install/moon.sh | bash
moon ci
```

Ensure `fetch-depth: 0` (or equivalent) for full git history — moon needs it for change detection.
