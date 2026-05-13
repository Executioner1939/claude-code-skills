### Go ecosystem sources

Authority order for Go claims:

1. `go list -m -versions <module>` for the full version list of a
   module.
2. `https://pkg.go.dev/<module>` for rendered API docs and the
   versions tab (`https://pkg.go.dev/<module>?tab=versions`).
3. `https://proxy.golang.org/<module>/@v/list` as the registry-of-record
   for module proxy queries.
4. The module's GitHub releases / CHANGELOG for version-specific
   behaviour claims.

`go.mod` in the surrounding project is authoritative for the version
actually in use. A pinned dependency is the verification decision; do
not re-verify it.
