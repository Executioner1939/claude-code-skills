/**
 * Tiny NDJSON helpers used by the archaeology pipeline.
 *
 *   - `readNdjson(stream)` yields each parsed record from an input stream.
 *     Skips blank lines; surfaces JSON parse errors with the offending line
 *     index so a malformed pipe is debuggable.
 *   - `writeNdjson(record)` writes a single record with a trailing newline.
 *
 * Pipeline-friendly:
 *
 *   anvil-inspect trees src/         # producer
 *     | anvil-inspect find-jsx --tag section  # filter
 *     | anvil-inspect paths           # sink
 */

import { createInterface, type Interface } from "node:readline";
import { Readable } from "node:stream";

export async function* readNdjson<T = unknown>(stream: Readable): AsyncGenerator<T> {
  const rl: Interface = createInterface({ input: stream, crlfDelay: Infinity });
  let lineNumber = 0;
  for await (const raw of rl) {
    lineNumber += 1;
    const line = raw.trim();
    if (!line) continue;
    try {
      yield JSON.parse(line) as T;
    } catch (err) {
      const detail = err instanceof Error ? err.message : String(err);
      throw new Error(`NDJSON parse error on line ${lineNumber}: ${detail}\n  > ${truncate(line, 200)}`);
    }
  }
}

export function writeNdjson(record: unknown, stream: NodeJS.WritableStream = process.stdout): void {
  stream.write(`${JSON.stringify(record)}\n`);
}

/** True when stdin is a pipe / redirect (i.e. we have something to read). */
export function hasStdinInput(): boolean {
  return !process.stdin.isTTY;
}

function truncate(s: string, n: number): string {
  return s.length > n ? `${s.slice(0, n - 1)}…` : s;
}
