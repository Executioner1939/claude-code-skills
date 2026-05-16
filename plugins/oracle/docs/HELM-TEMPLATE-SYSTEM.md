# Oracle Helm-style template system

Oracle ships a values-driven Jinja2 renderer that produces skill, agent, command, and hook bodies from templates plus a layered configuration tree. The model is borrowed directly from Helm: a `values.yaml` baseline plus per-environment overlays, validated against a JSON Schema, rendered through Jinja2 partials, with a lockfile that records the fingerprint of every input so drift can be detected without re-rendering.

This document describes the system as it stands at oracle 0.5.0. As of that version the scaffold is built but only `templates/fragments/*` are populated — the production templates (`templates/skills/<name>/SKILL.md.j2`, `templates/agents/<name>.md.j2`, etc.) have not been authored yet. The renderer runs end-to-end (`.render.lock.yaml` records a successful test render against `/private/tmp/oracle-test-all-three`) but the operational components (`skills/*/SKILL.md`, `agents/*.md`, etc.) are currently hand-authored, not produced by the renderer.

## Why a Helm-style renderer

Three problems a flat hand-authored plugin cannot solve:

1. **Per-project parameterisation.** A Rust monorepo wants the verification cascade to cite docs.rs and lib.rs; a Python project wants pypi.org and ReadTheDocs. Hand-authored skills have to embed every ecosystem; templated skills include a fragment based on `project.language`.
2. **Per-project intensity.** A learning project wants loose verification; a production-critical refactor wants strict. The Helm scaffold lets the same skill body declare three strictness presets and select one at render time.
3. **Drift detection.** When a user installs oracle into multiple projects, each project may carry different settings. The lockfile records the exact inputs that produced the current rendered bodies, so `/oracle:check` can announce "the rendered skills do not match your current values — re-render?".

## File layout

| Path | Role |
|---|---|
| `values.yaml` | Shipped defaults. Committed. Source of truth for every override layer's starting point. |
| `values.schema.json` | JSON Schema 2020-12. Validates the merged values before render. |
| `scripts/oracle-render.py` | The renderer CLI. Hard deps: PyYAML, Jinja2. Soft dep: jsonschema (skipped with a warning if missing unless `--strict-schema`). |
| `templates/fragments/_*.md` | Jinja partials. Never rendered to outputs — only included from other templates. Names prefixed with `_` by convention. |
| `templates/{skills,agents,commands,hooks}/...` | Production templates. **Currently empty.** Designed for `templates/<bucket>/<name>/...j2` (skills) or `templates/<bucket>/<name>.j2` (flat buckets). |
| `.render.lock.yaml` | Plugin-tree lockfile. Written by the renderer; records the fingerprint and per-output SHA256. |
| `.oracle/.lock.yaml` (in the consuming project) | Mirror of `.render.lock.yaml`, written to the project root so `/oracle:*` slash commands can detect drift without touching the plugin tree. |
| `~/.claude/oracle/values.yaml` (machine-wide) | Optional user-level overrides. Applied between defaults and project overrides. |
| `<project>/.oracle/values.yaml` | Per-project overrides. Committable. |

## The values layering model

The renderer merges four layers, right-biased. The deepest layer (defaults) is always present; the others are optional.

```
plugins/oracle/values.yaml                  # 1. defaults (committed in plugin)
  +
~/.claude/oracle/values.yaml                # 2. machine-wide user overrides
  +
<cwd>/.oracle/values.yaml                   # 3. per-project overrides
  +
--values FILE ...                           # 4. ad-hoc overlays (CLI flag)
```

`deep_merge` in `scripts/oracle-render.py:60` is right-biased and recursive on dicts; lists are replaced wholesale rather than concatenated. The result is then passed through `resolve_doc_registry` (`scripts/oracle-render.py:69`), which expands `project.doc_registry: auto` to a per-language list (rust → docs.rs, crates.io, lib.rs, this-week-in-rust.org, etc.), and validated against `values.schema.json`.

## Schema validation

`values.schema.json` is JSON Schema draft 2020-12 with `additionalProperties: false` enforced at every object level. Practically: every key in the merged values must be one the schema knows about, every required key must be present, and every constrained value must be in its allowed set.

The validator runs in `validate_schema` (`scripts/oracle-render.py:84`). Without `--strict-schema`, missing `jsonschema` library produces a warning and the render continues — useful in stripped-down environments. With `--strict-schema`, the absence of `jsonschema` is fatal.

The schema's enums are the safety net for new contributors authoring templates: a template that references `{{ project.language }}` is guaranteed to receive one of `rust | typescript | python | go | multi`, never an arbitrary string.

## The renderer

`scripts/oracle-render.py` discovers templates under `templates/skills/`, `templates/agents/`, `templates/commands/`, and `templates/hooks/`. The mapping rules per bucket:

| Bucket | Path shape | Template → output |
|---|---|---|
| `skills` | `<name>/SKILL.md.j2` | `templates/skills/verify/SKILL.md.j2` → `skills/verify/SKILL.md` |
| `agents` | flat | `templates/agents/canon-reader.md.j2` → `agents/canon-reader.md` |
| `commands` | flat | `templates/commands/init.md.j2` → `commands/init.md` |
| `hooks` | flat | `templates/hooks/inject-protocol.sh.j2` → `hooks/inject-protocol.sh` (rendered output gets mode 0755) |

Templates with no `.j2` source are left alone — the renderer is **additive**, not destructive. That means a hand-authored skill at `skills/foo/SKILL.md` survives an `oracle-render` invocation unchanged; only paths with a `.j2` source are written.

