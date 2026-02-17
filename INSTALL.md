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

### 2. Deploy agents and skills

```bash
make install
```

This installs specialists to `~/.claude/agents/` and skills to `~/.gemini/skills/`.

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

| Agent | Model | Council | Purpose |
|-------|-------|---------|---------|
| Developer | sonnet | dev, generic | Implementation quality, patterns, correctness |
| Database | sonnet | dev | Schema design, query performance, migrations |
| DevOps | sonnet | dev | CI/CD, deployment, monitoring, reliability |
| DocumentationWriter | sonnet | dev | README quality, API docs, developer experience |
| Tester | sonnet | dev | Test strategy, coverage, edge cases, regression |
| SecurityArchitect | sonnet | dev | Threat modeling, security policy, architectural risk |
| Architect | sonnet | generic | System design, boundaries, scalability, trade-offs |
| Designer | sonnet | generic, product | UX, user needs, accessibility, interaction design |
| ProductManager | sonnet | product | Requirements clarity, roadmap alignment, market fit |
| Analyst | sonnet | product | Success metrics, KPIs, measurement, business impact |
| Opponent | opus | standalone | Devil's advocate, stress-test ideas and decisions |
| Researcher | sonnet | standalone | Deep web research, multi-query synthesis, citations |

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
    - Architect
    - Designer
    - ProductManager
    - Analyst
  standalone:
    - Opponent
    - Researcher

councils:
  developer:
    roles: [Developer, Database, DevOps, DocumentationWriter, Tester, SecurityArchitect]
  generic:
    roles: [Architect, Designer, Developer, Researcher]
  product:
    roles: [ProductManager, Designer, Developer, Analyst]
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
make clean                      # remove old agents
make install                    # reinstall everything
```

## Dependencies

| Dependency | Required | Purpose |
|-----------|----------|---------|
| forge-lib | Yes (standalone) | Shared agent deployment utilities |
| Agent teams flag | Optional | Parallel council spawning (sequential fallback without) |

No Rust toolchain needed. No external runtime dependencies.

## Verify

See [VERIFY.md](VERIFY.md) for the post-installation checklist.
