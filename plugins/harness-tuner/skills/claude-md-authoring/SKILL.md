---
name: claude-md-authoring
description: >
  Best-practice authoring of CLAUDE.md and .claude/rules/*.md, sourced
  from Anthropic's official docs. The 200-line ceiling, the hierarchy
  loading order, path-scoped rules, @ imports, include / exclude lists,
  positive framing, style mirroring, the "would removing this cause
  Claude to make mistakes?" litmus. Auto-loaded by every agent in
  harness-tuner that authors or proposes changes to CLAUDE.md content.
---

# CLAUDE.md authoring

The plugin's writing discipline. Every proposed change traces back to one of the rules here.

Sources cited inline. Primary: <https://code.claude.com/docs/en/memory>, <https://code.claude.com/docs/en/best-practices>.

---

## The 200-line ceiling (binding)

> Target under 200 lines per CLAUDE.md file. Longer files consume more context and reduce adherence.

The harness-tuner's `harness-applier` agent **refuses** to apply a change that pushes any CLAUDE.md over 200 lines.

If a file is at 195 lines and a change is genuinely needed, the agent first proposes a split: extract a section into `.claude/rules/<topic>.md` with a `paths:` filter, leaving room.

---

## The line litmus (verbatim)

> For each line, ask: 'Would removing this cause Claude to make mistakes?' If not, cut it. Bloated CLAUDE.md files cause Claude to ignore your actual instructions.

Apply this on every audit. Claims that don't pass the litmus go on the cut list.

---

## Hierarchy loading order

Files load filesystem-root-down to cwd, with `CLAUDE.local.md` appended after `CLAUDE.md`. Practical order for `monorepo/services/orders/src/domain/`:

1. `~/.claude/CLAUDE.md`
2. `monorepo/CLAUDE.md`
3. `monorepo/CLAUDE.local.md`
4. `monorepo/services/orders/CLAUDE.md`
5. `monorepo/services/orders/src/CLAUDE.md`
6. `monorepo/services/orders/src/domain/CLAUDE.md`
7. Path-scoped rules in `.claude/rules/*.md` whose `paths:` matches.

Two implications:

- **A rule placed at level N is invisible to sessions opened at a sibling**. Useful for service-local invariants; harmful for cross-service rules wrongly placed.
- **Lower-level rules can reinforce or refine, but not contradict, higher-level rules.** Contradictions are HIERARCHY ISSUE findings.

---

## Path-scoped rules (the highest-leverage tool)

Files at `.claude/rules/<name>.md` with frontmatter `paths:` only enter context when Claude touches a matching file. They cost zero against the root's 200-line budget.

```markdown
---
paths:
  - "**/domain/**/*.rs"
  - "**/application/**/*.rs"
---

# Rules for domain and application layers

- No async fn here.
- Return Result<_, DomainError>.
- No unwrap() / expect().
```

**Use when**: a rule applies to a clearly-bounded slice of the repo.

**Don't use when**: a rule is truly repo-wide (it goes in root CLAUDE.md instead).

---

## `@` imports

`@<path>` at the start of a line in a CLAUDE.md imports that file's content at session-launch time.

- Resolved **relative to the file containing the `@`**, not cwd.
- Loaded **at session start**, so they DO consume the global context budget.
- Use for content that should always load alongside this CLAUDE.md, not for content that should sometimes load (use path-scoped rules for that).

Good use: `services/orders/CLAUDE.md` imports a shared event-versioning doc:

```markdown
@../../docs/conventions/event-versioning.md
```

Bad use: importing a 5000-line API reference into root CLAUDE.md. Use a skill with `references/` for that.

---

## Include / exclude lists (verbatim from Anthropic best-practices)

> **Include**:
> - Build commands, test commands, lint commands the AI should run
> - Code style and formatting conventions
> - Project-specific terminology and naming conventions
> - Architecture decisions and constraints
> - Common gotchas and edge cases
> - URLs to important documentation
> - Environment setup that's not in standard tools

> **Exclude**:
> - Anything Claude can figure out by reading code
> - Standard language conventions Claude already knows
> - Detailed API documentation (link to docs instead)
> - Information that changes frequently
> - Long explanations or tutorials
> - File-by-file descriptions of the codebase
> - Self-evident practices like "write clean code"

The audit applies these lists verbatim.

---

## Positive framing (verbatim rule)

> Tell Claude what to do, not what not to do.

Replace prohibitions with directives. The audit phase flags every "Do not X" line as a candidate for rewrite to "Y instead" form.

| Don't write | Do write |
|---|---|
| "Do not use markdown in your response" | "Respond in flowing prose paragraphs." |
| "Don't add docstrings" | "Keep code commentless unless logic is non-obvious." |
| "Don't read whole files" | "Use grep first, then Read with line ranges." |

---

## Style mirroring

> The formatting style used in your prompt may influence Claude's response style.

If you want structured markdown back, write the CLAUDE.md as structured markdown. If you want prose, write prose.

The harness-tuner uses structured markdown with tables because the audit / plan output is machine-parsed.

---

## Length thresholds (operational defaults the agent uses)

| File | Soft limit | Hard ceiling | Action when over |
|---|---|---|---|
| Root CLAUDE.md | 100 lines | 200 lines | propose split into path-scoped rules |
| Subdirectory CLAUDE.md | 80 lines | 200 lines | same |
| Path-scoped rule | 60 lines | 150 lines | propose factoring into multiple rules |
| `@` imports per file | 3 | 5 | over budget; convert to skill |

The harness-applier refuses on any hard ceiling violation.

---

## Per-service CLAUDE.md template (monorepo)

For a service in a hexagonal Rust monorepo, a good service-level `CLAUDE.md` looks like:

```markdown
# Service: <name>

## Bounded context
One paragraph: what business capability this service owns.

## KurrentDB streams owned
- <bounded_context>-<aggregate>-<id> -- written by this service only.

## Integration events emitted
- <event> on <topic> -- consumers: <list>.

## Adapters in use
- HTTP: axum router under api/.
- Persistence: sqlx postgres for read models in infrastructure/projections/.
- Event store: kurrentdb client wrapped in infrastructure/event_store/.
- Pub/sub: <broker>.

## Service-local invariants (additive to root)
- <thing>

## Imports
@../../docs/conventions/event-versioning.md
@../../docs/conventions/stream-naming.md
```

Target: 30-60 lines. The root CLAUDE.md owns architecture invariants; the service-level file owns service-specific facts.

---

## When to use this skill

Auto-loaded by `harness-mapper` (audit) and any future plan / apply agent. Reference for every proposal that adds, edits, or removes CLAUDE.md or `.claude/rules/*.md` content.

---

## Hard rule (every agent in this plugin)

**Never propose edits to the root `./CLAUDE.md` as something to APPLY.** Surface them as suggestions in the plan for the user to apply manually if they agree. The plugin's write-set is descendant `CLAUDE.md` files, `.claude/rules/`, and (where appropriate) `.claude/skills/`, `.claude/agents/`, `.claude/commands/`, `.claude/hooks/`.
