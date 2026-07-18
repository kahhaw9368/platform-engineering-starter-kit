# Platform Engineering Starter Kit

Build and run an internal developer platform on **AWS EKS** — without a large platform team
or months of lead time.

The kit gives a newly formed platform team two things:

1. **A working technical foundation** — two EKS Auto Mode clusters (nonprod and prod), GitOps
   delivery, and a catalog of ready-to-use service templates, stood up by a guided,
   dry-run-first bootstrap.
2. **A product operating model** — short workshops and recurring rituals that treat the
   platform as a product whose customers are your developers, so you build what teams
   actually need instead of what looks impressive.

Both are fronted by **APEX**: an AI platform engineer that runs inside your terminal
(Claude Code or Kiro CLI) and is available to every developer, 24×7. Developers ask it for a
new service and get one; platform engineers use it to onboard teams and run the product
rituals. There is no web portal to install and no ticket queue to wait in.

## How it works

- **The platform team operates almost nothing.** Every component is either an AWS-managed
  capability (EKS Auto Mode, managed Argo CD, CloudWatch) or versioned files in git.
- **All change flows through git.** Developers never touch AWS directly — a service, a
  namespace, or a promotion to prod is always a pull request, reviewed and merged.
- **The agent instantiates templates; it never improvises infrastructure.** Everything APEX
  creates comes from the versioned catalog your platform team controls.
- **Start small, grow on demand.** The kit ships the smallest platform that is genuinely
  useful, and names the graduation steps (e.g. policy engines, delivery orchestration) to
  adopt only when real usage demands them.

## Who is this for?

