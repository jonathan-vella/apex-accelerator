<!-- markdownlint-disable MD013 MD033 MD041 -->

# APEX Accelerator

<div align="center">
  <img
   src="https://capsule-render.vercel.app/api?type=waving&height=180&color=0:0A66C2,50:0078D4,110:00B7C3&text=APEX&fontSize=44&fontColor=FFFFFF&fontAlignY=34&desc=Agentic%20Platform%20Engineering%20eXperience%20for%20Azure&descAlignY=56"
   alt="APEX banner" />
</div>

> **Modernize your Azure Infrastructure with AI.** A production-ready template for building Well-Architected
> environments using custom Copilot agents, Dev Containers, and the Model Context Protocol (MCP).

[![Azure](https://img.shields.io/badge/Azure-0078D4?logo=microsoft-azure&logoColor=white)](https://azure.microsoft.com)
[![Bicep](https://img.shields.io/badge/Bicep-0078D4?logo=azure-pipelines&logoColor=white)](https://github.com/Azure/bicep)
[![Terraform](https://img.shields.io/badge/Terraform-7B42BC?logo=terraform&logoColor=white)](https://www.terraform.io)
[![Copilot](https://img.shields.io/badge/GitHub_Copilot-000000?logo=github-copilot&logoColor=white)](https://github.com/features/copilot)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

## Overview

This accelerator provides the scaffolding and governance to move from requirements to deployed infrastructure
using an orchestrated multi-agent workflow. It leverages domain-specific AI agents to ensure every deployment
is Well-Architected, governed, and documented.

**What you get**: Specialized agents, skills, validation scripts, a full dev container with all
tools pre-installed, and an optional weekly sync workflow that keeps your agents and skills up to date with
the [upstream APEX project](https://github.com/jonathan-vella/apex).

---

## Prerequisites

| Requirement            | Details                                              |
| ---------------------- | ---------------------------------------------------- |
| **VS Code**            | Latest stable release                                |
| **GitHub Copilot**     | Active license (Individual, Business, or Enterprise) |
| **Docker Desktop**     | For the dev container (or GitHub Codespaces)         |
| **Azure subscription** | Required (Owner or Contributor on the target subscription) |

---

## Quick Start

### 1. Create Your Repository

This repository is a **GitHub Template** — not a fork.

1. Click **"Use this template"** → **"Create a new repository"** at the top of this page
2. Choose an owner and name (e.g., `my-infraops-project`)
3. Select **Private** (do not use Public)
4. Click **Create repository**

> Your new repo has the same directory structure and files but a **clean commit history**
> and no fork relationship. It is entirely yours.

### 2. Clone and Open in Dev Container

```bash
git clone https://github.com/YOUR-USERNAME/my-infraops-project.git
cd my-infraops-project
code .
```

When prompted by VS Code, click **"Reopen in Container"** (or run `Dev Containers: Reopen in Container`
from the Command Palette). The container build takes 3-5 minutes and pre-installs:

- Azure CLI with Bicep extension
- Terraform CLI with TFLint
- GitHub CLI (`gh`)
- Node.js + npm (validation scripts)
- Python 3 + pip (MCP server, diagram generation)
- Go (Terraform MCP server)

### 3. Initialize Your Repository

After the dev container starts, run the initialization commands:

```bash
npm install
npm run init
npm run sync:workflows
```

**What these do:**

| Command                  | Purpose                                                                                                                                                                                       |
| ------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `npm install`            | Install Node.js dependencies (validation scripts, linting)                                                                                                                                    |
| `npm run init`           | **One-time setup** — replaces all references to the accelerator template repo with your repo's URL (auto-detected from git remote). Run `npm run init -- --dry-run` first to preview changes. |
| `npm run sync:workflows` | Fetches the latest GitHub Actions workflows from the [upstream APEX project](https://github.com/jonathan-vella/apex) into your `.github/workflows/` directory                |

> **Note:** Python dependencies (diagrams, Azure Pricing MCP server, apex-recall) are installed
> automatically by the dev container's `post-create.sh` script. No manual `pip install` is needed.

After running, review and commit:

```bash
git --no-pager diff
git add -A && git commit -m "chore: initialize from template"
git push
```

> **Expected diff:** You will see changes to `AGENTS.md`, `CONTRIBUTING.md`, and one or more
> `.github/workflows/` files. You may also see formatting-only changes to `.vscode/mcp.json`
> (the dev container normalizes its JSON arrays to multi-line format on first start) — this is
> expected and safe to commit.
>
> **Tip:** Use `git --no-pager diff` instead of plain `git diff` to avoid the `less` pager.
> If you do use `git diff` and see a `:` prompt, press `q` to exit or `Space` to scroll.

### 4. Set Up Azure

Run the setup wizard to configure Azure OIDC authentication, RBAC roles, and GitHub
secrets/variables — all in one command:

```bash
az login
npm run setup
```

The wizard creates an Entra ID app registration, OIDC federated credentials (for
main branch + dev/staging/prod environments), assigns Reader at your Management Group
and Contributor at your subscription, and configures all GitHub secrets and variables.
It is idempotent — safe to re-run.

See the [Azure Setup documentation](https://apexops.pro/getting-started/azure-setup/)
for headless mode, manual setup steps, and troubleshooting.

### 5. Allow GitHub Actions to Create Pull Requests

The maintenance workflows (step 6) open pull requests automatically when they
detect drift. This requires one permission change in your repository settings.

1. Go to your repository on GitHub
2. Click **Settings → Actions → General**
3. Scroll to **Workflow permissions**
4. Check **Allow GitHub Actions to create and approve pull requests**
5. Click **Save**

> **Why:** GitHub disables this by default on all new repositories.
> Without it, any workflow that opens a PR will fail with:
> `GitHub Actions is not permitted to create or approve pull requests`

### 6. Run the Maintenance Workflows

After Azure setup completes, trigger the two scheduled maintenance workflows once
so your repository has a fresh baseline before you start working. Both run weekly
on Mondays after this initial seed.

```bash
gh workflow run "Weekly Maintenance"
gh workflow run "Governance Policy Baseline"
```

| Workflow                       | Purpose                                                                                                                                              | Schedule                |
| ------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------- |
| **Weekly Maintenance**         | Refreshes the AVM module index, tracks Azure service deprecations, runs the quarterly docs/orphan audit, validates Draw.io tooling, and link-checks docs. | Mondays 06:00 UTC       |
| **Governance Policy Baseline** | Collects effective Azure Policy assignments (including management-group inheritance) from your subscription into `agent-output/_baseline/` so the IaC planner consumes real governance constraints. Requires step 4 to be complete. | Mondays 05:00 UTC       |

Verify both runs succeeded before continuing:

```bash
gh run list --workflow "Weekly Maintenance" --limit 1
gh run list --workflow "Governance Policy Baseline" --limit 1
```

Each run may open a pull request when it detects drift (new AVM module versions,
policy changes, deprecated services). Review and merge those PRs as they appear —
they are never auto-merged.

---

## Project Structure

Once you are working in your repo, here is what lives where:

```text
.github/
  agents/              # Agent definitions (*.agent.md)
    _subagents/        # Subagent definitions (non-user-invocable)
  skills/              # Reusable domain knowledge (SKILL.md per skill)
  instructions/        # File-type rules with glob-based auto-application
  copilot-instructions.md  # VS Code Copilot-specific orchestration instructions
  workflows/           # GitHub Actions (sync, CI, validation)
agent-output/          # Generated artifacts organized by project
  {project}/           # 01-requirements.md through 07-*.md
infra/
  bicep/{project}/     # Bicep templates (main.bicep + modules/)
  terraform/{project}/ # Terraform configurations (main.tf + modules/)
tools/
  mcp-servers/         # MCP servers (azure-pricing, drawio)
  scripts/             # Validation and maintenance scripts
site/                  # Documentation site source (Astro Starlight)
```

### What's Yours vs. What's Upstream

| Your files (safe to edit, never overwritten by sync) | Upstream-managed files (overwritten by sync) |
| ---------------------------------------------------- | -------------------------------------------- |
| `agent-output/` — generated project artifacts        | `.github/agents/` — agent definitions        |
| `infra/bicep/` — your Bicep templates                | `.github/skills/` — agent skills             |
| `.github/workflows/` — your CI/CD workflows          | `.github/instructions/` — coding rules       |
| `README.md` — your documentation                     | `.github/copilot-instructions.md`            |
|                                                      | `tools/`, `site/`, `package.json`            |
|                                                      | `AGENTS.md`, `.devcontainer/`, `.vscode/`    |

> **Note**: If you disable the sync workflow, everything becomes yours to edit freely.
> See [Customization](#customization) below.

---

## Customization

### Changing defaults (regions, tags, naming)

When you create from this template, **every file is yours**. The question is which
approach gives you the best experience over time.

**Strategy A: Edit directly** (simplest)

Edit the file you need — for example, change `swedencentral` to `westeurope` in
`.github/skills/azure-defaults/SKILL.md`. If you don't plan to pull upstream
improvements, disable the sync workflow entirely (repo Settings → Actions → disable
**Upstream Sync**) and manage the repo as your own.

If you want upstream updates later, re-enable the workflow. The sync PR will overwrite
your edited files with the upstream version (it is not a merge), so you'll need to
re-apply your changes after merging. Keep a record of what you changed.

**Strategy B: Keep sync enabled, layer your overrides** (recommended for teams that
want continuous upstream improvements)

The sync workflow overwrites all upstream-managed files but never touches the four
excluded paths. To safely store overrides that survive sync:

1. **Edit the sync exclusion list** — the sync workflow file itself is user-owned
   (`.github/workflows/` is excluded from sync). Open
   `.github/workflows/weekly-upstream-sync.yml` and add paths to `EXCLUDE_PATHS` and
   the matching `for path in ...` loop:

   ```yaml
   EXCLUDE_PATHS: |
     .github/workflows/
     agent-output/
     infra/bicep/
     infra/terraform/
     README.md
     AGENTS.md
   ```

   Then add your overrides to root `AGENTS.md` — it will survive all future syncs.

2. **Use `infra/bicep/AGENTS.md`** — since `infra/bicep/` is already excluded from
   sync, you can place an `AGENTS.md` there with your organization defaults. VS Code
   loads subfolder `AGENTS.md` files when working with files in that directory.

3. **VS Code user-profile instructions** — place a `.instructions.md` file in your
   VS Code profile's `prompts/` folder. This lives outside the repo entirely and
   applies to all your workspaces.

**Which strategy to pick?**

| Approach                          | Best for                                        |
| --------------------------------- | ----------------------------------------------- |
| **A: Edit directly, skip sync**   | Solo users, teams that self-manage updates      |
| **B: Layer overrides, keep sync** | Teams that want automatic upstream improvements |

### Adding new agents or skills

Agents are defined in `.github/agents/*.agent.md` and skills in
`.github/skills/*/SKILL.md`. You can add new ones alongside the existing set.
If you keep sync enabled, use distinctive names that won't collide with upstream
filenames, or add your custom paths to the sync exclusion list.

---

## IaC Tracks: Bicep and Terraform

Both IaC tracks are fully supported. The Requirements agent (Step 1) captures your
`iac_tool` preference, and the Orchestrator routes Steps 4-6 to the correct track.

| Factor          | Bicep                           | Terraform                                |
| --------------- | ------------------------------- | ---------------------------------------- |
| **Azure-only**  | Native DSL, first-class support | Multi-cloud via AzureRM provider         |
| **State**       | No state file (ARM-managed)     | State file (Azure Storage backend)       |
| **AVM modules** | `br/public:avm/res/`            | `registry.terraform.io/Azure/avm-res-*/` |
| **CI/CD**       | `az deployment group create`    | `terraform plan` + `terraform apply`     |

---

## Multi-Project Support

The accelerator is designed for **one repo containing multiple projects**. Each project
gets its own folders:

- `agent-output/{project}/` — artifacts (requirements, architecture, plans, docs)
- `infra/bicep/{project}/` or `infra/terraform/{project}/` — IaC templates

Agents, skills, instructions, and the dev container are shared across all projects.

**One repo per project** is also valid when teams need separate governance or isolation.
Each repo is created independently from the template.

### Sharing customizations across repos or teams

- **Edit the sync exclusion list** in each repo to protect `AGENTS.md`, then maintain a
  standard overrides section that you copy into each repo
- **VS Code user-profile instructions** — personal preferences that follow you across
  repos without any per-repo setup
- **Canonical overrides in a shared location** — maintain a standard overrides snippet
  in a team wiki or internal repo and copy it when creating new instances

---

## Keeping Up to Date

| What                                        | How                                          | Frequency      |
| ------------------------------------------- | -------------------------------------------- | -------------- |
| Agents, skills, instructions, docs, scripts | Automated weekly PR (upstream sync workflow) | Weekly         |
| GitHub Actions workflows                    | `npm run sync:workflows` (manual)            | As needed      |
| All validations                             | `npm run validate:all`                       | Before each PR |

The sync workflow opens a PR for human review — it never auto-merges. You can disable
it entirely if you prefer to manage updates manually.

---

## Validation & Quality

```bash
# Run all code and documentation validations
npm run validate:all

# Fix markdown formatting
npm run lint:md:fix

# Bicep validation (replace {project})
bicep build infra/bicep/{project}/main.bicep
bicep lint infra/bicep/{project}/main.bicep

# Terraform validation
terraform fmt -check -recursive infra/terraform/
cd infra/terraform/{project} && terraform init -backend=false && terraform validate
```

---

## Resources

- [APEX upstream project](https://github.com/jonathan-vella/apex)
- [APEX documentation](https://apexops.pro/)
- [Azure Setup guide](https://apexops.pro/getting-started/azure-setup/)
- [MicroHack (hands-on exercises)](https://microhack.apexops.pro/)
- [Prompt Guide](https://apexops.pro/guides/prompt-guide/)
- [FAQ](https://apexops.pro/reference/faq/)

## License

[MIT](LICENSE)
