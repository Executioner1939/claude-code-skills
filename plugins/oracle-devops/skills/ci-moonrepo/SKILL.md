---
name: ci-moonrepo
description: |
  moonrepo (moon) v2 expert -- workspace, tasks, CI/CD, Docker, remote caching, codegen, WASM toolchains, v1-to-v2 migration, plus six guards: affected-detection no-ops, runInCI inheritance traps, project-id / Cargo / Docker name drift, prototools-setup-toolchain churn, remote-cache and sccache flakiness, [[bin]] name collisions.
  Keywords: moon, moonrepo, moon.yml, .moon/, moon ci/run/exec/query/migrate, runInCI, MOON_*, .prototools, rust-toolchain.toml, setup-toolchain, setup-rust, mozilla-actions/sccache-action, sccache, RUSTC_WRAPPER, SCCACHE_*, Depot, $project, DOCKER_IMAGE, ArgoCD ImageUpdater, kustomize, [[bin]], CARGO_TARGET_DIR per-service.
  Affected-detection: "Resolved targets: 0", "No tasks affected by changed files", "build not started", "shards finish in seconds and nothing gets built or pushed", "task inheritance not granular enough".
  runInCI: "missing releases", "turn on fail fast for Moon", "separate moon job for PRs and one for builds", "build-release fires on PR".
  Name drift: "build green but prod unchanged", "CI went green but dev env still serving old behaviour", "argocd image updater not picking up new images".
  Toolchain: "linker not found", "rustc mismatch", "sccache: command not found".
  Cache: "CI hanging", "shard 1 hangs", "builds 8 min now 45+", "cache server unreachable", "oscillating", "we keep flipping this on and off".
  Binary collision: "wrong projection_worker", "[[bin]] name already defined", "link error in CI", "duplicate symbol".
paths:
  - "**/moon.yml"
  - "**/.moon/**"
  - "**/.prototools"
  - "**/rust-toolchain.toml"
  - "**/Cargo.toml"
  - "**/.github/workflows/*.yml"
  - "**/.github/workflows/*.yaml"
  - "**/argocd/**"
---

# moonrepo v2

moon is a Rust-written monorepo management, orchestration, and build system. Latest is **v2.2.4** (April 2026, verified via `npm view @moonrepo/cli version` on 2026-05-14).

Target **v2 syntax** unless the user mentions v1. v1 tells (`toolchain.yml` singular, `node.npm`, camelCase flags, `runner:` instead of `pipeline:`, `type:` instead of `layer:`, `platform:` instead of `toolchains:`) means run `moon migrate v2` and consult `references/moon-cheatsheet.md` for the migration table.

## How to use this skill

Six production-derived failure modes drive almost every moon support request. Match the user's symptom (or log line) against the table below, then read the named section of `references/workflows.md` for the decision tree. The workflows are the load-bearing material; everything else is reference.

| Symptom or log keyword | Workflow |
|---|---|
| `Resolved targets: 0` or `No tasks affected by changed files` on a real diff; missed releases on first push or force-push | `workflows.md` §1 -- affected-detection no-op |
| PR validate accidentally fires `build-release` / `docker-push`; or `moon ci :build-release` silently no-ops; "missing releases", "turn on fail fast" | `workflows.md` §2 -- runInCI inheritance |
| Build green but prod still serving old behaviour; ArgoCD ImageUpdater not picking up new images | `workflows.md` §3 -- project-id / Cargo / Docker / ArgoCD name drift |
| `linker not found`, `rustc mismatch`, `sccache: command not found`; oscillating `MOON_SKIP_*` toggles | `workflows.md` §4 -- toolchain-bootstrap strategy drift |
| `moon ci` hangs on gRPC connect; 8-min builds suddenly 45+ min; "we keep flipping this on and off" | `workflows.md` §5 -- remote cache / sccache flakiness |
| Wrong handler runs in a pod (users-service emitting achievements logic); `[[bin]] name already defined`; duplicate symbol at link time | `workflows.md` §6 -- workspace `[[bin]]` collision |

