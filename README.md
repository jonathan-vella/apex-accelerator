<!-- markdownlint-disable MD013 MD033 MD041 -->

# APEX Accelerator

<div align="center">
  <img
   src="https://capsule-render.vercel.app/api?type=waving&height=180&color=0:0A66C2,50:0078D4,110:00B7C3&text=APEX&fontSize=44&fontColor=FFFFFF&fontAlignY=34&desc=Agentic%20Platform%20Engineering%20eXperience%20for%20Azure&descAlignY=56"
   alt="APEX banner" />
</div>

> **GitHub template repository for Azure infrastructure delivery and standalone Well-Architected assessments.**
> Includes custom GitHub Copilot agents, domain skills, validators, a configured dev container, MCP server configuration, and optional upstream sync.

[![Azure](https://img.shields.io/badge/Azure-0078D4?logo=microsoft-azure&logoColor=white)](https://azure.microsoft.com)
[![Bicep](https://img.shields.io/badge/Bicep-0078D4?logo=azure-pipelines&logoColor=white)](https://github.com/Azure/bicep)
[![Terraform](https://img.shields.io/badge/Terraform-7B42BC?logo=terraform&logoColor=white)](https://www.terraform.io)
[![Copilot](https://img.shields.io/badge/GitHub_Copilot-000000?logo=github-copilot&logoColor=white)](https://github.com/features/copilot)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

## Overview

APEX Accelerator packages the agents, skills, instructions, validators, `.mcp.json` configuration, and dev container from the [upstream APEX project](https://github.com/jonathan-vella/apex) into a ready-to-clone GitHub template. Use it for two workflows:

- **Infrastructure delivery**: Coordinate a multi-step workflow through `01-Orchestrator` from requirements, architecture, retail pricing, and Azure Policy governance to Azure Verified Modules (AVM) in Bicep or Terraform, deployment, and as-built documentation, with independent `challenger-review-subagent` gates.
- **Standalone WAF assessment**: Run `/waf-assess-existing` in `01-Orchestrator` against local IaC, read-only Azure subscriptions, or both to generate a five-pillar Well-Architected review, existing-state architecture diagram, Cost Management report with visual charts, and prioritized action register without entering deployment steps.

---

## Prerequisites

| Requirement            | Details                                                                                                                                  |
| ---------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| **VS Code**            | Latest stable release                                                                                                                    |
| **GitHub Copilot**     | Active license (Individual, Business, or Enterprise)                                                                                     |
| **Docker Desktop**     | Validated on x86-64 and ARM64, including Windows with WSL 2; Linux hosts are supported (GitHub Codespaces is not separately validated)   |
| **Azure access**       | Depends on workflow mode (see modes below)                                                                                               |

**Azure access by mode:**

- **Offline IaC assessment (`Source: iac`) or early Architecture using shared ALZ Corp policy assumptions**: Requires no Azure subscription to start. Target-verified policy evidence and Azure access apply before completing IaC planning, generating code, or deploying.
- **Live standalone WAF assessment (`Source: azure` or `combined`)**: Requires read-only `az login` access (`Reader` and `Cost Management Reader` on target scopes), without running `npm run setup`.
- **Full Step 6 deployment and GitHub Actions OIDC automation**: Requires `Owner` or `Contributor` on the target subscription, plus Management Group `Reader` when enabling automated `Governance Policy Baseline` collection via `npm run setup`.

---

## Quick Start

### 1. Create Your Repository

This repository is a **GitHub Template**, not a fork.

1. Select **Use this template** -> **Create a new repository** at the top of this page
2. Choose an owner and name (for example, `my-infraops-project`)
3. Select **Private** (do not use Public)
4. Select **Create repository**

> Your new repository starts with the same directory structure, a clean commit history,
> and no fork relationship.

### 2. Clone and Configure Your Host

```bash
git clone https://github.com/YOUR-USERNAME/my-infraops-project.git
cd my-infraops-project
```

#### Microsoft Employees: Run This Before Starting the Container

**If you are a Microsoft employee, use the Microsoft launcher below instead of `code .`.**
Run it on your **host**, immediately after cloning, not inside a container or a VS Code integrated terminal.
Connect to your approved corporate network/VPN as required, and **fully exit all VS Code windows first**:
opening another window can reuse an existing process that does not have the feed settings.

On **Windows**, run from PowerShell:

```powershell
.\.devcontainer\open-microsoft.ps1
```

On **Linux, macOS, or WSL**, run from your host shell:

```bash
bash .devcontainer/open-microsoft.sh
```

The launcher opens this repository in VS Code with Microsoft's CFS package feeds for npm, Python, and
PowerShell. The npm/Python settings apply to **image and Feature builds as well as the running container**.
It needs no administrator access, Node.js, or Python on the host; the Windows launcher also works with
Windows PowerShell 5.1. It does not install packages, edit global settings or shell profiles, change credentials,
disable TLS checks, or fall back to public registries. Do not bypass a corporate execution policy if it blocks
the script; use your organization's approved execution method.

Use the launcher again whenever opening a fresh VS Code process for this project. No feed settings are
persisted to your host. Other organizations can supply their own approved feeds using the opt-ins documented
in [Package Sources](.devcontainer/README.md#package-sources).
Microsoft maintainers must also follow the publication-age and approved-source policy in [AGENTS.md](AGENTS.md);
choosing a feed alone does not prove every package meets that policy.

#### Everyone Else: Open Normally

**Not a Microsoft employee? Skip the Microsoft launchers.** The default public registries are unchanged;
apply your own organization's package-source requirements if applicable.

```bash
code .
```

#### Start the Dev Container

When prompted by VS Code, click **"Reopen in Container"** (or run `Dev Containers: Reopen in Container`
from the Command Palette). Build time depends on downloads and host resources. The container pre-installs:

- Azure CLI with Bicep extension
- Terraform CLI with TFLint
- GitHub CLI (`gh`)
- Node.js + npm (validation scripts)
- Python 3 + pip (diagram generation, apex-recall CLI)

If setup fails, inspect **Dev Containers: Show Container Log**. A `HandshakeFailure` while fetching pip from
`files.pythonhosted.org` means that build attempted public PyPI: check that you launched a fresh VS Code process
through the Microsoft script, then rebuild. If the approved feed itself is unavailable or lacks a required
package, stop and resolve that with your package-feed administrator; do not switch to public downloads.

### 3. Initialize Your Repository

After the dev container starts, run the initialization commands:

```bash
npm install
npm run init
npm run sync:workflows
```

**What each command does:**

| Command                  | Purpose                                                                                                                                                                                               |
| ------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `npm install`            | Installs Node.js dependencies for validation scripts and linting.                                                                                                                                     |
| `npm run init`           | One-time setup that replaces template repository references with your repository URL from the git remote. Run `npm run init -- --dry-run` first to preview changes.                                   |
| `npm run sync:workflows` | Previews consumer workflow updates from the [upstream APEX project](https://github.com/jonathan-vella/apex) (`--dry-run` by default). Run `npm run sync:workflows -- --apply --ref <commit-sha>` to write updates from a reviewed commit into `.github/workflows/`. |

> **Note:** The dev container `post-create.sh` script installs Python dependencies (`diagrams` and `apex-recall`)
> automatically, so manual `pip install` commands are unnecessary.

Review and commit the initialized files:

```bash
git --no-pager diff
git add -A && git commit -m "chore: initialize from template"
git push
```

> **Expected diff:** You will see changes to `AGENTS.md`, `CONTRIBUTING.md`, and one or more
> `.github/workflows/` files if you applied workflow updates. You may also see formatting-only changes to `.mcp.json`
> because the dev container normalizes JSON arrays to multi-line format on first start. Commit those changes safely.
>
> **Tip:** Use `git --no-pager diff` instead of plain `git diff` to avoid the `less` pager.
> If `git diff` opens a `:` prompt, press `q` to exit or `Space` to scroll.

### 4. Set Up Azure

Choose the setup level that matches your workflow:

- **Offline IaC assessment (`Source: iac`) or early Architecture with shared ALZ Corp policy assumptions**: Skip Azure sign-in and `npm run setup`. You only need Azure access before completing target-verified IaC planning, generating deployment code, or deploying.
- **Live standalone WAF assessment (`Source: azure` or `combined`)**: Sign in with read-only access (`Reader` and `Cost Management Reader` on target subscriptions) and skip `npm run setup`:

```bash
az login --tenant <TENANT_ID>
az account list --query "[].{name:name, id:id, tenantId:tenantId}" --output table
```

- **Full Step 6 deployment and GitHub Actions OIDC automation**: Run `az login` with `Owner` or `Contributor` on the target subscription (plus Management Group `Reader` if enabling automated `Governance Policy Baseline` collection), then run the idempotent setup script:

```bash
az login
npm run setup
```

`npm run setup` creates a Microsoft Entra ID app registration, configures OIDC federated credentials for `main` and `dev`, `staging`, and `prod` environments, assigns subscription and optional Management Group RBAC roles, and writes GitHub Actions secrets and variables.

See the [Azure Setup documentation](https://apexops.pro/getting-started/azure-setup/)
for headless mode, manual configuration, and troubleshooting.

### 5. Allow GitHub Actions to Create Pull Requests

Scheduled maintenance and sync workflows open pull requests when they detect updates. Enable pull request creation once in repository settings:

1. Open your repository on GitHub
2. Select **Settings -> Actions -> General**
3. Scroll to **Workflow permissions**
4. Check **Allow GitHub Actions to create and approve pull requests**
5. Select **Save**

> **Why:** GitHub disables this permission by default on new repositories.
> Without it, PR-creating workflows fail with:
> `GitHub Actions is not permitted to create or approve pull requests`

### 6. Run the Maintenance Workflows

Repositories created from this template include consumer workflows from APEX's `.github/consumer-workflows/` templates. Job guards keep these workflows inactive inside `jonathan-vella/apex`, this accelerator, and GitHub template repositories, while consumer repositories run them automatically when GitHub Actions runs.

| Workflow                       | Purpose                                                                                                                                                                                                                                 | Trigger / Schedule  |
| ------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------- |
| **Weekly Maintenance**         | Runs `azure-mcp-release` (checks the pinned Azure MCP stable release), `refresh-avm-module-index` (refreshes AVM Bicep and Terraform module indexes and version cache), and `track-deprecations` (updates `.github/data/azure-deprecations.json`). | Mondays 06:00 UTC   |
| **Governance Policy Baseline** | Collects effective Azure Policy assignments at Management Group scope into `.github/data/governance-policy-baseline.json.gz`. Runs only when repository variables `GOVERNANCE_BASELINE_ENABLED=true` and `GOVERNANCE_MG_ID` exist alongside Azure OIDC secrets. | Mondays 05:00 UTC   |
| **IaC Checks**                 | Validates Bicep and Terraform configurations on infrastructure changes.                                                                                                                                                                 | PRs and pushes      |

Seed `Weekly Maintenance` (and `Governance Policy Baseline` if configured) with a manual run:

```bash
gh workflow run "Weekly Maintenance"
gh run list --workflow "Weekly Maintenance" --limit 1

# Run only after setting GOVERNANCE_BASELINE_ENABLED=true, GOVERNANCE_MG_ID, and Azure OIDC secrets:
gh workflow run "Governance Policy Baseline"
gh run list --workflow "Governance Policy Baseline" --limit 1
```

Each refresh workflow opens a pull request for human review when data changes and never enables auto-merge.

---

## Start Your First Workflow

In VS Code Chat, confirm the session target is **Copilot** (local workspace session) and select **`01-Orchestrator`** from the agent picker.

### Option A: Infrastructure Delivery

Use this path to take a workload through the [multi-step delivery workflow](https://apexops.pro/concepts/workflow/): Requirements -> Architecture -> Governance -> IaC Plan -> Bicep or Terraform -> Deploy -> As-Built documentation.

```text
Start a new Azure project named {{PROJECT_NAME}}.
Preferred IaC track: {{BICEP_OR_TERRAFORM}}
Target region: swedencentral
Workload summary: {{WORKLOAD_SUMMARY}}
```

`01-Orchestrator` delegates to `02-Requirements` to collect missing business, resilience, compliance, SKU, and policy-source inputs before advancing to Architecture and independent `challenger-review-subagent` checks.

### Option B: Standalone WAF Assessment

Use `/waf-assess-existing` in `01-Orchestrator` to evaluate an existing workload without entering Governance, IaC planning, or deployment. See the [Standalone WAF Assessment guide](https://apexops.pro/guides/waf-assessment/) and the [standalone assessment contract](.github/skills/apex-workflow-engine/references/standalone-assessment.md).

```text
/waf-assess-existing
Project: {{PROJECT_NAME}}
Scenario: {{SCENARIO}}
Source: {{SOURCE}}
Visual charts: true
Action register: true

Azure read scope:
- Tenant ID: {{TENANT_ID}}
- Subscriptions: {{SUBSCRIPTION_IDS}}
- Resource groups: {{RESOURCE_GROUPS}}
- Allowed read categories: configuration, topology, utilization, operations, recovery, billing, policy
- Guardrails: Read-only access only. Do not read secrets, keys, connection strings, or certificates, and do not modify Azure resources.

IaC and diagrams:
- Paths: {{IAC_AND_DIAGRAM_PATHS}}
```

- **`Scenario`**: Set `evidence_only` to audit available evidence directly without a business interview, or `requirements_led` to capture business targets through `02-Requirements` (every field includes an `Unknown` option).
- **`Source`**: Set `iac` for offline Bicep, Terraform, `azure.yaml`, and diagrams (delete the `Azure read scope` block), `azure` for live read-only subscriptions via `az login` (delete the `IaC and diagrams` block), or `combined` to compare declared IaC against live Azure state.

---

## Project Structure

Key directories in your repository:

```text
.github/
  agents/              # Agent definitions (*.agent.md)
    _subagents/        # Subagent definitions (non-user-invocable)
  prompts/             # Slash-command entry prompts (e.g., waf-assess-existing.prompt.md)
  skills/              # Reusable domain knowledge (SKILL.md per skill)
  instructions/        # File-type rules with glob-based auto-application
  data/                # Policy baselines, AVM module indexes, deprecation data
  copilot-instructions.md  # VS Code Copilot orchestration instructions
  workflows/           # GitHub Actions (sync, CI, maintenance)
agent-output/          # Generated artifacts organized by project
  {project}/           # Delivery (01-requirements.md .. 07-*.md) or assessment bundle
infra/
  bicep/{project}/     # Bicep templates (main.bicep + modules/)
  terraform/{project}/ # Terraform configurations (main.tf + modules/)
tools/
  apex-recall/         # Session state and handoff CLI
  scripts/             # Validation and maintenance scripts
```

### What Is Yours vs. What Is Upstream

| Consumer-owned files (preserved across sync)                              | Upstream-managed files (overwritten by sync)                                                        |
| ------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------- |
| `agent-output/` (generated project artifacts)                             | `.github/agents/`, `.github/skills/`, `.github/instructions/`, `.github/plugins/`                   |
| `infra/bicep/` and `infra/terraform/` (project Bicep and Terraform code)  | `.github/copilot-instructions.md` and `.github/prompts/`                                            |
| `.github/workflows/` and `.github/consumer-workflows-state.json`          | `infra/bicep/AGENTS.md` and `infra/terraform/AGENTS.md` (`SYNC_EXCEPTIONS`)                         |
| `.github/data/` (private governance baselines and refreshed module data)  | `.github/data/alz-corp-policy-baseline.json.gz` (`SYNC_EXCEPTIONS`)                                 |
| `README.md`, `CONTRIBUTING.md`, `CHANGELOG.md`                            | `tools/`, `assets/`, `package.json`, `AGENTS.md`, `.devcontainer/`, `.vscode/`                      |

> **Note**: Upstream Sync preserves `infra/bicep/{project}/`, `infra/terraform/{project}/`, and private files in `.github/data/`, while updating shared `infra/bicep/AGENTS.md`, `infra/terraform/AGENTS.md`, and `.github/data/alz-corp-policy-baseline.json.gz` through `SYNC_EXCEPTIONS`. Disabling Upstream Sync makes every file consumer-managed; see [Customization](#customization).

---

## Customization

### Changing Defaults (Regions, Tags, Naming)

Choose between direct edits and layered overrides depending on whether you keep Upstream Sync active.

**Strategy A: Edit directly** (solo users or teams managing updates manually)

Edit the target file directly, such as changing `swedencentral` to `westeurope` in `.github/skills/apex-azure-defaults/SKILL.md`, and disable **Upstream Sync** in repository **Settings -> Actions**. Re-enabling Upstream Sync later replaces upstream-managed files on the sync PR branch, so record local edits if you plan to re-apply them.

**Strategy B: Keep sync enabled and layer overrides** (recommended for teams tracking upstream updates)

Upstream Sync overwrites upstream-managed files and never touches preserved paths in `EXCLUDE_PATHS`. Store durable overrides in one of three places:

1. **Extend `EXCLUDE_PATHS` in `.github/workflows/weekly-upstream-sync.yml`** (`EXCLUDE_PATHS` already preserves `.github/workflows/`):

   ```yaml
   EXCLUDE_PATHS: |
     .github/workflows/
     agent-output/
     infra/bicep/
     infra/terraform/
     README.md
     AGENTS.md
   ```

   Both the sync step and the preservation check read `EXCLUDE_PATHS`, so root `AGENTS.md` then survives future sync PRs.

2. **Add project-local guidance** in `infra/bicep/{project}/AGENTS.md` or `infra/terraform/{project}/AGENTS.md`. Upstream Sync preserves project subfolders while updating shared `infra/bicep/AGENTS.md` and `infra/terraform/AGENTS.md` via `SYNC_EXCEPTIONS`. Remove an entry from `SYNC_EXCEPTIONS` only if you want to maintain that shared file yourself.

3. **Use VS Code user-profile instructions** by placing a `.instructions.md` file in your local VS Code profile `prompts/` folder outside the repository.

### Adding Custom Agents or Skills

Agent definitions live in `.github/agents/*.agent.md` and skills live in `.github/skills/*/SKILL.md`. If Upstream Sync remains active, add any custom agent or skill paths to `EXCLUDE_PATHS` in `.github/workflows/weekly-upstream-sync.yml` because the mirror step deletes upstream-absent files outside `EXCLUDE_PATHS`.

---

## IaC Tracks: Bicep and Terraform

APEX supports both Bicep and Terraform tracks. `02-Requirements` records your `iac_tool` decision, and `01-Orchestrator` routes planning, code generation, and deployment to the matching track.

| Factor          | Bicep                           | Terraform                                |
| --------------- | ------------------------------- | ---------------------------------------- |
| **Provider**    | Native Azure DSL (ARM)          | AzureRM and AzAPI providers              |
| **State**       | ARM-managed (no state file)     | State file (Azure Storage backend)       |
| **AVM modules** | `br/public:avm/res/`            | `registry.terraform.io/Azure/avm-res-*/` |
| **CI/CD**       | `az deployment group create`    | `terraform plan` + `terraform apply`     |

---

## Multi-Project Support

One repository can host multiple projects in isolated subdirectories:

- `agent-output/{project}/` for requirements, architecture, governance, plans, assessments, and as-built docs
- `infra/bicep/{project}/` or `infra/terraform/{project}/` for IaC modules and entry points

All projects in the repository share the same agents, skills, instructions, and dev container. Create separate repositories from the template when teams need isolated access boundaries or independent Azure OIDC environments.

---

## Keeping Up to Date

| Surface                                               | Update Mechanism                                                           | Cadence        |
| ----------------------------------------------------- | -------------------------------------------------------------------------- | -------------- |
| Agents, skills, instructions, tools, shared baselines | **Upstream Sync** workflow opens a manual-review PR (`automation/upstream-sync`) | Weekly (Sundays) |
| Consumer GitHub Actions workflows                     | `npm run sync:workflows -- --dry-run`, then `--apply --ref <commit-sha>`   | As needed      |
| AVM module index, Azure MCP check, deprecations       | **Weekly Maintenance** workflow opens refresh PRs                          | Weekly (Mondays) |
| Tenant Azure Policy baseline (optional)               | **Governance Policy Baseline** workflow (`GOVERNANCE_BASELINE_ENABLED=true`) | Weekly (Mondays) |
| Local code and documentation checks                   | `npm run validate:all`                                                     | Before each PR |

### Upstream Content Sync

Manual **Upstream Sync** dispatches default to `dry_run=true`, mirroring and running contract checks on the runner without pushing branches or opening pull requests. Set `upstream_ref` to preview an upstream branch; only `main` can publish a sync PR (`dry_run=false`).

Upstream Sync preserves paths in `EXCLUDE_PATHS`, updates shared `SYNC_EXCEPTIONS` (`infra/bicep/AGENTS.md`, `infra/terraform/AGENTS.md`, `.github/data/alz-corp-policy-baseline.json.gz`, and `.github/data/governance-policy-baseline.fixture.json`), and seeds `SEED_PATHS` (AVM CSV/JSON indexes, module cache, and deprecation JSON) only when absent. Passing sync checks does not grant Azure deployment approval.

### Consumer Workflow Updates

Upstream Sync excludes `.github/workflows/` because `GITHUB_TOKEN` cannot push workflow changes by default. Preview and apply reviewed workflow template updates locally:

```bash
npm run sync:workflows -- --dry-run
npm run sync:workflows -- --apply --ref <reviewed-commit-sha>
```

`.github/consumer-workflows-state.json` tracks installed template hashes. Modified local workflow files block the update, and the updater reports retired templates for manual review instead of deleting them. See [consumer workflow ownership](tools/scripts/consumer-workflows.md) and the [Updating APEX guide](https://apexops.pro/guides/updating-apex/).

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

Full validator reference: [Validation Reference](https://apexops.pro/reference/validation-reference/).

---

## Resources

- [APEX documentation](https://apexops.pro/)
- [Quickstart guide](https://apexops.pro/getting-started/quickstart/)
- [Azure Setup guide](https://apexops.pro/getting-started/azure-setup/)
- [Workflow overview](https://apexops.pro/concepts/workflow/)
- [Standalone WAF Assessment guide](https://apexops.pro/guides/waf-assessment/)
- [Updating APEX guide](https://apexops.pro/guides/updating-apex/)
- [Prompt guide](https://apexops.pro/guides/prompt-guide/)
- [Validation reference](https://apexops.pro/reference/validation-reference/)
- [FAQ](https://apexops.pro/reference/faq/)
- [APEX MicroHack](https://microhack.apexops.pro/)
- [APEX upstream repository](https://github.com/jonathan-vella/apex)

## License

[MIT](LICENSE)
