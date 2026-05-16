"""Notion workspace probe.

@notionhq/notion-mcp-server consumes NOTION_TOKEN. Each Notion workspace
requires its own internal integration; the integration secret is
workspace-scoped, so multi-workspace = multiple integrations.

After paste we GET /v1/users/me to validate and discover the workspace
name. Important warning printed: if no page/db is shared with the
integration, the MCP server will see an empty workspace.
"""

from __future__ import annotations

import httpx

from .. import store
from ..paths import profile_dir
from .base import ProbeContext, ProbeError


NOTION_API_VERSION = "2022-06-28"


async def _validate(token: str) -> tuple[str, str]:
    """Returns (workspace_name, bot_name)."""
    async with httpx.AsyncClient(timeout=15) as client:
        r = await client.get(
            "https://api.notion.com/v1/users/me",
            headers={
                "Authorization": f"Bearer {token}",
                "Notion-Version": NOTION_API_VERSION,
            },
        )
    if r.status_code != 200:
        raise ProbeError(f"Notion API rejected the token ({r.status_code}): {r.text[:200]}")
    body = r.json()
    bot = body.get("bot") or {}
    ws_name = bot.get("workspace_name") or "Notion workspace"
    bot_name = body.get("name") or "integration"
    return ws_name, bot_name


async def probe(label: str, ctx: ProbeContext) -> store.Workspace:
    if not label:
        raise ProbeError("workspace label is required")

    ctx.log(f"opening Chromium at notion.so/profile/integrations for notion/{label}")
    from .browser_helper import open_url_in_profile
    async with open_url_in_profile(
        service="notion",
        workspace=label,
        url="https://www.notion.so/profile/integrations",
    ):
        ctx.log("create new integration; the workspace dropdown picks the binding")
        ctx.log("after creation, copy the Internal Integration Secret")
        token = (await ctx.paste_secret(
            "Paste the integration token (starts with secret_ or ntn_)"
        )).strip()

    if not (token.startswith("secret_") or token.startswith("ntn_")):
        raise ProbeError("expected secret_ or ntn_ prefix")

    ctx.log("validating against api.notion.com ...")
    ws_name, bot_name = await _validate(token)
    ctx.log(f"validated -- workspace: {ws_name} (bot: {bot_name})")
    ctx.log("REMINDER: share at least one page/db with the integration in Notion's UI,")
    ctx.log("otherwise the MCP server will see an empty workspace.")

    return store.upsert(store.Workspace(
        service="notion",
        label=label,
        kind="notion-integration",
        credentials={"NOTION_TOKEN": token},
        profileDir=str(profile_dir("notion", label)),
        discoveredName=ws_name,
    ))
