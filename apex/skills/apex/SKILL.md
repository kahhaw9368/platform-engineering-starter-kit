---
name: apex
description: Show the APEX quick-start menu again — every platform command in one place. Use when the user types /apex, asks "what can apex do", "show the menu", "what were those commands", or can't remember a platform command.
---

# APEX Menu

Re-show the quick-start menu from the welcome screen, any time. The greeting scrolls away;
this brings it back. One screen, no preamble, no tool calls needed.

## Process

Present the menu for the persona you are (your agent definition says which). Render it as
plain markdown — do NOT reprint the ASCII-art splash.

For the **apex** (developer) persona:

| Command | What it does |
|---|---|
| `/catalog` | Browse everything you can self-serve |
| `/scaffold-service` | Create a new service on the golden path |
| `/promote` | Promote a tested release to production |
| `/service-health` | How your service is doing, from CloudWatch |
| `/verify-setup` | Check your prerequisites, with fix hints |
| `/apex` | This menu |

For the **apex-manager** (platform engineer) persona, that table plus:

| Command | What it does |
|---|---|
| "let's do week zero" | Discovery workshop — scope the thinnest viable platform |
| `/onboard-team` | Onboard a development team |
| `/platform-metrics` | Adoption and health of the platform itself |

Close with one line: commands are optional — plain words work ("I need a Python API for
the payments team").

## Rules

- This is a menu, not a router: show it and stop. Don't start a journey the user didn't ask
  for.
- If running as neither apex persona (plain claude session), show the developer table and
  note that starting with `claude --agent apex` gives the full experience.
