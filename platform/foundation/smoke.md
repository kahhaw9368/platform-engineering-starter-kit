# Foundation smoke checklist (engagement-time seam, per spec)

Run after bootstrap.sh; every box must pass before week-one begins.

- [ ] `eksctl get cluster` shows platform-nonprod + platform-prod ACTIVE
- [ ] Auto Mode: `aws eks describe-cluster --name platform-nonprod` shows autoMode enabled;
      no self-managed node groups exist
- [ ] Argo CD capability ACTIVE; hub sees both clusters; SSO login via IdC works for a
      Platform Team member
- [ ] ACK + KRO capabilities ACTIVE on both clusters
- [ ] GitOps repo: reference layout present, branch protection on main, guardrails check
      required, CODEOWNERS gating *.prod.yaml
- [ ] RGDs applied via GitOps (platform/ folder synced): Team, WebService, MetricsDashboard
      APIs available (`kubectl api-resources | grep starterkit`)
- [ ] Dry-run onboarding: render team item for a test team -> PR -> merge -> namespace,
      quota, ECR repo exist -> revert PR -> resources reconciled away
- [ ] CI role: OIDC assume from a test workflow succeeds; ECR push allowed, nothing else
- [ ] Teardown documented and rehearsed mentally with the customer (below)

## Teardown

Reverse order: delete GitOps-managed resources by emptying teams/ (PR), disable capabilities,
`eksctl delete cluster` × 2, delete CI role + ECR repos. Customer data (git history) survives.
