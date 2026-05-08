---
description: Resurrect a dead-lettered ticket back to inbox/pending/ with optional human note appended to the ticket's objective. Resets attempts to 0 (the user is taking responsibility for the next attempt). Invoke as `/rust-monorepo-orchestrator:replay <ticket-id> [--note='<text>'] [--scope=<path>]`.
argument-hint: "<ticket-id> [--note='<text>'] [--scope=<path>]"
disable-model-invocation: true
allowed-tools:
  - Read
  - Glob
  - Bash(mkdir:*)
  - Bash(mv:*)
  - Bash(cp:*)
  - Bash(date:*)
  - Bash(pwd)
  - Bash(test:*)
  - Bash(echo:*)
  - Bash(find:*)
  - Bash(awk:*)
  - Bash(sed:*)
  - Bash(grep:*)
  - Bash(cut:*)
  - Bash(realpath:*)
  - Bash(cat:*)
  - Edit
  - Write
model: claude-sonnet-4-6
---

# /rust-monorepo-orchestrator:replay

Resurrect a dead-lettered ticket. The user is taking responsibility for the next attempt -- attempts is reset to 0 and an optional `--note` is appended to the objective so the next worker has the new context.

This is a quick command: no subagent dispatch.

## Step 0 -- Resolve arguments

```!
set -e
ARGS=$(printf '%s' "$ARGUMENTS")

TICKET_ID=$(printf '%s' "$ARGS" | awk '{ for (i=1;i<=NF;i++) if ($i !~ /^--/) { print $i; exit } }')
test -n "$TICKET_ID" || { echo "ABORT: ticket id is required. Usage: /rust-monorepo-orchestrator:replay <ticket-id> [--note='...'] [--scope=<path>]"; exit 0; }

# --note may contain spaces and is single-quoted.
NOTE=$(printf '%s' "$ARGS" | sed -n "s|.*--note='\\([^']*\\)'.*|\\1|p")
[ -z "$NOTE" ] && NOTE=$(printf '%s' "$ARGS" | sed -n 's|.*--note=\([^ ]*\).*|\1|p')

SCOPE=$(printf '%s' "$ARGS" | grep -oE -- '--scope=[^ ]+' | cut -d= -f2 || true)
[ -z "${SCOPE:-}" ] && SCOPE="$(pwd)"
test -d "$SCOPE" || { echo "ABORT: scope $SCOPE is not a directory"; exit 0; }
SCOPE=$(cd "$SCOPE" && pwd)

DL_PATH="$SCOPE/.refactor/dead-letter/$TICKET_ID.md"
test -f "$DL_PATH" || { echo "ABORT: $DL_PATH does not exist. Check /status for dead-lettered tickets."; exit 0; }

# Read the ticket's domain from frontmatter.
DOMAIN=$(awk -F': ' '/^domain:/{print $2; exit}' "$DL_PATH" | tr -d '"')
test -n "$DOMAIN" || { echo "ABORT: could not read domain from $DL_PATH"; exit 0; }

INBOX_PENDING="$SCOPE/.refactor/inbox/$DOMAIN/pending"
test -d "$INBOX_PENDING" || mkdir -p "$INBOX_PENDING"

DEST="$INBOX_PENDING/$TICKET_ID.md"
test ! -f "$DEST" || { echo "ABORT: $DEST already exists. Resolve or move it before replaying."; exit 0; }

NOW=$(date -u +%Y-%m-%dT%H:%M:%SZ)

cat <<EOF
BOOTSTRAP_OK=1
TICKET_ID=$TICKET_ID
DOMAIN=$DOMAIN
DL_PATH=$DL_PATH
DEST=$DEST
NOTE=${NOTE:-(none)}
NOW=$NOW
EOF
```

If bootstrap aborts, halt.

## Step 1 -- Reset frontmatter and append note

Read the dead-letter ticket. Use the Edit / Write tools to:

1. Rewrite frontmatter:
   - `status: pending`
   - `claimed_by: null`
   - `claimed_at: null`
   - `attempts: 0`
2. Append a note section at the end of the ticket body:

```markdown
---

## Replay note (<NOW>)

The user resurrected this ticket from dead-letter. Previous attempts failed
the verifier <attempts-original> times. The user has appended:

> <NOTE if provided, else "(no note)">

Treat this as new context for the next attempt. Re-read the original
objective and apply the note as guidance.
```

3. Move the file: `mv <DL_PATH> <DEST>`.

(Use the Write tool to write the modified content directly to `<DEST>`, then `rm <DL_PATH>`.)

## Step 2 -- Refresh registry

```!
bash "${CLAUDE_PLUGIN_ROOT}/scripts/registry-refresh.sh" "$SCOPE/.refactor/inbox/$DOMAIN"
```

## Step 3 -- Print summary

```
==========================================
  /rust-monorepo-orchestrator:replay complete
==========================================
  ticket:      <TICKET_ID>
  domain:      <DOMAIN>
  moved:       <DL_PATH>
            -> <DEST>
  attempts:    reset to 0
  note:        <NOTE or "(none)">

  next steps:
    1. Optionally edit <DEST> to refine the objective.
    2. Run /rust-monorepo-orchestrator:run-wave <DOMAIN> to dispatch.
==========================================
```

## Whole-workflow constraints

- Single ticket per invocation.
- Refuses if the ticket is not in dead-letter/.
- Refuses if a same-id ticket already exists in pending/.
- Resets `attempts: 0`. The user takes responsibility for the next attempt.
- Read-only on the source tree. Writes only to `.refactor/inbox/<domain>/pending/` and removes from `.refactor/dead-letter/`.
