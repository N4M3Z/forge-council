# forge-council

Twelve specialists. Three councils. One verdict.

A single AI agent is a single perspective. It gives you one take — its own — and misses everything outside its frame. forge-council provides specialist agents that work from independent perspectives: architecture, design, implementation, testing, security, product, research. Assemble them into councils for multi-round debates, or invoke any specialist standalone.

## What it does

**3-round debate** — All councils use a structured debate where specialists respond to each other's points across three rounds: initial positions, challenges, convergence. The lead synthesizes areas of agreement, remaining disagreements, and recommended actions.

**Three council types** — `/DeveloperCouncil` for code review, architecture, and debugging. `/Council` for cross-domain strategy and design debates. `/ProductCouncil` for requirements, features, and go/no-go decisions. Each selects the right specialists for the task.

**User checkpoints** — After Round 1, the lead shows you the initial positions and asks for your input before the debate rounds begin. Add context, redirect focus, or skip to synthesis. Override with `autonomous` (no stops), `interactive` (stop every round), or `quick` (one round only).

**Standalone specialists** — Every agent works independently via the Task tool. Opponent stress-tests your proposals. Researcher investigates topics across the web. No orchestration needed.

## What it looks like

You have an idea for a product. Before you write a line of code, you put it in front of the council:

```
/Council We're building an AI code review tool for enterprise — $50/seat,
targeting engineering teams of 50+. Should we go all-in?

Round 1 — Initial Positions:
  Architect:  The hard part isn't the AI — it's the integration surface.
              You need to plug into GitHub, GitLab, Bitbucket, and on-prem.
              That's four integration contracts before you ship one review.
  Designer:   Enterprise buyers won't even demo without SSO. Your landing
              page needs a "Book a demo" button, not a "Sign up" button.
              The first user isn't a developer — it's a procurement team.
  Developer:  $50/seat is a race to the bottom — GitHub Copilot is $19.
              Sell saved engineering hours, not seats. "This tool caught
              42 bugs last sprint" beats a per-seat invoice.
  Researcher: Three competitors pivoted from per-seat to usage-based pricing
              in 2025. CodeRabbit, Sourcery, and Codium all moved to
              per-PR or per-repo models after enterprise pushback on seat
              math for a tool that reviews code, not writes it.

[Checkpoint: Any context to add before debate?]

Round 2 — Challenges:
  Architect:  "Researcher's data on pricing pivots changes the equation.
              If we go usage-based, metering infrastructure becomes day-1
              architecture, not a nice-to-have."
  Designer:   "Developer's right on the value pitch, but procurement still
              needs a number. Usage-based with a monthly cap gives both —
              predictable budgets, honest pricing."
  Developer:  "Architect's integration concern is the real blocker. Start
              with GitHub only. One integration done well beats four done
              poorly. Validate with 10 teams before touching GitLab."
  Researcher: "Developer's 'GitHub first' aligns with the data — 73% of
              enterprise teams use GitHub. But Architect should flag: the
              GitHub API rate limit (5000/hr) will bottleneck teams over
              200 developers."

Round 3 — Convergence:
  Agreement:  Start GitHub-only. Usage-based pricing (per-PR, monthly cap).
              SSO before launch. Sell outcomes, not seats.
  Disagreement: Architect wants the integration abstraction layer now
              (10 days). Developer says YAGNI — build it when GitLab is real.
  Recommendation: Ship GitHub-only MVP with usage-based pricing and SSO.
              Build the abstraction layer when the second integration has
              a signed LOI, not before. The pricing model matters more
              than the code — validate that first.
```

One prompt. Four perspectives. The Researcher kills the pricing model with market data. The Designer catches a procurement blocker nobody was thinking about. The Developer and Architect disagree on abstraction timing — and the council resolves it with a concrete decision rule.

---

The product council does the same thing for requirements and strategy:

```
/ProductCouncil We're launching a payments API — how should we price it?

Round 1 — Initial Assessments:
  ProductManager: Transaction-based (0.5% + $0.10) aligns cost with value.
                  Developers only pay when they make money.
  Designer:       Developers hate surprise bills. Ship a pricing calculator
                  on day one. Show "your 10K transactions/mo = $60" before
                  they even create an account.
  Developer:      Metering infrastructure for real-time usage tracking is
                  three months of work. We don't have it. Flat tiers ship
                  in two weeks.
  Analyst:        At 0.5%, we're uncompetitive above $200 transactions —
                  Stripe is 2.9% but includes the payment rail. We're just
                  the API layer. Should be 10x cheaper or 10x simpler.

Round 2 — Challenges:
  ProductManager: "Analyst's pricing math is the wake-up call. We're not
                  competing with Stripe — we're competing with 'build it
                  yourself.' Price against internal eng cost, not Stripe."
  Analyst:        "Developer's right that metering is expensive. But flat
                  tiers leave money on the table above 50K transactions/mo.
                  That's exactly the segment that pays for the product."
  Developer:      "Ship flat tiers now, add metering when we have paying
                  customers funding it. Premature metering killed Segment's
                  first year — they burned runway on billing, not product."
  Designer:       "PM's 'price against internal cost' reframes everything.
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
/Council [any question worth debating]
/DeveloperCouncil [code to review, architecture to evaluate]
/ProductCouncil [requirements to validate, feature to scope]
```

