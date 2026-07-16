# Guardrails — CI policy checks (ADR-0009)

Required PR checks on every GitOps repo. No in-cluster admission engine in v1.

- [ ] schema validation (kubeconform)
- [ ] policy set (versioned platform artifact): requests/limits required, no privileged
      containers, no :latest tags, quota sanity
- [ ] reusable workflow both golden-path and trailblazer PRs run
