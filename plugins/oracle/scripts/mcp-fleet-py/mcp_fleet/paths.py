"""Filesystem layout for mcp-fleet state.

Same layout as the Node-based sibling at scripts/mcp-fleet/ so they can
share workspaces.json without migration.
"""

from __future__ import annotations

import os
import re
from pathlib import Path

ROOT_ENV = "ORACLE_MCP_FLEET_HOME"


def fleet_home() -> Path:
    override = os.environ.get(ROOT_ENV)
    if override:
        return Path(override).resolve()
    return Path.home() / ".claude" / "oracle" / "mcp-fleet"


def ensure_fleet_home() -> Path:
    p = fleet_home()
    p.mkdir(parents=True, exist_ok=True)
    try:
        p.chmod(0o700)
    except OSError:
        pass
    return p


def workspaces_json() -> Path:
    return fleet_home() / "workspaces.json"


def fleet_json() -> Path:
    return fleet_home() / "mcp-fleet.json"


def profiles_root() -> Path:
    return fleet_home() / "chrome-profiles"


def _sanitize(component: str) -> str:
    s = re.sub(r"[^a-z0-9-]+", "-", component.lower())
    s = s.strip("-")[:64]
    return s or "default"


def profile_dir(service: str, workspace_id: str) -> Path:
    d = profiles_root() / _sanitize(service) / _sanitize(workspace_id)
    d.mkdir(parents=True, exist_ok=True)
    try:
        d.chmod(0o700)
    except OSError:
        pass
    return d
