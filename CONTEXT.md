# Platform Engineering Starter Kit

A guided-first starter kit that bootstraps a customer's platform team into building and running an
internal developer platform on AWS EKS, using a platform-as-product operating model.

## Language

**Starter Kit**:
The guided-first repo (docs, workshops, templates, IaC) that is *our* product. Its customer is the
Platform Team. The Starter Kit is not the Platform — it bootstraps one.
_Avoid_: the platform, the product (ambiguous)

**Platform Team**:
The customer's team (typically newly formed or upgraded from an existing DevOps team) that uses the
Starter Kit to build and then own the Platform. The Starter Kit's true customer.
_Avoid_: DevOps team, ops team, infra team

**Platform**:
The internal developer platform the Platform Team builds and maintains as a product, running on
EKS Auto Mode. Its customers are Developers.
_Avoid_: DevEx platform, IDP (unless spelled out)

**EKS Auto Mode**:
The only compute runtime the Starter Kit supports (see ADR-0001). AWS manages nodes, networking,
load balancing, and storage; the Platform Team does not operate cluster machinery.
_Avoid_: EKS (unqualified, when the runtime mode matters)

**Developer**:
A software engineer on one of the customer's dev teams; the end user of the Platform.
_Avoid_: end user, app team (when referring to individuals)

**Dev Team**:
A stream-aligned software development team at the customer that consumes the Platform's services.
_Avoid_: app team, product team (overloaded)

**APEX**:
Agentic Platform Engineering eXperience — the project name, and the named chat persona ("Apex", a
platform engineer available 24×7) that is the Platform's front door. Runs as harness-portable
agent content (ADR-0013) through which Developers access the Catalog, golden paths, and guided
enablement. Replaces both the web portal (Backstage) and human enablement sessions of the pre-AI
era. Persona naming is deliberate branding for adoption (criteria #7).
_Avoid_: portal, IDP UI, chatbot (undersells it)

**Enablement**:
The guidance work APEX performs conversationally that platform teams previously delivered as
documentation portals and training sessions: explaining how to proceed, why standards exist
(requests/limits, health probes), and walking Developers through self-service journeys.
_Avoid_: support (reactive connotation), training (one-off connotation)

**APEX Skills**:
The curated agent skills from aws-samples/sample-apex-skills that equip the APEX agent with AWS
platform-engineering knowledge. Must be curated to agree with this kit's ADRs where they conflict.
_Avoid_: the skills repo (vague)

**Catalog**:
The machine-readable, semver-versioned list of golden-path artifacts (app templates and KRO types
with their parameter surfaces) published by the Platform Team. The only output space APEX can
instantiate from (ADR-0003).
_Avoid_: service catalog (Backstage connotation)

**Golden Path**:
A curated, versioned route from need to running service: app template + KRO type + the APEX
conversation that instantiates them. Going off it is allowed (trailblazers own their governance
targets); APEX never freehands it.
_Avoid_: paved road (synonym; pick one), best practice (vague)

**Harness**:
The packaged agent runtime a Developer runs APEX content in (agent loop, model access, tools,
memory, auth). Claude Code = reference harness; Kiro CLI = supported harness (ADR-0013). APEX is
content for harnesses, never a harness itself.
_Avoid_: client, CLI (underspecified)

**Foundation**:
The pre-platform layer (VPC, EKS cluster, IAM Identity Center, EKS Capabilities enablement)
provisioned once during the guided engagement via a bootstrap stack. Engagement tooling, not a
platform capability — Developers and APEX never touch it (ADR-0004).
_Avoid_: infrastructure (overloaded)
