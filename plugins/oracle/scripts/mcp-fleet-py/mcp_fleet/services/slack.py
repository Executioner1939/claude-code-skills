"""Slack workspace probe.

Slack's OAuth path is closed for non-Marketplace MCP apps. We use the
cookie-extraction approach that korotovsky/slack-mcp-server expects:
a `d` cookie (the xoxd token) plus an `xoxc-` token harvested from
localStorage after navigating to app.slack.com/client.

Flow:
  1. Open chromium in an isolated profile at slack.com/signin.
  2. TUI awaits user signal "signed_in".
  3. Read cookies from context, find `d`.
  4. Navigate to app.slack.com/client, wait for the team-keyed URL,
     read localStorage.localConfig_v2.teams[<id>].token.
  5. If either auto-extraction fails, prompt user to paste manually.
  6. Validate via slack.com/api/auth.test, persist if it returns ok=true.
"""

from __future__ import annotations

import re

import httpx
from playwright.async_api import async_playwright

from .. import store
from ..paths import profile_dir
from .base import ProbeContext, ProbeError


TEAM_URL_RE = re.compile(r"/client/([A-Z0-9]+)")


async def _extract_xoxc(context, ctx: ProbeContext) -> str:
    """Open app.slack.com/client in the same context and pull xoxc from localStorage."""
    page = await context.new_page()
    try:
        await page.goto("https://app.slack.com/client", wait_until="domcontentloaded", timeout=30000)
    except Exception:
        ctx.log("app.slack.com/client did not load; xoxc auto-extract may fail")

    try:
        await page.wait_for_url(TEAM_URL_RE, timeout=30000)
    except Exception:
        ctx.log("did not see /client/<TEAM_ID> URL within 30s; trying anyway")

    xoxc: str = await page.evaluate(
        """
        () => {
          try {
            const cfg = JSON.parse(localStorage.localConfig_v2);
            const m = document.location.pathname.match(/^\\/client\\/([A-Z0-9]+)/);
            if (!m) return "";
            const team = cfg.teams && cfg.teams[m[1]];
            return (team && team.token) || "";
          } catch { return ""; }
        }
        """
    )
    try:
        await page.close()
    except Exception:
        pass
    return xoxc or ""


async def _validate(xoxc: str, xoxd: str) -> str:
    """Slack auth.test returns the team name when the token is good."""
    async with httpx.AsyncClient(timeout=15) as client:
        r = await client.post(
            "https://slack.com/api/auth.test",
            data={"token": xoxc},
            cookies={"d": xoxd},
        )
    body = r.json() if r.headers.get("content-type", "").startswith("application/json") else {}
    if not body.get("ok"):
        raise ProbeError(f"Slack auth.test failed: {body.get('error') or 'unknown'}")
    return body.get("team") or "Slack workspace"


async def probe(label: str, ctx: ProbeContext) -> store.Workspace:
    if not label:
        raise ProbeError("workspace label is required")

    user_data = profile_dir("slack", label)

    ctx.log(f"opening Chromium for slack/{label}")
    ctx.log("sign in to ONE workspace, then click 'Signed in' in the TUI")

    async with async_playwright() as p:
        context = await p.chromium.launch_persistent_context(
            str(user_data),
            headless=False,
            viewport={"width": 1280, "height": 900},
            ignore_default_args=["--enable-automation"],
            args=[
                "--no-first-run",
                "--no-default-browser-check",
                "--disable-blink-features=AutomationControlled",
            ],
        )
        page = context.pages[0] if context.pages else await context.new_page()
        try:
            await page.goto("https://slack.com/signin", wait_until="domcontentloaded", timeout=30000)
        except Exception:
            pass

        await ctx.wait_signal("signed_in")

        cookies = await context.cookies()
        d_cookie = next(
            (c for c in cookies if c.get("name") == "d" and c.get("domain", "").endswith("slack.com")),
            None,
        )

        xoxd = d_cookie.get("value") if d_cookie else ""
        if xoxd:
            ctx.log("found `d` cookie (xoxd token)")
        else:
            ctx.log("`d` cookie not found in this profile")

        xoxc = ""
        if xoxd:
            ctx.log("walking app.slack.com/client to harvest xoxc from localStorage ...")
            try:
                xoxc = await _extract_xoxc(context, ctx)
            except Exception as e:
                ctx.log(f"auto-extraction error: {e}")

        try:
            await context.close()
        except Exception:
            pass

    if not xoxd:
        ctx.log("falling back to manual xoxd paste")
        xoxd = (await ctx.paste_secret("Paste xoxd token (the `d` cookie value)")).strip()
    if not xoxc:
        ctx.log("falling back to manual xoxc paste -- in DevTools on app.slack.com/client:")
        ctx.log("  JSON.parse(localStorage.localConfig_v2).teams[")
        ctx.log("    document.location.pathname.match(/^\\/client\\/([A-Z0-9]+)/)[1]")
        ctx.log("  ].token")
        xoxc = (await ctx.paste_secret("Paste xoxc token")).strip()

    if not xoxd or not xoxc:
        raise ProbeError("missing xoxd or xoxc token after manual fallback")

    ctx.log("validating against slack.com/api/auth.test ...")
    team_name = await _validate(xoxc, xoxd)
    ctx.log(f"validated -- team: {team_name}")

    return store.upsert(store.Workspace(
        service="slack",
        label=label,
        kind="slack-cookie",
        credentials={
            "SLACK_MCP_XOXC_TOKEN": xoxc,
            "SLACK_MCP_XOXD_TOKEN": xoxd,
        },
        profileDir=str(user_data),
        discoveredName=team_name,
    ))
