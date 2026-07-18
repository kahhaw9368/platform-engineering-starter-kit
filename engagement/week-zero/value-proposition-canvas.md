# Value Proposition Canvas — CMS Team

Fill against the FIRST 1-3 Dev Teams' concrete pains (criteria #1). Generic pains ("we want
DevOps") are not accepted — the facilitator will push for recent, specific episodes.

Filled during week-zero session, 2026-07-17.

## Customer profile (the Dev Teams)

**First team**: CMS Team — newly formed, building the new **microsite product**.
Stack: TypeScript / Node.js, RDS database. Container experience: some (images yes,
manifests no). CI: GitHub Actions.

**Jobs to be done** (what they're trying to accomplish):
- Ship the microsite product to production as a newly formed team
- Stand up repo, CI pipeline, and a dev environment without depending on another team
- Provision and evolve AWS resources (initially an RDS database) over the life of the service

**Pains** (concrete recent episodes, with time/cost when possible):
- **≥1 week wait** for the DevOps team to review + approve any AWS resource provisioning
  request before work can start
- **The wait repeats for every subsequent resource** — a new AWS resource mid-project
  (e.g. additional compute, a database change) goes back through the same ~1-week queue.
  Pain is recurring, not just day-zero. (Classic blocked/ticket-queue quadrant, criteria #3.)
- Newly formed team: no inherited infra knowledge; a manifests-from-scratch path would add
  cognitive load they don't have budget for

**Gains** (what better looks like, measurably):
- **Repo + pipeline + running dev environment in under an hour, no ticket** (the agreed
  week-zero target — becomes a tracked metric per ADR-0011)
- Subsequent infrastructure (e.g. RDS) is a PR, not a ticket — same-day, self-service
- Microsite reaches prod = engagement definition of done (ADR-0015)

## Value map (the Platform)

**Products & services** (catalog items, in customer language):
- "Get your team a home" — `team` v0.1.0: namespace, quotas, access for your people, an
  image repository — one request, no ticket
- "Start a service" — `web-api` template v0.1.0: repo scaffold with Dockerfile, health
  probes, and a working CI pipeline ⚠️ *currently FastAPI/Python — see gaps*
- "Run it" — `web-service` v0.1.0: your container running with logs and alarms included,
  deployed by PR merge (the PR *is* the deploy)

**Pain relievers** (map 1:1 to pains above — anything unmapped gets the TVP challenge):
- 1-week approval wait → `team` + `web-api` + `web-service` are self-service via Apex;
  guardrails are pre-approved policy, so no human review queue for golden-path resources
- Recurring per-resource wait → every resource change is a PR into the GitOps repo;
  Argo syncs on merge — same-day, and prod promotion is the only human approval (ADR-0007)
- Cognitive load for a new team → golden path hides manifests; parameters only, rendered
  from the catalog (ADR-0003); Apex explains the why as it goes

**Gain creators**:
- Under-an-hour target is measured, not promised: scaffold→running time is a derived
  metric (ADR-0011), reviewed monthly with the CMS team's actual numbers

## Catalog gaps logged (for Platform Team discovery ritual — criteria #5)

1. **No database catalog item** — CMS team needs RDS; the sharpest recurring pain is
   database/resource requests, and the catalog cannot relieve it yet. Candidate: an RDS
   kro-type (ACK-based, per ADR-0004). *Highest priority gap — it maps directly to the
   validated pain.* Interim: trailblazer path (team-authored IaC in the same PR flow).
2. **No Node.js/TypeScript app template** — `web-api` is FastAPI/Python; CMS team is
   TS/Node. Candidate: `web-api-node` template implementing the same CI artifact contract
   (ADR-0005). Interim: team adapts the Dockerfile/CI from the existing template
   (trailblazer-lite; same PR checks apply).

## The one-sentence value proposition

> For the **CMS team**, who **lose a week to DevOps approval for every AWS resource they
> need, from day zero and repeatedly thereafter**, the Platform **gives them repo, pipeline,
> dev environment, and infrastructure as self-service PRs — no tickets**, unlike **the
> current request-and-wait queue**, measured by **scaffold-to-running-dev-env time
> (target: < 1 hour) and resource-change lead time (target: same day)** (ADR-0011).
