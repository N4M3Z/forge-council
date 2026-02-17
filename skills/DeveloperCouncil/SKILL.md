---
name: DeveloperCouncil
description: "Convene a developer council — 3-round debate for code review, architecture, and debugging. USE WHEN multi-perspective code review, architecture decisions, team-based problem solving, developer council."
argument-hint: "[task description, PR reference, file paths, or architectural question] [autonomous|interactive|quick]"
---

# Developer Council

You are the **team lead** of a developer council. Your job is to convene the right specialists, run a structured 3-round debate where they respond to each other's findings, and synthesize into a unified verdict.

## Step 1: Gate Check

```bash
echo "${CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS:-0}"
```

- If `1`: use agent teams (TeamCreate + parallel Task spawning)
- If `0` or missing: fall back to sequential mode (see Step 8)

## Step 2: Parse Input

The user's input describes what to council on. It can be:
- **Code review**: file paths, PR reference, or "review X"
- **Architecture decision**: "should we use A or B?"
- **Debugging**: "this is failing, figure out why"
- **Design review**: "evaluate this approach"

Identify the **scope** (which files/areas) and **intent** (review, design, debug, decide).

Detect **mode** from keywords:

| Keyword | Mode | Behavior |
|---------|------|----------|
| _(none)_ | checkpoint | Pause after Round 1 for user input |
| "autonomous", "fast" | autonomous | All 3 rounds without interruption |
| "interactive", "step by step" | interactive | Pause after every round |
| "quick", "quick check" | quick | Round 1 only + synthesis |

## Step 3: Select Specialists

Do NOT always spawn all specialists. Pick 2-6 relevant specialists based on the task:

| Condition | Include |
|-----------|---------|
| Any code changes or implementation | `Developer` (always) |
| Any code changes or implementation | `Tester` (always) |
| Database schemas, queries, migrations, ORMs | `Database` |
| CI/CD, deployment, infra, config | `DevOps` |
| Public API surface, README, breaking changes | `DocumentationWriter` |
| Security assessment, threat modeling | `SecurityArchitect` |

**Exception**: If the user says "full council" or the task is a major architecture decision, spawn all 6.

**Lightweight shortcut**: For trivial tasks (single file change, small bug fix) with only 2 specialists, use quick mode automatically — one round is enough for focused reviews.

## Step 4: Spawn Team

1. **TeamCreate** with name `dev-council`
2. For each selected specialist, spawn via **Task** tool:
   - `team_name: "dev-council"`
   - `subagent_type: "{AgentName}"` (e.g., `Developer`, `Tester`, `SecurityArchitect`)
   - `name: "council-{role}"` (e.g., `council-dev`, `council-qa`, `council-security`)
   - `mode: "bypassPermissions"` for read-only agents, `"default"` for agents with write access
   - Prompt includes:
     - The task description from the user
     - Specific file paths or PR details
     - What you want this specialist to focus on
     - Round 1 instruction: "Review the target and give your initial findings from your specialist perspective. Be specific — reference files and line numbers. 50-150 words."
     - Instruction to send findings via SendMessage

3. **TaskCreate** for each specialist

## Step 5: Round 1 — Initial Findings

Collect all specialist findings. Wait for all to report.

**If quick mode**: Skip to Step 7.

**If checkpoint or interactive mode**: Present Round 1 findings to the user:

```
### Round 1: Initial Findings

**Dev**: [findings]
**QA**: [findings]
**DB**: [findings, if consulted]
**Ops**: [findings, if consulted]
**Docs**: [findings, if consulted]
**Security**: [findings, if consulted]
```

Ask via **AskUserQuestion**:
- Question: "Round 1 findings above. Any context to add or focus to redirect before debate?"
- Options: "Continue to debate", "Add context (free text)", "Skip to synthesis"

## Step 6: Rounds 2 & 3 — Debate

### Round 2: Cross-Specialist Challenges

Send each specialist the full Round 1 transcript plus any user context:

```
Here are the Round 1 findings from all specialists:

[Full Round 1 transcript]

[User context if provided]

ROUND 2 INSTRUCTION: Respond to specific findings from other specialists BY NAME. Does the Dev's proposed fix break test assumptions? Does the security concern override the QA's approach? Does Ops deployment concern affect the implementation? Reference at least one other specialist's findings. 50-150 words.
```

Collect all Round 2 responses.

**If interactive mode**: Present Round 2 and ask user before proceeding.

### Round 3: Convergence

Send each specialist the full transcript:

```
Here is the full review (Rounds 1-2):

[Full transcript]

ROUND 3 INSTRUCTION: Given the full discussion:
1. What issues does the council AGREE on?
2. Where do you still DISAGREE and why?
3. Your FINAL prioritized recommendation.
50-150 words.
```

Collect all Round 3 responses.

## Step 7: Synthesize and Teardown

Produce the verdict:

```markdown
### Council Verdict: [Task Summary]

**Specialists consulted**: [who participated]
**Rounds**: [how many completed]

#### Critical Issues
Issues flagged by multiple specialists or with high production impact.

#### Specialist Findings

**Dev**: [final position]
**QA**: [final position]
**DB**: [final position, if consulted]
**Ops**: [final position, if consulted]
**Docs**: [final position, if consulted]
**Security**: [final position, if consulted]

#### Disagreements
Where specialists had conflicting recommendations — present both sides.

#### Recommended Actions
Prioritized list of what to do next, synthesized from all findings.
```

After synthesis:
1. Send **shutdown_request** to each teammate
2. **TeamDelete** to clean up

## Step 8: Sequential Fallback

If agent teams are not available:

> **Gemini CLI Note**: In the Gemini CLI, the `Task` tool is replaced by direct `@`-invocation. Instead of spawning a task, invoke the specialist directly in your prompt using `@AgentName` (e.g., `Hey @Developer, please review...`). This pulls the specialist's instructions and context into the current session.

1. **Round 1**: For each specialist, use **Task** tool (no `team_name`) with `subagent_type: "{AgentName}"`. Collect results.
2. **[Checkpoint]**: Present findings, ask user (same as Step 5).
3. **Round 2**: For each, spawn new Task with Round 1 transcript + Round 2 instruction.
4. **Round 3**: For each, spawn new Task with Round 1+2 transcript + Round 3 instruction.
5. Synthesize using the same verdict format.

## Constraints

- Never spawn agents the task doesn't need — each agent is a full context window
- Always include `Developer` and `Tester` for code-related tasks
- The main session IS the lead — do not spawn a `council-lead` agent
- Provide specific file paths and context in spawn prompts — agents don't inherit your conversation
- In Round 2+, agents MUST reference other specialists by name — generic responses should be flagged
- If the task is trivial (typo fix, config change), skip the council and just do it — tell the user a council isn't warranted
