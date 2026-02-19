# AGENTS.md -- forge-council

> Pure-markdown multi-agent orchestration for Claude Code, Gemini CLI, and Codex.
> Thirteen specialists, four councils, structured 3-round debates. No compiled
> code -- only markdown agent definitions, YAML configuration, and shell scripts.

## Build / Install / Verify

No build system, compiler, or bundler. The only "build" is deploying agent
markdown files via `SCOPE` to provider directories (`.claude/.gemini/.codex`
for workspace, `~/.claude/~/.gemini/~/.codex` for user installs).

```bash
make install            # install agents + skills
make install-agents     # install agents using SCOPE (workspace|user|all) across Claude/Gemini/Codex
make install-codex-agent-config  # Codex compatibility post-processing (temporary Bash implementation) using SCOPE
make install-skills     # install skills using SCOPE across Claude/Gemini/Codex
make install-skills-claude  # install Claude skills using SCOPE
make install-skills-gemini  # install skills only to ~/.gemini/skills/
make install-skills-codex   # install Codex council skills using SCOPE
make verify-skills      # verify skills across Claude, Gemini, and Codex
make verify-codex-agent-config  # verify Codex role TOML/config artifacts
make clean              # remove previously installed agents
make verify             # run verification checks from VERIFY.md

bash lib/install-agents.sh agents            # standalone install (no Make)
bash lib/install-agents.sh agents --dry-run  # preview without writing
bash lib/install-agents.sh agents --clean    # clean old agents then reinstall
```

No automated tests, linter, or CI pipeline. Verification is manual per
`VERIFY.md` plus `make verify`/`make verify-skills`.

## Codex Experimental Features

Codex `/experimental` toggles persist in `~/.codex/config.toml` under
`[features]`.

```toml
[features]
multi_agent = true
apps = true
```

Use CLI helpers to manage persistent state:

```bash
codex features enable multi_agent
codex features enable apps
codex features list
```

Note: one-off CLI overrides (`--enable` / `--disable`) can temporarily override
saved config values for that run.

For Codex, specialists are used as **explicit sub-agents**. Installing agents/skills does not auto-run them. Invoke them directly in prompts (for example: `Task: SoftwareDeveloper — [request]`, `Task: SecurityArchitect — [request]`) or through the council skills.
Codex install flow also generates role config artifacts in `.codex/agents` (`*.toml`, `*.prompt.md`, `forge-council-agents.toml`) and injects a managed block into `.codex/config.toml` (or `~/.codex/config.toml` for `SCOPE=user`).
Current post-processing implementation is intentionally in `scripts/install-agents-codex.sh` for readability; long-term plan is migration into forge-lib Rust installers.

## Project Structure

FIXME: Up-to-date documentation is in CLAUDE.md. In case of conflict consult CLAUDE.md instead.

```
agents/              # 13 agent definitions (12 rostered + ForensicAgent)
lib/                 # git submodule -> forge-lib (shell utilities)
skills/              # 5 skill dirs: DebateCouncil, Demo, DeveloperCouncil, ProductCouncil, KnowledgeCouncil
defaults.yaml        # Agent roster + council composition (committed)
config.yaml          # User overrides (gitignored, same structure as defaults)
module.yaml          # Module metadata (name, version, description)
.claude-plugin/      # plugin.json manifest for Claude Code
.github/copilot-instructions.md  # Copilot rules (detailed architecture guide)
```

## Agent Markdown Files (`agents/*.md`)

### Frontmatter (YAML between `---` delimiters)

Required keys: `name` (PascalCase, matches filename), `description`, `version`.

Deployment config (model, tools, scope) lives in `defaults.yaml`, not in agent frontmatter.

```yaml
---
name: SoftwareDeveloper
description: "Senior developer specialist -- implementation quality, patterns, correctness. USE WHEN code review, implementation quality, design patterns, refactoring assessment."
version: 0.3.0
---
```

### Tool and model assignments (from defaults.yaml)

