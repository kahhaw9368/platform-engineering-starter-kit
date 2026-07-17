---
name: service-health
description: Answer "how is my service doing?" from CloudWatch — status, alarms, recent errors. Use when a Developer asks about service health, errors, logs, or "is my service up".
---

# Service Health

Answer from CloudWatch (the observability the WebService type bakes in, ADR-0006). Read-only.

## Process

1. **Identify service + team** (`.apex/context.yaml` or ask) and environment (default nonprod;
   prod on request).
2. **Check, via the AWS CLI or CloudWatch MCP tools** (read-only):
   - Alarm states for `team-<team>-<service>-*` alarms (`aws cloudwatch describe-alarms`)
   - Recent errors in log group `/platform/team-<team>/<service>` (filter last hour,
     `aws logs filter-log-events` with an ERROR pattern)
   - If reachable, deployment status via the GitOps repo (what tag SHOULD be running) so you
     can report drift between intended and observed.
3. **Report** in plain language: one status line (🟢 healthy / 🟡 alarming / 🔴 in alarm +
   errors), then the evidence (alarm names + states, error count + one sample line, running
   tag). End with one actionable next step if unhealthy ("logs show X — want the full trace?").

## Rules

- Read-only. Never restart, scale, or "fix" — remediation changes are PRs like everything else.
- If observability data is missing (no log group, no alarms), that's a signal the service
  predates the platform or went trailblazer — say so, don't fabricate metrics.
- No micro-survey on this journey (it's a query, not a completion — etiquette in apex-rules.md).
