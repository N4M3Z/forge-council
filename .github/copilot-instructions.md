# Copilot Instructions for forge-council

## What This Project Does

forge-council is a pure-markdown multi-agent orchestration framework. It provides 13 specialist agents that run 3-round debates on topics, organized into four council types:
- **DeveloperCouncil**: Code review, architecture, debugging (6 dev specialists)
- **ProductCouncil**: Requirements, features, strategy (PM, Designer, Dev, Analyst)
- **DebateCouncil**: Cross-domain debate (SystemArchitect, UxDesigner, SoftwareDeveloper, WebResearcher)
- **KnowledgeCouncil**: Knowledge architecture and memory lifecycle decisions

No compiled code -- only markdown agent definitions, YAML configuration, and skills. Deployment uses Rust binaries from the forge-lib submodule.

## High-Level Architecture

### Core Components

**agents/** -- 13 specialist agents (each a markdown file with YAML frontmatter + structured instructions):
- SoftwareDeveloper, DatabaseEngineer, DevOpsEngineer, DocumentationWriter, QaTester, SecurityArchitect (dev track)
- SystemArchitect, UxDesigner, ProductManager, DataAnalyst (cross-domain)
- TheOpponent (strong model, devil's advocate)
- WebResearcher (web search + synthesis)
- ForensicAgent (strong model, PII and secret detection)

Each agent has:
- Frontmatter: `name` (PascalCase), `description`, `version`
- Deployment config (model, tools, scope) in `defaults.yaml`
- Body: Role, Expertise, Instructions, Output Format, Constraints

**skills/** -- 5 orchestration skills (each a directory with SKILL.md + SKILL.yaml):
- `/DebateCouncil` -- generic 3-round debate
- `/DeveloperCouncil` -- specialized code/architecture council
- `/ProductCouncil` -- specialized product/strategy council
- `/KnowledgeCouncil` -- knowledge architecture and memory lifecycle
- `/Demo` -- interactive showcase

**defaults.yaml** -- canonical agent roster, council compositions, and provider config. Single source of truth for deployment (model tiers, tools, scope).

**lib/** -- git submodule pointing to forge-lib. Provides Rust binaries:
- `bin/install-agents` -- multi-provider agent deployment
- `bin/install-skills` -- provider-aware skill installer
- `bin/validate-module` -- convention test suite

## Build, Test, Verify

```bash
make install          # deploy agents + skills for all providers (SCOPE=workspace|user|all)
make verify           # check agents deployed + skills present
make verify-skills    # verify skills across all runtimes
make test             # run module validation (validate-module)
make lint             # shellcheck all scripts
make clean            # remove previously installed agents
```

### Installation

**Standalone** (Claude Code plugin):
```bash
git clone --recurse-submodules https://github.com/N4M3Z/forge-council.git
cd forge-council
make install                           # workspace scope (default)
make install SCOPE=user                # user-level (~/.claude/agents/, etc.)
```

The Makefile automatically initializes the forge-lib submodule and builds Rust binaries on first run.

Standalone agent deployment without Make:
```bash
lib/bin/install-agents agents              # install all 13 agents
lib/bin/install-agents agents --dry-run    # preview without writing
lib/bin/install-agents agents --clean      # remove old agents, then install
```

**As forge-core module**:
```bash
Hooks/sync-agents.sh   # uses FORGE_LIB env var set by forge-core
```

### Verification

```bash
make verify            # all agents + skills for current SCOPE
make verify-agents     # 13 agents across claude/gemini/codex
make verify-skills     # skills across claude/gemini/codex/opencode
```

Deployed agents have `source:` frontmatter field pointing back to the source file.

Interactive check: `/Demo agents` in Claude Code to verify all specialists are recognized.

### Enable Parallel Council Execution (Optional)

Add to `~/.claude/settings.json`:
```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

With this flag, councils spawn agents in parallel (TeamCreate + Task per agent). Without it, they run sequentially -- same verdict, slower.

## Key Conventions

### Agent Markdown Structure

Every agent file (`agents/*.md`) follows this structure:

1. **Frontmatter** (YAML between `---` delimiters):
   - `name`: PascalCase, must match filename (no .md)
   - `description`: Pattern: `"Role -- capabilities. USE WHEN triggers."` (USE WHEN clause for discoverability)
   - `version`: Semantic version (e.g., `0.3.0`)

   Deployment config (model, tools, scope) lives in `defaults.yaml`, NOT in agent frontmatter.

2. **Body** (in order):
   - Blockquote summary (one sentence, ends with "Shipped with forge-council.")
   - `## Role` -- what the agent does
   - `## Expertise` -- bullet list of domain areas
   - `## Personality` (optional, only for TheOpponent, WebResearcher, SecurityArchitect)
   - `## Instructions` -- detailed steps with `###` subsections
   - `## Output Format` -- markdown template in a fenced code block
   - `## Constraints` -- bullet list of boundaries

3. **Constraints section rules**:
   - Always end with: "When working as part of a team, communicate findings to the team lead via SendMessage when done"
   - Include honesty clause: "If X is solid, say so -- don't manufacture issues/objections/complexity"
   - Every critique must include a concrete suggestion

### Skill Structure

Every skill (`skills/*/`) has:
- `SKILL.md` -- orchestration instructions (multi-step debate flow)
- `SKILL.yaml` -- metadata and provider routing (claude, gemini, codex)

Skills follow numbered steps (Step 1-7/8). Debate modes detected from user keywords: checkpoint (default), autonomous ("fast"), interactive ("step by step"), quick ("quick check").

### Configuration

- **defaults.yaml**: Canonical roster, council composition, and provider config. Edit only when adding/removing agents or changing default model tiers.
- **config.yaml**: User overrides (gitignored). Same structure as defaults, only include fields you change.
- **module.yaml**: Module metadata (name, version, description). Update `version` on releases.

Provider-specific model tiers and whitelists live in `defaults.yaml` under `providers:`:

```yaml
providers:
    claude:
        fast: claude-sonnet-4-6
        strong: claude-opus-4-6
    gemini:
        fast: gemini-2.0-flash
        strong: gemini-2.5-pro
