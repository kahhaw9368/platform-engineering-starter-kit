# 0001 — EKS Auto Mode as the only supported compute runtime

## Status

Accepted (2026-07-16)

## Context

The Starter Kit is built by AWS (with the AWS container specialist team) to bootstrap customer
platform teams that have no existing platform. The technical TVP needs a Kubernetes runtime
decision. Options considered:

- **EKS with managed node groups** — most common today, but exposes the Platform Team to AMI
  lifecycle, node sizing, upgrade orchestration, and autoscaler configuration.
- **EKS + self-managed Karpenter** — powerful and flexible, but the Platform Team must operate
  Karpenter itself and own its configuration surface.
- **EKS Auto Mode** — AWS manages compute (Karpenter-based), networking, load balancing, storage
  add-ons, node lifecycle and patching; the Platform Team operates almost none of the underlying
  machinery.

The kit's target customer is a newly formed Platform Team, often upgraded from a DevOps team, with
no platform-operations experience. The kit's criteria framework demands maximum cognitive-load
reduction and "leverage managed services over bespoke builds."

## Decision

The Starter Kit supports **EKS Auto Mode only**. No managed node groups, no self-managed
Karpenter, no Fargate profiles as alternatives in the golden path.

## Consequences

- The Platform Team starts with the smallest possible operational surface — consistent with the
  Thinnest Viable Platform principle. Cluster compute, networking, and load balancing are AWS's
  problem, not theirs.
- The kit's docs, workshops, and IaC have exactly one runtime path — less to maintain, less to
  teach, no decision paralysis for the customer.
- Workloads with requirements Auto Mode doesn't cover (e.g., exotic instance constraints,
  DaemonSet-heavy patterns, GPU nuances beyond Auto Mode's support) are out of scope for the
  kit's golden path; such teams are "trailblazers" per the optionality principle and go beyond
  the kit deliberately.
- Auto Mode carries a compute-cost premium over self-managed nodes; the kit accepts this as the
  price of reduced operational load, and the week-zero material should state it openly.
- The kit is coupled to Auto Mode's capability roadmap; gaps close over time in AWS's favor.
