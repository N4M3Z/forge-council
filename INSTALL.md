# forge-council

> Specialist agents organized into councils — developer, debate, product, knowledge, hiring. 3-round debates with user checkpoints.

*This file follows the [install.md](https://github.com/mintlify/install-md) standard — structured instructions for AI agents to execute autonomously. Human readers: see [README.md](README.md) for conventional documentation.*

I want you to install forge-council for me. Execute all the steps below autonomously.

## OBJECTIVE

Deploy forge-council agents, council skills, and rules to all AI providers via Makefile.

## DONE WHEN

- `make validate` passes
- `ls ~/.claude/agents/SoftwareDeveloper.md` confirms agent deployment
- `ls ~/.claude/skills/DebateCouncil/SKILL.md` confirms skill deployment
- `ls ~/.claude/rules/AgentTeams.md` confirms rule deployment
- `git config core.hooksPath` returns `.githooks`

## Prerequisites

- A supported AI provider CLI: Claude Code, Codex, Gemini CLI, or OpenCode
- forge-cli (`cargo install` from source, see step below)
- Optional: `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` in `~/.claude/settings.json` for parallel council execution

## TODO

- [ ] Install forge-cli
- [ ] Clone the repository
- [ ] Run `make install` to deploy
- [ ] Verify agent, skill, and rule deployment
- [ ] Verify git hooks are active

## Steps

### Clone

```sh
git clone https://github.com/N4M3Z/forge-council.git
cd forge-council
```
If already cloned, pull latest:

```sh
git pull
```

### Check prerequisites

```sh
make validate
```

If `forge` shows MISSING, install forge-cli first:

```sh
git clone https://github.com/N4M3Z/forge-cli.git
cd forge-cli
make install
cd ../forge-council
```

### Install

```sh
make install
```

### Verify deployment

```sh
ls ~/.claude/agents/SoftwareDeveloper.md
ls ~/.claude/skills/DebateCouncil/SKILL.md
ls ~/.claude/rules/AgentTeams.md
```

### Verify git hooks

```sh
git config core.hooksPath
```

Should return `.githooks`.

EXECUTE NOW: Complete the above TODO list.

## Optional: StagedDelivery reinforcement hook

The `StagedDelivery` skill works on its own. Its per-prompt reinforcement is an
optional `UserPromptSubmit` hook, wired by hand — `make install` does not deploy
runtime hooks. Skip this section unless you want the loop restated each prompt.

Save the hook script (e.g. to `~/.config/staged-delivery/reinforce.sh`) and
`chmod +x` it:

```bash
#!/usr/bin/env bash
# UserPromptSubmit hook: reinforce the StagedDelivery loop while the session is armed.
# Opt-in — silent unless ~/.config/staged-delivery/armed exists (the skill arms it;
# "stop staged delivery" disarms). Always exits 0; communicates via stdout JSON only.
set -u
ARMED="${HOME}/.config/staged-delivery/armed"
[ -f "$ARMED" ] || exit 0
cat <<'JSON'
{"hookSpecificOutput":{"hookEventName":"UserPromptSubmit","additionalContext":"STAGED DELIVERY ACTIVE. For substantive work run the loop: (1) council — 2-4 relevant specialists in parallel, code-grounded, cite file:line; (2) opponent gate (TheOpponent) — verify vs code, kill gold-plating, output a staged plan + the single riskiest thing; (3) user/file decision gate — never auto-pick scope; (4) build staged — branch per feature, commit per stage, TaskCreate per stage; (5) verify suites separately + self-checks, sequential DB runs only; (6) ponytail the diff; (7) land — CHANGELOG, ff-merge, honest caveats; append leftovers to DEFERRED.md. Assume caveman (terse prose) and ponytail (lazy, shortest diff) are active. Trivial edits skip the loop. 'stop staged delivery' to disarm."}}
JSON
exit 0
```

Then add to `~/.claude/settings.json`, pointing at the absolute path where you saved it:

```json
{
    "hooks": {
        "UserPromptSubmit": [
            {
                "hooks": [
                    {
                        "type": "command",
                        "command": "bash \"$HOME/.config/staged-delivery/reinforce.sh\"",
                        "timeout": 5
                    }
                ]
            }
        ]
    }
}
```
