#!/bin/bash
# Forge auto-merge guard (maintainer repo edition) — PreToolUse hook on Bash.
#
# Forge's wall: agents never push, merge, or deploy. /automerge is the ONE
# sanctioned, opt-in exception, and this hook is its mechanical edge — a
# WHITELIST, not a filter. If a command could merge anything, it must match one
# of exactly two shapes, or it is refused:
#
#   gh pr merge <N> --squash --delete-branch -R <owner>/<repo>     (the merge)
#   gh pr merge <N> --disable-auto -R <owner>/<repo>               (the disarm)
#
# The repo must be spelled literally — this guard cannot expand shell variables,
# so `-R "$REPO"` fails closed. Then, for a merge: LOOP_AUTOMERGE must read
# 'true' (human-set) and PR <N>'s head ref must be an agent/* branch, so agents
# merge only their own loop PRs. Unset/unreadable state == OFF, so a fresh
# install behaves exactly as before: agents stop at a ready PR, the human merges.
#
# DETECTION IS POSITION-FREE. Five review rounds showed that any trigger keyed
# to a keyword's POSITION leaks, because gh accepts flags before, between and
# after subcommands (`gh pr -R x merge 99`, `gh -R x variable set`). So the
# trigger asks only "do the words gh and merge both appear?" and lets the
# anchored whitelist decide. Over-refusal is the deliberate trade: a command
# that merely mentions merging (a PR title, a commit message) is refused too.
#
# The toggle is HUMAN-ONLY: variable/secret writes are refused here in any
# spelling, CLI or API, so an agent cannot arm the switch that gates it.
#
# The whole command is folded to ONE line before matching, so a multi-line or
# backslash-continued command cannot hide a second merge behind a sanctioned
# first line (grep anchors per line, not per command).
#
# Residual, by design: shell EXPANSION cannot be resolved by a string guard —
# $VAR, eval, command substitution, and file-backed API bodies reach the shell
# as something this hook never saw. Branch protection and human review back it.

INPUT=$(cat)

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

# Fold to one line FIRST (so `\<newline>` becomes whitespace, not a line break),
# then collapse quoting evasion (gh\ pr\ merge, "gh" "pr" "merge" …).
DETECT=$(printf '%s' "$COMMAND" | tr '\n\r\t' '   ' | sed 's/\\//g; s/"//g; s/'"'"'//g')

# Message/title/body VALUES are data, not command words: a commit message or PR
# title that says "merge" or "push" must not trip the keyword walls below. Only
# unambiguous long-form message flags are stripped (never -d/-b/-t/-F, whose
# short spellings mean other things to gh), and only for the KEYWORD checks —
# the anchored whitelists still match the untouched command, so the sanctioned
# shape stays exact.
STRIPMSG='s/(^|[[:space:]])(-m|--message|--title|--body|--body-file|--description|--notes)([[:space:]]+|=)("[^"]*"|'"'"'[^'"'"']*'"'"'|[^[:space:]]*)/\1\2 MSGVALUE/g'
DETECT_KW=$(printf '%s' "$COMMAND" | tr '\n\r\t' '   ' | sed -E "$STRIPMSG" | sed 's/\\//g; s/"//g; s/'"'"'//g')

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

# --- The toggle is the human's switch ---------------------------------------
# An agent that can arm its own gate is not gated. Refused in every spelling:
# `gh variable set`, `gh -R x variable set`, and the REST routes behind them.
if hasw gh && hasw variable && { hasw set || hasw delete || hasw remove; }; then
  block "'$COMMAND' writes a repository variable. LOOP_AUTOMERGE is the human's switch — an agent never arms its own gate. Ask the human to run /automerge on."
fi
if hasw gh && hasw secret && { hasw set || hasw delete || hasw remove; }; then
  block "'$COMMAND' writes a repository secret. That is the human's to run."
fi
has 'actions/(variables|secrets)' \
  && block "'$COMMAND' targets the repository variable/secret API. LOOP_AUTOMERGE is the human's switch — an agent never arms its own gate."

