import assert from "node:assert/strict";
import { execFileSync, spawnSync } from "node:child_process";
import fs from "node:fs";
import path from "node:path";
import test from "node:test";
import { gzipSync, gunzipSync } from "node:zlib";
import * as yaml from "js-yaml";
import { loadValidator } from "../../tools/scripts/_lib/ajv-validator.mjs";
import { runValidator } from "../../tools/scripts/validate-governance-baseline.mjs";

const ROOT = path.resolve(import.meta.dirname, "../..");
const SHARED_BASELINE = ".github/data/alz-corp-policy-baseline.json.gz";
const PRIVATE_BASELINE = ".github/data/governance-policy-baseline.json.gz";
const workflow = yaml.load(fs.readFileSync(new URL("./weekly-upstream-sync.yml", import.meta.url), "utf8"));
const steps = workflow.jobs.sync.steps;
const apply = steps.find((step) => step.id === "sync");
const guard = steps.find((step) => step.name === "Assert excluded paths are unchanged");
const baselineValidation = steps.find((step) => step.name === "Validate shared ALZ Corp baseline");
const exclusions = workflow.env.EXCLUDE_PATHS.trim().split("\n");
const exceptions = workflow.env.SYNC_EXCEPTIONS.trim().split("\n");
const seeds = workflow.env.SEED_PATHS.trim().split("\n");
const retiredSkill = path.join(".github", "skills", "old-name", "SKILL.md");

function sharedSnapshot(generatedAt = "2026-11-01T00:00:00Z") {
  const subscription = "00000000-0000-0000-0000-00000000a1c0";
  const document = {
    schema_version: "governance-baseline-v1",
    baseline_kind: "alz-corp-default",
    alz_library_ref: "fixture-alz",
    azure_policy_ref: "fixture-policy",
    generated_at: generatedAt,
    management_group_id: "alz-corp",
    coverage_status: "COMPLETE",
    subscriptions_discovered: 1,
    subscriptions_processed: 1,
    subscriptions_skipped: [],
    subscriptions_excluded: [],
    summary: { total_findings: 0, total_blockers: 0, total_auto_remediate: 0, subscriptions_complete: 1 },
    subscriptions: {
      [subscription]: {
        schema_version: "governance-constraints-v1",
        subscription_id: subscription,
        discovered_at: generatedAt,
        source: "alz-corp-default",
        discovery_status: "COMPLETE",
        discovery_options: { include_defender_auto: true },
        discovery_summary: { defender_auto_filtered: 0 },
        provenance: {
          kind: "alz-corp-default",
          alz_library_ref: "fixture-alz",
          azure_policy_ref: "fixture-policy",
          verified_against_tenant: false,
        },
        findings: [],
      },
    },
  };
  return gzipSync(Buffer.from(JSON.stringify(document)));
}

function fixture(run, { shared = "upstream\n" } = {}) {
  const root = fs.mkdtempSync(path.join(ROOT, ".corp-sync-tests-"));
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
  const privateSnapshots = new Map([
    [PRIVATE_BASELINE, gzipSync(Buffer.from("private tenant snapshot\n"))],
    [".github/data/tenant-only.json", Buffer.from("consumer-owned private data\n")],
  ]);
  try {
    git("init", "-b", "main");
    git("config", "user.name", "Sync Fixture");
    git("config", "user.email", "fixture@example.invalid");
    for (const file of [...protectedFiles, ...exceptions, ...seeds]) write(file, "upstream\n");
    if (shared === null) fs.rmSync(path.join(repo, SHARED_BASELINE));
    else write(SHARED_BASELINE, shared);
    for (const file of privateSnapshots.keys()) write(file, "upstream must not export tenant data\n");
    for (const file of [
      "tools/scripts/validate-governance-baseline.mjs",
      "tools/scripts/_lib/ajv-validator.mjs",
      "tools/scripts/_lib/governance-baseline.mjs",
      "tools/scripts/_lib/json.mjs",
      "tools/scripts/_lib/reporter.mjs",
      "tools/schemas/governance-baseline.schema.json",
    ]) {
      const target = path.join(repo, file);
      fs.mkdirSync(path.dirname(target), { recursive: true });
      fs.copyFileSync(path.join(ROOT, file), target);
    }
    write(".github/skills/apex-new/SKILL.md", "new skill\n");
    write("tools/scripts/new-validator.mjs", "upstream\n");
    git("add", ".");
    git("commit", "-m", "upstream");
    const upstream = git("rev-parse", "HEAD");
    for (const file of [...protectedFiles, ...exceptions, ...seeds]) write(file, "downstream\n");
    for (const [file, bytes] of privateSnapshots) write(file, bytes);
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
    run({ repo, git, write, protectedFiles, privateSnapshots, shell, env });
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
  const sharedValidation = steps.indexOf(baselineValidation);
  assert.ok(sharedValidation > validation);
  for (const name of ["Commit and push sync branch", "Ensure PR labels exist", "Create or update pull request"]) {
    const position = steps.findIndex((step) => step.name === name);
    assert.ok(position > validation);
    assert.ok(position > sharedValidation);
    assert.match(steps[position].if, /env\.DRY_RUN != 'true'/);
  }
  assert.match(
    steps.find((step) => step.name === "No-op path — report").run,
    /\[\[ "\$DRY_RUN" == true \]\] && exit 0/,
  );
});

