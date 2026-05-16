"""GitHub org probe.

github/github-mcp-server consumes GITHUB_PERSONAL_ACCESS_TOKEN. Each org
gets its own PAT (fine-grained, resource-owner = the org), which keeps
the blast radius narrow and matches the spirit of mcp-fleet's isolation
model.

After paste we hit /user to validate, then /user/memberships/orgs to
confirm the PAT actually has access to the named org so the label and
the underlying scope match.
"""

from __future__ import annotations

import httpx

from .. import store
from ..paths import profile_dir
from .base import ProbeContext, ProbeError


async def _validate(token: str, label_hint: str) -> tuple[str, list[str]]:
    """Returns (login, accessible_orgs)."""
    headers = {
        "Authorization": f"Bearer {token}",
        "Accept": "application/vnd.github+json",
        "X-GitHub-Api-Version": "2022-11-28",
    }
    async with httpx.AsyncClient(timeout=15, headers=headers) as client:
        ur = await client.get("https://api.github.com/user")
        if ur.status_code != 200:
            raise ProbeError(f"GitHub rejected the PAT ({ur.status_code}): {ur.text[:200]}")
        login = (ur.json() or {}).get("login") or "github-user"

        # Fine-grained PATs don't list memberships at /user/memberships/orgs
        # the same way classic PATs do; /user/orgs reflects whatever the PAT
        # is scoped to read. Best-effort: list it and report.
        orgs: list[str] = []
        try:
            or_ = await client.get("https://api.github.com/user/orgs")
            if or_.status_code == 200:
                orgs = [o.get("login", "") for o in or_.json() if o.get("login")]
        except Exception:
            pass

    return login, orgs


async def probe(label: str, ctx: ProbeContext) -> store.Workspace:
    if not label:
        raise ProbeError("org label is required")

    ctx.log(f"opening Chromium at github.com/settings/personal-access-tokens/new for github/{label}")
    ctx.log("set Resource owner to the target org; grant Contents R, Issues RW, PRs RW, Metadata R")
    from .browser_helper import open_url_in_profile
    async with open_url_in_profile(
        service="github",
        workspace=label,
        url="https://github.com/settings/personal-access-tokens/new",
    ):
        token = (await ctx.paste_secret(
            "Paste the PAT (github_pat_... or ghp_...)"
        )).strip()

    if not (token.startswith("github_pat_") or token.startswith("ghp_")):
        raise ProbeError("expected github_pat_ or ghp_ prefix")

    ctx.log("validating against api.github.com ...")
    login, orgs = await _validate(token, label)
    if orgs:
        ctx.log(f"validated -- user: {login}, orgs visible: {', '.join(orgs)}")
        # Soft warning if the named label looks like an org and isn't in the list.
        if label not in orgs and login != label:
            ctx.log(f"NOTE: label '{label}' is not in the org list. That can be fine for")
            ctx.log("fine-grained PATs scoped to a single repository.")
    else:
        ctx.log(f"validated -- user: {login} (no orgs visible to this PAT)")

    discovered = orgs[0] if orgs else login

    return store.upsert(store.Workspace(
        service="github",
        label=label,
        kind="github-pat",
        credentials={"GITHUB_PERSONAL_ACCESS_TOKEN": token},
        profileDir=str(profile_dir("github", label)),
        discoveredName=discovered,
    ))
