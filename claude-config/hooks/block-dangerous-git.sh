#!/bin/bash
# Forge git guardrail (adapted from mattpocock's git-guardrails-claude-code).
# Inspects the ACTUAL command string — catches the blocked op anywhere in the
# command, including chained forms like `cd foo && git push` that a settings.json
# deny-glob can miss. This is what makes the push wall airtight under Bash(*).
#
# Forge-specific: blocks merge/force/reset/clean/branch -D and every push that
# is not the forge-loop's scoped exception — but ALLOWS git add/commit/gh pr
# create (Forge's model: local git is free, only the outward/destructive ops are
# walled). The ONE sanctioned push is `git push [-u] origin agent/<branch>` (the
# loop publishing its PR branch — loop-push-guard.sh validates it strictly);
# everything else the human pushes after local review.
# Also blocks raw-shell writes to .claude/settings.json: the Edit/Write tools are
# denied for it, and this closes the Bash(*) gap so the safety walls can't be
# rewritten by an agent. That file is human-only.

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

# Push scope — the forge-loop exception. Agents may push ONLY an agent/* branch
# to origin (publishing a loop PR branch); every push segment in the command must
# match that exact shape or the whole command is blocked. loop-push-guard.sh then
# validates the sanctioned segment strictly (flags, single ref, no refspecs).
#
# Global git flags before 'push' (-c/-C/--git-dir/…) can dodge the plain
# 'git push' detection and retarget the repo or config — never sanctioned.
if printf '%s' "$COMMAND" | grep -qE 'git([[:space:]]+-[^[:space:]]+([[:space:]]+[^-[:space:]][^[:space:]]*){0,2})+[[:space:]]+push([[:space:]]|$)'; then
  echo "BLOCKED: '$COMMAND' uses git global flags before 'push'. The only sanctioned push is plain 'git push [-u] origin agent/<branch>' — no -c/-C/--git-dir/other global flags." >&2
  exit 2
fi
if printf '%s' "$COMMAND" | grep -qE 'git[[:space:]]+push'; then
  while IFS= read -r seg; do
    if ! printf '%s' "$seg" | grep -qE '^git[[:space:]]+push[[:space:]]+((-u|--set-upstream)[[:space:]]+)?origin[[:space:]]+agent/[^:[:space:]]+[[:space:]]*$'; then
      echo "BLOCKED: '$COMMAND' pushes outside the loop scope. Agents may run exactly 'git push [-u] origin agent/<branch>' (the forge-loop publishing its PR branch); the human pushes everything else after local review." >&2
      exit 2
    fi
  done < <(printf '%s' "$COMMAND" | grep -oE 'git[[:space:]]+push[^|&;]*')
fi

# Settings lockdown — block shell writes to .claude/settings.json. Edit/Write are
# denied for it, but Bash(*) could still rewrite it, so close that here. Matches a
# redirect / sed -i / tee|cp|mv|dd|install|truncate|ln that TARGETS the file (reads
# like `cat .claude/settings.json` stay allowed).
if printf '%s' "$COMMAND" | grep -qE '(>>?[[:space:]]*[^ |&;]*\.claude/settings\.json|sed[[:space:]]+-i[^|&;]*\.claude/settings\.json|(tee|cp|mv|dd|install|truncate|ln)[[:space:]][^|&;]*\.claude/settings\.json)'; then
  echo "BLOCKED: '$COMMAND' looks like a shell write to .claude/settings.json — that file holds Forge's safety walls and is human-only. Edit it by hand, never via an agent." >&2
  exit 2
fi

exit 0