test("the shared baseline is an updateable exception while tenant snapshots remain excluded", () => {
  assert.ok(exclusions.includes(".github/data/"));
  assert.ok(exceptions.includes(SHARED_BASELINE));
  assert.ok(!seeds.includes(SHARED_BASELINE));
  assert.ok(!exceptions.includes(PRIVATE_BASELINE));
  assert.ok(!seeds.includes(PRIVATE_BASELINE));
});

test(
  "the checked-out shared baseline is schema-valid when upstream has shipped it",
  {
    skip: !fs.existsSync(path.join(ROOT, SHARED_BASELINE)),
  },
  () => {
    assert.equal(runValidator({ baselinePath: path.join(ROOT, SHARED_BASELINE) }), 0);
  },
);

test("mirror introduces and updates the shared snapshot without changing private bytes", () => {
  const first = sharedSnapshot();
  const second = sharedSnapshot("2026-11-08T00:00:00Z");
  fixture(
    ({ repo, git, write, privateSnapshots, shell, env }) => {
      git("rm", SHARED_BASELINE);
      git("commit", "-m", "consumer before shared baseline");
      assert.equal(fs.existsSync(path.join(repo, SHARED_BASELINE)), false);
      assert.equal(shell(apply.run).status, 0);
      assert.deepEqual(fs.readFileSync(path.join(repo, SHARED_BASELINE)), first);
      assert.equal(shell(guard.run).status, 0);
      const validated = shell(baselineValidation.run);
      assert.equal(validated.status, 0, validated.stdout + validated.stderr);
      const validate = loadValidator(path.join(ROOT, "tools/schemas/governance-baseline.schema.json"));
      assert.equal(validate(JSON.parse(gunzipSync(first))), true, JSON.stringify(validate.errors));
      for (const [file, bytes] of privateSnapshots) assert.deepEqual(fs.readFileSync(path.join(repo, file)), bytes);
      git("commit", "-m", "synced baseline");
      git("switch", "--detach", env.UPSTREAM_SHA);
      write(SHARED_BASELINE, second);
      git("add", SHARED_BASELINE);
      git("commit", "-m", "upstream regenerates shared snapshot");
      env.UPSTREAM_SHA = git("rev-parse", "HEAD");
      git("switch", "automation/upstream-sync");
      assert.equal(shell(apply.run).status, 0);
      assert.deepEqual(fs.readFileSync(path.join(repo, SHARED_BASELINE)), second);
      assert.equal(shell(guard.run).status, 0);
      const revalidated = shell(baselineValidation.run);
      assert.equal(revalidated.status, 0, revalidated.stdout + revalidated.stderr);
      for (const [file, bytes] of privateSnapshots) assert.deepEqual(fs.readFileSync(path.join(repo, file)), bytes);
    },
    { shared: first },
  );
});

test("mirror does not introduce an upstream tenant snapshot into a clean consumer", () => {
  fixture(({ repo, git, shell }) => {
    git("rm", PRIVATE_BASELINE);
    git("commit", "-m", "consumer has no private tenant snapshot");
    assert.equal(shell(apply.run).status, 0);
    assert.equal(fs.existsSync(path.join(repo, PRIVATE_BASELINE)), false);
    assert.equal(shell(guard.run).status, 0);
  });
});

test("private snapshot modifications, additions and renames fail the leak guard", () => {
  fixture(({ repo, git, write, privateSnapshots, shell }) => {
    assert.equal(shell(apply.run).status, 0);
    write(PRIVATE_BASELINE, "modified private snapshot\n");
    git("add", PRIVATE_BASELINE);
    assert.notEqual(shell(guard.run).status, 0);
    write(PRIVATE_BASELINE, privateSnapshots.get(PRIVATE_BASELINE));
    git("add", PRIVATE_BASELINE);
    const added = ".github/data/new-tenant-snapshot.json";
    write(added, "private\n");
    git("add", added);
    assert.notEqual(shell(guard.run).status, 0);
    git("rm", "-f", added);
    assert.equal(shell(guard.run).status, 0);
    git("rm", PRIVATE_BASELINE);
    assert.notEqual(shell(guard.run).status, 0);
    git("checkout", "HEAD", "--", PRIVATE_BASELINE);
    git("mv", PRIVATE_BASELINE, "leaked-snapshot.json.gz");
    assert.notEqual(shell(guard.run).status, 0);
    assert.equal(fs.existsSync(path.join(repo, PRIVATE_BASELINE)), false);
  });
});

test("validation tolerates the pre-rollout upstream but removes obsolete shared data", () => {
  fixture(
    ({ repo, shell }) => {
      assert.equal(shell(apply.run).status, 0);
      assert.equal(fs.existsSync(path.join(repo, SHARED_BASELINE)), false);
      const result = shell(baselineValidation.run);
      assert.equal(result.status, 0, result.stderr);
      assert.equal(result.stdout, "");
    },
    { shared: null },
  );
});

test("validation fails for a missing, corrupt or schema-invalid snapshot once upstream supplies it", () => {
  fixture(
    ({ repo, write, shell }) => {
      assert.equal(shell(apply.run).status, 0);
      fs.unlinkSync(path.join(repo, SHARED_BASELINE));
      assert.notEqual(shell(baselineValidation.run).status, 0);
      write(SHARED_BASELINE, "invalid gzip");
      assert.notEqual(shell(baselineValidation.run).status, 0);
      write(SHARED_BASELINE, gzipSync(Buffer.from("{}")));
      assert.notEqual(shell(baselineValidation.run).status, 0);
    },
    { shared: sharedSnapshot() },
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
