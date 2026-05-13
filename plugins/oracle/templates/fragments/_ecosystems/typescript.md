### TypeScript / JavaScript ecosystem sources

Authority order for TypeScript and JavaScript claims:

1. `npm view <pkg> version` and `npm view <pkg> --json` for current
   version, repository URL, and engines field.
2. The package's own `https://www.npmjs.com/package/<pkg>` page for
   download counts and the maintainer-supplied README.
3. The package's TypeDoc-generated docs (commonly hosted under the
   maintainer's docs site or at `https://<org>.github.io/<pkg>/`).
4. The package's GitHub releases page
   `https://github.com/<org>/<pkg>/releases` for changelog entries.

For Deno, prefer `https://deno.land/x/<module>@<version>/` and the
`deno.json` import map over npm shadows.

`package.json` / `pnpm-lock.yaml` / `bun.lockb` in the surrounding
project is authoritative for the version actually in use. A pinned
dependency is the verification decision; do not re-verify it.
