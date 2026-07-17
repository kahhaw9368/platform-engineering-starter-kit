#!/usr/bin/env bash
# Installer seam test (spec secondary seam): clean-dir install -> expected layout per harness.
set -euo pipefail
KIT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
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
check "$FAKE_HOME/.claude/apex/hooks/welcome-hook.sh"
grep -q "welcome-hook.sh" "$FAKE_HOME/.claude/settings.json" && echo "ok   welcome hook merged into settings.json" || { echo "MISS welcome hook in settings"; fail=1; }
node "$KIT_ROOT/installer/install.js" --source "$KIT_ROOT" --home "$FAKE_HOME" > /dev/null
[ "$(grep -c welcome-hook.sh "$FAKE_HOME/.claude/settings.json")" = "1" ] && echo "ok   hook install idempotent" || { echo "MISS idempotency"; fail=1; }
# Kiro layout (ADR-0013 verification)
check "$FAKE_HOME/.kiro/skills/catalog-browse/SKILL.md"
check "$FAKE_HOME/.kiro/steering/apex-rules.md"
check "$FAKE_HOME/.kiro/steering/welcome.md"
# Claude-only machine
CC_HOME="$(mktemp -d)"; mkdir -p "$CC_HOME/.claude"
node "$KIT_ROOT/installer/install.js" --source "$KIT_ROOT" --home "$CC_HOME" | grep -q "claude-code"
[ ! -d "$CC_HOME/.kiro/skills" ] && echo "ok   kiro skipped on claude-only machine" || fail=1
rm -rf "$CC_HOME"
exit $fail
