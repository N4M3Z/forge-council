# GEMINI.md - forge-council Context

This directory contains **forge-council**, a multi-agent orchestration framework for Claude Code, Codex, the Gemini CLI, and OpenCode. It enables structured multi-perspective debates among specialist agents for high-quality reviews, architectural decisions, and strategy recommendations.

## Project Overview

- **Purpose:** Provide "councils" of AI agents that debate topics across three rounds: Initial Positions, Challenges, and Convergence.
- **Architecture:**
    - **Agents (`agents/`):** Specialists across implementation, architecture, security, research, product, and hiring tracks (SoftwareDeveloper, SecurityArchitect, SystemArchitect, WebResearcher, TheOpponent, plus the hiring roster among others).
    - **Skills (`skills/`):** Council orchestration prompts that guide the lead agent through the debate. One skill per council type.
    - **Rules (`rules/`):** Always-loaded behavioural instructions covering agent-team gate checks and post-council learning capture.
    - **Configuration (`defaults.yaml`):** Canonical roster, per-agent tool assignments, provider-specific model tiers.
    - **Deployment:** Handled entirely by the external `forge` CLI. No build system inside this repo.

## Key Councils & Skills

- `/DebateCouncil`: Cross-domain debate (SystemArchitect, UxDesigner, SoftwareDeveloper, WebResearcher).
- `/DeveloperCouncil`: Code review, architecture, debugging with a focused set of dev specialists.
- `/ProductCouncil`: Requirements, strategy, business impact (ProductManager, UxDesigner, SoftwareDeveloper, DataAnalyst).
- `/KnowledgeCouncil`: Knowledge architecture and memory lifecycle (DocumentationWriter, SystemArchitect, WebResearcher).
- `/HiringCouncil`: Job postings, role design, compensation, recruitment strategy.

## Getting Started & Commands

### Installation

Install agents, skills, and rules into the local project workspace:

```sh
make install
```

To install at user scope so they are available across all projects:

```sh
forge install --target ~
```

This deploys to `.claude/`, `.codex/`, `.gemini/`, and `.opencode/` (workspace) or the user-level equivalents under `~/`.

### Gemini CLI configuration

Sub-agents must be enabled explicitly in `~/.gemini/settings.json` (or `.gemini/settings.json` for project-local config):

```json
{
    "experimental": { "enableAgents": true }
}
```

### Discovery & Verification

- **Claude Code:** restart the session after `make install`.
- **Gemini CLI:** run `/agents refresh` (or `/skills reload`) followed by `/agents list` (or `/skills list`).

Invoke a council by its slash command (`/DebateCouncil [topic]`) or invoke a specialist directly (`@SoftwareDeveloper review this PR`).

## Development Conventions

- **Agent Definitions:** Each agent in `agents/*.md` has YAML frontmatter for identity (`name`, `description`, `version`) and Markdown for behavioural instructions (Role, Expertise, Instructions, Output Format, Constraints). Deployment config (model, tools) lives in `defaults.yaml`.
- **Skill Definitions:** Each skill in `skills/*/SKILL.md` follows the same numbered flow: Step 0 gate check, parse input, select roster, spawn team, 3 debate rounds, synthesise verdict, sequential fallback.
- **Rules:** `rules/*.md` files deploy to provider rule directories and are always loaded. They cover the agent-team gate, mandatory teardown, and post-council learning capture.
- **Agent Teams:** Councils prefer parallel execution via `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` (Claude Code only). Without the flag they run sequentially via direct `Task` calls.

## Model Resolution

`defaults.yaml` lists per-provider model tiers under `providers.<provider>.models.{fast,strong}`. `forge install` selects the right tier for each agent based on the `model:` field in `defaults.yaml`. Agent-specific overrides in `config.yaml` take precedence.
