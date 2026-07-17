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

## Getting started (Platform Engineer)

Five steps, in order. Steps 1–2 are one-time setup; a Developer joining later only needs
steps 2–5 (with read-mostly permissions — their changes flow through git PRs, not AWS APIs).

### 1. IAM permissions

Log in via **IAM Identity Center** (`aws sso login`) with a permission set that can stand up
and operate the platform. Minimum capabilities for the Platform Engineer role:

| Purpose | Permissions (minimum) |
|---|---|
| Create/manage the clusters | `eks:*` on `platform-*` clusters (create, describe, update, delete, access entries) |
| EKS Capabilities (managed Argo CD, ACK, KRO) | `eks:CreateCapability`, `eks:DescribeCapability`, `eks:DeleteCapability` *(PROVISIONAL — confirm exact actions with the current EKS Capabilities docs)* |
| Cluster networking (created by eksctl) | `ec2:*` on VPC/subnet/SG resources, `cloudformation:*` on `eksctl-*` stacks |
| Service roles | `iam:CreateRole`, `iam:AttachRolePolicy`, `iam:PassRole` scoped to `platform-*` roles (incl. the CI OIDC role) |
| Container registry | `ecr:*` on team repositories |
| Observability (read for APEX; write via GitOps) | `cloudwatch:Describe*/Get*/List*`, `logs:Describe*/Get*/Filter*` |
| Identity wiring | `sso-admin` / Identity Center group read, to map Dev Team groups to cluster RBAC |

Sanity check:

```bash
aws sts get-caller-identity        # right account?
aws eks list-clusters              # permission works?
```

A **Developer** needs none of the write permissions — only IdC login, CloudWatch/logs read,
and git. That's the point of the one-pipe design (ADR-0004).

### 2. Verify required packages

| Package | Check | Needed for |
|---|---|---|
| Node.js 18+ | `node --version` | the installer |
| git | `git --version` | everything — all change flows through git |
| AWS CLI v2 | `aws --version` | IdC login, CloudWatch reads |
| GitHub CLI | `gh auth status` | PRs (or your forge's CLI — GitLab: `glab`) |
| Agent harness | `claude --version` or `kiro --version` | running APEX — [Claude Code](https://claude.com/claude-code) (reference) or Kiro CLI (supported) |
| eksctl + kubectl | `eksctl version` / `kubectl version --client` | **foundation bootstrap only** — Developers never need these |

### 3. Install APEX

```bash
npx github:kahhaw9368/platform-engineering-starter-kit
```

The installer detects your harness(es) and copies everything into place: 8 APEX skills, 10
curated EKS skills (vendored from [sample-apex-skills](https://github.com/aws-samples/sample-apex-skills)),
and Apex's rules + welcome screen — into `~/.claude/` and/or `~/.kiro/`.

```bash
npx github:kahhaw9368/platform-engineering-starter-kit --update           # refresh
npx github:kahhaw9368/platform-engineering-starter-kit --version v0.1.0   # pin
npx github:kahhaw9368/platform-engineering-starter-kit --uninstall        # remove
```

### 4. Start the agent

```bash
claude        # or: kiro
```

That's it — APEX is not a separate binary; it's skills + rules loaded by your harness. The
APEX welcome screen greets you with the Quick Start menu.

### 5. Inside the agent

In order, first session:

```
> /verify-setup        # confirms steps 1–2 actually work, with fix hints per failure
> /catalog             # see every golden-path item you can self-serve
```

Then, depending on who you are:

**Platform Engineer, day one** (standing up the platform):
1. Ask Apex to run the **week-zero assessment** ("let's do week zero") — it interviews you
   through value proposition, personas, and TVP scope before anything is built.
2. Run the one-time [Foundation bootstrap](platform/foundation/) (clusters, capabilities,
   GitOps repo) — guided, outside the agent.
3. `/onboard-team` your first real Dev Team.

**Developer, any day:**
1. `/scaffold-service` — conversation → two PRs → service deployed to nonprod on merge.
2. `/service-health` — "how is my service doing?" from CloudWatch.
3. `/promote` — tested release → human-approved PR → prod.

Or skip the slash commands and just ask: *"I need a Python API for the payments team."*

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
