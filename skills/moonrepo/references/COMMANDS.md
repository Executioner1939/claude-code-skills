# Moon Commands Reference

Complete reference for all moon CLI commands.

## Global Options

Available on every command:

| Option | Description |
|--------|-------------|
| `--cache <mode>` | Cache mode: `off`, `read`, `read-write` (default), `write` |
| `--color` | Force colored output |
| `-c, --concurrency` | Max threads (default: CPU cores) |
| `--dump` | Dump trace profile |
| `--log <level>` | Log level: `off`, `error`, `warn`, `info`, `debug`, `trace` |
| `--log-file <file>` | Write logs to file |
| `-q, --quiet` | Hide non-important output |
| `--theme` | Terminal theme: `dark`, `light` |

## Task Execution

### `moon run` (alias: `moon r`)

Run one or many targets with caching.

```bash
moon run <...target> [-- <args>]
```

**Examples:**
```bash
moon run app:build                    # Single target
moon run client:dev server:dev        # Multiple targets
moon run :test                        # All projects
moon run '#frontend:lint'             # By tag (quote for shell)
moon run ~:build                      # Closest project
moon run :build --query "language=typescript"  # With MQL filter
moon run app:test -- --coverage       # Pass args to command
```

**Options:**
| Option | Description |
|--------|-------------|
| `-f, --force` | Bypass cache, ignore changed files |
| `-i, --interactive` | Run interactively |
| `-s, --summary [level]` | Print action summary |
| `--affected [by]` | Only affected tasks (`local` or `remote`) |
| `--base <rev>` | Base revision for affected |
| `--head <rev>` | Head revision for affected |
| `--query <mql>` | Filter by MQL query |
| `--downstream <depth>` | Include dependents: `none`, `direct`, `deep` |
| `--upstream <depth>` | Include dependencies: `none`, `direct`, `deep` |

### `moon exec` (aliases: `moon x`, `moonx`)

Low-level task execution with fine-grained control.

```bash
moon exec <...target> [-- <args>]
```

Same options as `moon run` plus:

| Option | Description |
|--------|-------------|
| `--on-failure <action>` | On failure: `bail` or `continue` |
| `--only-ci-tasks` | Filter to CI-only tasks |
| `--no-actions` | Skip sync/setup actions |
| `--job <index>` | Current job index (for parallelization) |
| `--job-total <total>` | Total jobs |

### `moon check` (alias: `moon c`)

Run all build and test tasks for projects.

```bash
moon check [...projects]
```

**Options:**
| Option | Description |
|--------|-------------|
| `--all` | Check all projects |
| `--closest` | Check closest project from cwd |

### `moon ci`

Run affected tasks with `runInCI` enabled.

```bash
moon ci [...target]
```

**Examples:**
```bash
moon ci                    # All affected CI tasks
moon ci :build :lint       # Specific affected tasks
moon ci --base main        # Compare against main
```

## Project & Task Information

### `moon project` (alias: `moon p`)

Display project information.

```bash
moon project [id]
```

**Options:**
- `--json` - Output as JSON
- `--no-tasks` - Don't list tasks

### `moon projects`

List all workspace projects.

```bash
moon projects [--json]
```

### `moon task` (alias: `moon t`)

Display task information.

```bash
moon task [target]
```

**Options:**
- `--json` - Output as JSON

### `moon tasks`

List all workspace tasks.

```bash
moon tasks [id] [--json]
```

## Query Commands

### `moon query projects`

Query project information with filtering.

```bash
moon query projects [query]
```

**Filter Options:**
| Option | Description |
|--------|-------------|
| `--affected` | Filter affected projects |
| `--id <regex>` | Match project ID |
| `--language <regex>` | Match language |
| `--layer <regex>` | Match layer |
| `--source <regex>` | Match source path |
| `--stack <regex>` | Match stack |
| `--tags <regex>` | Match tags |
| `--tasks <regex>` | Match tasks |
| `--downstream <depth>` | Include dependents |
| `--upstream <depth>` | Include dependencies |

**Examples:**
```bash
moon query projects                      # All projects
moon query projects --id react           # Filter by ID regex
moon query projects "project~react"      # MQL query
moon query projects --affected           # Affected only
moon query projects --tasks "lint|build" # Has specific tasks
```

### `moon query tasks`

Query task information.

```bash
moon query tasks [query]
```

**Filter Options:**
| Option | Description |
|--------|-------------|
| `--affected` | Filter affected tasks |
| `--command <regex>` | Match command |
| `--id <regex>` | Match task ID |
| `--project <regex>` | Match project |
| `--toolchain <regex>` | Match toolchain |
| `--type <regex>` | Match type |

### `moon query affected`

Query affected projects and tasks.

```bash
moon query affected
```

**Options:**
- `--downstream <depth>` - Include dependents: `none`, `direct`, `deep`
- `--upstream <depth>` - Include dependencies: `none`, `direct`, `deep`

### `moon query changed-files`

Query changed files from VCS.

```bash
moon query changed-files
```

