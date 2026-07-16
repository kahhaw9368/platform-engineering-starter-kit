---
name: verify-setup
description: Verify a Developer's prerequisites for using the platform — harness, git access, AWS IAM Identity Center login. Use when the user asks to verify/check their setup, says something isn't working before their first journey, or invokes /verify-setup.
---

# Verify Setup

Check each prerequisite and report pass/fail with a fix hint. Run checks with the Bash tool;
never guess. Report ALL results (don't stop at first failure), then summarize.

## Checks

1. **Agent harness** — you are running, so the harness exists; report which one (Claude Code /
   Kiro CLI) and its version (`claude --version` / `kiro --version`).
2. **git** — `git --version` and, inside a repo, `git remote -v`.
   Fix hint: install git / clone the service repo.
3. **GitHub CLI (or the customer's forge CLI)** — `gh auth status`.
   Fix hint: `gh auth login`. If the customer uses GitLab/Bitbucket, check the equivalent
   (`glab auth status`) — read `.apex/context.yaml` for a `forge` key if present.
4. **AWS credentials via IAM Identity Center** — `aws sts get-caller-identity`.
   Fix hint: `aws sso login` (profile name from `.apex/context.yaml` `aws_profile` key, if set).
5. **Repo-local APEX context** — does `.apex/context.yaml` exist in the current repo? If yes,
   confirm service/team/template_version fields parse. If no, note that platform-wide journeys
   still work but service-aware ones ("add X to my service") need a scaffolded repo.

## Report format

One line per check: ✅/❌, what was checked, and (on ❌) the one-command fix hint. End with
either "You're ready — try /catalog" or the ordered list of fixes needed.

## Rules

- Read-only: this skill runs checks; it never installs, configures, or logs in on the
  Developer's behalf. Fix hints are commands the Developer runs themselves (auth flows are
  interactive and belong to them).