```

### Tool Assignments

| Tools | Agents |
|-------|--------|
| Read, Grep, Glob | SystemArchitect, UxDesigner, DocumentationWriter |
| Read, Grep, Glob, WebSearch | TheOpponent |
| Read, Grep, Glob, Bash | DatabaseEngineer, DevOpsEngineer |
| Read, Grep, Glob, Bash, WebSearch | SecurityArchitect, ForensicAgent |
| Read, Grep, Glob, Bash, Write, Edit, WebSearch | SoftwareDeveloper, QaTester |
| Read, Grep, Glob, WebSearch, WebFetch | WebResearcher, ProductManager, DataAnalyst |

### Git Conventions

Conventional Commits: `type: description`. Lowercase, no period, no scope.

Types: `feat`, `fix`, `docs`

Examples:
```
feat: add ForensicAgent for PII and secret detection
fix: correct model IDs in defaults.yaml providers
docs: rewrite copilot-instructions for current architecture
```

## When Adding or Modifying

### Adding a New Agent

1. Create `agents/YourAgent.md` with frontmatter (name, description, version) + structured body (Role, Expertise, Instructions, Output Format, Constraints)
2. Add deployment config to `defaults.yaml` under `agents:` (model tier, tools)
3. If joining a council, add to `defaults.yaml` `skills.*.roles` and update the corresponding `skills/*/SKILL.md`
4. Preview: `lib/bin/install-agents agents --dry-run`
5. Commit: `feat: add YourAgent for [domain]`

### Modifying an Existing Skill

1. Edit `skills/SkillName/SKILL.md` + `SKILL.yaml`
2. Keep step numbering intact (moderators follow the numbered flow)
3. If changing roster, update both the skill and `defaults.yaml` `skills.*.roles`
4. Test with `/Demo` or a council invocation
5. Commit: `feat: improve [skill] debate flow`

### Updating Models or Tools

1. Edit `defaults.yaml` under `agents:` (or create `config.yaml` for local override)
2. Reinstall: `lib/bin/install-agents agents --clean`
3. Restart session for changes to take effect

## File Organization

```
.github/
  copilot-instructions.md    # this file
agents/                      # 13 specialist markdown files (frontmatter + structured body)
skills/                      # 5 skill dirs: DebateCouncil, Demo, DeveloperCouncil, ProductCouncil, KnowledgeCouncil
lib/                         # git submodule -> forge-lib (Rust binaries for deployment + validation)
defaults.yaml                # canonical agent roster + council compositions + provider config
config.yaml                  # user overrides (gitignored), same structure as defaults
module.yaml                  # module metadata (name, version)
.claude-plugin/              # plugin.json manifest for Claude Code plugin discovery
.claude/                     # generated by `make install` (gitignored, .gitkeep only)
.gemini/                     # generated by `make install` (gitignored, .gitkeep only)
.codex/                      # generated by `make install` (gitignored, .gitkeep only)
.opencode/                   # generated by `make install` (gitignored, .gitkeep only)
README.md                    # user-facing overview
INSTALL.md                   # installation guide
VERIFY.md                    # post-install verification checklist
AGENTS.md                    # autogenerated agent reference (don't edit)
GEMINI.md                    # Gemini CLI context (don't edit)
CLAUDE.md                    # autogenerated by /Init (don't edit)
AgentTeams.md                # agent teams configuration (@ referenced by skills)
```

## Important Notes

- **Do not edit** AGENTS.md, GEMINI.md, or CLAUDE.md directly -- these are autogenerated by `/Init` and `/Update`.
- **VERIFY.md** is the source of truth for installation checks. Run it after any agent changes.
- Platform directories (`.claude/`, `.gemini/`, `.codex/`, `.opencode/`) contain deployed files generated by `make install`. They are gitignored -- never edit directly. Source of truth is `agents/`, `skills/`, and `defaults.yaml`.
- **Model assignments** are in `defaults.yaml` under `agents:`. TheOpponent, SecurityArchitect, and ForensicAgent use `strong` tier; all others use `fast`.
