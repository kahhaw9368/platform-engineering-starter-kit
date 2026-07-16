"""Catalog contract seam tests (ticket T1 / issue #2).

These test EXTERNAL behavior only: exit codes and rendered output of
render.py invoked as a subprocess — never its internals. This is the
pattern-setting test suite for the kit (spec: Testing Decisions).
"""

import subprocess
import sys
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parents[4]
CATALOG = ROOT / "platform" / "catalog" / "catalog.yaml"
RENDER = ROOT / "platform" / "catalog" / "harness" / "render.py"

GOOD_PARAMS = ["--param", "widget_name=orders-widget", "--param", "team=payments"]


def run(*args):
    return subprocess.run(
        [sys.executable, str(RENDER), "--catalog", str(CATALOG), *args],
        capture_output=True, text=True,
    )


def test_current_catalog_is_schema_valid_and_dummy_renders():
    r = run("--item", "dummy-item", *GOOD_PARAMS, "--check")
    assert r.returncode == 0, r.stderr
    assert "rendered 2 artifact(s)" in r.stdout


def test_rendering_is_deterministic_same_ask_same_result(tmp_path):
    """ADR-0003: same item + same parameters -> byte-identical output."""
    out1, out2 = tmp_path / "a", tmp_path / "b"
    assert run("--item", "dummy-item", *GOOD_PARAMS, "--out", str(out1)).returncode == 0
    assert run("--item", "dummy-item", *GOOD_PARAMS, "--out", str(out2)).returncode == 0
    files1 = sorted(p.relative_to(out1) for p in out1.rglob("*") if p.is_file())
    files2 = sorted(p.relative_to(out2) for p in out2.rglob("*") if p.is_file())
    assert files1 == files2 and files1
    for rel in files1:
        assert (out1 / rel).read_text() == (out2 / rel).read_text()


def test_rendered_output_substitutes_all_parameters(tmp_path):
    out = tmp_path / "out"
    r = run("--item", "dummy-item", *GOOD_PARAMS, "--param", "size=large",
            "--param", "replicas=5", "--out", str(out))
    assert r.returncode == 0, r.stderr
    text = (out / "instance.yaml").read_text()
    assert "orders-widget" in text and "payments" in text
    assert "size: large" in text and "replicas: 5" in text
    assert "{{" not in text


def test_defaults_apply_when_optional_params_omitted(tmp_path):
    out = tmp_path / "out"
    assert run("--item", "dummy-item", *GOOD_PARAMS, "--out", str(out)).returncode == 0
    text = (out / "instance.yaml").read_text()
    assert "size: small" in text and "replicas: 2" in text


def test_unknown_item_exits_3():
    r = run("--item", "no-such-thing", "--check")
    assert r.returncode == 3
    assert "unknown catalog item" in r.stderr


def test_parameter_outside_declared_surface_exits_4():
    """ADR-0003: APEX may collect ONLY the declared parameter surface."""
    r = run("--item", "dummy-item", *GOOD_PARAMS, "--param", "sneaky=1", "--check")
    assert r.returncode == 4
    assert "not in item's declared surface" in r.stderr


def test_missing_required_parameter_exits_4():
    r = run("--item", "dummy-item", "--param", "team=payments", "--check")
    assert r.returncode == 4
    assert "missing required parameter: widget_name" in r.stderr


def test_enum_violation_exits_4():
    r = run("--item", "dummy-item", *GOOD_PARAMS, "--param", "size=gigantic", "--check")
    assert r.returncode == 4


def test_pattern_violation_exits_4():
    r = run("--item", "dummy-item", "--param", "widget_name=Bad_Name!",
            "--param", "team=payments", "--check")
    assert r.returncode == 4


def test_invalid_catalog_exits_2(tmp_path):
    bad = tmp_path / "catalog.yaml"
    bad.write_text(
        "apiVersion: starterkit.aws/v1alpha1\nkind: Catalog\nitems:\n"
        "  - name: bad-version\n    kind: kro-type\n    version: not-semver\n"
        "    description: version is not semver here\n    path: types/dummy-item\n"
    )
    r = subprocess.run(
        [sys.executable, str(RENDER), "--catalog", str(bad), "--item", "bad-version", "--check"],
        capture_output=True, text=True,
    )
    assert r.returncode == 2
    assert "schema" in r.stderr.lower()


def test_duplicate_item_names_exit_2(tmp_path):
    item = ("  - name: twin\n    kind: kro-type\n    version: 0.1.0\n"
            "    description: duplicated twin item\n    path: types/dummy-item\n")
    bad = tmp_path / "catalog.yaml"
    bad.write_text("apiVersion: starterkit.aws/v1alpha1\nkind: Catalog\nitems:\n" + item + item)
    r = subprocess.run(
        [sys.executable, str(RENDER), "--catalog", str(bad), "--item", "twin", "--check"],
        capture_output=True, text=True,
    )
    assert r.returncode == 2
    assert "duplicate" in r.stderr


def test_unresolved_placeholder_in_artifact_exits_5(tmp_path):
    """An artifact referencing a parameter the item never declared must fail loudly."""
    src = tmp_path / "types" / "leaky"
    src.mkdir(parents=True)
    (src / "thing.yaml").write_text("name: {{widget_name}}\nleak: {{undeclared_param}}\n")
    cat = tmp_path / "catalog.yaml"
    cat.write_text(
        "apiVersion: starterkit.aws/v1alpha1\nkind: Catalog\nitems:\n"
        "  - name: leaky\n    kind: kro-type\n    version: 0.1.0\n"
        "    description: leaks an undeclared placeholder\n    path: types/leaky\n"
        "    parameters:\n"
        "      - {name: widget_name, type: string, description: widget name, required: true}\n"
    )
    r = subprocess.run(
        [sys.executable, str(RENDER), "--catalog", str(cat), "--item", "leaky",
         "--param", "widget_name=x", "--check"],
        capture_output=True, text=True,
    )
    assert r.returncode == 5
    assert "unresolved placeholder" in r.stderr
