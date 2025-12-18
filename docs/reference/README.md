# Reference Documentation

> **Single source of truth** for Agentic InfraOps patterns and defaults

This folder contains authoritative reference documentation. Other docs and agent files should link to these
documents rather than duplicating content.

## Contents

| Document                                 | Purpose                                                             |
| ---------------------------------------- | ------------------------------------------------------------------- |
| [defaults.md](defaults.md)               | Regions, CAF naming conventions, required tags, SKU recommendations |
| [agents-overview.md](agents-overview.md) | All 7 agents in one comparison table with usage examples            |
| [workflow.md](workflow.md)               | Canonical 7-step workflow diagram                                   |
| [bicep-patterns.md](bicep-patterns.md)   | Critical Bicep deployment patterns                                  |

## Why Single Source of Truth?

Before this consolidation, patterns like region defaults appeared in 10+ files. When updating from
`westeurope` to `swedencentral`, every file needed manual updates.

Now: Update `defaults.md` once, all other docs reference it.

## For Agent Authors

When creating or updating agent definitions in `.github/agents/`:

```markdown
<!-- Reference shared defaults instead of duplicating -->

📖 **Region Defaults**: See [docs/reference/defaults.md](../../docs/reference/defaults.md)
📖 **Naming Conventions**: See [docs/reference/defaults.md#caf-naming-conventions](../../docs/reference/defaults.md)
```
