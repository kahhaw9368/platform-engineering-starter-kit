---
name: onboard-team
description: Onboard a Dev Team to the platform — render a Team instance and open the GitOps PR. A Platform Team journey (apex-manager). Use when a platform engineer wants to onboard/add a team, grant a namespace, or bring a team onto the platform.
---

# Onboard Team

Render a `team` catalog item and open one GitOps PR. On merge: namespace, quotas, RBAC bound to
their IdC group, and an ECR repo exist (ADR-0008). This is the platform's front door for teams —
and the adoption metric's unit (ADR-0011).

**Platform Team journey.** If you are the developer-facing apex agent, don't run this:
onboarding decisions (quotas, tenancy) belong to the Platform Team. Give the user a
ready-to-paste request for the platform channel (team name + IdC group) instead.

## Process

1. **Interview** for the `team` item's declared parameters: team name (kebab-case; becomes
   namespace `team-<name>`), IdC group (the group their Developers already log in with — if
   they don't know it, that's a Platform Team question; don't guess), quotas (defaults are
   fine for most teams — explain they're per-namespace requests caps, changeable later by PR).
2. **Render** via the harness (`--item team`), **validate** via guardrails.
3. **PR** to the GitOps repo: `teams/<team>/team.yaml` + the folder structure, titled
   "Onboard team <name>". Note in the body: on merge, Argo creates the tenancy; first service
   scaffold can follow immediately.
4. **Hand back**: PR link, what exists after merge, pointer to scaffold-service as the next
   step. Micro-survey.

## Rules

- One team = one Team instance = one folder. Never batch multiple teams in one PR.
- Quota changes later are ordinary PRs editing team.yaml — mention it, teams fear "locked in".
