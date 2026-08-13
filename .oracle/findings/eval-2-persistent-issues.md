# Eval 2: Persistent-Issue Audit, skunkworks marketplace

Read-only audit at HEAD `a753105` (oracle 0.3.0). Evidence drawn from `git log --all`, per-plugin commit history, and the three plugins that ship `CHANGELOG.md` (`anvil`, `meta-skill-improver`, `oracle`). All claims cite short commit hashes and `path:line` where applicable.

## Executive summary

The marketplace exhibits a small number of recurring failure modes across versions and across plugins. The most consequential is **changelog absence**: 11 of 14 plugins ship no `CHANGELOG.md` despite the user-documented same-commit-as-version-bump rule, so the version-bump audit trail lives only in commit subjects. The second recurring class is **"ship-then-patch within hours"** — features land at vX.Y.0 and an immediate vX.Y.1 (or unversioned hotfix commit) follows for an edge case that should have been part of the initial release: oracle v0.1.0 → v0.1.1 (`intercept-install.sh` flag-with-arg parsing), meta-skill-improver v0.1.0 → v0.1.1 (`REPO_ROOT` derivation), k8s-deployment-readiness v1.0.0 → `a44618b` (12 CodeRabbit findings, four of them tool-allowlist drift). The third class is **marketplace / plugin.json schema churn** — six distinct historical commits have fixed marketplace structure, path prefixes, array-vs-string fields, and version drift, each time after the layout was already "shipped". A handful of smaller patterns round it out: version-number jumps that skip minors (rust-monorepo-orchestrator went 0.1.0 → 0.4.0 in a single commit), inline-Python-via-heredoc as a `jq` fallback that no test exercises, and docs/description drift on the `terraform-audit` and `oracle` entries.

## Pattern list

### 1. Fix-it-twice on the initial release ("ship vX.Y.0, hot-patch vX.Y.1 the same day")

Evidence:
- `a753105` oracle CHANGELOG `plugins/oracle/CHANGELOG.md:175-192` — v0.1.1 (2026-05-12) fixed `hooks/intercept-install.sh` flag-with-arg parsing for 32+ long-form flags and 5 short flags. The bug shipped in v0.1.0 the same day.
- `c30018b` meta-skill-improver v0.1.1 — `plugins/meta-skill-improver/CHANGELOG.md:11-15`. `REPO_ROOT` derivation used `$CLAUDE_PLUGIN_ROOT/../..`, which points at the user-scope plugin cache when installed via `/plugin install`. Fixed to `git rev-parse --show-toplevel` of cwd. v0.1.0 was committed at `8522a3e` (2026-05-10); v0.1.1 followed the same day.
- `a44618b` k8s-deployment-readiness CodeRabbit-driven hotfix landed within 24h of v1.0.0 (`499633a` on 2026-05-11). Twelve findings, four of which were allow-list omissions (see Pattern 4 below) and one a load-bearing argument-parsing bug: `awk '{print $1}'` truncated paths with spaces, fixed to `sed -E 's/[[:space:]]+--.*$//'`.

Root cause: each of these is a missing test for the integration boundary — flag parsing, repo-root resolution, path-with-whitespace handling. The features were shipped on optimistic-path tests only; the hostile-input cases came back in production within hours. oracle v0.3.0 retroactively addressed this for itself by adding `tests/test-intercept-install.sh` with 23 assertions including all the v0.1.1 flag-with-arg regressions (`plugins/oracle/CHANGELOG.md:48-50`), but the convention has not propagated.

Suggested cross-plugin fix: any plugin that ships a hook script or argument-parsing CLI gets a `tests/` directory with a shellcheck pass and hostile-input assertions before the version-bump commit is made. The oracle-v0.3.0 `tests/run-tests.sh` is the reference implementation.

Severity: high.
Frequency: recurring (3 confirmed instances inside the 6-month window).

### 2. Missing CHANGELOG.md across most of the marketplace

