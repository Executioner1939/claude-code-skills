# Changelog

All notable changes to the `anvil` plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [3.1.0] - 2026-05-05

### Added

- **New slash command** `/anvil:audit-component <path-to-component>` — audits a single target component end-to-end (Coverage / Quality / Hygiene / Genericness / Accessibility / Tokens / Library Policy) AND sweeps the rest of the codebase for every place each finding's underlying *pattern* is repeated. Premise: a defect found once is almost always a pattern repeated across the codebase, so the audit should make propagation explicit.
- **Pattern-extraction step** — agents in Step 1 flag findings as `PATTERN-ELIGIBLE` and the calling command abstracts each into a typed pattern: `LITERAL` (hardcoded value), `IMPORT` (forbidden / off-policy import), `STRUCTURAL` (render-shape signature), `DOMAIN` (domain-prefix in name), `WRAPPER` (thin wrapper of a primitive), `MISSING` (missing required artifact), `COUPLING` (tight coupling to data shape / route / singleton).
- **Cross-codebase pattern sweep (Step 3)** — typed dispatch per pattern: literal/import patterns via grep; structural patterns via `component-deduplicator` mode=structural; domain/wrapper patterns via `component-cartographer`; missing-artifact patterns via `storybook-coverage-analyst`; coupling patterns via grep grouped by tier.
- **Propagation matrix (Section 3 of the report)** — per pattern: signature, source, recommended remediation, every other occurrence with `file:line`, and a propagation-effort estimate (S / M / L / XL).
- **Action plan ordering (Section 4)** — sequenced as "fix target first, then propagate," with patterns ordered by `(occurrences_count * effort_inverse)` so the highest-leverage propagation runs first.
- `--no-sweep` mode flag — audit the target only, skip the cross-codebase sweep.

### Why

Per-tier audits (`audit-atoms`, `audit-molecules`, `audit-organisms`) grade the layer; they don't make repetition visible. When a deep look at one component surfaces a fix, that same fix usually applies to N other components — but without a cross-cutting sweep, the developer has to remember to check. `/anvil:audit-component` automates the "where else does this happen?" pass and turns "fix this one component" into a leveraged change the user can prioritize on a propagation matrix.

## [3.0.0] - 2026-05-05

### Changed (BREAKING)

- **Plugin renamed** `design-storybook-atomic` → `anvil`. The slash-command namespace prefix changes accordingly: `/design-storybook-atomic:<workflow>` → `/anvil:<workflow>`. Users must update any saved invocations and any cross-plugin references.
- **Workflow renamed** `audit-atomic` → `audit-atoms`. Reads correctly alongside the plural-tier siblings (`audit-molecules`, `audit-organisms`). Old: `/design-storybook-atomic:audit-atomic`. New: `/anvil:audit-atoms`.
- **Runtime data directory renamed** `<scope>/.design-storybook-atomic/` → `<scope>/.anvil/`. Configuration file at `<scope>/.design-storybook-atomic.yml` → `<scope>/.anvil.yml`. Existing baselines in adopting projects need to be moved to the new path or re-generated.
- **Cross-plugin references updated** in `~/.claude/agents/{transcript-analyzer,envelope-proposer}.md` and `~/.claude/commands/codify.md` (the personal `/codify` tool that scans this marketplace) plus `~/.claude/settings.json` `enabledPlugins` map.

### Why

`/design-storybook-atomic:audit-atomic [path]` was verbose and shipped with a singular workflow name (`audit-atomic`) that didn't fit the plural-tier pattern of its siblings. `/anvil:audit-atoms [path]` reads cleanly, is shorter, and the "anvil" name evokes the workshop / forge metaphor that fits a design-system-maintenance toolkit.

## [2.2.0] - 2026-05-05

### Added

