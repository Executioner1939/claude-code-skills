# harness-tuner

A meta-plugin. It does not solve a domain problem -- it tunes the Claude Code harness itself for whatever project you're working in.

Most teams accumulate `CLAUDE.md` files, skills, rules, commands, hooks, and monitors over months without ever stepping back to audit. Skills get ignored. Rules get redundant. Root `CLAUDE.md` files exceed the 200-line ceiling Anthropic recommends and adherence drops. Recurring user friction (the same scope-creep, the same hallucination, the same skipped step) goes uncodified.

This plugin reads your past session transcripts, audits everything currently codified, and proposes targeted additions, edits, and removals. It runs on the user's projects -- it is not project-specific.

## Status

**M1 (this version, 0.1.0):** plugin scaffold + four skills + the `transcript-digester` and `harness-mapper` agents + `/harness-tuner:digest` command. You can run digest against a project's session transcripts and get a structured `digest.md` of recurring patterns, friction, and uncodified workflows.

**M2 (planned):** `/harness-tuner:audit` -- combines digest with a full harness map; identifies gaps (recurring confusion with no rule), bloat (rules over 200 lines, redundancy, ignored entries), misplacement (root content that should be path-scoped), hierarchy issues (missing per-service CLAUDE.md, missing `@` imports, contradictions across the parent chain).

**M3 (planned):** `/harness-tuner:plan` -- per finding, proposes WHERE (always descendant -- never root), HOW (using prompting snippets), WHAT to remove elsewhere, WHEN to use `@` imports. For monorepos: generates per-service summary `CLAUDE.md` proposals that import shared rules.

**M4 (planned):** `/harness-tuner:tune` -- apply an approved plan. Hard rule: never touches root `./CLAUDE.md`. Refuses to push any CLAUDE.md over 200 lines. Appends to `.claude/CHANGELOG.md` describing what changed and why.

## Hard rules (every milestone)

1. **Never edits root `./CLAUDE.md`.** The agent surfaces proposed root-level changes as suggestions in the plan; the user applies them manually if they agree.
2. **200-line ceiling per CLAUDE.md.** Refuses to apply a change that pushes a file over.
3. **Path-scoped over root.** When a rule applies to <50% of the repo, it goes in `.claude/rules/*.md` with `paths:` frontmatter, not in root.
4. **`@` imports for shared content.** When two CLAUDE.md files share a paragraph, factor it to `docs/...` and `@`-import.
5. **CHANGELOG every change.** `.claude/CHANGELOG.md` gets a one-line entry per applied change with rationale.

## Hierarchy intelligence

When invoked from inside a service (e.g., `services/orders/`), `harness-tuner`:

1. Walks the parent chain from cwd up to repo root.
2. Identifies every `CLAUDE.md` it crosses.
3. **Excludes the root** from its write-set; reads it (so it knows what's there) but never edits it.
4. For each non-root parent, evaluates whether content is right for its level. Path-scoped rules in `.claude/rules/` are evaluated against their `paths:` frontmatter.
5. For monorepo cwd cases, proposes a service-level `CLAUDE.md` that states the bounded context, streams, and conventions specific to this service, plus relative `@` imports to shared docs (`@../../docs/conventions/event-versioning.md`).
6. Surfaces the **autoload chain** in `audit.md`: when working in `services/orders/src/domain/`, these files load in this order. Contradictions across this chain are HIERARCHY ISSUE findings.

## Layout

```
harness-tuner/
├── .claude-plugin/plugin.json
├── README.md
├── commands/
│   └── digest.md                   # M1 ships this; audit/plan/tune later
├── agents/
│   ├── transcript-digester.md      # opus-4-7, plan mode; reads ~/.claude/projects/.../*.jsonl
│   └── harness-mapper.md           # read-only; walks the .claude hierarchy
├── skills/
│   ├── harness-anatomy/            # what every Claude Code artefact looks like
│   ├── transcript-mining/          # how to read JSONL transcripts and score patterns
│   ├── claude-md-authoring/        # best-practice CLAUDE.md writing (Anthropic-cited)
│   └── opus-4-7-prompting/         # snippet bank (duplicated from rust-monorepo-orchestrator)
└── (no hooks, no scripts in M1)
```

## Output layout (in your project)

```
<project>/.claude/harness-tuner/
├── digests/<timestamp>/digest.md         # /digest output
├── audits/<timestamp>/audit.md           # /audit output (M2)
├── plans/<timestamp>/plan.md             # /plan output (M3)
└── CHANGELOG.md                          # /tune appends one line per applied change (M4)
```

## Why filesystem (not native Agent Teams)

Same reason as `rust-monorepo-orchestrator`: filesystem outputs are debuggable, auditable, portable, and compose with existing tools. The agent does not use the experimental `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` primitive.

## Install

```
/plugin marketplace add Executioner1939/claude-code-skills
/plugin install harness-tuner@skunkworks
```

## License

MIT.
