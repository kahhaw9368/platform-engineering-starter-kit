# Foundation — one-time bootstrap (ADR-0004)

Engagement tooling, not a platform capability. Developers and APEX never touch this.
Idempotent: safe to re-run after a partial failure.

Provisions: VPC (existing or new), nonprod + prod EKS Auto Mode clusters (ADR-0001/0007),
EKS Capabilities (managed Argo CD hub-and-spoke, ACK, KRO — ACK's day-0 policies include ECR,
so Team-type instances can create team repos), GitOps repo (placeholders rendered, branch
protection), CI OIDC role. IAM Identity Center *group→RBAC mapping* is a scripted-output
manual next-step, not automated (the IdC instance itself must pre-exist; only its ARN is wired
into Argo CD SSO) — a deliberate narrowing of ADR-0004's "IAM Identity Center wiring" scope.

Prerequisites: aws CLI v2, **eksctl ≥ 0.229** (older releases reject k8s 1.33; the weaveworks
tap is dead — install from homebrew-core), kubectl, gh (authenticated), git, AWS credentials
(`aws sso login`).

See the Usage header in [`bootstrap.sh`](bootstrap.sh) for the full variable contract
(REGION, GITOPS_REPO, PLATFORM_TEAM_HANDLE, IDC_INSTANCE_ARN; optional VPC_ID, IDC_REGION,
STARTER_KIT_REPO). Always `--dry-run` first — full plan, zero AWS mutations. The real run
creates the two clusters serially, ~20 min each (~40 min total). Set `VPC_ID` to build into
an existing VPC (validated live: exists, private subnets across ≥2 AZs; set `IDC_REGION` if
your Identity Center home region differs from REGION). After the real run, work the manual
next-steps the script prints, then [`smoke.md`](smoke.md) — every box before week one.

## Validation status (live, owner account, 2026-07-17 — issue #16)

- eksctl 0.229.0 accepts the rendered Auto Mode configs (`--dry-run`), both VPC modes
- `aws eks create-capability` (ARGOCD/ACK/KRO) is GA — command shapes taken from the real CLI
- Capability role trust policy (`capabilities.eks.amazonaws.com`) per the EKS User Guide
- NOT yet live-validated: a real end-to-end run (cluster + capability creation, GitOps repo
  bootstrap, CI role) — that is the explicit "go provision" step, verified by `smoke.md`
