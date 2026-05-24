# Copilot Instructions for forge-council

## What This Project Does

forge-council is a pure-markdown multi-agent orchestration framework for Claude Code. It provides 13 specialist agents that run 3-round debates on topics, organized into four council types:
- **DeveloperCouncil**: Code review, architecture, debugging (6 dev specialists)
- **ProductCouncil**: Requirements, features, strategy (PM, Designer, Dev, Analyst)
- **Council**: Cross-domain debate (Architect, Designer, Developer, Researcher)
- **KnowledgeCouncil**: Knowledge architecture and memory lifecycle decisions

No compiled code, no external runtimes — only markdown agent definitions, YAML config, shell scripts, and Claude Code skills.

## High-Level Architecture

### Core Components

**agents/** — 13 specialist agents (each a markdown file with YAML frontmatter + structured instructions):
- Developer, Database, DevOps, DocumentationWriter, Tester, SecurityArchitect (dev track)
- Architect, Designer, ProductManager, Analyst (cross-domain)
- Opponent (opus model, devil's advocate)
- Researcher (web search + synthesis)
- ForensicAgent (opus model, PII and secret detection)

Each agent has:
- `claude.*` frontmatter: name (PascalCase), model (sonnet/opus), description, tools list
- Body: Role, Expertise, Instructions, Output Format, Constraints

**skills/** — 5 orchestration skills (each a SKILL.md with debate flow logic):
- `/Council` — generic 3-round debate
- `/DeveloperCouncil` — specialized code/architecture council
- `/ProductCouncil` — specialized product/strategy council
- `/KnowledgeCouncil` — knowledge architecture and memory lifecycle
- `/Demo` — interactive showcase

Each skill is a multi-step process: gate check → parse input → select roster → spawn team → run 3 rounds → synthesize.

**defaults.yaml** — canonical agent roster and council compositions. Do not edit unless adding/removing agents from the default lineup.

**lib/install-agents.sh** — standalone deployment script (from forge-lib submodule). Reads agent markdown from `agents/` and deploys to `~/.claude/agents/`.

**lib/** — git submodule pointing to forge-lib. Provides shared utilities:
- `frontmatter.sh` — YAML frontmatter parsing
- `install-agents.sh` — agent deployment functions

## Build, Test, Verify

No build system, compiler, or test suite. Verification is manual and runs in Claude Code.

### Installation

**Standalone** (Claude Code plugin):
```bash
bash lib/install-agents.sh agents              # install all 13 agents
bash lib/install-agents.sh agents --dry-run    # preview without writing
bash lib/install-agents.sh agents --clean      # remove old agents, then install
```

**As forge-core module**:
```bash
Hooks/sync-agents.sh   # uses FORGE_LIB env var set by forge-core
```

### Verification

Run the checklist in VERIFY.md:
```bash
# All 13 agents deployed?
ls ~/.claude/agents/{Developer,Database,DevOps,DocumentationWriter,Tester,SecurityArchitect,Architect,Designer,ProductManager,Analyst,Opponent,Researcher,ForensicAgent}.md

# Each agent has synced-from header?
grep -l "^# synced-from:" ~/.claude/agents/{Developer,Database,DevOps,DocumentationWriter,Tester,SecurityArchitect,Architect,Designer,ProductManager,Analyst,Opponent,Researcher,ForensicAgent}.md | wc -l
# Expected: 13

# No stale Council-prefixed agents?
ls ~/.claude/agents/ | grep -i "^Council" || echo "Clean"

# 5 skills discoverable?
ls skills/*/SKILL.md   # Expected: Council, Demo, DeveloperCouncil, KnowledgeCouncil, ProductCouncil

# Interactive check in Claude Code:
/Demo agents
```

### Enable Parallel Council Execution (Optional)

Add to `~/.claude/settings.json`:
```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

With `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`, councils spawn agents in parallel (TeamCreate + Task per agent). Without it, they run sequentially — same verdict, slower. Standalone agents work without any flag.

## Key Conventions

### Agent Markdown Structure

Every agent file (`agents/*.md`) follows this structure:

1. **Frontmatter** (YAML between `---` delimiters):
   - `title`: Human-readable name
   - `description`: What the agent does
   - `claude.name`: PascalCase, must match filename (no .md)
   - `claude.model`: Short form only (`sonnet` or `opus`, never full model ID)
   - `claude.description`: Pattern: `"Role — capabilities. USE WHEN triggers."` (em-dash separated, USE WHEN clause for discoverability)
   - `claude.tools`: Comma-separated list. Options: Read, Grep, Glob, Bash, Write, Edit, WebSearch, WebFetch

2. **Body** (in order):
   - Blockquote summary (one sentence, ends with "Shipped with forge-council.")
   - `## Role` — what the agent does
   - `## Expertise` — bullet list of domain areas
   - `## Personality` (optional, only for Opponent, Researcher, SecurityArchitect)
   - `## Instructions` — detailed steps with `###` subsections
   - `## Output Format` — markdown template in a fenced code block
   - `## Constraints` — bullet list of boundaries

3. **Constraints section rules**:
   - Always end with: "When working as part of a team, communicate findings to the team lead via SendMessage when done"
   - Include honesty clause: "If X is solid, say so — don't manufacture issues/objections/complexity"
   - Every critique must include a concrete suggestion

### Skill Markdown Structure

Every skill (`skills/*/SKILL.md`) has:

1. **Frontmatter** (YAML):
   - `name`: Skill name (matches directory)
   - `description`: Pattern: `"Summary — details. USE WHEN triggers."`
   - `argument-hint`: Usage syntax for the user

