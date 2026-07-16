# 0008 — Namespace-per-team tenancy via a KRO 'Team' type

## Status

Accepted (2026-07-16)

## Context

Nonprod and prod clusters are shared by all Dev Teams (ADR-0007), so the kit needs a tenancy
model. Cluster-per-team maximizes isolation but grows cost and foundation sprawl linearly with
teams. Soft tenancy (naming conventions, trust) provides no quota/RBAC guardrails — one team's
mistake becomes everyone's outage, failing the optionality principle's governance requirements.

## Decision

**Namespace-per-team**, provisioned as a golden-path artifact: a KRO `Team` type that expands to
namespace(s), resource quotas, RBAC bindings, IAM Identity Center group mapping, ECR
repositories, and the team's folder in the GitOps repo. Onboarding a Dev Team is itself an
APEX-instantiable catalog item.

## Consequences

- Teams see and touch only their own services; quotas cap blast radius on shared clusters.
- "Onboard a team" becomes a measurable, self-service golden path — directly feeding the
  adoption metric (ratio of teams onboarded) from the criteria framework.
- Identity flows one way: IAM Identity Center groups → cluster RBAC — consistent with managed
  Argo CD's IdC SSO integration; no parallel identity system.
- Teams needing hard isolation later (compliance workloads) graduate to dedicated clusters as a
  documented variation; the managed Argo hub already handles multi-cluster.
