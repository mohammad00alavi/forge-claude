---
description: Forge maintainer-only — run ONE iteration of the repo's forge loop (queue = forge-loop-ready GitHub issues → worktree maker → gate → fresh-context verifier → ready PR with Closes #N → toggle-aware merge step). NOT shipped to installs.
---

Run one iteration of the forge loop for THIS repo. Read and execute
`maintenance/forge-loop.md` exactly — preflight, reconstruct state from GitHub,
**return path first** (clear review feedback, red CI, and behind-base on open
agent PRs), then at most one new `forge-loop-ready` issue: worktree, maker sub-agent
(fixer or builder), `forge-lint` + affected eval suite as the gate, verifier in
a fresh context, ready PR that `Closes #N`, and the merge step per
`maintenance/forge-loop-merge-step.md` (`/automerge` decides who merges).

Respect `maintenance/LOOP-STATE.md` caps. End with the Record step: every PR
claims its issue, every blocked issue explains itself, lessons appended to
LOOP-STATE, machinery changes logged in CHANGELOG. Stop when the stop condition
holds or the caps say stop.

You may edit, commit locally, and open PRs. Pushes are branch-scoped to
`agent/*` by the push guard and remain ask-gated. You never tag, never release,
never touch `main` directly, and never flip `LOOP_AUTOMERGE` yourself.

<!--
FORGE REPO ONLY. Enable with:
    cp maintenance/forge-loop.command.md .claude/commands/forge-loop.md
See maintenance/forge-loop.md → Activation for the full one-time grant.
-->
