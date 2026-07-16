# 0005 — CI is a contract, not a component; GitHub Actions is the reference implementation

## Status

Accepted (2026-07-16)

## Context

The golden path needs code push → container image in ECR → new tag in the GitOps repo → managed
Argo CD deploys. Argo CD does not build images; something must. Options considered: ship
AWS-native CI (CodeBuild/CodePipeline), run Argo Workflows in-cluster (as the APEX Skills stack
teaches — but it is not a managed EKS Capability, so the Platform Team would operate a CI
engine, breaking the "operate almost nothing" thesis of ADRs 0001–0004), stay fully CI-agnostic
(every customer reinvents the pipeline), or define a contract with one reference implementation.

Customers' Dev Teams already have CI systems they know (GitHub Actions, GitLab CI, Azure DevOps,
Bitbucket). Replacing a working CI raises cognitive load rather than lowering it; build pipelines
are not where this kit differentiates.

## Decision

The kit defines a **CI-agnostic artifact contract** as the golden path's build-side interface:

1. Build the container image from the app template's Dockerfile
2. Push it to the service's ECR repository
3. Bump the image tag in the service's GitOps repo

App templates ship with a working **GitHub Actions** workflow as the reference implementation.
Platform Teams on other CI systems port the contract (not a sprawling pipeline) — a bounded,
mechanical task the kit supports as an agent-assisted path (APEX can help generate the equivalent
pipeline for the customer's CI). Git hosting remains customer choice; managed Argo CD's
CodeConnections integration covers GitHub, GitLab, and Bitbucket.

## Consequences

- The kit never owns or operates a CI engine; the Platform Team operates none either.
- The contract is the stable interface — CI systems can change under it without touching the
  platform.
- Porting to Azure DevOps/GitLab/Bitbucket is a supported day-one story, not a footnote — and a
  natural APEX task, keeping the agent-as-platform-engineer narrative coherent.
- GitHub-first ordering is deliberate: it is the most common baseline and pairs with the managed
  Argo CD CodeConnections integration.
- Supply-chain hardening (image signing, provenance attestation) can be added to the contract in
  a later version without changing the architecture.
