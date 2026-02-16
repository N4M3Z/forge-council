# forge-council

Eight specialists. One unified verdict.

One AI agent reviewing your code is a monologue. It sees what it sees and misses everything outside its frame — the N+1 query a DBA would catch in seconds, the deployment risk an SRE would flag before it hits production, the edge case a QA engineer would write a test for before lunch. forge-council turns code review into a conversation between specialists: spawn a Developer, a Tester, a SecurityArchitect, a Database expert — each reviewing independently, in parallel, from their own domain. The lead synthesizes their findings into a single verdict with cross-cutting issues, disagreements, and prioritized actions. Or skip the council entirely and invoke any specialist standalone — run a threat model, stress-test a decision, research a topic across the web.

## Quick start

Run the demo to see the full roster and what a council review looks like:

```
/Demo
```

```
╔══════════════════════════════════════════════════════════╗
║                    forge-council                        ║
║         Eight specialists. One unified verdict.         ║
╚══════════════════════════════════════════════════════════╝

┌──────────────────────────────────────────────────────────┐
│  THE COUNCIL (multi-perspective review)                  │
├──────────────────────┬────────┬──────────────────────────┤
│ Developer            │ sonnet │ Implementation quality    │
│ Database             │ sonnet │ Schema & query perf       │
│ DevOps               │ sonnet │ CI/CD & deployment        │
│ DocumentationWriter  │ sonnet │ README & API docs         │
│ Tester               │ sonnet │ Coverage & edge cases     │
│ SecurityArchitect    │ sonnet │ Threat modeling           │
├──────────────────────┴────────┴──────────────────────────┤
│  STANDALONE SPECIALISTS                                  │
├──────────────────────┬────────┬──────────────────────────┤
│ Opponent             │ opus   │ Devil's advocate          │
│ Researcher           │ sonnet │ Deep web research         │
└──────────────────────┴────────┴──────────────────────────┘
```

Then point it at your code:

```
/DeveloperCouncil Review src/api/ for security, performance, and correctness
```

Or invoke a single specialist:

```
/DeveloperCouncil Review the database migration in db/migrations/024_add_teams.sql
```

The lead spawns only the relevant agents — a migration review gets Developer + Database + Tester, not the full roster.

## What it provides

**Developer Council** (`/DeveloperCouncil`) — Convenes 2-6 specialists in parallel, each reviewing from their domain. The main session acts as team lead: selects relevant specialists, spawns them, collects findings, synthesizes a unified verdict with cross-cutting issues and prioritized actions.

**Standalone specialists** — Every agent works independently via the Task tool. SecurityArchitect runs threat models. Opponent stress-tests proposals. Researcher investigates topics across the web. No orchestration needed.

## What it looks like

You ask the council to build something. Each specialist contributes what a generalist would miss:

```
/DeveloperCouncil Design and scaffold a prompt regression testing CLI —
run prompts against multiple LLM providers, diff outputs, track regressions
```

