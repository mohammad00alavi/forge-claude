---
description: Forge maintainer-only — flip LOOP_AUTOMERGE for THIS repo. On = agents may squash-merge their own green, review-clean, up-to-date PRs per the merge-step contract. Off (default) = agents stop at a ready PR; the human merges. NOT shipped to installs.
---

Manage the auto-merge toggle for the forge repo itself. Design record:
`docs/design/automerge/` (Option A — skill-gated merge). The contract a merge
must satisfy is `maintenance/forge-loop-merge-step.md`; the mechanical backstop is
the `maintenance/automerge-merge-guard.sh` PreToolUse hook.

This command is **human-invoked only**. Agents never run `/automerge` and never
set `LOOP_AUTOMERGE` themselves — an agent flipping its own switch is a defect.

Parse the argument (`on` / `off` / empty = status). Every `gh` call names the
repo explicitly: `-R mohammad00alavi/forge-claude` (cwd is not a fact you have).

## on

1. **Print this line for the maintainer to run themselves** — the guards refuse
   it from an agent by design: `gh variable set LOOP_AUTOMERGE --body true -R mohammad00alavi/forge-claude`
2. Confirm labels exist (create any missing): `automerge:halt`, `human:authorize`,
   `human:decide` — `gh label list -R mohammad00alavi/forge-claude`.
3. Settle the review policy: does this repo have a reviewer (review bot,
   CODEOWNERS, named reviewers)? The guard requires an approving review **on the
   PR's current head commit** unless `LOOP_REQUIRE_APPROVAL` is `false`. Where
   branch protection is in reach, **recommend** enabling "dismiss stale pull
   request approvals when new commits are pushed" — the server-side twin of that
   check, and one an agent's token cannot switch off.
4. Report: the toggle state, the review policy in force, the merge-step contract
   in one line (threads resolved incl. bots · approval on the current head · CI
   green · 0 behind · fresh `forge-lint` green · no `human:*` /
   `automerge:halt` · no escalate paths), and which currently open PRs would
   become eligible.

## off

1. **Print this line for the maintainer to run themselves** (same reason as `on`):
   `gh variable set LOOP_AUTOMERGE --body false -R mohammad00alavi/forge-claude`
2. On every open agent-owned PR, comment that auto-merge was disarmed by the
   maintainer, so a later reader knows why it waited for a human.
3. Report the new state.

## status (no argument)

Print `gh variable get LOOP_AUTOMERGE -R mohammad00alavi/forge-claude` (unset
== off), the review policy (`LOOP_REQUIRE_APPROVAL` unset/true = an approving
review on the current head is required; false = the verifier is the only
checker), the open PRs with their eligibility (what blocks each: review decision
/ threads / CI / behind / labels / escalate paths), and where the contract
lives. In the review column separate **approved (current head)** from
**approved (stale — re-request)** by comparing each approving review's commit
with `headRefOid`: a stale approval looks identical to a fresh one in GitHub's
UI, so saying which it is carries the whole signal.

<!--
This is the optional `/automerge` slash command for the FORGE REPO ONLY.
Copy it to `.claude/commands/automerge.md` to enable it:
    cp maintenance/automerge.command.md .claude/commands/automerge.md
Wire the mechanical guard in `.claude/settings.json` (repo-local, not committed):
    "PreToolUse": [{ "matcher": "Bash", "hooks": [{ "type": "command",
      "command": "bash \"$CLAUDE_PROJECT_DIR\"/maintenance/automerge-merge-guard.sh" }] }]
It deliberately is NOT in claude-config/ — the consumer edition ships separately
as claude-config/commands/automerge.md with its own guard hook.
-->
