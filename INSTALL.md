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

By default, this installs agents and skills into the local project directory for use in the current workspace (`SCOPE=workspace`):

- Agents: `.claude/agents/`, `.gemini/agents/`, `.codex/agents/`
- Skills: `.claude/skills/`, `.gemini/skills/`, `.codex/skills/`

To install globally for your user (available in all projects):

```bash
make install SCOPE=user
```

This installs specialists to `~/.claude/agents/`, `~/.gemini/agents/`, and `~/.codex/agents`, and installs skills for Claude, Gemini, and Codex.

Use `SCOPE=all` to target both workspace and user home directories.

The Makefile automatically initializes and updates the `lib/` submodule if required scripts are missing.

Provider-specific skill installs:

```bash
make install-skills-claude   # ./.claude/skills/ (SCOPE=workspace) or ~/.claude/skills/ (SCOPE=user|all)
make install-skills-gemini   # ~/.gemini/skills/ (uses SCOPE)
make install-skills-codex    # ./.codex/skills/ (SCOPE=workspace) or ~/.codex/skills/ (SCOPE=user|all)
```

### 3. Running Agents in Codex

In Codex, installed specialists are available as sub-agents, but they must be invoked explicitly.

- Standalone specialist: `Task: Developer — [request]`
- Council orchestration: `/Council`, `/DeveloperCouncil`, `/ProductCouncil`, `/KnowledgeCouncil`
- If you do not explicitly ask for a specialist/sub-agent, the main session handles the task directly.

### 4. Enable Agent Teams (Claude Code Only)

If you are using **Claude Code**, you can enable parallel specialist spawning. This feature is not supported in Gemini CLI.

Add to your `~/.claude/settings.json`:
```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

### 5. Running Agents in Gemini CLI

In the Gemini CLI, sub-agents are an experimental feature and must be enabled in your configuration.

Add the following to your `~/.gemini/settings.json` (or via `/settings`):

```json
{
  "experimental": {
    "enableAgents": true
  }
}
```

Once enabled, follow these steps to use your specialists:

1.  **Discovery**: Run `/agents refresh` (or `/skills reload`) to force a re-scan of the installed specialists.
2.  **Verification**: Run `/agents list` (or `/skills list`) to see all available specialists (Developer, Architect, etc.) and council commands.
3.  **Usage**: To launch a specialist standalone, use `/agents run <name> [query]`. You can also invoke councils via their slash commands (e.g., `/DeveloperCouncil` or `/Demo`).
4.  **Councils**: Since Gemini CLI does not support parallel `TeamCreate`, council skills will run in **Sequential Simulation Mode**, where the lead agent adopts the specialists' personas one by one.

### 6. Verification
Run `/Demo agents` to verify that all 12 specialists are correctly recognized by your current CLI.

Agents require a session restart to be discovered.

## What gets installed

| Agent | Model | Council | Purpose |
|-------|-------|---------|---------|
| Developer | fast | dev, generic | Implementation quality, patterns, correctness |
| Database | fast | dev | Schema design, query performance, migrations |
| DevOps | fast | dev | CI/CD, deployment, monitoring, reliability |
| DocumentationWriter | fast | dev | README quality, API docs, developer experience |
| Tester | fast | dev | Test strategy, coverage, edge cases, regression |
| SecurityArchitect | strong | dev | Threat modeling, security policy, architectural risk |
| Architect | fast | generic | System design, boundaries, scalability, trade-offs |
| Designer | fast | generic, product | UX, user needs, accessibility, interaction design |
| ProductManager | fast | product | Requirements clarity, roadmap alignment, market fit |
| Analyst | fast | product | Success metrics, KPIs, measurement, business impact |
| Opponent | strong | standalone | Devil's advocate, stress-test ideas and decisions |
| Researcher | fast | standalone | Deep web research, multi-query synthesis, citations |
| ForensicAgent | strong | standalone | PII and secret detection forensic specialist |

No compiled binaries — forge-council is pure markdown orchestration. Agents are markdown files deployed by scope across `.claude/.gemini/.codex` (workspace) and/or `~/.claude/~/.gemini/~/.codex` (user/all).

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
