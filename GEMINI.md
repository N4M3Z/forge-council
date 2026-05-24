# GEMINI.md - forge-council Context

This directory contains **forge-council**, a multi-agent orchestration framework designed for Claude Code and the Gemini CLI. It enables structured, multi-perspective debates among specialist agents to provide high-quality reviews, architectural decisions, and strategy recommendations.

## Project Overview

- **Purpose:** Provide a framework for "councils" of AI agents to debate topics across three rounds: Initial Positions, Challenges, and Convergence.
- **Architecture:**
    - **Agents (`agents/`):** 13 specialized Markdown-defined agents (e.g., Developer, ForensicAgent, Architect, Researcher, Opponent).
    - **Skills (`skills/`):** Orchestration logic (prompts) that guide the "lead" agent through the debate process for specific council types.
    - **Configuration (`defaults.yaml`):** Defines default agent rosters, council compositions, and specialist-specific tool overrides (sidecars), including provider-specific model tiers and whitelists.
    - **Ecosystem:** Part of the "forge" suite of tools, intended to be used as a standalone plugin or a forge-core module.

## Key Councils & Skills

- `/Council`: Generic cross-domain debate (Architect, Designer, Developer, Researcher).
- `/DeveloperCouncil`: Specialized for code review, architecture, and debugging (up to 6 dev-focused specialists).
- `/ProductCouncil`: Focused on requirements, strategy, and business impact (PM, Designer, Developer, Analyst).
- `/Demo`: An interactive showcase of the framework's capabilities.

## Getting Started & Commands

### Installation
To install the specialist agents and skills into your local project environment (default):
```bash
make install
```
*Note: This targets `.gemini/agents/` and `.gemini/skills/` within your current directory (`SCOPE=workspace`).*

To install globally for your user (available in all projects):
```bash
make install SCOPE=user
```
*Note: This targets `~/.claude/agents/`, `~/.gemini/agents/`, `~/.claude/skills/`, and `~/.gemini/skills/`.*

### Configuration (Gemini CLI)
Sub-agents must be explicitly enabled in `~/.gemini/settings.json` (or `.gemini/settings.json` for local config):
```json
{
  "experimental": { "enableAgents": true }
}
```

### Discovery & Verification
Invoke a council or specialist by using its name or slash command. If they don't appear, refresh the session:
- **Claude Code**: Restart the session.
- **Gemini CLI**: Run `/agents refresh` (or `/skills reload`) and `/agents list` (or `/skills list`).

## Development Conventions

- **Agent Definitions:** Agents are defined in `agents/*.md` using YAML frontmatter for metadata (name, model, description, tools) and Markdown for behavioral instructions (Role, Expertise, Constraints).
- **Skill Definitions:** Skills in `skills/*/SKILL.md` define the orchestration logic. They follow a standard multi-step process: Gate Check -> Parse Input -> Select Specialists -> Spawn Team -> 3-Round Debate -> Synthesis.
- **Agent Teams:** The framework prefers using the `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` feature for parallel agent execution. If disabled, it falls back to sequential task execution.
- **Modularity:** Avoid hardcoding rosters in skills; refer to `defaults.yaml` or allow the lead to select relevant specialists based on the task context.

## Model Resolution & Whitelisting

When deploying agents for Gemini, the installation script:
1.  **Resolves Tiers**: Uses Gemini-specific model tiers (e.g., `gemini_fast`, `gemini_strong`) defined in `defaults.yaml` or `config.yaml`. Falls back to global `fast`/`strong` if provider-specific tiers are not found.
2.  **Whitelists Models**: Filters out Claude-specific model names. Only models explicitly whitelisted for Gemini in the sidecar file are included in the generated agent frontmatter. This prevents cross-provider model contamination.
3.  **Overrides**: Agent-specific model settings in `agents/*.md` or `config.yaml` (sidecars) take precedence.

