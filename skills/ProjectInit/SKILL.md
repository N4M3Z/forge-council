---
name: ProjectInit
version: 0.1.0
description: "Establish a new project through a deep scoping interview -- distill the goal, set up local git tracking, and write project-scoped rules every subagent inherits. USE WHEN starting a new project, initializing a workspace, new research/analysis/coding effort, project kickoff, 'set up this project', or refreshing a project's rules after scope drift."
argument-hint: "[project directory, defaults to cwd] [refresh]"
---

# Project Init

You establish a project once, so every later session and every subagent starts oriented. The deliverable is not conversation -- it is a tracked workspace: local git, a distilled `CLAUDE.md`, and project-scoped rules under `.claude/rules/` that all subagents inherit. StagedDelivery is the natural follow-up loop, but this skill stands alone for any project type: research, discussion, coding, or data analysis.

**Module boundary.** Everything here uses native mechanisms (git, `CLAUDE.md`, `.claude/rules/`). Other-module skills (`Brainstorming` from forge-core) are optional enhancements: use them when installed, degrade gracefully when not.

## The interview

Dig deep before writing anything. Iterative `AskUserQuestion` rounds -- keep asking until the answers stop changing what you would write. Minimum ground to cover:

1. **Type and goal.** Research, discussion, coding, or data analysis? What does done look like -- the one-sentence outcome, and the measurable success criterion behind it.
2. **Scope edges.** What is explicitly out of scope. What already exists (data, code, documents, prior art) that the project builds on.
3. **Constraints.** Deadlines, tools that must or must not be used, external dependencies, compliance or privacy boundaries.
4. **Audience and voice.** Who consumes the output. Wording conventions, language, tone, terminology that must stay consistent.
5. **Visual consistency** (only when the project produces visual output). Color/typography/plot styling conventions, figure standards, templates to follow.
6. **Subagent context.** What must every spawned agent know without being told -- the facts that, if missing, make delegated work drift.

If the goal itself is still fuzzy after round one, run `Brainstorming` (when installed) to explore the space, then resume the interview with its output.

Follow-up rounds react to answers: a research project gets asked about venues and evidence standards; a coding project about stack, testing, and review gates; a data-analysis project about data provenance and reproducibility. Do not ask template questions the earlier answers already settled.

## The outputs

Write these in the project directory, in this order:

1. **Git tracking (local).** If no repo exists: `git init` (branch `main`), a `.gitignore` seeded for the project type, and an initial commit of the scaffold below. Never create a remote or push -- local tracking is the requirement.
2. **`CLAUDE.md`.** The distilled interview: goal, success criteria, scope edges, constraints, audience. Short -- it loads every session. Facts, not transcript.
3. **`.claude/rules/ProjectGoal.md`** -- always. The one rule every subagent inherits: what this project is, what done means, what is out of scope. Write it so a subagent with zero other context acts correctly.
4. **`.claude/rules/<Aspect>.md`** -- only for aspects the interview actually surfaced. Wording/terminology conventions, visual consistency standards, evidence or testing gates. One rule per aspect, PascalCase names, concise bodies. Do not write rules for things the interview never mentioned.
5. **`DEFERRED.md`** -- empty ledger seed (a heading and the format line), so StagedDelivery can resume scope from a file rather than context.

Stage everything, show the user the diff, commit on approval (conventional commits).

## Rule freshness

Rules rot when the project drifts. Instruct the session (and note it in `CLAUDE.md`):

- When the user corrects the same assumption 3+ times, or the goal/scope visibly shifts, propose the matching rule edit -- do not wait to be asked.
- `ProjectInit refresh` re-runs the interview only for the drifted areas: read the existing `CLAUDE.md` and rules first, ask only about what changed, rewrite only the affected files. Never re-interview from scratch when a refresh was requested.

## Handoff

Close by offering the follow-up loop: arm `StagedDelivery` for iterative delivery inside the newly scoped project. If StagedDelivery is not installed, say the project is initialized and stop -- the outputs stand on their own.

## Constraints

- Interview before writing. Never scaffold from assumptions the user did not confirm.
- The user owns the answers. Present distilled drafts for approval; never invent goals, style guides, or constraints that were not said.
- Local git only -- no remotes, no pushes, unless the user explicitly asks.
- Rules are scoped to what was surfaced. No boilerplate rule packs; an aspect nobody mentioned gets no rule.
- `CLAUDE.md` and rules are token-costly context -- keep them short and factual.
- Refresh mode edits only drifted files; it never rewrites a healthy scaffold.
