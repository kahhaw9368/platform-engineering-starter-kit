#!/usr/bin/env bash
# APEX welcome splash (SessionStart hook). Fires only for the apex agent on
# fresh sessions. Uses JSON systemMessage — plain stdout goes to model
# context, not the user's terminal.
INPUT="$(cat)"
AGENT=$(printf '%s' "$INPUT" | sed -n 's/.*"agent_type"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
SOURCE=$(printf '%s' "$INPUT" | sed -n 's/.*"source"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
if [ "$AGENT" = "apex" ] && { [ "$SOURCE" = "startup" ] || [ "$SOURCE" = "clear" ]; }; then
  python3 - "$(dirname "$0")/welcome.txt" <<'PY'
import json, sys
print(json.dumps({"systemMessage": open(sys.argv[1]).read(),
                  "suppressOutput": True}))
PY
fi
exit 0
