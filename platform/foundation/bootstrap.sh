#!/usr/bin/env bash
# Foundation bootstrap (ADR-0004) — run BY THE ENGAGEMENT TEAM, once per customer.
# Engagement tooling, not a platform capability: Developers and APEX never touch it.
# Idempotent: safe to re-run after a partial failure; existing resources are skipped.
#
# Usage:
#   REGION=ap-southeast-1 GITOPS_REPO=org/repo PLATFORM_TEAM_HANDLE=org/platform-team \
#   IDC_INSTANCE_ARN=arn:aws:sso:::instance/ssoins-... \
#     ./bootstrap.sh --dry-run     # print the full plan, mutate nothing
#     ./bootstrap.sh               # provision for real (2 clusters ~20 min each, serial ~40 min)
#
# Optional:
#   VPC_ID=vpc-...      build into an existing VPC (validated live); unset = new VPC per
#                       cluster. Interactive sessions are prompted when unset.
#   IDC_REGION=...      IAM Identity Center home region, if different from REGION
#   STARTER_KIT_REPO=.. org/repo of this starter kit (default: derived from git remote)
#   OUT_DIR=...         directory for rendered cluster configs (default: /tmp)
set -euo pipefail
cd "$(dirname "$0")"

case "${1:-}" in
  --dry-run) DRY_RUN=true ;;
  "")        DRY_RUN=false ;;
  *)         echo "FAIL: unknown argument: $1 (only --dry-run is supported)" >&2; exit 1 ;;
esac

ENVS=(nonprod prod)
HUB_ENV=nonprod   # managed Argo CD hub (ADR-0004/0007)
OUT_DIR=${OUT_DIR:-/tmp}
# ACK day-0 permission scope = the v1 catalog's service surface (ADR-0014): the Team type
# provisions ECR repos; WebService wires S3/SQS/DynamoDB; dashboards write CloudWatch.
# Deliberately broad on day 0; tighten with IAM Role Selectors before first prod tenant.
ACK_POLICIES=(AmazonEC2ContainerRegistryFullAccess AmazonS3FullAccess AmazonSQSFullAccess
              AmazonDynamoDBFullAccess CloudWatchFullAccessV2)

fail() { echo "FAIL: $*" >&2; exit 1; }
note() { echo "== $*"; }

# ---------- preflight (fails in seconds, before any AWS mutation) ----------
note "preflight"
for tool in aws eksctl kubectl gh git; do
  command -v "$tool" >/dev/null || fail "missing tool: $tool — see platform/foundation/README.md prerequisites"
done
K8S_VERSION=$(grep -E '^[[:space:]]+version:' cluster.eksctl.yaml | tr -d ' "' | cut -d: -f2)
: "${REGION:?set REGION (e.g. ap-southeast-1)}"
: "${GITOPS_REPO:?set GITOPS_REPO (org/repo for the GitOps repo Argo CD watches)}"
if ! $DRY_RUN; then
  : "${IDC_INSTANCE_ARN:?set IDC_INSTANCE_ARN (IAM Identity Center instance ARN — required by the managed Argo CD capability)}"
  : "${PLATFORM_TEAM_HANDLE:?set PLATFORM_TEAM_HANDLE (GitHub team/user that owns prod files, e.g. org/platform-team)}"
fi
IDC_REGION=${IDC_REGION:-$REGION}
STARTER_KIT_REPO=${STARTER_KIT_REPO:-$(git remote get-url origin 2>/dev/null \
  | sed -E 's#^(git@github\.com:|https://github\.com/)##; s#\.git$##')}
[[ -n "$STARTER_KIT_REPO" ]] || fail "cannot derive STARTER_KIT_REPO from git remote — set it explicitly"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text 2>/dev/null) \
  || fail "no valid AWS credentials — run: aws sso login"
gh auth status >/dev/null 2>&1 || fail "gh not authenticated — run: gh auth login"
echo "   account=$ACCOUNT_ID region=$REGION gitops=$GITOPS_REPO kit=$STARTER_KIT_REPO k8s=$K8S_VERSION"

