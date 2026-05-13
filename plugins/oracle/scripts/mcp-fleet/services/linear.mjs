// Linear workspace probe.
//
// dvcrn/mcp-server-linear consumes a personal API key via LINEAR_API_KEY
// and supports running multiple instances with different TOOL_PREFIX values
// for true multi-workspace concurrency.
//
// Linear shows the API key value exactly once at creation time, so we
// can't read it from the settings page after the fact. Flow: open
// linear.app/settings/api in an isolated profile, user logs in to the
// workspace, clicks Create new key, copies the displayed value, pastes
// here. Auto-extraction is unreliable because the displayed token is
// inside a flash modal that disappears on click-away.

import { launchProfile } from "../lib/playwright-launcher.mjs";
import { ask, askSecret } from "../lib/prompt.mjs";
import { upsert } from "../lib/workspaces-store.mjs";

export async function probe({ label }) {
  const wsLabel = label || (await ask("Linear workspace label (e.g. 'acme'): "));
  if (!wsLabel) throw new Error("workspace label is required");

  process.stdout.write(
    `\nLaunching Chrome with an isolated profile for linear/${wsLabel}.\n` +
    `Sign in to the workspace you want to bind to this label, then go to\n` +
    `Settings -> API -> Personal API keys and create a new key.\n\n`,
  );

  const { close } = await launchProfile({
    service: "linear",
    workspace: wsLabel,
    startUrl: "https://linear.app/settings/api",
  });

  const apiKey = await askSecret("Paste the new Linear API key (lin_api_..., input hidden): ");
  await close();

  if (!apiKey || !apiKey.startsWith("lin_api_")) {
    throw new Error("Expected a Linear personal API key starting with lin_api_");
  }

  return upsert({
    service: "linear",
    label: wsLabel,
    kind: "linear-api-key",
    credentials: { LINEAR_API_KEY: apiKey },
    profileDir: "",
  });
}

if (import.meta.url === `file://${process.argv[1]}`) {
  probe({ label: process.argv[2] }).then(
    (e) => { process.stdout.write(`Persisted linear workspace ${e.label}\n`); process.exit(0); },
    (e) => { process.stderr.write(`${e.message}\n`); process.exit(1); },
  );
}
