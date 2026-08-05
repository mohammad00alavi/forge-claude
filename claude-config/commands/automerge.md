---
description: "Human-only toggle: when ON, agents may squash-merge their own PRs — but only green, review-clean, up-to-date ones that pass this project's gate. OFF (default): agents always stop at a ready PR and you merge. Mechanically enforced by the automerge-merge-guard hook."
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
on every `gh` call. Then parse the argument (`on` / `off` / empty = status).

## on

1. First run only, offer setup: create labels `automerge:halt`,
   `human:authorize`, `human:decide` if missing; confirm squash merges are
   allowed on the repo; **recommend** (don't require) branch protection on the
   default branch with the project's CI as a required check.
2. `gh variable set LOOP_AUTOMERGE --body true -R "$REPO"`
3. Report what is now permitted, restating the contract in one line.

## off

1. `gh variable set LOOP_AUTOMERGE --body false -R "$REPO"`
2. `gh pr merge --disable-auto` any agent PRs armed earlier; comment on open
   agent PRs that auto-merge was disarmed, so the wait is explained.
3. Report the new state.

## status (no argument)

Print the variable (unset == OFF), open agent PRs, and per PR what blocks
merging (threads / CI / behind / labels / protected paths).

## The contract (what ON actually permits)

An agent may `gh pr merge <N> --squash --delete-branch -R "$REPO"` only when
ALL of the following hold, checked fresh, in this order:

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

The `automerge-merge-guard.sh` hook enforces the toggle, blocks `--admin`, and
fails closed when the variable is unreadable. Steps 1–6 are the agent's
obligation under this contract; a merge that skipped them is a defect even if
the hook let it through.