Evidence:
- 11 of 14 plugins have no `CHANGELOG.md`: `analysis-codebase-archaeology`, `carbon-solana`, `ci-moonrepo`, `design-principles`, `docs-eventcatalog`, `harness-tuner`, `k8s-deployment-readiness`, `rust-fmodel`, `rust-monorepo-orchestrator`, `rust-utoipa`, `terraform-audit`. Only `anvil`, `meta-skill-improver`, `oracle` are compliant.
- `rust-monorepo-orchestrator` is at v0.7.0 with five distinct released versions (`b2556f4` v0.1.0, `c413628` v0.4.0, `a3248d6` v0.5.0, `7426406` v0.6.0, `59153d7` v0.7.0) and zero `CHANGELOG.md`. The history of what landed in each release lives only in the long-form commit body of each release commit.
- `~/.claude/CLAUDE.md` explicitly states the convention: "Every plugin version bump in `plugins/<plugin>/.claude-plugin/plugin.json` must update `plugins/<plugin>/CHANGELOG.md` in the **same** commit (Keep a Changelog 1.1.0 format)." The auto-memory at `~/.claude/projects/.../feedback_changelog_convention.md` repeats it.

Root cause: convention exists in user memory and global instructions, but no enforcement gate runs at commit time. The three compliant plugins are all recent (anvil bumped to 4.0.0 on 2026-05-06; meta-skill-improver at 0.1.1 picked up its changelog at `ef0a135`; oracle started with one at v0.1.0). Older plugins predate the convention's enforcement and were never retro-fitted.

Suggested cross-plugin fix: a repo-level `tools/check-changelog.sh` (or a Husky-equivalent shell pre-commit) that fails if `plugins/<x>/.claude-plugin/plugin.json` `version` field changes without a corresponding diff to `plugins/<x>/CHANGELOG.md` in the same staged diff. Retro-fit the 11 missing changelogs from each plugin's commit-subject history; the long-form release-commit bodies have enough text to reconstruct the entries.

Severity: medium (audit trail loss, not runtime breakage).
Frequency: structural — affects 79% of the marketplace.

### 3. Marketplace / plugin.json schema churn

Evidence — six historical commits fixing the layout, each "after the fact":
- `4a5c6ae` "Add marketplace.json for plugin distribution"
- `7b33965` "Fix marketplace source format for plugin installation"
- `abb92ed` "Fix marketplace.json: use local source paths for component discovery"
- `38d4ef0` "Add plugin.json manifests and fix marketplace schema"
- `f285928` "Fix plugin.json: skills and agents must be arrays, not strings"
- `825b0ed` "Fix plugin.json paths: skills/agents values need ./ prefix per docs"
- `74b3606` "Align plugins with official Claude Code schemas (#1)"
- `296f87e` "Fix marketplace and plugin structure to match Anthropic plugin spec" — single bundle that renamed top-level `skills/` → `plugins/`, lifted scripts/schemas out of nested skill dirs, fixed the analysis-codebase-archaeology skill-name mismatch, removed an orphan `fmodel-rust-workspace` plugin from disk, and corrected `design-storybook-atomic` marketplace-vs-plugin version drift (marketplace said 2.0.1 while plugin.json said 2.1.0). 148 files touched.

Root cause: the marketplace and plugin.json schemas are authoritative-but-external. Each layout drift was caught manually by re-reading the upstream docs (`code.claude.com/docs/en/plugins`) months after the fact. No local schema validator runs.

Suggested cross-plugin fix: vendor the upstream JSON schemas (or write minimal ones) and add a `jq`-based validator to a `tools/validate-manifests.sh` that runs in CI: every `plugin.json` must parse, declare a name matching the directory name, declare a semver `version`, and every `marketplace.json` plugin entry must have a corresponding `plugin.json` whose `version` field agrees. The oracle test suite (`tests/run-tests.sh`) already runs `jq empty` on every `.json` + `.mcp.json`, but only for the oracle plugin; lift this to repo-root scope.

Severity: medium.
Frequency: recurring (six historical incidents; one as recent as `296f87e` 2026-05-05).

### 4. Tool-allowlist drift — granted-but-unused, or used-but-not-granted

