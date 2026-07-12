---
name: StagedDelivery
version: 0.1.0
description: "Plan via adversarial council, then build in verified stages with per-stage commits. USE WHEN building a feature batch, continuing a roadmap ('continue'), council-plan + opponent-review + staged implementation, iterative delivery loop, or running a headless file-feedback build loop."
argument-hint: "[feature/scope to plan, or 'continue' to take the top deferred item] [interactive|file-feedback]"
---

# Staged Delivery

You orchestrate a **plan → build → verify** loop. You do NOT reinvent councils or verification — you route to an existing council (DeveloperCouncil, ProductCouncil, KnowledgeCouncil) and add three things a council lacks: an **opponent gate**, a **user/file decision gate**, and a **deferred-menu ledger** so any window can resume.

**Module boundary.** Route only within this module (forge-council councils + agents) — those are always present when StagedDelivery is. Other-module skills (`ExecutePlan`, `StagedReview`, `VerifyCompletion`, `LearnFrom` from forge-core; `ponytail-review`) are **optional enhancements: use them when installed, degrade gracefully when not.** Never hard-depend on a skill outside forge-council.

This skill is **opt-in per session**. On invocation, **arm the session** so a UserPromptSubmit hook reinforces the loop every prompt (mirrors caveman/ponytail):

```sh
mkdir -p ~/.config/staged-delivery && touch ~/.config/staged-delivery/armed
```

Disarm on "stop staged delivery" / "normal mode": `rm -f ~/.config/staged-delivery/armed`. Once armed, run every substantive feature this way until disarmed. Trivial edits skip the loop.

The reinforcement hook is optional and wired by hand — forge does not deploy runtime hooks. See [INSTALL.md](../../INSTALL.md) for the script and the `settings.json` snippet. Without the hook the skill still works; you lose only the per-prompt restatement.

**Assumes caveman + ponytail are active too.** This loop pairs with them: caveman governs prose (terse, drop filler — write code/commits normally), ponytail governs what you build (the ladder: does it need to exist? stdlib? native? one line? then minimal code — shortest working diff wins). If they are not loaded, behave as if they were: terse output, smallest correct diff. The reinforcement hook restates all three each prompt.

## The loop

For each unit of work (a feature batch, or one "continue"):

1. **Scope.** Take the user's named scope, or the top item from `DEFERRED.md` (see Ledger). State what you're about to plan.