The Jinja2 environment uses `StrictUndefined` (`scripts/oracle-render.py:177`), which means any template referencing a values key that does not exist after merge will fail loudly rather than silently render empty. Paired with the JSON Schema this gives end-to-end safety: schema rejects invalid values, StrictUndefined rejects template typos.

`trim_blocks` and `lstrip_blocks` are on, which is the Helm-style "tidy whitespace" default. `keep_trailing_newline` is on so rendered Markdown ends with a single newline.

### Writing only changed files

`write_if_changed` (`scripts/oracle-render.py:151`) compares the rendered body to the existing file. If they match, the file is left untouched and its mtime is preserved. This matters for two reasons: (1) it makes `git diff` after a render meaningful — only the components actually affected by the values change appear in the diff; (2) the script hash in the lockfile is stable across no-op re-renders.

## Lockfiles and the `--check` mode

`fingerprint_inputs` (`scripts/oracle-render.py:131`) computes a SHA256 over: the plugin's `values.yaml`, any active user/project values, any `--values` overlay files, and every file under `templates/` (including fragments). The hash is the cache key for the entire render.

The renderer writes two lockfiles per successful run:

- `<plugin_dir>/.render.lock.yaml` — what the plugin tree was rendered to. Includes `rendered_for` (the project cwd), the input fingerprint, the merged values, and a per-output-file SHA256.
- `<cwd>/.oracle/.lock.yaml` — same content, mirrored to the consuming project. `/oracle:*` slash commands can read this without needing to know where the plugin is installed.

`--check` re-computes the fingerprint and compares against the lockfile, exiting 0 if clean and 2 if drift is detected. The two drift causes are tracked separately:

- `rendered_for` mismatch — the lockfile was produced for a different project.
- `input_fingerprint` mismatch — the inputs (values, templates, overlays) have changed since the last render.

This makes `--check` suitable as a CI gate: "PR may not merge if oracle's rendered components have drifted from `values.yaml`".

## Template authoring

A template can include any fragment with the standard Jinja `{% include %}` directive:

```jinja
{% include "fragments/_ecosystems/" + project.language + ".md" %}

{% include "fragments/_verification-strictness/" + verification.strictness + ".md" %}

{% include "fragments/_cite-sources.md" %}
```

The path is relative to the `templates/` root (the Jinja `FileSystemLoader` base). The fragments themselves can reference values directly — e.g. `templates/fragments/_cite-sources.md` reads `{{ verification.citation_format }}` and emits the per-format example.

Available fragments (oracle 0.5.0):

- `_cite-sources.md` — citation discipline block. Reads `verification.citation_format` and `verification.forbid_speculation`.
- `_rate-limit-etiquette.md` — budget-tier explanation. Reads `budget.monthly_credits` and the four threshold fields.
- `_ecosystems/{rust,typescript,python,go,multi}.md` — per-language authoritative-source ladder.
- `_verification-strictness/{loose,standard,strict}.md` — per-strictness verdict rules.

## CLI surface

```
oracle-render [--plugin-dir DIR] [--cwd DIR] [--values FILE]...
              [--out-dir DIR] [--dry-run] [--strict-schema] [--check]
```

| Flag | Effect |
|---|---|
| `--plugin-dir DIR` | Override the plugin location (default: parent of the script). |
| `--cwd DIR` | Override the consuming project root (default: cwd). The project's `.oracle/values.yaml` is sourced from here. |
| `--values FILE` | Repeatable. Extra overlay applied last, after project overrides. |
| `--out-dir DIR` | Render to a different directory rather than in-place. Useful for previewing without touching `plugins/oracle/skills/`. |
| `--dry-run` | Report would-be changes, write nothing. |
| `--check` | Exit 0 if the lockfile fingerprint matches current inputs; exit 2 if drift is detected. Implies `--dry-run`. |
| `--strict-schema` | Fail if `jsonschema` is not importable (default: warn and proceed). |

Exit codes: 0 on render success or clean `--check`; 1 on hard error (missing files, render exception, schema violation); 2 on drift detected by `--check`.

## What is not yet wired

Three loose ends in oracle 0.5.0:

1. **No production templates.** `templates/skills/`, `templates/agents/`, `templates/commands/`, `templates/hooks/` are absent. The 12 skills, 5 agents, 1 command, and 7 hooks under `skills/`, `agents/`, `commands/`, `hooks/` are hand-authored and do not pass through the renderer. The Helm machinery is therefore not enforcing any of the values-driven parameterisation it was built for.
2. **No slash-command driver.** There is no `/oracle:apply` or `/oracle:render` that runs the renderer for the user. Today the renderer is invoked manually: `python3 plugins/oracle/scripts/oracle-render.py`.
3. **`mcp_fleet.services` is in the schema but no MCP-fleet template consumes it.** The `mcp_fleet/` skill body is hand-authored and ignores the values.

These are not bugs — they are the natural next steps once the scaffold is judged worth investing in. The companion `RE-ARCHITECTURE.md` proposes a sequenced plan to author the production templates and promote the renderer to the load-bearing build system for the plugin.

## Sources and prior art

The model is taken from Helm's chart-rendering pipeline: a `values.yaml` baseline, a `values.schema.json`, a `templates/` tree of Go templates, and partials prefixed with `_`. The Jinja2 substitution and the `StrictUndefined` posture mirror Helm's `--strict` rendering mode. The drift-detection lockfile borrows from Terraform's state file rather than Helm directly.

- Helm chart values and partials: <https://helm.sh/docs/chart_template_guide/values_files/>
- Jinja2 `StrictUndefined`: <https://jinja.palletsprojects.com/en/stable/api/#jinja2.StrictUndefined>
- JSON Schema draft 2020-12: <https://json-schema.org/draft/2020-12/release-notes>
