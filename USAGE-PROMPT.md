# Template Usage Prompt

Use this prompt with `@plan` or your AI assistant to set up a new agentic workflow project.

---

## Prompt Template

```
Create a new Azure infrastructure project using the agentic workflow template.

**Project Details:**
- Project Name: [YOUR PROJECT NAME]
- Description: [Brief description of what this infrastructure will support]
- Primary Region: swedencentral (or specify alternative)
- Environment: dev | staging | prod

**Required Infrastructure:**
- [List the Azure resources you need]
- [e.g., App Service, SQL Database, Storage Account]
- [Key Vault, Virtual Network, etc.]

**Requirements:**
- [Security requirements]
- [Compliance requirements (HIPAA, PCI-DSS, etc.)]
- [Performance requirements]
- [Budget constraints]

**Setup Tasks:**
1. Copy template folder to new location
2. Initialize git repository
3. Update package.json with project name
4. Customize .github/copilot-instructions.md
5. Run npm install to set up Husky hooks
6. Open in Dev Container
7. Begin using the 7-step agent workflow

**Agent Workflow:**
- Step 1: @plan - Create requirements document
- Step 2: azure-principal-architect - Get WAF assessment
- Step 3: diagram-generator / adr-generator - Design artifacts
- Step 4: bicep-plan - Create detailed infrastructure plan
- Step 5: bicep-implement - Generate Bicep templates
- Step 6: Deploy to Azure
- Step 7: workload-documentation-generator - As-built artifacts
```

---

## Example: E-commerce Platform

```
Create a new Azure infrastructure project using the agentic workflow template.

**Project Details:**
- Project Name: contoso-ecommerce
- Description: E-commerce platform with web frontend, API backend, and database
- Primary Region: swedencentral
- Environment: dev (initial), prod (target)

**Required Infrastructure:**
- Azure App Service (frontend + API)
- Azure SQL Database (product catalog, orders)
- Azure Storage (product images, static assets)
- Azure Key Vault (secrets, certificates)
- Azure Front Door (CDN, WAF)
- Virtual Network with private endpoints

**Requirements:**
- PCI-DSS compliance for payment processing
- 99.9% uptime SLA
- Auto-scaling for peak traffic
- Monthly budget: $2,000-3,000

**Setup Tasks:**
1. Copy template to ~/projects/contoso-ecommerce
2. git init && git add . && git commit -m "Initial commit from template"
3. Update package.json: name = "contoso-ecommerce"
4. Customize copilot-instructions.md with e-commerce context
5. npm install
6. Open in VS Code → Reopen in Container
7. Start with azure-principal-architect for architecture assessment
```

---

## Quick Setup Commands

After copying the template to your new location:

```bash
# Navigate to new project
cd ~/your-new-project

# Initialize git
git init

# Install dependencies (sets up Husky hooks)
npm install

# Open in VS Code
code .

# Then: F1 → "Dev Containers: Reopen in Container"
```

## Files to Customize

| File                              | What to Change                                  |
| --------------------------------- | ----------------------------------------------- |
| `package.json`                    | name, description, repository URL, author       |
| `.github/copilot-instructions.md` | Project purpose, structure, naming conventions  |
| `README.md`                       | Project description, quick start, documentation |
| `.vscode/mcp.json`                | Enable/configure MCP servers if needed          |

## Validation Checklist

After setup, verify:

- [ ] Dev container builds successfully
- [ ] `npm install` completes
- [ ] Git hooks configured: `git config core.hooksPath` shows `.husky`
- [ ] Agents appear in Copilot agent picker (`Ctrl+Shift+A`)
- [ ] Markdown linting works: `npm run lint:md`
- [ ] Azure CLI authenticated: `az account show`
