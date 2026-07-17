#!/usr/bin/env bash
# Foundation bootstrap (T6/#7) — run BY THE ENGAGEMENT TEAM, once per customer.
# PROVISIONAL: EKS Capabilities enablement commands to be confirmed with the container
# specialist team; written to the documented capability model (managed Argo CD / ACK / KRO).
set -euo pipefail
: "${REGION:?set REGION}"; : "${GITOPS_REPO:?set GITOPS_REPO (org/repo)}"

for ENV in nonprod prod; do
  echo "== cluster: platform-$ENV"
  sed -e "s/{{env}}/$ENV/g" -e "s/{{region}}/$REGION/g" cluster.eksctl.yaml > "/tmp/cluster-$ENV.yaml"
  eksctl create cluster -f "/tmp/cluster-$ENV.yaml"
done

echo "== EKS Capabilities (PROVISIONAL command shapes — confirm at engagement)"
# Managed Argo CD capability: hub on nonprod account scope, both clusters registered,
# IdC SSO + CodeConnections to $GITOPS_REPO. Expected shape:
#   aws eks create-capability --name argocd --type ARGOCD ...
# Managed ACK + KRO capabilities on both clusters:
#   aws eks create-capability --name ack --type ACK --cluster platform-$ENV ...
#   aws eks create-capability --name kro --type KRO --cluster platform-$ENV ...
echo "   (see engagement runbook; fill exact commands during specialist validation)"

echo "== GitOps repo bootstrap"
# Instantiate platform/gitops/reference/ into $GITOPS_REPO with branch protection +
# required 'guardrails / policy-check' status check + CODEOWNERS (T5 layout).
echo "   gh repo create $GITOPS_REPO ... (reference layout copy; see T5 README)"

echo "== OIDC role for CI (artifact contract, ADR-0005)"
# Creates the ci role trusted by the customer's forge OIDC provider, ECR push scoped.
echo "   (role ARN feeds the web-api template's ci_role_arn parameter)"

echo "== smoke checklist -> smoke.md"
