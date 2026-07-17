---
name: onboard-team
description: Onboard a Dev Team to the platform — render a Team instance and open the GitOps PR. Use when someone wants to onboard/add their team, get a namespace, or join the platform.
---

# Onboard Team

Render a `team` catalog item and open one GitOps PR. On merge: namespace, quotas, RBAC bound to
their IdC group, and an ECR repo exist (ADR-0008). This is the platform's front door for teams —
and the adoption metric's unit (ADR-0011).

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
