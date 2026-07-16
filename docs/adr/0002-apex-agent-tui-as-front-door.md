# 0002 — APEX agent (TUI via Claude Code) as the Platform's front door, not a web portal

## Status

Accepted (2026-07-16)

## Context

Internal developer platforms conventionally use a web portal (typically Backstage) as the front
door: service catalog, scaffolder forms, docs. Backstage is powerful but is famously a product in
itself — it requires its own team, plugins, upgrades, and hosting, which contradicts this kit's
Thinnest Viable Platform principle and its target customer (a newly formed Platform Team with no
platform-operations experience).

The alternative considered: **APEX** (Agentic Platform Engineering eXperience) — a TUI/agent
experience delivered as a custom agent invoked via Claude Code, equipped with curated APEX Skills
(aws-samples/sample-apex-skills), through which Developers access templates, the catalog, golden
paths, and infra provisioning conversationally.

Note: the APEX Skills repo's own `eks-platform-engineering` skill recommends Backstage as the
portal layer. This kit deliberately deviates; the skills equipped to the APEX agent must be
curated/overridden so the agent does not recommend a stack that contradicts this ADR.

## Decision

The Platform's front door is the **APEX agent (TUI)**. The kit ships no web portal; Backstage is
explicitly out of scope for the golden path.

## Consequences

- No portal infrastructure to operate — consistent with TVP and EKS Auto Mode's "operate almost
  nothing" posture.
- The conversational interface can interview Developers like a good platform engineer would
  (smart defaults, trade-off explanations, composition of multiple capabilities in one request).
- **Discoverability risk**: a portal shows what exists; an agent must be asked. The catalog must
  be first-class and browsable through APEX ("what can I do here?") to compensate.
- **Late-majority risk**: less adventurous Developers may trust a UI more than an agent. Adoption
  work (docs, demos, success stories) must address this segment explicitly.
- Requires every customer Developer to have Claude Code (or a compatible harness) available —
  a real prerequisite the week-zero assessment must check.
- APEX Skills must be curated against this kit's ADRs before being equipped (they currently
  recommend Backstage/Keycloak/self-managed ArgoCD in places).
