"""Main Textual App for mcp-fleet -- claude-code-inspired aesthetic."""

from __future__ import annotations

import asyncio
import importlib
from datetime import datetime
from pathlib import Path
from typing import ClassVar

from rich.text import Text
from textual import work
from textual.app import App, ComposeResult
from textual.binding import Binding
from textual.containers import Horizontal
from textual.reactive import reactive
from textual.widgets import DataTable, Footer, RichLog, Static
from textual.worker import Worker, WorkerState

from .. import matrix, store, wire
from ..paths import fleet_home
from ..services.base import (
    ProbeContext,
    ProbeError,
    SERVICE_TITLES,
)
from .screens import AddWorkspaceModal, PasteModal, SignalModal


SERVICE_MODULES = {
    "slack": "mcp_fleet.services.slack",
    "linear": "mcp_fleet.services.linear",
    "notion": "mcp_fleet.services.notion",
    "github": "mcp_fleet.services.github",
    "atlassian": "mcp_fleet.services.atlassian",
}


class FleetApp(App[None]):
    CSS_PATH = "app.tcss"

    BINDINGS: ClassVar = [
        Binding("a", "add_workspace", "add"),
        Binding("w", "wire_all", "wire"),
        Binding("r", "refresh", "refresh"),
        Binding("q", "quit", "quit"),
    ]

    busy: reactive[bool] = reactive(False)

    def __init__(self) -> None:
        super().__init__()
        self._wired_cache: set[str] = set()

    # ------------------------------------------------------------------
    # Compose

    def compose(self) -> ComposeResult:
        # Title strip
        home = str(fleet_home()).replace(str(Path.home()), "~")
        title = Text()
        title.append("mcp-fleet", style="bold")
        title.append("  ")
        title.append("multi-workspace MCP onboarding", style="dim")
        title.append("  ")
        title.append(home, style="dim italic")
        yield Static(title, id="title-bar")

        # Bindings section
        yield Static("Workspaces", classes="section")
        yield Static(
            "press [bold]a[/bold] to bind a new workspace; "
            "[bold]w[/bold] to wire everything into Claude Code",
            classes="section-sub",
        )
        yield DataTable(id="bindings", cursor_type="none", zebra_stripes=False)
        yield Static("", id="empty-hint")

        # Log section
        yield Static("Activity", classes="section")
        yield RichLog(id="log", wrap=True, markup=True, max_lines=400)

        yield Footer()

    # ------------------------------------------------------------------
    # Lifecycle

    def on_mount(self) -> None:
        table = self.query_one("#bindings", DataTable)
        table.add_columns("service", "label", "discovered", "wired")
        self._refresh_wired_cache()
        self.refresh_table()
        n = len(store.read_store())
        self.log_line(f"loaded {n} workspace(s)" if n else "no workspaces yet", level="dim")
        if not wire.claude_available():
            self.log_line("claude CLI not on PATH; wire-all is a no-op", level="warn")

    # ------------------------------------------------------------------
    # Logging

    def log_line(self, message: str, *, level: str = "info") -> None:
        try:
            rl = self.query_one("#log", RichLog)
        except Exception:
            return
        ts = datetime.now().strftime("%H:%M:%S")
        body = Text()
        body.append(ts, style="dim")
        body.append("  ")
        style = {
            "info": "",
            "ok": "green",
            "warn": "yellow",
            "fail": "red",
            "dim": "dim",
        }.get(level, "")
        body.append(message, style=style)
        rl.write(body)

    # ------------------------------------------------------------------
    # State

    def _refresh_wired_cache(self) -> None:
        try:
            self._wired_cache = wire.list_existing()
        except Exception:
            self._wired_cache = set()

    def refresh_table(self) -> None:
        try:
            table = self.query_one("#bindings", DataTable)
        except Exception:
            return
        table.clear()
        workspaces = store.read_store()
        for w in workspaces:
            wired = w.server_name() in self._wired_cache
            wired_text = Text("wired", style="green") if wired else Text("·", style="dim")
            discovered = w.discoveredName or "—"
            disc_text = Text(discovered, style="" if w.discoveredName else "dim")
            table.add_row(
                Text(SERVICE_TITLES.get(w.service, w.service).lower(), style="dim"),
                Text(w.label),
                disc_text,
                wired_text,
            )
        # Empty-state hint
        hint = self.query_one("#empty-hint", Static)
        if not workspaces:
            hint.update(Text("no workspaces yet — press 'a' to add one", style="dim italic"))
        else:
            hint.update("")

    # ------------------------------------------------------------------
    # Actions

    def action_refresh(self) -> None:
        self._refresh_wired_cache()
        self.refresh_table()
        self.log_line("refreshed", level="dim")

    @work(exclusive=True, name="add-workspace")
    async def action_add_workspace(self) -> None:
        if self.busy:
            self.bell()
            self.log_line("a probe is already running; cancel it first", level="warn")
            return
        result = await self.push_screen_wait(AddWorkspaceModal())
        if not result:
            return
        service, label = result
        self.run_probe(service, label)

    @work(exclusive=True, name="wire-all")
    async def action_wire_all(self) -> None:
        if self.busy:
            self.bell()
            return
        if not wire.claude_available():
            self.log_line("claude CLI not on PATH; cannot wire", level="fail")
            return
        self.busy = True
        try:
            workspaces = store.read_store()
            if not workspaces:
                self.log_line("nothing to wire — add a workspace first", level="warn")
                return
            self.log_line(f"wiring {len(workspaces)} server(s) via 'claude mcp add'")
            path, count = matrix.build()
            self.log_line(f"matrix rebuilt: {count} server(s) -> {path}", level="dim")
            results = await asyncio.to_thread(wire.wire_all)
            ok = sum(1 for r in results if r.ok)
            for r in results:
                self.log_line(
                    f"  {r.server}  {r.message}",
                    level="ok" if r.ok else "fail",
                )
            level = "ok" if ok == len(results) else "warn"
            self.log_line(
                f"wired {ok}/{len(results)}. restart Claude Code to pick them up.",
                level=level,
            )
            self._refresh_wired_cache()
            self.refresh_table()
        finally:
            self.busy = False

    # ------------------------------------------------------------------
    # Probe orchestration

    def run_probe(self, service: str, label: str) -> None:
        self.busy = True
        self.log_line(f"probe start: {service}/{label}")
        self.run_worker(
            self._probe_worker(service, label),
            name=f"probe-{service}-{label}",
            exclusive=True,
        )

    async def _probe_worker(self, service: str, label: str) -> None:
        try:
            mod = importlib.import_module(SERVICE_MODULES[service])
        except Exception as e:
            self.log_line(f"failed to load {service} module: {e}", level="fail")
            self.busy = False
            return

        ctx = ProbeContext(
            log=self.log_line,
            paste_secret=lambda prompt: self._modal_paste_secret(service, label, prompt),
            paste_text=lambda prompt: self._modal_paste_text(service, label, prompt),
            wait_signal=lambda signal: self._modal_wait_signal(service, label, signal),
        )

        try:
            workspace = await mod.probe(label, ctx)
        except ProbeError as e:
            self.log_line(f"probe failed: {e}", level="fail")
            self.busy = False
            return
        except Exception as e:
            self.log_line(f"unexpected error: {e!r}", level="fail")
            self.busy = False
            return

        try:
            path, count = matrix.build()
            self.log_line(f"matrix rebuilt: {count} server(s)", level="dim")
        except Exception as e:
            self.log_line(f"matrix build failed: {e}", level="warn")

        name = workspace.discoveredName or "no name"
        self.log_line(
            f"persisted {workspace.service}/{workspace.label}  ({name})",
            level="ok",
        )
        self._refresh_wired_cache()
        self.refresh_table()
        self.busy = False

    # ------------------------------------------------------------------
    # Modal helpers

    async def _modal_paste_secret(self, service: str, label: str, prompt: str) -> str:
        result = await self.push_screen_wait(
            PasteModal(
                title=f"{SERVICE_TITLES.get(service, service)} / {label}",
                prompt=prompt,
                secret=True,
                placeholder="(hidden)",
            )
        )
        if result is None:
            raise ProbeError("cancelled by user")
        return result

    async def _modal_paste_text(self, service: str, label: str, prompt: str) -> str:
        result = await self.push_screen_wait(
            PasteModal(
                title=f"{SERVICE_TITLES.get(service, service)} / {label}",
                prompt=prompt,
                secret=False,
            )
        )
        if result is None:
            raise ProbeError("cancelled by user")
        return result

    async def _modal_wait_signal(self, service: str, label: str, signal: str) -> None:
        msg = {
            "signed_in": "sign in to the workspace in the Chromium window, then press Done",
        }.get(signal, f"waiting for: {signal}")
        ok = await self.push_screen_wait(
            SignalModal(
                title=f"{SERVICE_TITLES.get(service, service)} / {label}",
                prompt=msg,
            )
        )
        if not ok:
            raise ProbeError("cancelled by user at signal")

    # ------------------------------------------------------------------
    # Worker state

    def on_worker_state_changed(self, event: Worker.StateChanged) -> None:
        if event.state in (WorkerState.SUCCESS, WorkerState.ERROR, WorkerState.CANCELLED):
            if event.worker.name and event.worker.name.startswith("probe-"):
                self.busy = False


def main() -> None:
    FleetApp().run()


if __name__ == "__main__":
    main()
