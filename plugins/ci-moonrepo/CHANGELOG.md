# Changelog

All notable changes to the `ci-moonrepo` plugin are documented in this file.

The format is based on [Keep a Changelog 1.1.0](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [3.5.0] - 2026-05-14

Comprehensive rewrite anchored on real-use friction: "not understanding moon ci". Applies the oracle verification verdict from `phase-04c-oracle-verification.md`, refreshes all moon facts to v2.2.4 (April 2026), surfaces v2.1 and v2.2 features that replace older patterns in the body rules, and ships a new 1224-line comprehensive moon-ci guide at `references/ci-guide.md`. SKILL.md body shrinks from 303 to 304 lines net while moving procedural detail to the guide.

### Added

- **`references/ci-guide.md`** -- comprehensive moon-ci walkthrough (~1220 lines) anchored on the canonical docs (https://moonrepo.dev/docs/v2/guides/ci). Thirteen sections: seven steps of `moon ci`, `runInCI` semantics, the explicit-target filtering rule (with verbatim canon quote), MOON_BASE/MOON_HEAD/github.event.before discipline (including the all-zero SHA trap and double-fallback expression), affected-detection edges and the `^:check` primitive, parallelism via `--job` / `--job-total` + per-provider shard envs, remote-caching schema and the fast-fail probe, the three toolchain-bootstrap strategies (manual rustup / proto auto-install / moon v2 native) with detection grep and worked YAML, reporting via run-report-action and community alternatives, v2.1 + v2.2 features mapped to failure modes, two worked examples (PR validate workflow + deploy workflow with image-push + ArgoCD verify step), and eight anti-patterns mapped one-to-one to the six failure modes plus the `CARGO_TARGET_DIR` corollary.
- v2.1 (March 2026) release-notes coverage in `references/advanced.md`: `moon exec --plan`, three new `affectedFiles` settings, `runInSyncPhase`, `inheritAliases` / `installDependencies`, MCP `generate` JSON schema fix, `$projectTitle` / `$projectAliases` token fixes. Each row maps to the failure mode it addresses where applicable.
- v2.2.4 update (was v2.2.1) per `npm view @moonrepo/cli version` -- skill body, references, and changelog all carry the verified current version.
- `[C9]` Quote from canonical docs in Rule 2 body: "When providing targets, `moon ci` will still only run them if affected by changed files, but will still filter with the `runInCI` option." This is the load-bearing semantic for both failure shapes; elevating the quote into the rule body removes ambiguity.
- `[unverified]` markers in `references/advanced.md` and `ci-guide.md` for four features the cascade could not confirm: `moon ci --fail-on-no-affected` flag, `moon ci --explain` / `--dry-run` flags, new `moon query` schema in 2.1/2.2, and direct S3/GCS remote-cache backends without bazel-remote in front.
- Cross-reference table in SKILL.md `Reference files` now leads with `references/ci-guide.md`.

### Changed

- `[C1]` moon version updated **3.4.0 -> 3.5.0** alongside `2.2.1 -> 2.2.4` (April 2026) across SKILL.md body, `references/advanced.md`, and `references/ci-guide.md`. The `[unverified]` marker on the version line dropped.
- `[C2]` Rule 1 step 4: softened from "`moon exec --downstream` has been observed [unverified] to return wrong/empty answers" to "anecdotally observed to return empty answers under merge-commit bases in the user's transcript corpus, though canon does not address that specific failure surface [unverified-behavioural]". Cited https://moonrepo.dev/docs/commands/query/projects as the canonical primitive. The `[unverified]` marker survives as `[unverified-behavioural]` since the behavioural claim cannot be confirmed by canon.
- `[C3]` Rule 2 closing paragraph **factually corrected**: the previous text claimed `moon query tasks --json` was an unverified subcommand and steered to `moon project <id>`. The Oracle verdict confirmed `moon query tasks` is a documented subcommand at https://moonrepo.dev/docs/commands/query/tasks with `--json` and `--affected` flags. The rewritten paragraph names both primitives: `moon query tasks --affected --json` for graph-wide enumeration, `moon project <id> --json` for single-project introspection.
- `[C4]` Rule 4: `MOON_SKIP_SETUP_RUST` framing tightened. Cited https://moonrepo.dev/docs/how-it-works/action-graph as the source of the documented `MOON_SKIP_SETUP_TOOLCHAIN=true` (scopable per-tool by value) form. `[unverified]` dropped.
- `[C5]` Rule 5: `localReadOnly: true` exact spelling confirmed and cited (https://moonrepo.dev/docs/config/workspace#localreadonly, added in v1.40.0). `[unverified]` dropped.
- `[C6]` Rule 5 sccache+release-LTO bullet: softened from "sccache cannot cache the link/LTO step [unverified]" to "sccache cannot cache the link/LTO step (acknowledged in the sccache community but not in moon's docs [unverified-canon])". Kept the heuristic because the in-corpus evidence is real; just no longer presented as canonical moon guidance.
- `[C7]` Reference-files table: `moon migrate v2` no longer parenthesised as unverified -- the spelling is documented at https://moonrepo.dev/docs/migrate/2.0. `[unverified]` dropped.
- `[C8]` Rule 2 step 2: reframed from "`build-release` should be `runInCI: 'affected'`, not `true`" (which read as canonical recommendation) to "the convention is `runInCI: 'affected'` for `build-release` -- the moon docs accept `true`/`false`/`'affected'` and do not endorse one universally, so this is repo-policy, not canonical guidance". `[unverified]` dropped; replaced with explicit "this is repo-policy".
- `[C9]` Rule 2: load-bearing canonical quote elevated into the rule body (see Added). `[unverified]` dropped.
- SKILL.md body shrunk by moving the procedural detail behind each failure-mode rule to the new `references/ci-guide.md` at named anchors. The rule body in SKILL.md is now the load-bearing one-sentence directive plus the four-or-fewer load-bearing bullets; the full diagnostic procedure, schemas, worked YAML, and anti-pattern smoke tests live in the guide.
- `references/advanced.md` "Release notes" section replaced wholesale with the verified v2.1 + v2.2 surface, each mapped to the failure mode it addresses.
- `plugin.json` description and `marketplace.json` plugin description updated to mention the new `references/ci-guide.md` deliverable.

### Fixed

- `[C3]` The actively-wrong sentence in Rule 2 closing paragraph that mis-categorised `moon query tasks --json` as unverified has been rewritten. The subcommand is real and documented.
- Stale version reference (`2.2.1` -> `2.2.4`) across SKILL.md body, references, and changelog.
- Frontmatter `paths:` written as two separate globs (`*.yml` and `*.yaml`) -- carried forward from 3.4.0.
- The remaining `[unverified]` markers (two, both renamed for clarity: `[unverified-behavioural]` on `moon exec --downstream` empty-answer surface; `[unverified-canon]` on sccache+LTO link-step cacheability) are explicitly scoped: they flag claims the verification cascade could neither confirm nor refute from canon, not claims the agent should silently downgrade.

## [3.4.0] - 2026-05-14

### Added

- `[A2-A8]` Symptom-side trigger phrases in `description:` grouped by failure mode (affected-detection, runInCI, name drift, toolchain, cache, binary collision) -- "Resolved targets: 0", "build green but prod unchanged", "argocd image updater not picking up new images", "shards finish in seconds and nothing gets built or pushed", "we keep flipping this on and off", "[[bin]] name already defined", etc. Verbatim from the production transcript corpus.
- `[A9]` Frontmatter `paths:` extended to include `**/rust-toolchain.toml`, `**/Cargo.toml`, `**/.github/workflows/*.{yml,yaml}`, `**/argocd/**` so the skill auto-attaches when editing the file surface where the failure modes manifest, not only when "moon" appears by name.
- `[B1]` Rule 1: `^:check` task-graph edge primitive named as the load-bearing fix path for library-touch -> service-rebuild propagation.
- `[B2]` Rule 1: `github.event.before` empty-string AND zero-SHA (`0000000000000000000000000000000000000000`) trap on first push / force-push, plus a fail-fast assertion contract when `moon query` returns `[]` on a non-empty diff.
- `[B3]` Rule 3: `DOCKER_IMAGE` env on `docker-push` task as the canonical materialisation site; `argocd/applications/<app>/` + `argocd/image-updaters/<env>-<svc>.yaml` directory layout named.
- `[B7]` Rule 4: `rust-toolchain.toml` named as a fourth pin site (rustup honours it independently of moon).
- `[B8]` Rule 4: detection grep (`grep -l setup-rust .github/workflows/ ; cat .prototools ; cat .moon/toolchains.yml ; cat rust-toolchain.toml`) for identifying the active bootstrap strategy before editing.
- `[B9]` Rule 4: `mozilla-actions/sccache-action@v0.0.9` named as the remediation step; `SCCACHE_GCS_*` / `SCCACHE_S3_*` / `SCCACHE_REDIS_*` env block presence framed as evidence to install sccache, not unset the wrapper.
- `[B11]` Rule 5: concrete 3-line probe snippet (`timeout 25 grpcurl ...` with `nc -zw5` alternative); `MOON_REMOTE_HOST` / `MOON_REMOTE_TOKEN` named as the env vars to unset on probe failure.
- `[B12]` Rule 5: explicit that `SCCACHE_IDLE_TIMEOUT=0` belongs at workflow-level (release LTO link runs inside cargo, not as a separate moon task).
- `[B13]` Rule 5: `SCCACHE_GHA_ENABLED` and the GHA-cache 503 surface named.
- `[B14]` Rule 6: runtime-symptom path -- if a pod produces wrong behaviour for its own domain (users-service emitting achievements logic, missing-profile rows from wrong handler), suspect `[[bin]]` collision before blaming the deploy manifest.
- `[B15]` Rule 6: `grep -nH '^\[\[bin\]\]' services/*/Cargo.toml` and moon-id uniqueness `find ... | uniq -d` checks.
- `[B16]` Rule 6: explicit preempt of the `CARGO_TARGET_DIR` per-service anti-pattern -- defeats workspace incremental compilation and leaves the collision live.
- `[B17]` Rule 2: concrete cargo-argv duplication example (`cargo build --release --package svc --release --package svc`) showing the `mergeArgs` default-merge fire shape (in the lifted `references/real-world-gotchas.md` "Task-inheritance override mechanics" section).
- `[E1-E3]` New "Cross-skill defences" section pointing at `rust-monorepo-orchestrator` for binary-name collision and toolchain-bootstrap rules, `oracle:verification-protocol` for moon-CLI version-dependent claims, and `k8s-deployment-readiness` for the four-name-tuple invariant at deploy time.
- New `references/concepts.md` -- workspace, projects, tasks, smart hashing, project/action graphs lifted from inline body.
- `references/advanced.md` -- new "Release notes -- v2.2" section absorbing the v2.2 changelog block that previously sat inline.
- `references/real-world-gotchas.md` -- new "Task-inheritance override mechanics" section absorbing Rule 2 sub-rules 4 and 5 (`mergeArgs` / `mergeOutputs` default-merge mechanics and the bare-`moon ci` vs explicit-target pattern).

### Changed

- `[A1]` `description:` block compacted -- duplicated v2 version recital removed, redundant `MOON_*` env-var enumeration consolidated (`MOON_*` listed once). Combined `description + when_to_use` is 1484 chars (52 chars headroom under the 1,536-char skill-listing cap).
- `[B6]` Rule 3 reframed as scoped to the canonical Rust-service-deploys-via-image-push topology, not universal.
- `[B10]` Rule 5: probe assertion changed from `which $RUSTC_WRAPPER` to `command -v sccache && sccache --version` (more reliable across shells; verifies the binary actually exists and runs).
- `[D1, D2]` Six failure-mode rules front-loaded above the references table -- agents in incident mode hit rules first.
- `[D3]` v1-to-v2 enumeration deleted from inline body; replaced with a single sniff-list pointer to `references/migration-v1-to-v2.md`.
- `[D4]` "What's new in v2.2" inline block lifted into `references/advanced.md`; replaced with one-line pointer.
- `[D5]` Core Concepts lifted into new `references/concepts.md`; replaced with one-line pointer.
- `[D6]` Three Config Quick Reference blocks consolidated into a single ~15-line "Config skeleton" inline block; surrounding prose moves to the existing reference files.
- `[D7]` Rule 2 split -- sub-rules 1-3 stay inline; `mergeArgs`/`mergeOutputs` mechanics and the bare-`moon ci` vs explicit-target pattern move to `references/real-world-gotchas.md`.
- `[D8]` Quick Reference Commands trimmed -- Initialize, Running, CI sub-blocks stay inline; Docker / Code generation / Inspection sub-blocks move to `references/commands.md` with a one-line pointer.
- Rule 1 step 4 wording softened on `moon exec --downstream` to "observed [unverified] to return wrong/empty answers" rather than asserted universally.
- Rule 2 step 2 (`runInCI: 'affected'` for `build-release`) reframed as topology-scoped per `[B6]` / `[C8]`.
- Rule 2 step 5 / `moon ci :explicit-target` warning softened per `[C9]` to the actual mechanism (`moon ci` filters by `runInCI`; use `moon run` / `moon exec` for `runInCI:false` tasks on deploy lanes) rather than a blanket prohibition.

### Fixed

- `[C1-C9]` Inline `[unverified]` markers appended to nine externally-grounded or version-dependent claims so a future `/oracle:verify` cascade pass can hunt and ground them without losing the claim text: moon v2.2.1 release-notes phrasing, `moon exec --downstream` universality, `moon query tasks --json` subcommand existence, `MOON_SKIP_SETUP_RUST` no-op claim, `localReadOnly` exact key spelling, `RUSTC_WRAPPER + release-LTO` trade-off, `moon migrate v2` subcommand spelling, `build-release runInCI:'affected'` topology assumption, and the `moon ci :explicit-target` mechanism description.
- Frontmatter `paths:` written as two separate globs (`*.yml` and `*.yaml`) since YAML glob braces are not universally portable across glob libraries.

## [3.3.0] - 2026-05-14

### Added

- New `Production Failure-Mode Rules` section in `skills/ci-moonrepo/SKILL.md`, derived from clustered failure modes mined across three production Rust monorepos. Each rule carries a `[failure-mode: <id>]` anchor for downstream eval regression tracking.
- Rule: `moon-affected-detection-misses-targets` -- diagnostic order for `Resolved targets: 0` / `No tasks affected by changed files`, including `MOON_BASE` discipline per event type, propagation flags (`-g --downstream deep`), and `moon query projects --affected --json` as the deploy-target primitive instead of `moon exec --downstream`.
- Rule: `moon-task-run-in-ci-misconfiguration` -- `runInCI` must be explicit on every task; `moon ci <targets>` is additive (not narrowing); `build-release` should be `runInCI: 'affected'`; canonical pattern is bare `moon ci` for validate plus `moon exec` for deploy; per-project overrides need `mergeArgs: replace` / `mergeOutputs: replace`.
- Rule: `moon-project-id-image-name-divergence` -- (moon project id, Cargo package name, Docker image tag last segment, deploy manifest image reference) must line up as a single tuple; `$project` resolves to moon id, not Cargo name; verify all four task overrides (`check` / `test` / `lint` / `build-release`) when names diverge.
- Rule: `moon-toolchain-prototools-drift` -- name the bootstrap strategy (manual rustup / proto auto-install / moon v2 native) before editing `.prototools`, `.moon/toolchains.yml`, `setup-toolchain`, or any `MOON_SKIP_*` / `MOON_TOOLCHAIN_*` env var; single source of truth for the Rust toolchain version; `MOON_SKIP_SETUP_RUST` is silently ignored, use `MOON_SKIP_SETUP_TOOLCHAIN=rust`.
- Rule: `moon-remote-cache-and-sccache-flakiness` -- name the precise sub-symptom (cache unreachable / GHA cache 5xx / RUSTC_WRAPPER without sccache binary) before toggling; require a fast-fail connectivity probe; assert `which $RUSTC_WRAPPER` before any cargo invocation; `unset RUSTC_WRAPPER` for `build-release`; `SCCACHE_IDLE_TIMEOUT=0` in CI.
- Rule: `rust-workspace-binary-name-collision` -- service-prefix every `[[bin]]` name (`<service>_projection_worker`, not `projection_worker`); `cargo build --workspace --bins` smoke + `cargo metadata` uniqueness check before merging a service-scaffold PR; fix the whole collision class in one PR rather than one binary at a time.

### Changed

- `description` in `plugin.json` and skill frontmatter expanded to include the new auto-trigger surface area (Resolved targets: 0, runInCI, MOON_BASE, sccache, ArgoCD image name, build green but prod unchanged, projection_worker collision, etc.) so the skill activates on real-world phrasings of the six failure modes.

## [3.2.0] - prior baseline

Baseline before failure-mode-anchored revision. SKILL.md body documented moon v2 concepts, configuration, CLI, and v2.2 features, plus `references/real-world-gotchas.md` cataloguing field-hardened landmines, but the body itself contained no `[failure-mode: <id>]` anchors and no auditable cell-level evidence.
