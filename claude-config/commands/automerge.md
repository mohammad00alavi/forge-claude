---
description: "Human-only toggle: when ON, agents may squash-merge their own PRs — but only ones that are CI-green, review-clean and up to date. OFF (default): agents always stop at a ready PR and you merge. The automerge-merge-guard hook enforces every condition it can read from GitHub."
---

Flip or report this project's auto-merge toggle. **This command is for the
human.** Agents never invoke `/automerge` and never set `LOOP_AUTOMERGE`
themselves — an agent flipping its own switch is a defect to report.

Forge's wall stays the default: agents cannot push, merge, or deploy. Turning
this ON grants exactly one scoped exception — merging **their own** pull
requests, and only under the contract below. Everything else stays walled.

First, resolve the repo explicitly (never assume cwd):
`REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)` — abort with a
clear message if there is no GitHub remote or no write access. Use `-R "$REPO"`
on every `gh` call — except the merge and disarm commands, where the repo must be
spelled literally (the guard cannot expand shell variables). Then parse the argument (`on` / `off` / empty = status).

## on

1. First run only, offer setup: create labels `automerge:halt`,
   `human:authorize`, `human:decide` if missing; confirm squash merges are
   allowed on the repo; **recommend** (don't require) branch protection on the
   default branch with the project's CI as a required check **and "dismiss stale
   pull request approvals when new commits are pushed" enabled** — that setting
   is the server-side twin of this guard's head-commit check, and unlike the
   guard an agent's token cannot switch it off. The guard enforces freshness
   either way, since most repos have no protection at all.
2. **Settle who reviews — ask, don't assume.** Check whether this repo actually
   has a reviewer: a code-review bot/app installed (e.g. Copilot review), a
   CODEOWNERS file, or default reviewers. Report what you find, then have the
   human choose, because the guard requires an approving review by default:
   - a reviewer exists → nothing to do; PRs need that approval to merge;
   - no reviewer, and the human accepts the loop's fresh-context **verifier** as
     the only checker → `gh variable set LOOP_REQUIRE_APPROVAL --body false -R <owner>/<repo>` — again
     printed for the human to run, not run by the agent —
     and say plainly what that means: no second party sees the change before it
     lands, so the verifier and CI are the whole gate;
   - no reviewer and they are not comfortable with that → leave it required and
     auto-merge simply won't fire until someone reviews. That is a valid,
     safe outcome, not a misconfiguration.
3. **Print this line for the human to run themselves** — the guards refuse it
   from an agent, deliberately, since an agent that can arm its own gate is not
   gated by it: `gh variable set LOOP_AUTOMERGE --body true -R <owner>/<repo>`
4. Report what is now permitted, restating the contract in one line, and name
   the review policy in force (`approval required` vs `verifier-only`).

## off

1. **Print this line for the human to run themselves** (same reason as `on`):
   `gh variable set LOOP_AUTOMERGE --body false -R <owner>/<repo>`
2. `gh pr merge <N> --disable-auto -R <owner>/<repo>` for any agent PR armed
   earlier — PR by number, repo spelled literally, which is the only disarm
   shape the guard accepts. Then comment on open agent PRs that auto-merge was
   disarmed, so the wait is explained.
3. Report the new state.

## status (no argument)

Print the variable (unset == OFF), the review policy in force
(`LOOP_REQUIRE_APPROVAL` unset/true = an approving review is required; false =
the loop's verifier is the only checker) and whether this repo actually has a
reviewer configured, then open agent PRs and per PR what blocks merging
(review decision / threads / CI / behind / labels / protected paths). For the
review column distinguish **approved (current head)** from **approved (stale —
re-request)** by comparing each approving review's commit with `headRefOid`, and
from **not reviewed** — a stale approval reads as "approved" everywhere in
GitHub's UI, so naming it is the whole point.

## The contract (what ON actually permits)

An agent may `gh pr merge <N> --squash --delete-branch -R <owner>/<repo>` only
when ALL of the following hold, checked fresh, in this order. **Spell the repo
literally in the merge command** (`-R acme/widgets`, not `-R "$REPO"`): the
merge guard cannot expand shell variables, so a variable form fails closed.
Nothing else about the merge command is sanctioned — an unrecognized flag, a
non-numeric target, or a second repo named anywhere is blocked.

0. **A verdict that isn't a rejection, and by default an approval of the
   CURRENT head.** The PR's review decision must not be `CHANGES_REQUESTED` — a
   reviewer can request changes with only a summary and leave no thread at all,
   so threads alone never prove the feedback is clear. By default an APPROVED
   decision is also required, so "review requested" means someone actually
   looked. **That approval must be on the PR's current head commit**: GitHub
   keeps `reviewDecision` at APPROVED after later pushes, so a pre-push approval
   would otherwise clear a merge of code the reviewer never saw. Any push after
   approval — including `gh pr update-branch` — makes it stale, so request review
   only once the branch is final. A project with no reviewer opts out
   deliberately with `LOOP_REQUIRE_APPROVAL=false` (see `on` above), which makes
   the loop's verifier and CI the entire gate.
1. **Feedback resolved** — zero unresolved review threads, human AND bot
   (Copilot included). Fix on the branch, reply, resolve; an open thread is a
   hard block even when checks are green.
2. **CI green** — fix red checks on the branch first.
3. **Behind-zero** — if the PR is behind its base, `gh pr update-branch <N>`
   (the API path; local `git merge` stays walled) until behind == 0. Conflicts
   needing judgment → stop, comment, leave for the human.
4. **Project gate green, run now** — the venture's gate commands (typecheck,
   lint, tests, build), never a remembered earlier result.
5. **No blocking labels** — no `human:*` on the PR, no `automerge:halt` on the
   PR or any open issue.
6. **No protected paths in the diff** — `.github/**`, `.claude/**`, `.env*`,
   auth/payments/billing code, infra & deploy configs. Those PRs are always
   human-merged, toggle regardless.
7. Never `--admin`. Anything unmet → leave the PR **ready** with a comment
   saying exactly what blocked it.

**The hook enforces every condition it can read from GitHub.** `automerge-merge-guard.sh`
verifies the command shape, the literal repo, `LOOP_AUTOMERGE`, and an `agent/*`
head ref — and then reads the PR's real state from GitHub and refuses the merge
unless every check has concluded green (a queued or running check blocks too),
no `human:*`/`automerge:halt` label is present on the PR or any open issue, the
diff touches no protected path, the branch is neither behind nor conflicted, and
no review thread is unresolved. Unreadable state fails closed. This matters most
in a repo with **no branch protection**, where `gh pr merge` would otherwise
happily merge a red or stale PR: here green-before-merge is a wall, not a
promise. Steps 0–3 and 5–6 are verified by the hook, so skipping them is not possible.
**Step 4 is the exception: no shipped hook can know a venture's gate commands**,
so the project gate is the agent's obligation, with CI (step 2) as the mechanical
signal that makes red visible. If your gate runs in CI, step 4 is covered by
step 2; if it only runs locally, it is on the agent. (The maintainer edition of
this guard does run a gate, because in that one repo it knows what the gate is.)
