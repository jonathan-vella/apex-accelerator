# Agentic Workflow Template

This template provides the essential components for creating new projects that use the agentic workflow pattern
with GitHub Copilot.

## Included Components

### Core Configuration

| Component                         | Purpose                                       |
| --------------------------------- | --------------------------------------------- |
| `.devcontainer/`                  | Pre-configured dev container with Azure tools |
| `.github/agents/`                 | Custom Copilot agents for the workflow        |
| `.github/instructions/`           | AI coding standards and best practices        |
| `.github/copilot-instructions.md` | Main Copilot context file                     |
| `.husky/`                         | Git hooks for quality enforcement             |
| `.vscode/`                        | VS Code and MCP server configuration          |

### Quality Tooling

| Component                  | Purpose                           |
| -------------------------- | --------------------------------- |
| `package.json`             | Husky + markdownlint dependencies |
| `.markdownlint.json`       | Markdown linting rules            |
| `.markdownlint-cli2.jsonc` | CLI2 configuration                |
| `.markdownlintignore`      | Files to exclude from linting     |
| `.gitattributes`           | Line ending normalization         |
| `.gitignore`               | Standard ignore patterns          |

### GitHub Workflows

| Component                             | Purpose                      |
| ------------------------------------- | ---------------------------- |
| `.github/workflows/markdown-lint.yml` | CI markdown validation       |
| `.github/ISSUE_TEMPLATE/`             | Issue templates for requests |
| `.github/PULL_REQUEST_TEMPLATE.md`    | PR template                  |

## Quick Start

1. Copy this template to your new project location
2. Update `package.json` with your project name
3. Customize `.github/copilot-instructions.md` for your project
4. Run `npm install` to set up Husky hooks
5. Start using the agents: `Ctrl+Shift+A` in VS Code

## Customization Required

After copying, update these files:

1. **`package.json`** - Change name, description, repository URL
2. **`.github/copilot-instructions.md`** - Update project-specific context
3. **`.github/agents/*.agent.md`** - Customize agents for your domain
4. **`.devcontainer/devcontainer.json`** - Adjust tools if needed

## Agent Workflow

```
@plan → azure-principal-architect → bicep-plan → bicep-implement
```

See `.github/copilot-instructions.md` for full workflow documentation.