2. **Route to a council — code-grounded.** Classify the scope, convene the matching council skill (it owns roster selection; don't hand-assemble one):

   | Scope | Council |
   |---|---|
   | any implementation, code review, architecture, debugging | DeveloperCouncil |
   | requirements, feature scoping, go/no-go, prioritization | ProductCouncil |
   | docs, skills, rules, vault/note architecture | KnowledgeCouncil |

   Pass the scope to the council as its topic. Tell its specialists to read real files and cite `file:line` — no theorizing.

   **2b. No council fits (fallback only).** For a lone-file review or one narrow specialty where no council applies, spawn 1-2 individual forge-council specialists directly instead — `SoftwareDeveloper`/`QaTester` (implementation), `DatabaseEngineer` (schema), `SecurityArchitect` (threat model), `SystemArchitect` (boundaries), `UxDesigner` (flows), `WebResearcher` (external facts, verify don't fabricate). This is the exception, not the default. A scientific/paper "build" is not a code loop — hand it to forge-science's ScientificCouncil directly rather than routing here.

3. **Opponent gate.** The gate is mandatory; how it runs depends on the route:
   - **DeveloperCouncil** seats no adversary by default — spawn a standalone `TheOpponent` over the council's output.
   - **ProductCouncil / KnowledgeCouncil** — append `"with opponent"` to the invocation so the council seats `TheOpponent` itself, then this step is a **gate-check** on the returned verdict.
   - **2b fallback** — spawn a standalone `TheOpponent` over the specialist output.

   However it runs, the verdict MUST: verify claims against code, resolve conflicts, **kill gold-plating**, and emit (a) a **staged build plan** where each stage is independently shippable + testable, and (b) the **single riskiest thing**. A verdict missing the riskiest-thing line is incomplete — bounce it back.

4. **Decision gate — user chooses, never auto-pick.** Surface only the *verified* forks. Two modes:
   - **Interactive**: `AskUserQuestion` with the options (recommended first, "(Recommended)").
   - **File-feedback** (headless/continuous): write the plan + forks to `.staged-delivery/plan-NNN.md`, set status `AWAITING_FEEDBACK`, and wait for `.staged-delivery/feedback-NNN.md`. See **File-feedback loop** below.
   Never expand scope beyond what was chosen.

5. **Stage the build.** Branch per feature (`feat/<slug>`). `TaskCreate` one task per stage so the work is resumable. Build in dependency order: model → migration → service → routes → template. **Commit per stage** (conventional commits, no Co-Authored-By unless asked).

6. **Verify every stage.** Run suites *separately* (unit / integration / migration / e2e) + linter. Pure logic modules carry a runnable `_self_check()` / `if __name__ == "__main__"`. Verify external-behavior claims empirically (run both tools, show matching output) — never assert a tool/API/constant you didn't check. **Never fan out repeated full-suite runs against a shared DB — sequential only** (concurrent runs truncate each other and manufacture flakes).

7. **Ponytail the diff.** Cut speculative flexibility, hand-rolled stdlib, single-impl abstractions. Shortest working diff wins. (Invoke ponytail-review if available.)

8. **Land.** Update CHANGELOG, ff-merge to main, delete the branch. State **honest caveats**: what's deferred, model ceilings, "estimate not guarantee", what abstains/refuses. Append new deferred items to the Ledger.

After a batch with transferable learnings (a teardown, a rename touching many files, 3+ user corrections), invoke `LearnFrom`.

## Deferred-menu ledger

Keep `DEFERRED.md` at repo root (or `.staged-delivery/DEFERRED.md`). Every council pass emits items not chosen — append them with a one-line rationale and a value tag. "Continue" reads the top item. This is what makes the loop resumable in a different window: state lives in the file, not in context.

## File-feedback loop (headless / continuous)

For running without a human at the terminal, replace the interactive decision gate with files under `.staged-delivery/`:

- `plan-NNN.md` — council + opponent verdict, the forks as a checklist, a `status:` header (`AWAITING_FEEDBACK` | `APPROVED` | `CHANGES`).
- `feedback-NNN.md` — the decision. Two ways to produce it:
  1. **Human**: edits the file, picks options, sets `status: APPROVED`.
  2. **Verifier agents**: spawn a small reviewer panel (2-3 agents: a skeptic, a domain checker, a scope-cutter) that critique the plan and write a consensus decision + `status:`. Use this to fully close the loop with no human.
- Poll with `/loop` + `ScheduleWakeup` (long interval, 1200s+ when idle; short only when actively waiting on a just-written file). On `APPROVED` → implement stages → write `result-NNN.md` → start cycle NNN+1 from the Ledger. On `CHANGES` → re-run the opponent gate with the feedback.

Keep `state.json` (`{cycle, phase, branch}`) so a fresh window resumes mid-loop.

## Constraints

- Council first. A council is the default; individual specialists (2b) are the exception, used only when no council covers the scope. Never hand-assemble a specialist roster when a council fits.
- Stay in-module. Route only to forge-council councils/agents; treat forge-core and other skills as optional, and degrade gracefully when they are absent.
- Code-grounded everything. Read before asserting; cite `file:line`.
- The user owns scope. Never auto-expand; never pick a fork for them in interactive mode.
- One feature = one branch = staged commits. Don't batch unrelated work.
- Opponent output is mandatory before any code.
- Trivial/mechanical edits skip the whole loop — say so and just do them.
- Honest caveats always; no overclaiming "done" without the verification output behind it.
