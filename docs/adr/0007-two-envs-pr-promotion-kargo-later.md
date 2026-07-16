# 0007 — Two environments, APEX-assisted PR promotion; Kargo is the named growth path

## Status

Accepted (2026-07-16)

## Context

The golden path needs an environment topology and a promotion mechanism. Physical options:
separate EKS Auto Mode clusters per environment (strong blast-radius isolation) vs. namespaces in
one cluster (cheaper, weak isolation, a pattern customers painfully outgrow). Managed Argo CD
supports hub-and-spoke multi-cluster across accounts/regions with AWS handling connectivity,
removing the networking pain that traditionally argued for single-cluster setups.

Promotion options: manual PR edits, APEX-assisted PRs, or Kargo (Argo-family promotion tool:
Freight = sealed version bundle, Stages = pipeline stations, policies automate the git edits).
Kargo is powerful but is NOT a managed EKS Capability — it would be the first self-operated
component in the stack, and its payoff scales with services × releases × stages, volume the
target customer does not have at the start.

## Decision

- **Two environments in v1**: nonprod and prod, each a separate EKS Auto Mode cluster, both
  managed by one Argo CD capability (hub-and-spoke).
- **Promotion is an APEX-assisted PR**: "promote orders-service to prod" → APEX finds the tested
  image tag, opens the PR against prod config; a human approves; Argo syncs. Prod promotion
  always has a human gate.
- **Kargo is documented as the named growth path**, adopted when a customer's promotion-PR volume
  validates the need — not shipped in v1.

## Consequences

- Zero new tools to operate or teach in v1; promotion is auditable git history.
- Strong isolation between test and prod from day one; no namespace-as-environment habits to
  unlearn.
- Cost of a second cluster is accepted; Auto Mode scales nonprod down when idle.
- Retrofitting Kargo later changes only the promotion mechanism, not the GitOps architecture —
  both edit git in front of Argo CD.
- Three-environment customers (dev/staging/prod) are a documented variation, not the reference
  path.