# A review verdict is the reviewer's. An agent that can dismiss a
# changes-requested review, or submit its own approval, is not gated by it.
hasw gh && hasw review && has '(dismiss|approve|request-changes)' \
  && block "'$COMMAND' dismisses or submits a PR review verdict. Reviews belong to the reviewer — address the feedback and ask for the review to be updated."
has 'pulls/[^[:space:]]*/reviews' \
  && block "'$COMMAND' targets the PR reviews API. Review verdicts are the reviewer's — an agent never clears or grants its own approval."
# Same rule in GraphQL: addPullRequestReview submits a review and can carry
# event: APPROVE. The trailing class keeps addPullRequestReviewThreadReply —
# answering a thread — allowed, since replying is the loop's actual job.
has '(addPullRequestReview([^A-Za-z]|$)|submitPullRequestReview|dismissPullRequestReview)' \
  && block "'$COMMAND' submits or dismisses a PR review via GraphQL. Review verdicts are the reviewer's — reply to the thread and ask for the review to be updated instead."

# gh aliases rename any subcommand, so an alias can spell a merge with none of
# the words this guard looks for. Same reasoning as git's `alias.` wall.
hasw gh && hasw alias \
  && block "'$COMMAND' defines or imports a gh alias, which can rename any walled operation. Agents run plain gh."

# ANSI-C quoting ($'\x70ush') hides keywords from every text check; the shell
# expands it after this hook runs, so a command carrying it cannot be verified.
has "\\\$'" \
  && block "'$COMMAND' uses ANSI-C quoting, whose expansion this guard cannot see. Run the plain command instead."

# --- Could this command merge anything? --------------------------------------
# The loop's return path reads review threads with `gh api graphql -f
# query=query{…}`; that exact shape (whole command, single field, no file-backed
# body) is the only read carve-out. Everything else that carries a field flag is
# treated as a write, because gh POSTs as soon as any field is present.
FIELDFLAG='(^|[[:space:]])(-[fF]|--(field|raw-field|input))'
# The loop must resolve review threads, which is only possible via a GraphQL
# mutation. Exactly those thread/comment mutations are read-through here; any
# other mutation (merge, auto-merge, ref creation …) stays merge-capable.
is_loop_thread_mutation() {
  has 'mutation' || return 1
  has '(mergePullRequest|enablePullRequestAutoMerge|createRef|updateRef|deleteRef|updateBranchProtection|deleteBranchProtection)' && return 1
  has '(resolveReviewThread|unresolveReviewThread|addPullRequestReviewThreadReply|addComment)'
}
is_read_graphql() {
  printf '%s' "$DETECT" \
    | grep -qE '^[[:space:]]*gh[[:space:]]+api[[:space:]]+graphql[[:space:]]+(-f|--field)[[:space:]=]*query=[[:space:]]*query[[:space:]]*[{(][^@]*$' || return 1
  n=$(printf '%s' "$DETECT" | grep -oE -e "$FIELDFLAG" | wc -l | tr -d ' ')
  [ "$n" = "1" ]
}
merge_capable() {
  hasw gh && hasw merge && return 0
  has 'pulls/[^[:space:]]*/merge|merge-upstream|/merges|mergePullRequest|enablePullRequestAutoMerge' && return 0
  if hasw gh && hasw api; then
    # any method that is not a read is a write (PUT/POST/PATCH/DELETE and any
    # spelling of them, glued or spaced)
    has '(-X|--method)[[:space:]=]*[^[:space:]]+' \
      && ! has '(-X|--method)[[:space:]=]*([Gg][Ee][Tt]|[Hh][Ee][Aa][Dd])([[:space:]]|$)' && return 0
    if has 'mutation'; then
      is_loop_thread_mutation && return 1
      return 0
    fi
    if has "$FIELDFLAG"; then
      is_read_graphql && return 1
      is_loop_thread_mutation && return 1
      return 0
    fi
  fi
  return 1
}
merge_capable || exit 0

REPO="mohammad00alavi/forge-claude"

