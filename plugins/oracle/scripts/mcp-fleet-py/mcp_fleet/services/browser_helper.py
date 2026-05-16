"""Playwright wrapper -- launches a fresh-or-resumed Chromium with an
isolated --user-data-dir per (service, workspace). Headed by default --
the user has to log in once per workspace, and OAuth providers detect
and block headless flows.
"""

from __future__ import annotations

from contextlib import asynccontextmanager

from playwright.async_api import async_playwright

from ..paths import profile_dir


@asynccontextmanager
async def open_url_in_profile(*, service: str, workspace: str, url: str):
    """Yield (context, page) for an isolated Chromium profile at `url`.

    Chrome >=136 forbids CDP automation against the user's default
    --user-data-dir; we always use a fresh dir under fleet home.
    """
    user_data = profile_dir(service, workspace)
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
            await page.goto(url, wait_until="domcontentloaded", timeout=30000)
        except Exception:
            # Failure to load is not fatal -- the user can navigate manually.
            pass
        try:
            yield context, page
        finally:
            try:
                await context.close()
            except Exception:
                pass
