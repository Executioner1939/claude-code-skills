/**
 * Structurally rename the `meta.title` of a Storybook CSF3 file.
 *
 * This is the rename that bit hardest in the transcript that motivated this
 * package — a regex aimed at "the first `title:` in the file" instead landed
 * on fixture data. The locator in `parse-stories.ts` is structural, so this
 * mutator is too.
 *
 *   await renameStoryTitle("path/to/Button.stories.tsx", "Atoms/Actions/Button");
 *
 * Returns an object describing what changed, or `null` if no `meta.title`
 * was found (in which case the file is left untouched). The dry-run path
 * (default) returns the description without writing.
 */

import { readFile, writeFile } from "node:fs/promises";
import { locateMetaTitleNode } from "../parse-stories.js";

export interface RenameStoryTitleResult {
  filePath: string;
  before: string;
  after: string;
  /** Byte range of the literal contents that were (or would be) rewritten. */
  range: { start: number; end: number };
  /** True if the file was actually written. False for dry-runs. */
  written: boolean;
}

export interface RenameStoryTitleOptions {
  /** Apply the change. Defaults to `false` (dry-run). */
  apply?: boolean;
}

export async function renameStoryTitle(
  filePath: string,
  newTitle: string,
  opts: RenameStoryTitleOptions = {},
): Promise<RenameStoryTitleResult | null> {
  const node = locateMetaTitleNode(filePath);
  if (!node) return null;
  if (node.current === newTitle) {
    return {
      filePath,
      before: node.current,
      after: newTitle,
      range: { start: node.start, end: node.end },
      written: false,
    };
  }

  const source = await readFile(filePath, "utf8");
  // The locator returns the START of the literal *including* its quote,
  // and END *after* the closing quote. We splice between those bounds.
  const before = source.slice(0, node.start);
  const after = source.slice(node.end);
  const quote = source[node.start] === '"' ? '"' : source[node.start] === "'" ? "'" : "`";
  const escaped = newTitle.replace(new RegExp(quote, "g"), `\\${quote}`);
  const updated = `${before}${quote}${escaped}${quote}${after}`;

  if (opts.apply) await writeFile(filePath, updated, "utf8");

  return {
    filePath,
    before: node.current,
    after: newTitle,
    range: { start: node.start, end: node.end },
    written: Boolean(opts.apply),
  };
}
