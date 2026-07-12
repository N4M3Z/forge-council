# forge-council

A single AI agent is a single perspective. It gives you one take — its own — and misses everything outside its frame. forge-council provides specialist agents that work from independent perspectives: architecture, design, implementation, testing, security, product, research, hiring. Assemble them into councils for multi-round debates, or invoke any specialist standalone.

## Quick Start

```bash
git clone https://github.com/N4M3Z/forge-council.git
cd forge-council
make install     # forge install — deploys agents, skills, rules to all providers
```

Then in your session:

```text
/DebateCouncil [topic]
/DeveloperCouncil [task]
/ProductCouncil [requirements]
/KnowledgeCouncil [knowledge-management topic]
/HiringCouncil [job posting or role design]
```

Or invoke any specialist standalone — no council needed:

```text
Task: TheOpponent — "We should rewrite the backend in Rust"
Task: WebResearcher — "Best practices for rate limiting in distributed systems"
Task: SecurityArchitect — "Threat model our authentication system"
```

> **Note**: `make install` deploys to the local workspace (`./.claude`, `./.gemini`, `./.codex`, `./.opencode`). To install at user scope, run `forge install --target ~`.

## Makefile Commands

```bash
make install     # forge install — assemble + deploy for every provider
make validate    # pre-commit cascade (prek → forge validate → validate.sh fallback)
make clean       # remove build/ artifacts
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

Jump into a council with your own question:

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
| **TalentAcquisition** | fast | hiring | Sourcing strategy, JD design, candidate funnel |
| **HiringManager** | fast | hiring | Role definition, interview rubric, hiring decision |
| **CompensationAnalyst** | fast | hiring | Compensation benchmarks, equity bands |
| **ExecutiveAdvisor** | strong | hiring | Strategic hiring, leadership roles |
| **CzechLawAdvisor** | strong | hiring | Czech labour law and employment compliance |
| **IndustryExpert** | fast | hiring | Sector-specific hiring norms |

Every agent also works standalone via the Task tool. TheOpponent and WebResearcher can join any council as optional extras.

## Install

forge-council ships as a Claude Code plugin and as a forge-cli module. No compiled code — only markdown.

```bash
git clone https://github.com/N4M3Z/forge-council.git
cd forge-council
make install            # forge install — workspace deploy
forge install --target ~ # user-scope deploy (alternative)
```

Council parallel mode requires `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` in `~/.claude/settings.json`:

```json
{
    "env": {
        "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
    }
}
```

Without the flag, councils fall back to sequential subagent calls — same specialists, same debate, just slower. Standalone agents work without any flags.

## Skills

| Skill | Purpose |
|-------|---------|
| `/DebateCouncil` | Cross-domain 3-round debate with SystemArchitect, UxDesigner, SoftwareDeveloper, WebResearcher |
| `/DeveloperCouncil` | Code review, architecture, debugging with up to 6 dev specialists |
| `/ProductCouncil` | Requirements review, feature scoping, strategy with PM, UxDesigner, SoftwareDeveloper, DataAnalyst |
| `/KnowledgeCouncil` | Knowledge architecture and memory lifecycle decisions with DocumentationWriter, SystemArchitect, WebResearcher |
| `/HiringCouncil` | Job postings, role design, compensation, recruitment strategy |
| `/ProjectInit` | Deep scoping interview establishing a new project: local git, `CLAUDE.md`, project-scoped rules, `DEFERRED.md` seed |
| `/StagedDelivery` | Council-first plan/build/verify loop with opponent gate, decision gate, and deferred ledger; natural follow-up to `/ProjectInit` |

### Debate modes

| Mode | Trigger | Behavior |
|------|---------|----------|
| checkpoint | _(default)_ | Pause after Round 1 for user input |
| autonomous | "fast", "autonomous" | All 3 rounds without interruption |
| interactive | "step by step" | Pause after every round |
| quick | "quick check" | Round 1 only + lead synthesis |

## Configuration

Zero config required. `defaults.yaml` defines the agent roster and per-agent tool/model assignments. Override in `config.yaml` (gitignored):

| Setting | What it controls |
|---------|------------------|
| `agents.<Name>.model` | Model tier (`fast` or `strong`) for the named agent |
| `agents.<Name>.tools` | Tool allowlist for the named agent |
| `agents.<Name>.skills` | Skills available to the named agent |
| `providers.<provider>.models.{fast,strong}` | Provider-specific model tier mapping |

### Provider-Specific Models

`defaults.yaml` lists per-provider model tiers under `providers.<provider>.models.{fast,strong}`:

```yaml
providers:
    claude:
        models:
            fast: [claude-sonnet-4-6]
            strong: [claude-opus-4-6]
    gemini:
        models:
            fast: [gemini-2.0-flash]
            strong: [gemini-2.5-pro]
```

`forge install` selects the right tier per provider based on the agent's `model:` field.

### Specialist Overrides

Use `config.yaml` to override per-agent settings without editing agent markdown:

```yaml
agents:
    SoftwareDeveloper:
        model: strong
        tools: Read, Grep, Glob, Bash, Write, Edit
```

After changing overrides, run `make install` and restart your session.

## Architecture

Specialist agents, council skills, and always-loaded rules. Deployment is handled by the external `forge` CLI.

```
agents/
  SoftwareDeveloper.md         # Implementation quality, patterns
  SystemArchitect.md           # System design, boundaries, scalability
  DataAnalyst.md               # Metrics, KPIs, business impact
  DatabaseEngineer.md          # Schema design, query performance
  UxDesigner.md                # UX, user needs, accessibility
  DevOpsEngineer.md            # CI/CD, deployment, monitoring
  DocumentationWriter.md       # README quality, API docs, DX
  TheOpponent.md               # Devil's advocate, critical analysis
  ProductManager.md            # Requirements, roadmap, market fit
  WebResearcher.md             # Web research, multi-query synthesis
  ForensicAgent.md             # PII and secret detection forensic specialist
  SecurityArchitect.md         # Threat modeling, security policy
  QaTester.md                  # Test strategy, coverage, edge cases
  TalentAcquisition.md         # Sourcing, JD design, candidate funnel
  HiringManager.md             # Role definition, interview rubric
  CompensationAnalyst.md       # Compensation benchmarks, equity bands
  ExecutiveAdvisor.md          # Strategic hiring, leadership roles
  CzechLawAdvisor.md           # Czech labour law and employment compliance
  IndustryExpert.md            # Sector-specific hiring norms
skills/
  DebateCouncil/               # Generic 3-round debate
  DeveloperCouncil/            # Developer council orchestration
  KnowledgeCouncil/            # Knowledge architecture and memory lifecycle
  ProductCouncil/              # Product council orchestration
  HiringCouncil/               # Hiring council orchestration
rules/
  AgentTeams.md                # TeamCreate / TeamDelete gate + teardown protocol
  LearningCapture.md           # Post-teardown learning extraction
defaults.yaml                  # Agent roster, tool assignments, provider model tiers
module.yaml                    # Module metadata
```

Each agent file has `name`, `description`, `version` in frontmatter plus a structured body: Role, Expertise, Instructions, Output Format, Constraints. Deployment config (model, tools) lives in `defaults.yaml`. The `forge` CLI assembles all three artifact directories into `build/` and deploys them to provider directories.
