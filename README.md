# Project Name

> **Your Project Tagline** - One sentence describing your project.

## Overview

[Describe what this project does and why it exists]

## Quick Start

### Prerequisites

- Docker Desktop (or alternative: Podman, Colima, Rancher Desktop)
- VS Code with Dev Containers extension
- Azure subscription with Contributor access

### Getting Started

```bash
# Clone repository
git clone https://github.com/YOUR-ORG/YOUR-PROJECT.git
cd your-project

# Open in VS Code
code .

# Reopen in Dev Container
# F1 → "Dev Containers: Reopen in Container"
# Wait 3-5 minutes for initial build

# Authenticate with Azure
az login
az account set --subscription "<your-subscription-id>"

# Verify tools
terraform version && az bicep version && pwsh --version
```

## Agent Workflow

This project uses GitHub Copilot agents for Azure infrastructure development:

```mermaid
%%{init: {'theme':'neutral'}}%%
graph LR
    P["@plan"] --> A[azure-principal-architect]
    A --> B[bicep-plan]
    B --> I[bicep-implement]
```

| Step | Agent                       | Purpose                    |
| ---- | --------------------------- | -------------------------- |
| 1    | `@plan`                     | Create implementation plan |
| 2    | `azure-principal-architect` | Architecture guidance      |
| 3    | `bicep-plan`                | Infrastructure planning    |
| 4    | `bicep-implement`           | Bicep code generation      |

**Usage:** Press `Ctrl+Shift+A` in VS Code to select an agent.

## Project Structure

```
├── .devcontainer/           # Dev container configuration
├── .github/
│   ├── agents/              # Copilot agents
│   ├── instructions/        # AI coding standards
│   └── copilot-instructions.md
├── .bicep-planning-files/   # Implementation plans
├── infra/bicep/             # Bicep templates
└── docs/
    ├── adr/                 # Architecture decisions
    ├── cost-estimates/      # Architecture decisions
    └── diagrams/            # Architecture diagrams
```

## Documentation

- [Copilot Instructions](.github/copilot-instructions.md)
- [Documentation Hub](docs/README.md)
- [Architecture Decisions](docs/adr/README.md)

## Development

### Validation Commands

```bash
# Bicep
bicep build infra/bicep/{project}/main.bicep
bicep lint infra/bicep/{project}/main.bicep

# Markdown
npm run lint:md
```

### Deployment

```powershell
cd infra/bicep/{project}
./deploy.ps1 -WhatIf  # Preview changes
./deploy.ps1          # Deploy
```

## Contributing

1. Create a feature branch
2. Make your changes
3. Run `npm run lint:md` to validate markdown
4. Submit a pull request

## Additional Resources

For advanced usage, reference implementations, or additional documentation, see the main repository:
[azure-agentic-infraops](https://github.com/jonathan-vella/azure-agentic-infraops)

## License

[MIT](LICENSE)
