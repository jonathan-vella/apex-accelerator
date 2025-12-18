# ADR-004: Default Region Selection (swedencentral)

## Status

Accepted

## Date

2024-01-15

## Context

Azure infrastructure deployments require specifying a region. The choice of region affects:

1. **Latency** - Distance from end users impacts response times
2. **Compliance** - Data sovereignty and regulatory requirements
3. **Cost** - Pricing varies by region (sometimes 10-30% difference)
4. **Availability** - Not all services/SKUs are available in all regions
5. **Sustainability** - Carbon footprint varies by data center energy sources

### The Problem

Without a default, every demo and example would need region specification, leading to:

- Inconsistent examples across documentation
- User confusion about which region to choose
- Potential deployment failures due to service unavailability

### Considered Alternatives

| Region               | Pros                                    | Cons                              |
| -------------------- | --------------------------------------- | --------------------------------- |
| `eastus`             | Most services, lowest latency for US    | Crowded, quota issues, US-centric |
| `westeurope`         | Good EU coverage, mature region         | High demand, capacity constraints |
| `northeurope`        | EU data residency, good availability    | Ireland location may not suit all |
| `swedencentral`      | 100% renewable energy, EU, full service | Newer region, less familiarity    |
| `germanywestcentral` | EU, strong compliance, good perf        | German-specific requirements      |

## Decision

We selected **`swedencentral`** as the default region with **`germanywestcentral`** as the documented
alternative when quota issues arise.

### Selection Criteria

| Criterion            | swedencentral | Rationale                                 |
| -------------------- | ------------- | ----------------------------------------- |
| EU Data Residency    | ✅            | Complies with GDPR, EU data sovereignty   |
| Service Availability | ✅            | Full Azure service catalog                |
| Sustainability       | ✅            | 100% renewable energy, carbon-neutral ops |
| Availability Zones   | ✅            | 3 AZs for high availability               |
| Quota Availability   | ✅            | Less crowded than westeurope/northeurope  |
| Competitive Pricing  | ✅            | Comparable to other EU regions            |

### Configuration Approach

1. **Agent prompts** default to `swedencentral` in examples
2. **Bicep parameters** use `@allowed` decorator with recommended regions
3. **Documentation** explains when to deviate from default
4. **Fallback guidance** points to `germanywestcentral`

```bicep
@description('Azure region for all resources')
@allowed([
  'swedencentral'      // Primary - sustainable, full services
  'germanywestcentral' // Alternative - quota/compliance
  'northeurope'        // Alternative - Ireland
  'westeurope'         // Alternative - Netherlands
])
param location string = 'swedencentral'
```

## Consequences

### Positive

- Consistent examples throughout repository
- Environmentally conscious default (sustainability messaging)
- Good service availability and zone redundancy
- Fewer quota issues than overcrowded regions
- Clear guidance for when to deviate

### Negative

- Users in Americas or APAC have higher latency
- Some users may be unfamiliar with Swedish region
- Certain preview features may launch in US regions first

### When to Use Other Regions

The documentation provides clear guidance:

1. **Geographic latency** - Use regional alternatives (eastus, southeastasia)
2. **Compliance requirements** - Use country-specific regions (germanywestcentral, uksouth)
3. **Service availability** - Check Azure Products by Region
4. **Quota issues** - Fall back to germanywestcentral or other EU regions
5. **Cost optimization** - Use Azure Pricing MCP to compare regions

## Implementation

### Shared Configuration

Region defaults are centralized in `.github/agents/_shared/defaults.md`:

```yaml
default_region: swedencentral
fallback_region: germanywestcentral
region_abbreviations:
  swedencentral: swc
  germanywestcentral: gwc
  northeurope: neu
  westeurope: weu
```

### Copilot Instructions

`copilot-instructions.md` includes:

- Default region guidance
- Alternative region selection criteria
- Links to Azure compliance documentation
- Quota troubleshooting tips

## References

- [.github/copilot-instructions.md](../../.github/copilot-instructions.md) - Regional guidance
- [.github/agents/\_shared/defaults.md](../../.github/agents/_shared/defaults.md) - Shared config
- [Azure Regions](https://azure.microsoft.com/explore/global-infrastructure/geographies/)
- [Azure Sustainability](https://azure.microsoft.com/explore/global-infrastructure/sustainability/)
- [Azure Products by Region](https://azure.microsoft.com/global-infrastructure/services/)
