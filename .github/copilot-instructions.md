# Agentic InfraOps - Copilot Instructions

> Azure infrastructure engineered by agents. Verified. Well-Architected. Deployable.

## Quick Reference

| Rule                | Value                                                              |
| ------------------- | ------------------------------------------------------------------ |
| **Default Region**  | `swedencentral` (alt: `germanywestcentral`)                        |
| **Unique Names**    | `var uniqueSuffix = uniqueString(resourceGroup().id)` in main.bicep |
| **Key Vault**       | ≤24 chars: `kv-{short}-{env}-{suffix}`                             |
| **Storage Account** | ≤24 chars, lowercase+numbers only, NO hyphens                      |
| **SQL Server**      | ≤63 chars, Azure AD-only auth required                             |
| **Zone Redundancy** | App Service Plans: P1v4+ (not S1/P1v2)                             |
| **Commits**         | Conventional Commits: `feat:`, `fix:`, `docs:`, `chore:`           |

## Architecture

```text
.github/
├── agents/*.agent.md          # 8 custom agents (project-planner → workload-docs)
├── agents/_shared/defaults.md # Single source: regions, tags, naming, SKUs
├── instructions/*.md          # File-type rules (auto-applied by applyTo glob)
├── templates/*.template.md    # Canonical artifact structures (01-07)
└── prompts/*.prompt.md        # Reusable prompts
agent-output/{project}/        # Generated artifacts (01-requirements.md → 07-*.md)
infra/bicep/{project}/         # Generated Bicep: main.bicep, modules/, deploy.ps1
mcp/azure-pricing-mcp/         # Azure Pricing MCP server (auto-configured)
```

## Seven-Step Workflow

| Step | Agent                       | Output                      | MCP |
| ---- | --------------------------- | --------------------------- | --- |
| 1    | `project-planner`           | `01-requirements.md`        |     |
| 2    | `azure-principal-architect` | `02-architecture-*.md`      | 💰  |
| 3    | `diagram-generator`         | `03-des-*.py/.png`          |     |
| 4    | `bicep-plan`                | `04-implementation-plan.md` | 💰  |
| 5    | `bicep-implement`           | `infra/bicep/{project}/`    |     |
| 6    | `deploy`                    | `06-deployment-summary.md`  |     |
| 7    | `workload-documentation-*`  | `07-*.md` (6 files)         |     |

**Usage**: `Ctrl+Alt+I` → select agent → prompt → approve before next step

## Bicep Patterns

```bicep
// main.bicep - Generate uniqueSuffix ONCE, pass to ALL modules
var uniqueSuffix = uniqueString(resourceGroup().id)
var tags = {
  Environment: environment   // dev, staging, prod
  ManagedBy: 'Bicep'
  Project: projectName
  Owner: owner
}

// Storage: lowercase+numbers only, NO hyphens
var storageName = 'st${take(replace(projectName, '-', ''), 10)}${take(uniqueSuffix, 8)}'

// Key Vault: ≤24 chars with hyphens OK
var kvName = 'kv-${take(projectName, 8)}-${environment}-${take(uniqueSuffix, 6)}'
```

### Security Defaults (Azure Policy Compliance)

```bicep
// Storage - always set these
properties: {
  supportsHttpsTrafficOnly: true
  minimumTlsVersion: 'TLS1_2'
  allowBlobPublicAccess: false
  allowSharedKeyAccess: false  // Use managed identity
}

// SQL Server - Azure AD-only auth required
properties: {
  administrators: {
    azureADOnlyAuthentication: true
    login: sqlAdminGroupName
    sid: sqlAdminGroupObjectId
  }
}
```

## Commands

```bash
# Validation (runs automatically on commit)
bicep build infra/bicep/{project}/main.bicep
npm run lint:md                    # Markdown linting
npm run lint:md:fix                # Auto-fix markdown issues
npm run lint:artifact-templates    # Validate artifact structure

# Deployment
cd infra/bicep/{project}
pwsh -File deploy.ps1 -WhatIf     # Preview changes
pwsh -File deploy.ps1             # Execute deployment
```

## Conventions

- **Artifacts follow templates**: `agent-output/{project}/0X-*.md` must match `.github/templates/0X-*.template.md`
- **Instructions auto-apply**: `.github/instructions/*.instructions.md` apply via `applyTo` glob patterns
- **AVM-first**: Use Azure Verified Modules when available (`br/public:avm/res/...`)
- **Deploy scripts**: Always include `[CmdletBinding(SupportsShouldProcess)]` + `$WhatIfPreference`

## Key Files

| Purpose              | File                                 |
| -------------------- | ------------------------------------ |
| Shared defaults      | `.github/agents/_shared/defaults.md` |
| Bicep best practices | `.github/instructions/bicep-*.md`    |
| Artifact templates   | `.github/templates/*.template.md`    |
| Troubleshooting      | `docs/guides/troubleshooting.md`     |