# ---------- VPC choice ----------
note "VPC choice"
if [[ -z "${VPC_ID:-}" && -t 0 ]]; then
  echo "   Existing VPCs in $REGION (enter a vpc-id to use one, or press Enter for a new VPC):"
  # shellcheck disable=SC2016  # backticks are JMESPath literals, not shell expansion
  aws ec2 describe-vpcs --region "$REGION" \
    --query 'Vpcs[].{id:VpcId,cidr:CidrBlock,name:Tags[?Key==`Name`]|[0].Value}' --output table
  read -r -p "   VPC id [new]: " VPC_ID
  [[ -n "$VPC_ID" ]] && echo "   (for a reproducible/non-interactive run: VPC_ID=$VPC_ID ./bootstrap.sh)"
fi

VPC_BLOCK=""
if [[ -n "${VPC_ID:-}" ]]; then
  aws ec2 describe-vpcs --region "$REGION" --vpc-ids "$VPC_ID" >/dev/null \
    || fail "VPC $VPC_ID not found in $REGION"
  # One fetch; keyed by subnet id so same-AZ subnets can't collide (eksctl allows named keys)
  SUBNETS=$(aws ec2 describe-subnets --region "$REGION" \
    --filters "Name=vpc-id,Values=$VPC_ID" \
    --query 'Subnets[].[AvailabilityZone,SubnetId,MapPublicIpOnLaunch]' --output text)
  PRIVATE_AZ_COUNT=$(awk '$3=="False"{print $1}' <<<"$SUBNETS" | sort -u | grep -c . || true)
  # Auto Mode nodes need private subnets across >=2 AZs
  [[ "$PRIVATE_AZ_COUNT" -ge 2 ]] || fail "VPC $VPC_ID has private subnets in $PRIVATE_AZ_COUNT AZ(s); need >=2"
  VPC_BLOCK=$(
    echo "vpc:"
    echo "  id: $VPC_ID"
    echo "  subnets:"
    for SCOPE in private public; do
      [[ "$SCOPE" == private ]] && FLAG=False || FLAG=True
      LIST=$(awk -v f="$FLAG" '$3==f{print $1, $2}' <<<"$SUBNETS")
      [[ -n "$LIST" ]] || continue   # e.g. private-only enterprise VPC: omit empty scope
      echo "    $SCOPE:"
      while read -r AZ ID; do echo "      $ID: { id: $ID, az: $AZ }"; done <<<"$LIST"
    done
  )
  echo "   existing VPC $VPC_ID — private subnets span $PRIVATE_AZ_COUNT AZs"
else
  echo "   new VPC per cluster (eksctl-managed, CIDR 192.168.0.0/16, single NAT gateway)"
fi

# ---------- render cluster configs ----------
note "render cluster configs"
for ENV in "${ENVS[@]}"; do
  sed -e "s/{{env}}/$ENV/g" -e "s/{{region}}/$REGION/g" cluster.eksctl.yaml > "$OUT_DIR/cluster-$ENV.yaml"
  [[ -n "$VPC_BLOCK" ]] && echo "$VPC_BLOCK" >> "$OUT_DIR/cluster-$ENV.yaml"
  grep -q '{{' "$OUT_DIR/cluster-$ENV.yaml" && fail "unfilled template markers in $OUT_DIR/cluster-$ENV.yaml"
  echo "   rendered $OUT_DIR/cluster-$ENV.yaml"
done

