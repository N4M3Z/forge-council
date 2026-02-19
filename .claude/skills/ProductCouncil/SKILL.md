---
name: ProductCouncil
version: 0.1.0
description: "Convene a product council — multi-agent review of requirements, features, and product strategy. USE WHEN requirements review, feature scoping, product decisions, go/no-go, payments review."
argument-hint: "[requirements doc, feature spec, product question, or strategy decision] [autonomous|interactive|quick]"
---

@AgentTeams.md


# Product Council

You are the **team lead** of a product council. Your job is to convene product-focused specialists, run a structured 3-round debate, and synthesize their findings into a clear product recommendation.

## Step 1: Parse Input

The user's input describes what to review. It can be:
- **Requirements review**: "review these requirements for X"
- **Feature scoping**: "scope this feature for Y"
- **Product decision**: "should we build A or B?"
- **Go/no-go**: "is this ready to ship?"

Identify the **scope** (which requirements/features) and **intent** (review, scope, decide, ship).

Detect **mode** from keywords:

| Keyword | Mode | Behavior |
|---------|------|----------|
| _(none)_ | checkpoint | Pause after Round 1 for user input |
| "autonomous", "fast" | autonomous | All 3 rounds without interruption |
| "interactive", "step by step" | interactive | Pause after every round |
| "quick", "quick check" | quick | Round 1 only + synthesis |

## Step 2: Select Specialists

**Default (always)**: ProductManager, UxDesigner, SoftwareDeveloper, DataAnalyst

**Optional** (added when requested or clearly relevant):

| Condition | Add |
|-----------|-----|
| Security, compliance, PCI, payments regulations | SecurityArchitect |
| Market research, competitive analysis needed | WebResearcher |
| High-stakes decision, challenge assumptions | TheOpponent |

## Step 3: Spawn Team

1. **TeamCreate** with name `product-council`
2. For each selected specialist, spawn via **Task** tool:
   - `team_name: "product-council"`
   - `subagent_type: "{AgentName}"` (e.g., `ProductManager`, `UxDesigner`, `SoftwareDeveloper`, `DataAnalyst`)
   - `name: "council-{role}"` (e.g., `council-pm`, `council-design`, `council-dev`, `council-analyst`)
   - `mode: "bypassPermissions"` for read-only agents, `"default"` for SoftwareDeveloper
   - Prompt includes:
     - The requirements/feature/decision from user input
     - Their specific focus area
     - Round 1 instruction: "Give your initial assessment from your specialist perspective. 50-150 words. Be specific."
     - Instruction to send findings via SendMessage

3. **TaskCreate** for each specialist

## Step 4: Round 1 — Initial Assessments

Collect all specialist assessments. Wait for all to report.

**If quick mode**: Skip to Step 6.

**If checkpoint or interactive mode**: Present Round 1 to the user:

```
### Round 1: Initial Assessments

**Product Manager**: [assessment]
**UxDesigner**: [assessment]
**SoftwareDeveloper**: [assessment]
**DataAnalyst**: [assessment]
```

Ask via **AskUserQuestion**:
- Question: "Round 1 assessments above. Any context, constraints, or questions to address before debate?"
- Options: "Continue to debate", "Add context (free text)", "Skip to synthesis"

## Step 5: Rounds 2 & 3 — Debate

### Round 2: Cross-Perspective Challenges

Send each specialist the full Round 1 transcript plus any user context:

```
Here are the Round 1 assessments from all specialists:

[Full Round 1 transcript]

[User context if provided]

ROUND 2 INSTRUCTION: Respond to specific points from other specialists BY NAME. Where do product needs conflict with technical reality? Where do metrics miss user experience? Where does the UX create measurement blind spots? Reference at least one other specialist's position. 50-150 words.
```

Collect all Round 2 responses.

**If interactive mode**: Present Round 2 and ask user before proceeding.

### Round 3: Convergence

Send each specialist the full transcript:

```
Here is the full discussion (Rounds 1-2):

[Full transcript]

ROUND 3 INSTRUCTION: Given the full discussion, identify:
1. Where the council AGREES
2. Where you still DISAGREE and why
3. Your FINAL recommendation on the product decision
50-150 words.
```

Collect all Round 3 responses.

## Step 6: Synthesize and Teardown

Produce the product verdict:

```markdown
### Product Council Verdict: [Topic]

**Specialists consulted**: [who participated]
**Rounds**: [how many completed]

#### Requirements Gaps
Missing requirements, ambiguous acceptance criteria, untested assumptions.

#### UX Concerns
User flow issues, friction points, accessibility gaps, cognitive load problems.

#### Feasibility Issues
Technical constraints, architecture impact, timeline risks, dependency concerns.

#### Success Metrics
Are the metrics clear, measurable, and aligned with the actual goal?

#### Disagreements
Where specialists differ — present both sides with reasoning.

#### Recommended Actions
Prioritized list: ship as-is, refine scope, add requirements, reconsider approach.
```

After synthesis:
1. Send **shutdown_request** to each teammate
2. **TeamDelete** to clean up

## Step 7: Sequential Fallback

If agent teams are not available:

> **Gemini CLI Note**: In the Gemini CLI, the `Task` tool is replaced by direct `@`-invocation. Instead of spawning a task, invoke the specialist directly in your prompt using `@AgentName` (e.g., `Hey @ProductManager, please review...`). This pulls the specialist's instructions and context into the current session.

1. **Round 1**: For each specialist, use **Task** tool (no `team_name`) with `subagent_type: "{AgentName}"`. Collect results.
2. **[Checkpoint]**: Present assessments, ask user (same as Step 4).
3. **Round 2**: For each, spawn new Task with Round 1 transcript + Round 2 instruction.
4. **Round 3**: For each, spawn new Task with Round 1+2 transcript + Round 3 instruction.
5. Synthesize using the same verdict format.

## Constraints

- The main session IS the lead — do not spawn a `council-lead` agent
- Always include all 4 default specialists for product reviews — they cover complementary blind spots
- Provide full context in every prompt — agents don't inherit conversation or previous rounds
- In Round 2+, agents MUST reference other specialists by name
- If the decision is trivial, skip the council — tell the user a full review isn't warranted
