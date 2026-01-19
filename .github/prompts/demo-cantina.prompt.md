---
description: "Demo scenario: Cantina - team ops dashboard with App Service containers, ACR, SQL Database (Entra ID auth), and managed identities"
agent: "Project Planner"
model: "Claude Opus 4.5"
tools:
  - edit/createFile
  - edit/editFiles
---

# Demo: Cantina Requirements

Pre-populated requirements for a 30-minute live demo of the full 7-step workflow.

## Project Overview

**Project Name**: cantina
**Project Type**: Web App
**Target Environment**: prod
**Timeline**: 2 weeks

### Business Context

Internal team operations dashboard (codename "Cantina" - where the team gathers) for displaying project metrics, team availability,
and sprint progress. Used by a 50-person engineering department to track
daily standups and project health.

### Stakeholders

| Role           | Name/Team           | Responsibility         |
| -------------- | ------------------- | ---------------------- |
| Business Owner | Admiral (Eng VP)    | Approves requirements  |
| Technical Lead | Rebel Alliance Tech | Architecture decisions |
| Operations     | Droid Operations    | Day-2 support          |
| Security       | Imperial Guard      | Compliance sign-off    |

---

## Functional Requirements

### Core Capabilities

1. Display team member availability (in-office, remote, PTO)
2. Show sprint burndown charts from Azure DevOps
3. Display key project metrics (build status, test coverage)
4. Support dark/light theme toggle

### User Types & Load

| User Type        | Expected Count | Peak Concurrent | Geographic Region |
| ---------------- | -------------- | --------------- | ----------------- |
| Rebel Engineers  | 50             | 30              | Hoth Sector (EU)  |
| Squadron Leaders | 10             | 5               | Hoth Sector (EU)  |

### Integration Requirements

| System       | Integration Type | Direction | Protocol |
| ------------ | ---------------- | --------- | -------- |
| Azure DevOps | API              | Inbound   | REST     |
| MS Graph     | API              | Inbound   | REST     |

### Data Requirements

| Data Type      | Volume | Retention | Sensitivity | Storage       |
| -------------- | ------ | --------- | ----------- | ------------- |
| User profiles  | 1 MB   | Ongoing   | Internal    | Azure SQL     |
| Sprint metrics | 10 MB  | 90 days   | Internal    | Azure SQL     |
| Availability   | 1 MB   | 7 days    | Internal    | Azure SQL     |
| Telemetry      | 1 GB   | 90 days   | Internal    | App Insights  |
| Container logs | 500 MB | 30 days   | Internal    | Log Analytics |

---

## Non-Functional Requirements (NFRs)

### Availability & Reliability

| Requirement     | Target   | Notes                   |
| --------------- | -------- | ----------------------- |
| **SLA**         | 99.9%    | Business hours critical |
| **RTO**         | 4 hours  | Acceptable for internal |
| **RPO**         | 24 hours | Daily backup sufficient |
| **Maintenance** | Weekends | Preferred update window |

### Performance

| Metric               | Target  | Notes                       |
| -------------------- | ------- | --------------------------- |
| **Response Time**    | < 500ms | Dashboard load              |
| **Concurrent Users** | 30      | Peak during standup         |
| **Cold Start**       | < 5s    | App Service always-on (B1+) |

### Scalability

| Dimension   | Current | 12-Month | Notes        |
| ----------- | ------- | -------- | ------------ |
| Users       | 60      | 100      | Team growth  |
| Data Volume | 12 MB   | 50 MB    | More metrics |

---

## Compliance & Security

### Regulatory Requirements

- [x] **None** - Internal tool, no external data

### Data Residency

| Requirement          | Details                         |
| -------------------- | ------------------------------- |
| **Primary Region**   | swedencentral (Hoth datacenter) |
| **Data Sovereignty** | EU only (Alliance territory)    |

### Security Requirements

| Control                | Requirement                                   |
| ---------------------- | --------------------------------------------- |
| **Authentication**     | Azure AD (SSO) for web app                    |
| **SQL Authentication** | Entra ID only (no SQL auth)                   |
| **Authorization**      | Azure AD groups + RBAC                        |
| **Service Identity**   | Managed Identity (system-assign)              |
| **Encryption**         | TLS 1.2+ in transit, platform-managed at rest |
| **Container Registry** | Private, MI-authenticated                     |
| **Network**            | Public (internal users)                       |

---

## Cost Constraints

### Budget

| Period      | Budget | Currency | Notes                       |
| ----------- | ------ | -------- | --------------------------- |
| **Monthly** | $50    | USD      | Target: $25-35/month actual |
| **Annual**  | $600   | USD      | Allows headroom for growth  |

### Cost Optimization Priorities

| Priority                | Rank |
| ----------------------- | ---- |
| Minimize monthly spend  | 1    |
| Reduce operational cost | 2    |

---

## Operational Requirements

### Monitoring & Observability

