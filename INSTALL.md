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

### 3. Enable Agent Teams (Claude Code Only)

If you are using **Claude Code**, you can enable parallel specialist spawning. This feature is not supported in Gemini CLI.

Add to your `~/.claude/settings.json`:
```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

### 4. Running Agents in Gemini CLI

In the Gemini CLI, sub-agents are managed and viewed using the introspect command. After running `make install`, follow these steps:

1.  **Verification**: Run `/introspect` to see the current session state, including all **loaded sub-agents** (Developer, Architect, etc.).
2.  **Usage**: To interact with a specialist standalone, you can simply refer to them by name in your query, or if a skill facilitates it, use the skill's slash command.
3.  **Councils**: Since Gemini CLI does not support parallel `TeamCreate`, council skills (`/DeveloperCouncil`, `/Council`, etc.) will run in **Sequential Simulation Mode**. The lead agent will adopt the specialists' personas one by one to provide the multi-perspective review.

### 5. Verification
Run `/Demo agents` to verify that all 12 specialists are correctly recognized by your current CLI.

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
| [safety-net](https://github.com/kenryu42/claude-code-safety-net) | Recommended | Blocks destructive commands — see [root INSTALL.md](../../INSTALL.md#recommended-security-tools) |
| shellcheck | Recommended | `brew install shellcheck` — shell script linting |

No Rust toolchain needed. No external runtime dependencies.

## Verify

See [VERIFY.md](VERIFY.md) for the post-installation checklist.
