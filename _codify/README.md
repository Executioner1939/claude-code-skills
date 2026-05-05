# `/codify` — source-of-truth (not a published plugin)

This directory holds the `/codify` slash command, its five subagents, its report template, and its Stop-hook script. The files here are mirrors of the user-scope install at `~/.claude/`. **It is intentionally NOT registered in `marketplace.json`** — `/codify` is a personal maintenance tool that hardcodes paths to this user's marketplace and to local plugin caches; it is not portable.

The repo copy exists for version control, review, and bootstrap to a fresh machine. The user-scope copy under `~/.claude/` is the live one.

## What `/codify` does

Reads the current Claude Code session transcript, scans this marketplace for plugins / agents / skills, dispatches a transcript-analyzer subagent to extract findings (new skills, existing-skill changes, plugin / subagent / slash-command breakdowns, and at most one envelope proposal per session), then dispatches one of four implementer subagents per finding to produce a remediation report under `<repo>/.codify-inbox/<timestamp>/`. A Stop hook then runs each report as a background `claude --bare -p` invocation that performs the actual implementation. The envelope-proposal report runs first (wave 1) and `exec`-chains into the rest (wave 2) so breakdown remediations can adopt any new envelope shape.

The companion research dossier — including the v0.1 message-passing envelope schema — lives at `<repo>/.codify-inbox/_research.md`.

## Layout

```
_codify/
├── README.md                              # this file
├── commands/
│   └── codify.md                          # → ~/.claude/commands/codify.md
├── agents/
│   ├── transcript-analyzer.md             # → ~/.claude/agents/transcript-analyzer.md
│   ├── envelope-proposer.md               # → ~/.claude/agents/envelope-proposer.md
│   ├── skill-author.md                    # → ~/.claude/agents/skill-author.md
│   ├── skill-auditor.md                   # → ~/.claude/agents/skill-auditor.md
│   └── breakdown-analyzer.md              # → ~/.claude/agents/breakdown-analyzer.md
├── templates/
│   └── codify-report.md                   # → ~/.claude/templates/codify-report.md
└── hooks/
    └── codify-stop.sh                     # → ~/.claude/codify/codify-stop.sh (chmod +x)
```

## Hardcoded assumptions

`/codify` is not portable as-shipped. The slash command body assumes:

- Marketplace lives at `/Users/skunkworks/Documents/Work/Personal/claude-code-skills`
- `plugin-dev@claude-plugins-official` is installed at `~/.claude/plugins/cache/claude-plugins-official/plugin-dev/`
- `skill-creator@claude-plugins-official` is installed at `~/.claude/plugins/cache/claude-plugins-official/skill-creator/`
- Sessions are at `~/.claude/projects/<encoded-cwd>/<session-id>.jsonl` (encoding rule: `/` → `-` over the absolute cwd; the command falls back to a glob if the encoded path doesn't resolve)

If any of those paths change, edit `commands/codify.md` and re-sync to user scope.

## Reinstalling from this directory to user scope

On a fresh machine, after cloning the repo and confirming the assumptions above hold:

```bash
mkdir -p ~/.claude/{commands,agents,templates,codify}

cp _codify/commands/codify.md            ~/.claude/commands/
cp _codify/agents/*.md                   ~/.claude/agents/
cp _codify/templates/codify-report.md    ~/.claude/templates/
cp _codify/hooks/codify-stop.sh          ~/.claude/codify/
chmod +x ~/.claude/codify/codify-stop.sh

# Install Anthropic plugin dependencies (in Claude Code):
#   /plugin install plugin-dev@claude-plugins-official
#   /plugin install skill-creator@claude-plugins-official
```

Then merge this hook into `~/.claude/settings.json` (preserving every existing key):

```json
"hooks": {
  "Stop": [
    {
      "hooks": [
        {
          "type": "command",
          "command": "bash $HOME/.claude/codify/codify-stop.sh",
          "async": true,
          "timeout": 30
        }
      ]
    }
  ]
}
```

Verify with `jq '.hooks.Stop' ~/.claude/settings.json` and `bash -n ~/.claude/codify/codify-stop.sh`.

## Editing workflow

The user-scope copy at `~/.claude/` is the live one. Edit there first (so the next `/codify` run picks the change up), then sync back into this directory before committing:

```bash
cp ~/.claude/commands/codify.md         _codify/commands/
cp ~/.claude/agents/{transcript-analyzer,envelope-proposer,skill-author,skill-auditor,breakdown-analyzer}.md  _codify/agents/
cp ~/.claude/templates/codify-report.md _codify/templates/
cp ~/.claude/codify/codify-stop.sh      _codify/hooks/
```

## Why `_codify/` not `plugins/codify/`

`/codify` is a slash command at user scope, not a marketplace plugin. Wrapping it as a plugin would mean:

1. Removing the hardcoded marketplace path (would have to scan instead) — possible but reduces reliability for the only user who runs it.
2. Removing the hardcoded plugin-cache paths (would have to discover) — same.
3. Restructuring the Stop hook to live in `<plugin>/hooks/hooks.json` — but the hook needs to read state from `~/.claude/codify/.codify-active-<session>` regardless, so plugin-scoping it doesn't help.
4. Namespacing the slash command as `/codify:codify` or similar — worse UX than the bare `/codify` user-scope form.

The underscore prefix matches the convention already used inside `plugins/anvil/skills/_handoff/`, `_han-license/`, `_migration/` — "asset-like, not part of the published surface."

## Runtime artifacts (not committed)

`/codify` produces transient state at:
- `<repo>/.codify-inbox/<timestamp>/` — staging area for reports + the dependency map + the findings JSON
- `~/.claude/codify-runs/<timestamp>/` — background-run logs (outside the repo)
- `~/.claude/codify/.codify-active-<session-id>` — sentinel file the Stop hook reads then deletes

`.codify-inbox/` is **not** in `.gitignore` yet — see the recommendation in the most recent commit message.
