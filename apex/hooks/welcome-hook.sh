#!/usr/bin/env bash
# APEX welcome splash (SessionStart hook). Fires only for the apex agents on
# fresh sessions — each agent gets its own splash file. Uses JSON systemMessage
# — plain stdout goes to model context, not the user's terminal. Must never
# break a session: exit 0 and stay silent on any parse/read failure.
python3 -c '
import json, os, sys
SPLASH = {"apex": "welcome.txt", "apex-manager": "welcome-manager.txt"}
try:
    event = json.loads(sys.stdin.read())
    name = SPLASH.get(event.get("agent_type"))
    if name and event.get("source") in ("startup", "clear"):
        text = open(os.path.join(sys.argv[1], name)).read()
        print(json.dumps({"systemMessage": text, "suppressOutput": True}))
except Exception:
    pass
' "$(dirname "$0")" 2>/dev/null
exit 0
