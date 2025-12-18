# Azure Workload Requirements Template

> **Usage**: Copy this template into Copilot Chat when starting a new project with `@plan`.
> Fill in the sections below, then submit to begin the 7-step agentic workflow.

---

## 📋 Project Overview

**Project Name**: <!-- e.g., contoso-patient-portal -->
**Project Type**: <!-- Web App | API | Data Platform | IoT | AI/ML | Hybrid -->
**Target Environment**: <!-- dev | staging | prod | all -->
**Timeline**: <!-- Target go-live date or sprint deadline -->

### Business Context

<!-- Describe the business problem this workload solves. What's the value proposition? -->

### Stakeholders

| Role           | Name/Team | Responsibility         |
| -------------- | --------- | ---------------------- |
| Business Owner |           | Approves requirements  |
| Technical Lead |           | Architecture decisions |
| Operations     |           | Day-2 support          |
| Security       |           | Compliance sign-off    |

---

## 🎯 Functional Requirements

### Core Capabilities

<!-- List the main features/capabilities this workload must provide -->

1.
2.
3.

### User Types & Load

| User Type | Expected Count | Peak Concurrent | Geographic Region |
| --------- | -------------- | --------------- | ----------------- |
|           |                |                 |                   |

### Integration Requirements

<!-- Systems this workload must integrate with -->

| System | Integration Type   | Direction        | Protocol          |
| ------ | ------------------ | ---------------- | ----------------- |
|        | API / Event / File | Inbound/Outbound | REST/GraphQL/AMQP |

### Data Requirements

| Data Type | Volume | Retention  | Sensitivity                             |
| --------- | ------ | ---------- | --------------------------------------- |
|           | GB/TB  | Days/Years | Public/Internal/Confidential/Restricted |

---

## ⚡ Non-Functional Requirements (NFRs)

### Availability & Reliability

| Requirement                        | Target                  | Notes                      |
| ---------------------------------- | ----------------------- | -------------------------- |
| **SLA**                            | 99.9% / 99.95% / 99.99% |                            |
| **RTO** (Recovery Time Objective)  | minutes / hours         | Max acceptable downtime    |
| **RPO** (Recovery Point Objective) | minutes / hours         | Max acceptable data loss   |
| **Maintenance Window**             |                         | Preferred time for updates |

### Performance

| Metric                  | Target                   | Notes                  |
| ----------------------- | ------------------------ | ---------------------- |
| **Response Time (P95)** | < 200ms / < 500ms / < 2s |                        |
| **Throughput**          | requests/sec             |                        |
| **Concurrent Users**    |                          | Peak load              |
| **Data Processing**     | records/hour             | Batch processing needs |

### Scalability

| Dimension    | Current | 12-Month Projection | Notes |
| ------------ | ------- | ------------------- | ----- |
| Users        |         |                     |       |
| Data Volume  |         |                     |       |
| Transactions |         |                     |       |

---

## 🔒 Compliance & Security

### Regulatory Requirements

<!-- Check all that apply -->

- [ ] **HIPAA** - Healthcare data protection
- [ ] **PCI-DSS** - Payment card data
- [ ] **GDPR** - EU personal data
- [ ] **SOC 2** - Service organization controls
- [ ] **ISO 27001** - Information security
- [ ] **FedRAMP** - US federal compliance
- [ ] **NIST** - Security framework
- [ ] **Industry-specific**: <!-- specify -->
- [ ] **None** - No specific compliance requirements

### Data Residency

| Requirement               | Details                                    |
| ------------------------- | ------------------------------------------ |
| **Primary Region**        | swedencentral / germanywestcentral / other |
| **Data Sovereignty**      | Must data stay in specific country/region? |
| **Cross-border Transfer** | Any restrictions on data movement?         |

### Security Requirements

