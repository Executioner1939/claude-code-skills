// Slack workspace probe.
//
// Slack's OAuth path is closed for non-Marketplace MCP apps, so we use
// the cookie-extraction approach that korotovsky/slack-mcp-server expects:
// a `d` cookie (xoxd-prefixed) plus an `xoxc-` token harvested from the
// browser session. The user logs into a single workspace inside this
// fresh Chrome profile; we then walk every cookie and pull what's needed.
//
// References:
//   https://github.com/korotovsky/slack-mcp-server -- env vars consumed:
//     SLACK_MCP_XOXC_TOKEN, SLACK_MCP_XOXD_TOKEN

import { launchProfile } from "../lib/playwright-launcher.mjs";
import { ask, askSecret, confirm } from "../lib/prompt.mjs";
import { upsert } from "../lib/workspaces-store.mjs";

export async function probe({ label }) {
  const wsLabel = label || (await ask("Slack workspace label (e.g. 'acme-prod'): "));
  if (!wsLabel) throw new Error("workspace label is required");

  process.stdout.write(
    `\nLaunching Chrome with an isolated profile for slack/${wsLabel}.\n` +
    `Sign in to the ONE Slack workspace you want to bind to this label.\n` +
    `Once you see the workspace's main view, return here and press Enter.\n\n`,
  );

  const { context, page, close } = await launchProfile({
    service: "slack",
    workspace: wsLabel,
    startUrl: "https://slack.com/signin",
  });

  await ask("Press Enter once you are signed in and the workspace is loaded ");

  const cookies = await context.cookies();
  await close();

  const dCookie = cookies.find((c) => c.name === "d" && c.domain.endsWith("slack.com"));
  if (!dCookie) {
    process.stderr.write("Could not find Slack `d` cookie. Sign-in may have failed.\n");
    const manualXoxd = await askSecret("Paste xoxd token (input hidden): ");
    const manualXoxc = await askSecret("Paste xoxc token (input hidden): ");
    return persist(wsLabel, { xoxd: manualXoxd, xoxc: manualXoxc });
  }

  // The d cookie value IS the xoxd token (Slack prefixes it during set-cookie).
  // The xoxc token is workspace-keyed and lives in the page's bootData JSON --
  // accessible via window.boot_data.api_token after the workspace loads.
  let xoxc = "";
  try {
    const { context: ctx2, page: page2, close: close2 } = await launchProfile({
      service: "slack",
      workspace: wsLabel,
      startUrl: "https://app.slack.com/client",
    });
    await page2.waitForLoadState("domcontentloaded");
    xoxc = await page2.evaluate(() => {
      // eslint-disable-next-line no-undef
      return (window.boot_data && window.boot_data.api_token) || "";
    }).catch(() => "");
    await close2();
    void ctx2;
  } catch { /* fall through to manual paste */ }

  if (!xoxc) {
    process.stderr.write(
      "Could not auto-extract xoxc token from boot_data. " +
      "Open https://app.slack.com/client in the same profile, open DevTools, " +
      "run `window.boot_data.api_token`, and paste the result here.\n",
    );
    xoxc = await askSecret("Paste xoxc token (input hidden): ");
  }

  return persist(wsLabel, { xoxd: dCookie.value, xoxc });
}

function persist(label, { xoxd, xoxc }) {
  if (!xoxd || !xoxc) throw new Error("missing xoxd or xoxc token");
  return upsert({
    service: "slack",
    label,
    kind: "slack-cookie",
    credentials: {
      SLACK_MCP_XOXD_TOKEN: xoxd,
      SLACK_MCP_XOXC_TOKEN: xoxc,
    },
    profileDir: "", // populated by upsert via service+label lookup
  });
}

// Allow `node services/slack.mjs <label>` directly for debugging.
if (import.meta.url === `file://${process.argv[1]}`) {
  probe({ label: process.argv[2] }).then(
    (e) => { process.stdout.write(`Persisted slack workspace ${e.label}\n`); process.exit(0); },
    (e) => { process.stderr.write(`${e.message}\n`); process.exit(1); },
  );
}
