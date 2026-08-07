#!/bin/bash
# Forge loop push guard (maintainer repo edition) — PreToolUse hook on Bash.
#
# The forge loop needs to publish PR branches, but Forge's wall says agents
# don't push. This is that exception, made mechanical — and it is a WHITELIST,
# not a filter: if a command could publish anything, it must match the ONE
# sanctioned shape exactly, or it is refused.
#
#   [cd <path> && ] git push [-u|--set-upstream] origin agent/<branch>
#
# Refused: any other remote or branch, force/delete/tags/mirror/prune, src:dst
# refspecs, multiple refs, git global flags (-c/-C/--git-dir/…), send-pack,
# subtree push, redirects, chained or multi-line commands, wrapper prefixes
# (command/env/sudo/…) — anything whose meaning this guard cannot verify by
# inspection. Deviating from the sanctioned form is not an error to be parsed
# around: run the plain command instead.
#
# The whole command is folded to ONE line before matching, so a multi-line or
# backslash-continued command cannot hide a second push behind a sanctioned
# first line (grep anchors per line, not per command).
#
# Residual, by design: shell EXPANSION cannot be resolved by a string guard —
# $VAR, eval, command substitution, and glob-spelled paths reach the shell as
# something this hook never saw. Branch protection and human review back this
# wall — the shipped settings.json ALLOWS the sanctioned push shape outright, so
# there is no ask-prompt behind it.

INPUT=$(cat)

if command -v jq >/dev/null 2>&1; then
  COMMAND=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)
else
  # Portable fallback: the "command" value, honoring backslash escapes so a
  # quote inside the command can't truncate what we extract.
  # decode the JSON escapes too — \n/\t left raw would fuse words together
  # and hide keywords from every check below.
  COMMAND=$(printf '%s' "$INPUT" \
    | grep -oE '"command"[[:space:]]*:[[:space:]]*"([^"\\]|\\.)*"' | head -1 \
    | sed 's/^"command"[[:space:]]*:[[:space:]]*"//; s/"$//' \
    | sed 's/\\n/ /g; s/\\t/ /g; s/\\r/ /g; s/\\"/"/g; s/\\\\/\\/g')
fi

[ -z "$COMMAND" ] && exit 0

# Fold to one line FIRST (so `\<newline>` becomes whitespace, not a line break),
# then collapse quoting evasion (git\ push, "git" "push", g'i't …).
# Matched against, never executed.
DETECT=$(printf '%s' "$COMMAND" | tr '\n\r\t' '   ' | sed 's/\\//g; s/"//g; s/'"'"'//g')

# Message/title/body VALUES are data, not command words: a commit message or PR
# title that says "merge" or "push" must not trip the keyword walls below. Only
# unambiguous long-form message flags are stripped (never -d/-b/-t/-F, whose
# short spellings mean other things to gh), and only for the KEYWORD checks —
# the anchored whitelists still match the untouched command, so the sanctioned
# shape stays exact.
STRIPMSG='s/(^|[[:space:]])(-m|--message|--title|--body|--body-file|--description|--notes)([[:space:]]+|=)("[^"]*"|'"'"'[^'"'"']*'"'"'|[^[:space:]]*)/\1\2 MSGVALUE/g'
DETECT_KW=$(printf '%s' "$COMMAND" | tr '\n\r\t' '   ' | sed -E "$STRIPMSG" | sed 's/\\//g; s/"//g; s/'"'"'//g')

# Does this command touch a publishing verb at all? Trigger broadly: git AND
# push in any spelling (including `-c alias.x=push`), or a low-level publish
# verb. If neither appears, it is none of this guard's business.
if ! printf '%s' "$DETECT_KW" | grep -q 'send-pack'; then
  printf '%s' "$DETECT_KW" | grep -q 'git'  || exit 0
  printf '%s' "$DETECT_KW" | grep -q 'push' || exit 0
fi

# It does. Then it must be exactly the sanctioned shape — whole command.
printf '%s' "$DETECT" \
  | grep -qE '^[[:space:]]*(cd[[:space:]]+[^[:space:]|&;<>$`()]+[[:space:]]*&&[[:space:]]*)?git[[:space:]]+push([[:space:]]+(-u|--set-upstream))?[[:space:]]+origin[[:space:]]+agent/[A-Za-z0-9._-][A-Za-z0-9._/-]*[[:space:]]*$' \
  && exit 0

echo "BLOCKED: '$COMMAND' is not the sanctioned publish. Loop pushes are exactly '[cd <path> && ] git push [-u] origin agent/<branch>' — no other branch or remote, no extra flags, no redirects, no chained or multi-line commands, no wrappers. The human pushes everything else." >&2
exit 2