**Options:**
| Option | Description |
|--------|-------------|
| `--base <rev>` | Base revision |
| `--head <rev>` | Head revision |
| `--local` | Local state (like `git status`) |
| `--remote` | Remote state |
| `--status <type>` | Filter: `all`, `added`, `deleted`, `modified`, `staged`, `unstaged`, `untracked` |

## Graph Visualization

### `moon action-graph` (alias: `moon ag`)

Visualize action graph.

```bash
moon action-graph [target]
```

**Options:**
- `--dot` - DOT format output
- `--json` - JSON format output
- `--dependents` - Include dependents
- `--port <port>` - Server port

### `moon project-graph` (alias: `moon pg`)

Visualize project graph.

```bash
moon project-graph [id]
```

### `moon task-graph` (alias: `moon tg`)

Visualize task graph.

```bash
moon task-graph [target]
```

## Code Generation

### `moon generate` (alias: `moon g`)

Generate code from templates.

```bash
moon generate <id> [-- <vars>]
```

**Options:**
| Option | Description |
|--------|-------------|
| `--defaults` | Use defaults, skip prompts |
| `--dry-run` | Don't write files |
| `--force` | Overwrite existing |
| `--template` | Create new template |
| `--to <path>` | Destination directory |

**Examples:**
```bash
moon generate npm-package --to ./packages/new-pkg
moon generate react-component -- --name Button
moon generate my-template --template  # Create template scaffold
```

### `moon template` / `moon templates`

List and inspect templates.

```bash
moon templates [--json]
moon template <id> [--json]
```

## Sync Commands

### `moon sync code-owners`

Generate CODEOWNERS file.

```bash
moon sync code-owners [--force] [--clean]
```

### `moon sync config-schemas`

Generate JSON schemas.

```bash
moon sync config-schemas [--force]
```

### `moon sync projects`

Sync all workspace projects.

```bash
moon sync projects
```

### `moon sync vcs-hooks`

Sync VCS hooks.

```bash
moon sync vcs-hooks [--force] [--clean]
```

## Docker Commands

### `moon docker scaffold`

Create repository skeletons for Docker.

```bash
moon docker scaffold <...projects>
```

### `moon docker file`

Generate multi-stage Dockerfile.

```bash
moon docker file <project> [dest]
```

**Options:**
| Option | Description |
|--------|-------------|
| `--defaults` | Use defaults |
| `--build-task` | Task to build |
| `--start-task` | Task to start |
| `--image` | Base Docker image |
| `--no-prune` | Don't prune workspace |
| `--no-toolchain` | Use system binaries |

### `moon docker prune`

Prune Docker environment.

```bash
moon docker prune
```

### `moon docker setup`

Install tools and dependencies in Docker.

```bash
moon docker setup
```

## Toolchain Commands

### `moon toolchain add`

Add toolchain to workspace.

```bash
moon toolchain add <id> [plugin]
```

### `moon toolchain info`

Display toolchain information.

```bash
moon toolchain info <id> [plugin]
```

## Utility Commands

### `moon init`

Initialize moon in repository.

```bash
moon init [dest] [--minimal] [--yes] [--force]
```

### `moon setup`

Setup toolchain environment.

```bash
moon setup
```

### `moon clean`

Clean workspace cache.

```bash
moon clean [--lifetime <duration>]
```

**Examples:**
```bash
moon clean                    # Default 7 days
moon clean --lifetime "24 hours"
moon clean --lifetime "30 days"
```

### `moon hash`

Inspect or compare hash manifests.

```bash
moon hash <hash1> [hash2] [--json]
```

**Examples:**
```bash
moon hash abc123              # Inspect single hash
moon hash abc123 def456       # Compare two hashes
moon hash abc123 def456 --json
```

### `moon bin`

Get tool binary path.

```bash
moon bin <toolchain>
```

### `moon upgrade`

Upgrade moon binary.

```bash
moon upgrade
```

### `moon completions`

Generate shell completions.

```bash
moon completions [--shell <shell>]
```

### `moon mcp`

Start MCP server for AI integrations.

```bash
moon mcp
```

## Extension Commands

### `moon ext`

Execute WASM extension.

```bash
moon ext <id> [-- <args>]
```

**Built-in extensions:**
```bash
moon ext download -- --url <url> --dest <path>
moon ext migrate-nx
moon ext migrate-turborepo
moon ext unpack -- --src <archive> --dest <path>
```

### `moon extension add`

Add extension to workspace.

```bash
moon extension add <id> [plugin]
```

### `moon extension info`

Display extension information.

```bash
moon extension info <id> [plugin]
```

## Environment Variables

| Variable | Description |
|----------|-------------|
| `MOON_CACHE` | Override cache mode |
| `MOON_LOG` | Override log level |
| `MOON_CONCURRENCY` | Thread pool size |
| `MOON_TOOLCHAIN_FORCE_GLOBALS` | Use PATH binaries |
| `MOON_DEBUG_PROCESS_ENV` | Reveal process env vars |
| `MOON_DEBUG_PROCESS_INPUT` | Reveal process stdin |
| `MOON_SKIP_SETUP_TOOLCHAIN` | Skip toolchain setup |
