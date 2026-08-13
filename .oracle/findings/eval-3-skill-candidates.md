# Marketplace workflow-mining: skill / command candidates

**Scope.** Read-only mining of `~/Documents/Work/Personal/claude-code-skills/` (the skunkworks marketplace) for workflows that recur across plugins and warrant codification as an auto-trigger skill or a slash command. Evidence base: 14 plugins under `plugins/`, three changelogs at `plugins/{oracle,anvil,meta-skill-improver}/CHANGELOG.md`, hooks at `plugins/{oracle,anvil,rust-monorepo-orchestrator}/hooks/`, the marketplace manifest at `.claude-plugin/marketplace.json:1-211`, and the six-month commit log filtered to `plugins/`.

## Executive summary

Five workflows surfaced more than once across the marketplace and are mature enough to lift into a shared skill / command surface. The strongest signal sits around **plugin-manifest hygiene** (three remediation commits across plugin.json, marketplace.json, plugin-spec compliance) and **the "split workflow into command + methodology skill" refactor** (executed verbatim twice in five days: `425081d` for `analysis-codebase-archaeology` and `a7548a5` for `terraform-audit`, with `296f87e` retroactively applying the same shape to `design-storybook-atomic`). The next tier covers **SessionStart additionalContext injection** (`hookSpecificOutput` JSON envelope reimplemented independently in `oracle/hooks/inject-protocol.sh` and `rust-monorepo-orchestrator/hooks/inject-standard.sh`) and **shellcheck-clean plugin test harnesses** (only `oracle` ships one; `rust-monorepo-orchestrator` and `anvil` ship comparable hook code without coverage). The fifth, **changelog-bump idempotency**, is already mandated by global CLAUDE.md but has no enforcement surface. The natural host is a new `plugin-dev-meta` plugin (or fold into `harness-tuner`, which already owns the meta-plugin slot at `harness-tuner/.claude-plugin/plugin.json:2`); the upstream `plugin-dev` package at `~/.claude/plugins/cache/claude-plugins-official/plugin-dev/45896c8f2fe6/` covers the canonical authoring path but does not enforce these marketplace-local conventions.

Below: five ranked candidates, then a short non-candidates section.

---

## Candidates, ranked

### 1. `plugin-dev-meta:split-skill-into-command-and-methodology`

**Auto-trigger or slash command?** Slash command. This is a structural refactor the developer explicitly invokes when a `SKILL.md` is doing two jobs (procedure + reference). The user-initiated nature, the destructive file moves (delete-and-recreate), and the irreversibility of frontmatter splitting argue for a slash command, not an auto-trigger skill. The Anthropic analogy: skills are the company docs (load when relevant) and commands are the user-facing entry points; this is the latter.

**Purpose.** Refactor a single `plugins/<plugin>/skills/<workflow>/SKILL.md` that conflates user-invokable procedure with reference knowledge into two artefacts: `plugins/<plugin>/commands/<workflow>.md` (the procedural workflow with `disable-model-invocation:true`, `argument-hint`, `model:claude-opus-4-7`) plus a slimmed `plugins/<plugin>/skills/<workflow>/SKILL.md` that retains only methodology, templates, and trigger-phrase auto-load language.

**Description draft.** "This skill should be used when refactoring a plugin so its user-invokable workflow lives in `commands/` while its knowledge lives in `skills/`, matching the Anthropic plugin spec convention. Trigger when a `SKILL.md` mixes procedural Step-1-through-N narrative with reference templates, when a slash command is named the same as a knowledge skill, when the developer says 'split this skill', 'extract the workflow', 'move the procedure to a command', 'this is doing two jobs', or 'commands/ vs skills/'. The refactor produces a paired command + slimmed methodology skill and updates any agent references that loaded the old skill for procedure. Honours the `disable-model-invocation:true`, `argument-hint`, and `model:claude-opus-4-7` frontmatter conventions established by `plugins/terraform-audit/commands/audit.md` and `plugins/analysis-codebase-archaeology/commands/archaeology.md`. Updates the plugin's CHANGELOG.md and version in the same commit."

**Frontmatter sketch.**
```yaml
---
name: split-skill-into-command-and-methodology
description: <as above>
argument-hint: <plugin>/<skill-name>
allowed-tools: Read, Edit, Write, Bash(git:*), Bash(jq:*), Bash(find:*), Bash(grep:*), Glob, Grep
disable-model-invocation: true
model: claude-opus-4-7
---
```