# Gate root: the contract runs the fresh gate in the PR's OWN worktree. A cwd is
# honored only when it shares this project's git object store — i.e. it is a real
# worktree/checkout of THIS repo — so a crafted directory carrying a fake
# maintenance/forge-lint.sh cannot decide the gate.
PROJ="${CLAUDE_PROJECT_DIR:-$(pwd)}"
ROOT="$PROJ"
CWD=""
command -v jq >/dev/null 2>&1 && CWD=$(printf '%s' "$INPUT" | jq -r '.cwd // empty' 2>/dev/null)
if [ -n "$CWD" ] && [ -f "$CWD/maintenance/forge-lint.sh" ]; then
  A=$(cd "$CWD" 2>/dev/null && cd "$(git rev-parse --git-common-dir 2>/dev/null)" 2>/dev/null && pwd)
  B=$(cd "$PROJ" 2>/dev/null && cd "$(git rev-parse --git-common-dir 2>/dev/null)" 2>/dev/null && pwd)
  [ -n "$A" ] && [ "$A" = "$B" ] && ROOT="$CWD"
fi

RE_REPO=$(printf '%s' "$REPO" | sed 's/[.[\*^$+?(){}|/]/\\&/g')

# The disarm shape mutates nothing — that is how /automerge off cleans up.
printf '%s' "$DETECT" \
  | grep -qE "^[[:space:]]*gh[[:space:]]+pr[[:space:]]+merge[[:space:]]+[0-9]+[[:space:]]+--disable-auto[[:space:]]+(-R|--repo)[[:space:]]+${RE_REPO}[[:space:]]*\$" \
  && exit 0

# The merge shape. Anything that is not exactly this is refused.
PRNUM=$(printf '%s' "$DETECT" \
  | sed -nE "s|^[[:space:]]*gh[[:space:]]+pr[[:space:]]+merge[[:space:]]+([0-9]+)[[:space:]]+--squash[[:space:]]+--delete-branch[[:space:]]+(-R\|--repo)[[:space:]]+${RE_REPO}[[:space:]]*\$|\1|p")

[ -z "$PRNUM" ] && block "'$COMMAND' is not the sanctioned merge. The contract is exactly 'gh pr merge <N> --squash --delete-branch -R $REPO' (PR by number, repo spelled literally, no other flags, no redirects, no chained or multi-line commands, no gh api routes). Anything else is the human's to run."

# The human-set toggle. Unset, false, or unreadable == OFF.
STATE=$(gh variable get LOOP_AUTOMERGE -R "$REPO" 2>/dev/null)
[ "$STATE" = "true" ] || block "agents do not merge in this project (LOOP_AUTOMERGE read: '${STATE:-unreadable}'). Open the PR ready and request review — the human merges. The human can opt in with /automerge on."

# Everything below reads the PR's real state from GitHub, so the contract is a
# WALL and not a promise. Without branch protection `gh pr merge` will happily
# merge a red, stale, or protected-path PR, so the guard checks each condition
# itself. jq is required from here on; unreadable state == fail closed.
command -v jq >/dev/null 2>&1 \
  || block "jq is required to verify PR #$PRNUM's state (checks, labels, files) before merging. Install jq or leave the merge to the human."

PRJSON=$(gh pr view "$PRNUM" -R "$REPO" \
  --json headRefName,headRefOid,statusCheckRollup,labels,files,mergeStateStatus,mergeable,state,reviewDecision 2>/dev/null)
[ -z "$PRJSON" ] && block "cannot read PR #$PRNUM from $REPO, so its merge conditions cannot be verified. Leave it for the human."

jqf() { printf '%s' "$PRJSON" | jq -r "$1" 2>/dev/null; }

# Scope: agents merge only THEIR OWN PRs — head ref must be an agent/* branch.
HEADREF=$(jqf '.headRefName // ""')
case "$HEADREF" in
  agent/?*) ;;
  *) block "PR #$PRNUM head ref is '${HEADREF:-unreadable}', not an agent/* branch. Agents merge only their own loop PRs; this one is the human's to merge." ;;
esac

[ "$(jqf '.state // ""')" = "OPEN" ] \
  || block "PR #$PRNUM is not open. Nothing to merge."

