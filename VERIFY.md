# forge-council — Verification

> **For AI agents**: Complete this checklist after installation. Every check must pass before declaring the module installed.

## Quick check

```bash
ls ~/.claude/agents/{Developer,Database,DevOps,DocumentationWriter,Tester,SecurityArchitect,Opponent,Researcher}.md
```

Expected: all 8 files present.

## Agent deployment

```bash
# All 8 agents deployed
ls ~/.claude/agents/ | grep -E "^(Developer|Database|DevOps|DocumentationWriter|Tester|SecurityArchitect|Opponent|Researcher)\.md$" | wc -l
# Should output: 8

# Each agent has synced-from header
grep -l "^# synced-from:" ~/.claude/agents/{Developer,Database,DevOps,DocumentationWriter,Tester,SecurityArchitect,Opponent,Researcher}.md | wc -l
# Should output: 8
```

## Agent frontmatter

```bash
# All agents have claude.name in PascalCase
for f in Modules/forge-council/agents/*.md; do
  name=$(grep "^claude.name:" "$f" | head -1 | awk -F': ' '{print $2}')
  echo "$name"
done
# Should output 8 PascalCase names, each matching its filename
```

## No stale agents

```bash
# No old Council-prefixed agents remain
ls ~/.claude/agents/ | grep -i "^Council" || echo "Clean — no stale Council agents"
```

## Skill discovery

```bash
ls Modules/forge-council/skills/*/SKILL.md
# Should list: DeveloperCouncil, Demo
```

## Agent teams (optional)

```bash
echo "${CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS:-0}"
# 1 = parallel council mode available
# 0 = sequential fallback (still works, just slower)
```

## Manual check

Invoke the demo to verify agents load correctly:

```
/Demo agents
```

Should display the full roster with all 8 agents and their models.

## Expected results

- All 8 agent files deployed to `~/.claude/agents/`
- No orphaned `Council*` agent files
- Agent names match filenames (PascalCase)
- Both skills discoverable (DeveloperCouncil, Demo)
- `/Demo` renders the agent roster without errors
