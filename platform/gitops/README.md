# GitOps repo structure (what managed Argo CD watches — ADR-0004/0007/0008)

- [ ] Define repo layout: per-team folders (Team type provisions them), nonprod/ + prod/ env config
- [ ] Promotion = PR copying tested image tag nonprod → prod (ADR-0007); APEX-assisted, human gate
- [ ] Branch protection + required checks wiring (ADR-0009)

## Implemented (T5/#6)

`reference/` is the templated GitOps repo layout: platform/ (RGDs, both clusters), teams/
(per-team folders with nonprod + .prod.yaml split), required guardrail check via workflow_call,
CODEOWNERS gating prod files. Promotion mechanics documented in reference/README.md.
Placeholders ({{starter_kit_repo}}, {{platform_team_handle}}) are filled at Foundation bootstrap.
