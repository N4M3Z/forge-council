# AGENTS.md -- forge-council

> Pure-markdown multi-agent orchestration for Claude Code. Twelve specialists,
> three councils, structured 3-round debates. No compiled code -- only markdown
> agent definitions, YAML configuration, shell scripts, and Claude Code skills.

## Build / Install / Verify

No build system, compiler, or bundler. The only "build" is deploying agent
markdown files to `~/.claude/agents/`.

```bash
make install            # install agents + skills
make install-agents     # install agents only to ~/.claude/agents/
make install-skills     # install skills to ~/.claude/skills, ~/.gemini/skills, ~/.codex/skills
make install-skills-claude  # install skills only to ~/.claude/skills/
make install-skills-gemini  # install skills only to ~/.gemini/skills/
make install-skills-codex   # install skills only to ~/.codex/skills/
make clean              # remove previously installed agents
make verify             # run verification checks from VERIFY.md

bash bin/install-agents.sh            # standalone install (no Make)
bash bin/install-agents.sh --dry-run  # preview without writing
bash bin/install-agents.sh --clean    # clean old agents then reinstall
```

No automated tests, linter, or CI pipeline. Verification is manual per
`VERIFY.md` (check 12 agents in `~/.claude/agents/`, 4 skills, synced-from
headers). Run `make verify` for a quick sanity check.

## Project Structure

```
agents/              # 13 agent definitions (12 rostered + ForensicAgent)
bin/                 # install-agents.sh (standalone deployment)
lib/                 # git submodule -> forge-lib (shell utilities)
skills/              # 5 skill dirs: Council, Demo, DeveloperCouncil, ProductCouncil, KnowledgeCouncil
defaults.yaml        # Agent roster + council composition (committed)
config.yaml          # User overrides (gitignored, same structure as defaults)
module.yaml          # Module metadata (name, version, description)
.claude-plugin/      # plugin.json manifest for Claude Code
.github/copilot-instructions.md  # Copilot rules (detailed architecture guide)
```

## Agent Markdown Files (`agents/*.md`)

### Frontmatter (YAML between `---` delimiters)

Required keys: `title`, `description`, `claude.name`, `claude.model`,
`claude.description`, `claude.tools`.

```yaml
---
title: Developer
description: Senior developer specialist for implementation quality, patterns, and correctness
claude.name: Developer
claude.model: sonnet
claude.description: "Senior developer specialist -- implementation quality, patterns, correctness. USE WHEN code review, implementation quality, design patterns, refactoring assessment."
claude.tools: Read, Grep, Glob, Bash, Write, Edit
---
```

### Tool and model assignments

| Tools | Agents |
|-------|--------|
| `Read, Grep, Glob` | Architect, Designer, DocumentationWriter, Opponent |
| `Read, Grep, Glob, Bash` | Database, DevOps, SecurityArchitect, ForensicAgent |
| `Read, Grep, Glob, Bash, Write, Edit` | Developer, Tester |
| `Read, Grep, Glob, WebSearch, WebFetch` | Researcher, ProductManager, Analyst |

All agents use `sonnet` except `Opponent` which uses `opus`.

### Body structure (in order)

