#!/bin/bash
# Forge auto-merge guard (shipped to installs as .claude/hooks/) — PreToolUse on Bash.
# Forge's wall: agents never push, merge, or deploy. /automerge is the ONE
# sanctioned, opt-in exception, and this hook is its mechanical edge:
# `gh pr merge` is allowed only when the human has set the repo variable
# LOOP_AUTOMERGE to true (via /automerge on). Default state — variable unset,
# gh missing, offline — is OFF, so a fresh install behaves exactly as before:
# agents stop at a ready PR and the human merges. Fail-closed by construction.

INPUT=$(cat)

if command -v jq >/dev/null 2>&1; then
  COMMAND=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)
else
  COMMAND=$(printf '%s' "$INPUT" | sed -n 's/.*"command"[[:space:]]*:[[:space:]]*"\(.*\)".*/\1/p')
fi

[ -z "$COMMAND" ] && exit 0

# Only merge commands concern this guard.
printf '%s' "$COMMAND" | grep -qE 'gh[[:space:]]+pr[[:space:]]+merge' || exit 0

# Disarming is always allowed (how /automerge off cleans up armed PRs).
printf '%s' "$COMMAND" | grep -q -- '--disable-auto' && exit 0

# Bypassing branch protections is never allowed, toggle regardless.
if printf '%s' "$COMMAND" | grep -q -- '--admin'; then
  echo "BLOCKED: 'gh pr merge --admin' bypasses branch protections. Agents never use --admin. Drop the flag or leave the PR for the human." >&2
  exit 2
fi

# The contract's merge mode is exactly --squash --delete-branch; merge commits,
# rebases, and kept branches are never sanctioned (checked before the toggle so
# a wrong mode is blocked deterministically, even offline).
if printf '%s' "$COMMAND" | grep -qE -- '--merge|--rebase'; then
  echo "BLOCKED: the contract merge mode is --squash (never --merge/--rebase). Use 'gh pr merge <N> --squash --delete-branch' or leave the PR for the human." >&2
  exit 2
fi
if ! printf '%s' "$COMMAND" | grep -q -- '--squash' || ! printf '%s' "$COMMAND" | grep -q -- '--delete-branch'; then
  echo "BLOCKED: the contract merge is exactly 'gh pr merge <N> --squash --delete-branch' — both flags required." >&2
  exit 2
fi

# The human-set toggle, read from THIS project's repo (hook cwd == project root).
STATE=$(gh variable get LOOP_AUTOMERGE 2>/dev/null)
if [ "$STATE" != "true" ]; then
  echo "BLOCKED: agents do not merge in this project (LOOP_AUTOMERGE read: '${STATE:-unreadable}'). Open the PR ready and request review — the human merges. The human can opt in with /automerge on." >&2
  exit 2
fi

# Toggle is on: the merge may proceed IF the /automerge contract was satisfied —
# project gate green, review threads (incl. bots) resolved, CI green, PR not
# behind its base (gh pr update-branch), no human:*/automerge:halt labels, no
# protected paths in the diff. That contract lives in the /automerge command.
exit 0
