# Auto-merge toggle for the Forge forge loop — design options

**Goal:** one switch — `/automerge on` / `/automerge off` — and both modes work:

- **OFF** — the loop stops at a ready PR; you review and merge. Exactly the lean Mode-A flow.
- **ON** — green-gated PRs merge without you; everything else still waits for a human.

**Decided:** the switch lives in a **GitHub repo variable** `LOOP_AUTOMERGE` (`true`/`false`).
Flip it with the `/automerge` command
(wraps `gh variable set LOOP_AUTOMERGE --body true -R mohammad00alavi/forge-claude`) or by hand.

**Context:** these designs assume the lean forge-loop port designed in the 2026-07-31
investigation (loop pushes only `agent/*` branches, opens PRs **ready, never draft**, with
`Closes #N`; `main` / `release/*` stay protected). The toggle only changes *who performs the
merge*.

## The three options

| | A — skill-gated merge | B — native auto-merge + required check | C — full ratified auto-merge |
|---|---|---|---|
| Who merges when ON | the agent (`gh pr merge --squash`) | **GitHub**, after checks pass | a ratify script |
| Gate enforcement | skill re-runs `forge-lint.sh` (instruction-level) | **branch protection requires the check (mechanical)** | script + verdict panel |
| Works laptop-off | no — needs a running session | **yes** — merges when CI goes green | yes (with daemon) |
| Wall 1 (agents never push/merge) | most weakened — agent merges | agent never merges; GitHub does, per human-armed setting | agent merges via ratified path |
| Open review comments (e.g. Copilot) | agent must remember to fix before merging | **protection blocks merge until resolved; babysitter fixes** | babysitter + verdict panel |
| Behind branch | agent must remember to sync | **protection blocks; babysitter merges base in first** | merge queue serializes |
| New moving parts | command + skill edit | + 1 small CI workflow + protection setup + babysitter skill | scripts, labels, queue, breakers |
| Effort | ~half a day | ~2 days incl. babysitter + one-time setup | days; ongoing upkeep |

- [Consumer auto-merge](consumer-automerge.md) — **requirement:** consumers get the same
  toggle in their own projects. Option B generalized: ships in `claude-config/`, off by
  default, gate = the project's own CI check, one-time `/automerge setup` automates the
  activation. Wall 1 holds by default in every install.

## Recommendation: Option B

The forge loop's core rule is *the gate decides done, never the model's opinion*. Option B is the
only one where that rule is enforced by the platform: branch protection requires the
`forge-gate` check, so nothing — agent, script, or you on a bad day — can merge red. When
`LOOP_AUTOMERGE=false` the loop simply never arms auto-merge and the flow is byte-identical to
today's human-merge mode. It is also the friendliest to Forge's Wall 1: the agent never executes
a merge in either mode. Option A is a fine stepping stone if you want the toggle working in an
hour; C is overkill until Forge has real PR volume or outside contributors.

**Rev. 2026-08-03 — open comments & behind branches.** Raised in review: a green PR can still
carry unresolved Copilot threads, and native auto-merge alone would merge over them; likewise a
branch behind its base shouldn't land until base is merged in (behind = zero). Resolution, now
folded into Option B: branch protection additionally requires **conversation resolution** and
**up-to-date branch** (mechanical blocks), and a **babysitter skill** is the worker that fixes
comments and CI, merges base into the branch, re-gates and pushes. The recommendation is
therefore **B + babysitter**: agents fix everything, the platform performs the merge. The
babysitter is equally necessary under A or C — no option escapes needing the return path.

## Safety rules common to every option

- `human:legal` / `human:authorize` / any `human:*` label → never auto-merged.
- **Escalate paths** — diffs touching `claude-config/hooks/**`, `claude-config/settings.json`,
  `install.sh`, `maintenance/forge-lint.sh`, `maintenance/release-gate.sh`, or any
  `*.workflow.yml` → always human-merged, regardless of the toggle.
- `automerge:halt` label (on the PR or an open issue) overrides the variable: everything stops.
- Releases are untouched: tagging stays human-triggered via `release-gate.sh` + the release
  Action. Auto-merge applies to PRs into `main` only, never to tags or `release/*`.
- The variable is human-only **by convention**; the mechanical wall is branch protection
  (Option B) or the merge-blocking hook (Option A). Assume a misbehaving session *could* flip a
  variable — design so that flipping it alone is never sufficient to land a bad change.

## Status

**Decided 2026-08-04: Option A** (maintainer's call, accepting the trade-offs listed in
option A; the babysitter-style return path is folded into the merge-step contract itself).
Implemented on branch `release/v3.9.5`:

- Self-maintenance: `maintenance/automerge.command.md` (→ `.claude/commands/automerge.md`),
  `maintenance/forge-loop-merge-step.md` (the contract; becomes the forge-loop skill's merge
  step when the loop port lands), `maintenance/automerge-merge-guard.sh` (PreToolUse wall).
- Consumer: `claude-config/commands/automerge.md` + `claude-config/hooks/automerge-merge-guard.sh`,
  wired in `claude-config/settings.json` — ships with installs, off by default. See the
  decision note in [consumer-automerge.md](consumer-automerge.md).

The full option write-ups were pruned after the decision; the comparison table
above is the record of the roads not taken.
