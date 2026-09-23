import assert from "node:assert/strict";
import { execFileSync, spawnSync } from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";
import * as yaml from "js-yaml";

const workflow = yaml.load(fs.readFileSync(new URL("./weekly-upstream-sync.yml", import.meta.url), "utf8"));
const steps = workflow.jobs.sync.steps;
const apply = steps.find((step) => step.id === "sync");
const guard = steps.find((step) => step.name === "Assert excluded paths are unchanged");
const whitespace = steps.find((step) => step.name === "Check synchronized whitespace");
const exclusions = workflow.env.EXCLUDE_PATHS.trim().split("\n");
const exceptions = workflow.env.SYNC_EXCEPTIONS.trim().split("\n");
const seeds = workflow.env.SEED_PATHS.trim().split("\n");
const retiredSkill = path.join(".github", "skills", "old-name", "SKILL.md");

function fixture(run) {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "apex-sync-test-"));
  const repo = path.join(root, "repo");
  fs.mkdirSync(repo);
  const git = (...args) =>
    execFileSync("git", args, { cwd: repo, encoding: "utf8", stdio: ["ignore", "pipe", "pipe"] }).trim();
  const write = (file, content) => {
    const target = path.join(repo, file);
    fs.mkdirSync(path.dirname(target), { recursive: true });
    fs.writeFileSync(target, content);
  };
  const protectedFiles = exclusions.map((file) => (file.endsWith("/") ? `${file}local sentinel.txt` : file));
  try {
    git("init", "-b", "main");
    git("config", "user.name", "Sync Fixture");
    git("config", "user.email", "fixture@example.invalid");
    for (const file of [...protectedFiles, ...exceptions, ...seeds]) write(file, "upstream\n");
    write(".github/skills/apex-new/SKILL.md", "new skill\n");
    write("tools/scripts/new-validator.mjs", "upstream\n");
    git("add", ".");
    git("commit", "-m", "upstream");
    const upstream = git("rev-parse", "HEAD");
    for (const file of [...protectedFiles, ...exceptions, ...seeds]) write(file, "downstream\n");
    git("rm", ".github/skills/apex-new/SKILL.md");
    write(retiredSkill, "retired skill\n");
    write("tools/scripts/benchmark-e2e.mjs", "retired runner\n");
    git("add", ".");
    git("commit", "-m", "downstream");
    const env = {
      ...process.env,
      ...workflow.env,
      UPSTREAM_SHA: upstream,
      SYNC_BRANCH: "automation/upstream-sync",
      GITHUB_OUTPUT: path.join(root, "output"),
    };
    const shell = (script) =>
      spawnSync("bash", ["-e", "-o", "pipefail"], { input: script, cwd: repo, env, encoding: "utf8" });
    run({ repo, git, write, protectedFiles, shell });
  } finally {
    fs.rmSync(root, { recursive: true, force: true });
  }
}

test("workflow shell is valid and publication is gated behind validation and dry-run", () => {
  for (const step of steps.filter((step) => step.run)) {
    const result = spawnSync("bash", ["-n"], { input: step.run, encoding: "utf8" });
    assert.equal(result.status, 0, `${step.name}: ${result.stderr}`);
  }
  assert.equal(workflow.on.workflow_dispatch.inputs.dry_run.default, true);
  assert.equal(workflow.on.workflow_dispatch.inputs.upstream_ref.default, "main");
  assert.equal(workflow.env.UPSTREAM_REF, "${{ inputs.upstream_ref || 'main' }}");
  const validation = steps.findIndex((step) => step.name === "Validate synchronized contracts");
  for (const name of ["Commit and push sync branch", "Ensure PR labels exist", "Create or update pull request"]) {
    const position = steps.findIndex((step) => step.name === name);
    assert.ok(position > validation);
    assert.match(steps[position].if, /env\.DRY_RUN != 'true'/);
  }
  assert.match(
    steps.find((step) => step.name === "No-op path — report").run,
    /\[\[ "\$DRY_RUN" == true \]\] && exit 0/,
  );
});

