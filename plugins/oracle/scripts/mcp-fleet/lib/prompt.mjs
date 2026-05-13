// Minimal stdin prompt helper. Two functions: ask (echoed) and askSecret
// (echo-suppressed for pasting tokens). Avoids the readline/promises API's
// behaviour of echoing partial input on some Windows terminals.

import { stdin, stdout } from "node:process";

function write(s) { stdout.write(s); }

export function ask(question, { trim = true } = {}) {
  return new Promise((resolveP) => {
    write(question);
    let buf = "";
    const onData = (chunk) => {
      const s = chunk.toString("utf8");
      for (const ch of s) {
        if (ch === "\n" || ch === "\r") {
          stdin.removeListener("data", onData);
          stdin.pause();
          write("\n");
          resolveP(trim ? buf.trim() : buf);
          return;
        }
        buf += ch;
      }
    };
    stdin.resume();
    stdin.on("data", onData);
  });
}

export async function askSecret(question) {
  // Best-effort echo suppression. Falls back to echoed input if raw mode
  // is unavailable (e.g. piped stdin during tests). The user is told it
  // will be hidden so they know to expect that behaviour.
  if (!stdin.isTTY) return ask(question);
  write(question);
  const original = stdin.isRaw;
  stdin.setRawMode(true);
  stdin.resume();
  let buf = "";
  return await new Promise((resolveP) => {
    const onData = (chunk) => {
      const s = chunk.toString("utf8");
      for (const ch of s) {
        const code = ch.charCodeAt(0);
        if (ch === "\r" || ch === "\n") {
          stdin.removeListener("data", onData);
          stdin.setRawMode(original);
          stdin.pause();
          write("\n");
          resolveP(buf.trim());
          return;
        }
        if (code === 3) { // Ctrl-C
          stdin.setRawMode(original);
          process.exit(130);
        }
        if (code === 127 || code === 8) { // backspace
          buf = buf.slice(0, -1);
          continue;
        }
        buf += ch;
      }
    };
    stdin.on("data", onData);
  });
}

export async function confirm(question, { defaultYes = false } = {}) {
  const suffix = defaultYes ? " [Y/n] " : " [y/N] ";
  const a = (await ask(question + suffix)).toLowerCase();
  if (a === "") return defaultYes;
  return a === "y" || a === "yes";
}