**Body outline.**
1. Resolve target — accept `<plugin>/<skill>` or sniff active plugin from cwd.
2. Diagnose — confirm SKILL.md actually conflates procedure + reference (look for Step-1-through-N headings).
3. Author command — extract procedural sections to new `commands/<skill>.md` with canonical frontmatter.
4. Slim SKILL.md — keep methodology, templates, lens tables, trigger phrases; strip procedure.
5. Sweep references — agents and other skills that loaded the old SKILL for procedure need their bodies updated.
6. Version + changelog — bump SemVer (MINOR), append Keep-a-Changelog entry, present diff for user confirmation, stop short of commit.

**Host plugin.** New `plugin-dev-meta` plugin (cleanest), or `harness-tuner` (existing meta-plugin home at `plugins/harness-tuner/.claude-plugin/plugin.json:2`).

**Evidence.** Two verbatim executions:
- `425081d` (2026-05-05): "analysis-codebase-archaeology v1.2.0: split workflow into command + methodology skill" — commit body at `git show --stat 425081d` describes the exact pattern: new `commands/archaeology.md` (`disable-model-invocation:true`, `argument-hint`, `model:claude-opus-4-7`) + slimmed `skills/codebase-archaeology/SKILL.md` (175 → 92 lines).
- `a7548a5` (2026-05-05, four hours later): "terraform-audit v1.1.0: split workflow into command + slim methodology" — commit body explicitly says "Same shape change as analysis-codebase-archaeology v1.2.0".
- `296f87e` (2026-05-05): plugin-spec compliance retroactively applied the same shape to design-storybook-atomic by moving `disable-model-invocation:true + argument-hint` workflows from `skills/` to `commands/`.
- The shape is now canonical: `plugins/harness-tuner/commands/tune.md:2-27` and `plugins/oracle/skills/setup/SKILL.md` exhibit it. The developer is executing this refactor by hand each time.

---

### 2. `plugin-dev-meta:audit-plugin-manifest`

**Auto-trigger or slash command?** Auto-trigger skill (read-only validator). Fires whenever a plugin's `plugin.json`, `.mcp.json`, or `hooks/hooks.json` is being authored or edited. Read-only means no irreversibility; an auto-trigger is the right shape because the developer often forgets to check the four interlocked invariants (manifest version matches marketplace.json version matches changelog top entry; allowed-tools allow-lists every MCP tool the body references; hooks.json `command` paths are `${CLAUDE_PLUGIN_ROOT}`-rooted; .mcp.json envs interpolate `${VAR}` not `$VAR`).

**Purpose.** Statically validate a plugin's manifest surface against marketplace.json registration, changelog top entry, and hook-script paths. Output: a graded report with file:line citations.

**Description draft.** "This skill should be used when authoring or editing a plugin's manifest surface — `plugin.json`, `.claude-plugin/plugin.json`, `.mcp.json`, or `hooks/hooks.json`. Trigger on edits to those paths, version bumps, marketplace registration, MCP-server addition, hook addition, allowed-tools changes, or whenever the developer says 'validate the manifest', 'check the plugin spec', 'is this plugin schema-correct', 'audit allow-list', 'audit hooks.json'. Verifies five interlocked invariants: (1) `plugin.json:version` matches the entry in `.claude-plugin/marketplace.json` and the top non-Unreleased section in `CHANGELOG.md`; (2) every MCP tool referenced in any agent's `tools:` array or skill's `allowed-tools:` resolves to an actual server in `.mcp.json`; (3) every hook script in `hooks/hooks.json` exists at `${CLAUDE_PLUGIN_ROOT}/hooks/<file>` and is executable; (4) `.mcp.json` env-interpolations use `${VAR}` form not `$VAR`; (5) `description` field is between 80 and 2000 chars. Read-only — does not edit, only reports."

**Frontmatter sketch.**
```yaml
---
name: audit-plugin-manifest
description: <as above>
allowed-tools: Read, Glob, Grep, Bash(jq:*), Bash(find:*), Bash(test:*)
---
```