test("only main can publish; other refs are preview-only", () => {
  const fetch = steps.find((step) => step.name === "Fetch upstream branch").run;
  const guardScript = fetch.slice(0, fetch.indexOf("git remote remove"));
  assert.ok(guardScript.includes("git check-ref-format"));
  for (const [upstreamRef, dryRun, expected] of [
    ["main", "false", 0],
    ["main", "true", 0],
    ["perf/apex-workflow-optimization", "false", 1],
    ["unapproved-branch", "false", 1],
    ["unapproved-branch", "true", 0],
    ["invalid ref", "true", 1],
  ]) {
    const result = spawnSync("bash", ["-e", "-o", "pipefail"], {
      input: guardScript,
      env: { ...process.env, UPSTREAM_REF: upstreamRef, DRY_RUN: dryRun },
      encoding: "utf8",
    });
    assert.equal(result.status, expected, `${upstreamRef}, dry_run=${dryRun}: ${result.stderr}`);
  }
});

test("mirror retires old tooling, syncs shared exceptions and preserves local content", () => {
  fixture(({ repo, git, protectedFiles, shell }) => {
    const result = shell(apply.run);
    assert.equal(result.status, 0, result.stderr);
    for (const file of protectedFiles)
      assert.equal(fs.readFileSync(path.join(repo, file), "utf8"), "downstream\n", file);
    for (const file of exceptions) assert.equal(fs.readFileSync(path.join(repo, file), "utf8"), "upstream\n", file);
    for (const file of seeds) assert.equal(fs.readFileSync(path.join(repo, file), "utf8"), "downstream\n", file);
    assert.equal(fs.existsSync(path.join(repo, retiredSkill)), false);
    assert.equal(fs.existsSync(path.join(repo, "tools/scripts/benchmark-e2e.mjs")), false);
    assert.equal(fs.existsSync(path.join(repo, ".github/skills/apex-new/SKILL.md")), true);
    assert.equal(shell(guard.run).status, 0);
    git("commit", "-m", "synced");
    assert.equal(shell(apply.run).status, 0);
    assert.equal(git("diff", "--cached", "--name-only"), "");
  });
});

test("leak guard rejects unauthorized changes including renames from protected paths", () => {
  fixture(({ git, write, shell }) => {
    assert.equal(shell(apply.run).status, 0);
    write("agent-output/local sentinel.txt", "leaked\n");
    git("add", "agent-output/local sentinel.txt");
    assert.notEqual(shell(guard.run).status, 0);
    write("agent-output/local sentinel.txt", "downstream\n");
    git("add", "agent-output/local sentinel.txt");
    git("mv", "agent-output/local sentinel.txt", "leaked.txt");
    assert.notEqual(shell(guard.run).status, 0);
  });
});

test("whitespace check permits blank EOFs but rejects other whitespace errors", () => {
  fixture(({ git, write, shell }) => {
    assert.equal(shell(apply.run).status, 0);
    write("blank-eof.md", "content\n\n");
    git("add", "blank-eof.md");
    assert.equal(shell(whitespace.run).status, 0);

    write("trailing-whitespace.md", "content \n");
    git("add", "trailing-whitespace.md");
    const result = shell(whitespace.run);
    assert.notEqual(result.status, 0);
    assert.match(result.stdout, /trailing whitespace/);
  });
});

test("absent refresh data is seeded once and later modifications are protected", () => {
  fixture(({ repo, git, write, shell }) => {
    for (const file of seeds) git("rm", file);
    git("commit", "-m", "unseeded consumer");
    assert.equal(shell(apply.run).status, 0);
    assert.equal(shell(guard.run).status, 0);
    for (const file of seeds) assert.equal(fs.readFileSync(path.join(repo, file), "utf8"), "upstream\n");
    git("commit", "-m", "seeded consumer");
    for (const file of seeds) write(file, "refreshed by consumer\n");
    git("add", ".");
    git("commit", "-m", "consumer refresh");
    assert.equal(shell(apply.run).status, 0);
    assert.equal(shell(guard.run).status, 0);
    for (const file of seeds) assert.equal(fs.readFileSync(path.join(repo, file), "utf8"), "refreshed by consumer\n");
    write(seeds[0], "unexpected overwrite\n");
    git("add", seeds[0]);
    assert.notEqual(shell(guard.run).status, 0);
  });
});
