# Oracle re-architecture proposal

Status: **proposal**, awaiting user sign-off. Authored 2026-05-14 against oracle 0.5.0.

The goal: rebuild oracle as the user's personal Claude Code harness — a values-driven framework for codifying and enforcing standards in agent behaviour, with the existing Helm scaffold promoted from a half-built experiment to the load-bearing build system. Keep the name `oracle`. Keep the verification cascade as the flagship standard. Drop the sprawl, drop the half-completed bundles, replace the entry-skill duplication with a single standards registry.

The end state is one plugin that hosts an extensible library of standards (verification, anti-hype, parallel-tools, path-preflight, session-checkpoint, ... and whatever the user codifies next), where each standard ships as a Helm-rendered package and the harness enforces compliance through prompt-based and agent-based hooks.

## Vision in one paragraph

A *standard* in oracle is the unit of disciplined agent behaviour: a detection rule (when does the standard apply), a protocol body (what the agent must do), an enforcement hook (how compliance is judged), and an intensity ladder (loose, standard, strict). Each standard is a values-driven Helm package rendered into the skill/agent/command/hook slots that Claude Code understands. The harness is the registry plus renderer plus enforcement layer that ties them together. New standards are added by authoring one `standards/<name>/` directory; the rest of oracle picks them up automatically.

## The unifying abstraction — what a "standard" is

A standard is a directory under `standards/<slug>/` with this shape:

```
standards/oracle-001-verification-cascade/
  spec.yaml                # name, version, intensity range, defaults, lifecycle
  detector.md.j2           # auto-trigger phrases for the skill that surfaces this standard
  protocol.md.j2           # the prose the agent reads when the standard applies
  enforcement.json.j2      # Stop/SubagentStop prompt-hook bodies (judgment criteria)
  references.md.j2         # standards-body links, RFC numbers, doc citations
  eval/
    snapshots/<scenario>/  # reproducer trees for the meta-skill-improver eval harness
    postconds/<scenario>.py
```

`spec.yaml` declares the standard's metadata:

```yaml
slug: oracle-001-verification-cascade
display_name: Verification cascade
version: 1.0.0
applies_to: [tool-use, recommendation, citation]
default_intensity: standard
intensities: [loose, standard, strict]
enforcement:
  available: [stop-prompt, subagent-stop-prompt, subagent-stop-agent]
  default: subagent-stop-prompt
emits:
  skill: verify              # rendered to skills/verify/SKILL.md
  command: verify            # rendered to commands/verify.md (optional, alias to skill)
  hooks: [enforcement]       # rendered into hooks/hooks.json
references:
  - https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-4-best-practices
```

The renderer reads `standards.yaml` (a top-level registry of enabled standards), iterates each enabled standard's `spec.yaml`, and renders its templates into the standard plugin slots. From the user's perspective, adding a new standard is a one-directory addition.

## Pillar map

Eight pillars, each independently scoped so the user can opt into the rebuild incrementally.

### Pillar 1 — Promote the Helm scaffold to the build system

The renderer already exists (`scripts/oracle-render.py`) and is sound. What is missing is **the production templates**. Today, `templates/fragments/*` is populated but `templates/{skills,agents,commands,hooks}/` is empty. Hand-authored components under `skills/`, `agents/`, `commands/`, `hooks/` bypass the renderer entirely.

The move: author `.j2` templates for every component the harness ships. Every operational file in `skills/`, `agents/`, `commands/`, `hooks/` becomes a rendered artifact. Hand-authored components remain supported (the renderer is additive — files without a `.j2` source are left alone), but the harness's own components are all rendered. The pattern is then available to the user for project-specific extensions.

Outcome: `oracle-render` becomes the canonical build step. `/oracle:apply` (renamed from `setup`) runs the renderer for the current project. `/oracle:check` runs `oracle-render --check` and reports drift.

### Pillar 2 — The standards registry

Promote standards to a first-class concept in `values.yaml`:

```yaml
standards:
  oracle-001-verification-cascade:
    enabled: true
    intensity: standard
    enforcement:
      mode: subagent-stop-prompt    # stop-prompt | subagent-stop-prompt | subagent-stop-agent | none
      scope: research-silos          # all | research-silos | named-agents
      named_agents: []
  oracle-002-anti-hype-ranking:
    enabled: true
    intensity: standard
    enforcement: { mode: none }
  oracle-003-parallel-tools:
    enabled: true
    intensity: standard
    enforcement: { mode: stop-prompt }
  oracle-004-path-preflight:
    enabled: true
    intensity: standard
    enforcement: { mode: pre-tool-deterministic }  # already shipped as safe-edit-guard.sh
  oracle-005-session-checkpoint:
    enabled: true
    intensity: standard
    enforcement: { mode: none }
  oracle-006-citation-discipline:
    enabled: true
    intensity: standard
    enforcement: { mode: subagent-stop-prompt }
```

Add `standards.yaml` listing the directory roots oracle should scan (the bundled ones live under `plugins/oracle/standards/`; user-supplied standards can live anywhere the user points to). The schema gets a new top-level `standards` object with per-standard substructure, validated as strict (`additionalProperties: false`).

Outcome: the standards installed in the harness are visible from one file. The user can add, remove, or reconfigure a standard without editing skill bodies.

### Pillar 3 — The enforcement layer

The single most important architectural gap in oracle 0.5.0: nothing actually judges Claude's output for compliance. The `verification-protocol` skill is a hope, not a guarantee. `anthropics/claude-code#57661` documents the exact failure mode oracle exists to prevent — Opus 4.7 ignoring its own verification skill — and the current plugin cannot catch it.

The fix is the prompt-based and agent-based hook types I documented under `docs/claude-code/hooks.md:142`. Each standard's `enforcement.json.j2` produces a hook entry. The renderer aggregates them into `hooks/hooks.json`.

Three enforcement modes, in increasing rigour and cost:

- `stop-prompt` — `Stop` hook with `type: prompt`, single-turn Haiku judgment on whether the assistant's response complies with the standard. Per-fire cost: roughly 30 seconds of Haiku.
- `subagent-stop-prompt` — `SubagentStop` hook with `type: prompt`, scoped to a matcher (the subagent's `agent_type`). Fires only when a research silo finishes. Lower cost than `stop-prompt` because subagent stops are rarer than main-conversation stops.
- `subagent-stop-agent` — `SubagentStop` hook with `type: agent`, spawns a small judgment subagent that can Read/Grep/Glob the filesystem and verify claims against actual state. Highest fidelity, highest cost. Reserve for standards that demand filesystem grounding (oracle-006-citation-discipline: "did the silo write the file it claimed to cite").

The judgment prompts are rendered from each standard's `enforcement.json.j2`, parameterised by intensity. A `strict` oracle-001-verification-cascade enforcement requires two independent sources cited; `standard` requires one; `loose` is skipped.

Outcome: oracle becomes an actively-enforcing harness rather than a passive reference library. The user opts in per standard, per intensity, with the budget cost made explicit by the enforcement mode chosen.

### Pillar 4 — Collapse the slash-command surface

Today: 12 skills, six of which are directory-form slash commands (`/oracle:setup`, `/oracle:verify`, `/oracle:research`, `/oracle:vet`, `/oracle:budget`, `/oracle:mcp-fleet`), several of which are entry-skill / protocol-skill pairs.

Proposed: six slash commands, every one a lens over the standards registry:

| Command | Purpose |
|---|---|
| `/oracle:apply` | Run the renderer for the current project. Replaces `/oracle:setup`. Idempotent. |
| `/oracle:check` | Run the renderer in `--check` mode. Reports drift between the lockfile and current values + templates. |
| `/oracle:standards` | List active standards, their intensities, their enforcement modes. Subcommands: `enable`, `disable`, `set <standard>.<key>=<value>`. |
| `/oracle:verify` | Run the verification cascade on a supplied claim. The flagship standard, still surfaced as a first-class command. |
| `/oracle:research` | Multi-silo research workflow. Lives under the `oracle-007-research-protocol` standard. |
| `/oracle:vet` | Single-target library vetting. Lives under the `oracle-008-library-vetting` standard (currently the `vet` skill). |

`/oracle:budget` and `/oracle:mcp-fleet` move out — see Pillar 7 and Pillar 8 respectively.

The entry-skill / protocol-skill split disappears. Each standard ships one skill body (the rendered `protocol.md`), and the slash command surfaces it via `argument-hint`. No more `verify` + `verification-protocol`, no more `research` + `oracle-007-research-protocol`.

Outcome: 12 skills → 6 standards. The skill-listing budget pressure (12 × ~700 chars ≈ 80% of Opus's default 1% context-window cap) is roughly halved.

### Pillar 5 — Composable executor agents

The five research silos (`canon-reader`, `github-archivist`, `forum-anthropologist`, `issue-investigator`, `cost-rethinker`) stay, with two changes:

1. Their bodies are rendered from `templates/agents/<name>.md.j2`, so they pick up values-driven configuration (effort level, allowed tools, skill preloads).
2. They get a sixth sibling: a `judge-claims` agent for the enforcement layer. When a standard's enforcement mode is `subagent-stop-agent`, the hook spawns this agent with the standard's judgment criteria + the stopping subagent's transcript + the relevant filesystem context. Returns `decision: approve` or `decision: block` with `reason`.

Every executor agent's system prompt is built from the `opus-4-7-prompting` snippet bank (already a skill in `harness-tuner`). The snippet selection is encoded in `spec.yaml` as the agent's role (`orchestrator`, `planner`, `worker`, `verifier`, `auditor`, `reference-ingester`), and the renderer expands the right snippets into the rendered body. This makes the opus-4-7-prompting snippets active, not passive — every agent the harness ships is built from them.

Outcome: agent bodies are no longer hand-authored prose with embedded Anthropic snippets copy-pasted across files. The snippets are single-sourced; the renderer composes them by role.

### Pillar 6 — The values layer becomes the user's harness configuration

`values.yaml` today carries oracle-specific settings (verification, research, budget). After the rebuild, it carries the user's whole harness:

```yaml
project:
  language: rust
  ci_runner: github-actions
  doc_registry: auto

standards:
  # one block per standard (see Pillar 2)

agents:
  canon_reader:         { enabled: true,  effort: high  }
  judge_claims:         { enabled: true,  effort: high  }   # new (Pillar 5)
  # ...

style:
  no_emojis: true
  prose_over_bullets: false

extensions:
  # User-supplied standards directories
  paths:
    - ~/.claude/oracle-standards/
    - ./.oracle/standards/
```

`extensions.paths` is the load-bearing extension point. The user can author a new standard anywhere on the filesystem and oracle picks it up. This is what makes the harness "personal" — the user grows the standards library without forking the plugin.

Outcome: a single configuration surface for the user's discipline preferences across every standard the harness enforces.

### Pillar 7 — Move `mcp-fleet` out

`scripts/mcp-fleet/` (Node, 64 KB) and `scripts/mcp-fleet-py/` (Python, with a 155 MB local `.venv/` on disk for any contributor) are two parallel implementations of multi-workspace MCP OAuth-token isolation. Neither has anything to do with truth verification or standards enforcement. They got bundled into oracle because oracle also bundles `firecrawl-mcp`, but the two responsibilities should not share a plugin.

Move `mcp-fleet` to a sibling plugin: `plugins/mcp-fleet/`. Pick Node OR Python; delete the other. The Node implementation is 24× smaller and uses Playwright for browser automation, which is already a marketplace dependency via `oracle/scripts/mcp-fleet/lib/playwright-launcher.mjs`. Recommendation: keep Node, retire Python.

Outcome: oracle loses ~155 MB of unrelated concern from its source tree. Users who want truth verification can install just oracle; users who want multi-workspace MCP onboarding install `mcp-fleet`.

### Pillar 8 — Move `budget` into the verification standard, eliminate the standalone command

The firecrawl rate-limit budget is enforcement infrastructure for the verification cascade, not its own product. The `budget/` skill (`/oracle:budget`) is a status/control surface for that infrastructure. It should not be one of the seven user-facing slash commands.

Fold it into the verification standard's emitted set. `/oracle:apply` writes the budget state; `/oracle:check` reports it; the verification standard's `protocol.md.j2` includes the `_rate-limit-etiquette.md` fragment so budget rules are visible to the agent following the cascade.

Outcome: one fewer top-level command. The budget remains observable and controllable, just from `/oracle:standards oracle-001-verification-cascade` or by reading `~/.claude/plugins/oracle/usage.json` directly.

## Directory shape — before and after

### Before (oracle 0.5.0)

```
plugins/oracle/
  .claude-plugin/plugin.json
  .mcp.json
  .render.lock.yaml
  values.yaml
  values.schema.json
  README.md
  CHANGELOG.md
  agents/
    canon-reader.md          # hand-authored
    cost-rethinker.md
    forum-anthropologist.md
    github-archivist.md
    issue-investigator.md
  commands/
    init.md                  # only flat-file command; the other six are skills
  skills/
    oracle-002-anti-hype-ranking/SKILL.md
    budget/SKILL.md
    mcp-fleet/SKILL.md
    oracle-003-parallel-tools/SKILL.md
    oracle-004-path-preflight/SKILL.md
    research/SKILL.md
    oracle-007-research-protocol/SKILL.md
    oracle-005-session-checkpoint/SKILL.md
    setup/SKILL.md
    verification-protocol/SKILL.md
    verify/SKILL.md
    vet/SKILL.md
  hooks/
    hooks.json
    inject-protocol.sh
    intercept-install.sh
    oracle-preflight.sh
    rate-limit-guard.sh
    rate-limit-track.sh
    safe-edit-guard.sh
    track-reads.sh
  scripts/
    budget-lib.sh
    cost-table.json
    oracle-render.py
    mcp-fleet/                       # 64 KB Node, OAuth isolation, unrelated concern
    mcp-fleet-py/                    # 155 MB on disk inc .venv, duplicate of above
  templates/
    fragments/                       # populated
      _cite-sources.md
      _rate-limit-etiquette.md
      _ecosystems/{rust,typescript,python,go,multi}.md
      _verification-strictness/{loose,standard,strict}.md
    (skills/, agents/, commands/, hooks/ all empty)
  tests/
    run-tests.sh
    test-budget-lib.sh
    test-intercept-install.sh
    test-rate-limit-guard.sh
    test-rate-limit-track.sh
    test-safe-edit-guard.sh
    lib/assert.sh
  docs/
    SEARCH-WORKFLOWS.md
    HELM-TEMPLATE-SYSTEM.md          # (this rebuild adds it; companion of this file)
    RE-ARCHITECTURE.md               # this file
```

### After (proposed)

```
plugins/oracle/
  .claude-plugin/plugin.json
  .mcp.json
  README.md
  CHANGELOG.md
  values.yaml
  values.schema.json
  standards.yaml                     # top-level registry of active standards
  standards/
    oracle-001-verification-cascade/
      spec.yaml
      detector.md.j2
      protocol.md.j2
      enforcement.json.j2
      references.md.j2
      eval/{snapshots,postconds}/
    oracle-002-anti-hype-ranking/
      ...
    oracle-003-parallel-tools/
      ...
    oracle-004-path-preflight/
      ...
    oracle-005-session-checkpoint/
      ...
    oracle-006-citation-discipline/
      ...
    oracle-007-research-protocol/               # replaces research-protocol
      ...
    oracle-008-library-vetting/                 # replaces vet
      ...
  templates/
    fragments/                       # unchanged
      _cite-sources.md
      _rate-limit-etiquette.md
      _ecosystems/*.md
      _verification-strictness/*.md
      _opus-4-7-snippets/            # NEW: per-role-role snippet selection
        orchestrator.md.j2
        planner.md.j2
        worker.md.j2
        verifier.md.j2
        auditor.md.j2
        reference-ingester.md.j2
    skills/
      verify/SKILL.md.j2             # rendered from standards/oracle-001-verification-cascade/
      research/SKILL.md.j2           # rendered from standards/oracle-007-research-protocol/
      vet/SKILL.md.j2                # rendered from standards/oracle-008-library-vetting/
      standards/SKILL.md.j2          # the /oracle:standards meta-skill
      apply/SKILL.md.j2              # replaces setup
      check/SKILL.md.j2              # new
    agents/
      canon-reader.md.j2
      cost-rethinker.md.j2
      forum-anthropologist.md.j2
      github-archivist.md.j2
      issue-investigator.md.j2
      judge-claims.md.j2             # NEW (Pillar 5)
    hooks/
      hooks.json.j2                  # aggregates per-standard enforcement entries
      inject-protocol.sh.j2
      intercept-install.sh.j2
      safe-edit-guard.sh.j2
      track-reads.sh.j2
      rate-limit-guard.sh.j2
      rate-limit-track.sh.j2
  scripts/
    oracle-render.py
    budget-lib.sh
    cost-table.json
  tests/
    run-tests.sh
    test-render.sh                   # NEW: end-to-end render tests
    test-budget-lib.sh
    test-intercept-install.sh
    test-rate-limit-guard.sh
    test-rate-limit-track.sh
    test-safe-edit-guard.sh
    lib/assert.sh
  evals/                             # NEW: meta-skill-improver scorecards
    oracle-001-verification-cascade/...           # flagship; rest deferred per decision log
  docs/
    SEARCH-WORKFLOWS.md
    HELM-TEMPLATE-SYSTEM.md
    RE-ARCHITECTURE.md               # this file
    STANDARDS-AUTHORING.md           # NEW: how to add a new standard
```

`mcp-fleet` moves to its own plugin (`plugins/mcp-fleet/`).

## Migration phases

Five phases, each independently shippable and each leaving the plugin in a working state.

### Phase 0 — Land the docs (no behaviour change)

This file and `HELM-TEMPLATE-SYSTEM.md` get committed. README points readers at them. CHANGELOG entry: "0.5.1 — documented the Helm template scaffold and the re-architecture proposal". Zero risk; sets the design baseline.

### Phase 1 — Mint the standards directory and one template

Author `standards/oracle-001-verification-cascade/{spec.yaml,detector.md.j2,protocol.md.j2,references.md.j2}` and `templates/skills/verify/SKILL.md.j2`. Re-render the existing `skills/verify/SKILL.md` from the new template. The skill body and frontmatter must be byte-identical to the pre-render version on first run — this is the "behaviour-preserving migration" gate.

Once that round-trip works, do the same for `oracle-002-anti-hype-ranking`, `oracle-003-parallel-tools`, `oracle-004-path-preflight`, `oracle-005-session-checkpoint`. Verify each round-trips byte-identical, then delete the hand-authored sources.

Outcome: the harness's own skills are now rendered. The renderer is the build system.

### Phase 2 — Add the enforcement layer

For each standard, author `enforcement.json.j2`. Aggregate them into `templates/hooks/hooks.json.j2`. Add the `judge-claims` agent. Wire `SubagentStop` prompt-hooks on the four research silos (`canon-reader`, `github-archivist`, `forum-anthropologist`, `issue-investigator`), gated by `standards.oracle-001-verification-cascade.enforcement`.

Run `meta-skill-improver:improve-skill "verification cascade behaviour"` against the new harness with the enforcement layer on and off; expect the eval scorecard to show a measurable lift.

Outcome: oracle becomes an actively-enforcing harness. The flagship standard demonstrates the new model.

### Phase 3 — Collapse the slash-command surface

Author `standards/oracle-007-research-protocol/` and `standards/oracle-008-library-vetting/`. Render `skills/research/SKILL.md.j2` and `skills/vet/SKILL.md.j2`. Delete the `research`, `research-protocol`, `vet` hand-authored skills under `skills/`. Author `skills/standards/SKILL.md.j2` (the `/oracle:standards` meta-skill), `skills/apply/SKILL.md.j2` (replaces `setup`), `skills/check/SKILL.md.j2`.

Update `README.md` and the plugin description in `.claude-plugin/plugin.json` to advertise six standards-aware commands rather than six legacy commands.

Outcome: 12 skills → 6. Listing budget freed. The user-facing surface matches the architectural model.

### Phase 4 — Extract mcp-fleet, retire the duplicate implementation

Create `plugins/mcp-fleet/`. Move `scripts/mcp-fleet/*` into the new plugin's `scripts/`. Author its own `.claude-plugin/plugin.json`, README, CHANGELOG. Bump marketplace `metadata.version`. Delete `plugins/oracle/scripts/mcp-fleet-py/` (the Python duplicate) along with its 155 MB venv. Remove `mcp-fleet` from oracle's slash-command surface and from `values.yaml`.

Outcome: oracle stops carrying unrelated concern. Users can install one without the other.

### Phase 5 — Wire the eval harness against the flagship

Scope per the decision log below: **flagship only**. Author `standards/oracle-001-verification-cascade/eval/snapshots/<scenario>/` and `eval/postconds/<scenario>.py` for at least one reproducer that demonstrates the failure mode the cascade defends against (the anthropics/claude-code#57661 class — Opus 4.7 ignoring its own verify skill). Wire `/meta-skill-improver:improve-skill "verification cascade behaviour" --target oracle:verify` to grade the rebuild. Author `tests/test-render.sh` that runs the renderer in `--check` mode against a known-good fixture set.

Other standards ship without per-standard eval scaffolding in this phase. Their `eval/` directories stay empty until the user has used them in anger and decides which ones earn the rigour. The pattern from oracle-001-verification-cascade is the template for the eventual expansion.

Outcome: the flagship's claims about behavioural impact are measurable. The rest of the registry has the slot wired into `spec.yaml` but no scorecards yet — adding one later is one-directory-per-standard work, not a re-architecture.

## What stays the same

The Helm scaffold (Jinja2 renderer, layered values, schema validation, lockfile drift detection) is the right shape — it just needs the production templates the rebuild authors. The renderer's CLI surface is unchanged. The fragments under `templates/fragments/` are unchanged. The four-element subagent contract from `opus-4-7-prompting` continues to be the dispatch shape.

The verification cascade is unchanged: three tiers (package-manager CLI, firecrawl-search, WebSearch/WebFetch), citation-discipline mandatory, speculation forbidden under `verification.forbid_speculation: true`. The cascade is just one standard among N now.

The five research silos stay, with their bodies rendered rather than hand-authored. Their behaviour is unchanged.

## What gets dropped

- Entry-skill / protocol-skill duplication. The merger lets one skill body serve both the slash-command surface and the auto-trigger body.
- `commands/init.md` as a flat-file outlier. It becomes a directory-form skill alongside the others.
- The `mcp-fleet` Python implementation and its checked-in-on-disk 155 MB `.venv/`.
- The `mcp-fleet` skill body inside oracle (the slash command moves to the sibling plugin).
- The standalone `budget/` skill body. Budget control surfaces via `/oracle:standards oracle-001-verification-cascade` or the oracle-001-verification-cascade `protocol.md`.

## Decision log

Three architectural decisions, answered by the user on 2026-05-14 before Phase 1 work begins.

1. **Standards directory location: inside the plugin.** Standards live under `plugins/oracle/standards/<slug>/`. Oracle ships with its bundled standards in-tree. User-supplied standards are reachable via the `extensions.paths` config in `values.yaml` (defaults: `~/.claude/oracle-standards/`, `./.oracle/standards/`) — that is the portability surface for personal additions without forking the plugin.
2. **Standards naming convention: RFC-style numbered.** Slugs are `oracle-<NNN>-<noun-phrase>`. The initial registry: `oracle-001-verification-cascade` (flagship), `oracle-002-anti-hype-ranking`, `oracle-003-parallel-tools`, `oracle-004-path-preflight`, `oracle-005-session-checkpoint`, `oracle-006-citation-discipline`, `oracle-007-research-protocol`, `oracle-008-library-vetting`. Numbers are allocated at authorship and stable across renames; the noun-phrase part of the slug may be revised without breaking the ID. Slash commands keep their short user-facing names (`/oracle:verify`, `/oracle:research`, `/oracle:vet`) — only the registry uses the numbered IDs.
3. **Eval harness scope at Phase 5: flagship only.** `oracle-001-verification-cascade` gets a full eval directory with at least one snapshot and one postcond. The other seven standards ship with an empty `eval/` directory wired into their `spec.yaml` but no scorecards. The pattern from the flagship is the template for opportunistic expansion later — adding eval coverage for `oracle-002-anti-hype-ranking` (or any other) is per-standard work that does not change the architecture.

The recommendation for Phase 0 is: land this proposal + the Helm-system doc, then proceed to Phase 1 work directly. Phase 1 is roughly half a day of focused work. The full rebuild across all five phases is three to four days.
