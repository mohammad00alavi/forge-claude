#!/bin/bash
# Forge git guardrail (adapted from mattpocock's git-guardrails-claude-code).
#
# DESIGN (v4, after five adversarial review rounds): do NOT try to emulate the
# shell, and do NOT key any check to a keyword's POSITION — git and gh accept
# flags before, between and after subcommands (`git -C dir merge`,
# `git -c alias.m=merge m`, `gh pr -R x merge 99`), so every position-sensitive
# pattern leaks. Three models, all fail-closed:
#
#   1. WHITELIST for the sanctioned exception. A command that could publish
#      anything (mentions git AND push, or send-pack) must match the ONE
#      allowed shape exactly:
#         [cd <path> && ] git push [-u|--set-upstream] origin agent/<branch>
#      Anything else is refused — deviation cannot be safely interpreted.
#   2. POSITION-FREE DENY for destructive ops: if the command mentions git and
#      also mentions a destructive verb/flag ANYWHERE, it is refused.
#   3. .claude/ is human-only: every segment of a command naming it must be a
#      pure read verb, with no redirection anywhere.
#
# The whole command is folded to ONE line for the anchored whitelist, while the
# .claude walk splits on newlines too — so neither a multi-line command nor a
# backslash continuation can hide a second command behind a harmless first one.
#
# DELIBERATE over-blocking: because (2) and (3) match text anywhere, a command
# that only MENTIONS a walled word (`git commit -m "fix the git merge docs"`,
# or anything containing both "git" and "push") is refused. That is the intended
# trade — a false refusal costs a rephrase, a false allow costs the wall.
#
# Residual, by design: shell EXPANSION cannot be resolved by a string guard —
# $VAR, eval, command substitution, and glob-spelled paths (`.cla*/set*.json`)
# reach the shell as something this hook never saw. The settings ask-gate,
# branch protection, and human review back this wall.

INPUT=$(cat)

# Extract the command. Prefer jq if present; fall back to a portable parse that
# honors backslash escapes so a quote inside the command can't truncate it.
if command -v jq >/dev/null 2>&1; then
  COMMAND=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)
else
  # decode the JSON escapes too — \n/\t left raw would fuse words together
  # and hide keywords from every check below.
  COMMAND=$(printf '%s' "$INPUT" \
    | grep -oE '"command"[[:space:]]*:[[:space:]]*"([^"\\]|\\.)*"' | head -1 \
    | sed 's/^"command"[[:space:]]*:[[:space:]]*"//; s/"$//' \
    | sed 's/\\n/ /g; s/\\t/ /g; s/\\r/ /g; s/\\"/"/g; s/\\\\/\\/g')
fi

[ -z "$COMMAND" ] && exit 0

# Quote/backslash stripping and path-spelling collapse, applied twice: once
# preserving newlines (for the per-segment .claude walk) and once folded to a
# single line (for the anchored whitelist).
UNFOLDED=$(printf '%s' "$COMMAND" | tr '\r\t' '  ' \
  | sed 's/\\//g; s/"//g; s/'"'"'//g; s|//*|/|g; s|/\./|/|g; s|/\./|/|g; s|/\./|/|g')
DETECT=$(printf '%s' "$UNFOLDED" | tr '\n' ' ')

# Message/title/body VALUES are data, not command words: a commit message or PR
# title that says "merge" or "push" must not trip the keyword walls below. Only
# unambiguous long-form message flags are stripped (never -d/-b/-t/-F, whose
# short spellings mean other things to gh), and only for the KEYWORD checks —
# the anchored whitelists still match the untouched command, so the sanctioned
# shape stays exact.
STRIPMSG='s/(^|[[:space:]])(-m|--message|--title|--body|--body-file|--description|--notes)([[:space:]]+|=)("[^"]*"|'"'"'[^'"'"']*'"'"'|[^[:space:]]*)/\1\2 MSGVALUE/g'
DETECT_KW=$(printf '%s' "$COMMAND" | tr '\n\r\t' '   ' | sed -E "$STRIPMSG" \
  | sed 's/\\//g; s/"//g; s/'"'"'//g; s|//*|/|g; s|/\./|/|g; s|/\./|/|g; s|/\./|/|g')