When the user mentions task inheritance ("task inheritance not granular enough", `.moon/tasks/<lang>.yml`, "why did this task fire"), start with `workflows.md` §2 -- inheritance discipline is the root cause for the over-fire / silent-skip class.

For configuration questions that are not failure-driven (what fields exist on a task, the v1→v2 mapping, MQL syntax, environment variables), go to `references/moon-cheatsheet.md`.

For long-form walkthroughs (worked PR-validate + deploy workflows, the three toolchain-bootstrap strategies side-by-side, the inheritance pattern with CI-lane tag files), go to `references/ci-guide.md`.

## Verification posture

Six rules carry `[unverified-canon]` markers where the user's transcript corpus is the only source and canonical moon docs do not address the failure surface. These are catalogued at the bottom of each workflow in `workflows.md`. Before asserting any moon-CLI version-dependent claim, run the verification cascade: `npm view @moonrepo/cli version` first, then `firecrawl-search` against moonrepo.dev, then WebFetch.

## Cross-skill defences

Some invariants belong at a different layer of the stack and are noted here so the agent knows when to reach for a sibling skill:

- **`rust-monorepo-orchestrator`** is the right scaffold-time home for the binary-name collision rule (§6) and the toolchain-bootstrap three-strategy framing (§4). An ast-grep / `cargo metadata` lint there fires at service-creation time rather than at break-time.
- **`k8s-deployment-readiness`** is the natural home for the four-name-tuple invariant at deploy-readiness time -- assert the deploy manifest's image-repository last segment matches what the build pipeline emits.
- **`oracle:verification-protocol`** is mandatory for the `[unverified-canon]` claims; assert them as universal only after the three-tier cascade lands a more authoritative source.

## Reference files

| File | Contents |
|---|---|
| `references/workflows.md` | The six failure-mode workflows -- symptom-keyed decision trees. **Read first when diagnosing.** |
| `references/moon-cheatsheet.md` | Quick-reference: config skeletons, commands, task fields, dep syntax, MQL, env vars, v1→v2 migration table. |
| `references/ci-guide.md` | Long-form CI walkthrough: task inheritance pattern, revision comparison, remote cache, worked PR-validate + deploy examples. |
| `references/real-world-gotchas.md` | Symptom-keyed lookup for gotchas that did not warrant a full workflow but bite often. |
| `references/advanced.md` | MQL, project / action graphs, git hooks, environment variables, MCP server, debugging. |

## Scripts

Executable helpers under `scripts/` -- prefer these over hand-rolled shell. They encode the workflow smoke tests and the non-interactive moon-command wrappers.

| Script | Purpose |
|---|---|
| `scripts/graph-json.sh <subcommand> [args...]` | Wrap `moon project-graph` / `task-graph` / `action-graph` so they emit JSON instead of opening a browser. **Use this** instead of bare `moon <graph>` -- the bare form hangs in non-interactive tool contexts. |
| `scripts/affected-fail-fast.sh` | §1 fail-fast contract. Reads `MOON_BASE` / `MOON_HEAD`; exits 1 if diff is non-empty but `moon query projects --affected` returns zero. Drop in CI immediately before `moon ci`. |
| `scripts/audit-inheritance.sh [<root>]` | §2 inheritance smoke test. Asserts every `.moon/tasks/*.yml` declares `inheritedBy:` and every task has explicit `options.runInCI`. |
| `scripts/audit-name-drift.sh [<services-dir>] [<argocd-dir>]` | §3 four-name-tuple check. Compares moon id / cargo name / Docker image / deploy manifest. |
| `scripts/audit-toolchain.sh [<root>]` | §4 detection grep + multi-source-of-truth check. Catches `MOON_SKIP_SETUP_RUST` (silently ignored) and `MOON_TOOLCHAIN_FORCE_GLOBALS=<tool-name>` (parses as falsy). |
| `scripts/audit-bin-collisions.sh [<services-dir>]` | §6 workspace `[[bin]]` and moon-id uniqueness. |
