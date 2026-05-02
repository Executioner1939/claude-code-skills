# design-storybook-atomic

> Atomic design + Storybook 9/10 expert toolkit for Claude Code.

A complete plugin for working on a design system: **atomic design** (Brad Frost), **Storybook 9 / 10** (CSF Factories, autodocs, addon-vitest, addon-a11y, addon-docs/blocks), **design tokens** (W3C-DTCG, Style Dictionary, Tokens Studio), composition patterns, and accessibility (WCAG 2.2 AA, WAI-ARIA APG) — wired together with **specialized subagents** and **slash-command workflows** for auditing, deduplicating, and composing components.

## What's inside

### Layer 1 — Integrated knowledge skills (7)

These auto-load when you're working on relevant files. They reflect **modern Storybook 9 / 10** conventions (CSF Factories, `@storybook/addon-vitest`, `@storybook/addon-docs/blocks`, framework-specific packages like `@storybook/react-vite`).

| Skill | Auto-loads on |
|---|---|
| `atomic-design` | atoms / molecules / organisms / templates / pages |
| `storybook-authoring` | `*.stories.*`, `*.mdx`, `.storybook/**` |
| `storybook-atomic-integration` | story files in atomic-design folders |
| `design-tokens` | `tokens.json`, Style Dictionary, Tailwind config, theme files |
| `component-composition` | components with slot / compound / polymorphic patterns |
| `accessibility-stories` | a11y configuration, story a11y patterns |
| `story-coverage-checklist` | the rubric for "complete" Storybook coverage per atomic level |

### Layer 2 — Han-derived deeper-dive skills (12)

