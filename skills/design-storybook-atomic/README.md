# design-storybook-atomic v2.0.0

> Atomic design + Storybook 10 expert toolkit for Claude Code. **CSF Factories only.** TanStack-ecosystem-centric. Web + React Native. Inter-agent HANDOFF contract. Audit-history baseline + dated history.

A complete plugin for working on a design system: **atomic design** (Brad Frost), **Storybook 10** (CSF Factories, autodocs, addon-vitest, addon-a11y, addon-docs/blocks), **design tokens** (W3C-DTCG, Style Dictionary, Tokens Studio), **TanStack abstractions** at every atomic level (Query / DB / Form / Table / Virtual / Store / Pacer), composition patterns, and accessibility (WCAG 2.2 AA, WAI-ARIA APG) — wired together with **specialized subagents**, **inter-agent HANDOFF.md contracts**, and **slash-command workflows** for auditing, deduplicating, and composing components.

## What's new in v2.0.0

Breaking changes vs v1.x:

- **CSF Factories is the only accepted format.** CSF3 / CSF2 / `storiesOf` = auto-fail in audits. `story-writer` and `mdx-doc-writer` agents refuse to generate legacy formats. Project on legacy? See `_migration/migration-storybook-7-to-10.md`.
- **TanStack ecosystem mandated by atomic level.** Atoms must expose value-first `onChange` + `onBlur` + aria + forwardRef. Molecules wrap a TanStack Form `field`. Organism tables accept a TanStack Table instance (not raw `data + columns`). Organism lists / grids consume TanStack DB collections (or Query results). Animations use Motion (web) / Reanimated (native) with mandatory `prefers-reduced-motion`.
- **Approved-libraries policy.** Tailwind 4 + Radix + TanStack ecosystem + Zod + Day.js + Motion + Lucide on web; Expo + NativeWind + Reanimated + FlashList + @gorhom/bottom-sheet on native. Forbidden libs (RHF, lodash debounce, moment, date-fns, react-dnd, etc.) blocked by `library-policy-enforcer`.
- **Inter-agent HANDOFF.md contract.** Every multi-agent workflow now writes a HANDOFF.md per phase boundary at `<scope>/.design-storybook-atomic/handoffs/<workflow>-<run>/`; orchestrator halts if any subagent skips printing `HANDOFF: <path>`.
- **Audit-history (mirrors `terraform-audit`).** Tier-1 baseline diff at `<scope>/.design-storybook-atomic/baseline-<level>.md`; Tier-2 dated history at `<scope>/.design-storybook-atomic/history/<level>-<date>.md`. Every audit re-renders Section 9 — Diff vs baseline on subsequent runs.
- **Step N numbered phases** in every workflow body (replacing v1's Phase 1–5 wording) so all marketplace plugins read the same.
- **New `audit-libraries` workflow + `library-policy-enforcer` agent** for end-to-end policy enforcement.
- **5 Han storybook skills replaced with 5 originals** at SB 10 / CSF Factories conventions (Apache-2.0 obligation discharged for those 5 files; the 7 Han atomic-design methodology references are kept with attribution intact since methodology is version-agnostic).

## Layer 1 — Integrated knowledge skills (7)

These auto-load when you're working on relevant files. Modern Storybook 10 conventions throughout.

| Skill | Auto-loads on |
|---|---|
| `atomic-design` | atoms / molecules / organisms / templates / pages — Brad Frost methodology + per-level library obligations table |
| `storybook-authoring` | `*.stories.*`, `*.mdx`, `.storybook/**` — CSF Factories overview |
| `storybook-atomic-integration` | story files in atomic-design folders — sidebar conventions, required-stories per level, MDX-section template per level, addon table per level |
| `design-tokens` | `tokens.json`, Style Dictionary, Tailwind config, theme files — three-tier model, W3C-DTCG, taxonomy, refactor heuristics |
| `component-composition` | components — slot / compound / polymorphic / `asChild` / render-props / headless-and-skin patterns + composition-with-TanStack mapping |
| `accessibility-stories` | a11y configuration, story a11y patterns — addon-a11y + WAI-ARIA APG cheatsheet + manual-check matrix |
| `story-coverage-checklist` | story files — graded rubric. CSF Factories required at file level; CSF3 / CSF2 / `storiesOf` = auto-fail. Per-level required stories, MDX sections, a11y artifacts, hygiene checks (token / library / TanStack / atomic-design discipline) |

## Layer 2 — Storybook deeper-dive skills (5, originals at SB 10)

Each loads alongside `storybook-authoring` for depth on a specific concern. Modern conventions only.

| Skill | Concern |
|---|---|
| `storybook-story-writing` | factory-chain patterns, `.test()` inline tests, story extension, loaders, decorator stacks, sidebar conventions, naming |
| `storybook-args-controls` | argTypes / Controls / Actions / `fn()` spies / conditional controls / table grouping |
| `storybook-component-documentation` | MDX with `@storybook/addon-docs/blocks`, per-atomic-level templates, Doc Block reference |
| `storybook-play-functions` | interaction tests with the pre-bound `canvas`, `step()`-labelled phases, async / loading / error / drag-drop / file-upload / focus-management patterns |
| `storybook-configuration` | `defineMain` / `definePreview`, framework packages, addon registration, MSW integration, manager UI, SB 7→10 import path map |

## Layer 3 — Approved-libraries policy + TanStack integration (3 skills)

| Skill | Role |
|---|---|
| `approved-libraries` | The bouncer-list. Primary picks, approved alternates, forbidden libraries, with reasoning per pick. Web stack + native stack + cross-platform shared layer. Compliance scoring rubric. Per-PR exemption mechanism. |
| `tanstack-integration` | How each TanStack abstraction maps onto each atomic-design level. Field-friendly atom contract. Molecule-as-FormField wrapping a `field`. Organism DataTable accepting a Table instance. Organism lists feeding from DB collections. Cross-platform file split. |
| `_migration/migration-storybook-7-to-10` | Single migration reference for projects upgrading off SB 7 / 8 and CSF2 / CSF3. 11 numbered steps, codemod snippets, completion checklist. |

## Layer 4 — Han atomic-design references (7, attribution intact)

Adapted from the [`han`](https://github.com/TheBushidoCollective/han) plugin marketplace by **The Bushido Collective**, **Apache-2.0**. Methodology is version-agnostic; these complement Layer 1's `atomic-design`.

`han-atomic-design-fundamentals`, `han-atomic-design-quarks`, `han-atomic-design-atoms`, `han-atomic-design-molecules`, `han-atomic-design-organisms`, `han-atomic-design-templates`, `han-atomic-design-implementation`. License preserved at `skills/_han-license/LICENSE-Apache-2.0`.

## Layer 5 — Inter-agent HANDOFF template

`_handoff/HANDOFF-template.md` — adapted from the user's `handoff` skill template, scoped to phase boundaries within a workflow run. Storage path `<scope>/.design-storybook-atomic/handoffs/<workflow>-<run>/phase-<NN>-<from>-to-<to>.md`. Validation contract: write the file, re-read to verify, print `HANDOFF: <path>` to stdout — orchestrator halts on missing line.

## Slash-command workflows (8)

Skill-commands with `disable-model-invocation: true` — they fire only when invoked explicitly. All follow the `terraform-audit` `Step N` numbered pattern; the audit-* variants emit a 9-section report with **Section 9 — Diff vs baseline** when a prior baseline exists.

| Command | What it does |
|---|---|
| `/design-storybook-atomic:audit-atomic` | Grade every atom: coverage, quality, hygiene (TanStack contract + tokens + library policy + a11y). Baseline diff. |
| `/design-storybook-atomic:audit-molecules` | Same, scoped to molecules. Adds composition correctness, no-domain-state-leak, FormField-must-accept-field. |
| `/design-storybook-atomic:audit-organisms` | Same, scoped to organisms. Adds mandatory Empty/Loading/Error, data-contract MDX, no-routing-coupling, Table-instance / DB-collection contracts. |
| `/design-storybook-atomic:audit-tokens` | Source-tier audit + hardcoded-value scan + per-component compliance grade + refactor plan (auto exact matches, manual nearest matches). |
| `/design-storybook-atomic:audit-libraries` | **NEW v2.0.** package.json + import-graph + atomic-level integration audit against `approved-libraries` and `tanstack-integration`. |
| `/design-storybook-atomic:add-component` | Interactive new-component flow. Spec interpreter → cartography → reuse / extend / compose / build verdict → user confirm → composer → token enforce → stories + MDX (parallel) → policy + a11y review. HANDOFF.md per phase. |
| `/design-storybook-atomic:merge-duplicates` | Find near-duplicate clusters, propose canonical + migration plan, apply additive merge + codemod consumers + story consolidation + verify + post-merge audit. HANDOFF.md per cluster. |
| `/design-storybook-atomic:coverage-report` | Full coverage matrix across every atomic level. TanStack adoption heatmap. Top risks with cross-links to triage workflows. Quick wins. Optional `--html`. |

## Specialized subagents (11)

Each agent has tight scope, constrained tools, and **preloads the right knowledge skills** via the `skills:` frontmatter field.

| Agent | Purpose |
|---|---|
| `component-cartographer` | Read-only inventory of every component in the codebase, classified by atomic level. Emits storyFormatViolation / importPathViolation / addonTestViolation flags. |
| `atomic-auditor` | Grade a single component (or batch at one level) against `story-coverage-checklist`. |
| `ui-spec-interpreter` | Turn briefs / screenshots / design URLs into structured component specs. AskUserQuestion for clarification. |
| `component-composer` | Decide reuse / extend / compose / build-new; assemble; merge; fix. Modes: `decide` / `implement` / `fix` / `merge` / `codemod`. |
| `story-writer` | Write CSF Factories stories. Refuses CSF3 / CSF2 / `storiesOf`. |
| `mdx-doc-writer` | Write the Docs MDX page with `@storybook/addon-docs/blocks` only. Refuses legacy `@storybook/blocks`. |
| `design-token-enforcer` | Audit tokens; scan for hardcoded values; refactor exact-match hits. |
| `accessibility-reviewer` | WCAG 2.2 AA + WAI-ARIA APG manual-check pass. Defect list with WCAG SC references and canonical fixes. |
| `component-deduplicator` | Find near-duplicate clusters; propose canonical + migration plan. |
| `storybook-coverage-analyst` | Compute coverage matrix per atomic level (component × story-type × MDX × a11y × token × TanStack). |
| `library-policy-enforcer` | **NEW v2.0.** package.json + import-graph + atomic-level integration audit. Three modes: `audit-deps`, `audit-imports`, `audit-integrations`. |

## How a workflow composes

```text
USER: /design-storybook-atomic:audit-atomic
  │
  ▼
Step 0  load context + check baseline
Step 1  Agent(component-cartographer)             writes phase-01-cartographer-to-auditors.md
        │
        ▼
Step 2  Agent(atomic-auditor) × atoms (parallel batched)
                                                  writes phase-02-auditor-batch-<k>.md
        │
        ▼
Step 3  parallel:
        ├─ Agent(component-deduplicator)          writes phase-03-dedup-to-orch.md
        ├─ Agent(design-token-enforcer)           writes phase-03-tokens-to-orch.md
        ├─ Agent(accessibility-reviewer)          writes phase-03-a11y-to-orch.md
        └─ Agent(library-policy-enforcer)         writes phase-03-policy-to-orch.md
        │
        ▼
Step 4  synthesise 9-section report (incl. Diff vs baseline if applicable)
Step 5  write baseline + dated history
```

Every Agent prints `HANDOFF: <abs path>` on its own line; the orchestrator halts if any line is missing.

## Storage at the audited project

```text
<scope>/
└── .design-storybook-atomic/
    ├── baseline-atoms.md             ← Tier-1 (replaces previous on each run)
    ├── baseline-molecules.md
    ├── baseline-organisms.md
    ├── baseline-tokens.md
    ├── baseline-libraries.md
    ├── baseline-coverage.md
    ├── history/                      ← Tier-2 (additive)
    │   ├── atoms-2026-05-03.md
    │   ├── tokens-2026-05-03.md
    │   └── …
    └── handoffs/
        ├── audit-atomic-20260503-1734-a3/
        │   ├── phase-01-cartographer-to-auditors.md
        │   ├── phase-02-auditor-batch-1.md
        │   ├── phase-02-auditor-batch-2.md
        │   ├── phase-03-dedup-to-orch.md
        │   ├── phase-03-tokens-to-orch.md
        │   ├── phase-03-a11y-to-orch.md
        │   └── phase-03-policy-to-orch.md
        └── …
```

## Configuration (`.design-storybook-atomic.yml`)

A repo can override rubric weights, library-policy exemptions, and migration knobs:

```yaml
overrides:
  atoms:
    rtl_required: false
  hygiene:
    deprecated_blocks_pass: false

library_policy:
  allow_alternates_as_primary:
    - zustand                   # we use Zustand as primary, not TanStack Store
  exemptions:
    - dependency: react-hook-form
      reason: "5 forms in /admin/ blocked on TanStack Form's array-field UX"
      sunset: 2026-09-30
      pr: https://github.com/org/repo/pull/1234

migration:
  csf_factories_required: true
  csf3_grandfather:
    - "src/components/atoms/legacy/**"
  exemptions_sunset: 2026-09-30

merge:
  deferred:
    - cluster_id: modal-dialog-popup-2026
      reason: "intentional product variations"

exclude:
  - "src/components/atoms/legacy/**"
```

## Install

```text
/plugin marketplace add Executioner1939/claude-code-skills
/plugin install design-storybook-atomic@skunkworks
```

## License

MIT for original content (Layer 1, Layer 2, Layer 3, Layer 5, slash-command workflows, subagents, and the 5 modern storybook deeper-dive skills). Apache-2.0 for the 7 Han atomic-design methodology references at `skills/han-atomic-design-*/` — license preserved at `skills/_han-license/LICENSE-Apache-2.0`.
