---
name: Demo
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
║         Eight specialists. One unified verdict.         ║
╚══════════════════════════════════════════════════════════╝
```

Then explain the core idea in 2-3 sentences:

> A single AI reviewing code sees one perspective. forge-council provides eight specialist agents — five form a developer council for multi-perspective reviews, three operate as standalone specialists. Each agent brings domain expertise that a generalist would miss.

## Step 3: The Roster

Present the agents as a formatted table, reading each from `Modules/forge-council/agents/`:

```bash
for f in Modules/forge-council/agents/*.md; do
  name=$(grep "^claude.name:" "$f" | head -1 | awk -F': ' '{print $2}')
  model=$(grep "^claude.model:" "$f" | head -1 | awk -F': ' '{print $2}')
  desc=$(grep "^claude.description:" "$f" | head -1 | sed 's/^claude.description: *//' | sed 's/"//g' | cut -d'—' -f1)
  echo "$name|$model|$desc"
done
```

Format as:

```
┌─────────────────────────────────────────────────────────┐
│  THE COUNCIL (multi-perspective review)                 │
├──────────────────────┬────────┬─────────────────────────┤
│ Developer            │ sonnet │ Implementation quality   │
│ Database             │ sonnet │ Schema & query perf      │
│ DevOps               │ sonnet │ CI/CD & deployment       │
│ DocumentationWriter  │ sonnet │ README & API docs        │
│ Tester               │ sonnet │ Coverage & edge cases    │
│ SecurityArchitect    │ sonnet │ Threat modeling          │
├──────────────────────┴────────┴─────────────────────────┤
│  STANDALONE SPECIALISTS                                 │
├──────────────────────┬────────┬─────────────────────────┤
│ Opponent             │ opus   │ Devil's advocate         │
│ Researcher           │ sonnet │ Deep web research        │
└──────────────────────┴────────┴─────────────────────────┘
```

## Step 4: Council Flow Demo

Show the council orchestration pattern with a concrete example:

```
Example: /DeveloperCouncil Review the payment processing module

What happens:
  1. Lead parses the task → code + deployment + security relevant
  2. Spawns: Developer, Tester, DevOps, SecurityArchitect (4 agents)
  3. Each reviews independently, in parallel
  4. Lead synthesizes findings into a unified verdict

The result:
  - Cross-cutting issues (flagged by multiple specialists)
  - Per-specialist findings with file:line references
  - Prioritized action items
  - Disagreements between specialists (both sides presented)
```

## Step 5: Standalone Specialist Showcase

Show 3 example invocations for the standalone specialists:

**SecurityArchitect** — runs a full STRIDE threat model:
```
Task: SecurityArchitect — "Threat model the authentication system"
→ Executive summary, asset inventory, threat register, policy gaps, recommendations
```

**Opponent** — stress-tests any idea or decision:
```
Task: Opponent — "We're planning to rewrite the backend in Rust"
→ Steel man, key challenges, blind spots, hardest questions, overall assessment
```

**Researcher** — deep multi-query web research:
```
Task: Researcher — "Current best practices for rate limiting in distributed systems"
→ Decomposed queries, findings with confidence levels, sources, gaps
```

## Step 6: Live Demo (optional)

If the user requested `council` mode or the full showcase:

Ask the user what they'd like the council to review. Then invoke `/DeveloperCouncil` with their input.

If the user requested `agents` mode: pick one agent and run it on a real file from the current project as a demonstration.

If no live demo was requested, end with:

```
Ready to try it?

  /DeveloperCouncil [describe what to review]

  Or invoke any specialist standalone:
    Task tool → subagent_type: "SecurityArchitect"
    Task tool → subagent_type: "Opponent"
    Task tool → subagent_type: "Researcher"
```

## Constraints

- Keep the demo concise — showcase, don't lecture
- Read actual agent files to populate the roster (don't hardcode)
- If running a live demo, use a real task from the user's project
- The demo should take under 2 minutes to present (excluding live council runs)
