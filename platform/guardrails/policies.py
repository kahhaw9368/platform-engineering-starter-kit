#!/usr/bin/env python3
"""Guardrail policy suite (ADR-0009) — v0.1.0

Runs against a directory of rendered Kubernetes manifests. This is the
required PR check for every GitOps repo: golden-path output is dog-fooded
through it, trailblazer manifests are held to the same bar.

Policies (each maps to a criteria-#4 governance target):
  GR001  workload containers must declare resource requests and limits
  GR002  no privileged containers, no privilege escalation
  GR003  image tags must be pinned (no :latest, no untagged)
  GR004  liveness and readiness probes required on workload containers
  GR005  namespace must be set on namespaced resources (no default-ns drift)

Usage:  policies.py <dir-of-manifests> [--policy-version]
Exit:   0 all pass · 1 violations found · 2 unreadable input
"""

import sys
from pathlib import Path

import yaml

POLICY_VERSION = "0.1.0"
WORKLOAD_KINDS = {"Deployment", "StatefulSet", "DaemonSet", "Job", "CronJob"}
CLUSTER_SCOPED = {"Namespace", "ClusterRole", "ClusterRoleBinding", "CustomResourceDefinition",
                  "StorageClass", "PriorityClass", "ResourceGraphDefinition"}


def containers_of(doc: dict):
    spec = doc.get("spec", {})
    for path in (("template", "spec"), ("jobTemplate", "spec", "template", "spec")):
        pod = spec
        for key in path:
            pod = pod.get(key, {}) if isinstance(pod, dict) else {}
        if pod.get("containers"):
            return pod["containers"] + pod.get("initContainers", [])
    return []


def check_doc(doc: dict, source: str) -> list[str]:
    v = []
    kind = doc.get("kind", "")
    name = doc.get("metadata", {}).get("name", "?")
    where = f"{source} [{kind}/{name}]"

    if kind in WORKLOAD_KINDS:
        for c in containers_of(doc):
            cname = c.get("name", "?")
            res = c.get("resources", {})
            if not res.get("requests") or not res.get("limits"):
                v.append(f"GR001 {where} container {cname}: resource requests and limits required")
            sec = c.get("securityContext", {})
            if sec.get("privileged") or sec.get("allowPrivilegeEscalation"):
                v.append(f"GR002 {where} container {cname}: privileged/privilege-escalation forbidden")
            image = c.get("image", "")
            if image.endswith(":latest") or (":" not in image.split("/")[-1]):
                v.append(f"GR003 {where} container {cname}: image tag must be pinned, got {image!r}")
            if not c.get("livenessProbe") or not c.get("readinessProbe"):
                v.append(f"GR004 {where} container {cname}: liveness and readiness probes required")

    if kind and kind not in CLUSTER_SCOPED and not doc.get("metadata", {}).get("namespace"):
        v.append(f"GR005 {where}: namespace must be set explicitly")
    return v


def main() -> None:
    if "--policy-version" in sys.argv:
        print(POLICY_VERSION)
        return
    if len(sys.argv) != 2:
        print(__doc__, file=sys.stderr)
        sys.exit(2)
    target = Path(sys.argv[1])
    if not target.is_dir():
        print(f"error: {target} is not a directory", file=sys.stderr)
        sys.exit(2)

    violations, checked = [], 0
    for f in sorted(list(target.rglob("*.yaml")) + list(target.rglob("*.yml"))):
        try:
            docs = list(yaml.safe_load_all(f.read_text()))
        except yaml.YAMLError as e:
            violations.append(f"GR000 {f}: not valid YAML — {e}")
            continue
        for doc in docs:
            if isinstance(doc, dict) and doc.get("kind"):
                checked += 1
                violations.extend(check_doc(doc, str(f.relative_to(target))))

    for line in violations:
        print(f"FAIL {line}")
    print(f"guardrails v{POLICY_VERSION}: {checked} object(s) checked, "
          f"{len(violations)} violation(s)")
    sys.exit(1 if violations else 0)


if __name__ == "__main__":
    main()