| Tools | Agents |
|-------|--------|
| `Read, Grep, Glob` | SystemArchitect, UxDesigner, DocumentationWriter |
| `Read, Grep, Glob, WebSearch` | TheOpponent |
| `Read, Grep, Glob, Bash` | DatabaseEngineer, DevOpsEngineer, SecurityArchitect, ForensicAgent |
| `Read, Grep, Glob, Bash, Write, Edit, WebSearch` | SoftwareDeveloper, QaTester |
| `Read, Grep, Glob, WebSearch, WebFetch` | WebResearcher, ProductManager, DataAnalyst |

Model tiers (`fast`/`strong`) and tool assignments live in `defaults.yaml`. Override per-agent with `config.yaml`.

### Body structure (in order)

1. Blockquote summary (one sentence, ends with "Shipped with forge-council.")
2. `## Role`, `## Expertise`, `## Personality` (optional -- TheOpponent, WebResearcher, SecurityArchitect only)
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
| Agent filenames | `PascalCase.md` | `SoftwareDeveloper.md`, `SecurityArchitect.md` |
| `name` | PascalCase, matches filename | `SoftwareDeveloper`, `SecurityArchitect` |
| Skill directories | PascalCase | `DebateCouncil/`, `DeveloperCouncil/` |
| Skill files | Always `SKILL.md` | `skills/DebateCouncil/SKILL.md` |
| Skill metadata | Always `SKILL.yaml` | `skills/DebateCouncil/SKILL.yaml` |
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

forge-lib submodule (`lib/`) provides: `frontmatter.sh` (`fm_value`, `fm_body`,
`fm_list`), `install-agents.sh` (`deploy_agent`, `deploy_agents_from_dir`),
`install-skills.sh` (provider-aware skill installer), `sync-rosters.sh`,
`generate-agent-skills.sh` (specialist wrapper generation helper, not used by default install flow),
`strip-front.sh` (`strip_front [--keep key1,key2] file.md`).

## YAML Configuration

- `defaults.yaml` -- canonical roster. Edit only when adding/removing agents.
- `config.yaml` -- user overrides (gitignored). Same structure, only changed fields.
- Sidecar behavior is implemented via `defaults.yaml` + `config.yaml`.
- `module.yaml` -- module metadata. Update `version` on releases.
- Two-space indentation, unquoted string values, PascalCase agent names.
- Model and tool selection lives in `defaults.yaml`, NOT in agent frontmatter.
- Keep `defaults.yaml` and council skill roster sections in sync. Current council
  runtime selection is defined in `skills/*/SKILL.md`.

## Markdown Style

- Em-dashes (`--`) in prose and descriptions (not `---`)
- `claude.description` pattern: `"Role summary -- capabilities. USE WHEN triggers."`
- Blockquotes for one-line summaries; fenced code blocks for output templates
- No trailing whitespace; files end with a newline

## Modification Workflows

**Adding a new agent:** Create `agents/YourAgent.md` with correct frontmatter
and structured body (Role, Expertise, Instructions, Output Format, Constraints).
Add to `defaults.yaml` roster. Run `bash lib/install-agents.sh agents --dry-run` to
test. Commit: `feat: add YourAgent for [domain]`.

**Modifying a skill:** Edit `skills/SkillName/SKILL.md` and `skills/SkillName/SKILL.yaml`.
Keep step numbering intact. If changing roster logic, update both the skill and
`defaults.yaml`. Test with `/Demo` or a council invocation before committing.

**Updating models or tools:** Edit `defaults.yaml` (or `config.yaml` override),
then re-deploy with `lib/bin/install-agents agents --clean`.
Restart Claude Code for changes to take effect.

## Git Conventions

Conventional Commits: `type: description`. Lowercase, no trailing period, no
scope. Em-dashes in descriptions are fine. Types: `feat`, `fix`, `docs`.

```
feat: add ForensicAgent for PII and secret detection
fix: update forge-lib submodule to GitHub commit
docs: tighten README to match forge-reflect style
```
