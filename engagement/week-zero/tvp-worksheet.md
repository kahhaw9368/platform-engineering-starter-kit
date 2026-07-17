# Thinnest Viable Platform Worksheet — CMS Team engagement

Filled during week-zero session, 2026-07-17.

## Optionality map (criteria #4)

| Concern | Locked / Golden-path / Open | Rationale |
|---|---|---|
| Identity & access | Locked (IdC + team RBAC) | governance target; team initially proposed IAM-only, agreed to enable IdC this week (see prerequisites-checklist.md) |
| Guardrail policies | Locked (GR001-005) | shared-cluster safety |
| Workload shape | Golden path (web-service type) + trailblazer PRs | tech lead persona requires a real escape hatch — no-fight off-path is an explicit adoption condition |
| CI system | Open (contract, ADR-0005) | team already on GitHub Actions (reference) — zero porting needed |
| App language/stack | Golden path (web-api template) + adapt | template is Python/FastAPI, team is TS/Node — adapting the Dockerfile/CI is sanctioned trailblazer-lite; gap logged |
| Database (RDS) | Trailblazer only in v1 | no catalog item yet; team-authored IaC via the same PR flow, guardrails apply; top candidate for first growth wave |

## v1 scope check (every row must cite a criterion + a concrete need from the canvas)

| Proposed inclusion | Criterion # | Concrete need (from canvas) | Verdict |
|---|---|---|---|
| `team` onboarding item | #3 cognitive load | 1-week DevOps approval wait before team can start | IN |
| `web-api` app template | #6 DevEx | "repo + pipeline + dev env < 1 hour, no ticket" target | IN (team adapts to Node) |
| `web-service` deploy item | #3 self-service | recurring per-resource ticket wait; PR = deploy | IN |
| `metrics-dashboard` | #7/#8 adoption+satisfaction | under-an-hour target must be measured, not promised (ADR-0011) | IN |
| RDS catalog item | #2 TVP | validated day-one need (microsite DB) — but build on evidence, not anticipation | DEFERRED — trailblazer now; first discovery ritual decides |
| Node.js/TS template | #6 DevEx | team's actual stack | DEFERRED — adapt existing template; promote to catalog if a second TS team appears |

Scope decision: **trailblazer now, build on evidence** — thinnest path to first customer;
both gaps stay logged for the first discovery ritual (criteria #5).

## Platform Skills gaps (TT25 dimension 4)

| Skill | Present? | Gap plan (coaching emphasis during engagement) |
|---|---|---|
| Product management | ❌ | Primary coaching emphasis: value-based backlog, saying no via the TVP challenge, roadmap from measured demand — practiced in the prioritization ritual |
| UX writing (docs, errors) | ❌ | Critical given junior-heavy customer team ("no K8s jargon, no dead-end errors"). Coach: docs simplest-use-case-first, every error carries a next step (criteria #6) |
| Customer discovery | ❌ | Coach through the discovery cadence ritual: interview guides, distill needs, check against catalog — starting with the two logged gaps |
| Agile delivery | ✅ | Present — dedicated team already works iteratively; leverage as the carrier for the other three |

## Explicitly deferred (the named graduation steps)

Kargo (promotion volume), Kyverno (admission-time compliance), DevLake (DORA at scale),
infra catalog items (RDS/S3/SQS — first growth wave; **RDS is now the evidence-backed
front-runner** per the canvas). Adding anything here requires the evidence column filled
in the scope check above.
