#!/usr/bin/env python3
"""
Oracle harness renderer.

Layered values (right wins):
  1. <plugin_dir>/values.yaml             - shipped defaults (committed)
  2. $HOME/.claude/oracle/values.yaml     - machine-wide user overrides (optional)
  3. <cwd>/.oracle/values.yaml            - per-project overrides (committable)
  4. --values FILE ...                    - extra overlays for ad-hoc renders / tests

When (2) and (3) are both absent, the render uses (1) alone -- this is the
"default state when nothing is configured" path.

Renders Jinja2 templates in place over the plugin tree:
  templates/skills/<name>/SKILL.md.j2  -> skills/<name>/SKILL.md
  templates/agents/<name>.md.j2        -> agents/<name>.md
  templates/commands/<name>.md.j2      -> commands/<name>.md
  templates/hooks/<name>.sh.j2         -> hooks/<name>.sh           (mode 0755)

Templates that have no .j2 source are left alone -- the renderer is additive.

Lockfiles:
  <plugin_dir>/.render.lock.yaml          - rendered_for + input fingerprint
                                            + per-output SHA256
  <cwd>/.oracle/.lock.yaml                - same data, mirrored to the project
                                            so /oracle:* commands can detect drift
                                            without touching the plugin dir

Hard deps:  pyyaml, jinja2
Soft deps:  jsonschema (skipped with a warning if missing)

CLI:
  oracle-render [--plugin-dir DIR] [--cwd DIR] [--values FILE]...
                [--out-dir DIR] [--dry-run] [--strict-schema] [--check]

Exit codes:
  0 - rendered (or --dry-run / --check reports clean)
  1 - hard error (missing files, render failure, schema violation)
  2 - --check found drift (would re-render)
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
import sys
from pathlib import Path

try:
    import yaml
except ImportError:
    sys.exit("oracle-render: PyYAML is required (pip install pyyaml)")

try:
    from jinja2 import Environment, FileSystemLoader, StrictUndefined, TemplateError
except ImportError:
    sys.exit("oracle-render: Jinja2 is required (pip install jinja2)")

try:
    import jsonschema  # type: ignore
    HAS_JSONSCHEMA = True
except ImportError:
    HAS_JSONSCHEMA = False


# Output buckets. `path_shape` says how to map template-relpath -> output-relpath.
#   "skill"   -> templates/skills/verify/SKILL.md.j2   -> skills/verify/SKILL.md
#   "flat"    -> templates/agents/canon-reader.md.j2   -> agents/canon-reader.md
BUCKETS = {
    "skills":   {"out_subdir": "skills",   "path_shape": "skill"},
    "agents":   {"out_subdir": "agents",   "path_shape": "flat"},
    "commands": {"out_subdir": "commands", "path_shape": "flat"},
    "hooks":    {"out_subdir": "hooks",    "path_shape": "flat"},
}

FRAGMENTS_DIR = "fragments"   # include-only; never rendered to outputs


def deep_merge(base: dict, overlay: dict) -> dict:
    """Right-biased recursive merge. Lists are replaced wholesale."""
    out = dict(base)
    for k, v in overlay.items():
        if k in out and isinstance(out[k], dict) and isinstance(v, dict):
            out[k] = deep_merge(out[k], v)
        else:
            out[k] = v
    return out


def load_yaml(path: Path) -> dict:
    with path.open("r", encoding="utf-8") as f:
        data = yaml.safe_load(f) or {}
    if not isinstance(data, dict):
        raise SystemExit(f"oracle-render: {path} must be a YAML mapping at the root")
    return data


def resolve_doc_registry(values: dict) -> dict:
    """Expand `project.doc_registry: auto` to a per-language list."""
    auto_map = {
        "rust":       ["docs.rs", "crates.io", "lib.rs", "this-week-in-rust.org"],
        "typescript": ["npmjs.com", "deno.land", "typedoc-generated-docs"],
        "python":     ["pypi.org", "readthedocs.io"],
        "go":         ["pkg.go.dev", "proxy.golang.org"],
        "multi":      ["the language-appropriate package registry and primary doc site"],
    }
    if values.get("project", {}).get("doc_registry") == "auto":
        lang = values["project"]["language"]
        values["project"]["doc_registry"] = auto_map.get(lang, auto_map["multi"])
    return values


def validate_schema(values: dict, schema_path: Path, strict: bool) -> None:
    if not schema_path.exists():
        return
    if not HAS_JSONSCHEMA:
        msg = f"oracle-render: jsonschema not installed; skipping validation of {schema_path.name}"
        if strict:
            raise SystemExit(msg + " (--strict-schema set)")
        print(msg, file=sys.stderr)
        return
    schema = json.loads(schema_path.read_text(encoding="utf-8"))
    try:
        jsonschema.validate(values, schema)
    except jsonschema.ValidationError as e:
        path = ".".join(str(p) for p in e.absolute_path) or "<root>"
        raise SystemExit(f"oracle-render: schema violation at {path}: {e.message}")


def discover_templates(templates_dir: Path) -> list[tuple[str, Path]]:
    """Return [(bucket, template_relpath), ...] for every renderable .j2 file."""
    results = []
    for bucket in BUCKETS:
        bucket_dir = templates_dir / bucket
        if not bucket_dir.is_dir():
            continue
        for path in sorted(bucket_dir.rglob("*.j2")):
            rel = path.relative_to(templates_dir)
            results.append((bucket, rel))
    return results


def output_path_for(bucket: str, template_rel: Path, out_root: Path) -> Path:
    """Map a template relpath to its rendered destination under out_root."""
    cfg = BUCKETS[bucket]
    out_dir = out_root / cfg["out_subdir"]
    parts = template_rel.parts[1:]   # strip leading "<bucket>/"
    if cfg["path_shape"] == "skill":
        if len(parts) != 2:
            raise SystemExit(f"oracle-render: skill template {template_rel} must be <name>/SKILL.md.j2")
        skill_name, filename = parts
        return out_dir / skill_name / filename.removesuffix(".j2")
    *subdirs, filename = parts
    return out_dir.joinpath(*subdirs) / filename.removesuffix(".j2")


def fingerprint_inputs(plugin_dir: Path, global_values_path: Path | None,
                       project_values_path: Path | None,
                       extra_values: list[Path]) -> str:
    """SHA256 of every input that affects the render. Used by preflight to skip no-ops."""
    h = hashlib.sha256()
    files: list[Path] = [plugin_dir / "values.yaml"]
    if global_values_path and global_values_path.exists():
        files.append(global_values_path)
    if project_values_path and project_values_path.exists():
        files.append(project_values_path)
    files.extend(extra_values)
    templates_dir = plugin_dir / "templates"
    if templates_dir.is_dir():
        files.extend(sorted(templates_dir.rglob("*")))
    for p in files:
        if not p.is_file():
            continue
        h.update(str(p.relative_to(plugin_dir) if p.is_relative_to(plugin_dir) else p).encode("utf-8"))
        h.update(b"\0")
        h.update(p.read_bytes())
        h.update(b"\0")
    return h.hexdigest()


def render_one(env: Environment, template_rel: Path, values: dict) -> str:
    try:
        return env.get_template(str(template_rel)).render(**values)
    except TemplateError as e:
        raise SystemExit(f"oracle-render: failed to render {template_rel}: {e}")


def write_if_changed(path: Path, content: str, dry_run: bool) -> bool:
    if path.exists() and path.read_text(encoding="utf-8") == content:
        return False
    if not dry_run:
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content, encoding="utf-8")
        if path.suffix == ".sh":
            os.chmod(path, 0o755)
    return True


def main() -> int:
    parser = argparse.ArgumentParser(description="Render oracle skill/agent/command/hook templates in-place.")
    parser.add_argument("--plugin-dir", type=Path, default=Path(__file__).resolve().parent.parent,
                        help="Path to the oracle plugin (default: parent of this script).")
    parser.add_argument("--cwd", type=Path, default=Path.cwd(),
                        help="Project root whose .oracle/values.yaml supplies overrides (default: cwd).")
    parser.add_argument("--values", action="append", type=Path, default=[],
                        help="Extra values file(s), applied after plugin defaults and project overrides.")
    parser.add_argument("--out-dir", type=Path, default=None,
                        help="Override output root (default: --plugin-dir, i.e. in-place render).")
    parser.add_argument("--dry-run", action="store_true",
                        help="Report changes without writing.")
    parser.add_argument("--check", action="store_true",
                        help="Exit 0 if no re-render needed, 2 if drift detected. Implies --dry-run.")
    parser.add_argument("--strict-schema", action="store_true",
                        help="Fail if jsonschema is not installed (default: warn and continue).")
    args = parser.parse_args()

    plugin_dir: Path = args.plugin_dir.resolve()
    cwd: Path = args.cwd.resolve()
    out_root: Path = (args.out_dir or plugin_dir).resolve()
    templates_dir = plugin_dir / "templates"
    defaults_path = plugin_dir / "values.yaml"
    schema_path = plugin_dir / "values.schema.json"
    project_values = cwd / ".oracle" / "values.yaml"

    if not defaults_path.exists():
        return _die(f"missing {defaults_path}")
    if not templates_dir.is_dir():
        return _die(f"missing templates directory at {templates_dir}")

    values = load_yaml(defaults_path)
    if project_values.exists():
        values = deep_merge(values, load_yaml(project_values))
    for extra in args.values:
        values = deep_merge(values, load_yaml(extra))
    values = resolve_doc_registry(values)
    validate_schema(values, schema_path, args.strict_schema)

    fingerprint = fingerprint_inputs(plugin_dir, project_values, args.values)
    plugin_lock = plugin_dir / ".render.lock.yaml"
    project_lock = cwd / ".oracle" / ".lock.yaml"

    # --check: compare the would-be fingerprint against the existing lockfile.
    if args.check:
        existing = load_yaml(plugin_lock) if plugin_lock.exists() else {}
        same_project = existing.get("rendered_for") == str(cwd)
        same_fingerprint = existing.get("input_fingerprint") == fingerprint
        if same_project and same_fingerprint:
            print(f"oracle-render: clean (lockfile fingerprint matches, project={cwd})")
            return 0
        reason = []
        if not same_project:
            reason.append(f"project changed ({existing.get('rendered_for')!r} -> {str(cwd)!r})")
        if not same_fingerprint:
            reason.append("input fingerprint changed")
        print(f"oracle-render: drift detected ({'; '.join(reason)})", file=sys.stderr)
        return 2

    env = Environment(
        loader=FileSystemLoader(str(templates_dir)),
        undefined=StrictUndefined,
        trim_blocks=True,
        lstrip_blocks=True,
        keep_trailing_newline=True,
    )

    templates = discover_templates(templates_dir)
    if not templates:
        print("oracle-render: no templates found under templates/{skills,agents,commands,hooks}/",
              file=sys.stderr)

    statuses: list[tuple[Path, str]] = []
    rendered_index: dict[str, str] = {}
    for bucket, rel in templates:
        out = output_path_for(bucket, rel, out_root)
        body = render_one(env, rel, values)
        prior = out.read_text(encoding="utf-8") if out.exists() else None
        if prior is None:
            status = "create"
        elif prior != body:
            status = "update"
        else:
            status = "unchanged"
        if status != "unchanged":
            write_if_changed(out, body, args.dry_run)
        statuses.append((out, status))
        rendered_index[str(out.relative_to(out_root))] = hashlib.sha256(body.encode("utf-8")).hexdigest()

    lock = {
        "rendered_for": str(cwd),
        "rendered_with": str(plugin_dir),
        "out_root": str(out_root),
        "input_fingerprint": fingerprint,
        "values": values,
        "templates": rendered_index,
    }
    lock_body = yaml.safe_dump(lock, sort_keys=True, default_flow_style=False)
    if not args.dry_run:
        plugin_lock.write_text(lock_body, encoding="utf-8")
        project_lock.parent.mkdir(parents=True, exist_ok=True)
        project_lock.write_text(lock_body, encoding="utf-8")

    creates  = sum(1 for _, s in statuses if s == "create")
    updates  = sum(1 for _, s in statuses if s == "update")
    nochange = sum(1 for _, s in statuses if s == "unchanged")
    prefix   = "[dry-run] " if args.dry_run else ""
    print(f"{prefix}rendered {len(templates)} templates for project {cwd}: "
          f"{creates} created, {updates} updated, {nochange} unchanged")
    for out, status in statuses:
        if status != "unchanged":
            try:
                rel = out.relative_to(plugin_dir)
            except ValueError:
                rel = out
            print(f"  {status:>7}  {rel}")
    if not args.dry_run:
        print(f"  wrote   {plugin_lock.relative_to(plugin_dir)}")
        print(f"  wrote   {project_lock}")
    return 0


def _die(msg: str) -> int:
    print(f"oracle-render: {msg}", file=sys.stderr)
    return 1


if __name__ == "__main__":
    sys.exit(main())
