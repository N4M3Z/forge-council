# GEMINI.md - forge-council Context

This directory contains **forge-council**, a multi-agent orchestration framework designed for Claude Code and the Gemini CLI. It enables structured, multi-perspective debates among specialist agents to provide high-quality reviews, architectural decisions, and strategy recommendations.

## Project Overview

- **Purpose:** Provide a framework for "councils" of AI agents to debate topics across three rounds: Initial Positions, Challenges, and Convergence.
- **Architecture:**
    - **Agents (`agents/`):** 12 specialized Markdown-defined agents (e.g., Developer, Architect, Researcher, Opponent).
    - **Skills (`skills/`):** Orchestration logic (prompts) that guide the "lead" agent through the debate process for specific council types.
    - **Configuration (`defaults.yaml`):** Defines default agent rosters and council compositions.
    - **Ecosystem:** Part of the "forge" suite of tools, intended to be used as a standalone plugin or a forge-core module.

## Key Councils & Skills

- `/Council`: Generic cross-domain debate (Architect, Designer, Developer, Researcher).
- `/DeveloperCouncil`: Specialized for code review, architecture, and debugging (up to 6 dev-focused specialists).
- `/ProductCouncil`: Focused on requirements, strategy, and business impact (PM, Designer, Developer, Analyst).
- `/Demo`: An interactive showcase of the framework's capabilities.

## Getting Started & Commands

### Installation
To install the specialist agents and skills into your local environment:
```bash
make install
```
*Note: If using forge-core, use `Hooks/sync-agents.sh` instead.*

### Running a Council
Invoke a council by using its skill name followed by your query:
```
/DeveloperCouncil [task description or file paths]
/ProductCouncil [feature spec or strategy question]
/Council [any topic for debate]
```

### Debate Modes
You can control the debate flow by adding keywords to your request:
- **Default (checkpoint):** Pauses after Round 1 for user input.
- **`autonomous` / `fast`:** Runs all 3 rounds without interruption.
- **`interactive` / `step by step`:** Pauses after every round.
- **`quick` / `quick check`:** Runs only Round 1 followed by synthesis.

## Development Conventions

- **Agent Definitions:** Agents are defined in `agents/*.md` using YAML frontmatter for metadata (name, model, description, tools) and Markdown for behavioral instructions (Role, Expertise, Constraints).
- **Skill Definitions:** Skills in `skills/*/SKILL.md` define the orchestration logic. They follow a standard multi-step process: Gate Check -> Parse Input -> Select Specialists -> Spawn Team -> 3-Round Debate -> Synthesis.
- **Agent Teams:** The framework prefers using the `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` feature for parallel agent execution. If disabled, it falls back to sequential task execution.
- **Modularity:** Avoid hardcoding rosters in skills; refer to `defaults.yaml` or allow the lead to select relevant specialists based on the task context.