2. **Body** — Numbered steps (Step 1 through Step 7/8):
   - Step 1: Gate check (verify `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS`)
   - Step 2: Parse input (topic, optional extras, mode)
   - Step 3: Select roster
   - Step 4: Spawn team (TeamCreate + Task per agent)
   - Step 5: Round 1 — initial positions (50–150 words each)
   - Step 6: Rounds 2–3 — challenges then convergence
   - Step 7: Synthesize verdict + teardown (TeamDelete)
   - Step 8: Sequential fallback (if agent teams unavailable)

3. **Debate modes** (detected from user keywords):
   - Default (none): `checkpoint` — pause after Round 1
   - "autonomous", "fast": `autonomous` — all 3 rounds without stops
   - "interactive", "step by step": `interactive` — pause after every round
   - "quick", "quick check": `quick` — Round 1 only + synthesis

4. **Roster sizing**:
   - Default roster is fixed (e.g., 4 for Council)
   - Optional extras added conditionally (e.g., "with security" → add SecurityArchitect)
   - Maximum roster size: 7

### Shell Script Style

All scripts start with `set -euo pipefail` and follow these patterns:

```bash
SCRIPT_DIR="$(builtin cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULE_ROOT="$(builtin cd "$SCRIPT_DIR/.." && pwd)"
FORGE_LIB="${FORGE_LIB:-$MODULE_ROOT/lib}"  # prefer env var (forge-core), fallback to local

# Check for required files/dirs, exit 1 with user-friendly message
if [ ! -d "$FORGE_LIB" ]; then
  echo "forge-lib not found. Run: git submodule update --init" >&2
  exit 1
fi

source "$FORGE_LIB/frontmatter.sh"  # source, don't execute
```

- **Functions**: `lowercase_snake_case` (e.g., `deploy_agent`)
- **Constants/globals**: `UPPER_SNAKE_CASE` (e.g., `FORGE_LIB`, `AGENTS_SRC`)
- **Functions don't exit** — let the caller decide error handling (unless fatal)

### Configuration

- **defaults.yaml**: Canonical roster and council composition. Edit only when adding/removing agents.
- **config.yaml**: User overrides (gitignored). Same structure as defaults, only include fields you change.
- **module.yaml**: Module metadata (name, version, description). Update `version` on releases.
- **Model selection** lives in agent frontmatter, NOT in YAML config.

### Git Conventions

Conventional Commits: `type: description`. Lowercase, no period. Em-dashes in descriptions are fine.

Types: `feat`, `fix`, `docs`

Examples:
```
feat: add ForensicAgent for PII and secret detection
fix: update forge-lib submodule to GitHub commit abc123
docs: tighten README to match forge-reflect style
```

## When Adding or Modifying

### Adding a New Agent

1. Create `agents/YourAgent.md` with:
   - Correct frontmatter (claude.name, claude.model, tools)
   - Structured body (Role, Expertise, Instructions, Output Format, Constraints)
   - All constraints end with the team communication clause + honesty clause
   
2. Add to `defaults.yaml` roster (council or standalone)

3. Update `INSTALL.md` agent table if it's a major agent (optional for niche specialists)

4. Run the install script to test: `bash lib/install-agents.sh agents --dry-run`

5. Commit with conventional message: `feat: add YourAgent for [domain]`

### Modifying an Existing Skill

1. Edit `skills/SkillName/SKILL.md`
2. Keep the step numbering and structure intact (this is how moderators follow the flow)
3. If changing roster logic, update both the skill steps AND `defaults.yaml`
4. Test with `/Demo` or a council invocation before committing
5. Commit: `feat: improve [skill] debate flow` or similar

### Updating Models or Tools

1. Edit the agent markdown frontmatter (claude.model or claude.tools)
2. Re-run agent deployment:
   ```bash
   bash lib/install-agents.sh agents --clean   # standalone
   # or
   Hooks/sync-agents.sh                 # forge-core
   ```
3. Restart Claude Code for changes to take effect
4. Commit: `fix: update YourAgent model to [new-model]`

## File Organization

```
.github/
  copilot-instructions.md    # this file
agents/
  Developer.md               # 13 specialist agents (markdown + frontmatter)
  Database.md
  DevOps.md
  ForensicAgent.md
  ... (9 more)
skills/
  Council/
    SKILL.md                 # generic 3-round debate orchestration
  DeveloperCouncil/
    SKILL.md                 # code/architecture council
  ProductCouncil/
    SKILL.md                 # product/strategy council
  KnowledgeCouncil/
    SKILL.md                 # knowledge architecture and memory lifecycle
  Demo/
    SKILL.md                 # interactive showcase
lib/
  (forge-lib submodule)      # shared utilities (install-agents.sh, install-skills.sh, etc.)
defaults.yaml                # canonical agent roster + council configs
module.yaml                  # module metadata (name, version)
README.md                     # user-facing overview
INSTALL.md                    # installation guide
VERIFY.md                     # post-install verification checklist
AGENTS.md                     # autogenerated agent reference (don't edit)
GEMINI.md                     # Gemini CLI context (don't edit)
```

## Important Notes

- **Do not edit** AGENTS.md or GEMINI.md directly — these are autogenerated by `/Init` and `/Update` commands in Claude Code.
- **VERIFY.md** is the source of truth for installation checks. Run it after any agent changes.
- **No external test suite** — all verification is manual and runs in Claude Code.
- **No build step** — deployment is just `bash lib/install-agents.sh agents`, which copies markdown files to `~/.claude/agents/`.
- **Model assignments** are all in agent frontmatter (`claude.model: sonnet` or `opus`). Opponent, SecurityArchitect, and ForensicAgent use `opus`; all others use `sonnet`.
