#!/bin/bash
# Forge model-routing logger. Fires PreToolUse on the Task tool and appends one
# line per agent spawn to the current venture's routing ledger, so the 70/20/10
# model mix is actually MEASURABLE (the audit found it was only ever a target,
# never measured). Logging only — it NEVER blocks a spawn (always exits 0).
#
# The model is read from the spawned agent's OWN frontmatter
# (.claude/agents/<agent>.md `model:` line) — the single source of truth — so
# there is no separate agent->model map to keep in sync.

INPUT=$(cat)
ROOT="${CLAUDE_PROJECT_DIR:-.}"

# The spawned agent's name (the Task tool's subagent_type). jq if present, else
# a portable sed fallback so the hook works even where jq isn't installed.
if command -v jq >/dev/null 2>&1; then
  AGENT=$(printf '%s' "$INPUT" | jq -r '.tool_input.subagent_type // empty' 2>/dev/null)
else
  AGENT=$(printf '%s' "$INPUT" | sed -n 's/.*"subagent_type"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
fi
[ -z "$AGENT" ] && exit 0

# Model = the agent's own declared model (single source of truth: its frontmatter).
AGENT_FILE="$ROOT/.claude/agents/${AGENT}.md"
MODEL=unknown
[ -f "$AGENT_FILE" ] && MODEL=$(sed -n 's/^model:[[:space:]]*//p' "$AGENT_FILE" | head -1)
[ -z "$MODEL" ] && MODEL=unknown

# Append to the most recent venture's ledger (best-effort; never blocks the run).
TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)
VDIR=$(ls -td "$ROOT"/ventures/*/ 2>/dev/null | head -1)
[ -n "$VDIR" ] && printf '%s\t%s\t%s\n' "$TS" "$AGENT" "$MODEL" >> "${VDIR}routing-ledger.tsv" 2>/dev/null
exit 0
