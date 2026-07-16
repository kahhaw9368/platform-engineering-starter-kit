# 0014 — V1 catalog: one Web API template; growth path is standards-approved infra self-service

## Status

Accepted (2026-07-16)

## Context

The catalog is APEX's entire output space (ADR-0003): a Developer can only get what a template
exists for, and every template is permanent authoring + semver maintenance work. TVP discipline
says ship the fewest artifacts that make the engagement outcome ("first service in prod",
ADR-0015 definition of done) succeed. Considered and deferred: worker/queue template (first
proof that the catalog is plural), static frontend (better served off-EKS), GenAI service
template (adds model-access prerequisites to every engagement).

The customer-validated growth direction (from the kit author's own platform-operating
experience): the most-requested ad-hoc developer need over time is **cloud infrastructure** —
RDS, S3, EC2, queues — requested per-project, fulfilled today by tickets to ops teams.

## Decision

**V1 ships one app template: a containerized Web API service** (Dockerfile, health probes,
requests/limits, GitHub Actions CI workflow per ADR-0005, `WebService` KRO instance with baked-in
observability per ADR-0006). It is the vehicle for the engagement's first-service-in-prod
outcome.

**The catalog's named growth path is standards-approved infra self-service**: each infra offering
(RDS database, S3 bucket, SQS queue, …) added as a KRO type that encodes the Platform Team's
approved standards (encryption, sizing bounds, backup policy), so Developers self-serve within
platform-approved bounds instead of filing tickets — the direct kill of the request-based
blocking anti-pattern. ACK controller coverage gates which infra items are offered (RDS/S3/
DynamoDB/SQS strong; raw EC2 is a poor Kubernetes-style fit — validate per item with the AWS
container specialist team).

## Consequences

- V1 authoring surface is minimal and the engagement stays focused on one golden path
  end-to-end.
- Catalog growth after v1 follows demand evidence (criteria #2/#5), with infra items as the
  pre-named first wave.
- A single-template catalog risks looking thin in demos; mitigated by demoing the Team type,
  promotion, and metrics as further catalog items — the catalog is plural even in v1, just not
  in app templates.
