# forge-council

Thirteen specialists. Four councils. One verdict.

A single AI agent is a single perspective. It gives you one take — its own — and misses everything outside its frame. forge-council provides specialist agents that work from independent perspectives: architecture, design, implementation, testing, security, product, research. Assemble them into councils for multi-round debates, or invoke any specialist standalone.

## Quick Start

```bash
git clone --recurse-submodules https://github.com/N4M3Z/forge-council.git
cd forge-council
make install     # Install agents + skills to .claude/, .gemini/, .codex/
make verify
```

Then in your session:

```text
/Demo
/Council [topic]
/DeveloperCouncil [task]
/ProductCouncil [requirements]
/KnowledgeCouncil [knowledge-management topic]
```

Or invoke any specialist standalone — no council needed:

```text
Task: TheOpponent — "We should rewrite the backend in Rust"
Task: WebResearcher — "Best practices for rate limiting in distributed systems"
Task: SecurityArchitect — "Threat model our authentication system"
```

> **Note**: `make install` defaults to `SCOPE=workspace` and installs into local `./.claude`, `./.gemini`, and `./.codex`. To install globally for your user, use `make install SCOPE=user`.

## Makefile Commands

Primary commands:

```bash
make install                 # install agents + skills + teams config (SCOPE=workspace|user|all)
make install-agents          # install agent artifacts (uses SCOPE)
make install-codex-agent-config # Codex compatibility post-processing (forge-lib Rust binary)
make install-skills          # install skills for Claude, Gemini, and Codex (uses SCOPE)
make install-skills-codex    # install native council skills (uses SCOPE)
make verify                  # run verification checks (13 agents)
make verify-codex-agent-config # verify Codex role TOML/config artifacts (uses SCOPE)
```

## What it does

**3-round debate** — All councils use a structured debate where specialists respond to each other's points across three rounds: initial positions, challenges, convergence. The lead synthesizes areas of agreement, remaining disagreements, and recommended actions.

**Council skills** — `/DeveloperCouncil` for code review, architecture, and debugging. `/DebateCouncil` for cross-domain strategy and design debates. `/ProductCouncil` for requirements, features, and go/no-go decisions. `/KnowledgeCouncil` for knowledge architecture and memory lifecycle decisions. Each selects the right specialists for the task.

**User checkpoints** — After Round 1, the lead shows you the initial positions and asks for your input before the debate rounds begin. Add context, redirect focus, or skip to synthesis. Override with `autonomous` (no stops), `interactive` (stop every round), or `quick` (one round only).

**Standalone specialists** — Every agent works independently via the Task tool. TheOpponent stress-tests your proposals. WebResearcher investigates topics across the web. No orchestration needed.

## What it looks like

You have an idea for a product. Before you write a line of code, you put it in front of the council:

```
/DebateCouncil We're building an AI code review tool for enterprise — $50/seat,
targeting engineering teams of 50+. Should we go all-in?

Round 1 — Initial Positions:
  SystemArchitect: The hard part isn't the AI — it's the integration surface.
              You need to plug into GitHub, GitLab, Bitbucket, and on-prem.
              That's four integration contracts before you ship one review.
  UxDesigner: Enterprise buyers won't even demo without SSO. Your landing
              page needs a "Book a demo" button, not a "Sign up" button.
              The first user isn't a developer — it's a procurement team.
  SoftwareDeveloper: $50/seat is a race to the bottom — GitHub Copilot is $19.
              Sell saved engineering hours, not seats. "This tool caught
              42 bugs last sprint" beats a per-seat invoice.
  WebResearcher: Three competitors pivoted from per-seat to usage-based pricing
              in 2025. CodeRabbit, Sourcery, and Codium all moved to
              per-PR or per-repo models after enterprise pushback on seat
              math for a tool that reviews code, not writes it.

[Checkpoint: Any context to add before debate?]

Round 2 — Challenges:
  SystemArchitect: "WebResearcher's data on pricing pivots changes the equation.
              If we go usage-based, metering infrastructure becomes day-1
              architecture, not a nice-to-have."
  UxDesigner: "SoftwareDeveloper's right on the value pitch, but procurement
              still needs a number. Usage-based with a monthly cap gives
              both — predictable budgets, honest pricing."
  SoftwareDeveloper: "SystemArchitect's integration concern is the real blocker.
              Start with GitHub only. One integration done well beats four
              done poorly. Validate with 10 teams before touching GitLab."
  WebResearcher: "SoftwareDeveloper's 'GitHub first' aligns with the data — 73%
              of enterprise teams use GitHub. But SystemArchitect should flag: the
              GitHub API rate limit (5000/hr) will bottleneck teams over
              200 developers."

Round 3 — Convergence:
  Agreement:  Start GitHub-only. Usage-based pricing (per-PR, monthly cap).
              SSO before launch. Sell outcomes, not seats.
  Disagreement: SystemArchitect wants the integration abstraction layer now
              (10 days). SoftwareDeveloper says YAGNI — build it when GitLab is real.
  Recommendation: Ship GitHub-only MVP with usage-based pricing and SSO.
              Build the abstraction layer when the second integration has
              a signed LOI, not before. The pricing model matters more
              than the code — validate that first.
```

