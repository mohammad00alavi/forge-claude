# Auto-merge toggle for the Forge dev loop — design options

**Goal:** one switch — `/automerge on` / `/automerge off` — and both modes work:

- **OFF** — the loop stops at a ready PR; you review and merge. Exactly the lean Mode-A flow.
- **ON** — green-gated PRs merge without you; everything else still waits for a human.

**Decided:** the switch lives in a **GitHub repo variable** `LOOP_AUTOMERGE` (`true`/`false`),
same pattern as bondly-frontend's `LOOP_ENABLED`. Flip it with the `/automerge` command
(wraps `gh variable set LOOP_AUTOMERGE --body true -R mohammad00alavi/forge-claude`) or by hand.

**Context:** these designs assume the lean dev-loop port from the 2026-07-31 investigation
(loop pushes only `agent/*` branches, opens PRs **ready, never draft**, with `Closes #N`;
`main` / `release/*` stay protected). The toggle only changes *who performs the merge*.

## The three options

| | A — skill-gated merge | B — native auto-merge + required check | C — Bondly ratified port |
|---|---|---|---|
| Who merges when ON | the agent (`gh pr merge --squash`) | **GitHub**, after checks pass | script (`auto-merge` port) |
| Gate enforcement | skill re-runs `forge-lint.sh` (instruction-level) | **branch protection requires the check (mechanical)** | script + verdict panel |
| Works laptop-off | no — needs a running session | **yes** — merges when CI goes green | yes (with daemon) |
| Wall 1 (agents never push/merge) | most weakened — agent merges | agent never merges; GitHub does, per human-armed setting | agent merges via ratified path |
| New moving parts | command + skill edit | + 1 small CI workflow + protection setup | scripts, labels, queue, breakers |
| Effort | ~half a day | ~1 day incl. one-time setup | days; ongoing upkeep |

- [Option A — skill-gated merge](option-a-skill-gated-merge.md)
- [Option B — native auto-merge + required gate check](option-b-native-automerge-gate.md) ← **recommended**
- [Option C — Bondly-style ratified auto-merge](option-c-bondly-ratified-port.md)

## Recommendation: Option B

The dev loop's core rule is *the gate decides done, never the model's opinion*. Option B is the
only one where that rule is enforced by the platform: branch protection requires the
`forge-gate` check, so nothing — agent, script, or you on a bad day — can merge red. When
`LOOP_AUTOMERGE=false` the loop simply never arms auto-merge and the flow is byte-identical to
today's human-merge mode. It is also the friendliest to Forge's Wall 1: the agent never executes
a merge in either mode. Option A is a fine stepping stone if you want the toggle working in an
hour; C is overkill until Forge has real PR volume or outside contributors.

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

Design docs only — nothing implemented, nothing committed. Pick an option and the
implementation lands as: `maintenance/automerge.command.md` (→ `.claude/commands/automerge.md`),
a merge-step section in the forge `dev-loop` skill, and (Option B) one workflow template in
`maintenance/` following the existing copy-to-`.github/workflows/` convention.