- **New skill** `genericness-rubric` — fifth audit axis covering domain-prefix detection, slot-acceptance test, boil-down test, canonical primitives registry, and per-component verdict vocabulary (PASS / DELETE / RENAME-AND-SLOT / MERGE-INTO-PRIMITIVE / PROMOTE-TO-PRIMITIVE). Single source of truth for the canonical primitives shared across `atomic-auditor`, `component-deduplicator`, `component-cartographer`, and `component-composer`.
- **`atomic-auditor` agent**: new `mode: genericness-only` for focused cross-cutting passes; new `GENERICNESS` block in the per-component output (slotted between `HYGIENE` and `COMPOSITE`); new Method Step 5b that runs the four genericness probes (domain-prefix regex, slot-acceptance, boil-down, structural-cluster lookup); BATCH SUMMARY now reports `Domain-named shells`, `Wrapper-of-primitive (DELETE candidates)`, and `Structural-duplicate clusters surfaced`. Composite scoring gains a GENERICNESS override: verdicts `DELETE` / `MERGE-INTO-PRIMITIVE` force `BLOCKED`; `RENAME-AND-SLOT` / `PROMOTE-TO-PRIMITIVE` force `NEEDS-WORK`.
- **`component-deduplicator` agent**: new `mode: structural` that clusters by render-shape signature alone (≥ 0.95 threshold), ignoring prop-name Jaccard; new family-suffix detector covering `Card`, `Tile`, `Tier`, `Strip`, `Rail`, `Bar`, `Item`, `Row`, `Picker`, `Group`, `Selector`, `Wizard`, `Hero`, `Form`, `Drawer`, `Sheet`, `Dialog`, `Banner`, `Badge`, `Pip`, `Chip`, `Button`, `Link`, `Notice`; two-tier threshold (0.75 default; 0.65 with family-suffix or shape-similarity ≥ 0.90).
- **`component-cartographer` agent**: per-component output now emits `domainNamePattern`, `domainPrefix`, `genericPrimitiveCandidate`, `slotsAccepted`, `bodyShapeSignature`. New Method Step 4b derives these from cached source. SUMMARY adds `domain_named_components` and `wrappers_of_primitive_candidates` counters.
- **`component-composer` agent**: new mandatory Method Step 1 — Pre-flight registry lookup against the canonical primitives registry, with hard-stop `GENERICNESS_VIOLATION` halt if a downstream verdict would emit `BUILD-NEW` despite a registry shape-match or domain-prefix-suffix match. New `RENAME` verdict between `EXTEND` and `COMPOSE` for `<Domain><PrimitiveSuffix>` specs.
- **`atomic-design` skill**: new "Genericness as the level test" section enumerating the four failure modes — domain-named shell, pure wrapper, structural duplicate cluster, slot-incomplete — with cross-reference to the formal rubric.
- **`component-composition` skill**: new "Generic primitive registry" table (25 primitives with tier / required slots / variant axis / "tells you to NEW only when…" gate) plus a four-step REUSE-vs-EXTEND-vs-NEW pre-flight (structural-shape lookup → EXTEND/COMPOSE → domain-prefix rename → BUILD-NEW only when both miss).
- **Audit slash commands** (`audit-atoms`, `audit-molecules`, `audit-organisms`): Step 3 cross-cutting dispatch promoted from 4 to 5 agents (6 in `audit-organisms`) — `atomic-auditor mode=genericness-only` joins as a first-class parallel pass. Step 5 synthesis adds a new `SECTION 3 — DOMAIN-COUPLING / GENERICNESS DEFECTS` (DELETE candidates / RENAME-AND-SLOT / MERGE-INTO-PRIMITIVE / PROMOTE-TO-PRIMITIVE subsections); SECTION 1 SUMMARY adds three counts (`Domain-named shells`, `Wrapper-of-primitive (DELETE)`, `Structural-duplicate clusters`); ACTION PLAN gets a new `Block 0 — Surface reduction` that runs DELETE wrappers + RENAME-AND-SLOT shells before any per-component fix work.

### Changed

- **Audit synthesis section ordering** — every audit command renumbers SECTION 3+ by +1 to accommodate the new domain-coupling section. `audit-organisms` SECTION 5 renamed from `ROUTING / DOMAIN VIOLATIONS` to `ROUTING VIOLATIONS` to avoid collision with the new section's framing.
- **Operating rules** in all three audit commands: domain-shell-without-slots and pure-wrapper-of-primitive (DELETE verdict) are now classified as hygiene fails; both force `BLOCKED` regardless of other axis scores.
- **`component-deduplicator` operating rule 3** ("Synonym detection"): the inline synonym list is removed; the agent now defers to the `genericness-rubric` skill as the authoritative registry. Prevents drift between the agent body and the skill.

### Why

A real audit pass on a 33-organism design system scored 72/100 with 5 BLOCKED, but the rubric was structurally incapable of flagging ~30 atomic-design violations: domain-named shells (`BookingWizard`, `LicenceApplication`, `KYCStatus`, `CheckoutShell`, `HeroSimple`, `BrandHero`, `HeroGlobe`), pure wrappers of primitives (`KnownForChip`, `WishlistButton`, `Eyebrow`, `GoldRule`, `StockBadge`), and four structural-duplicate clusters (5 cards, 3 logo strips, 6 list-rows, 4 pickers — each collapsing to one slotted primitive). The audit pipeline lacked a genericness axis, the deduplicator's prop-name Jaccard weighting suppressed shape clusters with domain-divergent props, and no agent consulted a canonical primitives registry. Atomic design's level claim is "this component is a generic primitive at this tier" — without a test for that claim, folder placement was the only signal, which is necessary but not sufficient.

## [2.1.0] - prior to keepachangelog adoption

- Static component-graph scanner (Python, networkx-aware) refreshed via PostToolUse hook.
- Queryable `inventory.json` with reconciliation queue (misnamed / unfoldered / stray / tier-mismatch entries).
- GraphViz / Mermaid / Cytoscape / GEXF exporters.
- Audit Phase 0 baseline-integrity gate.

## [2.0.1] - prior to keepachangelog adoption

- TanStack policy.
- Inter-agent HANDOFF.md contract.
- Latest-only Storybook 10 enforcement (CSF Factories required; legacy CSF / `storiesOf` halted at the migration guide).

## [2.0.0] - prior to keepachangelog adoption

- Initial public release of the atomic-design + Storybook 10 toolkit. CSF Factories only. TanStack-ecosystem-centric. Web (Tailwind 4) + native (NativeWind / Expo / Reanimated). 8 slash-command workflows, 11 specialised subagents, 24+ skills.

[2.2.0]: https://github.com/Executioner1939/claude-code-skills/releases/tag/anvil-v2.2.0
[2.1.0]: https://github.com/Executioner1939/claude-code-skills/releases/tag/anvil-v2.1.0
[2.0.1]: https://github.com/Executioner1939/claude-code-skills/releases/tag/anvil-v2.0.1
[2.0.0]: https://github.com/Executioner1939/claude-code-skills/releases/tag/anvil-v2.0.0
