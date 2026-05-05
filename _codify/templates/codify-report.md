# <Title>

One sentence: the outcome a background `claude -p` run will produce when it processes this report.

## Type

One of: `new_skill` | `existing_skill_change` | `plugin_breakdown` | `subagent_breakdown` | `slash_command_breakdown` | `envelope_proposal`

## Evidence

Verbatim transcript excerpts that justify this report. Format each excerpt as:

```
turn <N> [user|assistant|tool_result]:
<excerpt>
```

For breakdown reports, include at least one transcript excerpt AND at least one definition file path (slash command body, agent system prompt, skill SKILL.md) showing the orchestration as it currently stands.

## Goal

The outcome the implementation must achieve, stated as one sentence in present tense (no activity verbs like "look at", "investigate", "explore"). The implementer's `acceptance` test must check that this goal was met.

## Files to create or change

Per file: absolute path (or `<repo>/...`-rooted path), and a one-line description of what changes there. Group by `(create)` and `(modify)`. No globs — list real paths.

```
(create) /Users/skunkworks/Documents/Work/Personal/claude-code-skills/plugins/<plugin>/commands/<name>.md
  — slash-command workflow that <does X>

(modify) /Users/skunkworks/Documents/Work/Personal/claude-code-skills/plugins/<plugin>/agents/<agent>.md
  — tighten Inputs section to declare envelope fields it consumes
```

## Implementation steps

Numbered, ordered list. Each step is a single change a `claude -p` background run can execute. Reference the file paths from the previous section. Do not skip steps; do not lump multiple changes into one bullet.

```
1. <action>
2. <action>
3. ...
```

## Acceptance criteria

A checklist the background run validates after the implementation completes. Each item is a verifiable predicate: contains/equals/matches/exists. The run halts and reports failure if any check fails.

```
- [ ] <predicate>
- [ ] <predicate>
- [ ] ...
```

## Out of scope

Anti-goals — what the implementation must NOT do. The run aborts if it tries.

```
- <forbidden>
- <forbidden>
```