```
┌──────────────────────────────────────────────────────────────────┐
│  Council Verdict: promptdiff CLI — Design & Scaffold             │
│  Specialists: Developer, Database, Tester, DevOps, Security     │
└──────────────────────────────────────────────────────────────────┘

ARCHITECTURE ── Developer ────────────────────────────────────────
  promptdiff/
    src/
      main.rs              # CLI entry: run, diff, report
      providers/           # Trait-based: OpenAI, Anthropic, local
        mod.rs             # Provider trait: send(prompt) → Response
        openai.rs
        anthropic.rs
      runner.rs            # Parallel execution across providers
      differ.rs            # Semantic + exact diff with scoring
      reporter.rs          # Terminal table + JSON + markdown output
    tests/
      fixtures/            # Golden prompt/response pairs

  One trait, one runner, one differ. Each provider implements
  Provider::send(). Runner fans out with tokio::JoinSet.
  Differ scores semantic similarity (cosine on embeddings) +
  exact match for structured outputs.

DATA LAYER ── Database ───────────────────────────────────────────
  SQLite for local-first, zero-config persistence:
    runs(id, suite, timestamp, git_sha)
    results(id, run_id, provider, prompt_hash, response, latency_ms,
            tokens_in, tokens_out, cost_usd)
    baselines(prompt_hash, provider, expected_response, threshold)

  Composite index on (prompt_hash, provider) for fast regression
  lookups. Cost tracking per-run enables "this refactor saved $4/day."
  Migration: single schema file, embedded via rusqlite.

TEST STRATEGY ── Tester ──────────────────────────────────────────
  Three layers:
    1. Unit: differ scoring against known pairs (exact, similar, drift)
    2. Integration: mock provider that returns fixture responses
    3. Golden: promptdiff tests itself — run the test suite, diff
       against committed baselines, fail CI if regression detected

  Edge cases to cover from day one:
    • Empty responses (provider timeout → empty string)
    • Non-deterministic outputs (temperature > 0 needs threshold)
    • Rate limit handling (429 backoff, not crash)
    • Provider API changes (structured error vs. garbage)

DEPLOYMENT ── DevOps ─────────────────────────────────────────────
  cargo install promptdiff — single binary, no runtime dependencies.
  CI integration via exit codes: 0 = pass, 1 = regression, 2 = error.

  GitHub Action workflow:
    - Trigger: on PR, on schedule (daily baseline refresh)
    - Cache: SQLite db as artifact between runs
    - Output: regression report as PR comment (markdown)

  Cost guard: configurable max-spend-per-run in config.toml.
  Default: $0.50. Prevents runaway costs from a test suite typo.

SECURITY ── SecurityArchitect ────────────────────────────────────
  API keys: read from env vars only, never config files. Support
  for 1Password CLI (op read) and AWS Secrets Manager as sources.
  Keys never appear in logs, test output, or SQLite rows.

  Prompt injection test suite: ship 20 adversarial prompts as a
  built-in suite. Run with: promptdiff run --suite injection-baseline.
  Detects when a model starts following injected instructions.

  Rate limiting: per-provider token bucket. Prevents accidental
  DDoS of API endpoints during parallel test runs.

RECOMMENDED NEXT STEPS ──────────────────────────────────────────
  1. Scaffold the project with cargo init + Provider trait (Dev)
  2. Create SQLite schema + migration (Database)
  3. Implement OpenAI + Anthropic providers (Dev)
  4. Build differ with threshold-based scoring (Dev + QA)
  5. Add golden test fixtures + CI workflow (QA + Ops)
  6. Ship injection baseline suite (Security)
  7. Write the README — this verdict is the first draft (Docs)
```

One prompt, five perspectives, a buildable tool. The Developer sketches the architecture, the DBA designs storage that enables cost tracking, QA defines a testing strategy that uses the tool to test itself, Ops handles CI and cost guards, and Security adds an injection detection suite nobody else thought of.

Standalone specialists work the same way, without the council:

```
Task: Opponent — "We're planning to rewrite the monolith into microservices"
```

```
┌────────────────────────────────────────────────────────────┐
│  Devil's Advocate: Monolith → Microservices Rewrite        │
└────────────────────────────────────────────────────────────┘

STEEL MAN ────────────────────────────────────────────────────
  The monolith has become a deployment bottleneck — a single
  change requires full regression, deploys take 45 minutes, and
  team ownership boundaries are unclear. Microservices would give
  independent deployment, clearer ownership, and technology choice
  per service.

KEY CHALLENGES ───────────────────────────────────────────────
  1. Distributed transactions replace ACID guarantees — every
     cross-service operation becomes an eventual consistency problem.
  2. You're trading deploy complexity for operational complexity.
     45-minute deploys become 12 services to monitor, debug, and
     keep compatible.
  3. Team size (4 engineers) is below the threshold where
     microservices pay off. You'll spend more time on infra than
     on features.

HARDEST QUESTIONS ────────────────────────────────────────────
  • What specific problem does this solve that a modular monolith
    wouldn't?
  • Do you have the ops capacity to run 12 services in production?
  • What's the rollback plan if the rewrite stalls at 40%?

OVERALL: Fundamentally sound motivation, wrong solution for the
team size. A modular monolith with clear module boundaries solves
the ownership and deploy problems without the operational tax.
Revisit microservices when the team hits 8-10 engineers.
```

