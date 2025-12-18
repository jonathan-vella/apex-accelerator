# ADR-001: Seven-Step Agent Workflow Design

## Status

Accepted

## Date

2024-01-15

## Context

This repository demonstrates GitHub Copilot's capabilities for Azure infrastructure development. We needed to
design a workflow that:

1. Showcases the full spectrum of Copilot capabilities (planning, architecture, code generation)
2. Provides clear separation of concerns between different phases
3. Allows for human approval gates between major decisions
4. Teaches best practices through the agent prompts themselves
5. Handles the token limit constraints of AI responses

### Considered Alternatives

1. **Single monolithic agent** - One agent handles everything from requirements to deployment
2. **Two-step workflow** - Architecture → Implementation only
3. **Seven-step workflow** - Finer granularity with separate agents for each phase, including deploy step
4. **No custom agents** - Rely entirely on Copilot Chat without custom prompts

## Decision

We adopted a **seven-step workflow** with approval gates:

```
@plan → azure-principal-architect → [Design Artifacts] → bicep-plan → bicep-implement → Deploy → [As-Built Artifacts]
```

With optional artifact phases:

- **Step 3**: Design Artifacts - `diagram-generator`, `adr-generator` (suffix: `-des`)
- **Step 7**: As-Built Artifacts - `diagram-generator`, `adr-generator` (suffix: `-ab`)

### Workflow Steps

| Step | Agent/Phase                 | Purpose                          | Creates Code? |
| ---- | --------------------------- | -------------------------------- | ------------- |
| 1    | `@plan`                     | Requirements gathering           | No            |
| 2    | `azure-principal-architect` | WAF assessment, recommendations  | No            |
| 3    | Design Artifacts (optional) | Design diagrams + ADRs           | No            |
| 4    | `bicep-plan`                | Implementation planning with AVM | Planning docs |
| 5    | `bicep-implement`           | Bicep code generation            | Yes           |
| 6    | Deploy                      | Deploy to Azure                  | No            |
| 7    | As-Built Artifacts (opt.)   | As-built diagrams + ADRs         | No            |

### Why Seven Steps?

1. **Matches real-world workflow** - Architects don't write code, developers don't set requirements
2. **Prevents token limit issues** - Splitting planning from implementation keeps responses focused
3. **Enables approval gates** - Each step requires human confirmation before proceeding
4. **Supports iterative refinement** - Can re-run any step without starting over

## Consequences

### Positive

- Clear separation between architecture decisions and implementation details
- Human remains in control with explicit approval gates
- Easier to debug issues (which step failed?)
- Supports phased demos (can show just architecture, or full workflow)
- Token limits are manageable with scoped agent responsibilities

### Negative

- More complex than single-agent approach
- Requires user to understand workflow sequence
- Context must be passed between steps (sometimes manually)
- New users may be confused by agent selection

### Mitigations

- Created `docs/workflow/WORKFLOW.md` with detailed workflow documentation
- Added workflow diagrams to agent prompts
- Agents prompt for approval before major actions
- `copilot-instructions.md` includes workflow quick reference

## References

- [docs/workflow/WORKFLOW.md](../workflow/WORKFLOW.md) - Full workflow documentation
- [.github/agents/](../../.github/agents/) - Agent definitions
- [.github/copilot-instructions.md](../../.github/copilot-instructions.md) - Copilot guidance
