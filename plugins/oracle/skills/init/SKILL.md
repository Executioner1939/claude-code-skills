---
name: init
description: Initialise the per-project oracle harness. Creates `.oracle/values.yaml` (committable per-project overrides), seeds it with sensible defaults inferred from the surrounding project (Cargo.toml -> rust, package.json -> typescript, pyproject.toml -> python, go.mod -> go, otherwise multi), then renders the harness in-place over the plugin tree using those values. Safe to re-run; idempotent. Use when first onboarding a project to oracle, or after a major upstream template change to refresh defaults.
argument-hint: "[--language rust|typescript|python|go|multi] [--strictness loose|standard|strict] [--force]"
allowed-tools: Bash, Read, Write
---

# /oracle:init

Initialise the per-project oracle harness for the current working directory.

## Value resolution model

Oracle resolves the values used to render its harness in four layers, with later layers overriding earlier ones:

1. **Defaults** -- `${CLAUDE_PLUGIN_ROOT}/values.yaml`, shipped with the plugin.
2. **Global overrides** -- `~/.claude/oracle/values.yaml`, machine-wide user preferences. Optional. If absent, this layer is skipped.
3. **Project overrides** -- `<cwd>/.oracle/values.yaml`, the file this command writes. Committable.
4. **Ad-hoc** -- `--values FILE` passed directly to `oracle-render.py` for tests / one-offs.

When (2) and (3) are both absent, the renderer uses (1) alone. This is the "default state when nothing is configured" path; no init is strictly required for oracle to function.

This command bootstraps layer (3) for the current project.

## Steps

1. **Detect project type.** Check the cwd for these files in order: `Cargo.toml` -> rust, `package.json` -> typescript, `pyproject.toml` -> python, `go.mod` -> go. If none match, default to `multi`. The user can override via `--language`.

2. **Create `.oracle/`** at the project root if it does not exist. Do not touch existing `.oracle/findings/` or `.oracle/research/`.

3. **Seed `.oracle/values.yaml`** with a heavily-commented overlay of just the keys that differ from the shipped defaults at `${CLAUDE_PLUGIN_ROOT}/values.yaml`. Minimum content:

   ```yaml
   # Per-project oracle overrides. Commit this file. The .oracle/.lock.yaml
   # next to it is render state and should be gitignored.
   project:
     language: <detected>
   ```

   If the user passed `--strictness`, also write:

   ```yaml
   verification:
     strictness: <value>
   ```

   If the file already exists and `--force` was not passed, leave it untouched and report `kept`.

4. **Register the project** in `~/.claude/oracle/projects.yaml` (the global registry the preflight hook consults). Idempotent -- if the absolute path is already listed, do nothing. The registry format is:

   ```yaml
   # ~/.claude/oracle/projects.yaml
   # Oracle project registry. The preflight hook only monitors projects
   # listed here. Hand-edit to remove entries you no longer want oracle
   # to manage; /oracle:init only adds.
   projects:
     - /abs/path/to/project1
     - /abs/path/to/project2
   ```

   If `~/.claude/oracle/projects.yaml` does not exist yet, create it with the header comment and a single-entry `projects:` list.

5. **Suggest gitignore entries** for the project's root `.gitignore` if missing:

   ```
   .oracle/.lock.yaml
   ```

   Do not auto-edit `.gitignore` -- print the recommendation and let the user decide.

6. **Run the renderer** to materialise the harness for this project:

   ```
   python3 ${CLAUDE_PLUGIN_ROOT}/scripts/oracle-render.py --cwd "$(pwd)"
   ```

   Surface its stdout verbatim. The renderer writes:
   - the rendered skill / agent / command / hook bodies in place over the plugin tree
   - `${CLAUDE_PLUGIN_ROOT}/.render.lock.yaml` (machine-wide)
   - `<cwd>/.oracle/.lock.yaml` (per-project mirror)

## Output

Report in this exact shape:

```
project root: <abspath>
detected language: <rust|typescript|python|go|multi>
.oracle/values.yaml: <created|kept|updated>
registry: <added|already-present>
gitignore recommendation: <added|already-present|skipped (no .gitignore)>
render: <renderer output>
```

## Rules

- Never overwrite `.oracle/values.yaml` without `--force`.
- Never auto-edit `.gitignore`.
- Never delete or rename existing `.oracle/findings/` or `.oracle/research/` content.
- The render step is mandatory unless the renderer dependencies are missing; if `python3 -c "import yaml, jinja2"` fails, report the missing modules and stop.
