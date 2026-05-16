"""Build ~/.claude/oracle/mcp-fleet/mcp-fleet.json from workspaces.json."""

from __future__ import annotations

import json
from datetime import datetime, timezone
from typing import Any

from . import store
from .paths import ensure_fleet_home, fleet_json, workspaces_json
from .specs import resolve


def render(workspaces: list[store.Workspace] | None = None) -> dict[str, Any]:
    if workspaces is None:
        workspaces = store.read_store()

    servers: dict[str, Any] = {}
    for w in workspaces:
        try:
            spec = resolve(w)
        except KeyError as e:
            # Skip unknown kinds rather than failing the whole render.
            print(f"warning: {e} -- skipping {w.service}/{w.label}")
            continue
        env: dict[str, str] = {}
        for k in spec.env_keys:
            env[k] = w.credentials.get(k, "")
        if spec.extra_env:
            env.update(spec.extra_env)
        servers[w.server_name()] = {
            "type": "stdio",
            "command": spec.command,
            "args": list(spec.args),
            "env": env,
        }

    return {
        "$generated_by": "plugins/oracle/scripts/mcp-fleet-py/mcp_fleet/matrix.py",
        "$generated_at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%S.%fZ"),
        "$source": str(workspaces_json()),
        "mcpServers": servers,
    }


def build() -> tuple[str, int]:
    ensure_fleet_home()
    workspaces = store.read_store()
    body = render(workspaces)
    out = fleet_json()
    out.write_text(json.dumps(body, indent=2) + "\n")
    return str(out), len(body["mcpServers"])
