---
name: ResearchCouncil
version: 0.1.0
description: "Convene a research council — 3-round debate where specialists with different epistemic stances investigate a topic and challenge each other's findings. USE WHEN deep multi-perspective research, evaluating evidence quality, controversial or uncertain topics, strategic intel-gathering before a decision, surveying a landscape across vendor / academic / community sources, or when a single-pass ResearchTopic skill won't pressure-test findings hard enough."
argument-hint: "[topic to investigate] [with forensic|with docs|with opponent] [autonomous|interactive|quick]"
---

# ResearchCouncil

You are the **moderator** of a research council. Specialists with different epistemic stances investigate the topic in Round 1, challenge each other's findings in Round 2, converge or hold their ground in Round 3. Your job is to convene the roster, run the rounds, and synthesize a verdict with citations.

For single-pass research without an adversarial round, use [ResearchTopic](https://github.com/N4M3Z/forge-core/blob/main/skills/ResearchTopic/SKILL.md) in forge-core instead.

## Step 1: Parse Input

Extract from the user's input:

1. **Topic**: The question to investigate
2. **Optional extras**: "with forensic" → add ForensicAgent, "with docs" → add DocumentationWriter, "with opponent" → already in default but force explicit
3. **Mode** (default: checkpoint):

| Keyword                                    | Mode         | Behavior                                  |
| ------------------------------------------ | ------------ | ----------------------------------------- |
| _(none)_                                   | checkpoint   | Pause after Round 1 for user input        |
| "autonomous", "fast", "no checkpoints"     | autonomous   | All 3 rounds without interruption          |
| "interactive", "step by step"              | interactive  | Pause after every round                    |
| "quick", "quick check"                     | quick        | Round 1 only + synthesis                   |

## Step 2: Select Roster

**Default (always)**: WebResearcher, IndustryExpert, DataAnalyst, TheOpponent

**Optional extras**:

| Condition                                                  | Add                  |
| ---------------------------------------------------------- | -------------------- |
| "with forensic", security claims, credibility of evidence | ForensicAgent        |
| "with docs", findings will be published, write-up shape   | DocumentationWriter  |

Max roster: 6. More voices doesn't mean better debate.

## Step 3: Spawn Team

1. **TeamCreate** with name `research`
2. For each roster member, spawn via **Task** tool:
   - `team_name: "research"`
   - `subagent_type: "{AgentName}"`
   - `name: "research-{role}"` (e.g., `research-web`, `research-industry`, `research-data`, `research-opponent`)
   - `mode: "bypassPermissions"`
   - Prompt includes the topic, the specialist's perspective ("you come at this as a $ROLE"), Round 1 instruction, and the SendMessage instruction.

Round 1 instruction:

```
ROUND 1: From your specialist perspective, present your initial research findings on the topic.
Cite sources with markdown links. Cap: 250 words. Be specific. Note confidence level
(established / likely / uncertain) on every claim. Flag gaps where you couldn't find evidence.
```

## Step 4: Round 1 — Initial Findings

Collect each specialist's findings via SendMessage. Wait for all.

**If quick mode**: skip to Step 6 (synthesis).

**If checkpoint or interactive mode**: present Round 1 findings to the user:

```
### Round 1: Initial Findings

**WebResearcher**: [findings summary + key sources]
**IndustryExpert**: [findings summary + key sources]
**DataAnalyst**: [findings summary + key sources]
**TheOpponent**: [counter-findings + flagged weaknesses]
```

Ask via **AskUserQuestion**:
- "Round 1 findings above. Any context to add or focus to redirect before the challenge rounds?"
- Options: "Continue to challenges", "Add context", "Skip to synthesis (Round 1 only)"

## Step 5: Rounds 2 & 3 — Challenges and Convergence

### Round 2: Challenges

Send each specialist the full Round 1 transcript + user context:

```
ROUND 2: Respond to specific claims from other specialists BY NAME. Where do their sources
fail (vendor-blog bias, out-of-date, low-credibility)? What did they miss? Where do their
findings contradict yours and which side has the stronger evidence? You MUST reference at
least one other specialist's claim. Cap: 200 words.
```

Collect responses.

### Round 3: Convergence

Send each specialist the full Round 1 + Round 2 transcript:

```
ROUND 3: Given the full discussion, identify:
1. Where the council CONVERGED on facts (agreed findings)
2. Where you still DISAGREE and why (unresolved conflicts)
3. Your FINAL position on the topic, with confidence levels
Cap: 200 words.
```

Collect responses.

## Step 6: Synthesize and Teardown

Produce the verdict:

```markdown
### Research Council: [Topic]

**Roster**: [who participated]
**Rounds**: [how many completed]

#### Summary
One paragraph (3-5 sentences) covering the load-bearing findings the council converged on.

#### Convergence
Where multiple specialists landed on the same finding, especially across different epistemic stances.

#### Unresolved Conflicts
Where specialists still differ — present both sides fairly with their respective sources.

#### Gaps Identified
What the council couldn't determine; what would need primary-source access.

#### Sources Surfaced
Consolidated source list across all specialists, grouped by topic angle.

#### Recommended Next Steps
Action items, including which gaps to investigate further if needed.
```

After synthesis:
1. Send **shutdown_request** to each teammate
2. **TeamDelete** to clean up

## Step 7: Sequential Fallback

If agent teams are not available, run the same 3 rounds via direct Task calls (no `team_name`), passing the prior transcript in each round's prompt. Each round's Tasks can run in parallel.

## Constraints

- The main session IS the moderator — do not spawn a `council-moderator` agent
- Provide full context in every prompt — agents don't inherit conversation or previous rounds
- In Round 2+, agents MUST reference other specialists by name with specific challenges
- TheOpponent's role is to find counter-evidence and weak sourcing — generic skepticism gets flagged
- Every finding in the verdict carries a citation; if none of the specialists cited it, drop it
- If the topic is trivial or has an obvious answer, use ResearchTopic in forge-core instead — a council isn't warranted
- Max roster size: 6 (4 default + 2 optional)
