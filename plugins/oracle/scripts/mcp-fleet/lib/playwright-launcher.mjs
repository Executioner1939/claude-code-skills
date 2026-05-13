// Playwright wrapper that launches a fresh-or-resumed Chromium with an
// isolated --user-data-dir per (service, workspace). Headed by default --
// the user has to log in once per workspace, and OAuth providers detect
// and block headless flows.
//
// playwright-core is loaded lazily so the plugin doesn't ship node_modules.
// The first invocation prompts the user to install via npx, then re-imports.

import { profileDir } from "./profile-dir.mjs";
import { spawnSync } from "node:child_process";

let _chromium = null;

async function loadPlaywright() {
  if (_chromium) return _chromium;
  try {
    const { chromium } = await import("playwright-core");
    _chromium = chromium;
    return chromium;
  } catch {
    process.stderr.write(
      "playwright-core not found. Installing browsers via npx (one-time, ~300MB):\n",
    );
    const r = spawnSync("npx", ["-y", "playwright@latest", "install", "chromium"], {
      stdio: "inherit",
    });
    if (r.status !== 0) {
      throw new Error(
        "playwright install failed. Run manually: npx -y playwright@latest install chromium",
      );
    }
    const { chromium } = await import("playwright-core");
    _chromium = chromium;
    return chromium;
  }
}

// Launch a persistent context bound to this workspace's profile dir.
// Returns { context, page, close }. Caller is responsible for invoking
// close() -- the persistence is the whole point, so we never auto-close.
export async function launchProfile({ service, workspace, startUrl, viewport }) {
  const chromium = await loadPlaywright();
  const userDataDir = profileDir(service, workspace);
  // Chrome >=136 refuses CDP automation against the default profile dir;
  // we never use it. We also strip --enable-automation to avoid the
  // "Chrome is being controlled by automated test software" banner that
  // some OAuth providers treat as a signal to block.
  const context = await chromium.launchPersistentContext(userDataDir, {
    headless: false,
    viewport: viewport || { width: 1280, height: 900 },
    ignoreDefaultArgs: ["--enable-automation"],
    args: [
      "--no-first-run",
      "--no-default-browser-check",
      "--disable-blink-features=AutomationControlled",
    ],
  });
  const page = context.pages()[0] || await context.newPage();
  if (startUrl) await page.goto(startUrl, { waitUntil: "domcontentloaded" });
  return {
    context,
    page,
    userDataDir,
    close: async () => { try { await context.close(); } catch { /* ignored */ } },
  };
}
