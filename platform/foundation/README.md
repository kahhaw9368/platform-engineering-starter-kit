# Foundation — one-time bootstrap runbook (ADR-0004)

**Who:** the engagement team together with the customer's Platform Team, once per customer.
**When:** after the week-zero assessment locks the TVP scope, before onboarding the first
Dev Team. **What it is:** engagement tooling, not a platform capability — Developers and
APEX never touch it (ADR-0004). Idempotent: safe to re-run after a partial failure;
existing resources are skipped.

Provisions: VPC (existing or new), nonprod + prod EKS Auto Mode clusters (ADR-0001/0007),
EKS Capabilities (managed Argo CD hub-and-spoke, ACK, KRO — ACK's day-0 policies include ECR,
so Team-type instances can create team repos), GitOps repo (placeholders rendered, branch
protection), CI OIDC role. IAM Identity Center *group→RBAC mapping* is a scripted-output
manual next-step, not automated (the IdC instance itself must pre-exist; only its ARN is wired
into Argo CD SSO) — a deliberate narrowing of ADR-0004's "IAM Identity Center wiring" scope.

**Duration:** dry-run ≈ 1 minute; real run ≈ 40–50 minutes (two clusters, serial, ~20 min
each, plus capabilities/repo/IAM). **Cost, order of magnitude:** two EKS control planes
(~USD 75/month each) + Auto Mode compute for system workloads + one NAT gateway per new VPC —
budget roughly USD 200–300/month for an idle foundation; existing-VPC mode avoids the new
NAT gateways. Teardown (below) reverses all of it.

## Prerequisites

- aws CLI v2, **eksctl ≥ 0.229** (older releases reject the Kubernetes version the kit pins;
  the weaveworks tap is dead — install from homebrew-core), kubectl, gh (authenticated), git
- AWS credentials (`aws sso login`) with the Platform Engineer permission set
  (IAM table in the root README)
- An IAM Identity Center instance (note its ARN, and its home region if different)
- Decided inputs: `REGION`, `GITOPS_REPO` (org/repo Argo CD will watch),
  `PLATFORM_TEAM_HANDLE` (GitHub team that owns prod files), and the VPC choice —
  existing `VPC_ID` (needs private subnets across ≥2 AZs) or unset for new VPCs

The full variable contract lives in the Usage header of [`bootstrap.sh`](bootstrap.sh)
(optional: `VPC_ID`, `IDC_REGION`, `STARTER_KIT_REPO`).

## Run it

**0. Day-0 review with Apex (recommended).** Render the plan (`--dry-run` below), then open
your harness (`claude` or `kiro`) and ask Apex: *"Review /tmp/cluster-nonprod.yaml and my VPC
choice against EKS best practices before I bootstrap."* Apex loads the vendored
eks-best-practices skill with this kit's ADR overrides applying (compute strategy is always
Auto Mode per ADR-0001 — ignore MNG/Karpenter suggestions). Sanity-checks networking, AZ
spread, and endpoint exposure before money is spent.

**1. Dry-run — always first.** Full plan, zero AWS mutations:

```bash
REGION=ap-southeast-1 GITOPS_REPO=org/gitops PLATFORM_TEAM_HANDLE=org/platform-team \
  ./bootstrap.sh --dry-run
```

Review the printed plan: VPC mode, both cluster configs (eksctl-validated), capability
layout, GitOps repo, CI role scope.

**2. Real run.** Same command plus `IDC_INSTANCE_ARN`, minus `--dry-run`. ~40–50 min;
re-run safely if it dies partway.

**3. Manual next-steps.** The script ends by printing them in order: authorize the Argo CD
hub's Git connection + register the prod cluster, map IdC groups to cluster RBAC and Argo CD
roles, publish the catalog RGDs into the GitOps repo's `platform/` folder and wire the
ApplicationSets, tighten the ACK role and CI trust before first prod tenant.

**4. Smoke.** Work [`smoke.md`](smoke.md) — every box must pass before week one begins.

## Teardown

Documented and rehearsed in [`smoke.md`](smoke.md#teardown): empty `teams/` via PR
(reconciles resources away), disable capabilities, `eksctl delete cluster` × 2, delete the
CI role + ECR repos. Git history survives.

## Validation status (live, owner account, 2026-07-17 — issue #16)

- eksctl 0.229.0 accepts the rendered Auto Mode configs (`--dry-run`), both VPC modes
- `aws eks create-capability` (ARGOCD/ACK/KRO) is GA — command shapes taken from the real CLI
- Capability role trust policy (`capabilities.eks.amazonaws.com`) per the EKS User Guide
- NOT yet live-validated: a real end-to-end run (cluster + capability creation, GitOps repo
  bootstrap, CI role) — that is the explicit "go provision" step, verified by `smoke.md`
