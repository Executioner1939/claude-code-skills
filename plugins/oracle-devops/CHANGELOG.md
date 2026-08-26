# Changelog

All notable changes to the `oracle-devops` plugin are documented in this file.

The format is based on [Keep a Changelog 1.1.0](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning 2.0.0](https://semver.org/spec/v2.0.0.html).

## [1.4.0] - 2026-08-26

### Changed

- **terraform-skill synced to its current local development version (skill
  metadata 1.7.0 -> 1.17.1).** Adds a Safe Destroy Protocol (mandatory
  `terraform plan -destroy` preview of every resource -- implicit dependents
  included -- with explicit confirmation, and no `-auto-approve` on destroy),
  cross-cloud resource and security maps (AWS/Azure/GCP) in the
  module-patterns and security-compliance references, a new
  `references/code-intelligence-lsp.md`, a remote-backend selection table in
  state-management, a Provisioners-as-last-resort section in code-patterns,
  and switches the CI cleanup workflow reference from static AWS keys to OIDC
  role assumption (`id-token: write` + `role-to-assume`).

## [1.3.1] - 2026-05-28

### Fixed
- **ci-moonrepo: corrected the `moon query --json` behaviour across three
  reference files.** The skill previously claimed a stray `--json` on a
  `moon query` subcommand is "silently ignored." Verified against moon
  2.2.5 and the official v2/v1 docs, the opposite is true: `--json` was
  **removed** in v2 and now produces a hard clap error
  (`unexpected argument`, exit code 2) on every `query` subcommand
  (`projects`, `tasks`, `changed-files`). Under `set -e` / `pipefail`
  that aborts the CI step rather than no-opping.
  - `references/workflows.md` -- both "silently ignored" statements
    rewritten to document the exit-2 hard error and the v1->v2 break.
  - `references/moon-cheatsheet.md` -- added a `moon query *` entry to the
    v1->v2 CLI breaking-changes list (v1 defaulted to a pipe-delimited
    text table and offered `--json`; v2 made JSON the default and dropped
    the flag).
  - `references/real-world-gotchas.md` -- fixed an active bug in the
    deploy-lane example, which recommended
    `moon query projects --affected --json` (now exit 2); dropped the
    flag.

## [1.3.0] - 2026-05-20

### Added
- **`openapi-rust-gen` skill** for regenerating Rust client crates from
  an OpenAPI spec via the pinned `openapitools/openapi-generator-cli`
  Docker image. Mirrors the hermes-platform `gen-hindsight` +
  `refresh.sh` pattern as a reusable, repo-agnostic command so future
  projects can stop reinventing it.
  - Triggers on phrases like "regenerate the openapi rust client",
    "generate a rust client from this openapi spec", "refresh the
    openapi snapshot", and "moon task to regenerate the <x>-client
    crate".
  - Body documents the script contract, the standard invocation, the
    `moon.yml` wiring (one `gen-<provider>` task + one
    `refresh-<provider>-spec` task), and the failure modes the script
    pre-flights.
- **`scripts/openapi-rust-gen.sh`** -- single-pass, non-interactive
  bundled bash script. Required flags: `--spec` (URL or local path),
  `--out-dir`, `--crate-name`. Optional: `--generator-version`
  (default `v7.10.0`, matching hermes-platform), `--refresh-only`,
  `--workspace-root` (defaults to `git rev-parse --show-toplevel`).
  - URL specs are fetched with curl, atomic temp+mv-written under
    `<workspace>/docker/<provider>/<provider>.<ext>` (extension
    inferred from URL, default yaml).
  - Local specs must live under the workspace root (Docker bind mount
    is `$workspaceRoot:/local`).
  - Pre-flights `docker info` before any network call; fails fast with
    actionable messages on docker-down, curl errors, missing
    `Cargo.toml` in the generator output.

### Notes
- Generator pinned at `v7.10.0` to match hermes-platform's
  `gen-hindsight`. Version bumps are a deliberate, reviewed change.
- No slash command shipped; the skill's keyword/trigger surface is
  specific enough for auto-trigger, and the script is the durable
  interface.

## [1.2.1] - 2026-05-17

### Added
- **`audit/mining/` scaffold** under the ci-moonrepo skill for the
  adjacent-fix-coverage assertion gap surfaced by the 1.2.0 audit.
  Two miners feed a shared co-occurrence schema that an upgraded
  grader can score against:
  - `mine-transcripts.py` -- scans `~/.claude/projects/<encoded-cwd>/
    <session-id>.jsonl` for moon-touching sessions, classifies each
    via shared keyword regex, emits (primary_path, adjacent_path,
    count, evidence) triples per failure mode. Pre-filters to
    moon-relevant paths only; deduplicates by last-3-segment key so
    the same `moon.yml` under different worktrees aggregates.
  - `mine-ci-chains.py` -- runs `git log` against a target repo,
    groups commits within an N-minute window into chains, drops
    chains that fall below the keyword-classifier threshold, emits
    the same triples. Higher-signal surface than transcripts because
    timestamps are objective and "missed-fix" semantics are
    unambiguous (the later commit literally fixed something the
    earlier one didn't).
  - `classifier.py` -- shared keyword regex bank lifted from
    `SKILL.md`'s description/keywords surface so mining and skill
    triggering drift together.
  - `grader-extension.md` -- specifies the new `adjacent_fix_coverage
    >= K of top-N` assertion shape and worked grader procedure.
- Smoke-tested locally: 1,257 transcripts scanned, 133 moon-relevant
  sessions, 717 pairs for the largest failure mode (down from 116k
  before the moon-relevance filter); 1,732 commits parsed from a
  real moon-using repo, 21 chains found within a 60-minute window.

### Notes
- Both miners ship with a `--dry-run` flag and verbose logging.
- README documents the limitations: keyword classifier is
  intentionally promiscuous and the first run requires manual review
  of the top-50 pairs before feeding into the grader.
- The audit workspace itself (`ci-moonrepo-workspace/`) is gitignored
  via the existing `*-workspace/` rule and remains uncommitted.

## [1.2.0] - 2026-05-17

### Changed
- **ci-moonrepo skill restructured workflow-first.** SKILL.md cut from
  305 lines (essay-style "Rules" with inline citations) to a thin
  dispatch table (~75 lines) keying user-symptom phrases to the matching
  workflow in `references/workflows.md`. Net total skill size 4,911 →
  2,400 lines (~50% reduction).
  - New `references/workflows.md` (604 lines): the six failure modes as
    symptom-keyed decision trees, not essays. Each ends in a smoke test.
  - New `references/moon-cheatsheet.md` (453 lines): consolidates the
    nine former canon-mirror files (concepts/commands/tasks/toolchains/
    workspace-config/docker/codegen/ci-cd/migration-v1-to-v2) into one
    quick-reference. Canon depth still lives at moonrepo.dev and is
    fetched on demand via the oracle verification cascade.
  - `references/ci-guide.md` trimmed 1,435 → 715 lines: keeps inheritance
    pattern, revision-comparison deep dive, remote-cache config, three
    toolchain strategies, two worked CI workflows. Drops the seven-step
    canon recap, parallelism / reporting / release-notes sections, and
    anti-patterns table (covered in workflows.md).
  - `references/advanced.md` trimmed 383 → 214 lines: keeps MQL, graphs,
    hooks, env vars, MCP, debugging. Drops release-history recap.
  - Deleted `references/{concepts,commands,tasks,toolchains,workspace-config,docker,codegen,ci-cd,migration-v1-to-v2}.md`.

### Added
- **`scripts/` bundle for workflow smoke tests and graph-command safety:**
  - `graph-json.sh` -- non-interactive wrapper for `moon project-graph`
    / `task-graph` / `action-graph`. The bare forms open a browser and
    hang in non-interactive tool contexts; this wrapper forces `--json`.
  - `affected-fail-fast.sh` -- §1 fail-fast contract. Exits 1 if
    `git diff $MOON_BASE..$MOON_HEAD` is non-empty but
    `moon query projects --affected` returns zero.
  - `audit-inheritance.sh` -- §2 smoke test (every .moon/tasks/*.yml has
    `inheritedBy:`; every task has explicit `options.runInCI`).
  - `audit-name-drift.sh` -- §3 four-name tuple check (moon id / cargo
    name / Docker image / deploy manifest).
  - `audit-toolchain.sh` -- §4 detection grep + multi-source-of-truth +
    catches `MOON_SKIP_SETUP_RUST` (silently ignored) and
    `MOON_TOOLCHAIN_FORCE_GLOBALS=<tool-name>` (parses as falsy).
  - `audit-bin-collisions.sh` -- §6 cargo workspace [[bin]] uniqueness
    plus moon project-id uniqueness.
- **Extended PreToolUse Bash hook** (`hooks/moon-ci-guard.sh`) with
  three new soft-warn tiers:
  - graph-command interactivity warning (open browser, hangs CI)
  - `MOON_SKIP_SETUP_RUST` detection (silently ignored by moon)
  - `--json` on `moon query` detection (silently ignored; JSON is default)
- **Hook messages re-pointed** at the new file/section structure
  (workflows.md §N + ci-guide.md §N).

### Fixed (verification-cascade corrections)
- `MOON_TOOLCHAIN_FORCE_GLOBALS=<tool-name>` is **wrong**. moon source
  parses it as a boolean (`crates/toolchain/src/lib.rs`); a tool name
  evaluates as falsy. Corrected to `=true` / `=1` throughout.
- `setup-rust` reads from `RUSTUP_TOOLCHAIN` / `rust-toolchain.toml` /
  legacy `rust-toolchain` / inputs -- **not** `.prototools`. Strategy A
  workflow updated.
- `dtolnay/rust-toolchain` has no semver tags; pin by channel or version
  (`@stable`, `@1.89.0`). Strategy A pin form corrected.
- `mozilla-actions/sccache-action` latest is `v0.0.10` (was `v0.0.9`).
  Updated. Action does NOT auto-set `RUSTC_WRAPPER=sccache`; worked
  examples now show the explicit export.
- §5 sccache + release-LTO claim refined via primary-source diagnosis
  (mozilla/sccache `src/compiler/rust.rs:1119-1135`; rust-lang/rust#71850
  closed 2025-01-30 as wontfix for fat-LTO). sccache rejects `bin`,
  `cdylib`, `dylib`, `proc-macro` crate types by design; dep rlibs are
  still cached but the final binary crate is not.
- §1 `moon exec --downstream` claim corrected. The exec-vs-query
  asymmetry was wrong -- both share `crates/affected/affected_tracker.rs`.
  The real bug is `crates/vcs/src/git/git_client.rs:530-548` silently
  dropping the head ref (open issue moonrepo/moon#2216, in-flight fix
  PR moonrepo/moon#2513). Workflow now points at the verified issue.

## [1.1.0] - 2026-05-16

### Added
- **moonrepo skill folded in** from the deprecated `ci-moonrepo` plugin
  (was 3.6.0 at fold time). Brings the full moonrepo v2.2 expert content
  plus its five reactive hooks:
  - `SessionStart` -> `orient.sh` workspace-orientation
  - `PreToolUse Edit|Write|MultiEdit` -> `moon-edit-guard.sh` (hard deny
    on `.moon/tasks.{yml,yaml}` singular, requires `inheritedBy:` block)
  - `PreToolUse Bash` -> `moon-ci-guard.sh` (hard deny on `moon ci`
    invocations that reference `github.event.before`)
  - `UserPromptSubmit` -> `moon-prompt-tagger.sh`
- `scripts/lint-moon-config.sh` carried over for standalone CI use.

### Removed (from sibling marketplace)
- `ci-moonrepo` plugin entry is unlisted from `marketplace.json`. The
  files remain on disk under `plugins/ci-moonrepo/` for now; can be
  deleted once oracle-devops is verified to ship the same skill.

## [1.0.0] - 2026-05-16

### Added
- Initial release.
- `skills/terraform-skill/` repackaged verbatim from
  `antonbabenko/terraform-skill@v1.8.0` (Apache-2.0 upstream; see
  `UPSTREAM-LICENSE-terraform-skill`). Covers Terraform / OpenTofu
  modules, native testing + Terratest, CI pipelines, security scanning
  (trivy, checkov), and state ops with version-aware guards.
- Four cherry-picked dev workflow skills repackaged from
  `firecrawl/firecrawl-workflows@main`:
  - `firecrawl-knowledge-base` — build searchable knowledge bases
  - `firecrawl-knowledge-ingest` — ingest content into a knowledge base
  - `firecrawl-qa` — QA on extracted web content
  - `firecrawl-website-design-clone` — extract design systems from running sites
- `assets/` and `tests/` directories carried over from the terraform-skill
  upstream so the skill's references and self-tests still resolve.

### Provenance
- `terraform-skill` is Apache-2.0 (Anton Babenko). The upstream LICENSE
  is preserved at the plugin root as `UPSTREAM-LICENSE-terraform-skill`.
- Firecrawl workflow skills are sourced from `firecrawl/firecrawl-workflows@main`.
