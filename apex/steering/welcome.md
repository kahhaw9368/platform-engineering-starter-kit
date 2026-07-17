# APEX Welcome Screen (session start)

Rendered at session start via the harness (Claude Code: SessionStart hook prints it; Kiro:
steering include). Content per docs/design/apex-welcome-screen.md; the Platform Team customizes
the marked lines at bootstrap. Every command listed MUST exist (criteria #6 rule).

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
 /scaffold-service                       Create a service (golden path)
 /onboard-team                           Onboard your team to the platform
 /promote                                Promote a tested release to prod
 /service-health                         Service health from CloudWatch
 /verify-setup                           Verify your prerequisites

 Or just ask — e.g. "I need a Python API with a Postgres database"

 🔧  PREREQUISITES
 git access · AWS IAM Identity Center login · kubectl not required

 📦  UPDATE
 npx apex-starter-kit --update                      # CUSTOMIZE: installer package name

 💬  COMMUNITY & FEEDBACK
 Slack: #platform-help                              # CUSTOMIZE: your channel
 Request a capability: just describe the need — Apex logs it for the Platform Team
 📣  Rate your last journey → one tap, right here in chat
```

All six Quick Start commands exist as skills (T7 + T8). Natural-language asks route to the
same skills via their descriptions.
