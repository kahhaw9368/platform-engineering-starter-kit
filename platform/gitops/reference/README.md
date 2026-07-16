# GitOps Repository (reference layout)

The single repo managed Argo CD watches (ADR-0004/0007). Instantiated per customer during the
Foundation bootstrap (T6). All change enters as PRs; nothing is ever kubectl-applied.

```
platform/                     # Platform-Team-owned: RGDs, policies — synced to BOTH clusters
  rgd-team.yaml
  rgd-web-service.yaml
teams/                        # One folder per Dev Team (created by the team type render)
  <team>/
    team.yaml                 # the Team instance (tenancy)
    <service>/
      web-service.yaml        # WebService instance — nonprod state
      web-service.prod.yaml   # WebService instance — prod state (promotion PRs touch ONLY this)
clusters/
  nonprod/                    # Argo CD ApplicationSet targets: platform/ + teams/**(nonprod)
  prod/                       # Argo CD ApplicationSet targets: platform/ + teams/**(prod files)
.github/workflows/pr-checks.yaml   # required check: guardrail suite on every PR
```

## Promotion (ADR-0007)

Promotion = a PR that copies the tested image tag from `web-service.yaml` (nonprod) into
`web-service.prod.yaml`. APEX opens it on request ("promote orders-api to prod"); a human
approves; Argo syncs prod. Prod promotion ALWAYS has a human gate — branch protection enforces
review on `teams/**/*.prod.yaml` via CODEOWNERS.

## Branch protection (Platform Team applies at bootstrap)

- `main` protected: PRs only, no direct pushes, no force pushes
- Required status check: `guardrails / policy-check`
- CODEOWNERS: `teams/**/*.prod.yaml` → platform team + the owning team lead
- Trailblazer manifests (hand-written YAML outside catalog types) enter the same way and pass
  the same checks (ADR-0009) — the escape hatch is an ordinary PR, not a side door.
