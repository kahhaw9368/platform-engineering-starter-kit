#!/usr/bin/env bash
# Welcome-splash seam test (T13/#14, agent split #24): SessionStart hook gating +
# single render. The hook must render the right splash (JSON systemMessage) ONLY
# for the apex/apex-manager agents on startup/clear, stay silent otherwise, and
# never break a session (always exit 0).
set -euo pipefail
KIT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
HOOK="$KIT_ROOT/apex/hooks/welcome-hook.sh"
WELCOME="$KIT_ROOT/apex/hooks/welcome.txt"
WELCOME_MGR="$KIT_ROOT/apex/hooks/welcome-manager.txt"

fail=0
ok()   { echo "ok   $*"; }
miss() { echo "MISS $*"; fail=1; }

run_hook() { printf '%s' "$1" | bash "$HOOK"; }

# The hook is registered in settings.json as a direct command — the exec bit is load-bearing.
if [ -x "$HOOK" ]; then ok "welcome-hook.sh is executable"; else miss "welcome-hook.sh not executable"; fi
if [ -f "$WELCOME" ]; then ok "welcome.txt exists next to the hook"; else miss "welcome.txt missing"; fi
if [ -f "$WELCOME_MGR" ]; then ok "welcome-manager.txt exists next to the hook"; else miss "welcome-manager.txt missing"; fi

assert_renders() { # label, payload, splash-file
  local out
  out="$(run_hook "$2")" || { miss "$1 exits 0"; return; }
  if printf '%s' "$out" | python3 -c '
import json, sys
d = json.load(sys.stdin)
assert d["suppressOutput"] is True, "suppressOutput not true"
assert d["systemMessage"] == open(sys.argv[1]).read(), "systemMessage != expected splash"
' "$3"; then
    ok "$1 renders valid JSON: systemMessage == $(basename "$3"), suppressOutput true"
  else
    miss "$1 JSON output"; printf 'hook stdout was: %s\n' "$out"
  fi
}

assert_silent() { # label, payload
  local out
  out="$(run_hook "$2")" || { miss "$1 exits 0"; return; }
  if [ -z "$out" ]; then ok "$1 silent"; else miss "$1 silent"; printf 'hook stdout was: %s\n' "$out"; fi
}

# --- renders: each agent gets its own splash on startup and clear ---
assert_renders "apex+startup" '{"agent_type":"apex","source":"startup"}' "$WELCOME"
assert_renders "apex+clear"   '{"agent_type":"apex","source":"clear"}' "$WELCOME"
assert_renders "apex-manager+startup" '{"agent_type":"apex-manager","source":"startup"}' "$WELCOME_MGR"
assert_renders "apex-manager+clear"   '{"agent_type":"apex-manager","source":"clear"}' "$WELCOME_MGR"
assert_renders "apex+startup (extra fields)" \
  '{"session_id":"abc","transcript_path":"/tmp/t.jsonl","cwd":"/x","hook_event_name":"SessionStart","agent_type":"apex","source":"startup"}' "$WELCOME"
assert_renders "apex+startup (pretty-printed)" '{
  "agent_type": "apex",
  "source": "startup"
}' "$WELCOME"

# --- silent: wrong agent, wrong source, lookalike payloads ---
assert_silent "non-apex agent"        '{"agent_type":"claude","source":"startup"}'
assert_silent "apex+resume"           '{"agent_type":"apex","source":"resume"}'
assert_silent "apex+compact"          '{"agent_type":"apex","source":"compact"}'
assert_silent "apex-manager+resume"   '{"agent_type":"apex-manager","source":"resume"}'
assert_silent "no agent_type"         '{"source":"startup"}'
assert_silent "apex prefix lookalike" '{"agent_type":"apex-other","source":"startup"}'
assert_silent "apex only in a string field" \
  '{"agent_type":"claude","source":"startup","note":"mentions \"agent_type\": \"apex\" in text"}'

# --- silent + exit 0: malformed / empty input must never break a session ---
assert_silent "malformed JSON" 'not json at all {{{'
assert_silent "empty input"    ''

# --- single render: the hook is the sole mechanism (T13 double-render fix) ---
# Tripwire for the exact defect: an agent definition instructing a verbatim
# re-render of the welcome file. Not proof against every rewording — review
# still applies.
for agent_def in "$KIT_ROOT"/apex/agents/*.md; do
  if grep -qiE "steering/welcome|welcome\.(md|txt)|verbatim" "$agent_def"; then
    miss "$(basename "$agent_def") must not re-render the welcome screen (hook is sole mechanism)"
  else
    ok "$(basename "$agent_def") does not re-render the welcome screen"
  fi
done

exit $fail
