# Vendored APEX Skills — Audit Matrix (T12/#13, ADR-0002/0013)

Disposition of every skill in aws-samples/sample-apex-skills against this kit's ADRs.
Refresh procedure at the bottom. Vendored = copied into apex/skills/vendor/ by the refresh
script at release time (NOT committed here until the embedding decision, ADR-0012 — the
installer pulls upstream at install time meanwhile).

## Dispositions

| Upstream skill | Disposition | ADR conflicts / rationale |
|---|---|---|
| eks-best-practices | **VENDOR + override note** | Sound advisory baseline. Override: compute strategy questions answer "Auto Mode" per ADR-0001 — the skill's MNG/Karpenter comparison guidance is inapplicable to golden-path clusters (fine for trailblazer/edge discussions). |
| eks-security | **VENDOR + override note** | Valuable for hardening conversations. Override: Kyverno/OPA admission guidance is a *named graduation step* (ADR-0009), not a v1 recommendation; image signing is a later contract version (ADR-0005). |
| eks-cost-intelligence | **VENDOR as-is** | Read-only cost assessment; no conflicts. Useful in metrics-review ritual. |
| eks-operation-review | **VENDOR as-is** | Read-only ops assessment; no conflicts. |
| eks-upgrade-check | **VENDOR as-is** | Auto Mode reduces its surface but insight remains valid; no conflicts. |
| eks-recon | **VENDOR as-is** | Discovery; useful in week-zero for customers with existing clusters. |
| eks-mcp-server | **VENDOR as-is** | Tooling setup; harness-level, no conflicts. |
| eks-genai | **VENDOR as-is** | Out of v1 golden path (ADR-0014) but harmless as advisory knowledge; GenAI template is a growth candidate. |
| eks-ingress-migration | **VENDOR as-is** | Day-2 utility; no conflicts. |
| eks-platform-engineering | **EXCLUDE — superseded** | Direct conflict: recommends Backstage portal (vs ADR-0002 APEX front door), Keycloak (vs IdC), self-managed ArgoCD + Argo Workflows CI (vs ADR-0004/0005 managed capability + CI contract), Kargo in v1 (vs ADR-0007). This kit IS the replacement for that skill's opinionated stack. Apex must never load it; its useful ACK/kro material is already embodied in our catalog types. |
| eks-design | **VENDOR + override note** | Document generator is useful in engagements. Override: designs produced for golden-path customers assume Auto Mode + EKS Capabilities stack (ADRs 0001/0004), not the skill's full option matrix. |
| eks-build | **EXCLUDE from Developer surface; ENGAGEMENT-ONLY** | Generates Terraform cluster projects — collides with ADR-0004 (no Terraform in Developer path) and overlaps T6 Foundation. Its "ArgoCD+ACK/KRO" pattern is useful input for the T6 bootstrap authoring, so keep it available to the *engagement facilitator context only*, never installed for Developers. |
| terraform-skill | **EXCLUDE from Developer surface; ENGAGEMENT-ONLY** | Same reason: Terraform is bootstrap-only (ADR-0004). |
| ecs-* (7 skills) | **EXCLUDE** | Kit is strictly EKS (ADR-0001); shipping ECS skills invites scope confusion. |
| skill-creator, steering-workflow-creator, update-docs | **EXCLUDE** | Maintainer tooling for the upstream repo, not platform capabilities. |

## Override mechanism

Overrides are NOT forks. `apex/rules/apex-rules.md` gains a "Vendored knowledge overrides"
section (below) that loads with every session and takes precedence over vendored skill content —
one place to audit, survives upstream refreshes untouched.

## Graduation-path preservation

Apex MAY mention Backstage/Kargo/Kyverno/DevLake/Argo Workflows as *named growth steps* with
their triggers (ADR-0007/0009/0011 wording) — it must NOT recommend them as v1 choices or
scaffold them.

## Refresh from upstream

1. `git -C /tmp clone --depth 1 https://github.com/aws-samples/sample-apex-skills`
2. Diff upstream skill list against this matrix; new skills default to EXCLUDE until audited.
3. Copy VENDOR-disposition skills into the install set; re-run installer seam test.
4. Re-read the two EXCLUDE-superseded skills' changelogs — if upstream adopts managed
   capabilities / Auto Mode positions, revisit dispositions (and possibly this kit's role in
   the embedding decision, ADR-0012).
