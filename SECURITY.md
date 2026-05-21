# Security

## Reporting a Vulnerability

Email **security@martinzeman.net** with `[forge-council security]` in the subject line. Include the affected file, reproduction steps, and impact. Expect acknowledgement within 72 hours.

## Scope

forge-council is pure markdown -- agent definitions, skill orchestration prompts, and YAML configuration. There is no compiled code, no runtime, and no network surface owned by this module. The threat model is therefore limited to prompt-injection and content-integrity concerns.

In scope:

- Prompt content in agents or skills that could be exploited to exfiltrate data, bypass tool restrictions, or hijack a council debate.
- Tool assignments in `defaults.yaml` that grant broader access than the agent's role requires.
- Provider-specific transforms (kebab-case, TOML conversion) that could materially change behaviour relative to the canonical Markdown source.

Out of scope:

- Vulnerabilities in the AI provider runtime (Claude Code, Gemini CLI, Codex, OpenCode) -- report upstream.
- Vulnerabilities in `forge-cli` itself -- see [forge-cli](https://github.com/N4M3Z/forge-cli).
- Bugs in agent behaviour that are not security relevant -- open a regular issue instead.

## Mitigations

- Agent files cap tool access to the minimum required (Read/Grep/Glob for most, Bash only where execution is needed, Write/Edit only for SoftwareDeveloper and QaTester).
- `defaults.yaml` is the single source of truth for tools; agent frontmatter cannot expand the allowlist.
- Council skills are confined to the orchestration role -- they spawn specialists via `Task` and never invoke shell commands directly.

## Maintainer Responsibilities

- Review tool assignments whenever an agent's role expands.
- Verify the SLSA provenance sidecar after every `forge install` (`forge provenance ~/.claude`).
- Run `forge validate` before merging changes to ensure agent and skill conventions hold.