| Control                   | Requirement                          | Notes |
| ------------------------- | ------------------------------------ | ----- |
| **Authentication**        | Azure AD / B2C / External IdP        |       |
| **Authorization**         | RBAC / ABAC / Custom                 |       |
| **Encryption at Rest**    | Platform / Customer-managed keys     |       |
| **Encryption in Transit** | TLS 1.2+ / mTLS                      |       |
| **Network Isolation**     | Private endpoints / VNet integration |       |
| **WAF**                   | Required / Optional                  |       |
| **DDoS Protection**       | Standard / Premium                   |       |

---

## 💰 Cost Constraints

### Budget

| Period            | Budget | Currency | Notes                         |
| ----------------- | ------ | -------- | ----------------------------- |
| **Monthly**       |        | USD/EUR  | Steady-state operational cost |
| **Annual**        |        | USD/EUR  | Total annual budget           |
| **Initial Setup** |        | USD/EUR  | One-time deployment costs     |

### Cost Optimization Priorities

<!-- Rank 1-5, where 1 is most important -->

| Priority                    | Rank | Notes |
| --------------------------- | ---- | ----- |
| Minimize monthly spend      |      |       |
| Optimize for performance    |      |       |
| Reduce operational overhead |      |       |
| Reserved capacity discounts |      |       |
| Spot/preemptible instances  |      |       |

### FinOps Considerations

- [ ] Cost alerts required at % of budget
- [ ] Showback/chargeback to business units
- [ ] Auto-shutdown for non-prod environments
- [ ] Right-sizing recommendations needed

---

## 🔧 Operational Requirements

### Monitoring & Observability

| Capability     | Requirement                  | Notes                  |
| -------------- | ---------------------------- | ---------------------- |
| **Logging**    | Centralized / Per-resource   | Retention period       |
| **Metrics**    | Platform / Custom            | Key metrics to track   |
| **Alerting**   | Email / Teams / PagerDuty    | On-call integration    |
| **Dashboards** | Azure Portal / Grafana       | Stakeholder visibility |
| **APM**        | Application Insights / Other | Distributed tracing    |

### Support Model

| Aspect               | Requirement                         |
| -------------------- | ----------------------------------- |
| **Support Hours**    | 24/7 / Business hours / Best effort |
| **Response Time**    | P1: / P2: / P3:                     |
| **Escalation Path**  |                                     |
| **Runbook Required** | Yes / No                            |

### Backup & DR

| Component | Backup Frequency | Retention  | DR Strategy                       |
| --------- | ---------------- | ---------- | --------------------------------- |
|           | Daily/Hourly     | Days/Weeks | Active-Active/Passive/Pilot Light |

---

## 🌍 Regional Preferences

**Primary Region**: `swedencentral` (default - sustainable, GDPR-compliant)
**Secondary Region**: `germanywestcentral` (for quota issues or DR)

### Override Reasons (if not using defaults)

- [ ] **Latency** - Users primarily in Americas/APAC
- [ ] **Compliance** - Specific data residency requirement
- [ ] **Service Availability** - Required service not available in default region
- [ ] **Cost** - Significant savings in alternate region

---

## 📝 Additional Context

<!-- Any other information that would help with architecture decisions -->

### Existing Infrastructure

<!-- Describe any existing Azure resources this must integrate with -->

### Constraints & Assumptions

<!-- Known limitations, dependencies, or assumptions -->

### Out of Scope

<!-- Explicitly list what is NOT included in this project -->

---

## ✅ Submission Checklist

Before submitting to `@plan`:

- [ ] Project name follows naming convention (lowercase, alphanumeric, hyphens)
- [ ] At least one functional requirement defined
- [ ] SLA/RTO/RPO specified (or explicitly marked N/A)
- [ ] Compliance requirements identified
- [ ] Budget range provided
- [ ] Primary region confirmed

---

**Ready to start?** Copy this completed template into Copilot Chat and invoke:

```
@plan [paste completed template]
```

The plan agent will:

1. Validate requirements completeness
2. Create `agent-output/{project-name}/` folder
3. Generate `01-requirements.md` with structured requirements
4. Prompt for approval before proceeding to Step 2
