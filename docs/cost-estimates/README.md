# Cost Estimates

This folder contains Azure cost estimate documents for infrastructure projects.

## What is a Cost Estimate?

A cost estimate document provides financial planning information for Azure infrastructure, including:

- Monthly and annual cost projections
- Architecture context linking costs to design decisions
- Business justification for technical choices
- Optimization recommendations for cost savings

## Creating Cost Estimates

Use the `@plan` agent in Copilot with cost estimation prompts:

1. Press `Ctrl+Shift+A` in VS Code
2. Select `@plan`
3. Request a cost estimate for your architecture

## Cost Estimate Template

```markdown
# Azure Cost Estimate: {Project Name}

**Generated**: {YYYY-MM-DD}
**Region**: {primary-region}
**Environment**: {Production|Staging|Development}

## 💰 Cost At-a-Glance

| Metric           | Value        |
| ---------------- | ------------ |
| Monthly Estimate | $X,XXX       |
| Annual Estimate  | $XX,XXX      |
| Reserved Savings | XX%          |

## Cost Breakdown by Category

| Category   | Monthly Cost | % of Total |
| ---------- | ------------ | ---------- |
| Compute    | $XXX         | XX%        |
| Storage    | $XXX         | XX%        |
| Networking | $XXX         | XX%        |

## Optimization Recommendations

- 💡 [Recommendations for cost savings]
```

## Status Indicators

| Status         | Indicator | Usage                    |
| -------------- | --------- | ------------------------ |
| Under budget   | ✅        | Budget utilization < 80% |
| Near budget    | ⚠️        | Budget utilization 80-100% |
| Over budget    | ❌        | Budget utilization > 100% |
| Recommendation | 💡        | Optimization suggestions |
| Savings        | 💰        | Money saved with commitments |
