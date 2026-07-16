# 0006 — Observability is baked into every KRO type, not opt-in

## Status

Accepted (2026-07-16)

## Context

The kit's observability substrate is CloudWatch (Container Insights). The question: how does
observability reach a Developer's service? Opt-in module (thinner default, but Developers must
know to ask — a discoverability risk that compounds with the TUI-only front door, ADR-0002), or
cluster-level-only (Platform Team sees the fleet; Developers see nothing app-specific), or baked
into the golden-path types.

## Decision

Every golden-path KRO type (e.g. `WebService`) expands to include its observability by default:
CloudWatch dashboard, baseline alarms, log and metric collection. A Developer gets observability
by deploying, with zero extra asks.

## Consequences

- Criteria #6 (SaaS-grade DevEx): "deploy → see your service's health" with no additional steps.
- APEX can answer "how is my service doing?" by reading CloudWatch for any golden-path service —
  a key conversational capability of the front door.
- Baseline dashboards/alarms are curated once by the Platform Team in the ResourceGraphDefinition
  and inherited by every instance; fleet-wide observability improvements ship as type version
  bumps.
- Cost: every service carries CloudWatch spend by default. Accepted — invisible services cost
  more in incidents than dashboards cost in dollars. Type parameters may expose a verbosity knob
  later if customers need it.
