# team — onboard a Dev Team (ADR-0008)

- `rgd-team.yaml` — the ResourceGraphDefinition the Platform Team installs once via GitOps
  (namespace, quotas, LimitRange defaults, read-only RBAC + IdC group binding, ACK ECR repo).
  PROVISIONAL markers inside require container-specialist validation.
- `instance/` — the ~12-line artifact APEX renders and PRs (the catalog item's render path).

Developer RBAC is read-only by design: all changes enter via GitOps PRs (ADR-0003/0004).
Team instances are the adoption-metric source (ADR-0011): teams onboarded = Team count in git.