| Capability         | Requirement                          |
| ------------------ | ------------------------------------ |
| **Logging**        | Application Insights + Log Analytics |
| **Metrics**        | Platform metrics (App Service, SQL)  |
| **APM**            | Application Insights SDK             |
| **Container Logs** | stdout/stderr to Log Analytics       |
| **Alerting**       | Email on errors, SQL DTU >80%        |
| **Dashboards**     | Application Insights dashboards      |

### Support Model

| Aspect            | Requirement    |
| ----------------- | -------------- |
| **Support Hours** | Business hours |
| **Response Time** | P1: 4 hours    |

---

## Regional Preferences

**Primary Region**: `swedencentral` (Hoth datacenter - cold but reliable)
**Secondary Region**: N/A (single region sufficient for the Rebellion)

---

## Demo Workflow Script

### Phase 1: Requirements (5 min)

```text
Invoke: @project-planner
Prompt: "Create requirements for cantina using this specification"
Output: agent-output/cantina/01-requirements.md
```

### Phase 2: Architecture (5 min)

```text
Invoke: @azure-principal-architect
Prompt: "Assess the cantina requirements"
Output: agent-output/cantina/02-architecture-assessment.md
```

### Phase 3: Design Artifacts (3 min)

```text
Invoke: @diagram-generator
Prompt: "Create architecture diagram for cantina"
Output: agent-output/cantina/03-des-diagram.py
```

### Phase 4: Implementation Plan (5 min)

```text
Invoke: @bicep-plan
Prompt: "Create implementation plan for cantina"
Output: agent-output/cantina/04-implementation-plan.md
```

### Phase 5: Bicep Implementation (7 min)

```text
Invoke: @bicep-implement
Prompt: "Implement the cantina infrastructure"
Output: infra/bicep/cantina/
```

### Phase 6: Deployment (3 min)

```text
Invoke: @deploy
Prompt: "Deploy cantina to Azure"
Output: agent-output/cantina/06-deployment-summary.md
```

### Phase 7: Documentation (2 min)

```text
Invoke: @workload-documentation-generator
Prompt: "Generate documentation for cantina"
Output: agent-output/cantina/07-*.md
```

---

## Expected Architecture

Container-based solution with managed identity and Entra ID authentication:

**Compute & Hosting:**

- **Azure App Service** (Basic B1, Linux) - Container hosting
- **Managed Identity** - System-assigned for ACR authentication

**Container & Registry:**

- **Azure Container Registry** (Basic SKU) - Private container registry
- **Container Image** - Dashboard application packaged as Docker image

**Data Layer:**

- **Azure SQL Database** (Basic, DTU-based) - Team dashboard data
- **Entra ID Authentication** - SQL Server configured for Azure AD-only auth
- **Managed Identity** - App Service uses MI to connect to SQL

**Monitoring & Security:**

- **Application Insights** (workspace-based, 5GB free tier) - APM and diagnostics
- **Log Analytics Workspace** - Centralized logging (30-day retention)
- **Azure AD** - User authentication (existing tenant)

**Why This Architecture:**

- **No Regional Constraint**: All services available in swedencentral
- **Container Deployment**: Portable, consistent across environments
- **Zero Credentials**: Managed identities eliminate connection strings
- **Entra ID SQL**: No SQL authentication, Azure AD-only (security best practice)
- **Cost Optimized**: Basic SKUs for all resources

**Architecture Flow:**

```
User → Azure AD (SSO) → App Service (container) → [MI] → SQL Database (Entra)
                              ↓
                    ACR (pull image via MI)
                              ↓
                    App Insights (telemetry)
```

**Estimated Monthly Cost:** ~$25-35/month

- App Service B1: ~$13/month
- Azure SQL Basic: ~$5/month
- ACR Basic: ~$5/month
- Application Insights: $0 (free 5GB tier)
- Log Analytics: $0 (free 5GB tier)
- Bandwidth: $0 (within free tier)

---

## Validation & Success Criteria

- [ ] All 7 agent outputs generated successfully (complete the Kessel Run)
- [ ] Bicep templates pass `bicep build` and `bicep lint` (R2-D2 approved)
- [ ] Architecture diagram renders correctly (hologram projection stable)
- [ ] Deployment completes without Azure Policy violations (no Imperial entanglements)
- [ ] Total demo execution time < 30 minutes (faster than the Millennium Falcon)
- [ ] Cost estimate aligns with $50/month budget constraint (within Alliance funding)
- [ ] All required Azure resources created in `swedencentral` (Hoth outpost secured)

---

## Demo Tips

1. **Skip Azure login** - Pre-authenticate before demo (trust in the Force)
2. **Pre-create resource group** - `rg-cantina-demo` (prepare the hyperdrive)
3. **Have Azure portal open** - Show resources after deployment (holocron view)
4. **Prepare rollback** - `git stash` if demo goes wrong (use the escape pod)
5. **May the Force be with you** - And may your deployment succeed on the first try
