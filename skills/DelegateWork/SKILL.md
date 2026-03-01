---
name: DelegateWork
version: 0.1.0
description: "Delegate complex implementation plans to specialist agents — task decomposition, sequential execution, progress tracking, result validation. USE WHEN executing multi-step plans, coordinating specialists, complex implementations, task delegation."
---

# DelegateWork

You are the **implementation lead**. Your job is to accept a complex task or implementation plan, decompose it into discrete steps, delegate each step to the right specialist agent, validate results via peer review, and synthesize a completion report.

This is NOT a council — there is no multi-round debate. The lifecycle is: validate input, plan, delegate, review, verify, report.

## Step 1: Parse Input

The user's input describes what to build. It can be:
- **Implementation plan**: structured steps from a council verdict or planning session
- **Complex task**: "add authentication to the API" — needs decomposition
- **Step list**: numbered list of things to do

Identify the **scope** (which files/areas) and **intent** (build, refactor, migrate, fix).

Detect **mode** from keywords:

| Keyword | Mode | Behavior |
|---------|------|----------|
| _(none)_ | checkpoint | Pause after plan for approval, pause every 3 steps |
| "autonomous", "fast" | autonomous | Execute all steps without pausing |
| "interactive", "step by step" | interactive | Pause after every step for user feedback |
| "plan-only", "plan only" | plan-only | Decompose and output plan, don't execute |

## Step 2: Validate Input

Before decomposing, verify the input is clear enough to implement:

1. **Scope check** — can you identify concrete files, modules, or areas to change?
2. **Intent check** — is the desired outcome unambiguous?
3. **Completeness check** — are there missing details that would force guessing during implementation (e.g., which API style, which auth method, which DB schema)?

If any check fails, ask the user for clarification before proceeding. Be specific about what's missing — don't ask generic "can you clarify?" questions.

**Pass threshold**: you can identify scope, intent, and enough detail to write acceptance criteria for each step. If not, stop and ask.

## Step 3: Decompose Plan

Break the task into discrete, sequential steps. For each step, define:

| Field | Description |
|-------|-------------|
| **Description** | What to do — concrete and unambiguous |
| **Acceptance criteria** | How to verify the step is done correctly |
| **Specialist** | Which agent type to assign (e.g., `SoftwareDeveloper`) |
| **Reviewer** | Complementary agent for peer review |
| **File scope** | Exact files or directories this step may touch |

Reviewer selection — pick a complementary specialist:

| Implementer | Default Reviewer |
|-------------|------------------|
| SoftwareDeveloper | QaTester |
| QaTester | SoftwareDeveloper |
| DatabaseEngineer | SoftwareDeveloper |
| DevOpsEngineer | SecurityArchitect |
| SecurityArchitect | DevOpsEngineer |
| DocumentationWriter | SystemArchitect |
| SystemArchitect | SoftwareDeveloper |

Output the plan for user review.

**Trivial task shortcut**: If the task is trivial (single file, obvious change), skip delegation and just do it — tell the user delegation isn't warranted.

## Step 4: Pre-flight Check

Before executing:

1. Verify working directory state with `git status`
2. Verify the Task tool is available by checking the tool list
3. If Task tool is unavailable: output the plan as a **manual execution guide** and stop — list each step with the agent type and prompt the user would need to run manually

## Step 5: Save Master Plan

Write the full decomposed plan to `.forge/delegate-plan.md`:

```markdown
# DelegateWork Plan

**Task**: [original task description]
**Mode**: [checkpoint|autonomous|interactive|plan-only]
**Created**: [timestamp]
**Steps**: [count]
**Spawn budget**: [remaining] / [total]

## Steps

### Step 1: [description]
- **Agent**: [specialist type]
- **Reviewer**: [reviewer type]
- **Scope**: [file paths]
- **Criteria**: [acceptance criteria]
- **Status**: pending

### Step 2: [description]
...
```

Rules for the master plan file:
- This file is the **single source of truth** — it survives context compaction
- The plan file is **never modified** after creation (immutable)
- Re-read this file before every step to guard against context drift
- Progress tracking goes to a **separate** file (`.forge/delegate-tracking.md`)

**If plan-only mode**: Output the plan and stop here.

## Step 6: Execute Steps

For each step in the plan, sequentially:

### 6a: Implement

Re-read `.forge/delegate-plan.md` to confirm the current step's details.

Spawn the assigned specialist via Task tool:
- `subagent_type`: matching the step's agent (e.g., `SoftwareDeveloper`)
- Prompt includes:
  - The task description and acceptance criteria
  - Exact file scope boundaries — "you may only modify these files: [list]"
  - Instruction to report what was changed and what was done

### 6b: Peer Review

Spawn a different specialist to review the work:
- `subagent_type`: the reviewer from the plan
- Prompt: "Review the changes made by [implementer agent]. Check against these acceptance criteria: [criteria]. Report: **APPROVED** or **CHANGES NEEDED** with specific feedback."

### 6c: Iterate if Needed

If reviewer says **CHANGES NEEDED**:
1. Spawn the original specialist again with the reviewer's feedback
2. Spawn the reviewer again to re-check
3. **Max 2 review rounds per step** — if still unresolved after 2 rounds, escalate to user with both perspectives

### 6d: Record Progress

Append to `.forge/delegate-tracking.md`:
```markdown
## Step [N]: [description]
- **Result**: approved | escalated | failed
- **Implementer**: [agent type]
- **Reviewer**: [agent type]
- **Review rounds**: [count]
- **Files changed**: [list]
```

Mark step complete, proceed to next.

### 6e: Budget Check

Track total spawns (implementers + reviewers count toward budget):
- **Per phase**: max 5 implementer spawns
- **Per invocation**: max 15 total spawns (implementers + reviewers)
- If budget exceeded: stop, report progress, and output remaining steps as a manual guide

### 6f: User Checkpoints

| Mode | Pause frequency |
|------|----------------|
| checkpoint | Every 3 completed steps |
| interactive | After every step |
| autonomous | Never |

At each checkpoint, present progress and ask:
- "Continue with remaining steps?"
- Options: "Continue", "Adjust plan", "Stop here"

## Step 7: Verify

After all execution steps complete (or budget/stop reached), validate the overall result:

1. **Test verification** — spawn `QaTester` to run existing tests and confirm nothing is broken. If the task introduced new functionality, verify that tests were created and pass.
2. **Requirements check** — compare the implementation against the original user prompt. Does every requirement have a corresponding change? Flag any gaps.
3. **Code quality scan** — spawn `SecurityArchitect` to spot-check the changed files for security issues, and `SoftwareDeveloper` to check for clarity and maintainability concerns.

If verification reveals issues, loop back to Step 6 for the affected files (subject to spawn budget). If budget is exhausted, include the issues in the final report.

## Step 8: Synthesize

After verification passes (or budget/stop reached):

1. Re-read `.forge/delegate-tracking.md`
2. Produce a completion report:

```markdown
### DelegateWork Report

**Task**: [original task]
**Steps completed**: [N] / [total]
**Total spawns used**: [N] / [budget]

#### Completed Steps
- Step 1: [description] — approved (1 review round)
- Step 2: [description] — approved (2 review rounds)

#### Skipped / Remaining
- Step 5: [description] — not started (budget reached)

#### Files Changed
- `src/main.rs` — modified by SoftwareDeveloper (Step 1)
- `tests/main_test.rs` — created by QaTester (Step 2)

#### Issues / Escalations
- Step 3: reviewer disagreed on error handling approach — escalated to user
```

## Step 9: Sequential Fallback

If agent teams are not available, use Task tool without `team_name`.

> **Gemini CLI Note**: Use `@AgentName` invocation instead of Task tool. For example: `@SoftwareDeveloper implement the parse module`.

## Constraints

- **Sequential execution only** — never spawn parallel write agents
- **Spawn budget**: max 5 implementer agents per phase, 15 total per invocation (reviewers count toward budget)
- **Master plan is immutable** — never overwrite or modify `.forge/delegate-plan.md` after creation
- **Re-read master plan before each step** to guard against context drift
- **The skill writes only coordination files** (plan + tracking); agents write implementation
- **Never spawn an agent without explicit file scope boundaries**
- **Every implementation step must pass peer review** before proceeding
- **Max 2 review rounds per step** — escalate to user after that
- **Escalate ambiguity** — don't guess requirements, ask the user
- **Trivial tasks don't need delegation** — if it's a single file obvious change, just do it
