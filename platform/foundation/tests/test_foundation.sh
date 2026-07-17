#!/usr/bin/env bash
# Foundation seam test (T16/#18): offline guard for the bootstrap surface.
# No AWS credentials by design: aws/gh/eksctl/kubectl are stubs that accept only
# the read-only calls the no-VPC_ID dry-run path makes and exit 99 on anything
# else, so the seam also proves --dry-run mutates nothing. Not covered here:
# the VPC_ID dry-run branch (needs ec2 describe-vpcs/subnets), and git — real
# git stays on PATH; the dry-run path only reads the local remote URL, and even
# that is skipped because STARTER_KIT_REPO is always set below.
set -euo pipefail
KIT_ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
FOUNDATION="$KIT_ROOT/platform/foundation"
STUBS="$(mktemp -d)"
WORK="$(mktemp -d)"
trap 'rm -rf "$STUBS" "$WORK"' EXIT
ENVS=(nonprod prod)

fail=0
ok()   { echo "ok   $*"; }
miss() { echo "MISS $*"; fail=1; }

command -v shellcheck >/dev/null || { echo "shellcheck is required" >&2; exit 1; }
python3 -c 'import yaml' 2>/dev/null || { echo "python3 with pyyaml is required" >&2; exit 1; }

# ---------- shellcheck ----------
for f in "$FOUNDATION/bootstrap.sh" "$FOUNDATION/tests/test_foundation.sh"; do
  if shellcheck "$f"; then ok "shellcheck ${f#"$KIT_ROOT"/}"; else miss "shellcheck ${f#"$KIT_ROOT"/}"; fi
done

# ---------- stub CLIs: the dry-run's entire allowed AWS/GitHub surface ----------
cat > "$STUBS/aws" <<'EOF'
#!/bin/bash
if [[ "${1:-} ${2:-}" == "sts get-caller-identity" ]]; then echo 123456789012; exit 0; fi
echo "STUB aws refused (dry-run must stay read-only): $*" >&2; exit 99
EOF
cat > "$STUBS/gh" <<'EOF'
#!/bin/bash
if [[ "${1:-} ${2:-}" == "auth status" ]]; then exit 0; fi
echo "STUB gh refused: $*" >&2; exit 99
EOF
cat > "$STUBS/eksctl" <<'EOF'
#!/bin/bash
DRY=false; CFG=""
while [[ $# -gt 0 ]]; do
  case "$1" in --dry-run) DRY=true ;; -f) CFG=$2; shift ;; esac
  shift
done
$DRY || { echo "STUB eksctl refused non-dry-run call" >&2; exit 99; }
[[ -s "$CFG" ]] || { echo "STUB eksctl: config '$CFG' missing or empty" >&2; exit 99; }
EOF
cat > "$STUBS/kubectl" <<'EOF'
#!/bin/bash
echo "STUB kubectl refused (dry-run must not touch a cluster): $*" >&2; exit 99
EOF
chmod +x "$STUBS"/{aws,gh,eksctl,kubectl}
# /usr/bin:/bin keeps coreutils/git but hides real aws/eksctl/kubectl installs
# (/usr/local/bin, homebrew) so only the stubs are visible to bootstrap.
SEAM_PATH="$STUBS:/usr/bin:/bin"

# ---------- dry-run end to end ----------
set +e
OUT=$(env -u VPC_ID -u IDC_INSTANCE_ARN -u IDC_REGION PATH="$SEAM_PATH" \
      REGION=ap-southeast-1 GITOPS_REPO=ci-org/platform-gitops \
      STARTER_KIT_REPO=ci-org/starter-kit PLATFORM_TEAM_HANDLE=ci-org/platform-team \
      OUT_DIR="$WORK" \
      bash "$FOUNDATION/bootstrap.sh" --dry-run </dev/null 2>&1)
RC=$?
set -e
if [[ $RC -eq 0 ]]; then ok "dry-run exits 0"; else miss "dry-run exit code $RC"; echo "$OUT"; fi
expect() { if grep -qF "$1" <<<"$OUT"; then ok "$2"; else miss "$2 — expected: $1"; fi; }
expect "2. Clusters: platform-nonprod + platform-prod" "plan covers clusters"
expect "ARGOCD on platform-nonprod"                    "plan covers capabilities (Argo CD hub)"
expect "ACK + KRO on both clusters"                    "plan covers capabilities (ACK/KRO)"
expect "4. GitOps repo: ci-org/platform-gitops"        "plan covers GitOps repo"
expect "5. CI OIDC role: platform-ci"                  "plan covers CI role"
for ENV in "${ENVS[@]}"; do
  expect "eksctl accepts $WORK/cluster-$ENV.yaml"      "eksctl validated rendered $ENV config"
done
expect "dry-run complete — nothing was created"        "dry-run terminates cleanly"

# ---------- rendered configs: valid YAML, Auto Mode on, markers filled ----------
for ENV in "${ENVS[@]}"; do
  CFG="$WORK/cluster-$ENV.yaml"
  if [[ -f "$CFG" ]] && ! grep -q '{{' "$CFG" && python3 - "$CFG" "$ENV" <<'PY'
import sys, yaml
cfg = yaml.safe_load(open(sys.argv[1]))
env = sys.argv[2]
assert cfg["autoModeConfig"]["enabled"] is True, "Auto Mode not enabled"
assert cfg["metadata"]["name"] == f"platform-{env}", cfg["metadata"]["name"]
assert cfg["metadata"]["region"] == "ap-southeast-1", cfg["metadata"]["region"]
PY
  then ok "rendered cluster-$ENV.yaml: valid YAML, Auto Mode enabled, no unfilled markers"
  else miss "rendered cluster-$ENV.yaml"; fi
done

# ---------- preflight failure: missing env var, actionable message ----------
for VAR in REGION GITOPS_REPO; do
  if [[ "$VAR" == REGION ]]; then KEEP="GITOPS_REPO=ci-org/platform-gitops"
  else KEEP="REGION=ap-southeast-1"; fi
  set +e
  OUT=$(env -u REGION -u GITOPS_REPO PATH="$SEAM_PATH" "$KEEP" OUT_DIR="$WORK" \
        bash "$FOUNDATION/bootstrap.sh" --dry-run </dev/null 2>&1)
  RC=$?
  set -e
  if [[ $RC -ne 0 ]] && grep -q "set $VAR" <<<"$OUT"; then
    ok "missing $VAR fails non-zero with actionable message"
  else miss "missing $VAR (rc=$RC)"; echo "$OUT"; fi
done

# ---------- preflight failure: missing tool, actionable message ----------
rm "$STUBS/eksctl"
set +e
OUT=$(env PATH="$SEAM_PATH" REGION=ap-southeast-1 GITOPS_REPO=ci-org/platform-gitops \
      OUT_DIR="$WORK" \
      bash "$FOUNDATION/bootstrap.sh" --dry-run </dev/null 2>&1)
RC=$?
set -e
if [[ $RC -ne 0 ]] && grep -q "missing tool: eksctl" <<<"$OUT" && grep -q "prerequisites" <<<"$OUT"; then
  ok "missing tool fails non-zero pointing at README prerequisites"
else miss "missing tool (rc=$RC)"; echo "$OUT"; fi

exit $fail
