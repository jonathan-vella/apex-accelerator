# Agentic InfraOps Accelerator

<div align="center">
  <img
   src="https://capsule-render.vercel.app/api?type=waving&height=180&color=0:0A66C2,50:0078D4,110:00B7C3&text=Agentic%20InfraOps&fontSize=44&fontColor=FFFFFF&fontAlignY=34&desc=Azure%20infrastructure%20engineered%20by%20agents&descAlignY=56"
   alt="Agentic InfraOps banner" />
</div>

> **Modernize your Azure Infrastructure with AI.** A production-ready template for building Well-Architected
> environments using custom Copilot agents, Dev Containers, and the Model Context Protocol (MCP).

[![Azure](https://img.shields.io/badge/Azure-0078D4?logo=microsoft-azure&logoColor=white)](https://azure.microsoft.com)
[![Bicep](https://img.shields.io/badge/Bicep-0078D4?logo=azure-pipelines&logoColor=white)](https://github.com/Azure/bicep)
[![Copilot](https://img.shields.io/badge/GitHub_Copilot-000000?logo=github-copilot&logoColor=white)](https://github.com/features/copilot)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

## 🚀 Overview

This accelerator provides the scaffolding and governance to move from requirements to deployed infrastructure
using an orchestrated workflow. It leverages domain-specific AI agents to ensure every deployment is
Well-Architected, governed, and documented.

---

## 🛠️ Multi-Agent Workflow

Agentic InfraOps coordinates specialized AI agents through a complete infrastructure development cycle.
Invoke the **InfraOps Conductor** (`Ctrl+Shift+I`) to begin.

```mermaid
sequenceDiagram
    autonumber
    participant U as 👤 User
    participant C as 🎼 Conductor
    participant R as 📋 Requirements
    participant A as 🏛️ Architect
    participant P as 📐 Bicep Plan
    participant B as ⚒️ Bicep Code
    participant D as 🚀 Deploy
    participant W as 📚 As-Built

    Note over C: ORCHESTRATION LAYER<br/>AI prepares. Humans decide.

    %% --- Step 1: Requirements ---
    U->>C: Describe infrastructure intent
    C->>R: Translate intent into structured requirements
    R-->>C: 01-requirements.md
    C->>U: Present requirements

    rect rgba(255, 200, 0, 0.15)
    Note over U,C: 🛑 HUMAN APPROVAL GATE
    U-->>C: Approve requirements
    end

    %% --- Step 2: Architecture Assessment ---
    C->>A: Assess architecture (WAF + Cost)
    Note right of A: cost-estimate-subagent<br/>handles pricing queries
    A-->>C: 02-assessment.md + 03-cost-estimate.md
    C->>U: Present architecture

    rect rgba(255, 200, 0, 0.15)
    Note over U,C: 🛑 HUMAN APPROVAL GATE
    U-->>C: Approve architecture
    end

    %% --- Step 4: Planning & Governance ---
    C->>P: Create implementation plan + governance
    Note right of P: governance-discovery-subagent<br/>queries Azure Policy via REST API
    P-->>C: 04-plan.md + governance constraints
    C->>U: Present plan

    rect rgba(255, 200, 0, 0.15)
    Note over U,C: 🛑 HUMAN APPROVAL GATE
    U-->>C: Approve plan
    end

    %% --- Step 5: IaC Generation & Validation ---
    C->>B: Generate Bicep templates (AVM-first)
    B-->>C: infra/bicep/{project}

    rect rgba(0, 150, 255, 0.08)
    Note over C,B: 🔍 Subagent Validation Loop
    Note right of B: bicep-lint-subagent → PASS/FAIL<br/>bicep-review-subagent → APPROVED/REVISION
    alt ✅ Validation passes
        C->>U: Present templates for deployment
        rect rgba(255, 200, 0, 0.15)
        Note over U,C: 🛑 HUMAN APPROVAL GATE
        U-->>C: Approve for deployment
        end
    else ⚠️ Validation fails
        C->>B: Revise with feedback
    end
    end

    %% --- Step 6: Deployment ---
    C->>D: Execute deployment
    Note right of D: bicep-whatif-subagent<br/>previews changes first
    D-->>C: 06-deployment-summary.md
    C->>U: Present deployment summary

    rect rgba(255, 200, 0, 0.15)
    Note over U,D: 🛑 HUMAN VERIFICATION
    U-->>C: Verify deployment
    end

    %% --- Step 7: As-Built Documentation ---
    C->>W: Generate workload documentation
    Note right of W: Reads all prior artifacts (01-06)<br/>+ queries deployed resource state
    W-->>C: 07-*.md documentation suite
    C->>U: Present as-built docs

    Note over U,W: ✅ AI Orchestrated. Human Governed. Azure Ready.
```

---

## 🏗️ Quick Start

### 1. Create Your Repository

This repository is a **GitHub Template**. To use it for your project:

1.  Click **"Use this template"** > **"Create a new repository"** at the top of the GitHub page.
2.  Clone your new repository to your local machine.
3.  Open the folder in **VS Code**.

### 2. Launch the Environment

1.  When prompted by VS Code (bottom-right), click **"Reopen in Container"**.
2.  Wait for the environment to build (3-5 minutes). This pre-installs the Azure CLI, Bicep, Python, and the Pricing MCP.
3.  In the VS Code Terminal, run `az login` to authenticate with Azure.

### 3. Deploy Your First Project

1.  Select the **InfraOps Conductor** agent from the Copilot Chat (`Ctrl+Shift+I`).
2.  Describe your infrastructure intent to start the 7-step orchestrated workflow.
3.  Follow the agent's guidance through requirements, architecture, and deployment.

---

## 🧪 Validation & Quality

Keep your repository healthy using built-in validation tools:

```bash
# Run all code and documentation lints
npm run validate

# Automatically fix markdown formatting issues
npm run lint:md:fix
```

- **Upstream Sync**: Weekly updates from the [parent project](https://github.com/jonathan-vella/azure-agentic-infraops)
  are delivered as Pull Requests. Your project code in `infra/` and `agent-output/` is protected.
- **Validation**: Integrated checks automatically lint your Bicep and Markdown files.

---

## 📂 Project Structure

- `.github/agents/` — Domain-specific Copilot agent definitions.
- `agent-output/` — 🏠 **Your work**: Generated artifacts (requirements, diagrams, docs).
- `infra/bicep/` — 🏠 **Your code**: Project-specific infrastructure templates.
- `mcp/` — Model Context Protocol servers (e.g., Azure Pricing).

---

## 📖 Resources

- [Main Azure Agentic InfraOps Repo](https://github.com/jonathan-vella/azure-agentic-infraops)
- [Workflow Guide](https://github.com/jonathan-vella/azure-agentic-infraops/blob/main/docs/reference/workflow.md)
- [Prompt Guide](https://github.com/jonathan-vella/azure-agentic-infraops/tree/main/docs/prompt-guide)

## 📄 License

[MIT](LICENSE)
