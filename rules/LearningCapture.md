---
paths:
  - "**/forge-council/skills/**"
---

After council teardown (shutdown_request + TeamDelete), spawn a **foreground Task agent** to capture transferable learnings from the verdict:

- `subagent_type: "general-purpose"`
- `description: "capture council learnings"`
- Agent prompt: include the full verdict text and these instructions:

> Review the council verdict. Extract 1-3 transferable learnings — principles, patterns, or decisions that apply beyond this specific council topic. Skip one-off findings.
>
> For each learning, present an AskUserQuestion: "Capture this learning?" with options: Capture / Skip / Skip All.
>
> For each "Capture", write a `.claude/rules/` file in the repo. Follow the concise rule format of existing rules.
>
> Report summary: N captured, M skipped.
