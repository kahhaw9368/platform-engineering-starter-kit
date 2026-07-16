# Platform Engineering Starter Kit

A starter kit for building an internal platform on **AWS EKS**, led by a **platform-as-product
mindset** (Team Topologies), not the tech stack. Target audience: customers with no existing
platform who don't know where to start.

## Required reading before any design/build work

Read `docs/context/platform-as-product-criteria.md` — the locked 8-criteria framework distilled
from the Team Topologies "Platform as a Product" course, the agreed two-layer kit structure
(product operating model + technical TVP on EKS), design rules, and current status.

## Agent skills

### Issue tracker

Issues and specs live in this repo's GitHub Issues (`gh` CLI). See `docs/agents/issue-tracker.md`.

### Domain docs

Single-context: `CONTEXT.md` (glossary) at the root, ADRs in `docs/adr/`. See `docs/agents/domain.md`.

## Core rules

- Product mindset first: never lead with the tech stack. Every technical component must map to
  one of the 8 criteria in the context doc.
- Thinnest Viable Platform: challenge anything not tied to a concrete customer need.
- Every capability should be self-service and non-blocking (no ticket queues).
- Prefer managed AWS / off-the-shelf CNCF tools over bespoke builds.
