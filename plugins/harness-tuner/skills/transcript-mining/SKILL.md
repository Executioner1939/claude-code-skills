---
name: transcript-mining
description: >
  How to read Claude Code session transcripts (JSONL files at
  ~/.claude/projects/<sanitized-cwd>/<session-id>.jsonl), extract
  patterns relevant to harness optimization, score them by recurrence
  and severity, and emit a structured digest. Auto-loaded by the
  transcript-digester agent. Includes anonymization conventions.
---

# Transcript mining

Claude Code persists every session as JSONL. The harness-tuner reads those JSONL files to find recurring user friction that the harness configuration could prevent. This skill is the parsing and scoring methodology.

---

## Where transcripts live

```
~/.claude/projects/<sanitized-cwd>/<session-id>.jsonl
```

`<sanitized-cwd>` is the project's working directory with `/` replaced by `-` (and other path-unsafe chars). To find transcripts for the current project:

```bash
# Sanitize cwd to the harness's encoding
SANITIZED=$(pwd | sed 's|/|-|g')
TRANSCRIPT_DIR="$HOME/.claude/projects/$SANITIZED"

# All sessions for this project, newest first
ls -1t "$TRANSCRIPT_DIR"/*.jsonl 2>/dev/null
```

If the directory doesn't resolve (encoding may have changed across versions), fall back to:

```bash
# Find any project dir that contains "monorepo" (or whatever the project name is)
find ~/.claude/projects -maxdepth 1 -type d -name "*<project-name>*"
```

The `transcript-digester` agent surfaces this as a runtime question if the standard path doesn't resolve. Don't hardcode.

---

## JSONL entry types

Each line is a JSON object. The schema has evolved across versions; the stable fields harness-tuner relies on:

| Field | Type | Meaning |
|---|---|---|
| `type` | string | one of `user`, `assistant`, `system`, `tool_use`, `tool_result` (older versions used `role` instead) |
| `timestamp` | ISO 8601 | when the entry was written |
| `content` | string \| array | the body; for tool entries, it's the tool input or output |
| `tool_name` | string | for `tool_use` / `tool_result` entries |
| `error` | bool | tool errors |
| `session_id` | string | redundant with the filename |

When the version-specific schema confuses parsing, fall back to grep-on-text to find user prompts (`"role": "user"` or `"type": "user"`), tool errors (`"is_error": true` or similar), and tool failures (presence of `"stderr"` followed by `non-zero exit`).

---

## Pattern types to extract

| Pattern | Signal in transcript | What it means for the harness |
|---|---|---|
| **Recurring user prompt** | the same prompt phrasing 3+ times across sessions | a workflow that should be a slash command |
| **Repeated tool failure** | same tool + same error pattern 3+ times | a hook or rule should pre-empt the failure |
| **Scope creep** | user follows up with "no, only do X, not Y" or "scope was..." 2+ times | scope ambiguity in the calling command's envelope; tighten `out_of_scope` |
| **Hallucinated path** | user corrects a fabricated file path | grounding rule (`investigate_before_answering`) is missing or ignored |
| **Skipped step** | "you forgot to..." follow-ups | the workflow's `acceptance` criteria are too loose |
| **Wrong tool** | user invokes a command and explains it should have used a different one | command dispatch routing issue |
| **Context bloat** | session goes off the rails after long context with many tool results | compaction or just-in-time retrieval rules missing |
| **Manual correction** | user edits Claude's output and pastes the diff back | output style / verification gate not codified |
| **Slash command misuse** | user invokes a slash command, then immediately undoes or supplements its output | command's prompt is unclear or its envelope is leaky |
| **Subagent miscoordination** | "the agent didn't write the handoff" type failures | HANDOFF.md contract not enforced |

---

## Scoring

Each finding gets a numeric score so the digest can rank them.

```
score = recurrence * severity * recency
```

| Factor | Weight |
|---|---|
| `recurrence` | count of independent occurrences (clamp at 10) |
| `severity` | `BLOCKING=4, NEEDS-WORK=2, NIT=1` |
| `recency` | `1.0` for last 7 days, `0.7` for last 30 days, `0.4` older |

Sort findings by score descending in the digest.

---

## Anonymization conventions

Transcripts may contain absolute paths, environment values, hostnames, or accidental secret-like strings. Before writing anything to a digest:

1. Replace `/Users/<name>/`, `/home/<name>/`, `C:\Users\<name>\` with `~/`.
2. Replace any token matching common secret patterns (`AKIA[A-Z0-9]{16}`, `ghp_[a-zA-Z0-9]{36}`, `sk-[a-zA-Z0-9]{20,}`, etc.) with `[REDACTED]`.
3. Replace IPv4 addresses outside RFC1918 with `[IP]`.
4. Replace email addresses with `[EMAIL]`.

The digest is a markdown file the user reads and possibly commits. Treat it as such.

---

## Digest output structure

The transcript-digester writes `digest.md` with sections:

```markdown
# Transcript digest

> Project: <repo-relative cwd>
> Sessions analyzed: <count>
> Date range: <earliest> -- <latest>
> Generated at: <ISO 8601>

## 1. Top friction (sorted by score)

For each finding (top 20):

### F-NN: <one-line title> [score: <n>]
- Pattern: <pattern type>
- Recurrence: <n> across <m> sessions
- Severity: BLOCKING | NEEDS-WORK | NIT
- Most-recent occurrence: <ISO 8601>
- Excerpts:
  - turn <n> ("<file>" session): "<verbatim, anonymized>"
  - turn <n> ("<file>" session): "<verbatim, anonymized>"
- Currently codified: yes (link to skill/rule/command) | no
- Hypothesized cause: <one sentence>
- Candidate remediation: <one sentence; the audit phase decides>

## 2. Recurring user prompts (workflow candidates)

User prompts that recurred 3+ times across sessions; candidates for new
slash commands.

| Prompt fragment | Recurrence | Currently a command? |
|---|---|---|
| "audit my domain..." | 5 | no -- candidate /audit |
| "write tests for..." | 8 | no |

## 3. Tool failures (hook candidates)

Repeated tool failures that a PreToolUse or PostToolUse hook could
prevent or recover from.

## 4. Skill / rule candidates

Knowledge bodies that recurred and could be codified as skills or path-scoped rules.

## 5. Bloat signals

Existing artefacts that did NOT show up in the transcripts (probably ignored or not autoloading correctly).

## 6. Anonymization summary

Number of paths / tokens / IPs / emails redacted. So the user knows what was scrubbed.
```

---

## Implementation notes

- Use Bash + jq + sed to extract turn-by-turn rather than loading whole files into context. Some session JSONLs are huge.
- For multi-session aggregation, jq has `inputs` for streaming over multiple files: `jq -s '...' *.jsonl` (slurp) or `jq '...' < (cat *.jsonl)` (stream).
- Anonymize at extraction time. Don't store unredacted text anywhere.
- Cap the digest at 20 top-scoring findings unless user passes `--full`.

---

## When to use this skill

Auto-loaded by `transcript-digester`. Reference for any agent that needs to read or interpret session transcripts.
