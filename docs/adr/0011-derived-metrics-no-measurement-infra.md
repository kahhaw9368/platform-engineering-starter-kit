# 0011 — Metrics are derived, not built: git + CloudWatch + APEX micro-surveys in v1

## Status

Accepted (2026-07-16)

## Context

Criteria #7/#8 require measuring adoption and satisfaction from day one, but a measurement
*system* (e.g. Apache DevLake for DORA, as the APEX Skills stack teaches) is another
self-operated component with data plumbing — premature when a platform has two teams and five
services. Meanwhile, prior ADRs mean the platform already produces a complete paper trail.

## Decision

**v1 builds no measurement infrastructure.** Metrics are derived from what already exists:

- **Adoption** — count golden-path artifacts in git: `Team` instances (teams onboarded),
  `WebService` instances + template versions (services on path), PR history (deploy frequency,
  lead time). CloudWatch liveness/traffic distinguishes *onboarded* from *actually using*
  (closing the 80%-onboarded/30%-using trap).
- **Satisfaction** — APEX asks a one-tap micro-question at journey completion (scaffold,
  promotion), plus an occasional NPS prompt. Reviewed in the product rituals APEX facilitates
  (ADR-0010).
- **Surfaces** — APEX is the primary query interface (plain-language, follow-up-capable, for the
  Platform Team's own use); one CloudWatch dashboard (shipped as a KRO type) serves ambient
  viewing and leadership audiences who will not open a terminal. No custom metrics web UI.

**Two products, two funnels**: the above measures the Platform. The Starter Kit itself (AWS's
product) is measured separately: GitHub stars = awareness, forks/unique cloners = intent,
guided engagements delivered = ground-truth adoption, with week-zero → first-production-deploy
time as the kit's headline success metric.

DevLake/DORA tooling is the named growth path once history and team count make trend analytics
meaningful.

## Consequences

- Zero new components; metrics are a by-product of the architecture (ADRs 0004, 0006, 0008).
- Micro-surveys must stay rare and one-tap, or they become nagging and poison the satisfaction
  signal.
- Derived metrics are coarse (no change-failure rate, no MTTR); accepted until DevLake
  graduation.
- The kit practices what it preaches: measurement from day one without violating TVP.
