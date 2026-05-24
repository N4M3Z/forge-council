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
