---
name: scaffold-service
description: Create a new service on the golden path — interview for parameters, render the template, open PRs. Use when a Developer wants a new service/API/app, says "scaffold", "create a service", "I need a new API", or similar.
---

# Scaffold Service

Take a Developer from "I need a service" to two open PRs: one creating their service repo
content, one registering the WebService in the GitOps repo. You are the interface, not the
factory (ADR-0003): everything is rendered from the catalog, never freehanded.

## Process

1. **Identify the item.** Read the catalog (see catalog-browse skill for location). For an HTTP
   API the item is `web-api` (+ its `web-service` GitOps instance). If the need doesn't match
   any item, stop — offer the trailblazer path and log the gap (apex-rules.md).
2. **Interview for parameters — only the declared surface.** Ask conversationally, in plain
   language, applying defaults where the user has no opinion. Explain constraints when they hit
   one ("lowercase and hyphens — it becomes a DNS name"). Confirm the team: read
   `.apex/context.yaml` if present; otherwise ask. If their team isn't onboarded yet, detour to
   the onboard-team journey first (a WebService needs its team namespace).
3. **Render.** Run the render harness from the same kit root the catalog came from
   (catalog-browse locates it; on installed-only machines that root is
   `~/.claude/apex/kit/` or `~/.kiro/apex/kit/`):
   `python3 <kit_root>/platform/catalog/harness/render.py --catalog <catalog> --item web-api --param k=v ... --out <workdir>`
   Then render the `web-service` item for the GitOps instance. Never hand-edit the output —
   if something's wrong, fix parameters and re-render. (Needs python3 with `pyyaml` and
   `jsonschema`; if missing, give the pip install line before proceeding.)
4. **Validate.** Run the guardrail suite on rendered manifests
   (`python3 <kit_root>/platform/guardrails/policies.py <dir>`). Golden-path output passes by
   construction; if it doesn't, that's a platform bug — report it, don't patch around it.
5. **Open the PRs.**
   - Service repo: create via the forge CLI (`gh repo create <org>/<service_name>` per the
     customer's org convention in `.apex/context.yaml`), push rendered content on a branch,
     open a PR so the Developer reviews their own scaffold.
   - GitOps repo: branch, add `teams/<team>/<service_name>/web-service.yaml` (rendered), PR
     titled "Onboard <service_name> (nonprod)".
6. **Hand back.** Show both PR links, what happens on merge (Argo syncs nonprod; CI takes over
   on their first push), and the one thing they must do next (fill `ci_role_arn` secret wiring
   if the bootstrap didn't). Then the one-tap micro-survey (apex-rules.md etiquette).

## Rules

- Same ask → same result: parameters fully determine output. No creative additions.
- Both PRs reference each other in their descriptions.
- If any step fails, stop and show the real error — no partial silent state.