**Body outline.**
1. Locate plugin root — `${CLAUDE_PLUGIN_ROOT}` or `git rev-parse --show-toplevel` with `.claude-plugin/` sniffing.
2. Five-invariant check — list above, each with PASS / FAIL / WARN.
3. Cross-marketplace consistency — compare `plugin.json` to the corresponding entry in the parent `marketplace.json`.
4. Changelog top-entry parity — version + ISO date.
5. Output contract — markdown table with file:line citations, no edits.

**Host plugin.** New `plugin-dev-meta` or fold into `harness-tuner`.

**Evidence.** Four manifest-hygiene commits in six months:
- `296f87e` (2026-05-05): "Fix marketplace and plugin structure to match Anthropic plugin spec" — six distinct manifest defects fixed in one bundle (commands vs skills directory, scripts location, schema-id URL, version drift between plugin.json `2.1.0` and marketplace entry `2.0.1`).
- `b73b535`: "marketplace v5.16.0: register carbon-solana" — manual registration step.
- `74b3606`: "Align plugins with official Claude Code schemas (#1)" — schema-alignment sweep.
- `38d4ef0`: "Add plugin.json manifests and fix marketplace schema".
- `4788359`: "marketplace: bump skunkworks v5.6.0 -> v5.7.0 for design-storybook-atomic v2.2.0" — version-bump-coupling that an audit skill would surface preemptively.
- The `296f87e` commit body specifically calls out `version: 2.1.0` in plugin.json vs `2.0.1` in marketplace.json drift as a class of bug. The skill's invariant #1 defends against exactly that.

---

### 3. `plugin-dev-meta:session-start-context-injector` (or knowledge skill: `session-start-injection-pattern`)

**Auto-trigger or slash command?** Auto-trigger knowledge skill. Encodes the SessionStart `hookSpecificOutput.additionalContext` pattern as reusable reference, not a one-shot command. The developer keeps writing the same bash shape (jq-emit JSON envelope, python3 fallback, fail-silent on missing tools); a skill describes the contract and the canonical shape, an auto-trigger fires when authoring `hooks/*.sh` that needs to emit `hookSpecificOutput`.

**Purpose.** Reference for the JSON envelope and the dual-runtime (jq / python3 / fail-silent) shape that SessionStart hooks must emit to inject `additionalContext` into a session.

**Description draft.** "This skill should be used when authoring or modifying a `SessionStart` hook script that injects additional context into a Claude Code session via `hookSpecificOutput.additionalContext`. Trigger on creation of `hooks/*.sh` files referenced by a `SessionStart` event in `hooks/hooks.json`, edits to existing SessionStart scripts, mentions of `additionalContext`, `hookSpecificOutput`, `hookEventName`, the literal `SessionStart` string in shell scripts, or developer phrases like 'inject the protocol', 'preload into every session', 'session-bootstrap context'. Encodes the canonical envelope shape (jq-primary, python3-fallback, fail-silent-on-missing-tooling), the 16k-character context cap pattern, and the requirement that `hookEventName` in the output match the wrapping array key in `hooks.json`."

**Frontmatter sketch.**
```yaml
---
name: session-start-injection-pattern
description: <as above>
---
```

**Body outline.**
1. The envelope — exact JSON shape (`hookSpecificOutput.{hookEventName,additionalContext}`).
2. Dual runtime — jq primary, python3 fallback, fail-silent third.
3. Size discipline — 16k char cap (per `inject-standard.sh:14`); rationale.
4. Pairing with hooks.json — `hookEventName` value must match the array key.
5. Worked example — the canonical shape.

**Host plugin.** `harness-tuner` (knowledge belongs with the meta-plugin) or new `plugin-dev-meta`.

**Evidence.** Two independent reimplementations of the same envelope shape:
- `plugins/oracle/hooks/inject-protocol.sh` (registered at `plugins/oracle/hooks/hooks.json:8-15` as the SessionStart entry).
- `plugins/rust-monorepo-orchestrator/hooks/inject-standard.sh:1-39` — line-for-line congruent envelope with the same jq-primary / python3-fallback / `exit 0` shape. Comment at line 7 makes the contract explicit.
- The pattern is being copy-pasted between plugins; codifying it stops the next plugin from reinventing the same bash.

---

### 4. `plugin-dev-meta:plugin-test-harness-scaffolder`

**Auto-trigger or slash command?** Slash command. Scaffolds a new test directory + `tests/run-tests.sh` + the JSON-syntax + shellcheck + per-script test-file conventions that `oracle` ships. User-initiated, file-creating, irreversible relative to whatever was there before — exactly the slash-command shape.

