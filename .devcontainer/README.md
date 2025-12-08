# Development Container

This devcontainer provides a complete, pre-configured development environment for agentic workflow projects.

**Base Image:** `mcr.microsoft.com/devcontainers/base:ubuntu-24.04`

## What's Included

### Infrastructure as Code Tools

- **Terraform CLI** (latest) with tfsec pre-installed
- **Azure CLI** (latest) with Bicep CLI
- **Checkov** - Infrastructure security scanner

### Scripting & Automation

- **PowerShell 7+** with Az modules
- **Python 3.12** with pip
- **Node.js LTS** with npm
- **Go** (latest) for Terratest

### VS Code Extensions (27 Pre-installed)

- GitHub Copilot + Chat + Mermaid Diagrams
- Azure Tools (Bicep, Resource Groups, Container Apps, etc.)
- HashiCorp Terraform
- Markdown (Mermaid, GitHub preview, linting)

## Quick Start

1. Open VS Code in this repository folder
2. Press `F1` → `Dev Containers: Reopen in Container`
3. Wait 3-5 minutes for initial build

### First-Time Setup

```bash
# Authenticate with Azure
az login

# Set your default subscription
az account set --subscription "<your-subscription-id>"

# Verify tools
terraform version && az bicep version && pwsh --version
```

## Environment Configuration

| Variable                  | Value                           | Purpose                  |
| ------------------------- | ------------------------------- | ------------------------ |
| `TF_PLUGIN_CACHE_DIR`     | `/home/vscode/.terraform-cache` | Terraform provider cache |
| `AZURE_DEFAULTS_LOCATION` | `swedencentral`                 | Default Azure region     |

## Troubleshooting

| Issue                 | Solution                                                 |
| --------------------- | -------------------------------------------------------- |
| Container won't start | Check Docker running, increase memory to 4GB+            |
| Tool not found        | Run `bash .devcontainer/post-create.sh`                  |
| Azure auth fails      | Use `az login --use-device-code`                         |
| Rebuild needed        | `F1` → `Dev Containers: Rebuild Container Without Cache` |
