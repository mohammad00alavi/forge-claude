#!/bin/bash
# Forge git guardrail (adapted from mattpocock's git-guardrails-claude-code).
# Inspects the ACTUAL command string — catches the blocked op anywhere in the
# command, including chained forms like `cd foo && git push` that a settings.json
# deny-glob can miss. This is what makes the push wall airtight under Bash(*).
#
# Forge-specific: blocks push/merge/force/reset/clean/branch -D — but ALLOWS
# git add/commit/gh pr create (Forge's model: local git is free, only the
# outward/destructive ops are walled; the human pushes after local review).

INPUT=$(cat)

# Extract the command. Prefer jq if present; fall back to a portable sed/grep
# parse so the hook works even where jq isn't installed.
if command -v jq >/dev/null 2>&1; then
  COMMAND=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)
else
  # Portable fallback: pull the value of "command":"..." (handles escaped quotes)
  COMMAND=$(printf '%s' "$INPUT" | sed -n 's/.*"command"[[:space:]]*:[[:space:]]*"\(.*\)".*/\1/p')
fi

[ -z "$COMMAND" ] && exit 0

# Operations Forge walls off (the human does these, or they're destructive):
DANGEROUS_PATTERNS=(
  "git push"            # push to remote — human-only, after local review
  "push --force"
  "git merge"           # merge — human-only
  "git reset --hard"    # destructive history/worktree wipe
  "git clean -f"        # deletes untracked files
  "git branch -D"       # force-delete branch
  "git checkout \."     # discards all local changes
  "git restore \."      # discards all local changes
)

for pattern in "${DANGEROUS_PATTERNS[@]}"; do
  if printf '%s' "$COMMAND" | grep -qE "$pattern"; then
    echo "BLOCKED: '$COMMAND' matches walled git operation '$pattern'. In Forge, agents commit locally and open PRs, but the human pushes/merges after reviewing locally. You do not have authority to run this — prepare it locally and surface it instead." >&2
    exit 2
  fi
done

exit 0