**Purpose.** Generate a `tests/` directory in the target plugin with the shellcheck + jq-empty + per-script test pattern used in `plugins/oracle/tests/run-tests.sh`.

**Description draft.** "This skill should be used when a plugin contains hook scripts or shell-script libraries but has no `tests/` directory, or when the developer asks to 'add tests', 'add a test harness', 'shellcheck this plugin', 'verify the hooks', 'scaffold tests' for any plugin under `plugins/`. Generates `tests/run-tests.sh` (top-level runner with three stages: shellcheck -x on every `.sh`, `jq empty` on every `.json` + `.mcp.json`, per-script `test-*.sh`), one stub `test-<script>.sh` per existing hook script with the structural assertion pattern, and adds a `Requires: shellcheck` note to the plugin's CHANGELOG. Will not overwrite existing tests."

**Frontmatter sketch.**
```yaml
---
name: scaffold-plugin-tests
description: <as above>
argument-hint: <plugin-name>
allowed-tools: Read, Write, Glob, Bash(find:*), Bash(test:*), Bash(mkdir:*)
disable-model-invocation: true
model: claude-opus-4-7
---
```

**Body outline.**
1. Detect target plugin — argument or cwd-sniff.
2. Inventory shell scripts — `find plugins/<plugin> -name '*.sh'`.
3. Generate `tests/run-tests.sh` — three-stage shape from oracle.
4. Generate per-script stubs — one `test-<basename>.sh` per `.sh`.
5. Append CHANGELOG `Requires:` note + update plugin description if MCP is present.
6. Final report — count of scripts covered, sample invocation.

**Host plugin.** New `plugin-dev-meta` or `harness-tuner`.

**Evidence.** Currently only one plugin ships tests:
- `plugins/oracle/tests/run-tests.sh:1-46` — the canonical three-stage shape (shellcheck `-x`, jq-empty, per-script). Five test files at `plugins/oracle/tests/` (`test-budget-lib.sh`, `test-intercept-install.sh`, `test-rate-limit-guard.sh`, `test-rate-limit-track.sh`).
- The `oracle/CHANGELOG.md:44-55` entry documents the design (69 assertions, 19 pass / 0 fail) — establishes it as a deliberate pattern.
- `plugins/rust-monorepo-orchestrator/hooks/*.sh` and `plugins/anvil/hooks/refresh-inventory.sh` are equally complex but untested. The pattern exists once, has earned its keep (caught the 0.1.1 flag-with-arg bug per `oracle/CHANGELOG.md:175-192`), and should be lifted.

---

### 5. `plugin-dev-meta:version-bump-with-changelog`

**Auto-trigger or slash command?** Slash command. Enforces the global CLAUDE.md rule that "every plugin version bump in `plugins/<plugin>/.claude-plugin/plugin.json` must update `plugins/<plugin>/CHANGELOG.md` in the same commit". The user-initiated, multi-file mechanical-coupling shape argues for slash.

**Purpose.** Atomically bump a plugin's SemVer, update marketplace.json's mirror, prepend a Keep-a-Changelog entry (Unreleased -> dated section), stage all three files, and stop short of commit so the developer can write the message.

**Description draft.** "This skill should be used when bumping a plugin's version. Trigger on developer phrases like 'bump <plugin> to <version>', 'release <plugin>', 'cut a release', 'tag a new version', or whenever an edit to any `plugins/<plugin>/.claude-plugin/plugin.json:version` field is proposed. Performs four coupled mutations atomically: (1) increments `plugin.json:version`; (2) increments the corresponding entry in `.claude-plugin/marketplace.json`; (3) renames the `[Unreleased]` section in `plugins/<plugin>/CHANGELOG.md` to `[<version>] - <ISO-date>` and inserts a new empty `[Unreleased]` above; (4) inserts a placeholder Keep-a-Changelog 1.1.0 section template if the changelog lacked an Unreleased section. Refuses to bump if any of the three files would be left inconsistent. Does not commit — leaves the working tree staged for the developer to write the commit message and run `git commit` themselves."

**Frontmatter sketch.**
```yaml
---
name: bump-plugin-version
description: <as above>
argument-hint: <plugin> <major|minor|patch | <semver>>
allowed-tools: Read, Edit, Bash(jq:*), Bash(git:status), Bash(git:diff), Bash(git:add), Bash(date:*)
disable-model-invocation: true
model: claude-opus-4-7
---
```

