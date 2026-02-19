# forge-council — Verification

> **For AI agents**: Complete this checklist after installation. Every check must pass before declaring the module installed.

## Quick check

### Global (user)
```bash
ls ~/.claude/agents/{SoftwareDeveloper,DatabaseEngineer,DevOpsEngineer,DocumentationWriter,QaTester,SecurityArchitect,SystemArchitect,UxDesigner,ProductManager,DataAnalyst,TheOpponent,WebResearcher,ForensicAgent}.md
ls ~/.codex/agents/{SoftwareDeveloper,DatabaseEngineer,DevOpsEngineer,DocumentationWriter,QaTester,SecurityArchitect,SystemArchitect,UxDesigner,ProductManager,DataAnalyst,TheOpponent,WebResearcher,ForensicAgent}.md
ls ~/.gemini/agents/{SoftwareDeveloper,DatabaseEngineer,DevOpsEngineer,DocumentationWriter,QaTester,SecurityArchitect,SystemArchitect,UxDesigner,ProductManager,DataAnalyst,TheOpponent,WebResearcher,ForensicAgent}.md
```
(Only if installed with `SCOPE=user` or `SCOPE=all`)

### Local (workspace)
```bash
ls .claude/agents/{SoftwareDeveloper,DatabaseEngineer,DevOpsEngineer,DocumentationWriter,QaTester,SecurityArchitect,SystemArchitect,UxDesigner,ProductManager,DataAnalyst,TheOpponent,WebResearcher,ForensicAgent}.md
ls .gemini/agents/{SoftwareDeveloper,DatabaseEngineer,DevOpsEngineer,DocumentationWriter,QaTester,SecurityArchitect,SystemArchitect,UxDesigner,ProductManager,DataAnalyst,TheOpponent,WebResearcher,ForensicAgent}.md
ls .codex/agents/{SoftwareDeveloper,DatabaseEngineer,DevOpsEngineer,DocumentationWriter,QaTester,SecurityArchitect,SystemArchitect,UxDesigner,ProductManager,DataAnalyst,TheOpponent,WebResearcher,ForensicAgent}.md
```
(Default for `make install`)

Expected: all 13 files present in the targeted directory.

## Agent deployment

```bash
# All 13 agents deployed (check targeted directory)
ls .gemini/agents/ | grep -E "^(SoftwareDeveloper|DatabaseEngineer|DevOpsEngineer|DocumentationWriter|QaTester|SecurityArchitect|SystemArchitect|UxDesigner|ProductManager|DataAnalyst|TheOpponent|WebResearcher|ForensicAgent)\.md$" | wc -l
# Should output: 13

# Each agent has synced-from header
grep -l "^# synced-from:" .gemini/agents/*.md | wc -l
# Should output: 13
```

## Agent frontmatter (Gemini)

```bash
# Verify Gemini agents use whitelisted models (not Claude names)
grep "^model:" .gemini/agents/SoftwareDeveloper.md
# Expected: model: gemini-2.0-flash (or other whitelisted Gemini model)
```

## No stale agents

```bash
# No old Council-prefixed agents remain
ls .gemini/agents/ | grep -i "^Council" || echo "Clean — no stale Council agents"
```

## Skill discovery

```bash
ls skills/*/SKILL.md
# Should list: DebateCouncil, Demo, DeveloperCouncil, ProductCouncil, KnowledgeCouncil
```

## Codex skills

```bash
ls .codex/skills/{DebateCouncil,Demo,DeveloperCouncil,ProductCouncil,KnowledgeCouncil}/SKILL.md
```

Expected: all 5 council skills present after `make install-skills-codex` (workspace mode).

## Codex role config

```bash
ls .codex/agents/{SoftwareDeveloper,DatabaseEngineer,DevOpsEngineer,DocumentationWriter,QaTester,SecurityArchitect,SystemArchitect,UxDesigner,ProductManager,DataAnalyst,TheOpponent,WebResearcher,ForensicAgent}.toml
grep -n 'prompt_file = "DataAnalyst.md"' .codex/agents/DataAnalyst.toml
grep -n "BEGIN forge-council agents" .codex/config.toml
```

Expected: all Codex role TOML files present after `make install-codex-agent-config` (or `make install`), `prompt_file` points to the deployed agent markdown file, and `.codex/config.toml` contains the forge-council role block markers.

## Agent teams (optional)

```bash
echo "${CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS:-0}"
# 1 = parallel council mode available (3-round debate runs fastest)
# 0 = sequential fallback (still works, just slower)
```

## Manual check

Invoke the demo to verify agents load correctly:

```
/Demo agents
```

Should display the full roster with all 13 agents and their correctly resolved models.

For Codex specialist usage, explicitly invoke sub-agents (for example `Task: SoftwareDeveloper — [request]`) or use council skills.

## Expected results

- All 13 agent files deployed to targeted directory
- No orphaned `Council*` agent files
- Agent names match filenames (PascalCase)
- 5 skills discoverable (DebateCouncil, Demo, DeveloperCouncil, ProductCouncil, KnowledgeCouncil)
- Codex has 5 council skills installed by default
- `/Demo` renders the agent roster without errors
