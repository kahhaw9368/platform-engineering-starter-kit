# 0013 — APEX is harness-agnostic content; Claude Code is reference, Kiro CLI is supported

## Status

Accepted (2026-07-16)

## Context

APEX makes an agent harness a prerequisite for every Developer at the customer — a procurement
and security-approval reality that differs per customer. Definitions: a *harness* is everything
wrapped around the model that makes it a working agent (agent loop, model API access, tool
execution, memory/context, auth/identity, permissions). Claude Code and Kiro CLI are packaged,
vendor-assembled harnesses.

Options considered: hard-require Claude Code (one vendor's approval status gates the entire
kit); Kiro-first (contradicts the design intent and the current first-class Claude Code support
in sample-apex-skills); build a custom APEX harness on Bedrock + AgentCore (a full software
product with an AI runtime to operate — the heaviest possible violation of the kit's
"operate almost nothing" thesis); maintain a polished agent-free fallback (doubles the UX
surface); or ship harness-portable content.

## Decision

**APEX ships as harness-portable content, never as a harness.** Skills, agent configuration, and
commands follow the open Agent Skills standard (agentskills.io), as sample-apex-skills already
does. The customer brings whichever packaged harness they have licensed and security-approved.

- **Claude Code is the reference harness**: designed on, tested on, demoed on, screenshotted in
  docs.
- **Kiro CLI is a supported harness, not best-effort**: as the AWS-native product, Kiro support
  is verified per release (installer targets it, skills tested in it), matching the dual-harness
  convention of sample-apex-skills.
- Other standard-compliant harnesses get the skills-level experience without per-release
  verification.
- **Week-zero checks the prerequisite explicitly**: no approved agentic CLI at the customer =
  the kit is not fit for that customer yet.

## Consequences

- No vendor's procurement status is a single gate on the kit; the week-zero question widens to
  "any approved agentic CLI?" — with Kiro as the natural AWS answer where nothing is approved
  yet.
- We never build or operate an agent runtime; APEX remains versioned files (consistent with
  ADRs 0003 and 0012).
- Portability discipline: value lives in skills (portable); harness-specific features (custom
  agent definitions, subagents, hooks) are garnish and must degrade gracefully outside Claude
  Code.
- Release checklist must include a Kiro CLI verification pass — this is a standing cost accepted
  because Kiro is an AWS product and the AWS-native story matters commercially.
- The architectural agent-free escape hatch (everything is git PRs a human can open manually)
  exists by construction but is not maintained as a polished parallel UX.
