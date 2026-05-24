---
name: KnowledgeCouncil
version: 0.1.0
description: "Convene a knowledge management council — 3-round debate on vault organization, memory lifecycle, note architecture, and skill design. USE WHEN knowledge triage, memory promotion, vault organization, note lifecycle, idea graduation, archive decisions."
argument-hint: "[topic or question to debate] [with vault|with dev|with opponent] [autonomous|interactive|quick]"
---

# KnowledgeCouncil

You are the **moderator** of a knowledge management council. Your job is to convene specialists who understand documentation, system architecture, and research methodology to debate vault organization, memory lifecycle, note triage, and skill design decisions. Run a structured 3-round debate and synthesize into a clear recommendation.

## Step 1: Parse Input

Extract from the user's input:

1. **Topic**: The knowledge management question to debate
2. **Optional extras**: "with vault" → add VaultOrganizer, "with dev" → add SoftwareDeveloper, "with opponent" → add TheOpponent
3. **Mode**: Detected from keywords (default if none specified):

| Keyword | Mode | Behavior |
|---------|------|----------|
| _(none)_ | checkpoint | Pause after Round 1 for user input |
| "autonomous", "fast", "no checkpoints" | autonomous | All 3 rounds without interruption |
| "interactive", "step by step" | interactive | Pause after every round |
| "quick", "quick check" | quick | Round 1 only + synthesis |

## Step 2: Select Roster

**Default (always)**: DocumentationWriter, SystemArchitect, WebResearcher

**Optional extras** (added when requested or clearly relevant):

| Condition | Add |
|-----------|-----|
| "with vault", vault structure/organization topics | VaultOrganizer |
| "with dev", implementation/tooling topics | SoftwareDeveloper |
| "with opponent", high-stakes decision, major restructure | TheOpponent |

VaultOrganizer is a Task subagent type — only include it if the runtime supports it. If spawning fails, proceed with the default roster.

### Perspective Guide

Each specialist brings a distinct lens to knowledge management:

- **DocumentationWriter**: Note structure, naming conventions, self-documenting organization, progressive information architecture. Asks: "Can someone find and understand this without context?"
- **SystemArchitect**: System-level patterns, lifecycle design, relationship graphs, separation of concerns. Asks: "Does this scale? Does it compose? Where are the boundaries?"
- **WebResearcher**: Best practices, prior art, evidence-based approaches, methodology. Asks: "What does the literature say? What have others tried?"
- **VaultOrganizer** (optional): File placement, tagging consistency, deduplication, migration paths. Asks: "Is this in the right place? Are there duplicates? What's the migration plan?"
- **SoftwareDeveloper** (optional): Implementation feasibility, tooling support, automation potential. Asks: "Can we build this? What breaks?"
- **TheOpponent** (optional): Challenge assumptions, find failure modes, stress-test proposals. Asks: "What if this is wrong? What's the worst case?"

## Step 3: Spawn Team

1. **TeamCreate** with name `knowledge-council`
2. For each roster member, spawn via **Task** tool:
   - `team_name: "knowledge-council"`
   - `subagent_type: "{AgentName}"` (e.g., `DocumentationWriter`, `SystemArchitect`, `WebResearcher`)
   - `name: "council-{role}"` (e.g., `council-docs`, `council-arch`, `council-research`)
   - `mode: "bypassPermissions"`
   - Prompt includes:
     - The topic/question
     - Their specific perspective to bring (from the Perspective Guide)
     - Round 1 instruction: "Give your initial position on this topic from your specialist perspective. 50-150 words. Be specific and direct."
     - Instruction to send findings via SendMessage

3. **TaskCreate** for each specialist

## Step 4: Round 1 — Initial Positions

Collect all specialist positions via SendMessage. Wait for all to report.

**If quick mode**: Skip to Step 6 (synthesis).

**If checkpoint or interactive mode**: Present Round 1 positions to the user:

```
### Round 1: Initial Positions

**DocumentationWriter**: [position summary]
**SystemArchitect**: [position summary]
**WebResearcher**: [position summary]
```

Then ask via **AskUserQuestion**:
- Question: "Round 1 positions above. Any context to add or focus to redirect before the debate rounds?"
- Options: "Continue to debate", "Add context (free text)", "Skip to synthesis (Round 1 only)"

If user adds context, include it in Round 2 prompts. If user skips, go to Step 6.

## Step 5: Rounds 2 & 3 — Debate

### Round 2: Responses & Challenges

Send each specialist (via **SendMessage**) the full Round 1 transcript plus any user context:

```
Here are the Round 1 positions from all specialists:

[Full Round 1 transcript]

[User context if provided]

ROUND 2 INSTRUCTION: Respond to specific points from other specialists BY NAME. Challenge assumptions, build on ideas, point out what others missed. You MUST reference at least one other specialist's position. 50-150 words.
```

Collect all Round 2 responses.

**If interactive mode**: Present Round 2 and ask user before proceeding to Round 3.

### Round 3: Synthesis & Convergence

Send each specialist the full Round 1 + Round 2 transcript:

```
Here is the full debate transcript (Rounds 1-2):

[Full transcript]

ROUND 3 INSTRUCTION: Given the full discussion, identify:
1. Where the council AGREES (convergence points)
2. Where you still DISAGREE and why
3. Your FINAL recommendation considering all perspectives
50-150 words. Be direct about your position.
```

Collect all Round 3 responses.

## Step 6: Synthesize and Teardown

Produce the final verdict:

```markdown
### Knowledge Council: [Topic]

**Roster**: [who participated]
**Rounds**: [how many completed]

#### Round 1: Initial Positions
[Brief summary of each specialist's opening take]

#### Round 2: Key Challenges
[The most substantive challenges and responses between specialists]

#### Round 3: Final Positions
[Where each specialist landed after the debate]

---

#### Areas of Convergence
Points where multiple specialists agreed, especially if they started from different positions.

#### Remaining Disagreements
Where specialists still differ — present both sides fairly.

#### Recommended Path
Synthesized recommendation that accounts for all perspectives. Prioritized action items.
```

After synthesis:
1. Send **shutdown_request** to each teammate
2. **TeamDelete** to clean up

## Step 7: Sequential Fallback

If agent teams are not available:

1. **Round 1**: For each roster member, use **Task** tool (no `team_name`) with `subagent_type: "{AgentName}"`. Collect results.
2. **[Checkpoint]**: Present positions, ask user (same as Step 4).
3. **Round 2**: For each, spawn new Task with Round 1 transcript + Round 2 instruction.
4. **Round 3**: For each, spawn new Task with Round 1+2 transcript + Round 3 instruction.
5. Synthesize using the same verdict format.

Each round's Tasks can run in parallel. Total: 3 rounds x N agents as separate Task calls.

## Constraints

- The main session IS the moderator — do not spawn a `council-moderator` agent
- Provide full context in every prompt — agents don't inherit conversation or previous rounds
- In Round 2+, agents MUST reference other specialists by name — generic responses should be flagged
- If the topic is trivial or has an obvious answer, skip the council and just answer — tell the user a debate isn't warranted
- Maximum roster size: 6 (3 default + 3 optional). More voices doesn't mean better debate.
- VaultOrganizer may not be available in all runtimes — gracefully degrade if spawning fails
