# Agentic Workflow Template - Build Plan

## Objective

Create a reusable template for new projects that leverage the agentic workflow pattern with GitHub Copilot. The
template should include all essential configuration files, agents, and tooling to enable immediate productivity.

## Template Contents

### 1. Dev Container Configuration (`.devcontainer/`)

- [x] `devcontainer.json` - Container configuration with Azure tools, Copilot extensions, editor settings
- [x] `post-create.sh` - Initialization script for Husky hooks and environment setup
- [x] `update-tools.sh` - Tool update script
- [x] `README.md` - Dev container documentation

### 2. GitHub Configuration (`.github/`)

#### Agents (`.github/agents/`)

- [x] `azure-principal-architect.agent.md` - Architecture guidance (NO CODE)
- [x] `bicep-plan.agent.md` - Infrastructure planning with AVM
- [x] `bicep-implement.agent.md` - Bicep code generation
- [x] `diagram-generator.agent.md` - Python architecture diagrams
- [x] `adr-generator.agent.md` - Architecture Decision Records
- [x] `infrastructure-specialist.agent.md` - Unified agent (optional)
- [x] `_shared/defaults.md` - Shared agent configuration

#### Instructions (`.github/instructions/`)

- [x] `bicep-code-best-practices.instructions.md` - Bicep standards
- [x] `terraform-azure.instructions.md` - Terraform standards
- [x] `markdown.instructions.md` - Documentation standards
- [x] `cost-estimate.instructions.md` - Cost estimation format

#### Other GitHub Files

- [x] `copilot-instructions.md` - Main Copilot context (CUSTOMIZE THIS)
- [x] `PULL_REQUEST_TEMPLATE.md` - PR template
- [x] `ISSUE_TEMPLATE/` - Issue templates

#### Workflows (`.github/workflows/`)

- [x] `markdown-lint.yml` - CI markdown validation

### 3. Git Hooks (`.husky/`)

- [x] `pre-commit` - Markdown validation hook
- [x] `_/husky.sh` - Husky runtime

### 4. VS Code Configuration (`.vscode/`)

- [x] `mcp.json` - MCP server configuration (template, no venv path)

### 5. Quality Tooling (Root)

- [x] `package.json` - Husky + markdownlint dependencies (CUSTOMIZE)
- [x] `.markdownlint.json` - Markdown linting rules
- [x] `.markdownlint-cli2.jsonc` - CLI2 configuration
- [x] `.markdownlintignore` - Exclusion patterns
- [x] `.gitattributes` - Line ending normalization
- [x] `.gitignore` - Standard ignore patterns

### 6. Documentation Scaffolding

- [x] `docs/README.md` - Documentation hub template
- [x] `docs/adr/` - ADR directory placeholder
- [x] `docs/diagrams/` - Diagrams directory placeholder
- [x] `infra/bicep/` - Bicep templates directory placeholder
- [x] `.bicep-planning-files/` - Planning files directory placeholder

## Files Requiring Customization

After copying the template, these files MUST be updated:

| File                              | What to Change                                       |
| --------------------------------- | ---------------------------------------------------- |
| `package.json`                    | name, description, repository URL, author            |
| `.github/copilot-instructions.md` | Project name, purpose, structure, naming conventions |
| `.vscode/mcp.json`                | MCP server paths (or remove if not using)            |
| `.github/agents/*.agent.md`       | Domain-specific customizations                       |

## Excluded from Template

These components are project-specific and NOT included:

- `mcp/azure-pricing-mcp/` - MCP server source code (large, optional)
- `scenarios/` - Demo scenarios
- `scripts/` - Project-specific scripts
- `docs/guides/` - Detailed guides (project-specific)
- `CHANGELOG.md`, `CONTRIBUTING.md`, `CONTRIBUTORS.md` - Repo-specific

## Setup Instructions

1. Copy template folder to new location
2. Initialize git: `git init`
3. Update `package.json` with project details
4. Run `npm install` to install Husky and markdownlint
5. Update `.github/copilot-instructions.md` for your project
6. Open in VS Code and "Reopen in Container"
7. Start using agents with `Ctrl+Shift+A`

## Validation Checklist

- [ ] Dev container builds successfully
- [ ] `npm install` completes without errors
- [ ] Git hooks are configured (`git config core.hooksPath`)
- [ ] Agents appear in Copilot agent picker
- [ ] Markdown linting works (`npm run lint:md`)
