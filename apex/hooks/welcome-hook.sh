#!/usr/bin/env bash
# APEX welcome splash (SessionStart hook). Fires only for the apex agent on
# fresh sessions. Uses JSON systemMessage — plain stdout goes to model
# context, not the user's terminal. Must never break a session: exit 0 and
# stay silent on any parse/read failure.
python3 -c '
import json, sys
try:
    event = json.loads(sys.stdin.read())
    if event.get("agent_type") == "apex" and event.get("source") in ("startup", "clear"):
        print(json.dumps({"systemMessage": open(sys.argv[1]).read(),
                          "suppressOutput": True}))
except Exception:
    pass
' "$(dirname "$0")/welcome.txt" 2>/dev/null
exit 0
