# 0015 — Engagement definition of done: first real service in production

## Status

Accepted (2026-07-16)

## Context

The guided engagement needs an outcome promise. Options: "platform stood up" (infrastructure +
APEX installed, Platform Team trained — ends exactly where adoption risk begins), "three teams
onboarded" (proves repeatability but engagement length depends on customer org readiness,
outside AWS's control), or an outcome in between.

## Decision

A v1 engagement is done when:

1. Foundation is up (nonprod + prod Auto Mode clusters, managed Argo CD/ACK/KRO capabilities,
   IAM Identity Center wiring).
2. The Platform Team operates APEX and the Catalog (can version, publish, and support them).
3. At least one real Dev Team is onboarded via the `Team` type.
4. One real service (not a demo app) is deployed to production through the golden path.
5. The product rituals are running: metrics review (ADR-0011), discovery cadence, satisfaction
   capture (ADR-0010).

## Consequences

- The engagement's headline metric is **week-zero → first production deploy** — also the Starter
  Kit's own success metric (ADR-0011).
- The engagement ends with adoption *started*, not merely possible; the riskiest step (first
  real team, first real workload) happens with AWS in the room.
- Scaling from one team to many is explicitly the customer Platform Team's journey afterwards,
  supported by the kit's product-ritual artifacts — not an engagement obligation.
