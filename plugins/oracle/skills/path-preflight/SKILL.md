---
name: path-preflight
description: 'This skill should be used whenever Claude is about to Read a file path, run a Bash command against a path, WebFetch a URL, or otherwise reference a file or URL that did NOT originate from a prior tool result in the current session. Triggers on situations like reading a path the user mentioned in passing, reading a path the agent inferred from a project convention, fetching a docs URL that the agent guessed by pattern, opening a config file the agent assumes exists. Transcript-corpus evidence shows ~300 preventable errors per ten newest sessions from File-does-not-exist plus HTTP-404 plus HTTP-403 events caused by speculative paths and URLs. This skill encodes the list-before-read discipline so the next path access is grounded in evidence rather than guesswork.'
---

# Path and URL pre-flight

Before Read, WebFetch, or any Bash command that consumes a path or
URL the agent has not seen surface in a prior tool result, confirm
the path exists. The cost of one extra `ls`, `find`, `Glob`, or site
map is trivial; the cost of a Read against a nonexistent file is a
wasted round-trip and a polluted context window.

## When to pre-flight

Pre-flight whenever the path or URL has not already appeared in:

- A prior tool result in this session.
- The user's most recent message.
- An explicit file the user pinned.

If the agent is constructing the path from a convention ("the config
should be at `<repo>/config/app.toml`"), assume nothing. Run a `Glob`,
`find`, or `ls` first. Surface results in one place, then act.

## Pre-flight tools, by surface

| You're about to                | Pre-flight with                          |
|--------------------------------|------------------------------------------|
| `Read /path/file`              | `ls /path/file` (or `Glob "/path/**"`)   |
| `Read <directory>`             | `ls <directory>` first                   |
| `Bash cat /path`               | Same as Read pre-flight                  |
| `WebFetch https://...`         | `firecrawl-map` or a site search first   |
| `Bash gh repo view owner/repo` | `gh search repos owner/repo` first       |
| `Bash cargo run --bin <name>`  | `cargo run --bin 2>&1` to list bins      |

## When NOT to pre-flight

- The user explicitly typed the path in this turn.
- A prior tool result in this session emitted the path.
- You're creating a new file (Write to a nonexistent path is correct).
- The pre-flight tool would be more expensive than the target call.

## Why this matters

The transcript-corpus evidence on this machine across 1,186 sessions
shows ~300 events per recent-ten sessions of:

- `File does not exist. Note: your current working directory is ...`
- `Request failed with status code 404`
- `Request failed with status code 403`

Almost all of these are caused by guessing the path before listing.
Pre-flighting is a 1-second cost that prevents a 10-second round-trip
plus a context-pollution event.

## Parallel pre-flight

Pre-flight calls are independent and should be batched. If you're
about to Read five files, dispatch all five `ls` checks (or one
`Glob`) in a single tool batch before deciding which Reads to issue.
See `parallel-tools` for the dispatch discipline.

## Edge case: the path exists but is wrong

A successful `ls` confirms the path exists; it does NOT confirm the
file's content matches the agent's assumption. Treat pre-flight as
existence-grounding only, not as content-grounding. The Read tool
remains the authority on what's inside.
