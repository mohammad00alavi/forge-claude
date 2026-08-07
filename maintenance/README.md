# Forge self-maintenance (maintainer-only)

Everything in this folder maintains the Forge repo ITSELF. It lives outside
`claude-config/`, so `install.sh` never ships it to a user's project. Users who
clone Forge get `/improve` (to fix their own local copy); this repo-wide
self-review is for the maintainer only.

## Pieces
- **`forge-lint.sh`** — deterministic consistency checks (agent/command counts,
  dead path-variable notation, machinery-log-in-learnings, weakened walls,
  dangling references, ungated commands, an unrun baseline). Exits non-zero on a
  regression. Free, no API key. Run any time: `bash maintenance/forge-lint.sh`.
- **`self-review.md`** — the daily LLM self-review playbook: health → eval gate
  vs BASELINE → mine the usage signal → gated `/improve` fixes → digest. It
  proposes; it never ships.
- **`self-review.command.md`** — optional `/self-review` slash command for the
  repo: `cp maintenance/self-review.command.md .claude/commands/self-review.md`.
- **`forge-self-review.workflow.yml`** — the GitHub Action (daily). Install:
  `cp maintenance/forge-self-review.workflow.yml .github/workflows/forge-self-review.yml`.
- **`digests/`** — dated self-review digests land here.
- **`release-gate.sh`** — deterministic release readiness check (lint + version
  markers agree + eval baseline established + tag free). `maintenance/release-gate.sh 3.9`.
- **`forge-release.workflow.yml`** — the tag-on-demand release Action. Install:
  `cp maintenance/forge-release.workflow.yml .github/workflows/forge-release.yml`.
- **`automerge.command.md`** — optional `/automerge` toggle for THIS repo (design:
  `docs/design/automerge/`, Option A). Off = agents stop at a ready PR (default);
  on = they may squash-merge under the merge-step contract. Install:
  `cp maintenance/automerge.command.md .claude/commands/automerge.md`.
- **`forge-loop-merge-step.md`** — the contract an agent-performed merge must satisfy
  (threads resolved incl. bots · CI green · behind-zero via `gh pr update-branch` ·
  fresh lint · no `human:*`/`automerge:halt` · no escalate paths).
- **`automerge-merge-guard.sh`** — PreToolUse hook walling `gh pr merge` behind the
  human-set `LOOP_AUTOMERGE` repo variable + a fresh `forge-lint` pass; blocks
  `--admin` always; fail-closed when the variable is unreadable.
- **`forge-loop.md`** — the loop playbook: queue = `forge-loop-ready` GitHub issues →
  return path first → worktree maker (fixer/builder) → lint+eval gate →
  fresh-context verifier → ready PR `Closes #N` → toggle-aware merge step.
  Standing config in **`LOOP-STATE.md`** (caps · escalate · roles · lessons);
  tracker/label/domain config for shaping skills in `docs/agents/`.
- **`forge-loop.command.md`** — optional `/forge-loop` (one iteration). Install:
  `cp maintenance/forge-loop.command.md .claude/commands/forge-loop.md`.
- **`loop-push-guard.sh`** — PreToolUse hook making Wall 1's loop exception
  mechanical: `git push` allowed ONLY as `git push [-u] origin agent/<branch>` —
  no force/delete/tags/refspecs/other remotes; everything else stays human.

## Cutting a release (tag-on-demand)

Releases are deliberate and human-triggered — the self-review never tags. When a
batch of merged improvements is ready:

1. Bump the version markers: `README` badge, `install.sh` echo, and add a
   `CHANGELOG.md` section (see RELEASING.md). `release-gate.sh <v>` tells you if
   anything's inconsistent.
2. Push to `main`.
3. **Actions → Forge release → Run workflow → enter the version.** It re-runs the
   gate, then creates the annotated `vX.Y` tag and publishes the GitHub Release.
   If the gate fails, it does NOT tag — it tells you exactly what to fix.

This is CI you trigger, not an agent shipping on its own: the self-review job
still can't tag; only this human-dispatched job does.

## Why it's safe to automate
Same wall as the rest of Forge: the loop OBSERVES daily and PROPOSES (edits + the
eval gate + a PR), but the HUMAN ships. It can never push, merge, tag, or cut a
release — Forge's `settings.json` deny-list holds even inside CI. It acts only on
**confirmed patterns** (a trap seen ≥2×, a learning at `↑↑`, or an eval
regression), with a small per-run change budget — biased toward stability, the
opposite of Forge's early 8-versions-in-a-day thrash.

## Start small
The `health` job is turnkey and free — enable it first. Add the `self-review`
job (and the `ANTHROPIC_API_KEY` secret) when you want the LLM layer on top.