Adapted from the [`han`](https://github.com/TheBushidoCollective/han) plugin marketplace by **The Bushido Collective**, **Apache-2.0**. Each skill ships with attribution and the upstream LICENSE preserved at `skills/_han-license/`.

These complement Layer 1 — they go **deeper per atomic level** (one focused skill per level) and **per Storybook concern** (one per story file kind).

| Atomic-design level skills | Storybook-concern skills |
|---|---|
| `han-atomic-design-fundamentals` | `han-storybook-story-writing` |
| `han-atomic-design-quarks` | `han-storybook-args-controls` |
| `han-atomic-design-atoms` | `han-storybook-component-documentation` |
| `han-atomic-design-molecules` | `han-storybook-play-functions` |
| `han-atomic-design-organisms` | `han-storybook-configuration` |
| `han-atomic-design-templates` | |
| `han-atomic-design-implementation` | |

> The Han skills target **Storybook 7 / 8** conventions. For Storybook 9 / 10 (CSF Factories, addon-vitest, addon-docs/blocks), Layer 1's `storybook-authoring` skill is the modern reference. Cross-references are noted in each Han skill's attribution block.

### Layer 3 — Slash-command workflows (7)

Skill-commands with `disable-model-invocation: true` — they fire only when you invoke them explicitly.

| Command | What it does |
|---|---|
| `/design-storybook-atomic:audit-atomic` | Systematically audit every atom for story coverage, uniqueness, token compliance, a11y. Produces a graded report. |
| `/design-storybook-atomic:audit-molecules` | Same audit, scoped to molecules. Adds composition checks (no atom-imports-atom, no domain-state leaks, required `play` stories). |
| `/design-storybook-atomic:audit-organisms` | Same audit, scoped to organisms. Adds mandatory `Empty`/`Loading`/`Error` coverage, data-contract docs, no-routing-coupling. |
| `/design-storybook-atomic:audit-tokens` | Find hardcoded values, audit token taxonomy, propose token refactors. |
| `/design-storybook-atomic:add-component` | Interactive new-component flow. Asks for spec, screenshots, design URL. Inventories existing components. Decides reuse / extend / compose / build-new. Composes via subagents. Writes stories + MDX. |
| `/design-storybook-atomic:merge-duplicates` | Find near-duplicates. Score similarity. Propose canonical version. Plan migration. |
| `/design-storybook-atomic:coverage-report` | Full design-system coverage matrix as Markdown (and optional HTML). |

### Layer 4 — Specialized subagents (10)

Each agent has tight scope, constrained tools, and **preloads the right knowledge skills** via the `skills:` frontmatter field (Storybook 9/10's auto-loading mechanism for subagents).

| Agent | Purpose |
|---|---|
| `component-cartographer` | Read-only inventory of every component in the codebase, classified by atomic level. |
| `atomic-auditor` | Grade a single component (or batch at one level) against `story-coverage-checklist`. |
| `ui-spec-interpreter` | Turn briefs / screenshots / design URLs into structured component specs. |
| `component-composer` | Decide reuse / extend / compose / build-new; assemble; merge. |
| `story-writer` | Write CSF Factories or CSF3 stories matching the project's existing format. |
| `mdx-doc-writer` | Write the Docs MDX page following the level-specific template. |
| `design-token-enforcer` | Audit tokens; scan for hardcoded values; refactor exact-match hits to tokens. |
| `accessibility-reviewer` | Run WCAG 2.2 AA + WAI-ARIA APG manual checks; produce defect list with fixes. |
| `component-deduplicator` | Find near-duplicate clusters; propose canonical + migration plan. |
| `storybook-coverage-analyst` | Compute the coverage matrix (component × story-type) and grade each cell. |

## How it composes

```
USER: /design-storybook-atomic:audit-atomic
  │
  ▼
[skill-command body — orchestration only]
  │
  ├─→ Agent(component-cartographer)
  │     ├─ preloads skill: atomic-design
  │     ├─ preloads skill: storybook-atomic-integration
  │     └─ preloads skill: component-composition
  │
  ├─→ Agent(atomic-auditor) × atoms (in parallel, batched)
  │     ├─ preloads skill: atomic-design
  │     ├─ preloads skill: storybook-authoring
  │     ├─ preloads skill: storybook-atomic-integration
  │     ├─ preloads skill: story-coverage-checklist
  │     ├─ preloads skill: design-tokens
  │     └─ preloads skill: accessibility-stories
  │
  ├─→ Agent(component-deduplicator)        ← finds duplicate atoms
  ├─→ Agent(design-token-enforcer)         ← scans for hardcoded values
  └─→ Agent(accessibility-reviewer)        ← WCAG manual-check pass
        │
        ▼
   structured audit report (graded per atom; consolidated)
```

The subagent `skills:` field is the key idiom: each agent gets exactly the reference material it needs preloaded into context, no more.

## Storybook version coverage

- **Storybook 10 (current major)**: CSF Factories (`preview.meta` / `meta.story`), `defineMain` / `definePreview`, `@storybook/addon-vitest`, `@storybook/addon-docs/blocks`, `composeStories` from framework packages.
- **Storybook 9**: CSF Factories (React), `@storybook/addon-vitest` (graduated from experimental), framework-specific packages.
- **Storybook 7 / 8**: CSF3 object syntax fully supported; legacy `@storybook/blocks` / `@storybook/experimental-addon-test` paths covered as migration cheatsheet.

The Han-derived skills (Layer 2) reflect Storybook 7 / 8 idioms; Layer 1 modernizes them. Use both — Layer 1 for the canonical "how it should look in 2026", Layer 2 for the depth-per-level deep dives.

## Install

Once this plugin is in the marketplace:

```text
/plugin marketplace add Executioner1939/claude-code-skills
/plugin install design-storybook-atomic@skunkworks
```

## Usage notes

- All **knowledge skills auto-load** when you open relevant files (per each skill's `paths` field).
- All **slash commands print their plan and ask for confirmation** before mutating code.
- **Subagents are read-only by default.** Edits happen only in `component-composer`, `design-token-enforcer`, `story-writer`, and `mdx-doc-writer`, and only after a human-approved plan.
- **Memory**: every audit / inventory / merge run appends a one-liner to `.claude/agent-memory/<agent>/activity.log`. Subsequent runs can compare deltas.

## Configuration overrides

A repo can override the rubric weights / required-stories table by adding a `.storybook-atomic.yml`:

```yaml
overrides:
  atoms:
    rtl_required: false
  hygiene:
    deprecated_blocks_pass: false
exclude:
  - "src/components/atoms/legacy/**"
```

Audit workflows surface the override summary at the top of every report so grades are reproducible.

## Attribution

This plugin includes content adapted from:

- **[`han`](https://github.com/TheBushidoCollective/han)** by The Bushido Collective — Apache-2.0. Specifically the 12 Han-derived skills under `skills/han-*/`. The full Apache-2.0 license text is preserved at `skills/_han-license/LICENSE-Apache-2.0`.

The integrated skills, workflow commands, and subagents are MIT, by `Executioner1939`.

## License

MIT for original content; Apache-2.0 for the Han-derived `skills/han-*/` directories. See LICENSE files.
