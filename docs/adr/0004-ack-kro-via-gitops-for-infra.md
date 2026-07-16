# 0004 — ACK + KRO via GitOps for all Developer-requested infrastructure

## Status

Accepted (2026-07-16)

## Context

Per ADR-0003, APEX opens PRs containing instances of Platform-Team-owned artifacts. When a
Developer requests AWS resources ("my service needs an S3 bucket"), the PR must contain an
artifact that causes real AWS resources to exist. Options considered:

- **Terraform modules** — familiar to DevOps-heritage Platform Teams, but requires a second
  delivery pipe (plan/apply executor such as Atlantis or CodeBuild) plus state management,
  locking, and drift discipline — operational load the kit promises to remove.
- **CloudFormation/CDK** — AWS-native but the weakest GitOps-native story on EKS; also a second
  pipe. Ruled out.
- **ACK + KRO via GitOps** — AWS resources declared as Kubernetes objects (ACK controllers
  reconcile them against real AWS APIs); KRO ResourceGraphDefinitions let the Platform Team
  publish one simple developer-facing custom type (e.g. `WebService`) that expands into the full
  wired graph (Deployment, Bucket, IAM role, Pod Identity, …). Argo CD, ACK, and KRO are all
  managed EKS Capabilities — AWS operates the controllers.

## Decision

**All Developer-requested infrastructure flows through one pipe: git → managed Argo CD → KRO →
ACK → AWS.** The developer-facing artifact in APEX's PRs is a single KRO custom-type instance
(~15 lines). KRO ResourceGraphDefinitions are the mechanism by which the Platform Team publishes
its curated abstractions; the catalog APEX reads is essentially the set of KRO types and their
parameter surfaces.

The foundation layer (VPC, the EKS cluster itself, IAM Identity Center — everything that must
exist before ACK has a cluster to run in) is provisioned once during the guided engagement via a
simple bootstrap stack (format TBD, low stakes). It is engagement tooling, not a platform
capability; Developers never touch it and APEX does not provision it.

## Consequences

- The full delivery chain is AWS-managed end to end (Auto Mode + managed Argo CD + managed
  ACK/KRO): the Platform Team operates no cluster machinery, no GitOps engine, no IaC executor,
  and no state files.
- Continuous reconciliation: hand-deleted resources converge back to git's declared state, unlike
  point-in-time `terraform apply`.
- The kit teaches exactly one infrastructure model — coherent with its "operate almost nothing"
  thesis and criteria #3 (cognitive load).
- Aligns with the APEX Skills' opinionated stack (which teaches ACK + KRO in this role), reducing
  skill-curation work from ADR-0002.
- **Maturity risk accepted**: KRO is young; ACK controller coverage varies by AWS service. The
  kit's golden-path templates must stick to well-covered services (S3, DynamoDB, RDS, IAM, SQS);
  coverage should be validated with the AWS container specialist team as templates are authored.
- Debugging KRO/ACK failures (CRD status conditions) is a new muscle for DevOps-heritage teams —
  must be covered in the kit's workshop material.
- No Terraform in the Developer-facing path. Teams wanting Terraform go off the golden path as
  trailblazers, owning their governance targets per the optionality principle.
