---
name: Demo
version: 0.1.0
description: "Showcase forge-council — demonstrate the agent roster, council flow, and standalone specialists. USE WHEN demo, showcase, show agents, what can forge-council do."
argument-hint: "[optional: 'council' for live council demo, 'agents' for roster walkthrough]"
---

# forge-council Demo

Showcase the forge-council module. Walk through the agent roster, demonstrate the council flow, and show standalone specialist invocations.

## Step 1: Determine demo mode

Parse the user's argument:

| Argument | Mode | What to show |
|----------|------|--------------|
| (none) | Full showcase | Everything below |
| `council` | Live council | Run an actual council on a sample task |
| `agents` | Roster walkthrough | Introduce each agent with sample prompts |

## Step 2: Introduction

Present the module with impact:

```
╔══════════════════════════════════════════════════════════╗
║                    forge-council                        ║
║    Thirteen specialists. Four councils. One verdict.    ║
╚══════════════════════════════════════════════════════════╝
```

Then explain the core idea in 2-3 sentences:

> A single AI is a single perspective. forge-council provides thirteen specialist agents organized into four council types — developer, generic, product, and knowledge. All councils use 3-round debate: initial positions → challenges → convergence. Each agent brings domain expertise that a generalist would miss.

## Step 3: The Roster

Present the agents as a formatted table, reading each from the agents directory:

```bash
# Resolve agents directory relative to skill
SKILL_DIR="$(builtin cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENTS_DIR="$(builtin cd "$SKILL_DIR/../../agents" && pwd)"

for f in "$AGENTS_DIR"/*.md; do
  name=$(grep "^name:" "$f" | head -1 | awk -F': ' '{print $2}')
  desc=$(grep "^description:" "$f" | head -1 | sed 's/^description: *//' | sed 's/"//g' | cut -d'—' -f1)
  echo "$name|$model|$desc"
done
```

Format as:

```
┌─────────────────────────────────────────────────────────┐
│  DEVELOPER COUNCIL (/DeveloperCouncil)                  │
├──────────────────────┬──────────────────────────────────┤
│ SoftwareDeveloper    │ Implementation quality           │
│ DatabaseEngineer     │ Schema & query perf              │
│ DevOpsEngineer       │ CI/CD & deployment               │
│ DocumentationWriter  │ README & API docs                │
│ QaTester             │ Coverage & edge cases            │
│ SecurityArchitect    │ Threat modeling                  │
├──────────────────────┴──────────────────────────────────┤
│  DEBATE COUNCIL (/DebateCouncil)                        │
├──────────────────────┬──────────────────────────────────┤
│ SystemArchitect      │ System design                    │
│ UxDesigner           │ UX & user needs                  │
│ SoftwareDeveloper    │ Implementation reality           │
│ WebResearcher        │ Data & precedent                 │
├──────────────────────┴──────────────────────────────────┤
│  PRODUCT COUNCIL (/ProductCouncil)                      │
├──────────────────────┬──────────────────────────────────┤
│ ProductManager       │ Requirements & roadmap           │
│ UxDesigner           │ UX & user needs                  │
│ SoftwareDeveloper    │ Tech feasibility                 │
│ DataAnalyst          │ Metrics & impact                 │
├──────────────────────┴──────────────────────────────────┤
│  KNOWLEDGE COUNCIL (/KnowledgeCouncil)                  │
├──────────────────────┬──────────────────────────────────┤
│ DocumentationWriter  │ Note architecture                │
│ SystemArchitect      │ Structural patterns              │
│ WebResearcher        │ Evidence & precedent             │
├──────────────────────┴──────────────────────────────────┤
│  STANDALONE SPECIALISTS                                 │
├──────────────────────┬──────────────────────────────────┤
│ TheOpponent          │ Devil's advocate (strong tier)   │
│ WebResearcher        │ Deep web research                │
│ ForensicAgent        │ PII & secret detection           │
└──────────────────────┴──────────────────────────────────┘
```

## Step 4: Council Flow Demo

Show the 3-round debate pattern with a concrete example:

```
Example: /DebateCouncil Should we use WebSockets or SSE for real-time updates?

What happens:
  1. Lead selects: SystemArchitect, UxDesigner, SoftwareDeveloper, WebResearcher
  2. ROUND 1: Each gives initial position (in parallel)
  3. [Checkpoint]: Lead shows positions, asks user for input
  4. ROUND 2: Each responds to others' points BY NAME (in parallel)
  5. ROUND 3: Each identifies agreements + final recommendation (in parallel)
  6. Lead synthesizes: convergence, disagreements, recommended path

Debate modes:
  - Default: checkpoint after Round 1 (ask user before debate)
  - autonomous/fast: all 3 rounds without stopping
  - interactive: checkpoint after every round
  - quick: Round 1 only + synthesis
```

## Step 5: Standalone Specialist Showcase

Show 3 example invocations for the standalone specialists:

**SecurityArchitect** — runs a full STRIDE threat model:
```
Task: SecurityArchitect — "Threat model the authentication system"
→ Executive summary, asset inventory, threat register, policy gaps, recommendations
```

**TheOpponent** — stress-tests any idea or decision:
```
Task: TheOpponent — "We're planning to rewrite the backend in Rust"
→ Steel man, key challenges, blind spots, hardest questions, overall assessment
```

**WebResearcher** — deep multi-query web research:
```
Task: WebResearcher — "Current best practices for rate limiting in distributed systems"
→ Decomposed queries, findings with confidence levels, sources, gaps
```

## Step 6: Live Demo (optional)

If the user requested `council` mode or the full showcase:

Ask the user which council type to demo, then invoke it with their input:
- `/Council [topic]` — cross-domain debate
- `/DeveloperCouncil [task]` — code review or architecture
- `/ProductCouncil [spec]` — requirements or strategy
- `/KnowledgeCouncil [topic]` — vault organization, memory lifecycle

If the user requested `agents` mode: pick one agent and run it on a real file from the current project as a demonstration.

If no live demo was requested, end with:

```
Ready to try it?

  /DebateCouncil [topic to debate]
  /DeveloperCouncil [code to review]
  /ProductCouncil [requirements to evaluate]
  /KnowledgeCouncil [knowledge management topic]

  Or invoke any specialist standalone:
    Task tool → subagent_type: "SystemArchitect"
    Task tool → subagent_type: "TheOpponent"
    Task tool → subagent_type: "ProductManager"

> **Gemini CLI Note**: In the Gemini CLI, standalone specialists are invoked directly using `@AgentName` (e.g., `@SystemArchitect`, `@TheOpponent`).
```

## Constraints

- Keep the demo concise — showcase, don't lecture
- Read actual agent files to populate the roster (don't hardcode)
- If running a live demo, use a real task from the user's project
- The demo should take under 2 minutes to present (excluding live council runs)
