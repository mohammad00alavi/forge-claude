# Option B — GitHub-native auto-merge + required gate check (recommended)

The loop never merges. It only **arms** GitHub's native auto-merge when the toggle is on;
GitHub performs the merge once the required check passes. Branch protection makes the gate
mechanical: red can't merge, no matter who asks.

## Pieces

1. **`forge-pr-gate.yml`** — one small GitHub Action, shipped as
   `maintenance/forge-pr-gate.workflow.yml` and copied to `.github/workflows/` (the existing
   convention for `forge-release` / `forge-self-review`). On every PR to `main`:

   - run `bash maintenance/forge-lint.sh` → this is the required **`forge-gate`** status check
   - fail fast if the PR carries `automerge:halt` or any `human:*` label
   - fail if the diff touches an escalate path (`claude-config/hooks/**`,
     `claude-config/settings.json`, `install.sh`, `maintenance/forge-lint.sh`,
     `maintenance/release-gate.sh`, `**/*.workflow.yml`) **unless** a human has approved —
     touching those files is legal, auto-merging them is not

   Free to run: forge-lint is deterministic, no API key. The eval suite (needs
   `ANTHROPIC_API_KEY`) can join the gate later as a second, optional check.

2. **Branch protection on `main`** (one-time, human, in repo settings): require the
   `forge-gate` check, require the branch to be up to date, block direct pushes, and enable
   **"Allow auto-merge"** in repo settings.

3. **The loop's merge step** becomes two lines:

   ```
   LOOP_AUTOMERGE=true  → gh pr merge <N> --auto --squash -R mohammad00alavi/forge-claude
   LOOP_AUTOMERGE=false → do nothing; request review
   ```

   `--auto` doesn't merge — it registers intent. GitHub merges iff `forge-gate` goes green and
   protection is satisfied. If the gate is red, the PR just sits there, ready for you.

4. **`/automerge` command** — same as Option A (`gh variable set LOOP_AUTOMERGE …`), plus:
   `/automerge off` also runs `gh pr merge --disable-auto` on the loop's open PRs, so nothing
   armed earlier can land after you turn it off.

## Both modes, concretely

- **OFF:** loop opens ready PRs and stops. `forge-gate` still runs (nice: you get a green/red
  signal before reviewing), but only you merge. Byte-identical to the human-merge flow.
- **ON:** same PRs, same gate — GitHub merges the green ones. You review after the fact, or
  spot-check; `automerge:halt` on anything suspicious stops the world.

## Why this is the recommendation

- **The gate rule becomes physics.** "The gate decides done, never the model's opinion" is
  enforced by branch protection, not by skill text. A confused session cannot merge red.
- **Wall 1 survives in both modes.** The agent never executes a merge; it expresses intent and
  the platform acts. OFF mode doesn't even do that.
- **Laptop-off capable.** Auto-merge fires when CI finishes, no session required — the only
  option where ON works without you or a daemon being awake.
- **Minimal new code.** One ~40-line workflow, a command file, a two-line skill step. No Node,
  no merge queue, no verdict machinery.

## Trade-offs

**Against:** one-time human setup (protection rules, allow-auto-merge setting, `gh variable
set`, label creation) — cannot be committed, mirrors bondly's activation-runbook step; requires
the repo to run Actions (it already will, once the self-review/release workflows are installed);
merge commits are authored by GitHub (github-actions / merge event), so the "who merged"
trail reads differently from a human squash — worth a line in CHANGELOG conventions.

**Failure honesty:** if `forge-lint.sh` has a blind spot, ON mode lands the blind spot without
a human read. Mitigation is the escalate-path deny and keeping the lint growing — same posture
bondly takes ("review is the ceiling").
