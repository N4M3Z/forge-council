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
- Skills: `.claude/skills/`, `.gemini/skills/`, `.codex/skills/`, `.opencode/skills/`

To install globally for your user (available in all projects):

```bash
make install SCOPE=user
```

This installs specialists to `~/.claude/agents/`, `~/.gemini/agents/`, and `~/.codex/agents/`, and installs skills for Claude, Gemini, Codex, and OpenCode.

Use `SCOPE=all` to target both workspace and user home directories.

The Makefile automatically initializes the `lib/` submodule on first run if `Cargo.toml` is not found.

Provider-specific skill installs:

```bash
make install-skills-claude    # ./.claude/skills/ (SCOPE=workspace) or ~/.claude/skills/ (SCOPE=user|all)
make install-skills-gemini    # via gemini CLI (skipped if CLI not installed)
make install-skills-codex     # ./.codex/skills/ (SCOPE=workspace) or ~/.codex/skills/ (SCOPE=user|all)
make install-skills-opencode  # ./.opencode/skills/ with kebab-case names (SCOPE=workspace|user|all)
make install-codex-agent-config # Codex compatibility post-processing and .codex/config.toml update (uses SCOPE)
```

Codex install also generates:
- `agents/<Agent>.toml` (model + model_reasoning_effort + prompt_file)
- `agents/<Agent>.prompt.md` (agent prompt body)
- `agents/forge-council-agents.toml` (role manifest merged into `config.toml`)

`config.yaml` overrides are respected for Codex model selection (provider tiers and per-agent model tier), with fallback to `defaults.yaml`.
Current implementation is intentionally in `scripts/install-agents-codex.sh` as a temporary readable fallback; target architecture is migration into forge-lib Rust libraries.

### 3. Running Agents in Codex

In Codex, installed specialists are available as sub-agents, but they must be invoked explicitly.

- Standalone specialist: `Task: SoftwareDeveloper — [request]`
- Council orchestration: `/DebateCouncil`, `/DeveloperCouncil`, `/ProductCouncil`, `/KnowledgeCouncil`
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
2.  **Verification**: Run `/agents list` (or `/skills list`) to see all available specialists (SoftwareDeveloper, SystemArchitect, etc.) and council commands.
3.  **Usage**: To launch a specialist standalone, use `/agents run <name> [query]`. You can also invoke councils via their slash commands (e.g., `/DeveloperCouncil` or `/Demo`).
4.  **Councils**: Since Gemini CLI does not support parallel `TeamCreate`, council skills will run in **Sequential Simulation Mode**, where the lead agent adopts the specialists' personas one by one.

### 6. Verification
Run `/Demo agents` to verify that all 13 specialists are correctly recognized by your current CLI.

Agents require a session restart to be discovered.

## What gets installed

| Agent | Model | Council | Purpose |
|-------|-------|---------|---------|
| SoftwareDeveloper | fast | dev, debate | Implementation quality, patterns, correctness |
| DatabaseEngineer | fast | dev | Schema design, query performance, migrations |
| DevOpsEngineer | fast | dev | CI/CD, deployment, monitoring, reliability |
| DocumentationWriter | fast | dev, knowledge | README quality, API docs, developer experience |
| QaTester | fast | dev | Test strategy, coverage, edge cases, regression |
| SecurityArchitect | strong | dev | Threat modeling, security policy, architectural risk |
| SystemArchitect | fast | debate, knowledge | System design, boundaries, scalability, trade-offs |
| UxDesigner | fast | debate, product | UX, user needs, accessibility, interaction design |
| ProductManager | fast | product | Requirements clarity, roadmap alignment, market fit |
| DataAnalyst | fast | product | Success metrics, KPIs, measurement, business impact |
| TheOpponent | strong | standalone | Devil's advocate, stress-test ideas and decisions |
| WebResearcher | fast | debate, knowledge | Deep web research, multi-query synthesis, citations |
| ForensicAgent | strong | standalone | PII and secret detection forensic specialist |

No compiled binaries — forge-council is pure markdown orchestration. Agents are markdown files deployed by scope across `.claude/`, `.gemini/`, `.codex/` (workspace) and/or `~/` equivalents (user/all). Skills are additionally deployed to `.opencode/skills/` with kebab-case names.

## Configuration

### defaults.yaml

Ships with the agent roster and council composition:

```yaml
agents:
  SoftwareDeveloper:
    model: fast
    tools: Read, Grep, Glob, Bash, Write, Edit, WebSearch
  # ... 12 more agents

skills:
  DeveloperCouncil:
    scope: workspace
    roles:
      - SoftwareDeveloper
      - DatabaseEngineer
      - DevOpsEngineer
      - DocumentationWriter
      - QaTester
      - SecurityArchitect
  DebateCouncil:
    scope: workspace
    roles: [SystemArchitect, UxDesigner, SoftwareDeveloper, WebResearcher]
  ProductCouncil:
    scope: workspace
    roles: [ProductManager, UxDesigner, SoftwareDeveloper, DataAnalyst]
```

### Module config override

Create `config.yaml` (gitignored) to override:

```yaml
# Example: change a specialist's model tier
agents:
  SoftwareDeveloper:
    model: strong
```

Model and tool selection lives in `defaults.yaml`. To change, edit `defaults.yaml` (or `config.yaml` override) and re-run install.

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
