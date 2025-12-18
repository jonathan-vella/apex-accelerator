# ADR-003: Azure Verified Modules (AVM) First Approach

## Status

Accepted

## Date

2024-01-15

## Context

When generating Bicep infrastructure code, there are multiple approaches to resource definition:

1. **Raw Bicep resources** - Define each Azure resource directly with full property specification
2. **Custom modules** - Create reusable modules with organization-specific patterns
3. **Azure Verified Modules (AVM)** - Use Microsoft's officially maintained module library

### The Challenge

Azure resources have complex configurations with hundreds of potential properties. A single App Service
deployment might require:

- App Service Plan (with SKU, workers, zone redundancy)
- App Service (with runtime, networking, identity, slots)
- Private Endpoint (with DNS, NIC, subnet)
- Diagnostic Settings (with log categories, metrics)
- Managed Identity (with role assignments)

Writing raw Bicep for each resource is:

- Time-consuming and error-prone
- Inconsistent across teams
- Difficult to maintain as Azure APIs evolve
- Missing security best practices

## Decision

We adopted an **AVM-first approach** where:

1. **Prefer AVM modules** for all supported resources
2. **Fall back to raw Bicep** only when AVM doesn't cover the resource type
3. **Use consistent parameter patterns** across all module calls
4. **Document AVM versions** in planning files for reproducibility

### AVM Module Categories

| Category | Registry Path                   | Example Resources               |
| -------- | ------------------------------- | ------------------------------- |
| Resource | `avm/res/<provider>/<resource>` | VNet, Storage, Key Vault, SQL   |
| Pattern  | `avm/ptn/<pattern-name>`        | Hub-spoke network, Landing zone |
| Utility  | `avm/utl/<utility-name>`        | Naming, tagging utilities       |

### Standard Module Reference Format

```bicep
module keyVault 'br/public:avm/res/key-vault/vault:0.11.0' = {
  name: 'keyVaultDeployment'
  params: {
    name: keyVaultName
    location: location
    tags: tags
    // AVM handles: private endpoints, RBAC, diagnostics, soft delete
    enablePurgeProtection: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
  }
}
```

### Why AVM?

1. **Microsoft maintained** - Updated with latest API versions and security patches
2. **Well-Architected by design** - Implements WAF recommendations out of the box
3. **Tested extensively** - Unit tests, integration tests, policy compliance
4. **Consistent interfaces** - Similar parameter patterns across all modules
5. **Private endpoint support** - Built-in PE configuration for supported resources

## Consequences

### Positive

- 60-80% reduction in Bicep code volume
- Security best practices included by default (TLS 1.2, HTTPS, encryption)
- Easier maintenance as AVM handles API version updates
- Consistent module interface patterns improve learning curve
- Private endpoints and diagnostics are first-class features

### Negative

- Learning curve for AVM parameter structure
- Module versions must be tracked and updated
- Some edge-case configurations may not be exposed
- Dependency on external registry (`mcr.microsoft.com`)
- Raw Bicep still needed for unsupported resource types

### Mitigations

- Agent prompts include common AVM patterns
- Planning files document specific versions to use
- Fallback to raw Bicep is explicitly allowed
- Shared configuration includes AVM module references

## Implementation in Agents

### bicep-plan Agent

Creates planning documents that specify:

- Which AVM modules to use
- Specific versions (e.g., `0.11.0`)
- Required parameters for each module
- Dependencies between modules

### bicep-implement Agent

Generates Bicep code that:

- References AVM modules from public registry
- Uses pinned versions from planning docs
- Follows AVM parameter naming conventions
- Includes proper outputs for module chaining

## AVM Resources

- [AVM Module Index](https://aka.ms/avm/index) - Searchable module catalog
- [AVM GitHub](https://github.com/Azure/bicep-registry-modules) - Source code
- [AVM Contribution Guide](https://aka.ms/avm/contribute) - Module development

## Common AVM Modules Used

| Resource Type        | AVM Module Path                          | Version |
| -------------------- | ---------------------------------------- | ------- |
| Virtual Network      | `avm/res/network/virtual-network`        | 0.5.0   |
| NSG                  | `avm/res/network/network-security-group` | 0.4.0   |
| Key Vault            | `avm/res/key-vault/vault`                | 0.11.0  |
| Storage Account      | `avm/res/storage/storage-account`        | 0.14.0  |
| SQL Server           | `avm/res/sql/server`                     | 0.10.0  |
| App Service Plan     | `avm/res/web/serverfarm`                 | 0.4.0   |
| App Service          | `avm/res/web/site`                       | 0.12.0  |
| Log Analytics        | `avm/res/operational-insights/workspace` | 0.9.0   |
| Application Insights | `avm/res/insights/component`             | 0.4.0   |

> **Note**: Versions shown are examples. Always check [AVM Index](https://aka.ms/avm/index) for latest.

## References

- [.github/agents/\_shared/defaults.md](../../.github/agents/_shared/defaults.md) - Shared AVM references
- [.github/agents/bicep-plan.agent.md](../../.github/agents/bicep-plan.agent.md) - Planning agent
- [.github/agents/bicep-implement.agent.md](../../.github/agents/bicep-implement.agent.md) - Implementation agent