## Agents

| Agent | Model | Council | Standalone | Use for |
|-------|-------|---------|------------|---------|
| **Developer** | sonnet | yes | yes | Implementation quality, patterns, correctness |
| **Database** | sonnet | yes | yes | Schema design, query performance, migrations |
| **DevOps** | sonnet | yes | yes | CI/CD, deployment, monitoring, reliability |
| **DocumentationWriter** | sonnet | yes | yes | README quality, API docs, developer experience |
| **Tester** | sonnet | yes | yes | Test strategy, coverage, edge cases, regression |
| **SecurityArchitect** | sonnet | yes | yes | Threat modeling, security policy, architectural risk |
| **Opponent** | opus | no | yes | Devil's advocate, stress-test ideas and decisions |
| **Researcher** | sonnet | no | yes | Deep web research, multi-query synthesis, citations |

## Council flow

```
User invokes /DeveloperCouncil
    │
    ▼
┌──────────────────────────────────────┐
│  Lead: parse task, select 2-6       │
│  specialists based on what's needed  │
└──────────────────────────────────────┘
    │
    ▼
┌──────────┬──────────┬──────────┬──────────┐
│Developer │ Tester   │ DevOps   │ Security │  ← spawned in parallel
│          │          │          │ Architect│
│ reviews  │ reviews  │ reviews  │ reviews  │
│ code     │ tests    │ infra    │ threats  │
└────┬─────┴────┬─────┴────┬─────┴────┬─────┘
     │          │          │          │
     └──────────┴──────────┴──────────┘
                    │
                    ▼
         ┌─────────────────────┐
         │  Lead: synthesize   │
         │  verdict + actions  │
         └─────────────────────┘
                    │
                    ▼
           Council Verdict
```

The lead always includes Developer and Tester for code tasks. Database, DevOps, DocumentationWriter, and SecurityArchitect join when their domain is relevant. Say "full council" to spawn all six.

## Install

Works as a **standalone Claude Code plugin** or as a **forge-core module**.

### As a forge-core module

Already registered. Deploy agents with:

```bash
Hooks/sync-agents.sh
```

### Standalone

```bash
bash bin/install-agents.sh
```

## Prerequisites

Council mode uses agent teams (parallel spawning). Enable in settings:

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

Without this flag, `/DeveloperCouncil` falls back to sequential subagent calls — same specialists, same verdict, just slower.

Standalone agents work without any flags.

## Skills

| Skill | Purpose |
|-------|---------|
| `/DeveloperCouncil` | Convene a multi-perspective developer council for review, design, or debugging |
| `/Demo` | Showcase the agent roster, council flow, and standalone specialists |

## Configuration

`defaults.yaml` defines the agent roster and council composition. Override in `config.yaml` (gitignored):

| Setting | Default | What it controls |
|---------|---------|-----------------|
| `agents.council` | Developer, Database, DevOps, DocumentationWriter, Tester, SecurityArchitect | Agents available for council selection |
| `agents.standalone` | Opponent, Researcher | Agents that operate independently |
| `councils.developer.roles` | all 6 council agents | Which agents the developer council can spawn |

Model selection lives in agent frontmatter (`agents/*.md`). To change a model, edit the agent file and re-run the agent sync.

## Architecture

Eight markdown agent files, one skill, one install script. No compiled code — forge-council is pure orchestration.

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
bin/
  install-agents.sh       # Standalone agent deployment
defaults.yaml             # Agent roster + council composition
module.yaml               # Module metadata
```

Agents are deployed to `~/.claude/agents/` by `sync-agents.sh` (forge-core) or `install-agents.sh` (standalone). Each agent file contains frontmatter (`claude.name`, `claude.model`, `claude.description`, `claude.tools`) plus a structured body (Role, Expertise, Instructions, Output Format, Constraints).

> `CLAUDE.md` and `AGENTS.md` are autogenerated by `/Init`. Do not edit directly — run `/Update` to regenerate.
