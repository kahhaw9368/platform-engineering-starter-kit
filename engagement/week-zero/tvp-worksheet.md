# Thinnest Viable Platform Worksheet — [Customer name]

## Optionality map (criteria #4)

| Concern | Locked / Golden-path / Open | Rationale |
|---|---|---|
| Identity & access | Locked (IdC + team RBAC) | governance target |
| Guardrail policies | Locked (GR001-005) | shared-cluster safety |
| Workload shape | Golden path (web-service type) + trailblazer PRs | |
| CI system | Open (contract, ADR-0005) | teams keep what they know |
| ...customer-specific rows... | | |

## v1 scope check (every row must cite a criterion + a concrete need from the canvas)

| Proposed inclusion | Criterion # | Concrete need (from canvas) | Verdict |
|---|---|---|---|

## Platform Skills gaps (TT25 dimension 4)

| Skill | Present? | Gap plan (coaching emphasis during engagement) |
|---|---|---|
| Product management | | |
| UX writing (docs, errors) | | |
| Customer discovery | | |
| Agile delivery | | |

## Explicitly deferred (the named graduation steps)

Kargo (promotion volume), Kyverno (admission-time compliance), DevLake (DORA at scale),
infra catalog items (RDS/S3/SQS — first growth wave). Adding anything here requires the
evidence column filled in the scope check above.
