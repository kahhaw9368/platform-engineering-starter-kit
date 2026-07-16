# Platform as a Product — Criteria Framework

Distilled from Team Topologies "Platform as a Product" course material (Skelton & Pais, TT25 decks
parts 1 & 2, plus learning-resources companion), studied 2026-07-16. This is the foundation for the
AWS EKS platform engineering starter kit.

## Project intent

Build a **platform engineering starter kit based on AWS EKS**, but led by a
**platform-as-product mindset**, not the tech stack. Target audience: customers who have **no
platform today and don't know where to start**. The kit must force users through "who are your
customers, what's their pain, what's the thinnest thing that helps" *before* any `terraform apply`.

## The 8 best-practice criteria (locked)

1. **Product definition** — Platform as a compelling internal product with an explicit value
   proposition (Value Proposition Canvas included). Evan Bottcher: "a foundation of self-service
   APIs, tools, services, knowledge and support, arranged as a compelling internal product."
2. **Thinnest Viable Platform (TVP)** — Start minimal (could even be a wiki page of curated
   guidance), grow only on concrete customer need, actively prune unused services. Running three
   generations of the same solution = product failure (Fournier).
3. **Cognitive load reduction** — Every capability targets the **self-service AND non-blocking**
   quadrant (ticket queue = anti-pattern). Curated abstractions; leverage managed/3rd-party
   services over bespoke builds. Value ≠ complexity or service count.
4. **Optionality with governance** — Spectrum of optionality: identity/access control = locked
   down, few options; deployment pipelines/runtimes = golden paths with escape hatches. **No
   mandates** (mandates hide fitness-for-purpose issues; aim ~80/20 adoption). Off-path
   "trailblazer" teams still own their governance targets (security, compliance, cost).
5. **Customer discovery & prioritization** — Customers = teams *using* the platform, NOT
   stakeholders/sponsors. User personas per service (experience level, tech savviness, info
   needs). Reserve standing capacity for discovery; transparent, consistent prioritization
   criteria; co-develop each new service with a few real teams.
6. **DevEx quality** — The bar is SaaS-like (Docker/Stripe-grade onboarding). Two failure modes:
   tooling (context switching, inconsistency) and interactions (slow support, bad docs, broken
   promises). Nielsen's 10 usability heuristics apply to CLIs/APIs/portals. Consistency across
   services in one platform; shared design & interaction principles. Docs are an adoption tool:
   simplest use case first, usage-focused, examples throughout.
7. **Adoption lifecycle management** — Optional products follow the classic adoption curve. Early
   adopters validate; majorities demand reliability/"ilities". Measure honestly: onboarded-teams
   ratio is the start, but watch the trap (80% teams onboarded, only 30% of apps using it).
   Rising help requests during early adoption = not ready for wider rollout. Semver builds trust
   (0.x = early adopters, 1.0+ = majority). Marketing is real platform work (announcements,
   release notes, branding, joint success-story demos). Don't chase 100% adoption — accelerate
   the 80% onboard. Avoid the doom loop: more adoption → more support → less stability work.
8. **Measured by satisfaction** — Customer satisfaction is the value proxy: NPS (% promoters −
   % detractors), Twilio-style surveys/chatbot, built-in feedback channels.

## Starter kit structure (agreed direction)

Two layers:

1. **Product operating model** (templates & guidance): platform vision / value-prop canvas, TVP
   definition worksheet, customer discovery interview guide, persona templates, adoption metrics
   (onboarding time, DORA, SPACE/NPS), platform roadmap, platform team charter (team topology,
   interaction modes), transparent prioritization criteria, satisfaction survey instrument.
   Opens with a **week-zero assessment/workshop module** based on the TT25 closing checklist:
   Clear Platform Value / True Platform Customers / Platform Optionality / Platform Skills.
2. **Technical TVP on EKS**: thinnest viable implementation with golden paths and self-service,
   designed to start small and evolve from measured demand. Usage tracking from day one (to
   enable pruning). Explicit optionality map (locked vs golden-path-with-escape-hatches).

## Design rules for the kit

- Every technical component must map back to one of the 8 criteria; anything that doesn't gets
  challenged (TVP spirit).
- Acceptance criterion per capability: "can a stream-aligned team get X without filing a ticket
  or waiting on a human?"
- Managed AWS / off-the-shelf CNCF over bespoke ("leverage 3rd parties as much as possible").
- Ship thin with a deprecation muscle, not a kitchen sink.

## Status / next steps

- Criteria framework: **complete and locked** (as of 2026-07-16).
- Tech stack conversation: **not started yet** — next step is mapping stack choices to criteria.
- Matt Pocock's `grill-with-docs` skill installed (`.claude/skills/`) to stress-test the idea;
  run `/setup-matt-pocock-skills` once first, then `/grill-with-docs`.

## Source material

- `/Users/kahhaw/Downloads/PlatformasaProductLearningResources-220112-121728.pdf` — resource list
- `/Users/kahhaw/Downloads/platformpdf-part1.pdf` — TT25 deck: Platform Value, Platform Customers
- `/Users/kahhaw/Downloads/platformpdf-part2.pdf` — TT25 deck: Platform Experience, Adoption Cycle
