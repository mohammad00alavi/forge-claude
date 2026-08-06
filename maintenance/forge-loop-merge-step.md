# The merge step — contract for agent-performed merges (Option A)

What an agent must satisfy before merging one of its own PRs in THIS repo.
Applies only when `LOOP_AUTOMERGE` is `true`; enforced mechanically by
`maintenance/automerge-merge-guard.sh`. When the forge-loop skill lands (the lean
loop port), this file becomes its merge-step section verbatim — until then it is
the standing contract `/automerge` points at.

Run the steps in order, per open agent-owned PR. Every `gh` call passes
`-R mohammad00alavi/forge-claude`.

Every condition below is **also enforced mechanically** by
`maintenance/automerge-merge-guard.sh`, which reads the PR's real state from
GitHub before letting `gh pr merge` through: checks green (pending counts as not
green), no `human:*`/`automerge:halt` label on the PR or any open issue, no
protected path in the diff, not behind or conflicted, no unresolved review
thread, an approving review **on the current head commit**, plus a fresh
`forge-lint`. Unreadable state fails closed. Satisfy the steps because they are
right, not because the wall is watching — but the wall is watching.

**Order matters: approval comes LAST.** An approval is a verdict on one commit.
GitHub leaves `reviewDecision` at APPROVED after later pushes, but this guard
compares the approval's commit to the PR's head — so any push after approval,
**including `gh pr update-branch`**, makes it stale. Land every fix first, get
to behind-zero, then request review on the final head. A stale approval is not a
malfunction; it means re-request and wait.

## 0. Toggle

`gh variable get LOOP_AUTOMERGE` — anything but `true` (including unset or an
error): stop at the ready PR, request review, done. That is the OFF flow and it
is always a valid outcome.

## 1. Return path first — nothing merges over open feedback

- **Unresolved review threads** — human AND bot (Copilot included): fix each on
  the same branch, reply, resolve the thread. An open thread is a hard block,
  green checks notwithstanding.
- **Red CI** — fix on the branch, push, wait for the re-run.

## 2. Behind-zero — never merge a stale branch

If the PR is behind its base: `gh pr update-branch <N>` (merges base into the
PR branch — the API path, so no local `git merge` is needed and none is
allowed). Repeat after CI until behind == 0. Conflicts: resolve them on the PR
branch; if resolution needs a judgment call, stop — comment what conflicts and
leave the PR for the human.

## 3. Fresh gate

`bash maintenance/forge-lint.sh` in the PR's own worktree, now — never a
remembered earlier result. Red gate → fix or leave ready with a comment.

## 4. Eligibility

- No `human:*` label on the PR; no `automerge:halt` on the PR or any open issue.
- Diff touches no escalate path: `claude-config/hooks/**`,
  `claude-config/settings.json`, `install.sh`, `maintenance/forge-lint.sh`,
  `maintenance/release-gate.sh`, `maintenance/automerge-merge-guard.sh`, any
  `*.workflow.yml`. Those PRs are always human-merged, toggle regardless.

## 5. Merge

`gh pr merge <N> --squash --delete-branch -R mohammad00alavi/forge-claude`
— exactly that shape, and nothing else: the PR named by NUMBER (a branch or URL
target is rejected), the repo spelled literally (the guard cannot expand shell
variables), no unrecognized flags, and never `--admin` (bypassing protections is
not a thing agents do). Anything
still red at any step: leave the PR **ready** and comment exactly what blocked
the merge (the write-back). Releases are out of scope entirely: tagging stays
human-triggered via `release-gate.sh`.
