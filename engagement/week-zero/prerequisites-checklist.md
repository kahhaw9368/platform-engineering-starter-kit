# Week Zero — Prerequisites Checklist

Hard gates first. A ❌ on any hard gate pauses the engagement — resolve before proceeding
(better week zero than week six).

## Hard gates

- [x] **Agent harness approved & licensed for every participating Developer** (ADR-0013).
      Which one? ☑ Claude Code ☐ Kiro CLI ☐ Other standard-compliant: ______
- [x] **AWS accounts** for nonprod + prod (or OU/account-vending path agreed) — both exist
- [x] **IAM Identity Center** enabled, Dev Team groups exist (or can be created this week) —
      *initially proposed IAM-only; team agreed to enable IdC this week (standalone directory).
      Gate passes as "enabled this week, groups creatable". Identity stays locked-down per
      ADR-0008 / criteria #4.*
- [x] **Git forge access** (GitHub/GitLab/Bitbucket) for all Developers; org admin available
      for repo creation + branch protection — GitHub (reference forge)
- [x] **A real first Dev Team identified**, with a real service need (not a demo appetite) —
      yes; team + service captured in value-proposition-canvas.md

## Soft gates (note, don't block)

- [x] Existing CI system: **GitHub Actions** (reference — no ci-porting needed, ADR-0005)
- [x] Container experience level of the first team: none / **some** / strong — comfortable
      with images, not manifests; golden path should stay high-abstraction
- [x] Platform Team named: **yes — dedicated team** (size/backgrounds to be recorded in
      tvp-worksheet.md skills section)
- [x] Executive sponsor identified (stakeholder ≠ customer — criteria #5): **yes — named sponsor**

Facilitated by the platform-as-product skill; filled during the week-zero session (2026-07-17).
**Result: all hard gates pass — week zero proceeds.**
