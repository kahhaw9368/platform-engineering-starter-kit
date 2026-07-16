# web-service — the v1 golden-path workload type (ADR-0004, ADR-0006)

- `rgd-web-service.yaml` — ResourceGraphDefinition installed once by the Platform Team:
  Deployment (probes, requests/limits, no privilege escalation) + Service + CloudWatch
  LogGroup (30d retention) + baseline 5xx alarm. Observability baked in: deploy = observed.
- `instance/` — the ~15-line artifact APEX renders and PRs.

PROVISIONAL markers inside require container-specialist validation (kro schema syntax,
ACK CloudWatch/Logs controller availability, size->resources mapping mechanism).