| You are | You will | Start at |
|---|---|---|
| A **Platform Engineer** — standing up and owning the platform | Scope the platform with your first customers, provision the foundation, onboard teams | [For Platform Engineers](#for-platform-engineers) |
| A **Developer** — building services on an existing platform | Scaffold, ship, observe, and promote your services through the agent | [For Developers](#for-developers) |

## For Platform Engineers

Eight steps, in order. The first five get the agent running and verified; the last three
stand up the platform, each gated on the one before.

### 1. Get the right AWS access

Log in via **IAM Identity Center** (`aws sso login`) with a permission set that can stand up
and operate the platform. Minimum capabilities:

| Purpose | Permissions (minimum) |
|---|---|
| Create/manage the clusters | `eks:*` on `platform-*` clusters (create, describe, update, delete, access entries) |
| EKS Capabilities — the AWS-managed add-ons the platform runs on: Argo CD (GitOps delivery), ACK (AWS resources managed from Kubernetes), KRO (composable resource templates) | `eks:CreateCapability`, `eks:DescribeCapability`, `eks:ListCapabilities`, `eks:UpdateCapability`, `eks:DeleteCapability` |
| Cluster networking (created by eksctl) | `ec2:*` on VPC/subnet/SG resources, `cloudformation:*` on `eksctl-*` stacks |
| Service roles | `iam:CreateRole`, `iam:AttachRolePolicy`, `iam:PassRole` scoped to `platform-*` roles — includes the role the bootstrap creates so CI pipelines can push images without long-lived keys |
| Container registry | `ecr:*` on team repositories |
| Observability (read for APEX; write via GitOps) | `cloudwatch:Describe*/Get*/List*`, `logs:Describe*/Get*/Filter*` |
| Identity wiring | `sso-admin` / Identity Center group read, to map Dev Team groups to cluster RBAC |

Sanity check:

```bash
aws sts get-caller-identity        # right account?
aws eks list-clusters              # permission works?
```

Developers need none of these write permissions — their path is covered in
[For Developers](#for-developers).

### 2. Install the required tools

| Tool | Check | Needed for |
|---|---|---|
| Node.js 18+ | `node --version` | the installer |
| git | `git --version` | everything — all change flows through git |
| AWS CLI v2 | `aws --version` | Identity Center login, CloudWatch reads |
| GitHub CLI | `gh auth status` | pull requests (or your forge's CLI — GitLab: `glab`) |
| An agent CLI — [Claude Code](https://claude.com/claude-code) or [Kiro CLI](https://kiro.dev); you need one, not both | `claude --version` or `kiro --version` | running APEX (APEX is content these CLIs load, not a separate program) |
| eksctl ≥ 0.229 + kubectl | `eksctl version` / `kubectl version --client` | **step 7 only** — Developers never need these. Install per the [eksctl docs](https://eksctl.io/installation/); versions below 0.229 reject the Kubernetes version the kit uses |

### 3. Install APEX

```bash
npx github:kahhaw9368/platform-engineering-starter-kit
```

The installer detects which agent CLI you have and copies everything into place: the APEX
skills, curated EKS knowledge, and the agent's rules and welcome screen — into `~/.claude/`
and/or `~/.kiro/`.

```bash
npx github:kahhaw9368/platform-engineering-starter-kit --update           # refresh
npx github:kahhaw9368/platform-engineering-starter-kit --version v0.1.0   # pin
npx github:kahhaw9368/platform-engineering-starter-kit --uninstall        # remove
```

### 4. Start the agent

APEX comes as two personas: **`apex-manager`** for you (platform-team journeys: discovery
workshop, onboarding teams, platform metrics) and **`apex`** for your developers (scaffold,
promote, service health). As the platform engineer, start yours:

```bash
claude --agent apex-manager        # or: kiro
```

The `--agent` flag matters: it starts the session *as* that persona — rules, welcome screen,
quick-start menu. A plain `claude` session still has the skills but won't greet you as
Apex. From here on, "Apex" is who you're talking to. (The persona split is guidance, not a
permission boundary — access control stays in IAM and PR review.)

### 5. Verify your setup

First session, in order:

```
> /verify-setup        # checks agent CLI, git, gh, Identity Center login — with fix hints
> /catalog             # see every template and capability you can self-serve
```

`/verify-setup` covers the everyday tools. It does **not** check eksctl/kubectl (the
bootstrap in step 7 checks its own tools before touching anything) or the step-1 write
permissions — platform engineers should run the step-1 sanity checks for those; this
caveat does not apply to Developers.

### 6. Run the discovery workshop

Before building anything, ask Apex: *"let's do week zero."* It runs a short, structured
interview — who the platform's first customers are, what problem it solves for them, and
what the **smallest genuinely useful first version** of the platform must include (and,
just as important, what it can leave out). The output is a one-page scope you can defend.

Don't skip this and don't bootstrap first: the workshop is what confirms the platform is
worth its monthly cost before any money is spent.

### 7. Provision the foundation (one-time)

Follow the [Foundation runbook](platform/foundation/) — clusters, capabilities, GitOps
repo. It runs from your terminal (not through APEX — this is the eksctl/kubectl step from
the tools table), dry-run first, with a recommended Apex review of the rendered plan. The
runbook states who runs it, how long it takes, and what it costs per month **before**
anything is created.

### 8. Onboard your first team

Back inside the agent: `/onboard-team` your first **real** development team — not a demo
team; the goal of the whole engagement is a real service in production. Have two things
ready: the team's name and the Identity Center group its developers log in with. The agent
renders the team's configuration and opens a pull request; when it merges, the team's
namespace, quotas, and container registry exist.

The platform is now live. Hand your developers the next section.

## For Developers

You build services **on** the platform; you never touch the machinery **under** it. No
eksctl, no kubectl, no AWS write permissions — every change you make travels as a pull
request, reviewed and merged.

One-time setup:

1. **Get access** — Identity Center login (`aws sso login`), CloudWatch read, and git.
   Nothing from the platform-engineer permission table.
2. **Install the tools** — Node.js 18+, git, AWS CLI v2, GitHub CLI, and one agent CLI:
   [Claude Code](https://claude.com/claude-code) or [Kiro CLI](https://kiro.dev). No eksctl,
   no kubectl — those are platform-engineer tools.
3. **Install APEX**:

   ```bash
   npx github:kahhaw9368/platform-engineering-starter-kit
   ```

   This copies the APEX skills and agent into your agent CLI (`~/.claude/` and/or
   `~/.kiro/`). It downloads no source code and touches nothing in AWS.

4. **Start the agent**:

   ```bash
   claude --agent apex        # or: kiro
   ```

   The `--agent apex` flag is required — it starts the session *as* Apex, with its rules
   and welcome menu. A plain `claude` session won't greet you as Apex.

5. **Verify** — inside the session, run `/verify-setup` (every check should pass), then
   `/catalog` to see what you can self-serve.

From then on, any day — start with `claude --agent apex` and:

| Ask | What happens |
|---|---|
| `/scaffold-service` | a short conversation → two pull requests → your service deployed to nonprod on merge |
| `/service-health` | "how is my service doing?" answered from CloudWatch |
| `/promote` | a tested release → a human-approved pull request → production |

Or skip the commands and just ask in plain words: *"I need a Python API for the payments
team."*

## What it costs

An idle foundation runs roughly **USD 200–300/month** (two EKS control planes, system
compute, NAT gateways; less if you bring an existing VPC). The
[Foundation runbook](platform/foundation/) has the breakdown and the teardown that reverses
all of it.

## Under the hood

For readers who want the reasoning behind the design:

- [`CONTEXT.md`](CONTEXT.md) — the project glossary (what we mean by *Platform*, *APEX*,
  *golden path*, *Foundation*).
- [`docs/adr/`](docs/adr/) — 15 architecture decision records covering every locked choice
  (why EKS Auto Mode only, why no web portal, why GitOps is the single delivery pipe).
- [`docs/context/platform-as-product-criteria.md`](docs/context/platform-as-product-criteria.md)
  — the eight platform-as-product criteria the kit is built against.
