---
name: catalog-browse
description: Browse the platform Catalog — what a Developer can self-serve. Use when the user asks "what can I do here", "what's in the catalog", "show me templates", "what can the platform give me", or invokes /catalog.
---

# Catalog Browse

Show the Developer what the Platform offers. The Catalog is the complete self-service surface —
if it's not in the Catalog, APEX cannot create it (ADR-0003), though trailblazer PRs remain open
to them (mention this only if asked).

## Process

1. Locate the catalog — first match wins:
   1. the path configured in this repo's `.apex/context.yaml` (`catalog_path` key) — a
      customer-published catalog always beats the kit default,
   2. `platform/catalog/catalog.yaml` in a starter-kit checkout (current repo),
   3. the installed kit copy: `~/.claude/apex/kit/platform/catalog/catalog.yaml` (Kiro:
      `~/.kiro/apex/kit/...`) — present on every machine the installer has run on.
   If none exists, the install is broken — point at
   `npx github:kahhaw9368/platform-engineering-starter-kit --update` and the Platform Team.
2. Read it (plain YAML). Filter out items whose name starts with `dummy-` (seam fixtures).
3. Present a table: **name · kind · version · description**. Flag 0.x versions as
   "early adopter" per the semver trust convention (criteria #7).
4. For any item the user picks, show its parameter surface: name, type, required/default,
   pattern constraints — phrased in plain language ("service name: lowercase, hyphens, 3–40
   chars"), not raw regex.
5. Offer the natural next step: "want me to scaffold one?" → hand off to the scaffold-service
   journey (or the equivalent journey for that item kind).

## Rules

- Never present an item that is not in the catalog file. Never improvise capabilities.
- If the catalog is missing or unparseable, say so and point to the Platform Team — do not
  reconstruct it from memory.
- PLACEHOLDER-descriptions (if any survive) are shown as "coming soon", not offered.
