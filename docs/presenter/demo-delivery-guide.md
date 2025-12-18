# Demo Delivery Guide

This guide helps presenters deliver compelling GitHub Copilot demonstrations for IT Professionals. Whether you're
presenting to customers, colleagues, or leadership, this guide will help you maximize impact.

## 🎯 Demo Philosophy

### The "Efficiency Multiplier" Message

**Core Message**: GitHub Copilot is an **efficiency multiplier** for IT Professionals—not a replacement for expertise,
but an amplifier of it.

**Why This Matters**:

- IT Pros retain ownership of decisions and quality
- Copilot handles repetitive work, freeing time for architecture and strategy
- Learning happens through context-aware suggestions, not separate training

### What to Avoid

| ❌ Don't Say                             | ✅ Say Instead                                   |
| ---------------------------------------- | ------------------------------------------------ |
| "Copilot writes code for you"            | "Copilot accelerates your workflow"              |
| "You don't need to know Bicep/Terraform" | "Copilot helps you learn best practices faster"  |
| "It's magic"                             | "It's pattern recognition from your context"     |
| "It always gets it right"                | "It gives you a strong starting point to refine" |

## 📋 Demo Structure (30 Minutes)

### Phase 1: Scene Setting (5 minutes)

**Goal**: Establish the problem and connect with the audience's experience.

**Key Points**:

1. **The Challenge**: "How long does it typically take to set up a new Azure environment from scratch?"
2. **The Reality**: Manual work involves documentation lookup, copy-paste errors, security misconfigurations
3. **The Opportunity**: What if we could reduce 4-6 hours to 30-45 minutes?

**Engagement Technique**: Ask the audience about their typical workflow before showing Copilot.

### Phase 2: Live Demo (15 minutes)

**Goal**: Show Copilot in action with real Infrastructure-as-Code.

**Recommended Flow**:

1. **Start Fresh** - Open VS Code in a clean workspace
2. **Show Context** - Open the scenario folder (e.g., `scenarios/S01-bicep-baseline/`)
3. **Use Agents** - Demonstrate the workflow: `@plan` → `azure-principal-architect` → `bicep-plan` → `bicep-implement`
4. **Accept & Refine** - Show the iterative process of accepting and improving suggestions
5. **Deploy (Optional)** - If time permits, deploy to Azure to show working infrastructure

**Pro Tips**:

- **Pause after each suggestion** - Let the audience absorb what Copilot generated
- **Explain your prompts** - Verbalize why you're asking for specific things
- **Show mistakes** - When Copilot needs correction, it demonstrates the "human in the loop" value
- **Use Tab and Enter deliberately** - Show you're reviewing before accepting

### Phase 3: Validation (8 minutes)

**Goal**: Prove the generated code works and meets quality standards.

**Validation Steps**:

1. **Syntax Check**: `bicep build main.bicep` or `terraform validate`
2. **Security Scan**: Show no critical vulnerabilities (tfsec, Checkov)
3. **Deployment**: `az deployment group create --what-if` to preview changes
4. **Resource Verification**: Show resources in Azure Portal

**Why This Matters**: Validation builds trust—showing that Copilot output is near-production-ready.

### Phase 4: Wrap-Up (2 minutes)

**Goal**: Summarize value and provide next steps.

**Key Points**:

1. **Time Savings**: Recap what was accomplished and how long it would take manually
2. **Quality**: Highlight built-in best practices (security, naming, modularity)
3. **Learning**: Mention how the process taught patterns, not just generated code
4. **Next Steps**: Point to resources (this repository, documentation, trial signup)

## 🎯 Demo Scenarios by Audience

### Quick Demo (15 minutes)

**Best For**: Busy executives, large group introductions

**Use**: S01 (Bicep Baseline) or S02 (Terraform Baseline)

**Focus**: Speed and quality—show a complete infrastructure in 10-12 minutes.

### Standard Demo (30 minutes)

**Best For**: Technical teams, IT Pro workshops

**Use**: Full 30-MIN-DEMO-SCRIPT.md with S01 or S03

**Focus**: Balance of speed, quality, and learning moments.

### Deep Dive (60+ minutes)

**Best For**: Hands-on workshops, training sessions

**Use**: S03 (Agentic Workflow) or S09 (Coding Agent)

**Focus**: Comprehensive workflow including ADRs, architecture review, and deployment.

## 💬 Handling Live Demo Challenges

### When Copilot Gives Unexpected Output

**Response**: "This is a great example of why we review suggestions. Let me refine my prompt..."

**Action**: Show how to iterate—add more context to your prompt and regenerate.

