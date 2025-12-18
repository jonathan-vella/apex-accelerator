# Workflow Documentation

This folder contains the complete guide to the Agentic InfraOps seven-step agentic workflow.

## Quick Reference

```mermaid
%%{init: {'theme':'neutral'}}%%
graph LR
    A["@plan<br/>Step 1"] --> B["architect<br/>Step 2"]
    B --> C["Design<br/>Step 3"]
    C --> D["bicep-plan<br/>Step 4"]
    D --> E["implement<br/>Step 5"]
    E --> F["Deploy<br/>Step 6"]
    F --> G["As-Built<br/>Step 7"]
```

| Step | Agent/Phase                 | Purpose                                    |
| ---- | --------------------------- | ------------------------------------------ |
| 1    | `@plan`                     | Generate implementation plan               |
| 2    | `azure-principal-architect` | WAF assessment, architecture guidance      |
| 3    | Design Artifacts            | Design diagrams + ADRs (`-des` suffix)     |
| 4    | `bicep-plan`                | AVM module selection, governance discovery |
| 5    | `bicep-implement`           | Generate validated Bicep templates         |
| 6    | Deploy                      | Deploy to Azure                            |
| 7    | As-Built Artifacts          | As-built diagrams + ADRs (`-ab` suffix)    |

> **Note**: Steps 3 and 7 are optional artifact phases using `diagram-generator` and `adr-generator`.

## Main Documentation

➡️ **[WORKFLOW.md](WORKFLOW.md)** — Complete guide with detailed instructions for each step

This comprehensive guide covers:

- How to invoke and use each agent
- Approval gates and when to proceed
- Best practices for effective prompting
- Common patterns and anti-patterns
- Troubleshooting workflow issues

## Related Documentation

- [Quick Start](../guides/quickstart.md) — 10-minute setup + first workflow run
- [Getting Started Journey](../guides/getting-started-journey.md) — Comprehensive onboarding with learning paths
- [Troubleshooting](../guides/troubleshooting.md) — Common issues and solutions
- [Agent Definitions](../../.github/agents/) — Customize agent behavior
