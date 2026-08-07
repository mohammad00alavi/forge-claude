# Consumer auto-merge — shipping the toggle in `claude-config/`

> **Decision note (2026-08-04):** Option **A** was chosen, so what ships differs from the
> B-flavored design below: the consumer gets `claude-config/commands/automerge.md` (the
> command + the merge contract) and `claude-config/hooks/automerge-merge-guard.sh` (the
> mechanical wall on `gh pr merge`), wired in `claude-config/settings.json`. No workflow
> template is required; branch protection with the project's CI as a required check is
> *recommended* in the command's setup step, not mandated. The sections below stay as the
> original B-shaped design record.
>
> **Decision note 2 (2026-08-04, later):** the full LOOP also ships to consumers —
> `claude-config/commands/forge-loop.md` (queue = human-labelled `forge-loop-ready`
> issues → worktree maker → project gate → fresh verifier → ready PR → toggle-aware
> merge) plus `claude-config/hooks/loop-push-guard.sh`. To let the loop publish its PR
> branches, the blanket push deny moved into the hooks: every push must be exactly
> `git push [-u] origin agent/<branch>` (block-dangerous-git.sh scopes it,
> loop-push-guard.sh validates strictly). Merge authority is unchanged — human, or the
> contract under `/automerge on`.

Consumers get the same toggle: `/automerge on|off` in their own project, off by default.
Originally designed as Option B generalized — merge performed by GitHub after the project's
own gate check passes. Wall 1 ("push/merge/deploy are yours alone") holds by default in every
install; auto-merge is a **human-granted, mechanically-gated exception**.

## What ships (moves into `claude-config/`, lands in every install)

| Piece | Where | Notes |
|---|---|---|
| `/automerge` command | `claude-config/commands/automerge.md` | `on` / `off` / bare (status) / `setup` |
| PR-gate workflow template | `claude-config/templates/pr-gate.workflow.yml` | generic; gate command is a placeholder |
| This design as user docs | README "Commands" section + a short guide | consumer-facing wording |

Forge-repo self-maintenance keeps its own copy in `maintenance/` (gate = `forge-lint.sh`);
the consumer template is the same shape with the gate swapped.

## The gate is the project's own

Forge can't know a project's test command, so the check that protects `main` is theirs:

- `/automerge setup` asks for (or detects) the gate command — `npm run gate`, `npm test`,
  `pytest`, `go test ./...` — and writes it into the copied workflow.
- The workflow publishes the **`gate`** status check on every PR; branch protection requires it.
- Forge's verifier agent remains the *pre-PR* gate (maker ≠ checker); the CI check is the
  *merge* gate. Both must pass — the verifier can't merge, and CI can't be skipped.

## `/automerge setup` — one-time, human-run, per consumer repo

Automates the activation runbook instead of documenting it:

1. Copy `pr-gate.workflow.yml` → `.github/workflows/pr-gate.yml`, fill the gate command.
2. `gh repo edit --enable-auto-merge`
3. `gh label create` — `automerge:halt`, `human:authorize`, `human:decide` (+ `risk:*` later).
4. Branch protection on the default branch via `gh api`: require the `gate` check, require
   up-to-date branch, block direct pushes.
5. `gh variable set LOOP_AUTOMERGE --body false` — armed later, explicitly, by the human.

The repo is always derived from `git remote` (never assumed from cwd) and every `gh` call
passes `-R`. Setup refuses to run from a detached/fork remote it can't write to.

## `/automerge on|off`

- `on` → `gh variable set LOOP_AUTOMERGE --body true -R <their repo>`; prints what is now
  eligible to auto-merge and the deny list.
- `off` → sets `false` **and** `gh pr merge --disable-auto` on open agent PRs, so nothing
  armed earlier lands afterwards.
- Agents' behavior: build/maintain flows open PRs **ready, never draft**; when the variable is
  `true` they add `gh pr merge --auto --squash`. That is the entire agent-side delta — arming
  intent, never merging.

## Escalate deny list (consumer defaults)

PRs touching these never auto-merge, toggle regardless — shipped as an editable list inside
the workflow: `.github/**`, `.claude/**`, lockfiles, `infra/**`, `Dockerfile*`, deploy
configs, `.env*`. Projects extend it to their own auth/payment/consent seams.

## Safety posture, restated for the README

- Default install: nothing changes — no workflow, no variable, walls exactly as today.
- Armed: the wall moves from "a human clicks merge" to "the platform merges only green,
  human-scoped classes" — flipping the variable alone is never sufficient; protection and the
  gate check are the enforcement.
- `automerge:halt` label stops everything; `/automerge off` disarms in one command.

## Cost of making it a product feature

It's no longer a maintainer convenience: needs consumer docs, an eval covering the command,
a `forge-lint` consistency check (command ↔ template ↔ README stay in sync), and a MINOR
version bump per RELEASING.md. Budget roughly 2× the self-maintenance-only build.
