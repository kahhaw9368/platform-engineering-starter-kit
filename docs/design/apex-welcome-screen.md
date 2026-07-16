# APEX Welcome Screen (TUI)

Modeled on the internal UNO TAM agent's session-start screen, which the kit author identified as
the reference experience. The welcome screen is the primary mitigation for ADR-0002's
discoverability risk: the first thing a Developer sees is a menu of what exists, not an empty
prompt.

Mechanically: rendered at session start by the harness (Claude Code: session-start hook /
statusline + output style; Kiro: steering equivalent). Content is versioned with the APEX bundle
(ADR-0012) so the Platform Team can customize sections per customer.

## Mockup

```text
                                                Share feedback anytime with /feedback.

  █████╗  ██████╗  ███████╗ ██╗  ██╗
 ██╔══██╗ ██╔══██╗ ██╔════╝ ╚██╗██╔╝
 ███████║ ██████╔╝ █████╗    ╚███╔╝
 ██╔══██║ ██╔═══╝  ██╔══╝    ██╔██╗
 ██║  ██║ ██║      ███████╗ ██╔╝ ██╗
 ╚═╝  ╚═╝ ╚═╝      ╚══════╝ ╚═╝  ╚═╝

 APEX — Agentic Platform Engineering eXperience
 Your platform engineer, available 24×7

 ⚠   AI & DATA NOTICE
 All output is AI-generated and must be verified before applying to
 production systems. APEX never applies changes directly — every change
 lands as a pull request for human review. Follow your organization's
 data handling policies. Do not paste secrets or customer PII.

 📋  QUICK START
 /catalog                                Browse everything you can self-serve
 @apex:scaffold-service                  Create a new service (golden path)
 @apex:onboard-team                      Onboard your team to the platform
 @apex:promote                           Promote a tested release to production
 @apex:service-health                    How is my service doing?

 Or just ask — e.g. "I need a Python API with a Postgres database"

 🔧  PREREQUISITES
 git access · AWS IAM Identity Center login · kubectl not required
 @apex:verify-setup                      Verify your setup

 📦  UPDATE
 npx apex-skills --update

 💬  COMMUNITY & FEEDBACK
 Slack: #platform-help
 Request a capability or report an issue via @apex:request-capability
 📣  Rate your last journey → answered in one tap, right here in chat
```

## Section mapping (UNO → APEX)

| UNO section | APEX equivalent | Notes |
|---|---|---|
| ASCII logo + product line | APEX logo + subtitle + persona tagline | Branding as adoption mechanism (criteria #7) |
| AI & Data Notice | Kept, customer-appropriate | Reinforces ADR-0003: PRs only, never direct apply — the notice doubles as a trust statement |
| Quick Start (SOP commands) | Catalog browse + top golden-path journeys | The discoverability fix; `/catalog` is first deliberately |
| "Or just ask" | Same, with a golden-path example | Teaches the conversational mode |
| Prerequisites + verify SOP | Harness/git/IdC check + `@apex:verify-setup` | Week-zero prerequisite (ADR-0013) made self-checkable forever |
| Update instructions | `npx apex-skills --update` | ADR-0012 |
| Community & Feedback | Customer's Slack channel + capability requests + micro-survey | Feeds discovery (criteria #5) and satisfaction capture (ADR-0011) |

## Rules

- The Platform Team owns and customizes the Slack channel, catalog highlights, and any
  customer-specific notice text; the structure is fixed by the kit.
- Every command shown must exist and work — a dead command on the welcome screen is a
  first-impression killer (criteria #6).
- Keep it to one screen. It is a lobby, not a manual.
