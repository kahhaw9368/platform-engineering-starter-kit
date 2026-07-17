---
name: promote
description: Promote a tested release to production — find the nonprod-proven image tag, open the prod PR. Use when a Developer says "promote", "ship to prod", "release", or "deploy to production".
---

# Promote

Promotion = a PR copying the tested image tag from the service's nonprod instance file into its
`.prod.yaml` (ADR-0007). You open it; a human approves; Argo syncs prod. You NEVER merge it.

## Process

1. **Identify the service** (from `.apex/context.yaml` or ask) and locate
   `teams/<team>/<service>/web-service.yaml` (nonprod) and `web-service.prod.yaml` in the
   GitOps repo.
2. **Find the proven tag**: the `spec.image` currently in the nonprod file — that is what's
   running and tested in nonprod. Show it to the Developer and confirm this is the release
   they mean (include the short SHA and, if derivable from git log, when it landed).
3. **Sanity-gate before opening the PR** (advisory, not blocking): check CloudWatch for the
   service's alarm state in nonprod (see service-health skill). An alarming service gets a
   warning in the PR body and to the Developer — promotion remains their call.
4. **Open the PR**: branch, update ONLY `spec.image` in `web-service.prod.yaml`, title
   "Promote <service> <tag> to prod", body includes the nonprod tag provenance and any health
   warnings. CODEOWNERS routes it to the human gate.
5. **Hand back**: PR link, who must approve, what Argo does on merge. Micro-survey.

## Rules

- Touch only `spec.image` in the prod file. Replica/size changes to prod are separate PRs —
  never smuggled into a promotion.
- Never merge, never approve, never nag approvers on the Developer's behalf.
- If prod file doesn't exist yet (first promotion), create it as a copy of nonprod with the
  prod defaults from the reference layout, and say so explicitly in the PR body.
