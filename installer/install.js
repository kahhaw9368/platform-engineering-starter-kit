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
const UPSTREAM = "https://github.com/aws-samples/sample-apex-skills.git";
// Developer-surface vendored skills (dispositions: apex/skills/VENDORED.md).
// eks-build + terraform-skill are engagement-only; ecs-*, eks-platform-engineering excluded.
const VENDORED = [
  "eks-best-practices", "eks-security", "eks-cost-intelligence",
  "eks-operation-review", "eks-upgrade-check", "eks-recon",
  "eks-mcp-server", "eks-genai", "eks-ingress-migration", "eks-design",
];
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
  // npx already downloaded this package — use it directly unless the user
  // asked for a different version or an update (which need the git cache).
  const packaged = path.resolve(__dirname, "..");
  if (!version && !flag("--update") && fs.existsSync(path.join(packaged, "apex", "skills"))) {
    return packaged;
  }
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

function ensureUpstream() {
  const cache = path.join(CACHE + "-upstream");
  if (flag("--source")) return null; // hermetic test mode: skip upstream fetch
  if (!fs.existsSync(cache)) {
    log("fetching vendored skills (sample-apex-skills)...");
    execSync(`git clone --depth 1 ${UPSTREAM} "${cache}"`, { stdio: "pipe" });
  } else if (flag("--update")) {
    execSync("git pull --ff-only", { cwd: cache, stdio: "pipe" });
  }
  return cache;
}

function installVendored(upstream, harnessSkillsDir) {
  if (!upstream) return;
  for (const skill of VENDORED) {
    const src = path.join(upstream, "skills", skill);
    if (fs.existsSync(src)) copyDir(src, path.join(harnessSkillsDir, skill));
  }
  log(`vendored ${VENDORED.length} upstream skills (see apex/skills/VENDORED.md)`);
}

function installClaudeCode(src) {
  const skillsSrc = path.join(src, "apex", "skills");
  for (const skill of fs.readdirSync(skillsSrc)) {
    if (skill === "VENDORED.md") continue;
    copyDir(path.join(skillsSrc, skill), path.join(HOME, ".claude", "skills", skill));
  }
  installVendored(ensureUpstream(), path.join(HOME, ".claude", "skills"));
  copyDir(path.join(src, "apex", "rules"), path.join(HOME, ".claude", "apex", "rules"));
  copyDir(path.join(src, "apex", "steering"), path.join(HOME, ".claude", "apex", "steering"));
  copyDir(path.join(src, "apex", "agents"), path.join(HOME, ".claude", "agents"));
  copyDir(path.join(src, "apex", "hooks"), path.join(HOME, ".claude", "apex", "hooks"));
  installWelcomeHook();
  log("claude-code: skills + rules + steering + apex agent + welcome hook installed");
}

function installKiro(src) {
  const skillsSrc = path.join(src, "apex", "skills");
  for (const skill of fs.readdirSync(skillsSrc)) {
    if (skill === "VENDORED.md") continue;
    copyDir(path.join(skillsSrc, skill), path.join(HOME, ".kiro", "skills", skill));
  }
  installVendored(ensureUpstream(), path.join(HOME, ".kiro", "skills"));
  // Kiro consumes rules + welcome as steering documents
  copyDir(path.join(src, "apex", "rules"), path.join(HOME, ".kiro", "steering"));
  copyDir(path.join(src, "apex", "steering"), path.join(HOME, ".kiro", "steering"));
  log("kiro: skills + steering installed");
}

function installWelcomeHook() {
  // Merge the APEX SessionStart splash into ~/.claude/settings.json (never clobber).
  const settingsPath = path.join(HOME, ".claude", "settings.json");
  let settings = {};
  if (fs.existsSync(settingsPath)) {
    try { settings = JSON.parse(fs.readFileSync(settingsPath, "utf8")); }
    catch { log("warn: ~/.claude/settings.json unparseable — skipping welcome hook"); return; }
  }
  const hookCmd = path.join(HOME, ".claude", "apex", "hooks", "welcome-hook.sh");
  settings.hooks = settings.hooks || {};
  settings.hooks.SessionStart = settings.hooks.SessionStart || [];
  const already = JSON.stringify(settings.hooks.SessionStart).includes("welcome-hook.sh");
  if (!already) {
    settings.hooks.SessionStart.push({
      matcher: "startup|clear",
      hooks: [{ type: "command", command: hookCmd, timeout: 10 }],
    });
    fs.writeFileSync(settingsPath, JSON.stringify(settings, null, 2) + "\n");
  }
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
  fs.rmSync(path.join(HOME, ".claude", "agents", "apex.md"), { force: true });
  // Remove the welcome hook entry (leave the rest of settings.json untouched)
  const sp = path.join(HOME, ".claude", "settings.json");
  if (fs.existsSync(sp)) {
    try {
      const s = JSON.parse(fs.readFileSync(sp, "utf8"));
      if (s.hooks && s.hooks.SessionStart) {
        s.hooks.SessionStart = s.hooks.SessionStart.filter(
          (h) => !JSON.stringify(h).includes("welcome-hook.sh"));
        if (s.hooks.SessionStart.length === 0) delete s.hooks.SessionStart;
        fs.writeFileSync(sp, JSON.stringify(s, null, 2) + "\n");
      }
    } catch { /* leave unparseable settings alone */ }
  }
  log("uninstalled (cache kept; delete ~/.apex-starter-kit to remove fully)");
}

if (flag("--uninstall")) {
  uninstall();
} else {
  const src = ensureSource();
  const harnesses = detectHarnesses();
  if (harnesses.includes("claude-code")) installClaudeCode(src);
  if (harnesses.includes("kiro")) installKiro(src);
  const launch = harnesses.includes("claude-code") ? "claude --agent apex" : "kiro";
  log(`done. Harnesses: ${harnesses.join(", ")}. Start a session (${launch}) and run /catalog.`);
}
