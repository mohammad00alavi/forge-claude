#!/bin/bash
# Forge auto-merge guard (maintainer repo edition) — PreToolUse hook on Bash.
# Option A ships the merge on the agent, so the wall moves into this hook:
# `gh pr merge` is allowed ONLY when the human-set LOOP_AUTOMERGE variable is
# true AND a fresh forge-lint gate passes. Everything else about the command
# stream passes through untouched. Fail-closed: if the toggle can't be read
# (no gh, no network), merging is blocked — off is the default state.
#
# Wire in .claude/settings.json (repo-local) alongside block-dangerous-git.sh.

INPUT=$(cat)

if command -v jq >/dev/null 2>&1; then
  COMMAND=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)
else
  COMMAND=$(printf '%s' "$INPUT" | sed -n 's/.*"command"[[:space:]]*:[[:space:]]*"\(.*\)".*/\1/p')
fi

[ -z "$COMMAND" ] && exit 0

# Only merge commands concern this guard.
printf '%s' "$COMMAND" | grep -qE 'gh[[:space:]]+pr[[:space:]]+merge' || exit 0

# Disarming is always allowed (it's how /automerge off cleans up).
printf '%s' "$COMMAND" | grep -q -- '--disable-auto' && exit 0

# Bypassing branch protections is never allowed, toggle regardless.
if printf '%s' "$COMMAND" | grep -q -- '--admin'; then
  echo "BLOCKED: 'gh pr merge --admin' bypasses protections. Agents never use --admin. Drop the flag or leave the PR for the human." >&2
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

REPO="mohammad00alavi/forge-claude"

# The merge must target THIS repo: the toggle read below is forge-claude's, so a
# -R/--repo pointing anywhere else is never sanctioned (checked before the
# toggle so cross-repo attempts are blocked deterministically, even offline).
TARGET=$(printf '%s' "$COMMAND" | sed -nE 's/.*(--repo|-R)[[:space:]=]*([^[:space:]]+).*/\2/p' | head -1)
if [ -n "$TARGET" ] && [ "$TARGET" != "$REPO" ]; then
  echo "BLOCKED: this merge targets '$TARGET' but the toggle being honored is $REPO's. Cross-repo merges are never sanctioned — drop the flag or leave that PR for its own human." >&2
  exit 2
fi

# Gate root: the contract runs the fresh gate in the PR's OWN worktree. Use the
# session's cwd when it is a Forge checkout (worktree merges gate the worktree);
# fall back to the project root otherwise.
CWD=""
command -v jq >/dev/null 2>&1 && CWD=$(printf '%s' "$INPUT" | jq -r '.cwd // empty' 2>/dev/null)
ROOT="${CLAUDE_PROJECT_DIR:-$(pwd)}"
[ -n "$CWD" ] && [ -f "$CWD/maintenance/forge-lint.sh" ] && ROOT="$CWD"

# 1. The human-set toggle. Unset, false, or unreadable == OFF.
STATE=$(gh variable get LOOP_AUTOMERGE -R "$REPO" 2>/dev/null)
if [ "$STATE" != "true" ]; then
  echo "BLOCKED: LOOP_AUTOMERGE is not 'true' (read: '${STATE:-unreadable}'). Auto-merge is off: stop at the ready PR and request review. The human flips this with /automerge on." >&2
  exit 2
fi

# 2. Fresh gate — the gate decides done, never a remembered result.
if ! bash "$ROOT/maintenance/forge-lint.sh" >/dev/null 2>&1; then
  echo "BLOCKED: forge-lint is red in $ROOT. Fix the gate (bash maintenance/forge-lint.sh) or leave the PR ready with a comment. Toggle-on never overrides a red gate." >&2
  exit 2
fi

# Toggle on + gate green: the merge may proceed. The rest of the contract
# (threads resolved, CI green, behind-zero, no human:*/halt, escalate paths)
# is the merge step's job — see maintenance/forge-loop-merge-step.md.
exit 0
