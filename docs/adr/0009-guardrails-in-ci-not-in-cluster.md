# 0009 — Guardrails run in CI at PR time; no in-cluster admission engine in v1

## Status

Accepted (2026-07-16)

## Context

Golden-path output is safe by construction (ADR-0003: reviewed templates, bounded parameters),
but the optionality principle allows trailblazer PRs containing hand-written manifests into
shared clusters. Something must check those. Options: policy checks in the PR pipeline;
an in-cluster admission engine (Kyverno/OPA Gatekeeper); both; or human review alone.

Key facts: git PRs are the *only* path to the clusters (no direct kubectl/apply for Developers or
APEX), so PR-time checks cover every entrance. An admission engine is not a managed EKS
Capability — it would be a self-operated component with policy lifecycle to manage, and a
misconfigured admission webhook can block all deployments cluster-wide, a severe failure mode
for a novice Platform Team.

## Decision

**Guardrails live in CI, plus runtime containment from tenancy.** Every PR to a GitOps repo runs
a required, fast validation suite before merge: schema validation (e.g. kubeconform) and a small
curated policy-as-code set (resource limits required, no privileged containers, no `latest`
tags, and similar). Runtime blast radius is contained by the KRO `Team` type's quotas and RBAC
(ADR-0008). No admission engine ships in v1; it is the documented graduation step when customer
scale or compliance regimes ("nothing unscanned may ever run") validate the need.

## Consequences

- Fast, in-context feedback: Developers see which rule failed directly in the PR, before
  anything touches a cluster.
- Nothing new to operate in-cluster; the "Platform Team operates almost nothing" thesis holds.
- The policy set is a versioned platform artifact — curated once, inherited by every repo check.
- Accepted gap: PR checks can be bypassed by git admins; mitigated by branch protection on
  platform-owned repos. Admission control closes this fully when adopted later, as an additive
  layer requiring no architectural change.
- Same graduation pattern as Kargo (ADR-0007): heavier tools are named growth paths, adopted on
  validated demand, not shipped speculatively.
