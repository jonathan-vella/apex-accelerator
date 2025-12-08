# Usage Examples 📖

Real-world examples of using the Azure Pricing MCP Server with VS Code Copilot or Claude Desktop.

---

## Table of Contents

- [Basic Price Queries](#basic-price-queries)
- [Multi-Node & Cluster Pricing](#multi-node--cluster-pricing)
- [Price Comparisons](#price-comparisons)
- [Region Recommendations](#region-recommendations)
- [Cost Estimations](#cost-estimations)
- [SKU Discovery](#sku-discovery)
- [Storage Pricing](#storage-pricing)
- [Sample API Responses](#sample-api-responses)
- [Reference Tables](#reference-tables)

---

## Basic Price Queries

### Virtual Machine Pricing

**Query:**
```
What's the price of a Standard_D4s_v3 VM in East US?
```

**What happens:**
- Tool: `azure_price_search`
- Filters: `service_name=Virtual Machines`, `sku_name=D4s v3`, `region=eastus`

**Sample Response:**
```
Standard_D4s_v3 in East US:
- Linux: $0.192/hour
- Windows: $0.384/hour
- 1-Year Savings Plan: $0.134/hour (30% savings)
- 3-Year Savings Plan: $0.106/hour (45% savings)
```

---

### Database Pricing

**Query:**
```
What are the prices for Azure SQL Database in West Europe?
```

**What happens:**
- Tool: `azure_price_search`
- Filters: `service_name=Azure SQL Database`, `region=westeurope`

---

### GPU VM Pricing

**Query:**
```
Show me NVIDIA GPU VM pricing in East US 2
```

**What happens:**
- Tool: `azure_price_search`
- Filters: `service_name=Virtual Machines`, `sku_name=NC`, `region=eastus2`

---

## Multi-Node & Cluster Pricing

### AKS Node Pool Pricing

**Query:**
```
Price for 20 Standard_D32s_v6 nodes in East US 2 for AKS
```

**Sample Response:**
```
Standard_D32s_v6 in East US 2:

| Option              | Hourly/Node | Monthly/Node | 20 Nodes/Month |
|---------------------|-------------|--------------|----------------|
| Linux On-Demand     | $1.613      | $1,177.49    | $23,549.80     |
| 1-Year Savings Plan | $1.113      | $812.49      | $16,249.82     |
| 3-Year Savings Plan | $0.742      | $541.65      | $10,832.93     |
| Windows             | $3.085      | $2,252.05    | $45,041.00     |
| Linux Spot          | $0.313      | $228.43      | $4,568.66      |
```

---

### Kubernetes Cluster Cost Estimate

**Query:**
```
Estimate monthly cost for a Kubernetes cluster with:
- 5 D8s_v5 nodes for system
- 20 D16s_v5 nodes for workloads
- All in East US
```

---

## Price Comparisons

### Cross-Region Comparison

**Query:**
```
Compare D4s_v5 VM prices between eastus, westeurope, and southeastasia
```

**What happens:**
- Tool: `azure_price_compare`
- Parameters: `service_name=Virtual Machines`, `sku_name=D4s v5`, `regions=[eastus, westeurope, southeastasia]`

**Sample Response:**
```
D4s_v5 Price Comparison:

| Region        | Hourly Price | Monthly (730h) |
|---------------|--------------|----------------|
| eastus        | $0.192       | $140.16        |
| westeurope    | $0.211       | $154.03        |
| southeastasia | $0.221       | $161.33        |

💡 East US is 13% cheaper than Southeast Asia
```

---

### SKU Comparison

**Query:**
```
Compare storage options: Premium SSD vs Standard SSD vs Standard HDD
```

---

## Region Recommendations

The region recommendation tool supports multiple SKU name formats for convenience:
- **Display format**: `D4s v5`, `E4as v5`
- **ARM format**: `Standard_D4s_v5`, `Standard_E4as_v5`
- **Underscore format**: `D4s_v5`, `E4as_v5`

All formats are automatically normalized and will return the same results.

### Find Cheapest Regions for VMs

**Query:**
```
What are the cheapest regions for D4s v5 VMs?
```

or equivalently:
```
What are the cheapest regions for Standard_D4s_v5 VMs?
```

**What happens:**
- Tool: `azure_region_recommend`
- Parameters: `service_name=Virtual Machines`, `sku_name=D4s v5`, `top_n=10`

**Sample Response:**
```
🌍 Region Recommendations for Virtual Machines - D4s v5

Currency: USD
Total regions found: 34
Showing top: 10

📊 Summary:
   🥇 Cheapest: IN Central (centralindia) - $0.023400
   🥉 Most Expensive: BR South (brazilsouth) - $0.117000
   💰 Max Savings: 80.0% by choosing the cheapest region

📋 Ranked Recommendations:

| Rank | Region | Location | Price | Savings vs Max |
|------|--------|----------|-------|----------------|
| 🥇 1 | centralindia | IN Central | $0.0234/hr | 80.0% |
| 🥈 2 | eastus2 | US East 2 | $0.0336/hr | 71.2% |
| 🥉 3 | eastus | US East | $0.0336/hr | 71.2% |
| 4 | westus3 | US West 3 | $0.0336/hr | 71.2% |
| 5 | northcentralus | US North Central | $0.0364/hr | 68.9% |
```

---

### AKS Cluster - Find Cheapest Region

**Query:**
```
Find the cheapest regions for running D8s v6 nodes
```

or with ARM format:
```
Find the cheapest regions for Standard_D8s_v6
```

**What happens:**
- Tool: `azure_region_recommend`
- Parameters: `service_name=Virtual Machines`, `sku_name=D8s v6`, `top_n=5`

---

### Region Recommendations with Discount

**Query:**
```
Show cheapest regions for E4s v5 VMs with my 15% enterprise discount
```

**What happens:**
- Tool: `azure_region_recommend`
- Parameters: `service_name=Virtual Machines`, `sku_name=E4s v5`, `discount_percentage=15`

---

## Cost Estimations

### Development Environment

**Query:**
```
Estimate monthly cost for D4s_v5 running 10 hours per day, 22 days per month
```

**What happens:**
- Tool: `azure_cost_estimate`
- Parameters: `service_name=Virtual Machines`, `sku_name=D4s v5`, `region=eastus`, `hours_per_month=220`

**Sample Response:**
```
Cost Estimate for D4s_v5 (Dev Environment)

Usage: 220 hours/month (10hr/day × 22 days)

On-Demand:
- Hourly: $0.192
- Monthly: $42.24
- Yearly: $506.88

With 1-Year Savings Plan:
- Monthly: $29.48
- Yearly: $353.76
- Savings: $153.12/year (30%)

With 3-Year Savings Plan:
- Monthly: $23.32
- Yearly: $279.84
- Savings: $227.04/year (45%)
```

---

### Production 24/7 Workload

**Query:**
```
Estimate yearly cost for E8s_v5 running 24/7 in West US 2
```

---

## SKU Discovery

### Find Available VM Sizes

**Query:**
```
What VM sizes are available for compute-intensive workloads?
```

**What happens:**
- Tool: `azure_sku_discovery`
- Parameters: `service_hint=compute`

---

### App Service Plans

**Query:**
```
What App Service plans are available?
```

**What happens:**
- Tool: `azure_sku_discovery`
- Parameters: `service_hint=app service`
- Uses fuzzy matching: "app service" → "Azure App Service"

**Sample Response:**
```
SKU Discovery for 'app service' (mapped to: Azure App Service)

📦 Azure App Service Basic:
   • B1: $0.018/hour
   • B2: $0.036/hour
   • B3: $0.072/hour

📦 Azure App Service Standard:
   • S1: $0.10/hour
   • S2: $0.20/hour
   • S3: $0.40/hour

📦 Azure App Service Premium v3:
   • P1v3: $0.125/hour
   • P2v3: $0.25/hour
   • P3v3: $0.50/hour
```

---

### Fuzzy Service Name Matching

The `azure_sku_discovery` tool supports common aliases:

| You Say | Maps To |
|---------|---------|
| "vm", "virtual machine" | Virtual Machines |
| "app service", "web app" | Azure App Service |
| "sql", "database" | Azure SQL Database |
| "kubernetes", "aks", "k8s" | Azure Kubernetes Service |
| "storage", "blob" | Storage |
| "redis", "cache" | Azure Cache for Redis |
| "cosmos", "cosmosdb" | Azure Cosmos DB |
| "functions", "serverless" | Azure Functions |

---

## Storage Pricing

### Block Blob Operations

**Query:**
```
How much does 100,000 write operations on Block Blob LRS GPv1 in East US cost?
```

**Sample Response:**
```
Block Blob LRS (GPv1) - East US:
- Write Operations: $0.00036 per 10K
- 100,000 operations = 10 × 10K
- Total: $0.0036

With 10% customer discount: $0.00324
```

---

### Storage Tiers Comparison

**Query:**
```
Compare Hot, Cool, and Archive storage pricing in East US
```

---

## Sample API Responses

### Price Search Response

```json
{
  "items": [
    {
      "service": "Virtual Machines",
      "product": "Virtual Machines Dsv6 Series",
      "sku": "D32s v6",
      "region": "eastus2",
      "location": "US East 2",
      "discounted_price": 1.4517,
      "original_price": 1.613,
      "unit": "1 Hour",
      "type": "Consumption",
      "savings_plans": [
        {"retailPrice": 0.742, "term": "3 Years"},
        {"retailPrice": 1.113, "term": "1 Year"}
      ],
      "savings_amount": 0.1613,
      "savings_percentage": 10.0
    }
  ],
  "count": 1,
  "currency": "USD",
  "discount_applied": {
    "percentage": 10.0,
    "note": "Prices shown are after discount"
  }
}
```

### Cost Estimate Response

```
Cost Estimate for Virtual Machines - D4s v5
Region: eastus
Product: Virtual Machines Dsv5 Series
Unit: 1 Hour
Currency: USD

💰 10.0% discount applied - All prices shown are after discount

Usage Assumptions:
- Hours per month: 730
- Hours per day: 23.98

On-Demand Pricing:
- Hourly Rate: $0.1728
- Daily Cost: $4.15
- Monthly Cost: $126.14
- Yearly Cost: $1,513.73

Savings Plans Available:

1 Year Term:
- Hourly Rate: $0.1206
- Monthly Cost: $88.04
- Yearly Cost: $1,056.46
- Savings: 30.21% ($457.27 annually)

3 Years Term:
- Hourly Rate: $0.0954
- Monthly Cost: $69.64
- Yearly Cost: $835.70
- Savings: 44.80% ($678.03 annually)
```

---

## Reference Tables

### Common Azure Service Names

> ⚠️ Service names are **case-sensitive**!

| Service | Exact Name |
|---------|------------|
| Virtual Machines | `Virtual Machines` |
| Storage | `Storage` |
| SQL Database | `Azure SQL Database` |
| Cosmos DB | `Azure Cosmos DB` |
| Kubernetes | `Azure Kubernetes Service` |
| App Service | `Azure App Service` |
| Functions | `Azure Functions` |
| Redis Cache | `Azure Cache for Redis` |
| PostgreSQL | `Azure Database for PostgreSQL` |
| MySQL | `Azure Database for MySQL` |
| OpenAI | `Azure OpenAI` |
| AI Services | `Azure AI services` |

---

### Common Azure Regions

| Region Code | Location |
|-------------|----------|
| `eastus` | US East |
| `eastus2` | US East 2 |
| `westus` | US West |
| `westus2` | US West 2 |
| `westus3` | US West 3 |
| `centralus` | US Central |
| `westeurope` | West Europe |
| `northeurope` | North Europe |
| `uksouth` | UK South |
| `eastasia` | East Asia |
| `southeastasia` | Southeast Asia |
| `japaneast` | Japan East |
| `australiaeast` | Australia East |
| `canadacentral` | Canada Central |
| `brazilsouth` | Brazil South |

---

### Service Families

| Family | Includes |
|--------|----------|
| `Compute` | VMs, AKS, Container Instances, App Service |
| `Storage` | Blob, Files, Disks, Data Lake |
| `Databases` | SQL, Cosmos DB, PostgreSQL, MySQL |
| `Networking` | VNet, Load Balancer, Application Gateway, CDN |
| `AI + Machine Learning` | OpenAI, Cognitive Services, ML |
| `Analytics` | Synapse, Data Factory, HDInsight |

---

## Tips for Best Results

| Tip | Example |
|-----|---------|
| ✅ Be specific with SKU names | `D4s_v5` not just `D4` |
| ✅ Use exact region codes | `eastus` not `East US` |
| ✅ Check savings plans | Always compare 1yr and 3yr options |
| ✅ Use fuzzy discovery | `azure_sku_discovery` for unknown services |
| ✅ Specify currency if needed | Add `currency_code=EUR` |
| ✅ Filter by price type | `Consumption`, `Reservation`, `DevTestConsumption` |

---

## Troubleshooting

### No Results Returned

- ❌ Service name misspelled or wrong case
- ❌ SKU doesn't exist in that region
- ❌ Region name incorrect

**Fix:** Try a broader search first, then narrow down.

### Unexpected Prices

- Check if you're looking at Spot vs On-Demand
- Windows vs Linux pricing differs significantly
- Some meters show per-hour, others per-month

### Too Many Results

- Add more filters (region, SKU name)
- Use `limit` parameter to reduce results

---

<p align="center">
  <b>Questions?</b> Check <a href="README.md">README.md</a> or open an <a href="https://github.com/msftnadavbh/AzurePricingMCP/issues">issue</a>!
</p>