block() { echo "BLOCKED: $1" >&2; exit 2; }
# grep exits 0 on match, 1 on no-match, and >1 on a REGEX ERROR. Treating an
# error as "no match" would let a typo in any pattern below silently switch a
# wall off, so an unusable pattern refuses the command instead.
_grep_kw() {
  printf '%s' "$DETECT_KW" | grep -qE -e "$1"
  case $? in
    0) return 0 ;;
    1) return 1 ;;
    *) block "internal guard error: a wall pattern failed to compile, so '$COMMAND' cannot be checked. That is a bug in this hook — refusing the command rather than letting it through unverified." ;;
  esac
}
has()  { _grep_kw "$1"; }
hasw() { _grep_kw "(^|[^A-Za-z0-9_.-])$1([^A-Za-z0-9_.-]|$)"; }
FFLAG='([[:space:]]-[^[:space:]]*f|--force)'

# ANSI-C quoting ($'\x67it') hides keywords from every text check below; the
# shell expands it after this hook runs, so such a command cannot be verified.
printf '%s' "$COMMAND" | grep -q "\$'" \
  && block "'$COMMAND' uses ANSI-C quoting, whose expansion this guard cannot see. Run the plain command instead."

# --- 1. Destructive git operations (position-free) ---------------------------
if hasw git; then
  hasw merge && block "'$COMMAND' merges — that is the human's call. Agents commit locally and open PRs. (If this only mentions the word in text, rephrase: this wall matches the raw command.)"
  hasw pull  && block "'$COMMAND' pulls (a merge in disguise) — that is the human's call. Fetch and rebase locally, or ask the human."
  has 'alias\.' && block "'$COMMAND' injects a git alias, which can rename any walled operation. Agents run plain git."
  hasw 'checkout-index' && block "'$COMMAND' rewrites the worktree from the index. Agents do not run it."
  hasw remote && { hasw 'set-url' || hasw rename || hasw add || hasw remove; } \
    && block "'$COMMAND' redefines a remote. The publish wall pins the remote by NAME, so re-pointing origin would publish anywhere — that is the human's call."
  has 'config[^|&;]*remote\.' \
    && block "'$COMMAND' rewrites remote configuration. Re-pointing origin would defeat the publish wall — that is the human's call."
  has '--hard' && block "'$COMMAND' is a destructive worktree/history wipe. Agents do not run it."
  has 'reset[^|&;]*--(merge|keep)' && block "'$COMMAND' resets the worktree/index wholesale. Agents do not run it."
  hasw 'read-tree' && has '--reset' && block "'$COMMAND' resets the index/worktree wholesale. Agents do not run it."
  hasw 'update-ref' && has '([[:space:]]-[^[:space:]]*d|--delete)' && block "'$COMMAND' deletes a ref directly. Agents do not run it."
  hasw clean && has "$FFLAG" && block "'$COMMAND' force-deletes untracked files. Agents do not run it."
  hasw branch && has "([[:space:]]-[^[:space:]]*D|--delete|$FFLAG)" && block "'$COMMAND' deletes or force-modifies a branch. Agents do not run it."
  { hasw checkout || hasw switch || hasw branch; } && has '[[:space:]]-[BC]([[:space:]]|$)' \
    && block "'$COMMAND' force-moves a branch (checkout -B / switch -C). Agents do not run it."
  hasw 'update-ref' && block "'$COMMAND' rewrites a ref directly, bypassing the branch walls. Agents do not run it."
  hasw rm && has "([[:space:]]-[^[:space:]]*r|--recursive|$FFLAG)" && block "'$COMMAND' removes tracked files recursively/forcibly. Agents do not run it."
  if hasw checkout || hasw restore || hasw switch; then
    # whole-tree pathspecs, including git's pathspec magic (:/ :(top) :(glob) :!)
    has '[[:space:]](\.|\./|\./\.|\.\.|:|:/|:!|\*|\*\*|/)([[:space:]]|$)' && block "'$COMMAND' discards all local changes. Agents do not run it."
    has '[[:space:]]:\(' && block "'$COMMAND' uses whole-tree pathspec magic. Agents do not run it."
    has "($FFLAG|--discard-changes)" && block "'$COMMAND' force-switches and discards local changes. Agents do not run it."
  fi
fi

