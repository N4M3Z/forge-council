# Contributing

## Getting Started

```sh
git clone https://github.com/N4M3Z/forge-council.git
cd forge-council
make install
```

Prerequisites:

- `forge` CLI on PATH (install from [forge-cli](https://github.com/N4M3Z/forge-cli))
- `shellcheck` for shell linting
- At least one AI provider CLI (Claude Code, Gemini CLI, Codex, or OpenCode)

## Modification Workflows

### Adding a new agent

1. Create `agents/YourAgent.md` with frontmatter (name, description, version) and structured body (Role, Expertise, Instructions, Output Format, Constraints).
2. Add deployment config to `defaults.yaml` under `agents:` (model tier, tools).
3. If joining a council, list the agent in the corresponding `skills/*/SKILL.md` roster.
4. Preview: `forge assemble` (writes to `build/`, does not deploy).
5. Commit: `feat: add YourAgent for [domain]`.

### Modifying a skill

1. Edit `skills/SkillName/SKILL.md`.
2. Keep numbered step structure intact -- moderators follow the steps verbatim.
3. Test with a council invocation in a real session.
4. Commit: `feat: improve [skill] debate flow`.

### Updating models or tools

1. Edit `defaults.yaml` under `agents:` (or `config.yaml` for local overrides).
2. Re-run `make install`.
3. Restart your session for changes to load.

## Conventions

See [CLAUDE.md](CLAUDE.md) and [AGENTS.md](AGENTS.md) for the full project conventions.

## Git

Conventional Commits: `type: description`. Lowercase, no trailing period, no scope.

Types: `feat`, `fix`, `docs`, `chore`, `refactor`, `test`.

## Pull Requests

1. Fork and create a branch.
2. Make changes following the conventions above.
3. Run `make validate` and verify it passes.
4. Open a PR against `main`.

CI runs validation on every PR. The `main` branch requires passing CI before merge.
