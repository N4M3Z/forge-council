# forge-council

Eight specialists. One unified verdict.

A single AI agent is a single perspective. It gives you one take — its own — and misses everything outside its frame. forge-council provides specialist agents that work from independent perspectives: review, design, build, challenge, research. Assemble them into councils for multi-perspective verdicts, or invoke any specialist standalone.

## What it does

**Developer Council** (`/DeveloperCouncil`) — Convenes 2-6 specialists in parallel, each working from their domain. The main session acts as team lead: parses the task, selects relevant specialists, spawns them, and synthesizes their independent findings into a single verdict with cross-cutting issues, disagreements, and prioritized actions.

**Standalone specialists** — Every agent works independently via the Task tool. SecurityArchitect runs threat models. Opponent stress-tests proposals. Researcher investigates topics across the web. No orchestration required.

**Demo** (`/Demo`) — Interactive showcase of the full roster, council flow, and example invocations. Try it first.

## What it looks like

You ask the council to design something. Five specialists work in parallel, each contributing what a generalist would miss:

```
/DeveloperCouncil Design a prompt regression testing CLI —
run prompts against multiple LLM providers, diff outputs, track regressions
```

The lead spawns Developer, Database, Tester, DevOps, and SecurityArchitect. Each works independently. Minutes later, the verdict arrives:

```
Council Verdict: promptdiff CLI — Design & Scaffold
Specialists: Developer, Database, Tester, DevOps, SecurityArchitect

Dev:      Trait-based provider architecture. One runner fans out with
          tokio::JoinSet. Differ scores semantic similarity + exact match.
Database: SQLite for zero-config persistence. Cost tracking per-run
          enables "this refactor saved $4/day." Composite index on
          (prompt_hash, provider) for fast regression lookups.
QA:       Three test layers — unit, integration, golden. Golden tests
          use promptdiff to test itself. Edge cases: empty responses,
          non-deterministic outputs, rate limits, API changes.
Ops:      cargo install — single binary. CI via exit codes (0/1/2).
          GitHub Action posts regression report as PR comment.
          Cost guard: max $0.50/run prevents runaway API spend.
Security: API keys from env vars only, never config. Ship 20 adversarial
          prompts as a built-in injection detection suite. Per-provider
          rate limiting prevents accidental DDoS during test runs.

Next steps:
  1. Scaffold with cargo init + Provider trait (Dev)
  2. SQLite schema + migration (Database)
  3. Golden test fixtures + CI workflow (QA + Ops)
  4. Injection baseline suite (Security)
```

One prompt, five perspectives, a buildable tool. The DBA adds cost tracking nobody asked for. QA designs tests that use the tool to test itself. Security ships an injection detection suite the Developer wouldn't have thought of.

Standalone specialists work the same way, without the council. You ask the Opponent to challenge a decision:

```
Task: Opponent — "We're planning to rewrite the monolith into microservices"
```

```
Steel man: The monolith is a deployment bottleneck — 45-minute deploys,
unclear ownership, full regression on every change.

Key challenges:
  1. Distributed transactions replace ACID guarantees
  2. Trading deploy complexity for operational complexity
  3. Team size (4 engineers) is below the microservices threshold

Overall: Sound motivation, wrong solution for the team size. A modular
monolith solves ownership and deploy problems without the operational tax.
Revisit microservices at 8-10 engineers.
```

## The council

```
/DeveloperCouncil [task]
    │
    ▼
┌─────────────────────────────────────────┐
│  Lead: parse task, select specialists   │
│  based on what the task needs           │
└─────────────────────────────────────────┘
    │
    ▼
┌──────────┬──────────┬──────────┬──────────┐
│Developer │ Tester   │ DevOps   │ Security │  ← in parallel
│          │          │          │ Architect│
└────┬─────┴────┬─────┴────┬─────┴────┬─────┘
     │          │          │          │
     └──────────┴──────────┴──────────┘
                    │
                    ▼
         ┌─────────────────────┐
         │  Lead: synthesize   │
         │  verdict + actions  │
         └─────────────────────┘
```

The lead always includes Developer and Tester for code tasks. Database, DevOps, DocumentationWriter, and SecurityArchitect join when their domain is relevant. Say "full council" to spawn all six.

## Agents

| Agent | Model | Council | Use for |
|-------|-------|---------|---------|
| **Developer** | sonnet | yes | Implementation quality, patterns, correctness |
| **Database** | sonnet | yes | Schema design, query performance, migrations |
| **DevOps** | sonnet | yes | CI/CD, deployment, monitoring, reliability |
| **DocumentationWriter** | sonnet | yes | README quality, API docs, developer experience |
| **Tester** | sonnet | yes | Test strategy, coverage, edge cases, regression |
| **SecurityArchitect** | sonnet | yes | Threat modeling, security policy, architectural risk |
| **Opponent** | opus | standalone | Devil's advocate, stress-test ideas and decisions |
| **Researcher** | sonnet | standalone | Deep web research, multi-query synthesis, citations |

Every agent also works standalone via the Task tool.

## Install

Works as a **standalone Claude Code plugin** or as a **forge-core module**. No compiled code — forge-council is pure markdown orchestration.

### As a forge-core module

Already registered. Deploy agents with:

```bash
Hooks/sync-agents.sh
```

### Standalone

```bash
git clone https://github.com/N4M3Z/forge-council.git
bash forge-council/bin/install-agents.sh
```

Council mode uses agent teams (parallel spawning). Enable in settings:

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

Without this flag, `/DeveloperCouncil` falls back to sequential subagent calls — same specialists, same verdict, just slower. Standalone agents work without any flags.

## Skills

| Skill | Purpose |
|-------|---------|
| `/DeveloperCouncil` | Convene a multi-perspective developer council for review, design, or debugging |
| `/Demo` | Interactive showcase of the agent roster, council flow, and example invocations |

## Configuration

Zero config required. `defaults.yaml` defines the agent roster and council composition. Override in `config.yaml` (gitignored):

| Setting | Default | What it controls |
|---------|---------|-----------------|
| `agents.council` | Developer, Database, DevOps, DocumentationWriter, Tester, SecurityArchitect | Agents available for council selection |
| `agents.standalone` | Opponent, Researcher | Agents that operate independently |
| `councils.developer.roles` | all 6 council agents | Which agents the developer council can spawn |

Model selection lives in agent frontmatter (`agents/*.md`). To change a model, edit the agent file and re-run the agent sync.

## Architecture

Eight markdown agent files, two skills, one install script.

```
agents/
  Developer.md            # Implementation quality, patterns
  Database.md             # Schema design, query performance
  DevOps.md               # CI/CD, deployment, monitoring
  DocumentationWriter.md  # README quality, API docs, DX
  Tester.md               # Test strategy, coverage, edge cases
  SecurityArchitect.md    # Threat modeling, security policy
  Opponent.md             # Devil's advocate, critical analysis
  Researcher.md           # Web research, multi-query synthesis
skills/
  DeveloperCouncil/       # Council orchestration skill
  Demo/                   # Interactive showcase
bin/
  install-agents.sh       # Standalone agent deployment
defaults.yaml             # Agent roster + council composition
module.yaml               # Module metadata
```

Each agent file contains `claude.*` frontmatter (name, model, description, tools) plus a structured body: Role, Expertise, Instructions, Output Format, Constraints. Agents are deployed to `~/.claude/agents/` by `sync-agents.sh` (forge-core) or `install-agents.sh` (standalone).

> `CLAUDE.md` and `AGENTS.md` are autogenerated by `/Init`. Do not edit directly — run `/Update` to regenerate.
