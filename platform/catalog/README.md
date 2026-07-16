# Catalog — APEX's entire output space (ADR-0003, ADR-0014)

Semver-versioned golden-path artifacts. A Developer can only get what exists here.

- `types/` — KRO ResourceGraphDefinitions: `Team` (ADR-0008), `WebService` (ADR-0004/0006),
  `PlatformMetricsDashboard` (ADR-0011)
- `templates/web-api/` — the one v1 app template (ADR-0014)
- `catalog.yaml` — machine-readable index APEX reads (name, version, parameter surface)

Growth path (ADR-0014): standards-approved infra self-service (RDS, S3, SQS as KRO types).
