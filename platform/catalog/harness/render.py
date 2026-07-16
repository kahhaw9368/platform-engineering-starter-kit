#!/usr/bin/env python3
"""Catalog render harness — the kit's primary test seam.

Given a catalog item + parameters, produce the rendered artifacts (the PR
content APEX would open). Deterministic by construction (ADR-0003): same
item + same parameters -> byte-identical output. No model, no network.

Rendering is mechanical substitution only — {{param_name}} placeholders in
the item's artifact files. Anything more creative belongs in the artifact,
not the renderer.

Usage:
    render.py --catalog <catalog.yaml> --item <name> \
              [--param key=value ...] [--out <dir>] [--check]

Exit codes: 0 ok; 2 catalog invalid; 3 unknown item; 4 parameter error;
5 unresolved placeholder in rendered output.
"""

import argparse
import json
import re
import sys
from pathlib import Path

import yaml
from jsonschema import Draft202012Validator

PLACEHOLDER = re.compile(r"\{\{([a-z][a-z0-9_]*)\}\}")
SCHEMA_PATH = Path(__file__).resolve().parent.parent / "schema" / "catalog-schema.json"


def fail(code: int, msg: str) -> "NoReturn":
    print(f"error: {msg}", file=sys.stderr)
    sys.exit(code)


def load_catalog(catalog_path: Path) -> dict:
    """Load and schema-validate the catalog index. Exit 2 on any violation."""
    try:
        catalog = yaml.safe_load(catalog_path.read_text())
    except yaml.YAMLError as e:
        fail(2, f"catalog is not valid YAML: {e}")
    schema = json.loads(SCHEMA_PATH.read_text())
    errors = sorted(Draft202012Validator(schema).iter_errors(catalog), key=str)
    if errors:
        for e in errors:
            print(f"catalog schema violation at /{'/'.join(map(str, e.path))}: {e.message}",
                  file=sys.stderr)
        fail(2, f"catalog failed schema validation ({len(errors)} violation(s))")
    names = [i["name"] for i in catalog["items"]]
    dupes = {n for n in names if names.count(n) > 1}
    if dupes:
        fail(2, f"duplicate item names in catalog: {sorted(dupes)}")
    return catalog


def resolve_item(catalog: dict, catalog_path: Path, name: str) -> tuple[dict, Path]:
    """Find the item and its artifact directory. Exit 3 if either is missing."""
    item = next((i for i in catalog["items"] if i["name"] == name), None)
    if item is None:
        known = ", ".join(i["name"] for i in catalog["items"])
        fail(3, f"unknown catalog item {name!r} (catalog has: {known})")
    src = catalog_path.parent / item["path"]
    if not src.is_dir():
        fail(3, f"item {name!r} declares path {item['path']!r} but {src} is not a directory")
    return item, src


def validate_params(item: dict, given: dict) -> dict:
    """Check given parameters against the item's declared surface (ADR-0003:
    APEX may collect ONLY these). Apply defaults. Exit 4 on violations."""
    surface = {p["name"]: p for p in item.get("parameters", [])}
    unknown = set(given) - set(surface)
    if unknown:
        fail(4, f"parameters not in item's declared surface: {sorted(unknown)}")
    resolved = {}
    for pname, spec in surface.items():
        if pname in given:
            raw = given[pname]
        elif "default" in spec:
            raw = spec["default"]
        elif spec.get("required"):
            fail(4, f"missing required parameter: {pname}")
        else:
            continue
        if spec["type"] == "integer":
            try:
                raw = int(raw)
            except (TypeError, ValueError):
                fail(4, f"parameter {pname} must be an integer, got {raw!r}")
        elif spec["type"] == "boolean":
            if isinstance(raw, str):
                if raw.lower() not in ("true", "false"):
                    fail(4, f"parameter {pname} must be true/false, got {raw!r}")
                raw = raw.lower() == "true"
        elif spec["type"] == "enum":
            if raw not in spec.get("values", []):
                fail(4, f"parameter {pname} must be one of {spec.get('values')}, got {raw!r}")
        elif spec["type"] == "string":
            pat = spec.get("pattern")
            if pat and not re.fullmatch(pat, str(raw)):
                fail(4, f"parameter {pname}={raw!r} does not match pattern {pat!r}")
        resolved[pname] = raw
    return resolved


def render_tree(src: Path, params: dict) -> dict[str, str]:
    """Mechanically substitute {{param}} in every artifact file.
    Returns {relative_path: content}. Exit 5 if any placeholder survives."""
    rendered, unresolved = {}, []
    SKIP_DIRS = {"__pycache__", ".git", ".venv", "node_modules"}
    SKIP_SUFFIXES = {".pyc", ".pyo"}
    SKIP_NAMES = {".DS_Store"}
    for f in sorted(src.rglob("*")):
        if not f.is_file():
            continue
        if (set(f.parts) & SKIP_DIRS or f.suffix in SKIP_SUFFIXES
                or f.name in SKIP_NAMES):
            continue
        rel = str(f.relative_to(src))
        # Parameters may also appear in file/dir names (e.g. {{service_name}}.yaml)
        rel = PLACEHOLDER.sub(lambda m: str(params.get(m.group(1), m.group(0))), rel)
        text = f.read_text()
        text = PLACEHOLDER.sub(lambda m: str(params.get(m.group(1), m.group(0))), text)
        for m in PLACEHOLDER.finditer(text):
            unresolved.append(f"{rel}: {{{{{m.group(1)}}}}}")
        rendered[rel] = text
    if unresolved:
        for u in unresolved:
            print(f"unresolved placeholder — {u}", file=sys.stderr)
        fail(5, "rendered output contains unresolved placeholders")
    return rendered


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--catalog", type=Path, required=True)
    ap.add_argument("--item", required=True)
    ap.add_argument("--param", action="append", default=[], metavar="KEY=VALUE")
    ap.add_argument("--out", type=Path, help="write rendered artifacts here")
    ap.add_argument("--check", action="store_true",
                    help="validate + render in memory, write nothing")
    args = ap.parse_args()

    given = {}
    for kv in args.param:
        if "=" not in kv:
            fail(4, f"--param must be KEY=VALUE, got {kv!r}")
        k, _, v = kv.partition("=")
        given[k] = v

    catalog = load_catalog(args.catalog)
    item, src = resolve_item(catalog, args.catalog, args.item)
    params = validate_params(item, given)
    rendered = render_tree(src, params)

    if args.out and not args.check:
        for rel, content in rendered.items():
            dest = args.out / rel
            dest.parent.mkdir(parents=True, exist_ok=True)
            dest.write_text(content)
    print(f"ok: {item['name']}@{item['version']} rendered {len(rendered)} artifact(s)"
          + (f" -> {args.out}" if args.out and not args.check else " (check mode)"))


if __name__ == "__main__":
    main()
