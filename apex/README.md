# APEX — Agentic Platform Engineering eXperience

Harness-portable agent content (ADR-0013): Claude Code = reference, Kiro CLI = supported.
Distributed via npx installer (ADR-0012). Welcome screen spec: docs/design/apex-welcome-screen.md

- `skills/` — curated skills: vendored subset of aws-samples/sample-apex-skills (overridden where
  they conflict with ADRs, e.g. no Backstage/Kargo/Argo Workflows in v1) + first-party skills:
  - [ ] platform-as-product (facilitates week-zero + rituals, ADR-0010; built from
        docs/context/platform-as-product-criteria.md)
  - [ ] scaffold-service, onboard-team, promote, service-health, verify-setup, catalog-browse
  - [ ] ci-porting (port the ADR-0005 contract to Azure DevOps/GitLab/Bitbucket)
- `steering/` — journey routing (welcome screen, slash commands)
- `rules/` — guardrail behaviors (never freehand manifests — ADR-0003; PRs only; micro-survey
  etiquette — ADR-0011)

## Implemented (T7/#8)

- `skills/catalog-browse/` — /catalog: reads catalog.yaml, presents items + parameter surfaces,
  never improvises capabilities
- `skills/verify-setup/` — /verify-setup: harness/git/forge-CLI/IdC checks with fix hints,
  read-only by design
- `rules/apex-rules.md` — identity (Apex, 24×7 platform engineer), hard rules (never freehand,
  never apply, never merge prod, declared parameters only), micro-survey etiquette
- `steering/welcome.md` — the welcome screen (UNO-derived, docs/design spec), CUSTOMIZE markers
  for per-customer lines

Kiro degradation (ADR-0013): skills + rules are plain markdown following the Agent Skills
standard — both harnesses read them; the SessionStart welcome hook is Claude Code garnish,
Kiro uses a steering include (wired in T11's installer).

## Journeys (T8/#9)

- `skills/scaffold-service/` — interview (declared params only) → render harness → guardrails →
  two linked PRs (service repo + GitOps registration)
- `skills/onboard-team/` — Team instance render → one GitOps PR → tenancy on merge
- `skills/promote/` — proven nonprod tag → prod PR touching only spec.image, human-gated;
  advisory health check in PR body; never merges
- `skills/service-health/` — read-only CloudWatch answers (alarms, errors, drift); no survey

All four end-to-end conversations are bounded by apex-rules.md hard rules; render + guardrail
mechanics are the T1/T2 seams — the skills orchestrate, the harness produces.
