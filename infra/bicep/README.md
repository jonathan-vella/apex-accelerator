# Bicep Infrastructure Templates

This folder contains Azure Bicep templates for infrastructure deployment.

## Structure

```
infra/bicep/
├── {project-name}/
│   ├── main.bicep          # Main deployment template
│   ├── main.bicepparam     # Parameter file
│   ├── modules/            # Reusable modules
│   │   ├── network.bicep
│   │   ├── storage.bicep
│   │   └── ...
│   └── deploy.ps1          # Deployment script
```

## Generating Templates

Use the agent workflow:

1. `azure-principal-architect` - Architecture assessment
2. `bicep-plan` - Create implementation plan
3. `bicep-implement` - Generate Bicep code

## Deployment

```powershell
# Navigate to project folder
cd infra/bicep/{project-name}

# Deploy with what-if
./deploy.ps1 -WhatIf

# Deploy
./deploy.ps1
```

## Validation

```bash
# Build (syntax check)
bicep build main.bicep

# Lint (best practices)
bicep lint main.bicep

# Format
bicep format main.bicep
```
