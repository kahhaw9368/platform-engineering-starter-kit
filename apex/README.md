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
