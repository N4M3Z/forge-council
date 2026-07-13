---
name: HarnessCouncil
version: 0.1.0
description: "Convene a council of independent AI CLI harnesses (codex, agy, grok, Lumo) plus a Fable subagent to review ONE artifact in parallel, then synthesize by cross-harness agreement. USE WHEN you want a second and third opinion from other vendors on a repo, PR, plan, findings, spec, or design; running an adversarial cross-check across models; stress-testing a decision; or figuring out which CLI harnesses can actually run headlessly and how to handle their quirks (hangs, preamble-only output, missing CLIs, drifted model ids)."
---

# HarnessCouncil

Council member availability on this machine (missing = skip, or ask the user to install):

!`for cli in codex agy grok opencode; do command -v "$cli" >/dev/null 2>&1 && printf '%s ' "$cli" || printf '%s(missing) ' "$cli"; done`

Convene several independent AI harnesses on one question at once, collect their answers, and synthesize the result by cross-vendor agreement. Independence is the point: a second Claude shares Claude's blind spots; a different vendor does not. This is the one-to-many convener; for a one-to-one handoff to a single other harness use the ContextRelay skill.

The value here is operational: the council members are real CLIs with real quirks, and running them blindly wastes a turn. This skill records how to drive each one headlessly, how to tell a real answer from a non-answer, and how to combine the results honestly.

## The council

The availability line above already shows which members exist — drop anything marked missing, and never invent an invocation for a CLI that is not there.

| Member | Non-interactive invocation | Reads repo? | Notes |
|--------|----------------------------|-------------|-------|
| **Fable** | spawn a subagent via the Agent tool, `model: fable` | yes (has tools) | the in-house primary; give it the repo path |
| **codex** (GPT-5.5) | `codex exec -C <repo> -s read-only -m gpt-5.5 --color never - < brief` | yes | has a real `exec` subcommand; reliable |
| **agy** (Gemini) | `agy -p "<brief+source>"` | no | NO `exec`; flag-driven. Hangs often (see below) |
| **grok** | `grok -p "<brief+source>"` (`--single`), or `grok agent` | no | NO `exec`; composer model narrates a plan and exits unless told answer-only |
| **Lumo Max** | `opencode run -m proton-lumo/lumo-max "<brief+source>"` | no | Proton's model; non-interactive mode auto-rejects file reads, so inline the source |

Only **codex** among these has an `exec` subcommand. `agy exec` / `grok exec` are not real (they read "exec" as a prompt word); their headless mode is `-p`.

## Workflow

1. **Frame one shared brief** — the question plus the artifact. For members that cannot read files (agy, grok, Lumo), inline the material into the prompt; iterate a zsh array (`files=(a b c); for f in $files`) with `command cat -n`, never `for f in "$string"` (zsh does not word-split a scalar).
2. **Confirm the roster** — the availability injection above lists installed members. Check model ids against the CLI's own `models` list, not memory (grok serves `grok-composer-2.5-fast`, not "grok-4.5").
3. **Fan out in parallel** — spawn the Fable subagent and launch each CLI in the background, each writing to its own output file. Every CLI needs the keychain, localhost, and network, so run them outside the command sandbox (`dangerouslyDisableSandbox`).
4. **Collect, distinguishing answers from non-answers** — read each output. Treat these as abstentions, not verdicts: a hang (agy), a preamble-only reply that narrates intent then exits (grok's first try), unbounded reasoning with no conclusion (some local models), or a missing CLI.
5. **Synthesize by agreement** — rank findings by cross-harness consensus (agreement across independent vendors is the strong signal); note dissent explicitly; a lone finding is a lead to verify, not a fact. Verify concrete claims (paths, line numbers, env-var names) against the source yourself before acting. Return a ranked assessment, not four concatenated reviews.

## Failure modes and fixes

- **agy `-p` hangs** — it reliably produces nothing and must be killed. Wrap it in a hard timeout and treat non-return as abstained. Its agentic mode (`--add-dir`/`--sandbox`) hangs worse; do not use it.
- **grok prints only a preamble** — the composer model starts an agentic turn that single-turn mode cuts off. Prepend an explicit directive: "ANSWER-ONLY. Do not use tools, do not narrate a plan. Output only the final answer, reasoning from the material provided." Retry once.
- **A member is missing** (e.g. Sol not installed) — the availability line marks it; say so in the synthesis rather than silently dropping it.
- **Large inlined prompts** — keep the artifact tight; huge prompts make the slower CLIs time out.
- **Model id drift** — the CLI's `models` subcommand is the source of truth; a remembered name (a version bump, a renamed model) is not.

## Synthesis stance

Consensus across vendors is the deliverable, not each raw review. Say which members returned, which abstained and why, where they agreed (rank these first), and where a single member dissented (flag, don't bury). Then verify the load-bearing concrete claims yourself before you or the user act on them.
