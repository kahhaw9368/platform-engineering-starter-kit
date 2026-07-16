# Guardrail Policy Suite — Changelog

Versioned platform artifact (ADR-0009). Policy changes are product changes:
announce per criteria #7 (release notes channel).

## 0.1.0 (2026-07-16)
- GR001 resource requests+limits required on workload containers
- GR002 privileged containers / privilege escalation forbidden
- GR003 image tags pinned (no :latest, no untagged)
- GR004 liveness + readiness probes required
- GR005 explicit namespace on namespaced resources
- Convention pinned: KRO instances carry team namespace (ADR-0008)
