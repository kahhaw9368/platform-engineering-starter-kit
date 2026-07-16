# Guardrails — CI policy checks (ADR-0009)

Required PR checks on every GitOps repo. No in-cluster admission engine in v1.

- [ ] schema validation (kubeconform)
- [ ] policy set (versioned platform artifact): requests/limits required, no privileged
      containers, no :latest tags, quota sanity
- [ ] reusable workflow both golden-path and trailblazer PRs run

## Implemented (v0.1.0)

`policies.py <dir>` — exit 0 clean, 1 violations, 2 unreadable. Policies GR001–GR005
(see CHANGELOG.md). Reusable workflow: `.github/workflows/guardrails.yaml`
(`workflow_call` with `manifest_dir`). Dog-food chain in CI: catalog render → policy check.
kubeconform schema validation: deferred to T5 wiring (needs CRD schemas from T3/T4).
