"""Atlassian site probe.

sooperset/mcp-atlassian consumes per-site API token + email + site URL.
One workspace = one Atlassian site (covering both Jira and Confluence on
that site -- the same API token authenticates against both products).

After paste we GET /rest/api/3/myself with basic auth (email:token) to
validate. We then probe /wiki/rest/api/user/current to confirm Confluence
access on the same site; failure there is a WARN not an ERROR (a site
might have only one product enabled).
"""

from __future__ import annotations

import base64
import re

import httpx

from .. import store
from ..paths import profile_dir
from .base import ProbeContext, ProbeError


URL_RE = re.compile(r"^https://[^/]+\.atlassian\.net/?$")


async def _validate(site_url: str, email: str, token: str, ctx: ProbeContext) -> tuple[str, bool, bool]:
    """Returns (display_name, jira_ok, confluence_ok)."""
    base = site_url.rstrip("/")
    auth = base64.b64encode(f"{email}:{token}".encode()).decode()
    headers = {"Authorization": f"Basic {auth}", "Accept": "application/json"}

    async with httpx.AsyncClient(timeout=15, headers=headers) as client:
        jr = await client.get(f"{base}/rest/api/3/myself")
        if jr.status_code != 200:
            raise ProbeError(f"Atlassian Jira rejected the token ({jr.status_code}): {jr.text[:200]}")
        display = (jr.json() or {}).get("displayName") or email

        jira_ok = True
        confluence_ok = False
        try:
            cr = await client.get(f"{base}/wiki/rest/api/user/current")
            confluence_ok = cr.status_code == 200
        except Exception:
            confluence_ok = False

    return display, jira_ok, confluence_ok


async def probe(label: str, ctx: ProbeContext) -> store.Workspace:
    if not label:
        raise ProbeError("site label is required")

    site_url = (await ctx.paste_text(
        "Site URL (e.g. https://acme.atlassian.net)"
    )).strip()
    if not URL_RE.match(site_url):
        raise ProbeError("expected https://<tenant>.atlassian.net")

    email = (await ctx.paste_text("Atlassian account email")).strip()
    if "@" not in email:
        raise ProbeError("expected an email address")

    ctx.log(f"opening Chromium at id.atlassian.com/manage-profile/security/api-tokens for atlassian/{label}")
    from .browser_helper import open_url_in_profile
    async with open_url_in_profile(
        service="atlassian",
        workspace=label,
        url="https://id.atlassian.com/manage-profile/security/api-tokens",
    ):
        token = (await ctx.paste_secret("Paste the API token")).strip()

    if not token:
        raise ProbeError("API token is required")

    ctx.log("validating against Jira + Confluence APIs ...")
    display, jira_ok, confluence_ok = await _validate(site_url, email, token, ctx)
    products = []
    if jira_ok:
        products.append("Jira")
    if confluence_ok:
        products.append("Confluence")
    else:
        ctx.log("NOTE: Confluence is not reachable on this site/token; Jira-only binding.")
    ctx.log(f"validated -- {display} ({' + '.join(products) or 'unknown product'})")

    base = site_url.rstrip("/")
    return store.upsert(store.Workspace(
        service="atlassian",
        label=label,
        kind="atlassian-api-token",
        credentials={
            "CONFLUENCE_URL": f"{base}/wiki",
            "CONFLUENCE_USERNAME": email,
            "CONFLUENCE_API_TOKEN": token,
            "JIRA_URL": base,
            "JIRA_USERNAME": email,
            "JIRA_API_TOKEN": token,
        },
        profileDir=str(profile_dir("atlassian", label)),
        discoveredName=f"{display} @ {base}",
    ))
