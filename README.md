# Platform Engineering Starter Kit

A guided-first starter kit that bootstraps a customer's platform team into building and running an
internal developer platform on **AWS EKS Auto Mode** — led by a **platform-as-product mindset**
(Team Topologies), fronted by **APEX**, an agentic platform engineer available to developers 24×7.

> **Start here:** [`CONTEXT.md`](CONTEXT.md) (glossary) · [`docs/adr/`](docs/adr/) (15 locked
> decisions) · [`docs/context/platform-as-product-criteria.md`](docs/context/platform-as-product-criteria.md)
> (the 8 best-practice criteria)

## The thesis

**The platform team operates almost nothing.** Every component is either an AWS-managed
capability or versioned files in git:

| Concern | How | ADR |
|---|---|---|
| Compute | EKS Auto Mode (only) | 0001 |
| Front door | APEX chat persona (TUI), no web portal | 0002 |
| Golden path | Agent instantiates versioned artifacts, never freehands | 0003 |
| Infra provisioning | git → managed Argo CD → KRO → ACK → AWS (one pipe) | 0004 |
| CI | Artifact contract; GitHub Actions reference implementation | 0005 |
| Observability | Baked into every KRO type (CloudWatch) | 0006 |
| Environments | nonprod + prod clusters; APEX-assisted PR promotion | 0007 |
| Tenancy | Namespace-per-team via a `Team` KRO type | 0008 |
| Guardrails | CI policy checks + quotas; no admission engine in v1 | 0009 |
| Product operating model | APEX-facilitated (week zero + rituals) | 0010 |
| Metrics | Derived from git + CloudWatch; APEX micro-surveys | 0011 |
| Distribution | npx installer; harness-agnostic (Claude Code ref, Kiro supported) | 0012, 0013 |
| V1 catalog | One Web API template; infra self-service as growth path | 0014 |
| Engagement done | First real service in production | 0015 |

Heavier tools (Kargo, Kyverno, DevLake, Backstage) are **named graduation steps**, adopted on
validated demand — never shipped speculatively.

## Install APEX (the agent)

**Prerequisites:** [Node.js 18+](https://nodejs.org), git, and one agent harness —
[Claude Code](https://claude.com/claude-code) (reference) or Kiro CLI (supported).

The package is not on npm yet, so install straight from this repo:

```bash
npx github:kahhaw9368/platform-engineering-starter-kit
```

That's it. The installer detects your harness(es) and copies everything into place:

| What you get | Where it lands (Claude Code) |
|---|---|
| 8 APEX skills — `/catalog`, `/verify-setup`, `/scaffold-service`, `/onboard-team`, `/promote`, `/service-health`, platform-as-product, platform-metrics | `~/.claude/skills/` |
| 10 curated AWS EKS skills (vendored from [sample-apex-skills](https://github.com/aws-samples/sample-apex-skills)) | `~/.claude/skills/` |
| Apex's rules + welcome screen | `~/.claude/apex/` |

Then start a session and try it:

```bash
claude          # or: kiro
> /verify-setup   # check your prerequisites
> /catalog        # see what you can self-serve
```

Other commands:

```bash
npx github:kahhaw9368/platform-engineering-starter-kit --update      # refresh to latest
npx github:kahhaw9368/platform-engineering-starter-kit --version v0.1.0   # pin a release
npx github:kahhaw9368/platform-engineering-starter-kit --uninstall   # remove
```

> **Developer vs. Platform Team:** Developers only need the install above. Standing up the
> platform itself (clusters, GitOps repo, capabilities) is the Platform Team's one-time
> [Foundation bootstrap](platform/foundation/) — done together during the guided engagement.

## Repo layout

```
engagement/        Layer 1 — product operating model (week-zero, rituals, worksheets)
platform/          Layer 2 — technical TVP
  foundation/      One-time bootstrap (VPC, clusters, capabilities, IdC) — engagement tooling
  catalog/         The golden-path artifacts (KRO types + app templates), semver-versioned
  gitops/          GitOps repo structure Argo CD watches (team folders, env config)
  guardrails/      CI policy checks (schema + policy-as-code) required on every PR
apex/              APEX agent content (skills, steering, rules) — harness-portable
installer/         npx installer that delivers apex/ to developer machines
docs/              ADRs, design specs, criteria framework
```