# CI green: every check that exists must have CONCLUDED successfully. A pending,
# queued, failing or cancelled check blocks — this is the condition that branch
# protection would enforce, and most consumer repos have none.
NOTGREEN=$(jqf '[.statusCheckRollup[]? | ((.conclusion // .state // .status // "PENDING") | ascii_upcase) | select(. != "SUCCESS" and . != "SKIPPED" and . != "NEUTRAL")] | length')
case "$NOTGREEN" in
  ''|*[!0-9]*) block "cannot read PR #$PRNUM's check status. Leave the merge to the human." ;;
  0) ;;
  *) block "PR #$PRNUM has $NOTGREEN check(s) that are not green (failing, queued, or still running). Fix the cause on the branch and let CI re-run — a red or pending gate is never merged, toggle regardless." ;;
esac

# The emergency stop and the human-reserved markers.
BLOCKING=$(jqf '[.labels[]?.name | select(startswith("human:") or . == "automerge:halt")] | length')
case "$BLOCKING" in
  ''|*[!0-9]*) block "cannot read PR #$PRNUM's labels. Leave the merge to the human." ;;
  0) ;;
  *) block "PR #$PRNUM carries a human:*/automerge:halt label. Those are the human's markers — this PR is theirs to merge." ;;
esac
HALT=$(gh issue list -R "$REPO" --label automerge:halt --state open --json number -q 'length' 2>/dev/null)
case "$HALT" in
  ''|*[!0-9]*) block "cannot check for an open automerge:halt issue in $REPO. Leave the merge to the human." ;;
  0) ;;
  *) block "an open automerge:halt issue is in effect in $REPO — all auto-merging is frozen until the human clears it." ;;
esac

# Protected paths are always human-merged, toggle regardless.
PROTECTED=$(jqf '[.files[]?.path | select(test("^\\.github/|^\\.claude/|(^|/)\\.env|(^|/)(auth|payments|billing|secrets)/|^infra/|(^|/)Dockerfile|(^|/)docker-compose|(^|/).*\\.tf$"))] | length')
case "$PROTECTED" in
  ''|*[!0-9]*) block "cannot read PR #$PRNUM's file list. Leave the merge to the human." ;;
  0) ;;
  *) block "PR #$PRNUM touches $PROTECTED protected path(s) (.github/, .claude/, .env*, auth/payments/billing, infra, containers). Those are always human-merged." ;;
esac

# Behind base, conflicted, or otherwise not mergeable right now.
MSS=$(jqf '.mergeStateStatus // ""')
case "$MSS" in
  BEHIND)  block "PR #$PRNUM is behind its base. Run 'gh pr update-branch $PRNUM -R $REPO' and let CI re-run before merging." ;;
  DIRTY)   block "PR #$PRNUM has conflicts with its base. Resolve them on the branch, or leave it for the human if the resolution needs judgment." ;;
  BLOCKED) block "PR #$PRNUM is blocked by branch protection (a required review or check is outstanding). That gate is the human's to satisfy." ;;
  UNSTABLE|DRAFT) block "PR #$PRNUM is not in a mergeable state ($MSS)." ;;
esac
[ "$(jqf '.mergeable // ""')" = "CONFLICTING" ] \
  && block "PR #$PRNUM conflicts with its base. Resolve on the branch or leave it for the human."

# Unresolved review threads — human AND bot (Copilot included). An open thread
# is a hard block even when every check is green.
THREADS=$(gh api graphql -F owner="${REPO%%/*}" -F name="${REPO##*/}" -F pr="$PRNUM" -f query='
  query($owner:String!,$name:String!,$pr:Int!){repository(owner:$owner,name:$name){
    pullRequest(number:$pr){reviewThreads(first:100){nodes{isResolved isOutdated}}}}}' \
  --jq '[.data.repository.pullRequest.reviewThreads.nodes[] | select(.isResolved == false and .isOutdated == false)] | length' 2>/dev/null)
case "$THREADS" in
  ''|*[!0-9]*) block "cannot read PR #$PRNUM's review threads. Leave the merge to the human." ;;
  0) ;;
  *) block "PR #$PRNUM has $THREADS unresolved review thread(s), human or bot. Address each on the branch, reply, and resolve it — feedback is never merged over." ;;
