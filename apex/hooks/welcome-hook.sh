#!/usr/bin/env bash
# APEX welcome splash (SessionStart hook). Fires only for the apex agent on
# fresh sessions; stdout renders in the user's terminal before first input.
INPUT="$(cat)"
AGENT=$(printf '%s' "$INPUT" | sed -n 's/.*"agent_type"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
SOURCE=$(printf '%s' "$INPUT" | sed -n 's/.*"source"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
if [ "$AGENT" = "apex" ] && { [ "$SOURCE" = "startup" ] || [ "$SOURCE" = "clear" ]; }; then
  cat "$(dirname "$0")/welcome.txt"
fi
exit 0
