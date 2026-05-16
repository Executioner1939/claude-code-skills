"""Workspace store. JSON-backed, mode 600.

Schema-compatible with the Node mcp-fleet/lib/workspaces-store.mjs version:
the same workspaces.json file is readable by both implementations.
"""

from __future__ import annotations

import json
from dataclasses import dataclass, field, asdict
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Iterable

from .paths import ensure_fleet_home, profile_dir, workspaces_json

SCHEMA_VERSION = 1


@dataclass
class Workspace:
    service: str  # slack | linear | notion | github | atlassian
    label: str
    kind: str  # slack-cookie | linear-api-key | notion-integration | github-pat | atlassian-api-token
    credentials: dict[str, str]
    profileDir: str = ""
    createdAt: str = ""
    discoveredName: str | None = None  # team/workspace/org name discovered post-paste

    def server_name(self) -> str:
        raw = f"{self.service}__{self.label}"
        return "".join(c if c.isalnum() or c == "_" else "_" for c in raw)


def _utcnow_iso() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%S.%fZ")


def read_store() -> list[Workspace]:
    p = workspaces_json()
    if not p.exists():
        return []
    try:
        data = json.loads(p.read_text())
    except json.JSONDecodeError as e:
        raise RuntimeError(f"workspaces.json is corrupt ({e}). Fix or delete: {p}") from e
    out: list[Workspace] = []
    for w in data.get("workspaces", []):
        out.append(Workspace(
            service=w["service"],
            label=w["label"],
            kind=w["kind"],
            credentials=dict(w.get("credentials", {})),
            profileDir=w.get("profileDir", ""),
            createdAt=w.get("createdAt", ""),
            discoveredName=w.get("discoveredName"),
        ))
    return out


def write_store(workspaces: Iterable[Workspace]) -> None:
    ensure_fleet_home()
    p = workspaces_json()
    body = {
        "version": SCHEMA_VERSION,
        "workspaces": [
            {k: v for k, v in asdict(w).items() if v is not None}
            for w in workspaces
        ],
    }
    p.write_text(json.dumps(body, indent=2) + "\n")
    try:
        p.chmod(0o600)
    except OSError:
        pass


def upsert(w: Workspace) -> Workspace:
    """Insert or replace a (service, label) entry. Returns the enriched record."""
    if not w.service or not w.label or not w.kind:
        raise ValueError("workspace missing service / label / kind")
    if not w.profileDir:
        w.profileDir = str(profile_dir(w.service, w.label))
    if not w.createdAt:
        w.createdAt = _utcnow_iso()

    store = read_store()
    out: list[Workspace] = []
    replaced = False
    for existing in store:
        if existing.service == w.service and existing.label == w.label:
            out.append(w)
            replaced = True
        else:
            out.append(existing)
    if not replaced:
        out.append(w)
    write_store(out)
    return w


def remove(service: str, label: str) -> bool:
    store = read_store()
    keep = [w for w in store if not (w.service == service and w.label == label)]
    if len(keep) == len(store):
        return False
    write_store(keep)
    return True


def get(service: str, label: str) -> Workspace | None:
    for w in read_store():
        if w.service == service and w.label == label:
            return w
    return None