Evidence:
- `a44618b` (k8s-deployment-readiness CodeRabbit hotfix, 2026-05-11) explicitly added `Bash(sed:*)` to `develop.md` and `Bash(head:*)` + `Bash(sed:*)` to both `staging.md` and `production.md`. These binaries were referenced by existing pipelines in the same files when v1.0.0 shipped at `499633a`. Verified: `git show 499633a:plugins/k8s-deployment-readiness/commands/develop.md` shows only `Bash(awk:*)` granted, while the command body invoked `sed` for path argument stripping.
- The `awk → sed` argument-parsing change inside the same hotfix is the *reason* the `sed` grant was needed; the original v1.0.0 author wrote the allow-list to match the (broken) `awk` implementation, not the corrected one. The fix forced both an implementation change and an allow-list addition.
- oracle v0.2.0 went the other direction and over-listed defensively: "All ten active firecrawl tools allow-listed everywhere; the four deprecated browser_* tools intentionally excluded" (`plugins/oracle/CHANGELOG.md:114-124`). This is the safer drift direction but pays a precision tax — the v0.2.0 CHANGELOG explicitly tracks the deprecated-but-excluded set so future contributors don't add them back.

Root cause: the allow-list and the command body are authored in the same file but reviewed by different eyes — the body is reviewed for correctness, the allow-list is reviewed for minimality. There is no static check that the set of `Bash(<bin>:*)` grants is a superset of the set of binaries actually invoked in the command body.

Suggested cross-plugin fix: a `tools/check-allowlist.sh` that grep-extracts every `Bash(<bin>:*)` from a command's frontmatter, grep-extracts every shell-binary invocation from the command body (best-effort tokenisation; `awk`, `sed`, `head`, etc.), and reports the symmetric difference. False positives are acceptable; the goal is to catch `sed` being used without `Bash(sed:*)` granted.

Severity: medium (commands silently prompt the user for permission, breaking the "no-friction" UX the allow-lists exist to provide).
Frequency: recurring (k8s-deployment-readiness, plus the v2.0.0-era design-storybook-atomic flatten where commands had `disable-model-invocation:true` mixed with implicit-tool-grants — fixed in `296f87e`).

### 5. Version-number jumps that skip minors

Evidence:
- `rust-monorepo-orchestrator` went `b2556f4` v0.1.0 → `c413628` v0.4.0 in a single commit, skipping v0.2.0 and v0.3.0. The commit body explains this as "feature-complete two-plugin release" landing M1 scaffold's follow-on commands + agents in one batch, but the version delta does not communicate what was added in v0.2 / v0.3.
- `terraform-audit` shipped `47516ac` "apply review fixes (v1.0.1)" but the current `plugins/terraform-audit/.claude-plugin/plugin.json` is at v1.1.0 with no v1.0.x trail in any changelog (file does not exist).
- oracle v0.2.0 was authored but never previously committed — landed bundled with v0.3.0 at `a753105`. The CHANGELOG retroactively documents both, which is the right move, but the marketplace-version field bumped 5.21.1 → 5.23.0 in one commit (skipping 5.22.0 entirely).

Root cause: version numbers are authored by-the-feature, not by-the-commit. When several features land in one push, the missing minors silently dissolve. Acceptable on a young plugin; muddies semver expectations for downstream consumers later.

Suggested cross-plugin fix: when bundling, either (a) cherry-pick into separate commits with sequential versions, or (b) skip the intermediate version numbers explicitly and have the CHANGELOG carry empty placeholder sections so the gap is visible. oracle v0.3.0 did (b) correctly (`plugins/oracle/CHANGELOG.md:76` has the v0.2.0 heading even though it shipped concurrently with v0.3.0).

Severity: low.
Frequency: 3 observed instances.

### 6. CodeRabbit feedback as a stand-in for an internal review pass

