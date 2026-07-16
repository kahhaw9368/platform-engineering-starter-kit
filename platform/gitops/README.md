# GitOps repo structure (what managed Argo CD watches — ADR-0004/0007/0008)

- [ ] Define repo layout: per-team folders (Team type provisions them), nonprod/ + prod/ env config
- [ ] Promotion = PR copying tested image tag nonprod → prod (ADR-0007); APEX-assisted, human gate
- [ ] Branch protection + required checks wiring (ADR-0009)
