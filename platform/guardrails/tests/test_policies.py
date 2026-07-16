"""Guardrail policy suite tests (ticket T2 / issue #3). External behavior only."""

import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
POLICIES = ROOT / "platform" / "guardrails" / "policies.py"

GOOD = """\
apiVersion: apps/v1
kind: Deployment
metadata: {name: orders, namespace: team-payments}
spec:
  template:
    spec:
      containers:
        - name: app
          image: 123.dkr.ecr.us-east-1.amazonaws.com/orders:1.4.2
          resources:
            requests: {cpu: 100m, memory: 128Mi}
            limits: {cpu: 500m, memory: 256Mi}
          livenessProbe: {httpGet: {path: /healthz, port: 8080}}
          readinessProbe: {httpGet: {path: /ready, port: 8080}}
"""


def run(d: Path):
    return subprocess.run([sys.executable, str(POLICIES), str(d)],
                          capture_output=True, text=True)


def write(tmp_path, content):
    (tmp_path / "m.yaml").write_text(content)
    return tmp_path


def test_compliant_manifest_passes(tmp_path):
    r = run(write(tmp_path, GOOD))
    assert r.returncode == 0, r.stdout
    assert "0 violation(s)" in r.stdout


def test_missing_resources_fails_gr001(tmp_path):
    bad = GOOD.replace("          resources:\n            requests: {cpu: 100m, memory: 128Mi}\n            limits: {cpu: 500m, memory: 256Mi}\n", "")
    r = run(write(tmp_path, bad))
    assert r.returncode == 1 and "GR001" in r.stdout


def test_privileged_container_fails_gr002(tmp_path):
    bad = GOOD.replace("image:", "securityContext: {privileged: true}\n          image:")
    r = run(write(tmp_path, bad))
    assert r.returncode == 1 and "GR002" in r.stdout


def test_latest_tag_fails_gr003(tmp_path):
    r = run(write(tmp_path, GOOD.replace("orders:1.4.2", "orders:latest")))
    assert r.returncode == 1 and "GR003" in r.stdout


def test_untagged_image_fails_gr003(tmp_path):
    r = run(write(tmp_path, GOOD.replace("orders:1.4.2", "orders")))
    assert r.returncode == 1 and "GR003" in r.stdout


def test_missing_probes_fails_gr004(tmp_path):
    bad = GOOD.replace("          livenessProbe: {httpGet: {path: /healthz, port: 8080}}\n", "")
    r = run(write(tmp_path, bad))
    assert r.returncode == 1 and "GR004" in r.stdout


def test_missing_namespace_fails_gr005(tmp_path):
    r = run(write(tmp_path, GOOD.replace(", namespace: team-payments", "")))
    assert r.returncode == 1 and "GR005" in r.stdout


def test_invalid_yaml_fails_gr000(tmp_path):
    r = run(write(tmp_path, "kind: Deployment\n  broken indentation: [\n"))
    assert r.returncode == 1 and "GR000" in r.stdout


def test_cluster_scoped_kinds_exempt_from_namespace(tmp_path):
    r = run(write(tmp_path, "apiVersion: v1\nkind: Namespace\nmetadata: {name: team-x}\n"))
    assert r.returncode == 0, r.stdout


def test_rendered_dummy_item_passes_guardrails_dogfood(tmp_path):
    """Dog-food chain (acceptance criterion): the rendered output of a catalog
    item must pass the guardrail suite. Pins the convention that KRO instances
    carry an explicit namespace (team namespace, per ADR-0008 tenancy)."""
    render = ROOT / "platform" / "catalog" / "harness" / "render.py"
    catalog = ROOT / "platform" / "catalog" / "catalog.yaml"
    out = tmp_path / "rendered"
    r1 = subprocess.run(
        [sys.executable, str(render), "--catalog", str(catalog), "--item", "dummy-item",
         "--param", "widget_name=dogfood", "--param", "team=ci", "--out", str(out)],
        capture_output=True, text=True)
    assert r1.returncode == 0, r1.stderr
    r2 = run(out)
    assert r2.returncode == 0, r2.stdout


def test_rendered_team_item_passes_guardrails_dogfood(tmp_path):
    """Every real catalog item's render output passes guardrails (T4/#5)."""
    render = ROOT / "platform" / "catalog" / "harness" / "render.py"
    catalog = ROOT / "platform" / "catalog" / "catalog.yaml"
    out = tmp_path / "rendered"
    r1 = subprocess.run(
        [sys.executable, str(render), "--catalog", str(catalog), "--item", "team",
         "--param", "team_name=payments", "--param", "idc_group=payments-devs",
         "--out", str(out)],
        capture_output=True, text=True)
    assert r1.returncode == 0, r1.stderr
    r2 = run(out)
    assert r2.returncode == 0, r2.stdout
