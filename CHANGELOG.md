# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/).

## [Unreleased]

### Added

- `skills/StagedDelivery/SKILL.md` -- council-first plan/build/verify loop: routes scope to DeveloperCouncil/ProductCouncil/KnowledgeCouncil (individual specialists only when no council fits), a conditional opponent gate, a user/file decision gate, and a deferred-menu ledger. Stays in-module; forge-core skills are optional. Optional per-prompt reinforcement hook documented for manual wiring in `INSTALL.md` (not deployed by forge).
- `rules/AgentTeams.md` -- documents the `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` gate, mandatory teardown protocol, and the known upstream agent-team bugs (#49671, #53160, #55824, #59717).
- Step 0 gate check inline in every council skill (DebateCouncil, DeveloperCouncil, ProductCouncil, KnowledgeCouncil, HiringCouncil) -- replaces the previous `@AgentTeams.md` injection.
- `.githooks/pre-commit` with `prek` / `forge validate` cascade and hash-verified `validate.sh` fallback (canonical source: forge-cli `templates/init/.githooks/pre-commit`).
- `.pre-commit-config.yaml` driving shellcheck, gitleaks, and `forge validate`.
- `.gitleaks.toml` for secret scanning configuration.
- `.gitattributes` enforcing LF line endings.
- `.github/workflows/quality.yaml` CI pipeline running `prek-action`.
- `CHANGELOG.md`, `CONTRIBUTING.md`, `SECURITY.md`, `CODEOWNERS` -- GitHub community health files.

### Changed

- Migrated from `forge-lib` git submodule to the external `forge-cli` binary.
- `Makefile` reduced to `install` / `validate` / `clean` targets that delegate to `forge` and `.githooks/pre-commit`.
- `defaults.yaml` providers section uses the `models.{fast,strong}: [<id>]` schema expected by forge-cli (was a flat list).
- Council skill rosters removed from `defaults.yaml` -- each `skills/*/SKILL.md` is the source of truth for its roster.

### Removed

- `lib/` git submodule and `.gitmodules` -- replaced by `forge-cli` external binary.
- `AgentTeams.md` (repo root) -- replaced by `rules/AgentTeams.md`, deployed as a rule rather than `@`-included.
- `VERIFY.md` -- verification steps embedded in `INSTALL.md` per the Mintlify standard.
- `install-teams-config`, `install-agents`, `install-skills`, `verify-skills`, `verify-agents`, `lint`, `check`, `init`, `test` Makefile targets -- `forge install` and `forge validate` cover the same surface.
- `agents.*.scope` and the top-level `teams:` field from `defaults.yaml` -- forge-cli does not consume them.

## [0.4.0]

### Added

- Hiring council specialists (TalentAcquisition, HiringManager, CompensationAnalyst, ExecutiveAdvisor, CzechLawAdvisor, IndustryExpert) and HiringCouncil skill.
- `rules/LearningCapture.md` -- post-teardown agent that distills council verdicts into reusable rules.
- Skill suggestions in `defaults.yaml` per agent.

### Changed

- Council skill descriptions tightened with explicit USE WHEN triggers.

[Unreleased]: https://github.com/N4M3Z/forge-council/compare/v0.4.0...HEAD
[0.4.0]: https://github.com/N4M3Z/forge-council/releases/tag/v0.4.0
