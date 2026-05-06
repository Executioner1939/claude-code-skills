#!/usr/bin/env node
// Bin entry — calls into the compiled CLI (or the tsx-loaded source in dev).
// We keep this thin so `pnpm install --bin` produces a small wrapper.

import { fileURLToPath } from "node:url";
import path from "node:path";
import { existsSync } from "node:fs";

const here = path.dirname(fileURLToPath(import.meta.url));
const compiled = path.resolve(here, "..", "dist", "cli.js");
const sourceTs = path.resolve(here, "..", "src", "cli.ts");

async function main() {
  if (existsSync(compiled)) {
    const mod = await import(compiled);
    return mod.run(process.argv);
  }
  // Dev path: launch via tsx if it's available.
  try {
    await import("tsx/esm");
    const mod = await import(sourceTs);
    return mod.run(process.argv);
  } catch (err) {
    process.stderr.write(
      "anvil-inspect: no compiled output and tsx not installed.\n" +
        "  Run `pnpm install` then `pnpm build` inside plugins/anvil/scripts/component-inspector/.\n",
    );
    process.exit(1);
  }
}

main().catch((err) => {
  process.stderr.write(`anvil-inspect: ${err?.stack ?? err}\n`);
  process.exit(1);
});
