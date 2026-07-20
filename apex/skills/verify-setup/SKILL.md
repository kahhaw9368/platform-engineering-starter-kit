---
name: verify-setup
description: Verify a Developer's prerequisites for using the platform — harness, git access, AWS IAM Identity Center login. Use when the user asks to verify/check their setup, says something isn't working before their first journey, or invokes /verify-setup.
---

# Verify Setup

Check each prerequisite and report pass/fail with a fix hint. Run checks with the Bash tool;
never guess. Report ALL results (don't stop at first failure), then summarize.

A day-one Developer runs this from an empty directory, before they have any service — that
is the *expected* state, not a problem. Only report something as needing a fix when it
actually blocks a journey. Never make a fresh, correct setup look broken.

## Checks

1. **Agent harness** — you are running, so the harness exists; report which one (Claude Code /
   Kiro CLI) and its version (`claude --version` / `kiro --version`).
2. **git** — `git --version`. Fix hint: install git.
   (Do NOT warn about the current directory not being a repo — Developers work from anywhere
   until they have a scaffolded service. See "location awareness" below.)
3. **GitHub CLI (or the customer's forge CLI)** — `gh auth status`.
   Fix hint: `gh auth login`. If the customer uses GitLab/Bitbucket, check the equivalent
   (`glab auth status`) — read `.apex/context.yaml` for a `forge` key if present.
4. **AWS credentials via IAM Identity Center** — `aws sts get-caller-identity`.
   Fix hint: `aws sso login` (profile name from `.apex/context.yaml` `aws_profile` key, if set).
5. **Catalog reachable** — locate the catalog per the catalog-browse order (repo
   `catalog_path` → kit checkout → installed copy at `~/.claude/apex/kit/` or
   `~/.kiro/apex/kit/`) and confirm the file parses. Also
   `python3 -c "import yaml, jsonschema"` — the render harness needs both.
   Fix hints: `npx github:kahhaw9368/platform-engineering-starter-kit --update` /
   `pip3 install pyyaml jsonschema`.

## Location awareness (report as context, never as a fix)

After the checks, state where the user is in one line, matter-of-factly:

- Inside a scaffolded service repo (`.apex/context.yaml` present): confirm its
  service/team fields parse and say service-aware journeys are live here.
- Anywhere else: "You're not inside a service repo — that's normal before your first
  scaffold. Everything starts from right here: try `/catalog`, then `/scaffold-service`."
  Do not call this a warning, do not list it under fixes, do not tell them to create or
  clone anything — the scaffold journey creates their repo.

## Report format

One line per check: ✅/❌, what was checked, and (on ❌) the one-command fix hint. Then the
one-line location note. End with either "You're ready — try /catalog" or the ordered list
of fixes needed. "Fixes needed" contains only real blockers — no optional items, no
"(optional) cd somewhere".

## Rules

- Read-only: this skill runs checks; it never installs, configures, or logs in on the
  Developer's behalf. Fix hints are commands the Developer runs themselves (auth flows are
  interactive and belong to them).
