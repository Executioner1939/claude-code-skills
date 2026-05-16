"""Linear workspace probe.

dvcrn/mcp-server-linear consumes a personal API key via LINEAR_API_KEY.
Multi-workspace = multiple keys, distinguished via TOOL_PREFIX so each
binding gets a unique set of tool names.

API keys are shown once at creation, so we paste-prompt. After paste we
validate by querying viewer{} on the GraphQL API so the user knows the
key works before we persist it.
"""

from __future__ import annotations

import httpx

from .. import store
from ..paths import profile_dir
from .base import ProbeContext, ProbeError


async def _validate(api_key: str) -> str:
    """Hit Linear's GraphQL API to validate the key + discover the org name."""
    async with httpx.AsyncClient(timeout=15) as client:
        r = await client.post(
            "https://api.linear.app/graphql",
            headers={"Authorization": api_key, "Content-Type": "application/json"},
            json={"query": "{ viewer { name email } organization { name } }"},
        )
    if r.status_code != 200:
        raise ProbeError(f"Linear API rejected the key ({r.status_code}): {r.text[:200]}")
    data = r.json()
    if data.get("errors"):
        raise ProbeError(f"Linear GraphQL error: {data['errors']}")
    org = (data.get("data") or {}).get("organization") or {}
    return org.get("name") or "Linear workspace"


async def probe(label: str, ctx: ProbeContext) -> store.Workspace:
    if not label:
        raise ProbeError("workspace label is required")

    ctx.log(f"opening Chromium at linear.app/settings/api for linear/{label}")
    # Use Playwright to open the page for the user, then await paste.
    from .browser_helper import open_url_in_profile
    async with open_url_in_profile(
        service="linear",
        workspace=label,
        url="https://linear.app/settings/api",
    ):
        ctx.log("sign in -> Settings -> API -> Personal API keys -> Create new key")
        api_key = (await ctx.paste_secret(
            "Paste the new Linear API key (starts with lin_api_)"
        )).strip()

    if not api_key.startswith("lin_api_"):
        raise ProbeError("expected a key starting with lin_api_")

    ctx.log("validating against api.linear.app ...")
    org_name = await _validate(api_key)
    ctx.log(f"validated -- organization: {org_name}")

    return store.upsert(store.Workspace(
        service="linear",
        label=label,
        kind="linear-api-key",
        credentials={"LINEAR_API_KEY": api_key},
        profileDir=str(profile_dir("linear", label)),
        discoveredName=org_name,
    ))