Evidence:
- `a44618b` "k8s-deployment-readiness: address CodeRabbit review (12 findings)" — applied within 24h of v1.0.0. Twelve findings spanning argument parsing, tool allowlists, MD040 fence labels, MD028 blockquote separators, and a fence-nesting bug (inner ```yaml prematurely closing outer ```markdown), and a README description-vs-count mismatch ("five internal skills" vs the body's six-unique-skills claim).
- `763afec`, `1d95bdf`, `adda3e2`, `52756e2` — four consecutive k8s-observability-metrics fixes on 2026-05-11, the day after v1.0.0 landed. The PromQL fix at `52756e2` ("count without ()" → "count without (cpu, mode)") is a real correctness bug, not a lint nit — the original metric collapsed to a single global series.

Root cause: the plugins ship without an internal lint/review pass; CodeRabbit's PR review is being used as the de-facto first-pass review. This works in the sense that the bugs do get caught, but the cycle time is "ship, then immediately fix in public" rather than "ship cleanly". The k8s-observability PromQL bug is particularly load-bearing — anyone who pinned to the v1.0.0 skill body before the four hotfixes had broken USE-method dashboards.

Suggested cross-plugin fix: stand up a pre-commit lint gate that runs the cheap checks locally: `markdownlint-cli2` for MD040 / MD028 / MD031 / MD058 / MD022 in committed `.md` files; `shellcheck -x` for hook scripts (oracle v0.3.0 already does this for itself); `jq empty` for `.json` / `.mcp.json`. The expensive checks (semantic review of PromQL, of generic code logic) still need CodeRabbit, but the lint findings should never reach a public PR.

Severity: medium (per-incident severity ranges low for MD028 to high for the PromQL bug).
Frequency: recurring (12-finding bundle at a44618b plus a 4-commit cluster the same day).

### 7. Hook output formats — used correctly, but with portability gymnastics that no test exercises

Evidence:
- `plugins/oracle/hooks/inject-protocol.sh:77-94` — uses `jq` if available, falls back to inline Python3, falls back to a raw printf. The Python fallback uses an env-var indirection (`PROTOCOL_BODY="$PROTOCOL" python3 - <<'PY'`) to avoid shell-quoting the protocol body into a Python heredoc.
- `plugins/oracle/hooks/rate-limit-guard.sh:66-89` — three branches emit different `hookSpecificOutput` shapes (silent `additionalContext`, `permissionDecision: ask` with `permissionDecisionReason`, `permissionDecision: deny` with reason). The v0.3.0 test suite (`tests/test-rate-limit-guard.sh`, 13 assertions) covers each tier — this is the *only* hook in the marketplace with tier-coverage tests.
- `plugins/rust-monorepo-orchestrator/hooks/inject-standard.sh:18-30` — same dual-path jq-then-python pattern, no test.
- `plugins/oracle/hooks/intercept-install.sh:253-256` — uses `hookSpecificOutput.additionalContext` for a non-blocking soft reminder. Correct: the install-interceptor never blocks.

Root cause: the harness's hook-output API supports several shapes (`additionalContext`, `permissionDecision`, top-level `decision`); the marketplace's pattern of "jq if available else python3 else printf" is correct but is itself a unit of code that can drift. Only oracle has tests; the other two hook-shipping plugins (anvil's `refresh-inventory.sh`, rust-monorepo-orchestrator's two hooks) are unverified.

Suggested cross-plugin fix: standardise on a single helper script (e.g. `shared/emit-hook-output.sh`) that takes `--type {additionalContext,permissionDecision,decision}` and a payload, and emits the right JSON. Lift oracle's shellcheck + jq-validation pattern into a repo-level test runner so all hook scripts get the same coverage. The marketplace has been lucky here — no hook-output-format bug has shipped that I can find in the 6-month window — but the lack of tests outside oracle is the leading indicator.

Severity: low (latent; no incidents yet observed).
Frequency: structural.

### 8. Description / README / plugin.json drift on the public-facing surface

Evidence:
- `a44618b` fixed the k8s-deployment-readiness README claim that the verifier loaded "six internal skills" to "loads five internal skills ... the last is exercised only when Terraform or GitOps repos are in scope" — to make the count agree with the body's "six unique skills across both agents".
- `296f87e` fixed `design-storybook-atomic` marketplace-vs-plugin.json version drift (marketplace said 2.0.1, plugin.json said 2.1.0).
- `terraform-audit` `plugin.json` description and `marketplace.json` description at `296f87e` diverged: marketplace.json gained a "8-section critique" phrase the plugin.json did not. They are aligned now (both at v1.1.0) but the drift was a real fix.
- oracle v0.3.0 description in `marketplace.json:198` is multi-paragraph and 22 lines long; the same plugin's `plugin.json` description (`plugins/oracle/.claude-plugin/plugin.json`) is shorter. The two are not literally identical, by design, but every minor change creates two places to forget to update.

Root cause: descriptions live in three places (`plugin.json`, `marketplace.json`, `README.md`) with no single source of truth. The current convention is "marketplace.json is the long form, plugin.json is the short form, README is the longest" — workable but uncodified.

Suggested cross-plugin fix: declare `plugin.json` description as the source of truth, generate `marketplace.json` entries' descriptions from it (or at minimum cross-check). Repo-level `tools/check-descriptions.sh` that diffs the two and fails if `plugin.json` description is not a prefix or substring of the `marketplace.json` description.

Severity: low.
Frequency: recurring (3 observed).

## Cross-cutting observations — habits the marketplace as a whole exhibits

**The marketplace ships young, then matures in public.** Eight of the 14 plugins are at v0.x.y or v1.x.y; only `anvil` (4.0.0), `ci-moonrepo` (3.2.0), and `docs-eventcatalog` (2.2.0) have crossed v2.0.0. This is fine for a personal marketplace, but it means the user is the first integration test for every plugin. Patterns 1 and 6 are direct consequences.

**oracle v0.3.0 is the reference implementation for the conventions the rest of the marketplace lacks.** It is the only plugin with `tests/`, the only plugin with a shellcheck-clean hook surface verified by an executable suite, the only plugin with a CHANGELOG covering every release including the v0.1.1 hotfix, the only plugin scoping subagent `Write` / `Edit` to explicit paths (`plugins/oracle/CHANGELOG.md:151-154`), and the only plugin that runs `jq empty` over every `.json` file at test time. Lifting these conventions to repo scope would close five of the eight patterns above.

**Manifest schema knowledge is not version-controlled.** Every schema-fix commit (Pattern 3) cites the upstream Anthropic docs in the body but does not pin or vendor a schema. The next upstream schema change will replay the same loop.

**Hook scripts are the single largest concentration of un-tested code.** Only oracle's three hooks have a test; anvil's `refresh-inventory.sh` and rust-monorepo-orchestrator's two hooks (`inject-standard.sh`, `refresh-on-inbox-change.sh`) ship un-asserted. Hooks are unusual code — they execute outside the model's reasoning loop and emit JSON that the harness consumes verbatim — so a hook bug fails in a way the user only sees as "the model is behaving oddly". The next persistent-issue bucket in 6 months will likely be hook-output-shape bugs.

**Plugin scope and feature scope drift in opposite directions.** Plugins start narrow (oracle v0.1.0 = 1 SessionStart hook + 1 PreToolUse hook + 1 skill + 1 command) and accrete features in single big releases (v0.3.0 = 5 subagents, 5 skills, 5 commands, 4 hooks, a full test suite, a bundled MCP server). The accreting releases are where the patch-within-hours pattern lives. anvil's CHANGELOG shows the same — `[2.2.0]` is dense, `[4.0.0]` is denser, the version line is the boundary the user has to read multiple paragraphs to understand.

## Top 3 recommended conventions to codify

1. **Every plugin SHOULD ship `tests/` with a `run-tests.sh` that exits non-zero on shellcheck findings, JSON syntax failures, or any plugin-specific assertion.** oracle v0.3.0 is the reference (`plugins/oracle/tests/run-tests.sh`). Minimum: `shellcheck -x` on every `.sh` under `hooks/` and `scripts/`, `jq empty` on every `.json` and `.mcp.json`, `markdownlint-cli2` on every `.md` under `commands/` and `skills/`. Plugins shipping argument-parsing logic (hooks that read tool input, install-interceptors, path-stripping commands) MUST add hostile-input assertions before any version-bump commit.

2. **Every plugin MUST ship `CHANGELOG.md` in Keep-a-Changelog 1.1.0 format, updated in the same commit as any `plugin.json` version bump.** Enforce with a repo-level pre-commit gate: if `git diff --cached --name-only` contains `plugins/<x>/.claude-plugin/plugin.json` and the diff hunk touches the `version` field, then `plugins/<x>/CHANGELOG.md` must also be in the staged diff. Retro-fit the 11 missing changelogs from each plugin's commit-subject history.

3. **Every public-facing claim (CHANGELOG entry, README count, marketplace description) SHOULD cite `path:line` of the change it describes.** The user already follows this convention in commit bodies (the `a44618b` and `52756e2` commit messages both cite file paths and line numbers). Lifting it into the CHANGELOG body means future audits can verify "v0.1.1 fixed flag-with-arg parsing in `hooks/intercept-install.sh`" against the actual current line numbers without re-deriving the file from `git blame`. Bonus: when a future refactor breaks the cited line, the CHANGELOG itself becomes the regression signal.
