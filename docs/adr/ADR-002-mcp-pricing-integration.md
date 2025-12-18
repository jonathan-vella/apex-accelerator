# ADR-002: Azure Pricing MCP Server Integration

## Status

Accepted

## Date

2024-01-15

## Context

Cost estimation is a critical part of infrastructure planning. Cloud architects and IT professionals need
accurate cost information to:

1. Create budgets and business cases
2. Compare architectural alternatives
3. Optimize resource selection (SKUs, regions)
4. Provide stakeholders with expected monthly costs

### The Problem

GitHub Copilot has training data that may be outdated for Azure pricing. Azure prices change frequently due to:

- New SKU introductions
- Regional pricing variations
- Promotional offers and reserved capacity discounts
- Currency fluctuations

Relying on Copilot's built-in knowledge would result in inaccurate cost estimates.

### Considered Alternatives

1. **Use Azure Pricing Calculator links** - Direct users to the web calculator
2. **Embed static pricing data** - Include pricing tables in agent prompts
3. **Call Azure Retail Prices API directly** - Use terminal commands to fetch prices
4. **Build custom MCP server** - Dedicated pricing service with caching

## Decision

We built a **custom Model Context Protocol (MCP) server** for Azure pricing that:

1. Integrates with the [Azure Retail Prices API](https://learn.microsoft.com/rest/api/cost-management/retail-prices/azure-retail-prices)
2. Provides 6 specialized tools for different pricing scenarios
3. Caches responses for 1 hour to reduce API calls
4. Uses singleton HTTP session for connection reuse
5. Includes customer discount handling (disabled by default)

### MCP Server Tools

| Tool                     | Purpose                                           |
| ------------------------ | ------------------------------------------------- |
| `azure_price_search`     | Search prices with filters (service, SKU, region) |
| `azure_price_compare`    | Compare prices across regions or SKUs             |
| `azure_region_recommend` | Find cheapest region for a service                |
| `azure_cost_estimate`    | Estimate monthly costs based on usage             |
| `azure_discover_skus`    | List available SKUs for a service                 |
| `get_customer_discount`  | Get/set customer discount percentage              |

### Why MCP?

- **Native Copilot integration** - Tools appear in Copilot's tool list
- **Real-time data** - Always fetches current Azure prices
- **Structured responses** - Returns formatted data Copilot can reason about
- **Extensible** - Easy to add new pricing tools

## Consequences

### Positive

- Cost estimates use real-time Azure pricing data
- Agents can compare regions and recommend cost-optimized options
- Reduces risk of outdated pricing in generated documentation
- Demonstrates MCP extensibility for enterprise scenarios
- Caching reduces API latency for repeated queries

### Negative

- Requires Python environment and dependencies
- Dev container setup needed for seamless experience
- API calls add latency to responses (~2-5 seconds)
- Pricing API has rate limits (may affect heavy usage)

### Mitigations

- Pre-configured in dev container with automatic setup
- 1-hour TTL cache reduces API calls
- Connection pooling for efficient HTTP handling
- Graceful error handling with fallback messages

### Pricing Data Accuracy

**Important**: The MCP server uses the Azure Retail Prices API which provides:

- ✅ Real-time list prices (pay-as-you-go rates)
- ✅ Current SKU availability by region
- ❌ Does NOT include negotiated EA/CSP discounts
- ❌ Does NOT include reserved instance pricing by default
- ❌ Does NOT include promotional offers

All cost estimates should be validated with the [Azure Pricing Calculator](https://azure.microsoft.com/pricing/calculator/)
for production budgeting.

## Implementation Details

### Directory Structure

```
mcp/azure-pricing-mcp/
├── src/azure_pricing_mcp/
│   ├── server.py      # MCP server with caching, session management
│   └── handlers.py    # Tool implementations
├── requirements.txt   # Dependencies (aiohttp, cachetools, mcp)
└── README.md          # Setup and usage documentation
```

### Key Technical Decisions

1. **Singleton HTTP session** - Prevents "Connector is closed" errors
2. **TTLCache (1 hour)** - Balances freshness vs. performance
3. **30-second timeout** - Prevents hanging on slow API responses
4. **Discount default = 0%** - User must explicitly request discounts

## References

- [mcp/azure-pricing-mcp/README.md](../../mcp/azure-pricing-mcp/README.md) - Server documentation
- [Azure Retail Prices API](https://learn.microsoft.com/rest/api/cost-management/retail-prices/azure-retail-prices)
- [Model Context Protocol](https://modelcontextprotocol.io/) - MCP specification
