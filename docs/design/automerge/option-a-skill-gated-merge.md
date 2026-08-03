# Option A — Skill-gated merge (the agent merges when ON)

The merge decision lives inside the `dev-loop` skill. Last step of every cycle:

```
state = gh variable get LOOP_AUTOMERGE -R mohammad00alavi/forge-claude   # unset == false
if state != "true"          → stop at ready PR, request review. Done (today's flow).
if state == "true":
    re-run bash maintenance/forge-lint.sh          # gate, fresh, in the PR worktree
    check eligibility: no human:* label, no automerge:halt, diff clear of escalate paths
    all green → gh pr merge <N> --squash --delete-branch -R mohammad00alavi/forge-claude
    anything red → leave PR ready + comment why it was not auto-merged
```

## The `/automerge` command

`maintenance/automerge.command.md`, copied to `.claude/commands/automerge.md` (the
`self-review.command.md` convention). Human-invoked only:

- `/automerge on` → `gh variable set LOOP_AUTOMERGE --body true -R …`, then prints the state
  and the current eligibility rules.
- `/automerge off` → sets `false` **and** comments on any open loop PRs that auto-merge was
  disarmed (so a later reader knows why they waited).
- `/automerge` (bare) → just reports the state.

## Making it mechanical-ish

Skill text alone is instruction-level enforcement. Two cheap hardeners:

1. **PreToolUse hook** on `Bash(gh pr merge*)`: a small shell guard that exits non-zero unless
   `LOOP_AUTOMERGE=true` *and* `forge-lint.sh` passes in the current worktree. Mirrors the
   bondly-frontend commit/branch-policy guard pattern, but in shell (Forge has no Node).
2. **Gate re-run is mandatory** — the skill merges only off a fresh `forge-lint.sh` run in the
   PR's own worktree, never off a remembered earlier result.

## Both modes, concretely

- OFF: identical to the lean Mode-A flow. The merge step is a no-op that requests your review.
- ON: you still see every merge — the PR, the gate output, and a merge commit trail — you just
  aren't the one clicking. Flip OFF at any time; already-open PRs simply wait for you.

## Trade-offs

**For:** smallest possible build (command + skill section + optional hook, no CI, no repo
settings); works entirely from a laptop session; easy to rip out.

**Against:** merges only happen while a session is running — nothing lands overnight; the agent
itself performs the merge, the largest bend of Wall 1 of the three options; enforcement is a
hook + discipline, not the platform — a session that ignores the skill could in principle
merge red (branch protection in Option B is what truly closes that).

**Fit:** the fastest way to have the toggle working today, and a reasonable stepping stone —
A's command and skill section are exactly what Option B reuses; B then moves the merge itself
to GitHub.
