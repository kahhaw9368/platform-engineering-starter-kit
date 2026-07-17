# Installer (ADR-0012)

npx installer following the `npx apex-skills` convention: detect harness (Claude Code / Kiro),
copy/symlink apex/ content, support --version pinning and --update.

- [x] package: `apex-starter-kit` (own installer, apex-skills conventions; embedding decision still open per ADR-0012)
- [x] Kiro layout verified by installer seam test in CI (every push = the release checklist pass)

## Usage

    npx apex-starter-kit               # install into detected harnesses (~/.claude, ~/.kiro)
    npx apex-starter-kit --version v0.1.0   # pin
    npx apex-starter-kit --update      # refresh cache then reinstall
    npx apex-starter-kit --uninstall

Seam test: installer/tests/test_installer.sh (runs in CI: installer-seam workflow).
NOT yet published to npm — publish happens with the sample-apex-skills embedding decision.
