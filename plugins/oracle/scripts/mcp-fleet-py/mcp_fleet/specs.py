"""Per-kind upstream MCP server specs.

Each entry maps a workspace `kind` to the stdio command + args + env keys
that the corresponding upstream MCP server expects. Versions verified
against npm/PyPI on 2026-05-13; bump deliberately.

Mirrors plugins/oracle/scripts/mcp-fleet/build-matrix.mjs.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Callable

from .store import Workspace


@dataclass
class StdioSpec:
    command: str
    args: list[str]
    env_keys: list[str]
    extra_env: dict[str, str] | None = None


SpecFn = Callable[[Workspace], StdioSpec]


SPECS: dict[str, SpecFn] = {
    "slack-cookie": lambda w: StdioSpec(
        command="npx",
        args=["-y", "slack-mcp-server@1.2.3"],
        env_keys=["SLACK_MCP_XOXC_TOKEN", "SLACK_MCP_XOXD_TOKEN"],
        # Write-tool toggle for korotovsky/slack-mcp-server. Empirically
        # observed behaviour for slack-mcp-server@1.2.3:
        #   "true"               -> conversations_add_message enabled in
        #                           DMs + group DMs + public + private (everything)
        #   "1,public,private"   -> public + private channels ONLY, no DMs
        #   "C0123,D0456,..."    -> per-channel allowlist
        # Default is "true" because the user explicitly opted into full write
        # surface including DMs after testing 1,public,private and finding DMs
        # were blocked. Override per-workspace in workspaces.json if you want
        # narrower scope on a specific binding.
        extra_env={"SLACK_MCP_ADD_MESSAGE_TOOL": "true"},
    ),
    "linear-api-key": lambda w: StdioSpec(
        command="npx",
        args=["-y", "mcp-server-linear@1.6.0"],
        env_keys=["LINEAR_API_KEY"],
        extra_env={"TOOL_PREFIX": f"linear_{w.label}_"},
    ),
    "notion-integration": lambda w: StdioSpec(
        command="npx",
        args=["-y", "@notionhq/notion-mcp-server@2.2.1"],
        env_keys=["NOTION_TOKEN"],
    ),
    "github-pat": lambda w: StdioSpec(
        command="docker",
        args=[
            "run", "-i", "--rm",
            "-e", "GITHUB_PERSONAL_ACCESS_TOKEN",
            "ghcr.io/github/github-mcp-server",
        ],
        env_keys=["GITHUB_PERSONAL_ACCESS_TOKEN"],
    ),
    "atlassian-api-token": lambda w: StdioSpec(
        command="uvx",
        args=["mcp-atlassian==0.21.1"],
        env_keys=[
            "CONFLUENCE_URL", "CONFLUENCE_USERNAME", "CONFLUENCE_API_TOKEN",
            "JIRA_URL", "JIRA_USERNAME", "JIRA_API_TOKEN",
        ],
    ),
}


def resolve(workspace: Workspace) -> StdioSpec:
    factory = SPECS.get(workspace.kind)
    if not factory:
        raise KeyError(f"no upstream-server spec for kind {workspace.kind!r}")
    return factory(workspace)
