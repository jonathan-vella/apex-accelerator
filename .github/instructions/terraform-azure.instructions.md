---
description: "Best practices for Azure infrastructure solutions using Terraform and Azure Verified Modules"
applyTo: "**/*.terraform, **/*.tf, **/*.tfvars, **/*.tflint.hcl, **/*.tfstate, **/*.tf.json, **/*.tfvars.json"
---

# Azure Terraform Best Practices

Guidelines for creating secure, maintainable, and Well-Architected Azure infrastructure using Terraform.
Leverage Azure Verified Modules (AVM) whenever available to reduce maintenance burden and align with
Microsoft best practices.

## General Instructions

- Use latest stable Terraform and Azure provider versions
- Default to `swedencentral` region (alternative: `germanywestcentral` for quota issues)
- Use Azure Verified Modules (AVM) for all significant resources
- Store state in Azure Storage backend with state locking enabled
- Never commit state files or secrets to source control
- Check for planning files in `.terraform-planning-files/` folder when present

## Anti-Patterns to Avoid

| Category      | Anti-Pattern                   | Why to Avoid             | Solution                       |
| ------------- | ------------------------------ | ------------------------ | ------------------------------ |
| Configuration | Hardcoded values               | Reduces reusability      | Use variables with defaults    |
| Configuration | `terraform import` as workflow | Creates drift risk       | Define resources in code       |
| Configuration | Complex conditionals           | Hard to maintain         | Simplify or use modules        |
| Configuration | `local-exec` provisioners      | Unreliable, not portable | Use native resources           |
| Security      | Secrets in state files         | Security vulnerability   | Use ephemeral secrets (v1.11+) |
| Security      | Overly permissive IAM          | Violates least privilege | Scope permissions narrowly     |
| Security      | Default passwords/keys         | Security risk            | Use managed identities         |
| Operational   | Direct production changes      | Bypasses review          | Use CI/CD pipelines            |
| Operational   | Manual resource changes        | Causes state drift       | All changes via Terraform      |
| Operational   | Local machine deployments      | No audit trail           | Use automation pipelines       |

---

## Code Organization

Structure Terraform configurations with logical file separation:

| File           | Purpose                      |
| -------------- | ---------------------------- |
| `main.tf`      | Core resources               |
| `variables.tf` | Input variables              |
| `outputs.tf`   | Output values                |
| `terraform.tf` | Provider configuration       |
| `locals.tf`    | Local values and expressions |

- Use `snake_case` for variables and module names
- Run `terraform fmt` to ensure consistent formatting
- Split large files by resource type (e.g., `main.networking.tf`, `variables.networking.tf`)

## Azure Verified Modules (AVM)

Use Azure Verified Modules for all significant resources. AVMs align with the Well-Architected Framework
and reduce maintenance burden.

- Discover AVMs at [Azure Verified Modules Registry](https://registry.terraform.io/namespaces/Azure)
- If no AVM exists, create resources "in the style of" AVM for consistency
- Exception: User explicitly requests not to use AVM or uses private registry

## Code Style Standards

Follow AVM-aligned coding standards:

| Standard          | Rule                                | Reference       |
| ----------------- | ----------------------------------- | --------------- |
| Variable naming   | Use `snake_case` for all names      | TFNFR4, TFNFR16 |
| Type declarations | Explicit types on all variables     | TFNFR18         |
| Descriptions      | Comprehensive descriptions required | TFNFR17         |
| Sensitive values  | Mark sensitive appropriately        | TFNFR22         |
| Dynamic blocks    | Use for optional nested objects     | TFNFR12         |

## Secrets Management

Prefer managed identities over stored secrets. When secrets are required:

- Use `ephemeral` secrets with write-only parameters (Terraform v1.11+)
- Store secrets in Key Vault, not in code or state
- Never write secrets to local filesystem or git
- Mark sensitive values appropriately

## Outputs

Expose only information needed by other configurations:

### Good Example - Well-documented outputs

```hcl
output "resource_group_name" {
  description = "Name of the created resource group"
  value       = azurerm_resource_group.example.name
}

output "virtual_network_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.example.id
}
```

### Bad Example - Unnecessary or undocumented outputs

```hcl
output "rg" {
  value = azurerm_resource_group.example.name  # Missing description
}

output "everything" {
  value = azurerm_resource_group.example  # Exposes unnecessary attributes
}
```

## Local Values

Use locals for computed values and complex expressions:

### Good Example - Structured locals

```hcl
locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    Owner       = var.owner
    CreatedBy   = "terraform"
  }

  resource_name_prefix = "${var.project_name}-${var.environment}"
  location_short       = substr(var.location, 0, 3)
}
```

## Terraform Best Practices

| Practice     | Rule                                 | Notes                         |
| ------------ | ------------------------------------ | ----------------------------- |
| Dependencies | Remove redundant `depends_on`        | Use implicit references       |
| Iteration    | `count` for 0-1, `for_each` for many | Maps provide stable addresses |
| Data sources | OK in root modules                   | Avoid in reusable modules     |
| Versioning   | Target latest stable versions        | Specify in terraform.tf       |

## Folder Structure

Use tfvars for environment differences. Avoid branch/folder per environment anti-patterns.

```text
my-azure-app/
├── infra/                          # Terraform root module
│   ├── main.tf                     # Core resources
│   ├── variables.tf                # Input variables
│   ├── outputs.tf                  # Outputs
│   ├── terraform.tf                # Provider configuration
│   ├── locals.tf                   # Local values
│   └── environments/               # Environment-specific configs
│       ├── dev.tfvars
│       ├── test.tfvars
│       └── prod.tfvars
├── .github/workflows/              # CI/CD pipelines
└── README.md                       # Documentation
```

## Azure Best Practices

### Resource Naming and Tagging

- Follow [Azure naming conventions](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)
- Use consistent region naming for multi-region deployments
- Implement consistent tagging strategy

### Networking

- Validate existing VNet/subnet IDs before creating new resources
- Use NSGs and ASGs appropriately
- Implement private endpoints for PaaS services
- Comment exceptions where public endpoints are required

### Security and Compliance

- Use Managed Identities instead of service principals
- Implement Key Vault with appropriate RBAC
- Enable diagnostic settings for audit trails
- Follow principle of least privilege

## Cost Management

- Confirm budget approval for expensive resources
- Use environment-appropriate sizing (dev vs prod)
- Ask for cost constraints if not specified

## State Management

- Use remote backend (Azure Storage) with state locking
- Never commit state files to source control
- Enable encryption at rest and in transit

## Validation

Run these commands before committing Terraform code:

```bash
# Format code
terraform fmt -recursive

# Validate syntax
terraform validate

# Plan changes (requires ARM_SUBSCRIPTION_ID env var)
terraform plan -var-file=environments/dev.tfvars

# Security scan
tfsec .
checkov -d .
```

## Maintenance

- Review instructions when provider versions update
- Update examples to reflect current patterns
- Remove deprecated resource types
- Keep AVM module versions current
