# forge-council — Installation

> **For AI agents**: This guide covers installation of forge-council. Follow the steps for your deployment mode.

## As part of forge-core (submodule)

Already included as a submodule. Deploy agents with:

```bash
Hooks/sync-agents.sh
```

Restart Claude Code for agents to be available. forge-lib is provided by the parent project via `FORGE_LIB` env var — the module's own `lib/` submodule is not used when running inside forge-core.

## Standalone (Claude Code plugin)

### 1. Clone with submodules

```bash
git clone --recurse-submodules https://github.com/N4M3Z/forge-council.git
```

Or if already cloned:

```bash
git submodule update --init
```

This checks out [forge-lib](https://github.com/N4M3Z/forge-lib) into `lib/`, providing shared utilities for agent deployment.

### 2. Deploy agents

```bash
bash bin/install-agents.sh
```

This reads agent files from `agents/` and installs them to `~/.claude/agents/`.

Use `--dry-run` to preview without writing, `--clean` to remove existing forge-council agents first.

### 3. Enable agent teams (optional)

Add to `~/.claude/settings.json`:

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

Without this flag, `/DeveloperCouncil` falls back to sequential subagent calls — same specialists, same verdict, just slower. Standalone agents work without any flags.

### 4. Restart Claude Code

Agents require a session restart to be discovered.

## What gets installed

| Agent | Model | Purpose |
|-------|-------|---------|
| Developer | sonnet | Implementation quality, patterns, correctness |
| Database | sonnet | Schema design, query performance, migrations |
| DevOps | sonnet | CI/CD, deployment, monitoring, reliability |
| DocumentationWriter | sonnet | README quality, API docs, developer experience |
| Tester | sonnet | Test strategy, coverage, edge cases, regression |
| SecurityArchitect | sonnet | Threat modeling, security policy, architectural risk |
| Opponent | opus | Devil's advocate, stress-test ideas and decisions |
| Researcher | sonnet | Deep web research, multi-query synthesis, citations |

No compiled binaries — forge-council is pure markdown orchestration. Agents are markdown files deployed to `~/.claude/agents/`.

## Configuration

### defaults.yaml

Ships with the agent roster and council composition:

```yaml
agents:
  council:
    - Developer
    - Database
    - DevOps
    - DocumentationWriter
    - Tester
    - SecurityArchitect
  standalone:
    - Opponent
    - Researcher
```

### Module config override

Create `config.yaml` (gitignored) to override:

```yaml
# Example: remove a specialist from the council roster
agents:
  council:
    - Developer
    - Tester
    - DevOps
```

Model selection lives in agent frontmatter (`agents/*.md`). To change a model, edit the agent file and re-run the agent sync.

## Updating

```bash
git pull --recurse-submodules    # update module + forge-lib
bin/install-agents.sh --clean    # re-deploy agents (removes old, installs new)
```

## Dependencies

| Dependency | Required | Purpose |
|-----------|----------|---------|
| forge-lib | Yes (standalone) | Shared agent deployment utilities |
| Agent teams flag | Optional | Parallel council spawning (sequential fallback without) |

No Rust toolchain needed. No external runtime dependencies.

## Verify

See [VERIFY.md](VERIFY.md) for the post-installation checklist.