One prompt. Four perspectives. The WebResearcher kills the pricing model with market data. The UxDesigner catches a procurement blocker nobody was thinking about. The SoftwareDeveloper and SystemArchitect disagree on abstraction timing — and the council resolves it with a concrete decision rule.

---

The product council does the same thing for requirements and strategy:

```
/ProductCouncil We're launching a payments API — how should we price it?

Round 1 — Initial Assessments:
  ProductManager: Transaction-based (0.5% + $0.10) aligns cost with value.
                  Developers only pay when they make money.
  UxDesigner:     Developers hate surprise bills. Ship a pricing calculator
                  on day one. Show "your 10K transactions/mo = $60" before
                  they even create an account.
  SoftwareDeveloper: Metering infrastructure for real-time usage tracking is
                  three months of work. We don't have it. Flat tiers ship
                  in two weeks.
  DataAnalyst:    At 0.5%, we're uncompetitive above $200 transactions —
                  Stripe is 2.9% but includes the payment rail. We're just
                  the API layer. Should be 10x cheaper or 10x simpler.

Round 2 — Challenges:
  ProductManager: "DataAnalyst's pricing math is the wake-up call. We're not
                  competing with Stripe — we're competing with 'build it
                  yourself.' Price against internal eng cost, not Stripe."
  DataAnalyst:    "SoftwareDeveloper's right that metering is expensive. But flat
                  tiers leave money on the table above 50K transactions/mo.
                  That's exactly the segment that pays for the product."
  SoftwareDeveloper: "Ship flat tiers now, add metering when we have paying
                  customers funding it. Premature metering killed Segment's
                  first year — they burned runway on billing, not product."
  UxDesigner:     "PM's 'price against internal cost' reframes everything.
                  Landing page should show: '3 engineers x 2 months = $90K.
                  Or $199/mo.' That's the real comparison."

Round 3 — Convergence:
  Recommendation: Three flat tiers ($0/99/499) at launch. Add usage-based
                  above $499 when volume justifies metering investment.
                  Position against build-vs-buy, not against Stripe.
```

## Try it

After installing, run the interactive demo:

```
/Demo
```

Or jump straight into a council with your own question:

```
/DebateCouncil [any question worth debating]
/DeveloperCouncil [code to review, architecture to evaluate]
/ProductCouncil [requirements to validate, feature to scope]
```

Or invoke any specialist standalone — no council needed:

```
Task: TheOpponent — "We should rewrite the backend in Rust"
Task: WebResearcher — "Best practices for rate limiting in distributed systems"
Task: SecurityArchitect — "Threat model our authentication system"
```

## Codex Sub-Agents

In Codex, specialists are used via **explicit sub-agent invocation**. They are not auto-selected just because they are installed.

- Use direct invocation style: `Task: SoftwareDeveloper — [request]`
- Use council skills when you want multi-agent debate: `/DebateCouncil`, `/DeveloperCouncil`, `/ProductCouncil`, `/KnowledgeCouncil`
- If you do not ask for a specialist/sub-agent, the main session handles the request alone
- Installation also runs Codex compatibility post-processing that generates per-agent role files (`agents/*.toml`) and injects role entries into `.codex/config.toml` (or `~/.codex/config.toml` for `SCOPE=user`).
- This post-processing is implemented by `lib/bin/install-codex-agent-config` from the forge-lib submodule.

