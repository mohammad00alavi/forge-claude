#!/bin/bash
# Forge loop push guard (maintainer repo edition) — PreToolUse hook on Bash.
# The forge loop needs to push PR branches, but Wall 1 says agents don't push.
# This is the branch-scoped exception, made mechanical: a `git push` is allowed
# ONLY when it pushes an agent/* branch to origin — nothing else, ever.
# It TIGHTENS the existing ask-gate (settings still prompt); it never widens it.
#
# Allowed:  git push -u origin agent/gh-42   ·  git push origin agent/fix-lint
# Blocked:  push to main/master/release*/HEAD, any --force/-f, --delete/-d,
#           --mirror/--all/--tags, tag refspecs, refspecs with a colon,
#           non-origin remotes, and any push whose target can't be parsed.

INPUT=$(cat)

if command -v jq >/dev/null 2>&1; then
  COMMAND=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)
else
  COMMAND=$(printf '%s' "$INPUT" | sed -n 's/.*"command"[[:space:]]*:[[:space:]]*"\(.*\)".*/\1/p')
fi

[ -z "$COMMAND" ] && exit 0

# Shell-quoting evasion (git\ push, "git" "push", g'i't …): run every check
# against a normalized copy with backslashes and quotes stripped. $VAR/eval
# indirection is beyond a string guard — the ask-gate and branch protection
# back this wall.
DETECT=$(printf '%s' "$COMMAND" | sed 's/\\//g; s/"//g; s/'"'"'//g')

# Global git flags before 'push' (-c/-C/--git-dir/…) can dodge the plain
# 'git push' detection below and retarget the repo or config — never sanctioned.
if printf '%s' "$DETECT" | grep -qE 'git([[:space:]]+-[^[:space:]]+([[:space:]]+[^-[:space:]][^[:space:]]*){0,2})+[[:space:]]+push([[:space:]]|$)'; then
  echo "BLOCKED: git global flags before 'push' are not allowed. Loop pushes are exactly 'git push [-u] origin agent/<branch>' — nothing else. The human pushes everything else." >&2
  exit 2
fi

# Only push commands concern this guard.
printf '%s' "$DETECT" | grep -qE 'git[[:space:]]+push' || exit 0

block() { echo "BLOCKED: $1 Loop pushes are exactly 'git push [-u] origin agent/<branch>' — nothing else. The human pushes everything else." >&2; exit 2; }

# Never any force/delete/mass flavor, anywhere in the command.
printf '%s' "$DETECT" | grep -qE -- '--force|--force-with-lease|(^|[[:space:]])-f([[:space:]]|$)|--delete|(^|[[:space:]])-d([[:space:]]|$)|--mirror|--all|--tags|--prune' \
  && block "force/delete/mass push flags are never allowed."

# Refspecs with a colon (src:dst) can retarget protected refs.
printf '%s' "$DETECT" | grep -qE 'git[[:space:]]+push[^|&;]*[^-][[:space:]][^[:space:]]*:' \
  && block "explicit refspecs (src:dst) are not allowed."

# Extract the first `git push …` segment (stop at chaining operators).
SEG=$(printf '%s' "$DETECT" | grep -oE 'git[[:space:]]+push[^|&;]*' | head -1)

# Strip flags; expect exactly: remote 'origin' + one agent/* branch.
set -- $SEG                      # $1=git $2=push $3...
shift 2
REMOTE=""; BRANCH=""; EXTRA=0
for tok in "$@"; do
  case "$tok" in
    -u|--set-upstream) ;;                       # the one flag we accept
    -*) block "flag '$tok' is not allowed on a loop push." ;;
    *) if [ -z "$REMOTE" ]; then REMOTE="$tok"
       elif [ -z "$BRANCH" ]; then BRANCH="$tok"
       else EXTRA=1; fi ;;
  esac
done

[ "$EXTRA" = 1 ] && block "multiple refs in one push are not allowed."
[ "$REMOTE" = "origin" ] || block "remote '$REMOTE' is not 'origin'."
case "$BRANCH" in
  agent/?*) exit 0 ;;                            # the sanctioned shape
  *) block "branch '${BRANCH:-<none>}' is not an agent/* branch." ;;
esac
