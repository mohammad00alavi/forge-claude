#!/usr/bin/env bash
# Guard behavior tests — offline, no network, no GitHub account.
#
# Runs both merge-guard editions against fixtures served by a fake `gh`
# (tests/fake-gh, PATH-prepended), driving each contract condition
# independently. Maintainer-only: nothing here ships to installs.
#
#   bash maintenance/tests/run.sh          # all cases
#   FIXTURE=stale-approval bash …/fake-gh/gh pr view 42   # inspect a fixture
#
# Exit 0 = every case behaved as specified. A guard exits 2 to BLOCK a command
# and 0 to ALLOW it.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT" || exit 1
FAKE="$ROOT/maintenance/tests/fake-gh"
chmod +x "$FAKE/gh" 2>/dev/null || true

CONSUMER="claude-config/hooks/automerge-merge-guard.sh"
MAINTAINER="maintenance/automerge-merge-guard.sh"
GITGUARD="claude-config/hooks/block-dangerous-git.sh"
REPO="mohammad00alavi/forge-claude"
MERGE="gh pr merge 42 --squash --delete-branch -R $REPO"

pass=0; fail=0
# which script produced the verdict: consumer merge guard, maintainer merge
# guard, or the shipped git guardrail
tag() {
  case "$1" in
    "$CONSUMER")   echo "merge(consumer)" ;;
    "$MAINTAINER") echo "merge(maintainer)" ;;
    "$GITGUARD")   echo "git-guardrail" ;;
    *)             basename "$1" .sh ;;
  esac
}
# run <fixture> <guard> <expected-exit> <label> [command]
run() {
  local fixture="$1" guard="$2" want="$3" label="$4" cmd="${5:-$MERGE}" got
  printf '{"cwd":"%s","tool_input":{"command":%s}}' "$ROOT" "$(printf '%s' "$cmd" | jq -Rs .)" \
    | PATH="$FAKE:$PATH" FIXTURE="$fixture" bash "$guard" >/dev/null 2>&1
  got=$?
  if [ "$got" = "$want" ]; then
    pass=$((pass+1)); printf '  PASS (%s) %-22s %s\n' "$got" "$(tag "$guard")" "$label"
  else
    fail=$((fail+1)); printf '  FAIL (got %s want %s) %-14s %s\n' "$got" "$want" "$(tag "$guard")" "$label"
  fi
}

echo "== approvals are bound to the head commit =="
for g in "$CONSUMER" "$MAINTAINER"; do
  run fresh-approval        "$g" 0 "approval on current head -> merges"
  run stale-approval        "$g" 2 "approval on an older commit -> blocked"
  run stale-approval-optout "$g" 0 "stale approval + LOOP_REQUIRE_APPROVAL=false -> merges"
  run reviews-unreadable    "$g" 2 "approving-reviews query unreadable -> blocked (fail closed)"
done

echo "== a rejection is never merged over, fresh or stale =="
for g in "$CONSUMER" "$MAINTAINER"; do
  run changes-requested       "$g" 2 "changes-requested -> blocked"
  run changes-requested-stale "$g" 2 "changes-requested on an older commit -> blocked"
done

echo "== no reviewer at all =="
for g in "$CONSUMER" "$MAINTAINER"; do
  run no-review        "$g" 2 "nobody reviewed -> blocked"
  run no-review-optout "$g" 0 "nobody reviewed + human opted out -> merges"
done

echo "== legitimate review commands pass through untouched =="
for g in "$CONSUMER" "$MAINTAINER" "$GITGUARD"; do
  run fresh-approval "$g" 0 "gh pr edit --add-reviewer"  "gh pr edit 42 --add-reviewer octocat -R $REPO"
  run fresh-approval "$g" 0 "gh pr comment"              "gh pr comment 42 --body 'addressed the review' -R $REPO"
  run fresh-approval "$g" 0 "gh pr view --json"          "gh pr view 42 --json reviewDecision,headRefOid -R $REPO"
done

echo "== .claude/ is human-only, including glob-spelled paths =="
# The glob subpatterns use bracket expressions that are easy to get subtly wrong;
# if one failed to compile the wall would go quiet, so exercise each spelling.
for c in \
  'rm .claude/settings.json' \
  'rm .claude/set*.json' \
  'rm .cla*/set*.json' \
  'rm .cla?ude/settings.json' \
  'cp evil.json .claude/settings.json' \
  'echo x > .claude/settings.json' \
  'echo x > .claude//settings.json' \
  'echo x > .claude/./settings.json'
do
  run fresh-approval "$GITGUARD" 2 "blocked: $c" "$c"
done
for c in \
  'cat .claude/settings.json' \
  'grep permissions .claude/settings.json' \
  'jq .hooks .claude/settings.json'
do
  run fresh-approval "$GITGUARD" 0 "allowed: $c" "$c"
done

echo "== an agent never grants or clears a verdict =="
for g in "$CONSUMER" "$MAINTAINER" "$GITGUARD"; do
  run fresh-approval "$g" 2 "gh pr review --approve"     "gh pr review 42 --approve -R $REPO"
  run fresh-approval "$g" 2 "review dismissal via REST"  "gh api -X PUT repos/$REPO/pulls/42/reviews/1/dismissals -f message=x"
done
# GraphQL is a third spelling of the same act. The boundary matters: submitting
# a review is refused, but REPLYING to a thread is the loop's actual job, and
# addPullRequestReviewThreadReply contains addPullRequestReview as a substring.
for g in "$CONSUMER" "$MAINTAINER"; do
  run fresh-approval "$g" 2 "graphql addPullRequestReview (can carry event: APPROVE)" \
    'gh api graphql -f query=mutation{addPullRequestReview(input:{pullRequestId:1,event:APPROVE}){clientMutationId}}'
  run fresh-approval "$g" 2 "graphql submitPullRequestReview" \
    'gh api graphql -f query=mutation{submitPullRequestReview(input:{pullRequestReviewId:1,event:APPROVE}){clientMutationId}}'
  run fresh-approval "$g" 2 "graphql dismissPullRequestReview" \
    'gh api graphql -f query=mutation{dismissPullRequestReview(input:{pullRequestReviewId:1,message:x}){clientMutationId}}'
  run fresh-approval "$g" 0 "graphql thread REPLY still allowed" \
    'gh api graphql -f query=mutation{addPullRequestReviewThreadReply(input:{body:fixed}){clientMutationId}}'
  run fresh-approval "$g" 0 "graphql resolveReviewThread still allowed" \
    'gh api graphql -f query=mutation{resolveReviewThread(input:{threadId:abc}){thread{isResolved}}}'
done

echo
if [ "$fail" = 0 ]; then echo "guard tests: OK ($pass cases)"; else echo "guard tests: $fail FAILED of $((pass+fail))"; fi
exit $([ "$fail" = 0 ] && echo 0 || echo 1)
