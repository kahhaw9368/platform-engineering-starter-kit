# Render Harness — the Catalog contract seam

`render.py` is the kit's primary test seam: given a catalog item + parameters, it produces the
rendered artifacts (the PR content APEX opens). Deterministic by construction (ADR-0003) — no
model, no network, mechanical `{{param}}` substitution only.

```
python render.py --catalog ../catalog.yaml --item dummy-item \
  --param widget_name=orders-widget --param team=payments --out /tmp/rendered
```

Exit codes: 0 ok · 2 catalog invalid · 3 unknown item · 4 parameter error · 5 unresolved placeholder.

- Schema: `../schema/catalog-schema.json`
- Tests: `tests/test_seam.py` (external behavior only — the kit's pattern-setting suite)
- CI: `.github/workflows/catalog-seam.yaml` on every PR

APEX consumes this seam: it collects parameters conversationally, then calls the harness — it
never writes manifests itself. The guardrail suite (T2/#3) chains after rendering.
