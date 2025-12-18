---
description: "Standards for Azure cost estimate documentation with architecture and business context"
applyTo: "**/03-des-cost-estimate.md, **/07-ab-cost-estimate.md, **/docs/*-cost-estimate.md"
---

# Azure Cost Estimate Documentation Standards

## Document Purpose

Cost estimates provide:

- **Financial clarity** for budget approvals
- **Architecture context** linking costs to design decisions
- **Optimization guidance** for reducing costs
- **Visual impact** through callouts and progress indicators

---

## Required Header

```markdown
# Azure Cost Estimate: {Project Name}

**Generated**: {YYYY-MM-DD}
**Region**: {primary-region}
**Environment**: {Production|Staging|Development}
**MCP Tools Used**: {azure_price_search, azure_cost_estimate, etc.}
```

---

## Cost At-a-Glance (Required)

Include immediately after header:

```markdown
## 💰 Cost At-a-Glance

> **Monthly Total: ~$X,XXX** | Annual: ~$XX,XXX
>
> Budget: ████████░░ 80% utilized ($X,XXX of $X,XXX)
>
> | Status | Indicator |
> |--------|-----------|
> | Budget Status | ✅ Under Budget |
> | Savings Available | 💰 $X,XXX/year with reservations |
```

---

## Visual Standards

### Status Indicators

| Status | Indicator | Usage |
|--------|-----------|-------|
| Under budget | ✅ | < 80% utilized |
| Near budget | ⚠️ | 80-100% utilized |
| Over budget | ❌ | > 100% utilized |
| Recommendation | 💡 | Optimization suggestions |
| Savings | 💰 | Money saved |

### Category Colors

| Category | Emoji |
|----------|-------|
| Compute | 💻 |
| Data | 💾 |
| Networking | 🌐 |
| Security | 🔐 |
| Monitoring | 📊 |

---

## Required Sections

### 1. Executive Summary

- Total monthly/annual cost
- Budget utilization
- Key cost drivers (top 3)
- Available savings

### 2. Cost Breakdown by Category

```markdown
## 💻 Compute Services

| Resource | SKU | Qty | Monthly |
|----------|-----|-----|---------|
| App Service | P1v3 | 2 | $XXX |
| Functions | EP1 | 1 | $XXX |

**Subtotal**: $XXX/month
```

### 3. Regional Comparison

| Region | Monthly Cost | vs Primary |
|--------|--------------|------------|
| swedencentral | $X,XXX | Baseline |
| germanywestcentral | $X,XXX | +X% |

### 4. Optimization Recommendations

```markdown
## 💡 Cost Optimization

| Opportunity | Savings | Action |
|-------------|---------|--------|
| Reserved Instances (3yr) | 💰 $X,XXX/yr | Commit to RI |
| Dev/Test pricing | 💰 $XXX/mo | Use B-series |
| Auto-shutdown | 💰 $XXX/mo | Schedule VMs |
```

### 5. Assumptions

- Pricing type (PAYG, EA, CSP)
- Usage patterns (730 hrs/mo = 24x7)
- Data transfer estimates
- Query date

---

## Pricing Sources (Priority Order)

1. **Azure Pricing MCP** - `azure_price_search`, `azure_cost_estimate`
2. **Azure Pricing Calculator** - Manual validation
3. **Azure Retail API** - Programmatic access

---

## Patterns to Avoid

| Anti-Pattern | Solution |
|--------------|----------|
| No visual indicators | Use ✅⚠️❌💰💡 |
| Missing assumptions | Document pricing basis |
| No optimization section | Always include savings opportunities |
| Stale prices | Note query date, re-validate monthly |
