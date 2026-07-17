#!/usr/bin/env node
/**
 * APEX installer (ADR-0012) — npx apex-starter-kit
 *
 * Delivers the APEX bundle (skills/, rules/, steering/) into the harness(es)
 * on this machine. Follows the `npx apex-skills` convention: clone to a
 * versioned cache, then copy into harness locations.
 *
 * Layouts (ADR-0013):
 *   Claude Code:  ~/.claude/skills/<skill>/            (skills)
 *                 ~/.claude/apex/rules+steering        (referenced by skills)
 *   Kiro CLI:     ~/.kiro/skills/<skill>/              (skills)
 *                 ~/.kiro/steering/                    (rules+welcome as steering)
 *
 * Flags: --version <tag> (pin), --update (refresh cache), --uninstall,
 *        --source <dir> (local checkout instead of git — used by CI seam test),
 *        --home <dir>   (override $HOME — used by CI seam test)
 */

const fs = require("fs");
const path = require("path");
const { execSync } = require("child_process");

const REPO = "https://github.com/kahhaw9368/platform-engineering-starter-kit.git";
const args = process.argv.slice(2);
const flag = (name) => {
  const i = args.indexOf(name);
  return i === -1 ? null : args[i + 1] || true;
};

const HOME = flag("--home") || process.env.HOME;
const CACHE = path.join(HOME, ".apex-starter-kit");

function log(msg) { console.log(`[apex] ${msg}`); }

function ensureSource() {
  const local = flag("--source");
  if (local) return path.resolve(local);
  const version = flag("--version");
  if (fs.existsSync(CACHE)) {
    if (flag("--update")) {
      log("updating cache...");
      execSync("git pull --ff-only", { cwd: CACHE, stdio: "pipe" });
    }
  } else {
    log(`cloning ${REPO}...`);
    execSync(`git clone --depth 1 ${REPO} "${CACHE}"`, { stdio: "pipe" });
  }
  if (version && version !== true) {
    execSync(`git fetch --tags && git checkout ${version}`, { cwd: CACHE, stdio: "pipe" });
    log(`pinned to ${version}`);
  }
  return CACHE;
}

function copyDir(src, dest) {
  fs.mkdirSync(dest, { recursive: true });
  fs.cpSync(src, dest, { recursive: true });
}

function detectHarnesses() {
  const found = [];
  // Directory presence = the harness is (or has been) used on this machine.
  if (fs.existsSync(path.join(HOME, ".claude"))) found.push("claude-code");
  if (fs.existsSync(path.join(HOME, ".kiro"))) found.push("kiro");
  if (found.length === 0) {
    log("no harness detected (~/.claude or ~/.kiro). Install Claude Code or Kiro CLI first.");
    process.exit(1);
  }
  return found;
}

function installClaudeCode(src) {
  const skillsSrc = path.join(src, "apex", "skills");
  for (const skill of fs.readdirSync(skillsSrc)) {
    copyDir(path.join(skillsSrc, skill), path.join(HOME, ".claude", "skills", skill));
  }
  copyDir(path.join(src, "apex", "rules"), path.join(HOME, ".claude", "apex", "rules"));
  copyDir(path.join(src, "apex", "steering"), path.join(HOME, ".claude", "apex", "steering"));
  log("claude-code: skills + rules + steering installed");
}

function installKiro(src) {
  const skillsSrc = path.join(src, "apex", "skills");
  for (const skill of fs.readdirSync(skillsSrc)) {
    copyDir(path.join(skillsSrc, skill), path.join(HOME, ".kiro", "skills", skill));
  }
  // Kiro consumes rules + welcome as steering documents
  copyDir(path.join(src, "apex", "rules"), path.join(HOME, ".kiro", "steering"));
  copyDir(path.join(src, "apex", "steering"), path.join(HOME, ".kiro", "steering"));
  log("kiro: skills + steering installed");
}

function uninstall() {
  const skillNames = fs.existsSync(path.join(CACHE, "apex", "skills"))
    ? fs.readdirSync(path.join(CACHE, "apex", "skills")) : [];
  for (const h of [".claude", ".kiro"]) {
    for (const s of skillNames) {
      fs.rmSync(path.join(HOME, h, "skills", s), { recursive: true, force: true });
    }
  }
  fs.rmSync(path.join(HOME, ".claude", "apex"), { recursive: true, force: true });
  log("uninstalled (cache kept; delete ~/.apex-starter-kit to remove fully)");
}

if (flag("--uninstall")) {
  uninstall();
} else {
  const src = ensureSource();
  const harnesses = detectHarnesses();
  if (harnesses.includes("claude-code")) installClaudeCode(src);
  if (harnesses.includes("kiro")) installKiro(src);
  log(`done. Harnesses: ${harnesses.join(", ")}. Start a session and run /catalog.`);
}
