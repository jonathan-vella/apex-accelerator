---
description: "Quick demo: Static Web App requirements (pre-filled values)"
agent: "Requirements"
model: "Claude Opus 4.5"
tools:
  - edit/createFile
---

# Static Web App Demo - Requirements (Pre-filled)

Fast-track requirements for a Static Web App demo with Application Insights.
All values are pre-filled for quick live demonstration.

## Project Details

| Field           | Value                                        |
| --------------- | -------------------------------------------- |
| **Project**     | `infraops-demo`                              |
| **Type**        | Static Web Application                       |
| **Region**      | `westeurope` (Static Web App supported)      |
| **Environment** | Production                                   |
| **Framework**   | React (Vite)                                 |
| **Repo**        | `https://github.com/contoso/static-web-demo` |

## Functional Requirements

- Host a single-page application (SPA) with client-side routing
- Serve static assets (HTML, CSS, JS, images) globally via CDN
- Support staging environments via preview branches

## Non-Functional Requirements

| Category          | Requirement                         |
| ----------------- | ----------------------------------- |
| **Availability**  | 99.9% SLA                           |
| **Performance**   | < 200ms TTFB (global edge)          |
| **Scalability**   | Auto-scales (serverless)            |
| **Security**      | HTTPS only, managed SSL certificate |
| **Observability** | Application Insights for telemetry  |

## Azure Resources

| Resource             | SKU/Tier | Purpose                    |
| -------------------- | -------- | -------------------------- |
| Static Web App       | Standard | Hosting with staging slots |
| Application Insights | -        | Telemetry and monitoring   |

## Tags

```yaml
Environment: prod
Project: contoso-static-demo
ManagedBy: Bicep
Owner: demo-team
```

## Budget

| Field              | Value      |
| ------------------ | ---------- |
| **Monthly Budget** | ~$15/month |

> The Azure Pricing MCP server will generate detailed cost estimates during
> architecture assessment (Step 2).

## Output

Generate a summary confirming these requirements are ready for architecture
assessment. No file output needed for this demo.
