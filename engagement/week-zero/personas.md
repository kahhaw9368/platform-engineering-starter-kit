# Personas — CMS Team

Per criteria #5: personas differentiated by experience level, technical savviness, information
needs. Anchor each on a real person from the first Dev Teams (name optional, role required).

Filled during week-zero session, 2026-07-17. Team shape: 1 tech lead + 3 junior developers —
top-heavy; the lead is both the single reviewer and the skeptic, the juniors are who the
golden path is really for.

## Persona 1: "The veteran tech lead" — also the late-majority proxy (criteria #7)
- Anchor: Tech Lead, CMS team (many years of experience)
- Experience/savviness: high — can do all of this by hand given time; the platform must beat
  his own speed, not just the DevOps ticket queue
- What they need from the Platform: fast paths that respect his time; visibility into what
  was rendered/deployed; confidence he can hand journeys to juniors safely
- What they'd never tolerate:
  - **Being slowed down** — an agent flow slower than his own CLI muscle memory kills
    adoption on day one
  - **No escape hatch** — golden path until it isn't; must be able to go off-path
    (trailblazer, ADR rules apply) without a fight
- First journey they'll run: **everything, solo, first** — team onboarding, scaffold,
  first deploy, promotion — before letting juniors touch it
- 1.0 trust bar (this persona gates it): the platform is "trustworthy" when he's willing
  to let a junior run scaffold-to-deploy without him watching

## Persona 2: "The junior developer" (×3)
- Anchor: the three junior developers, CMS team
- Experience/savviness: early career; TypeScript/Node comfortable, some container exposure
  (images yes, manifests no), no Kubernetes fluency
- What they need from the Platform: one front door (Apex), plain-language explanations of
  the *why*, guardrails that make it safe to try things
- What they'd never tolerate:
  - **Kubernetes jargon** — errors/docs assuming K8s fluency they don't have
    (docs bar: simplest use case first, criteria #6)
  - **Dead-end errors** — failures with no next concrete step; they can't self-rescue the
    way the lead can (matches the Apex rule: show the error, what was checked, next step)
- First journey they'll run: shipping code changes via PR merge on the already-scaffolded
  service — *after* the lead has cleared the path

## Adoption risk recorded (honest, per criteria #7)

The "lead does everything first" pattern is understandable but concentrates all platform
knowledge in one person — the lead becomes an internal ticket queue for his own team, and
the juniors' first-journey feedback (the truest usability test) arrives late. Mitigation to
propose during the guided engagement: once the lead has validated the path, have one junior
run a scaffold end-to-end as the under-an-hour usability test, with the lead observing.
