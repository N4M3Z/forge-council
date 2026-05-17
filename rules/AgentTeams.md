When the user invokes a council skill (DebateCouncil, DeveloperCouncil, ProductCouncil, KnowledgeCouncil, HiringCouncil), check `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` before spawning:

```bash
echo "${CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS:-0}"
```

- `1`: use `TeamCreate` + parallel `Task` with `team_name` (Steps 3-6 of the skill)
- `0` or missing: sequential fallback via `Task` without `team_name` (Step 7)

## Why TeamCreate / TeamDelete matter

The agent teams primitive is the only way to spawn multiple specialists that can address each other by name in subsequent rounds via `SendMessage`. Without `TeamCreate`, each Round 2 / Round 3 dispatch must re-prime every specialist with the full transcript, which loses cross-specialist references and burns tokens.

Known agent-team failure modes ([upstream tracker][CC]):

- `TeamDelete` blocks until every member acknowledges `shutdown_request` ([#49671][I49671]) -- always send the shutdown before calling `TeamDelete`, then verify members exited.
- Stale teams after session crash deadlock both `TeamCreate` and `TeamDelete` ([#53160][I53160]) -- if `TeamCreate` returns "already exists" and `TeamDelete` returns "no team name found", the team config in `~/.claude/teams/{name}/` survived a crash and needs manual cleanup.
- Orchestrator lead context can become stuck even after teammates exit cleanly ([#55824][I55824]) -- a fresh session resolves it; from a running session call `TeamDelete` explicitly even if the team appears empty.
- Models pattern-match "create an agent team" to plain `Agent` instead of `TeamCreate` when the team primitives are deferred ([#59717][I59717]) -- always load `TeamCreate`, `TeamDelete`, and `SendMessage` via `ToolSearch` before Step 3.

## Mandatory teardown

Every council run must end with: `shutdown_request` to each member → confirm `idle_notification` / exit → `TeamDelete`. Skipping teardown leaves zombie teams that block the next session's `TeamCreate`.

[CC]: https://github.com/anthropics/claude-code/issues?q=is%3Aissue+agent+teams
[I49671]: https://github.com/anthropics/claude-code/issues/49671
[I53160]: https://github.com/anthropics/claude-code/issues/53160
[I55824]: https://github.com/anthropics/claude-code/issues/55824
[I59717]: https://github.com/anthropics/claude-code/issues/59717