# --- 2. Outward gh operations that are the human's alone ---------------------
if hasw gh; then
  hasw alias \
    && block "'$COMMAND' defines or imports a gh alias, which can rename any walled operation. Agents run plain gh."
  hasw review && has '(dismiss|approve|request-changes)' \
    && block "'$COMMAND' dismisses or submits a PR review verdict. Reviews are the reviewer's — an agent never clears or grants its own approval."
  hasw variable && { hasw set || hasw delete || hasw remove; } \
    && block "'$COMMAND' writes a repository variable. Those are the human's switches (LOOP_AUTOMERGE included) — an agent never arms its own gate."
  hasw secret && { hasw set || hasw delete || hasw remove; } \
    && block "'$COMMAND' writes a repository secret. That is the human's to run."
  hasw release && { hasw create || hasw delete || hasw upload; } \
    && block "'$COMMAND' publishes or deletes a release. That is the human's call."
  hasw repo && { hasw sync || hasw delete || hasw archive; } \
    && block "'$COMMAND' mutates the repository outwardly. That is the human's call."
fi
has 'actions/(variables|secrets)' \
  && block "'$COMMAND' targets the repository variable/secret API. Those are the human's switches — an agent never arms its own gate."
has 'pulls/[^[:space:]]*/reviews' \
  && block "'$COMMAND' targets the PR reviews API. Review verdicts are the reviewer's — an agent never clears or grants its own approval." 

# --- 3. Publishing: the ONE sanctioned shape, or nothing ---------------------
if has 'send-pack' || { hasw git && has 'push'; }; then  # DETECT_KW: message text ignored
  printf '%s' "$DETECT" \
    | grep -qE '^[[:space:]]*(cd[[:space:]]+[^[:space:]|&;<>$`()]+[[:space:]]*&&[[:space:]]*)?git[[:space:]]+push([[:space:]]+(-u|--set-upstream))?[[:space:]]+origin[[:space:]]+agent/[A-Za-z0-9._-][A-Za-z0-9._/-]*[[:space:]]*$' \
    || block "'$COMMAND' is not the sanctioned publish. Agents may run exactly '[cd <path> && ] git push [-u] origin agent/<branch>' — no other branch or remote, no extra flags, no redirects, no chained or multi-line commands, no wrappers. The human pushes everything else after local review."
fi

# --- 4. .claude/ is human-only: reads only, never a write --------------------
# Glob-spelled paths (.cla*/set*.json) are matched best-effort; the shell
# expands them after this hook runs, so they remain a documented residual.
if has '\.claude|settings\.json|\.c[^[:space:]/]*(\*|\?|\[)[^[:space:]/]*/|set[^[:space:]]*(\*|\?|\[)[^[:space:]]*json'; then
  case "$DETECT" in
    *'>'*) block "'$COMMAND' redirects into Forge's config. .claude/ holds the safety walls and is human-only — edit it by hand." ;;
  esac
  # Split on newlines as well as | & ; — a read verb on line 1 must not vouch
  # for a write on line 2.
  while IFS= read -r SEG; do
    case "$SEG" in *[![:space:]]*) ;; *) continue ;; esac
    set -f
    set -- $SEG
    # skip env assignments, shell-grammar punctuation and transparent wrappers
    while [ $# -gt 0 ]; do
      tok="$1"
      tok="${tok#\(}"; tok="${tok#\{}"; tok="${tok#!}"
      [ -z "$tok" ] && { shift; continue; }
      case "${tok##*/}" in
        command|exec|env|nohup|nice|time|timeout|stdbuf|sudo|doas|ionice|xargs|builtin|eval|then|do|else|elif|if|while|until|for) shift; continue ;;
      esac
      case "$tok" in -*) break ;; *=*) shift; continue ;; esac
      break
    done
    set +f
    [ -n "$tok" ] || continue
    # `cd` into .claude would put later relative-path writes out of this wall's
    # sight, so it is not a read here.
    case "${tok##*/}" in
      cd) case "$SEG" in *.claude*) block "'$COMMAND' changes directory into Forge's config, where later relative-path writes would be invisible to this wall. Work from the project root; .claude/ is human-only." ;; esac ;;
    esac
    case "${tok##*/}" in
      cat|less|more|head|tail|grep|egrep|fgrep|rg|jq|wc|diff|ls|stat|file|shasum|md5|md5sum|cksum|nl|realpath|dirname|basename|cd|echo) ;;
      *) block "'$COMMAND' would write, delete, or rewrite Forge's config via '${tok##*/}'. .claude/ holds the safety walls and is human-only — only reads (cat/grep/jq/diff/…) are allowed; edit it by hand." ;;
    esac
  done < <(printf '%s\n' "$UNFOLDED" | tr '|&;' '\n\n\n')
fi

exit 0
