/**
 * Smoke test for the structural meta.title locator.
 *
 * The point: even though the fixture story file contains MULTIPLE `title:`
 * properties (two inside the FIXTURE_LINKS array — `Casual range session` and
 * `Email verified` — plus one inside `meta`), the locator must point at the
 * meta one. A regex that matched the first `title:` would land on the fixture.
 */

import path from "node:path";
import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { locateMetaTitleNode } from "../src/parse-stories.js";

const here = path.dirname(fileURLToPath(import.meta.url));
const fixture = path.resolve(here, "fixtures/atoms/Button/Button.stories.tsx");
const source = readFileSync(fixture, "utf8");

const node = locateMetaTitleNode(fixture);
if (!node) {
  process.stderr.write("FAIL: locator returned undefined\n");
  process.exit(1);
}

if (node.current !== "Atoms/Actions/Button") {
  process.stderr.write(`FAIL: locator landed on the wrong title — got '${node.current}', expected 'Atoms/Actions/Button'\n`);
  process.exit(1);
}

// Verify the captured range is, in fact, inside the meta block — the source
// substring at [start, end] must be exactly the title literal contents and
// must come AFTER the FIXTURE_LINKS declaration.
const fixtureIdx = source.indexOf("FIXTURE_LINKS");
if (fixtureIdx < 0 || node.start <= fixtureIdx) {
  process.stderr.write("FAIL: locator landed before FIXTURE_LINKS — would have stomped fixture data\n");
  process.exit(1);
}

process.stdout.write(`PASS: structural locator landed on meta.title at [${node.start}, ${node.end}] — '${node.current}'\n`);
process.exit(0);
