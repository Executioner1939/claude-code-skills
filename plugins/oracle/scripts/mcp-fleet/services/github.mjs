// GitHub org probe.
//
// github/github-mcp-server consumes a PAT via GITHUB_PERSONAL_ACCESS_TOKEN.
// "Multi-workspace" for GitHub really means "multiple orgs", which can be
// served either by one PAT scoped across orgs (simpler) or one PAT per org
// (stronger blast-radius isolation). Per-org is the recommended pattern
// here -- the whole point of mcp-fleet is workspace-isolation -- and
// fine-grained PATs are scope-restrictable to a single org's resources.
//
// We open the fine-grained token creation page; the user picks the
// resource owner (the target org), grants the desired scopes, and pastes
// the resulting github_pat_xxx value back.

import { launchProfile } from "../lib/playwright-launcher.mjs";
import { ask, askSecret } from "../lib/prompt.mjs";
import { upsert } from "../lib/workspaces-store.mjs";

export async function probe({ label }) {
  const wsLabel = label || (await ask("GitHub org label (e.g. 'acme'): "));
  if (!wsLabel) throw new Error("org label is required");

  process.stdout.write(
    `\nLaunching Chrome with an isolated profile for github/${wsLabel}.\n` +
    `Sign in, then on the fine-grained PAT page set Resource owner to the\n` +
    `target org and grant whatever scopes the MCP server should expose.\n` +
    `Recommended for read-mostly use: Contents R, Issues RW, Pull requests RW,\n` +
    `Metadata R. Add Actions R/W or Administration only if you need them.\n\n`,
  );

  const { close } = await launchProfile({
    service: "github",
    workspace: wsLabel,
    startUrl: "https://github.com/settings/personal-access-tokens/new",
  });

  const token = await askSecret("Paste the PAT (github_pat_... or ghp_..., input hidden): ");
  await close();

  if (!token || !(token.startsWith("github_pat_") || token.startsWith("ghp_"))) {
    throw new Error("Expected a GitHub PAT starting with github_pat_ or ghp_");
  }

  return upsert({
    service: "github",
    label: wsLabel,
    kind: "github-pat",
    credentials: { GITHUB_PERSONAL_ACCESS_TOKEN: token },
    profileDir: "",
  });
}

if (import.meta.url === `file://${process.argv[1]}`) {
  probe({ label: process.argv[2] }).then(
    (e) => { process.stdout.write(`Persisted github org ${e.label}\n`); process.exit(0); },
    (e) => { process.stderr.write(`${e.message}\n`); process.exit(1); },
  );
}