**Body outline.**
1. Parse args — plugin name + bump kind.
2. Compute next version — read current, apply bump.
3. Edit three files — plugin.json, marketplace.json entry, CHANGELOG.md.
4. Consistency check — diff verification (all three versions match).
5. Stage + report — `git add` the three files, print the diff, stop before commit.

**Host plugin.** New `plugin-dev-meta` or fold into `harness-tuner`.

**Evidence.** The rule is codified in `~/.claude/CLAUDE.md` ("Marketplace repo conventions ... Every plugin version bump ... must update `plugins/<plugin>/CHANGELOG.md` in the **same** commit") yet only three of fourteen plugins ship a CHANGELOG.md at all (`oracle`, `anvil`, `meta-skill-improver` per `find plugins -maxdepth 3 -name CHANGELOG.md`). The drift is observable:
- `oracle/CHANGELOG.md:1-7` and `meta-skill-improver/CHANGELOG.md:1-9` adopt the "convention: every version bump touches this file in the same commit" preamble verbatim — the developer wrote the rule down twice.
- Commits like `4788359` ("marketplace: bump skunkworks v5.6.0 -> v5.7.0 for design-storybook-atomic v2.2.0") demonstrate the second-file step happening in a separate commit, which is exactly what the skill prevents.
- Eleven plugins (every plugin except the three above) currently have no CHANGELOG.md, so the rule cannot be enforced retroactively without the skill scaffolding one.

---

## Non-candidates (recommended to leave uncodified)

Three workflows surfaced in the mining sweep but are recommended **against** codification, to avoid premature abstraction:

**(a) "Address a CodeRabbit review" workflow.** Commit `a44618b` ("k8s-deployment-readiness: address CodeRabbit review, 12 findings") is the only instance in the six-month log; the existing `coderabbit:autofix` and `coderabbit:code-review` skills already cover this surface. A bespoke marketplace-local skill would duplicate an upstream skill the developer already has installed.

**(b) "Bundle a third-party Apache-2.0 skill verbatim" workflow.** Done once (`a7548a5` bundled Anton Babenko's terraform-skill v1.6.0 into `plugins/terraform-audit/skills/terraform-skill/`). The licence-attribution detail in `terraform-audit/.claude-plugin/plugin.json:11` is bespoke enough per-bundle (different licence, different attribution copy, different version-pin policy) that a skill would calcify the wrong abstraction. Better left as a one-off.

**(c) "Rename a plugin (and propagate)" workflow.** Done once for `design-storybook-atomic -> anvil` (`3e14d3f`, anvil 3.0.0). The propagation touched ~/.claude/agents/, ~/.claude/commands/, ~/.claude/settings.json, runtime data directories, and configuration filenames (per `anvil/CHANGELOG.md:58-66`). A renaming skill would have to encode all those external touch-points, but each rename has a different blast radius. Recommend keeping this as a manual transcript-driven exercise.

---

## Ranking summary

| Rank | Candidate | Frequency | Impact | Host |
|---|---|---|---|---|
| 1 | split-skill-into-command-and-methodology | 3 commits in five days | High (canonical refactor) | new `plugin-dev-meta` or `harness-tuner` |
| 2 | audit-plugin-manifest | 4+ manifest-fix commits | High (defends version drift) | new `plugin-dev-meta` or `harness-tuner` |
| 3 | session-start-injection-pattern | 2 independent reimplementations | Medium (saves rediscovery) | `harness-tuner` |
| 4 | scaffold-plugin-tests | 1 mature reference, 3 untested candidates | Medium-high (test coverage debt) | new `plugin-dev-meta` |
| 5 | bump-plugin-version | Global rule, 3 of 14 plugins compliant | High once retroactive scaffolding lands | new `plugin-dev-meta` or `harness-tuner` |

A single new plugin `plugin-dev-meta` hosts candidates 1, 2, 4, 5; `harness-tuner` is the natural home for candidate 3 (the knowledge-skill shape fits the existing meta-plugin charter at `harness-tuner/.claude-plugin/plugin.json:2`). If consolidation is preferred, all five can live in `harness-tuner` since it already declares itself as the meta-plugin slot for harness-level optimisation.
