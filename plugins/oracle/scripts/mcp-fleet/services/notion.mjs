// Notion workspace probe.
//
// @notionhq/notion-mcp-server consumes an integration token via the
// NOTION_TOKEN env. Each Notion workspace requires its own internal
// integration; the secret_xxx token is workspace-scoped, so multi-workspace
// = multiple integrations.
//
// Auto-extraction of the secret is not feasible: Notion's integration
// secret is revealed via a Show button and the value is rendered into a
// React-controlled <input> with no stable selector across UI revs. Manual
// paste is the honest path.

import { launchProfile } from "../lib/playwright-launcher.mjs";
import { ask, askSecret } from "../lib/prompt.mjs";
import { upsert } from "../lib/workspaces-store.mjs";

export async function probe({ label }) {
  const wsLabel = label || (await ask("Notion workspace label (e.g. 'acme'): "));
  if (!wsLabel) throw new Error("workspace label is required");

  process.stdout.write(
    `\nLaunching Chrome with an isolated profile for notion/${wsLabel}.\n` +
    `Sign in to the target workspace, then create an internal integration:\n` +
    `  1. Go to https://www.notion.so/profile/integrations\n` +
    `  2. New integration, name it (the workspace dropdown picks the binding)\n` +
    `  3. Copy the Internal Integration Secret (starts with secret_ or ntn_)\n` +
    `  4. Share at least one page/database with the integration so it has data scope\n\n`,
  );

  const { close } = await launchProfile({
    service: "notion",
    workspace: wsLabel,
    startUrl: "https://www.notion.so/profile/integrations",
  });

  const token = await askSecret("Paste the integration token (input hidden): ");
  await close();

  if (!token || !(token.startsWith("secret_") || token.startsWith("ntn_"))) {
    throw new Error("Expected a Notion integration token starting with secret_ or ntn_");
  }

  return upsert({
    service: "notion",
    label: wsLabel,
    kind: "notion-integration",
    credentials: { NOTION_TOKEN: token },
    profileDir: "",
  });
}

if (import.meta.url === `file://${process.argv[1]}`) {
  probe({ label: process.argv[2] }).then(
    (e) => { process.stdout.write(`Persisted notion workspace ${e.label}\n`); process.exit(0); },
    (e) => { process.stderr.write(`${e.message}\n`); process.exit(1); },
  );
}