# ---------- plan ----------
note "plan"
cat <<PLAN
   1. VPC: ${VPC_ID:+existing $VPC_ID}${VPC_ID:-new (eksctl creates one per cluster, 192.168.0.0/16, single NAT)}
   2. Clusters: platform-nonprod + platform-prod — EKS Auto Mode, k8s $K8S_VERSION, region $REGION
      (serial, ~20 min each — expect ~40 min total)
   3. EKS Capabilities:
        ARGOCD on platform-$HUB_ENV (hub; IdC SSO via IDC_INSTANCE_ARN, IdC region $IDC_REGION)
        ACK + KRO on both clusters (roles trusted by capabilities.eks.amazonaws.com)
        ACK day-0 policies: ${ACK_POLICIES[*]}
   4. GitOps repo: $GITOPS_REPO from ../gitops/reference, placeholders rendered
      (starter_kit_repo=$STARTER_KIT_REPO, platform_team_handle=${PLATFORM_TEAM_HANDLE:-<real run only>}),
      branch protection + required 'guardrails / policy-check' + CODEOWNERS
   5. CI OIDC role: platform-ci trusted by GitHub Actions OIDC for repo:${GITOPS_REPO%%/*}/*
      (service repos build the images — tighten to specific repos at engagement), ECR push only
PLAN

if $DRY_RUN; then
  note "dry-run: validating rendered configs with eksctl (read-only)"
  for ENV in "${ENVS[@]}"; do
    eksctl create cluster -f "$OUT_DIR/cluster-$ENV.yaml" --dry-run >/dev/null || fail "eksctl rejected $OUT_DIR/cluster-$ENV.yaml"
    echo "   eksctl accepts $OUT_DIR/cluster-$ENV.yaml"
  done
  note "dry-run complete — nothing was created"
  exit 0
fi

# ---------- 2. clusters ----------
for ENV in "${ENVS[@]}"; do
  if aws eks describe-cluster --region "$REGION" --name "platform-$ENV" >/dev/null 2>&1; then
    note "cluster: platform-$ENV already exists — skipping"
  else
    note "cluster: platform-$ENV (~20 min)"
    eksctl create cluster -f "$OUT_DIR/cluster-$ENV.yaml"
  fi
done

# ---------- 3. capability roles + capabilities ----------
note "EKS Capabilities"
TRUST='{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":"capabilities.eks.amazonaws.com"},"Action":["sts:AssumeRole","sts:TagSession"]}]}'
capability_role() { # name policies...
  local NAME=$1; shift
  aws iam get-role --role-name "$NAME" >/dev/null 2>&1 || \
    aws iam create-role --role-name "$NAME" --assume-role-policy-document "$TRUST" \
      --tags Key=starterkit.aws/layer,Value=foundation >/dev/null
  local P; for P in "$@"; do
    aws iam attach-role-policy --role-name "$NAME" --policy-arn "arn:aws:iam::aws:policy/$P"
  done
  echo "arn:aws:iam::$ACCOUNT_ID:role/$NAME"
}
ensure_capability() { # cluster name type role-arn [extra args...]
  local CLUSTER=$1 NAME=$2 TYPE=$3 ROLE=$4; shift 4
  if aws eks describe-capability --region "$REGION" --cluster-name "$CLUSTER" \
       --capability-name "$NAME" >/dev/null 2>&1; then
    echo "   $NAME on $CLUSTER already exists — skipping"
  else
    aws eks create-capability --region "$REGION" \
      --capability-name "$NAME" --cluster-name "$CLUSTER" --type "$TYPE" \
      --role-arn "$ROLE" --delete-propagation-policy RETAIN "$@"
  fi
}
ARGOCD_ROLE=$(capability_role platform-capability-argocd)          # no perms needed by default
KRO_ROLE=$(capability_role platform-capability-kro)                # kro needs none
ACK_ROLE=$(capability_role platform-capability-ack "${ACK_POLICIES[@]}")

ensure_capability "platform-$HUB_ENV" argocd ARGOCD "$ARGOCD_ROLE" \
  --configuration "{\"argoCd\":{\"awsIdc\":{\"idcInstanceArn\":\"$IDC_INSTANCE_ARN\",\"idcRegion\":\"$IDC_REGION\"}}}"
for ENV in "${ENVS[@]}"; do
  ensure_capability "platform-$ENV" ack ACK "$ACK_ROLE"
  ensure_capability "platform-$ENV" kro KRO "$KRO_ROLE"
done

# ---------- 4. GitOps repo ----------
note "GitOps repo: $GITOPS_REPO"
if ! gh repo view "$GITOPS_REPO" >/dev/null 2>&1; then
  gh repo create "$GITOPS_REPO" --private
  TMP=$(mktemp -d)
  cp -R ../gitops/reference/. "$TMP/"
  # Render layout placeholders (platform/gitops/README.md: "filled at Foundation bootstrap")
  find "$TMP" -type f -exec sed -i.bak \
    -e "s#{{starter_kit_repo}}#$STARTER_KIT_REPO#g" \
    -e "s#{{platform_team_handle}}#$PLATFORM_TEAM_HANDLE#g" {} +
  find "$TMP" -name '*.bak' -delete
  grep -rq '{{' "$TMP" && fail "unfilled template markers in rendered GitOps layout"
  git -C "$TMP" init -q -b main && git -C "$TMP" add -A
  git -C "$TMP" commit -qm "GitOps reference layout (starter kit foundation bootstrap)"
  git -C "$TMP" remote add origin "https://github.com/$GITOPS_REPO.git"
  git -C "$TMP" push -qu origin main
  rm -rf "$TMP"
fi
gh api --method PUT "repos/$GITOPS_REPO/branches/main/protection" --input - <<'JSON'
{"required_status_checks":{"strict":true,"contexts":["guardrails / policy-check"]},
 "enforce_admins":false,
 "required_pull_request_reviews":{"require_code_owner_reviews":true},
 "restrictions":null,
 "allow_force_pushes":false,
 "allow_deletions":false}
JSON

# ---------- 5. CI OIDC role (artifact contract, ADR-0005) ----------
note "CI OIDC role"
OIDC_ARN="arn:aws:iam::$ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
aws iam get-open-id-connect-provider --open-id-connect-provider-arn "$OIDC_ARN" >/dev/null 2>&1 || \
  aws iam create-open-id-connect-provider --url https://token.actions.githubusercontent.com \
    --client-id-list sts.amazonaws.com >/dev/null
# Scaffolded SERVICE repos assume this role from their CI (web-api template), so trust the
# whole org, not just the GitOps repo. Tighten to an explicit repo list at engagement.
# Two sub patterns: GitHub OIDC tokens may carry the plain owner/repo form or the
# immutable-ID form (owner@id/repo@id) — trust must match both or CI gets AccessDenied.
CI_TRUST=$(cat <<JSON
{"Version":"2012-10-17","Statement":[{"Effect":"Allow",
 "Principal":{"Federated":"$OIDC_ARN"},
 "Action":"sts:AssumeRoleWithWebIdentity",
 "Condition":{"StringEquals":{"token.actions.githubusercontent.com:aud":"sts.amazonaws.com"},
              "StringLike":{"token.actions.githubusercontent.com:sub":
                ["repo:${GITOPS_REPO%%/*}/*","repo:${GITOPS_REPO%%/*}@*/*"]}}}]}
JSON
)
aws iam get-role --role-name platform-ci >/dev/null 2>&1 || \
  aws iam create-role --role-name platform-ci --assume-role-policy-document "$CI_TRUST" >/dev/null
