### Python ecosystem sources

Authority order for Python claims:

1. `pip index versions <pkg>` (or `uv pip index versions <pkg>`) for
   current version. `pip show <pkg>` for installed-version metadata.
2. The package's `https://pypi.org/project/<pkg>/` page for the
   maintainer-supplied README and download counts.
3. The package's docs site -- typically
   `https://<pkg>.readthedocs.io/` or the maintainer's GitHub Pages.
4. The package's GitHub releases / CHANGELOG for version-specific
   behaviour claims.

`pyproject.toml`, `requirements.txt`, `poetry.lock`, or `uv.lock` in
the surrounding project is authoritative for the version actually
in use. A pinned dependency is the verification decision; do not
re-verify it.