## The debate

```
/DebateCouncil [topic]  or  /DeveloperCouncil [task]  or  /ProductCouncil [spec]
    │
    ▼
┌─────────────────────────────────────────┐
│  Lead: parse task, select specialists,  │
│  detect mode (checkpoint/auto/quick)    │
└─────────────────────────────────────────┘
    │
    ▼  ROUND 1: Initial Positions
┌──────────┬──────────┬──────────┬──────────┐
│ Agent A  │ Agent B  │ Agent C  │ Agent D  │  ← in parallel
└────┬─────┴────┬─────┴────┬─────┴────┬─────┘
     └──────────┴──────────┴──────────┘
                    │
    ▼  [Checkpoint: user input]
                    │
    ▼  ROUND 2: Challenges (with Round 1 transcript)
┌──────────┬──────────┬──────────┬──────────┐
│ Agent A  │ Agent B  │ Agent C  │ Agent D  │  ← in parallel
└────┬─────┴────┬─────┴────┬─────┴────┬─────┘
     └──────────┴──────────┴──────────┘
                    │
    ▼  ROUND 3: Convergence (with full transcript)
┌──────────┬──────────┬──────────┬──────────┐
│ Agent A  │ Agent B  │ Agent C  │ Agent D  │  ← in parallel
└────┬─────┴────┬─────┴────┬─────┴────┬─────┘
     └──────────┴──────────┴──────────┘
                    │
                    ▼
         ┌─────────────────────┐
         │  Lead: synthesize   │
         │  verdict + actions  │
         └─────────────────────┘
```

## Agents

| Agent | Model | Councils | Use for |
|-------|-------|----------|---------|
| **SoftwareDeveloper** | fast | dev, debate | Implementation quality, patterns, correctness |
| **DatabaseEngineer** | fast | dev | Schema design, query performance, migrations |
| **DevOpsEngineer** | fast | dev | CI/CD, deployment, monitoring, reliability |
| **DocumentationWriter** | fast | dev, knowledge | README quality, API docs, developer experience |
| **QaTester** | fast | dev | Test strategy, coverage, edge cases, regression |
| **SecurityArchitect** | strong | dev | Threat modeling, security policy, architectural risk |
| **SystemArchitect** | fast | debate, knowledge | System design, boundaries, scalability, trade-offs |
| **UxDesigner** | fast | debate, product | UX, user needs, accessibility, interaction design |
| **ProductManager** | fast | product | Requirements clarity, roadmap alignment, market fit |
| **DataAnalyst** | fast | product | Success metrics, KPIs, measurement, business impact |
| **TheOpponent** | strong | standalone | Devil's advocate, stress-test ideas and decisions |
| **WebResearcher** | fast | debate, knowledge | Deep web research, multi-query synthesis, citations |
| **ForensicAgent** | strong | standalone | PII and secret detection forensic specialist |

Every agent also works standalone via the Task tool. TheOpponent and WebResearcher can join any council as optional extras.

## Install

Works as a **standalone Claude Code plugin** or as a **forge-core module**. No compiled code — forge-council is pure markdown orchestration.

### Standalone

```bash
git clone --recurse-submodules https://github.com/N4M3Z/forge-council.git
cd forge-council
make install
```

By default, this installs agents and skills into the local `.gemini/` directory of the project (`SCOPE=workspace`). To install to your user home directory (for use across all projects):

```bash
make install SCOPE=user
```

Council mode uses agent teams (parallel spawning). Enable in settings:

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

Without this flag, councils fall back to sequential subagent calls — same specialists, same debate, just slower. Standalone agents work without any flags.

## Skills

| Skill | Purpose |
|-------|---------|
| `/DebateCouncil` | Cross-domain 3-round debate with SystemArchitect, UxDesigner, SoftwareDeveloper, WebResearcher |
| `/DeveloperCouncil` | Code review, architecture, debugging with up to 6 dev specialists |
| `/ProductCouncil` | Requirements review, feature scoping, strategy with PM, UxDesigner, SoftwareDeveloper, DataAnalyst |
| `/KnowledgeCouncil` | Knowledge architecture and memory lifecycle decisions with DocumentationWriter, SystemArchitect, WebResearcher |
| `/Demo` | Interactive showcase — roster, flow, and example invocations |