# Existing roles created by an earlier bootstrap keep their old (single-pattern) trust;
# refresh it so re-runs heal the AccessDenied case too.
aws iam update-assume-role-policy --role-name platform-ci --policy-document "$CI_TRUST"
aws iam put-role-policy --role-name platform-ci --policy-name ecr-push --policy-document "$(cat <<JSON
{"Version":"2012-10-17","Statement":[
 {"Effect":"Allow","Action":"ecr:GetAuthorizationToken","Resource":"*"},
 {"Effect":"Allow","Action":["ecr:BatchCheckLayerAvailability","ecr:PutImage",
  "ecr:InitiateLayerUpload","ecr:UploadLayerPart","ecr:CompleteLayerUpload"],
  "Resource":"arn:aws:ecr:$REGION:$ACCOUNT_ID:repository/*"}]}
JSON
)"
echo "   ci_role_arn: arn:aws:iam::$ACCOUNT_ID:role/platform-ci (feeds the web-api template)"

note "done — NEXT STEPS (manual, in order)"
cat <<'NEXT'
   1. Authorize the Argo CD hub's Git connection to the GitOps repo (console approval)
      and register the prod cluster with the hub.
   2. Map IdC groups to cluster RBAC via EKS access entries (Dev Teams + Platform Team),
      and to Argo CD roles (update-capability --configuration rbacRoleMappings).
   3. Publish the catalog RGDs into the GitOps repo's platform/ folder and wire the Argo CD
      ApplicationSets so both clusters sync them (smoke.md checks `kubectl api-resources`).
   4. Tighten the ACK role from day-0 policies to IAM Role Selectors, and the platform-ci
      trust from org-wide to explicit service repos, before first prod tenant.
   5. Run the smoke checklist: platform/foundation/smoke.md — every box before week one.
NEXT
