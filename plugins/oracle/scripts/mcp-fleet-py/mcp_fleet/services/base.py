"""Common types and helpers shared across service probes."""

from __future__ import annotations

from dataclasses import dataclass
from typing import Any, Callable, Awaitable


LogFn = Callable[[str], None]


class ProbeError(Exception):
    """Raised when a probe cannot complete (user cancellation, bad token, etc.)."""


@dataclass
class ProbeContext:
    """Communication channel between a probe and the TUI driving it.

    A probe gets a log callback (free-text status updates) and can `await`
    paste_secret / paste_text / wait_signal -- the TUI fulfils these via
    its own widgets so the probe never has to know about Textual.
    """
    log: LogFn
    paste_secret: Callable[[str], Awaitable[str]]
    paste_text: Callable[[str], Awaitable[str]]
    wait_signal: Callable[[str], Awaitable[None]]


SERVICES = ["slack", "linear", "notion", "github", "atlassian"]
SERVICE_TITLES = {
    "slack": "Slack",
    "linear": "Linear",
    "notion": "Notion",
    "github": "GitHub",
    "atlassian": "Atlassian",
}
SERVICE_HINTS = {
    "slack": "headed browser will open at slack.com/signin; sign in to ONE workspace",
    "linear": "browser opens at linear.app/settings/api; create a personal API key and paste back",
    "notion": "browser opens at notion.so/profile/integrations; create internal integration, share at least one page",
    "github": "browser opens at github.com/settings/personal-access-tokens/new; Resource owner = target org",
    "atlassian": "browser opens at id.atlassian.com/manage-profile/security/api-tokens; you'll also enter site URL + email",
}
