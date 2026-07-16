# 0003 — APEX instantiates versioned artifacts; it never freehands manifests or IaC

## Status

Accepted (2026-07-16)

## Context

With an agent as the front door (ADR-0002), there is a spectrum for how the golden path is
actually delivered:

1. **Agent drives fixed artifacts** — templates, IaC modules, and a machine-readable catalog live
   as semver-versioned artifacts in git, owned by the Platform Team. APEX only looks up the
   catalog, collects parameters conversationally, renders the template mechanically, and opens a
   pull request. GitOps (managed Argo CD) remains the sole path to the cluster.
2. **Agent generates, guardrails validate** — APEX freehands manifests/IaC from model + skills
   knowledge; policy engines (OPA/Kyverno) and CI gates veto violations.
3. **Agent advisory only** — APEX explains; Developers execute documented commands themselves.
4. **Full agentic freedom** — APEX acts directly on AWS/cluster APIs in conversation.

The deciding concerns: supportability (the Platform Team must support what gets created),
upgradeability (fleet-wide template patches), trust for the late majority (predictable output),
governance (review the template once, not every generation), and the TT25 doom loop (more
adoption → more support load → no stability work). Freehand generation makes every service a
snowflake, even when policy-compliant.

## Decision

Option 1. **The agent is the interface, not the factory.** APEX's output space is bounded by the
catalog of versioned templates and modules the Platform Team publishes. Same ask → same result.
APEX never invents manifests, never writes IaC outside published modules' parameter surfaces, and
never applies anything to a cluster directly — all changes land as pull requests into GitOps
repos.

## Consequences

- The golden path stays golden: N instances of one known template, not N bespoke creations.
- Fleet upgrades are tractable ("all services on python-api v1.2 need patch X").
- Security/compliance review the template once; every instantiation inherits it.
- Semver on templates plugs into the adoption lifecycle (0.x = early adopters, 1.0+ = majority).
- The escape hatch is an ordinary PR outside the template — trailblazer teams can go off-path,
  owning their governance targets per the optionality principle, without APEX changing modes.
- Cost: new capabilities require the Platform Team to author/curate a template first — APEX
  cannot improvise one. This is accepted as the TVP discipline working as intended (nothing
  enters the platform without a concrete, curated need).
- The catalog format and template parameter surfaces become the kit's most important technical
  contracts.
