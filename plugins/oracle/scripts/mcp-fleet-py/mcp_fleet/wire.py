"""Wire rendered servers into Claude Code.

`claude mcp add`'s `-e/--env` flag is variadic in commander.js, which makes
repeated `-e KEY=VAL -e KEY=VAL` collapse the second value onto the first
flag and then misparse the positional server name. We sidestep the CLI
entirely and write the mcpServers block directly into ~/.claude.json,
which is the same file `claude mcp add` mutates anyway.

Safety:
  - Atomic write via temp file + os.replace.
  - One-off backup at ~/.claude.json.mcp-fleet-backup-<timestamp> before
    the first write of a session.
  - Only the mcpServers key is touched; every other top-level field is
    preserved verbatim.
  - Our entries override same-name existing entries; foreign entries
    (e.g. chakra-ui, claude.ai-managed) are left alone.
"""

from __future__ import annotations

import json
import os
import shutil
import subprocess
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from typing import Any

from . import matrix


CLAUDE_JSON = Path.home() / ".claude.json"


@dataclass
class WireResult:
    server: str
    ok: bool
    message: str


def claude_available() -> bool:
    return shutil.which("claude") is not None and CLAUDE_JSON.exists()


def list_existing() -> set[str]:
    """Return server names currently registered in ~/.claude.json."""
    if not CLAUDE_JSON.exists():
        return set()
    try:
        data = json.loads(CLAUDE_JSON.read_text())
    except Exception:
        return set()
    return set((data.get("mcpServers") or {}).keys())


def _backup_path() -> Path:
    ts = datetime.now().strftime("%Y%m%d-%H%M%S")
    return CLAUDE_JSON.with_name(f".claude.json.mcp-fleet-backup-{ts}")


def wire_all() -> list[WireResult]:
    if not CLAUDE_JSON.exists():
        return [WireResult("(all)", False, f"{CLAUDE_JSON} not found; is Claude Code installed?")]

    # Read current.
    try:
        data = json.loads(CLAUDE_JSON.read_text())
    except Exception as e:
        return [WireResult("(all)", False, f"could not read {CLAUDE_JSON}: {e}")]

    # Render the new matrix.
    body = matrix.render()
    new_servers: dict[str, Any] = body.get("mcpServers", {}) or {}
    if not new_servers:
        return [WireResult("(all)", False, "no workspaces to wire")]

    existing: dict[str, Any] = dict(data.get("mcpServers") or {})

    # Backup once per call.
    try:
        backup = _backup_path()
        backup.write_text(CLAUDE_JSON.read_text())
    except Exception as e:
        return [WireResult("(backup)", False, f"backup failed, aborting: {e}")]

    # Merge: new overwrites same-name, foreign entries preserved.
    merged = dict(existing)
    results: list[WireResult] = []
    for name, spec in new_servers.items():
        action = "updated" if name in existing else "added"
        merged[name] = spec
        results.append(WireResult(name, True, action))

    data["mcpServers"] = merged

    # Atomic write.
    try:
        tmp = CLAUDE_JSON.with_suffix(CLAUDE_JSON.suffix + ".tmp")
        tmp.write_text(json.dumps(data, indent=2))
        os.replace(tmp, CLAUDE_JSON)
    except Exception as e:
        return [WireResult("(write)", False, f"failed to write {CLAUDE_JSON}: {e}")]

    return results


def wire_one(name: str, spec: dict[str, Any]) -> WireResult:
    """Wire a single server. Mostly used for re-wiring after a token refresh."""
    if not CLAUDE_JSON.exists():
        return WireResult(name, False, f"{CLAUDE_JSON} not found")
    try:
        data = json.loads(CLAUDE_JSON.read_text())
    except Exception as e:
        return WireResult(name, False, str(e))
    existing = dict(data.get("mcpServers") or {})
    action = "updated" if name in existing else "added"
    existing[name] = spec
    data["mcpServers"] = existing
    tmp = CLAUDE_JSON.with_suffix(CLAUDE_JSON.suffix + ".tmp")
    tmp.write_text(json.dumps(data, indent=2))
    os.replace(tmp, CLAUDE_JSON)
    return WireResult(name, True, action)