esac

# The review verdict itself. Threads are not enough: "request changes" with only
# a summary and no inline comment creates NO thread, so a changes-requested
# review would otherwise read as clean feedback.
RD=$(jqf '.reviewDecision // ""')
case "$RD" in
  CHANGES_REQUESTED)
    block "PR #$PRNUM has a changes-requested review. Address it and get the review updated — an explicit rejection is never merged over, thread or no thread." ;;
  *)
    # An approval is REQUIRED unless the human has explicitly accepted the loop's
    # own fresh-context verifier as the only checker: on a repo with no reviewer,
    # "review requested" is a request to nobody, and zero reviews would otherwise
    # pass as zero feedback.
    NEEDAPP=$(gh variable get LOOP_REQUIRE_APPROVAL -R "$REPO" 2>/dev/null)
    if [ "$NEEDAPP" != "false" ]; then
      [ "$RD" = "APPROVED" ] \
        || block "PR #$PRNUM has no approving review (review decision: ${RD:-none}). Nobody has reviewed it, so there is no feedback to have resolved. Either get a review (a human, or a PR-review bot), or — if this project accepts the loop's fresh-context verifier as its only checker — the human sets 'gh variable set LOOP_REQUIRE_APPROVAL --body false -R $REPO' to say so deliberately."

      # An approval is a verdict on a specific COMMIT, not on the PR forever.
      # GitHub leaves reviewDecision at APPROVED after new commits are pushed
      # unless the repo enables "dismiss stale approvals" protection, which most
      # do not — so an approval earned at commit aaa would otherwise clear a
      # merge of bbb/ccc that the reviewer never saw. Re-earn it on every push.
      HEADOID=$(jqf '.headRefOid // ""')
      [ -n "$HEADOID" ] \
        || block "cannot read PR #$PRNUM's head commit, so the approval cannot be checked against it. Leave the merge to the human."
      FRESH=$(gh api graphql -F owner="${REPO%%/*}" -F name="${REPO##*/}" -F pr="$PRNUM" -F oid="$HEADOID" -f query='
        query($owner:String!,$name:String!,$pr:Int!){repository(owner:$owner,name:$name){
          pullRequest(number:$pr){reviews(states: APPROVED, last: 50){nodes{commit{oid}}}}}}' \
        --jq "[.data.repository.pullRequest.reviews.nodes[] | select(.commit.oid == \"$HEADOID\")] | length" 2>/dev/null)
      case "$FRESH" in
        ''|*[!0-9]*)
          block "cannot read PR #$PRNUM's approving reviews, so the approval cannot be tied to the current commit. Leave the merge to the human." ;;
        0)
          APPROVED_AT=$(gh api graphql -F owner="${REPO%%/*}" -F name="${REPO##*/}" -F pr="$PRNUM" -f query='
            query($owner:String!,$name:String!,$pr:Int!){repository(owner:$owner,name:$name){
              pullRequest(number:$pr){reviews(states: APPROVED, last: 50){nodes{commit{oid}}}}}}' \
            --jq '[.data.repository.pullRequest.reviews.nodes[].commit.oid] | last // "unknown"' 2>/dev/null)
          block "PR #$PRNUM's approval is for commit $(printf '%.7s' "${APPROVED_AT:-unknown}"), but the head is now $(printf '%.7s' "$HEADOID") — the reviewer never saw the newer commits. Re-request review (gh pr edit $PRNUM --add-reviewer <who> -R $REPO) and wait for a fresh approval; never dismiss a review or approve yourself." ;;
      esac
    fi ;;
esac

# Fresh gate — the gate decides done, never a remembered result.
bash "$ROOT/maintenance/forge-lint.sh" >/dev/null 2>&1 \
  || block "forge-lint is red in $ROOT. Fix the gate (bash maintenance/forge-lint.sh) or leave the PR ready with a comment. Toggle-on never overrides a red gate."

# Shape, toggle, scope, CI, labels, paths, freshness, feedback, the review
# verdict (bound to the head commit) and the fresh gate are all verified.
exit 0
