# Architecture Diagrams

> **Version 3.6.0** | [Back to Documentation Hub](../README.md)

This folder contains generated architecture diagrams for various scenarios.

## Where Diagrams Live

| Folder                   | Description                           | Last Updated  |
| ------------------------ | ------------------------------------- | ------------- |
| [ecommerce/](ecommerce/) | E-commerce platform architecture      | December 2025 |
| [mcp/](mcp/)             | Azure Pricing MCP server architecture | December 2025 |
| [workflow/](workflow/)   | Agent workflow visualizations         | December 2025 |

> **Freshness Note**: Diagrams are regenerated when infrastructure changes. Check the `.py` file timestamp or run
> the diagram-generator agent to refresh.

## IT Pro Usage

Diagrams help IT Pros explain:

- **Network flows**: VNet peering, NSG rules, private endpoints
- **Security boundaries**: WAF placement, Key Vault access, managed identities
- **Ops dependencies**: Monitoring, backup, DR relationships

## About Diagrams

Architecture diagrams are generated using the `diagram-generator` custom agent, which uses the Python
[diagrams](https://diagrams.mingrammer.com/) library by mingrammer.

### File Types

- `.py` - Python source code for generating diagrams
- `.png` - Generated PNG images
- `.svg` - Scalable vector graphics (when available)
- `.dot` - Graphviz DOT format

## Generating New Diagrams

1. Press `Ctrl+Shift+A` in VS Code
2. Select `diagram-generator`
3. Describe the architecture you want to visualize

The agent will create a Python script and generate the corresponding image.

## Related Documentation

- [S09 Diagrams as Code](../../scenarios/S09-diagrams-as-code/) - Hands-on scenario for diagram generation
- [Visual Elements Guide](../presenter/visual-elements-guide.md) - Using diagrams in presentations
- [Diagram Generator Agent](../../.github/agents/diagram-generator.agent.md) - Agent definition
