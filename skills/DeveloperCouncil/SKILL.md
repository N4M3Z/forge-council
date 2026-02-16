---
name: DeveloperCouncil
description: "Convene a developer council — multi-agent review, design, or debugging. USE WHEN multi-perspective code review, architecture decisions, team-based problem solving, developer council."
argument-hint: "[task description, PR reference, file paths, or architectural question]"
---

# Developer Council

You are the **team lead** of a developer council. Your job is to convene the right specialists, assign them focused tasks, and synthesize their independent findings into a unified verdict.

## Step 1: Gate Check

Check if agent teams are available:

```bash
echo "${CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS:-0}"
```

- If `1`: use agent teams (TeamCreate + parallel Task spawning)
- If `0` or missing: tell the user agent teams are not enabled, then fall back to sequential mode (see Step 7)

## Step 2: Parse Input

The user's input describes what to council on. It can be:
- **Code review**: file paths, PR reference, or "review X"
- **Architecture decision**: "should we use A or B?"
- **Debugging**: "this is failing, figure out why"
- **Design review**: "evaluate this approach"

Identify the **scope** (which files/areas) and **intent** (review, design, debug, decide).

## Step 3: Select Specialists

Do NOT always spawn all specialists. Pick 2-5 relevant specialists based on the task:

| Condition | Include |
|-----------|---------|
| Any code changes or implementation | `Developer` (always) |
| Any code changes or implementation | `Tester` (always) |
| Database schemas, queries, migrations, ORMs | `Database` |
| CI/CD, deployment, infra, config | `DevOps` |
| Public API surface, README, breaking changes | `DocumentationWriter` |
| Security assessment, threat modeling | `SecurityArchitect` |

**Exception**: If the user says "full council" or the task is a major architecture decision, spawn all 6.

For lightweight tasks (single file change, small bug fix), 2 specialists (Developer + Tester) is enough.

## Step 4: Spawn Team

1. **TeamCreate** with name `dev-council`
2. For each selected specialist, spawn via **Task** tool:
   - `team_name: "dev-council"`
   - `subagent_type: "{AgentName}"` (e.g., `Developer`, `Tester`, `SecurityArchitect`)
   - `name: "council-{role}"` (e.g., `council-dev`, `council-qa` — for SendMessage addressing)
   - `mode: "bypassPermissions"` for read-only agents, `"default"` for agents with write access
   - In the prompt, provide:
     - The task description from the user
     - Specific file paths or PR details
     - What you want this specialist to focus on
     - Instruction to send findings back via SendMessage

Example spawn prompt for Developer:
```
Review the following code for implementation quality, patterns, and correctness.

Target: [files/PR/description from user input]

Focus on: correctness, readability, maintainability, pattern adherence.
Send your findings to the team lead when done.
```

3. **TaskCreate** for each specialist with a focused subject and description
4. Create a synthesis task assigned to yourself, blocked by all specialist tasks

## Step 5: Monitor and Coordinate

- Specialist messages are delivered automatically — you do not need to poll
- If a specialist reports "nothing relevant for my domain", acknowledge and move on
- If a specialist is blocked or needs clarification, relay the question to the user
- Wait for all specialists to report before synthesizing

## Step 6: Synthesize and Teardown

Once all specialists have reported, produce a structured verdict:

### Council Verdict: [Task Summary]

**Specialists consulted**: [list who participated]

#### Critical Issues
Issues flagged by multiple specialists or with high production impact.

#### Specialist Findings

**Dev**: [summary of dev findings]
**QA**: [summary of QA findings]
**DB**: [summary of DB findings, if consulted]
**Ops**: [summary of Ops findings, if consulted]
**Docs**: [summary of Docs findings, if consulted]
**Security**: [summary of Security findings, if consulted]

#### Disagreements
Where specialists had conflicting recommendations — present both sides.

#### Recommended Actions
Prioritized list of what to do next, synthesized from all findings.

---

After synthesis:
1. Send **shutdown_request** to each teammate
2. **TeamDelete** to clean up

## Step 7: Sequential Fallback

If agent teams are not available (gate check failed), run the council sequentially:

1. For each selected specialist, use the **Task** tool (without `team_name`) with `subagent_type: "{AgentName}"` (e.g., `Developer`, `Tester`)
2. Collect each result
3. Synthesize findings using the same verdict format from Step 6

This is slower but requires no experimental features.

## Constraints

- Never spawn agents the task doesn't need — each agent is a full context window
- Always include `Developer` and `Tester` for code-related tasks
- The main session IS the lead — do not spawn a `council-lead` agent
- Provide specific file paths and context in spawn prompts — agents don't inherit your conversation
- If the task is trivial (typo fix, config change), skip the council and just do it — tell the user a council isn't warranted
