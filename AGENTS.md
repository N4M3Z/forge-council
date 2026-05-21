# AGENTS.md -- forge-council

> Pure-markdown multi-agent orchestration for Claude Code, Codex, Gemini CLI, and OpenCode. Specialist agents, council orchestration skills, structured 3-round debates. No compiled code -- only markdown agent definitions, YAML configuration, and council orchestration skills.

## Build / Install / Verify

No compiler or bundler. The `forge` CLI assembles source content into `build/` then deploys it to provider directories (`.claude/`, `.codex/`, `.gemini/`, `.opencode/`).

```sh
make install         # forge install -- assemble + deploy for every provider
make validate        # bash .githooks/pre-commit -- prek -> forge validate -> validate.sh fallback
make clean           # rm -rf build/
```

To install at user scope instead of the workspace:

```sh
forge install --target ~
```

Single-provider install:

```sh
forge install --provider claude
```

## Project Structure

```
agents/              specialist markdown files
skills/              6 council orchestration skills
rules/               always-loaded behavioural rules (AgentTeams, LearningCapture)
defaults.yaml        canonical roster + tool/model assignments (committed)
config.yaml          user overrides (gitignored, same structure as defaults)
module.yaml          module metadata
.claude-plugin/      plugin.json for Claude Code plugin discovery
.githooks/           pre-commit hook
.pre-commit-config.yaml
.gitleaks.toml
.gitattributes
.github/workflows/   quality.yaml (prek-action CI)
```

## Agent Markdown Files (`agents/*.md`)

### Frontmatter

Required keys: `name` (PascalCase, matches filename), `description`, `version`.

Deployment config (model, tools) lives in `defaults.yaml`, not in agent frontmatter.

```yaml
---
name: SoftwareDeveloper
description: "Senior developer specialist -- implementation quality, patterns, correctness. USE WHEN code review, implementation quality, design patterns, refactoring assessment."
version: 0.3.0
---
```

### Tool and model assignments (from `defaults.yaml`)

| Tools | Agents |
|-------|--------|
| `Read, Grep, Glob` | SystemArchitect, UxDesigner, DocumentationWriter, HiringManager, ExecutiveAdvisor |
| `Read, Grep, Glob, WebSearch` | TheOpponent, CzechLawAdvisor |
| `Read, Grep, Glob, Bash` | DatabaseEngineer, DevOpsEngineer |
| `Read, Grep, Glob, Bash, WebSearch` | SecurityArchitect, ForensicAgent |
| `Read, Grep, Glob, Bash, Write, Edit, WebSearch` | SoftwareDeveloper, QaTester |
| `Read, Grep, Glob, WebSearch, WebFetch` | WebResearcher, ProductManager, DataAnalyst, TalentAcquisition, CompensationAnalyst, IndustryExpert |

Model tiers (`fast` / `strong`) live in `defaults.yaml`. Override per agent in `config.yaml`.

### Body structure

1. Blockquote summary (one sentence, ends with "Shipped with forge-council.").
2. `## Role`, `## Expertise`, optional `## Personality` (TheOpponent, WebResearcher, SecurityArchitect).
3. `## Instructions` -- detailed steps with `###` subsections.
4. `## Output Format` -- markdown template in a fenced code block.
5. `## Constraints` -- bullet list. Must include the honesty clause ("If X is solid, say so -- don't manufacture issues") and team communication clause ("communicate findings to the team lead via SendMessage when done"). Every critique must include a concrete suggestion.

## Skill Files (`skills/*/SKILL.md`)

Council skills (DebateCouncil, DeveloperCouncil, ProductCouncil, KnowledgeCouncil, HiringCouncil) follow the same numbered flow:

| Step | Purpose |
|------|---------|
| Step 0 | Gate check -- inspect `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` |
| Step 1 | Parse input (topic, optional extras, debate mode) |
| Step 2 | Select roster (max 7) |
| Step 3 | `TeamCreate` + parallel `Task` per specialist |
| Step 4 | Round 1: initial positions |
| Step 5 | Rounds 2 and 3: challenges + convergence |
| Step 6 | Synthesise verdict, `shutdown_request`, `TeamDelete` |
| Step 7 | Sequential fallback when teams unavailable |

Debate modes detected from user keywords:

| Keyword | Mode | Behaviour |
|---------|------|-----------|
| _(none)_ | checkpoint | Pause after Round 1 |
| "autonomous", "fast" | autonomous | Run all 3 rounds without interruption |
| "interactive", "step by step" | interactive | Pause after every round |
| "quick", "quick check" | quick | Round 1 only plus synthesis |

The main session is the moderator -- never spawn a `council-moderator` agent. Maximum roster size is 7.

## Rules (`rules/*.md`)

Always-loaded behavioural instructions deployed to `~/.claude/rules/` (or workspace equivalent):

- `AgentTeams.md`: gate-check protocol, mandatory teardown sequence (`shutdown_request` -> verify exit -> `TeamDelete`), known upstream bugs around `TeamCreate` / `TeamDelete` (#49671, #53160, #55824, #59717).
- `LearningCapture.md`: post-teardown spawning of a `general-purpose` Task that distils verdicts into reusable rules.

## Naming Conventions

| Context | Convention | Examples |
|---------|-----------|----------|
| Agent filenames | PascalCase.md | `SoftwareDeveloper.md`, `SecurityArchitect.md` |
| Skill directories | PascalCase | `DebateCouncil/`, `DeveloperCouncil/` |
| Skill files | `SKILL.md` | `skills/DebateCouncil/SKILL.md` |
| Rule filenames | PascalCase.md | `AgentTeams.md`, `LearningCapture.md` |
| YAML keys | lowercase | `agents:`, `providers:` |
| Team names (runtime) | lowercase-kebab | `council`, `dev-council` |

## YAML Configuration

- `defaults.yaml` -- canonical roster, tool/model assignments per agent, provider model tiers. Edit when adding or removing agents.
- `config.yaml` -- user overrides (gitignored). Same structure, only the fields you change.
- `module.yaml` -- module metadata. Update `version` on releases.

## Markdown Style

- Em-dashes (`--`) in prose and descriptions.
- `description` pattern: `"Role summary -- capabilities. USE WHEN triggers."`.
- Blockquotes for one-line summaries; fenced code blocks for output templates.
- No trailing whitespace; files end with a newline.

## Modification Workflows

**Adding a new agent**: Create `agents/YourAgent.md` with frontmatter and structured body. Add an `agents.YourAgent` entry to `defaults.yaml`. Run `forge assemble` to preview, then `make install`. Commit: `feat: add YourAgent for [domain]`.

**Modifying a skill**: Edit `skills/SkillName/SKILL.md`. Keep the numbered step structure intact. The roster lives inside each skill -- there is no central roster section in `defaults.yaml`. Test with a council invocation.

**Updating models or tools**: Edit `defaults.yaml` under `agents:` (or `config.yaml` for local overrides). Run `make install` and restart your session.

## Git Conventions

Conventional Commits: `type: description`. Lowercase, no trailing period, no scope. Types: `feat`, `fix`, `docs`, `chore`, `refactor`, `test`.

```
feat: add ForensicAgent for PII and secret detection
fix: correct model IDs in defaults.yaml providers
docs: tighten README to match forge-core style
```
