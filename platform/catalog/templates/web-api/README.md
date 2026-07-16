# Web API Template (v1's only app template — ADR-0014)

To author:
- [ ] app skeleton (language TBD with specialist team — FastAPI or Node candidate)
- [ ] Dockerfile with health endpoints
- [ ] .github/workflows/ci.yaml — reference implementation of the artifact contract (ADR-0005):
      build image → push ECR → bump tag in GitOps repo
- [ ] web-service instance manifest (the ~15-line KRO custom resource APEX PRs)
- [ ] repo-local APEX context file (service name, team, template version — ADR-0012)
