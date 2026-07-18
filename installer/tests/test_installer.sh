#!/usr/bin/env bash
# Installer seam test (spec secondary seam): clean-dir install -> expected layout per harness.
set -euo pipefail
KIT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
python3 -c 'import yaml, jsonschema' 2>/dev/null \
  || { echo "python3 with pyyaml + jsonschema is required (render-from-installed-copy check)" >&2; exit 1; }
FAKE_HOME="$(mktemp -d)"
trap 'rm -rf "$FAKE_HOME"' EXIT

mkdir -p "$FAKE_HOME/.claude" "$FAKE_HOME/.kiro"   # both harnesses present
node "$KIT_ROOT/installer/install.js" --source "$KIT_ROOT" --home "$FAKE_HOME"

fail=0
check() { if [ -e "$1" ]; then echo "ok   $1"; else echo "MISS $1"; fail=1; fi; }
# Claude Code layout
check "$FAKE_HOME/.claude/skills/catalog-browse/SKILL.md"
check "$FAKE_HOME/.claude/skills/scaffold-service/SKILL.md"
check "$FAKE_HOME/.claude/skills/platform-as-product/SKILL.md"
check "$FAKE_HOME/.claude/apex/rules/apex-rules.md"
check "$FAKE_HOME/.claude/apex/steering/welcome.md"
check "$FAKE_HOME/.claude/agents/apex.md"
check "$FAKE_HOME/.claude/agents/apex-manager.md"
check "$FAKE_HOME/.claude/apex/hooks/welcome-hook.sh"
check "$FAKE_HOME/.claude/apex/hooks/welcome.txt"
check "$FAKE_HOME/.claude/apex/hooks/welcome-manager.txt"
# Kit materials (#25): installed-only machines must be able to render + validate
check "$FAKE_HOME/.claude/apex/kit/platform/catalog/catalog.yaml"
check "$FAKE_HOME/.claude/apex/kit/platform/catalog/harness/render.py"
check "$FAKE_HOME/.claude/apex/kit/platform/guardrails/policies.py"
if find "$FAKE_HOME/.claude/apex/kit" -name __pycache__ | grep -q .; then
  echo "MISS __pycache__ leaked into kit materials"; fail=1
else
  echo "ok   kit materials exclude __pycache__"
fi
# The seam that matters: a render from the installed copy alone must succeed
RENDER_OUT="$(mktemp -d)"
if python3 "$FAKE_HOME/.claude/apex/kit/platform/catalog/harness/render.py" \
    --catalog "$FAKE_HOME/.claude/apex/kit/platform/catalog/catalog.yaml" \
    --item dummy-item --param widget_name=seamtest --param team=seam-team \
    --out "$RENDER_OUT" >/dev/null 2>&1; then
  echo "ok   render harness works from installed kit copy"
else
  echo "MISS render from installed kit copy"; fail=1
fi
rm -rf "$RENDER_OUT"
grep -q "welcome-hook.sh" "$FAKE_HOME/.claude/settings.json" && echo "ok   welcome hook merged into settings.json" || { echo "MISS welcome hook in settings"; fail=1; }
node "$KIT_ROOT/installer/install.js" --source "$KIT_ROOT" --home "$FAKE_HOME" > /dev/null
[ "$(grep -c welcome-hook.sh "$FAKE_HOME/.claude/settings.json")" = "1" ] && echo "ok   hook install idempotent" || { echo "MISS idempotency"; fail=1; }
# Kiro layout (ADR-0013 verification)
check "$FAKE_HOME/.kiro/skills/catalog-browse/SKILL.md"
check "$FAKE_HOME/.kiro/steering/apex-rules.md"
check "$FAKE_HOME/.kiro/steering/welcome.md"
check "$FAKE_HOME/.kiro/apex/kit/platform/catalog/catalog.yaml"
# Claude-only machine
CC_HOME="$(mktemp -d)"; mkdir -p "$CC_HOME/.claude"
node "$KIT_ROOT/installer/install.js" --source "$KIT_ROOT" --home "$CC_HOME" | grep -q "claude-code"
[ ! -d "$CC_HOME/.kiro/skills" ] && echo "ok   kiro skipped on claude-only machine" || fail=1
rm -rf "$CC_HOME"
exit $fail
