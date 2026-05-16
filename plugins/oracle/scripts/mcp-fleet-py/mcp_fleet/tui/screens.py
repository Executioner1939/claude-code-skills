"""Modal screens used by the main App."""

from __future__ import annotations

from typing import ClassVar

from textual.app import ComposeResult
from textual.containers import Vertical, Horizontal
from textual.screen import ModalScreen
from textual.widgets import Button, Input, Label, Select, Static

from ..services.base import SERVICES, SERVICE_TITLES, SERVICE_HINTS


class PasteModal(ModalScreen[str | None]):
    """Single-line input modal. Returns the entered string, or None if cancelled."""

    BINDINGS: ClassVar = [("escape", "cancel", "Cancel")]

    def __init__(self, title: str, prompt: str, secret: bool = False, placeholder: str = ""):
        super().__init__()
        self._title = title
        self._prompt = prompt
        self._secret = secret
        self._placeholder = placeholder

    def compose(self) -> ComposeResult:
        with Vertical(id="modal"):
            yield Label(self._title, id="modal-title")
            yield Static(self._prompt, id="modal-prompt")
            yield Input(
                password=self._secret,
                placeholder=self._placeholder,
                id="modal-input",
            )
            with Horizontal(id="modal-actions"):
                yield Button("Cancel", id="cancel")
                yield Button("OK", id="ok", variant="primary")

    def on_mount(self) -> None:
        self.query_one("#modal-input", Input).focus()

    def on_input_submitted(self, event: Input.Submitted) -> None:
        self.dismiss(event.value)

    def on_button_pressed(self, event: Button.Pressed) -> None:
        if event.button.id == "ok":
            self.dismiss(self.query_one("#modal-input", Input).value)
        else:
            self.dismiss(None)

    def action_cancel(self) -> None:
        self.dismiss(None)


class SignalModal(ModalScreen[bool]):
    """Wait-for-user-action modal. Dismiss(True) on Done, Dismiss(False) on Cancel."""

    BINDINGS: ClassVar = [("escape", "cancel", "Cancel")]

    def __init__(self, title: str, prompt: str, done_label: str = "Done"):
        super().__init__()
        self._title = title
        self._prompt = prompt
        self._done_label = done_label

    def compose(self) -> ComposeResult:
        with Vertical(id="modal"):
            yield Label(self._title, id="modal-title")
            yield Static(self._prompt, id="modal-prompt")
            with Horizontal(id="modal-actions"):
                yield Button("Cancel", id="cancel")
                yield Button(self._done_label, id="done", variant="primary")

    def on_button_pressed(self, event: Button.Pressed) -> None:
        self.dismiss(event.button.id == "done")

    def action_cancel(self) -> None:
        self.dismiss(False)


class AddWorkspaceModal(ModalScreen[tuple[str, str] | None]):
    """Pick a service + label. Returns (service, label), or None if cancelled."""

    BINDINGS: ClassVar = [("escape", "cancel", "Cancel")]

    def __init__(self, default_service: str | None = None):
        super().__init__()
        self._default = default_service

    def compose(self) -> ComposeResult:
        options = [(SERVICE_TITLES[s], s) for s in SERVICES]
        with Vertical(id="modal"):
            yield Label("Add workspace", id="modal-title")
            yield Static("Service:", id="modal-prompt")
            yield Select(options, value=self._default or SERVICES[0], id="service")
            yield Static("Workspace label (short, lowercase, e.g. 'contactable'):")
            yield Input(placeholder="label", id="label")
            yield Static(id="hint", classes="muted")
            with Horizontal(id="modal-actions"):
                yield Button("Cancel", id="cancel")
                yield Button("Start", id="start", variant="primary")

    def on_mount(self) -> None:
        self._update_hint(self._default or SERVICES[0])
        self.query_one("#label", Input).focus()

    def _update_hint(self, service: str) -> None:
        hint = self.query_one("#hint", Static)
        hint.update(SERVICE_HINTS.get(service, ""))

    def on_select_changed(self, event: Select.Changed) -> None:
        if event.value:
            self._update_hint(str(event.value))

    def on_input_submitted(self, event: Input.Submitted) -> None:
        self._submit()

    def on_button_pressed(self, event: Button.Pressed) -> None:
        if event.button.id == "start":
            self._submit()
        else:
            self.dismiss(None)

    def _submit(self) -> None:
        svc = str(self.query_one("#service", Select).value)
        lbl = self.query_one("#label", Input).value.strip()
        if not lbl:
            self.notify("Label is required.", severity="warning")
            return
        self.dismiss((svc, lbl))

    def action_cancel(self) -> None:
        self.dismiss(None)
