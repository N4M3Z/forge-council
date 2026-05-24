# Agent Teams

## Step 0: Gate Check

```bash
echo "${CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS:-0}"
```

- If `1`: use agent teams (TeamCreate + parallel Task spawning)
- If `0` or missing: fall back to sequential mode (see Step 7)
