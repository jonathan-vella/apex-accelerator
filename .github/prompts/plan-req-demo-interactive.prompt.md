---
description: "Quick demo: Static Web App requirements (interactive)"
agent: "Project Planner"
model: "Claude Opus 4.5"
tools:
  - edit/createFile
---

# Static Web App Demo - Requirements (Interactive)

Gather minimal requirements for a Static Web App demo with Application Insights.
Prompt the user for key inputs, keep it fast for live demos.

## Mission

Quickly capture the essentials for deploying a Static Web App with monitoring.
Skip the full NFR interview - focus on what's needed for this simple workload.

## Questions to Ask

### 1. Project Basics

Ask the user:

```text
What's your project name? (lowercase, hyphens only, e.g., "my-demo-app")
```

### 2. Framework (Optional)

```text
What frontend framework? [React/Vue/Angular/Vanilla JS/Other]
Default: React
```

### 3. Repository (Optional)

```text
GitHub repo URL? (Leave blank for manual deployment)
```

## Pre-filled Defaults

Apply these automatically (inform the user):

| Setting         | Value                           | Rationale                    |
| --------------- | ------------------------------- | ---------------------------- |
| **Region**      | `westeurope`                    | Static Web App supported     |
| **Environment** | `prod`                          | Demo simplicity              |
| **SLA**         | 99.9%                           | Standard tier includes this  |
| **SKU**         | Standard                        | Enables staging + custom DNS |
| **Monitoring**  | Application Insights            | Telemetry included           |
| **Security**    | HTTPS only, managed certificate | Default behavior             |

## Azure Resources

| Resource             | SKU/Tier | Purpose                    |
| -------------------- | -------- | -------------------------- |
| Static Web App       | Standard | Hosting with staging slots |
| Application Insights | -        | Telemetry and monitoring   |

## Required Tags

```yaml
Environment: prod
Project: { user-provided-name }
ManagedBy: Bicep
Owner: demo-team
```

## Budget (Ask User)

Prompt the user:

```text
What's your approximate monthly budget? (e.g., ~$15/month)
```

> The Azure Pricing MCP server will generate detailed cost estimates during
> architecture assessment (Step 2).

## Output Summary

After gathering inputs, summarize:

```markdown
## Requirements Summary

| Field     | Value                         |
| --------- | ----------------------------- |
| Project   | {projectName}                 |
| Framework | {framework}                   |
| Region    | westeurope                    |
| SLA       | 99.9%                         |
| Resources | Static Web App + App Insights |
| Budget    | {user-provided-budget}        |

Ready to proceed to architecture assessment?
```

## Next Step

Inform the user:

> "Requirements captured. Invoke `@azure-principal-architect` to generate
> the architecture assessment, or proceed directly to `@bicep-plan` for
> this simple workload."
