// Atlassian site probe.
//
// sooperset/mcp-atlassian consumes per-instance API token + email + site
// URL via CONFLUENCE_URL / CONFLUENCE_USERNAME / CONFLUENCE_API_TOKEN
// (and the JIRA_* trio). One instance per Atlassian site. This sidesteps
// the official remote MCP's known multi-site OAuth collision bug
// (atlassian/atlassian-mcp-server#23, microsoft/vscode#293533).

import { launchProfile } from "../lib/playwright-launcher.mjs";
import { ask, askSecret } from "../lib/prompt.mjs";
import { upsert } from "../lib/workspaces-store.mjs";

export async function probe({ label }) {
  const wsLabel = label || (await ask("Atlassian site label (e.g. 'acme'): "));
  if (!wsLabel) throw new Error("site label is required");

  const siteUrl = await ask("Site URL (e.g. https://acme.atlassian.net): ");
  if (!/^https:\/\/[^/]+\.atlassian\.net\/?$/.test(siteUrl)) {
    throw new Error("Expected an https://<tenant>.atlassian.net URL");
  }

  const email = await ask("Atlassian account email: ");
  if (!email.includes("@")) throw new Error("Expected an email address");

  process.stdout.write(
    `\nLaunching Chrome with an isolated profile for atlassian/${wsLabel}.\n` +
    `Sign in, then create an API token at the page that opens.\n\n`,
  );

  const { close } = await launchProfile({
    service: "atlassian",
    workspace: wsLabel,
    startUrl: "https://id.atlassian.com/manage-profile/security/api-tokens",
  });

  const token = await askSecret("Paste the API token (input hidden): ");
  await close();

  if (!token) throw new Error("API token is required");

  const baseUrl = siteUrl.replace(/\/$/, "");
  return upsert({
    service: "atlassian",
    label: wsLabel,
    kind: "atlassian-api-token",
    credentials: {
      CONFLUENCE_URL: `${baseUrl}/wiki`,
      CONFLUENCE_USERNAME: email,
      CONFLUENCE_API_TOKEN: token,
      JIRA_URL: baseUrl,
      JIRA_USERNAME: email,
      JIRA_API_TOKEN: token,
    },
    profileDir: "",
  });
}

if (import.meta.url === `file://${process.argv[1]}`) {
  probe({ label: process.argv[2] }).then(
    (e) => { process.stdout.write(`Persisted atlassian site ${e.label}\n`); process.exit(0); },
    (e) => { process.stderr.write(`${e.message}\n`); process.exit(1); },
  );
}