Or invoke any specialist standalone — no council needed:

```
Task: Opponent — "We should rewrite the backend in Rust"
Task: Researcher — "Best practices for rate limiting in distributed systems"
Task: SecurityArchitect — "Threat model our authentication system"
```

## The debate

```
/Council [topic]  or  /DeveloperCouncil [task]  or  /ProductCouncil [spec]
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
| **Developer** | sonnet | dev, generic | Implementation quality, patterns, correctness |
| **Database** | sonnet | dev | Schema design, query performance, migrations |
| **DevOps** | sonnet | dev | CI/CD, deployment, monitoring, reliability |
| **DocumentationWriter** | sonnet | dev | README quality, API docs, developer experience |
| **Tester** | sonnet | dev | Test strategy, coverage, edge cases, regression |
| **SecurityArchitect** | sonnet | dev | Threat modeling, security policy, architectural risk |
| **Architect** | sonnet | generic | System design, boundaries, scalability, trade-offs |
| **Designer** | sonnet | generic, product | UX, user needs, accessibility, interaction design |
| **ProductManager** | sonnet | product | Requirements clarity, roadmap alignment, market fit |
| **Analyst** | sonnet | product | Success metrics, KPIs, measurement, business impact |
| **Opponent** | opus | standalone | Devil's advocate, stress-test ideas and decisions |
| **Researcher** | sonnet | standalone | Deep web research, multi-query synthesis, citations |

Every agent also works standalone via the Task tool. Opponent and Researcher can join any council as optional extras.

## Install

Works as a **standalone Claude Code plugin** or as a **forge-core module**. No compiled code — forge-council is pure markdown orchestration.

### As a forge-core module

Already registered. Deploy agents with:

```bash
Hooks/sync-agents.sh
```

### Standalone

```bash
git clone --recurse-submodules https://github.com/N4M3Z/forge-council.git
cd forge-council
make install
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
| `/Council` | Cross-domain 3-round debate with Architect, Designer, Developer, Researcher |
| `/DeveloperCouncil` | Code review, architecture, debugging with up to 6 dev specialists |
| `/ProductCouncil` | Requirements review, feature scoping, strategy with PM, Designer, Dev, Analyst |
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
| `agents.council` | 10 agents | Agents available for council selection |
| `agents.standalone` | Opponent, Researcher | Agents that operate independently |
| `councils.developer.roles` | 6 dev specialists | Developer council roster |
| `councils.generic.roles` | Architect, Designer, Developer, Researcher | Generic council roster |
| `councils.product.roles` | PM, Designer, Developer, Analyst | Product council roster |

Model selection lives in agent frontmatter (`agents/*.md`). To change a model, edit the agent file and re-run the agent sync.

## Architecture

Twelve markdown agent files, four skills, and a deployment utility in forge-lib.

```
agents/
  Architect.md            # System design, boundaries, scalability
  Analyst.md              # Metrics, KPIs, business impact
  Database.md             # Schema design, query performance
  Designer.md             # UX, user needs, accessibility
  Developer.md            # Implementation quality, patterns
  DevOps.md               # CI/CD, deployment, monitoring
  DocumentationWriter.md  # README quality, API docs, DX
  Opponent.md             # Devil's advocate, critical analysis
  ProductManager.md       # Requirements, roadmap, market fit
  Researcher.md           # Web research, multi-query synthesis
  SecurityArchitect.md    # Threat modeling, security policy
  Tester.md               # Test strategy, coverage, edge cases
skills/
  Council/                # Generic 3-round debate
  DeveloperCouncil/       # Developer council orchestration
  ProductCouncil/         # Product council orchestration
  Demo/                   # Interactive showcase
lib/
  install-agents.sh       # Agent deployment utility (from forge-lib)
defaults.yaml             # Agent roster + council composition
module.yaml               # Module metadata
```

Each agent file contains `claude.*` frontmatter (name, model, description, tools) plus a structured body: Role, Expertise, Instructions, Output Format, Constraints. Agents are deployed to `~/.claude/agents/` by `sync-agents.sh` (forge-core) or `install-agents.sh` (standalone).

> `CLAUDE.md` and `AGENTS.md` are autogenerated by `/Init`. Do not edit directly — run `/Update` to regenerate.