1. Blockquote summary (one sentence, ends with "Shipped with forge-council.")
2. `## Role`, `## Expertise`, `## Personality` (optional -- Opponent, Researcher, SecurityArchitect only)
3. `## Instructions` -- detailed steps with `###` subsections
4. `## Output Format` -- markdown template in a fenced code block
5. `## Constraints` -- bullet list; must include the honesty clause ("If X is
   solid, say so -- don't manufacture issues") and team communication clause
   ("communicate findings to the team lead via SendMessage when done");
   every critique must include a concrete suggestion

## Skill Files (`skills/*/SKILL.md` + `skills/*/SKILL.yaml`)

`SKILL.md` contains the behavior/instructions. `SKILL.yaml` contains metadata and
provider routing (`claude`, `gemini`, `codex`).

Required metadata keys in `SKILL.yaml`: `name`, `description`, `argument-hint`,
and `providers.*.enabled` for each supported runtime. Body in `SKILL.md` is numbered
steps (Step 1 through 7/8). All council skills follow: gate check, parse input,
select roster, spawn team, 3 debate rounds, synthesize + teardown, sequential
fallback. Main session IS the moderator (never spawn one). Maximum roster size 7.

| Keyword | Mode | Behavior |
|---------|------|----------|
| _(none)_ | checkpoint | Pause after Round 1 for user input |
| "autonomous" | autonomous | All 3 rounds without interruption |
| "interactive" | interactive | Pause after every round |
| "quick" | quick | Round 1 only + synthesis |

## Naming Conventions

| Context | Convention | Examples |
|---------|-----------|---------|
| Agent filenames | `PascalCase.md` | `Developer.md`, `SecurityArchitect.md` |
| `claude.name` | PascalCase, matches filename | `Developer`, `SecurityArchitect` |
| `claude.model` | lowercase short form | `sonnet`, `opus` |
| Skill directories | PascalCase | `Council/`, `DeveloperCouncil/` |
| Skill files | Always `SKILL.md` | `skills/Council/SKILL.md` |
| Skill metadata | Always `SKILL.yaml` | `skills/Council/SKILL.yaml` |
| Shell functions | `lowercase_snake_case` | `fm_value`, `deploy_agent` |
| Shell constants | `UPPER_SNAKE_CASE` | `FORGE_LIB`, `AGENTS_SRC` |
| YAML keys | lowercase | `developer`, `generic`, `product` |
| Team names (runtime) | lowercase-kebab | `council`, `dev-council` |

## Shell Scripts

- Shebang: `#!/usr/bin/env bash`; start with `set -euo pipefail`
- Resolve paths: `SCRIPT_DIR="$(builtin cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"`
- Source libraries, don't execute: `source "$FORGE_LIB/frontmatter.sh"`
- Check for required files/dirs before proceeding, `exit 1` with user-friendly message
- Argument parsing via `for arg in "$@"; do case "$arg" in ...`
- Local variables in functions declared with `local`
- Functions don't exit -- let the caller decide error handling (unless fatal)

forge-lib submodule (`lib/`) provides: `frontmatter.sh` (`fm_value`, `fm_body`),
`install-agents.sh` (`deploy_agent`, `deploy_agents_from_dir`),
`strip-front.sh` (`strip_front [--keep key1,key2] file.md`).

## YAML Configuration

- `defaults.yaml` -- canonical roster. Edit only when adding/removing agents.
- `config.yaml` -- user overrides (gitignored). Same structure, only changed fields.
- `module.yaml` -- module metadata. Update `version` on releases.
- Two-space indentation, unquoted string values, PascalCase agent names.
- Model selection lives in agent frontmatter, NOT in YAML config.

## Markdown Style

- Em-dashes (`--`) in prose and descriptions (not `---`)
- `claude.description` pattern: `"Role summary -- capabilities. USE WHEN triggers."`
- Blockquotes for one-line summaries; fenced code blocks for output templates
- No trailing whitespace; files end with a newline

## Modification Workflows

**Adding a new agent:** Create `agents/YourAgent.md` with correct frontmatter
and structured body (Role, Expertise, Instructions, Output Format, Constraints).
Add to `defaults.yaml` roster. Run `bash bin/install-agents.sh --dry-run` to
test. Commit: `feat: add YourAgent for [domain]`.

**Modifying a skill:** Edit `skills/SkillName/SKILL.md`. Keep step numbering
intact. If changing roster logic, update both the skill AND `defaults.yaml`.
Test with `/Demo` or a council invocation before committing.

**Updating models or tools:** Edit agent frontmatter (`claude.model` or
`claude.tools`), then re-deploy with `bash bin/install-agents.sh --clean`.
Restart Claude Code for changes to take effect.

## Git Conventions

Conventional Commits: `type: description`. Lowercase, no trailing period, no
scope. Em-dashes in descriptions are fine. Types: `feat`, `fix`, `docs`.

```
feat: add ForensicAgent for PII and secret detection
fix: update forge-lib submodule to GitHub commit
docs: tighten README to match forge-reflect style
```