### When Copilot Is Slow

**Response**: "Copilot is analyzing the full context of our project. This thorough analysis is what makes
suggestions so relevant."

**Action**: Continue talking about what you expect, fill time with explanation.

### When Deployment Fails

**Response**: "This is exactly why we validate. Let's see what the error tells us..."

**Action**: Use Copilot to troubleshoot! This demonstrates real-world value.

### When Asked "Can It Do X?"

**Response**: "Let's try it! One of Copilot's strengths is handling novel requests."

**Action**: Attempt the request live—success or failure, it's a learning moment.

## 📊 Presenting ROI Data

### Time Savings Framework

| Task Category          | Manual Estimate | With Copilot  | Savings    |
| ---------------------- | --------------- | ------------- | ---------- |
| Initial Setup          | 2-4 hours       | 15-30 min     | 85-90%     |
| Security Configuration | 1-2 hours       | 10-15 min     | 85-90%     |
| Documentation          | 1-2 hours       | 10-15 min     | 85-90%     |
| Testing/Validation     | 1-2 hours       | 15-20 min     | 75-85%     |
| **Total**              | **5-10 hours**  | **50-80 min** | **85-90%** |

### Making ROI Personal

Ask the audience:

- "How many infrastructure projects does your team deliver per month?"
- "What's the hourly cost of your infrastructure engineers?"
- "How much time is spent on repetitive configuration vs. architecture decisions?"

Then use the [ROI Calculator](roi-calculator.md) to build a custom business case.

## 🔧 Technical Setup Checklist

### Before the Demo

```bash
# Verify Dev Container works
cd /workspaces/azure-agentic-infraops
# F1 → "Dev Containers: Rebuild Container"

# Verify tools
terraform --version   # Should show 1.5+
az --version          # Should show 2.50+
bicep --version       # Should show 0.20+
pwsh --version        # Should show 7+

# Verify Copilot
# Open Copilot Chat (Ctrl+Alt+I)
# Try a simple prompt to confirm it responds
```

### Demo Environment

- **Font Size**: 16-18pt in VS Code for visibility
- **Theme**: Light theme often works better for projectors
- **Zoom**: 125-150% browser zoom for Azure Portal
- **Notifications**: Disable all system notifications

## 📚 Scenario Quick Reference

| Scenario                  | Duration  | Best For           | Key Demo Points          |
| ------------------------- | --------- | ------------------ | ------------------------ |
| S01 - Bicep Baseline      | 15-20 min | Quick demos        | Fast IaC generation      |
| S02 - Terraform Baseline  | 15-20 min | Multi-cloud teams  | Cross-platform patterns  |
| S03 - Agentic Workflow | 30-45 min | Deep dives         | Full agent orchestration |
| S04 - Documentation       | 10-15 min | Doc-heavy teams    | Automated README/ADR     |
| S05 - Service Validation  | 10-15 min | Testing focus      | Validation scripts       |
| S06 - Troubleshooting     | 15-20 min | Support teams      | Diagnostic assistance    |
| S07 - SBOM Generator      | 15-20 min | Security focus     | Supply chain visibility  |
| S08 - Diagrams as Code    | 10-15 min | Architecture teams | Visual documentation     |
| S09 - Coding Agent        | 15-20 min | Async workflows    | Issue-to-PR automation   |

## 🎤 Presenter Tips

### Building Confidence

1. **Practice aloud** - Your prompts should sound natural when you verbalize them
2. **Know the fallbacks** - Have screenshots ready for connectivity issues
3. **Embrace imperfection** - Small hiccups make demos more authentic
4. **Tell stories** - Connect scenarios to real projects you've worked on

### Engaging the Audience

1. **Ask questions early** - "Who here has written Bicep before?"
2. **Invite prompts** - "What would you like to see Copilot generate?"
3. **Acknowledge expertise** - "You probably know a faster way to do this manually..."
4. **Create anticipation** - "Watch what happens when I hit Tab..."

### Closing Strong

1. **Recap the journey** - "In 30 minutes, we went from zero to deployed infrastructure"
2. **Quantify value** - "This would have taken 4-6 hours manually"
3. **Call to action** - "Try the Dev Container yourself—link in the slides"
4. **Offer follow-up** - "Happy to do a deeper dive with your team"

---

📖 **Related Resources**:

- [Objection Handling](objection-handling.md) - Prepare for tough questions
- [ROI Calculator](roi-calculator.md) - Build a business case
- [30-MIN Demo Script](../../scenarios/30-MIN-DEMO-SCRIPT.md) - Step-by-step walkthrough
