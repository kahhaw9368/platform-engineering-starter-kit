---
name: platform-metrics
description: Answer platform adoption and health questions from git + CloudWatch — teams onboarded, services on golden path, deploys per week, services actually alive. Use when the Platform Team asks about adoption, usage, platform metrics, or during the metrics-review ritual.
---

# Platform Metrics (derived — ADR-0011)

Answer adoption questions by COUNTING WHAT EXISTS. No metrics database; git and CloudWatch are
the sources. Always distinguish onboarded from actually-using (the 80/30 trap).

## The queries

Run these against the GitOps repo checkout (clone/pull it first if needed):

- **Teams onboarded**: count `teams/*/team.yaml` files. List names.
- **Services on golden path**: count `teams/*/*/web-service.yaml`. Group by team.
- **Template versions in fleet**: grep rendered instances for their template annotation, or
  cross-reference scaffold PRs; report version spread (0.x fleet = early-adopter platform).
- **Deploys/week**: `git log --since=<period> --oneline -- 'teams/**'` — count tag-bump commits
  (CI-authored) vs. promotion commits (touching *.prod.yaml). Report both.
- **Services ALIVE** (the trap check): for each service, CloudWatch log group
  `/platform/team-<team>/<service>` — events in last 7 days? (`aws logs describe-log-streams`
  / `filter-log-events`). Alive = logs flowing. Report alive/total ratio next to the onboarded
  count, always together, e.g. "8 teams onboarded; 12 of 19 services alive in the last week".
- **Alarm posture**: `aws cloudwatch describe-alarms --alarm-name-prefix team-` — how many in
  ALARM state right now.

## Report format

Lead with the two numbers that matter (onboarded vs. alive), then the table, then ONE observed
trend ("payments team stopped deploying 3 weeks ago — discovery conversation?"). Numbers
without a suggested question are just decoration.

## Rules

- Read-only everywhere. Never write to CloudWatch, never touch the GitOps repo state.
- If a number can't be derived (e.g. no CloudWatch access from this machine), say exactly that
  and what access would fix it — never estimate.
- Satisfaction data (micro-survey/NPS) lives with the satisfaction ritual — point there, don't
  duplicate.