### Debate modes

| Mode | Trigger | Behavior |
|------|---------|----------|
| checkpoint | _(default)_ | Pause after Round 1 for user input |
| autonomous | "fast", "autonomous" | All 3 rounds without interruption |
| interactive | "step by step" | Pause after every round |
| quick | "quick check" | Round 1 only + lead synthesis |

## Configuration

Zero config required. `defaults.yaml` defines the agent roster and council composition. Override in `config.yaml` (gitignored):

| Setting | Default | What it controls |
|---------|---------|-----------------|
| `models` | fast/strong | Global model tier mappings |
| `gemini` | tiers/whitelist | Gemini-specific models and whitelist |
| `claude` | tiers/whitelist | Claude-specific models and whitelist |
| `agents.*` | 13 agents | Agent deployment config (model, tools, scope) |
| `skills.*` | council roles | Council rosters and scope |
| `{AgentName}.tools` | _(none)_ | Specialist-specific tool overrides (sidecars) |
| `{AgentName}.scope` | _(none)_ | Specialist-specific scope override (user|workspace) |

### Provider-Specific Models

You can define separate model tiers and whitelists for Gemini and Claude in `defaults.yaml`:

```yaml
providers:
  gemini:
    models:
      - gemini-2.0-flash
      - gemini-2.5-flash
      - gemini-2.5-pro
    fast: gemini-2.0-flash
    strong: gemini-2.5-pro

  claude:
    models:
      - claude-opus-4.6
      - claude-haiku-4.6
      - claude-sonnet-4-6
    fast: claude-sonnet-4-6
    strong: claude-opus-4.6
```

Only whitelisted models are included in the generated agent frontmatter for each provider.

### Specialist Tool Overrides (Sidecars)

Sidecar behavior is implemented through `defaults.yaml` (committed defaults) and optional `config.yaml` (local overrides, gitignored).

Use `config.yaml` to override per-agent model tiers/tools without editing agent markdown:

```yaml
agents:
  SoftwareDeveloper:
    model: strong
    tools: Read, Grep, Glob, Bash, Write, Edit

  QaTester:
    tools:
      - Read
      - Grep
      - Glob
      - Bash
      - Write
      - Edit
```

After changing overrides, reinstall agents:

```bash
make install-agents SCOPE=workspace
```

## Architecture

Thirteen markdown agent files, five skills, and deployment utilities in forge-lib.

```
agents/
  SystemArchitect.md      # System design, boundaries, scalability
  DataAnalyst.md          # Metrics, KPIs, business impact
  DatabaseEngineer.md     # Schema design, query performance
  UxDesigner.md           # UX, user needs, accessibility
  SoftwareDeveloper.md    # Implementation quality, patterns
  DevOpsEngineer.md       # CI/CD, deployment, monitoring
  DocumentationWriter.md  # README quality, API docs, DX
  TheOpponent.md          # Devil's advocate, critical analysis
  ProductManager.md       # Requirements, roadmap, market fit
  WebResearcher.md        # Web research, multi-query synthesis
  ForensicAgent.md        # PII and secret detection forensic specialist
  SecurityArchitect.md    # Threat modeling, security policy
  QaTester.md             # Test strategy, coverage, edge cases
skills/
  DebateCouncil/          # Generic 3-round debate
  DeveloperCouncil/       # Developer council orchestration
  KnowledgeCouncil/       # Knowledge architecture and memory lifecycle decisions
  ProductCouncil/         # Product council orchestration
  Demo/                   # Interactive showcase
lib/
  bin/                    # Rust binaries from forge-lib submodule
    install-agents        # Multi-provider agent deployment
    install-skills        # Provider-aware skill installer
    validate-module       # Convention test suite
defaults.yaml             # Agent roster, council composition, provider config
module.yaml               # Module metadata
```

Each agent file has `name`, `description`, `version` in frontmatter plus a structured body: Role, Expertise, Instructions, Output Format, Constraints. Deployment config (model, tools, scope) lives in `defaults.yaml`. Agents are deployed by `lib/bin/install-agents` (standalone) or `sync-agents.sh` (forge-core).

> `CLAUDE.md` and `AGENTS.md` are autogenerated by `/Init`. Do not edit directly — run `/Update` to regenerate.
