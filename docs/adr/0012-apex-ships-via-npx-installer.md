# 0012 — APEX ships via npx installer in v1; upstream embedding deferred

## Status

Accepted (2026-07-16) — embedding question deliberately deferred

## Context

APEX is a bundle (agent definition, curated skills, slash commands, guardrail rules) that must
reach Developers' machines and stay upgradeable by the Platform Team. Options: a Claude Code
plugin (versioned unit, app-store-like install/upgrade), an npx installer copying files into
~/.claude/ (the pattern aws-samples/sample-apex-skills already uses, with --version pinning and
--update), repo-local config only, or hybrid.

A future decision is pending: after v1 ships, the kit will be embedded into the
sample-apex-skills GitHub repo — either the APEX repo vendors artifacts from this kit's repo, or
this kit is parked wholesale as a folder inside it.

## Decision

**v1 distributes APEX via an npx installer**, following the existing `npx apex-skills`
convention: detect the agent harness, copy/symlink the curated skills + agent config + commands,
support `--version` pinning and `--update`.

The upstream embedding question (vendor vs. park-as-folder in sample-apex-skills) is **explicitly
deferred** until after v1 ships.

## Consequences

- Distribution matches the ecosystem the kit will live in — whichever embedding path is chosen
  later, the install story (`npx …`) does not change for users.
- Version drift across developer machines is the accepted trade-off; mitigated by pinning flags
  and small guided-customer counts in v1. A Claude Code plugin remains the graduation path if
  drift becomes a support burden.
- Scaffolded service repos still carry lightweight context files (service name, team, template
  version) so APEX is service-aware inside each repo — context, not a second copy of APEX.
- The kit's repo structure should keep APEX artifacts (skills/, steering/, rules/) cleanly
  separable from engagement material, so both embedding options remain cheap.
