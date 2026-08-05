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

1. `gh variable set LOOP_AUTOMERGE --body true -R mohammad00alavi/forge-claude`
2. Confirm labels exist (create any missing): `automerge:halt`, `human:authorize`,
   `human:decide` — `gh label list -R mohammad00alavi/forge-claude`.
3. Report: the toggle state, the merge-step contract in one line (threads
   resolved incl. bots · CI green · 0 behind · fresh `forge-lint` green · no
   `human:*` / `automerge:halt` · no escalate paths), and which currently open
   PRs would become eligible.

## off

1. `gh variable set LOOP_AUTOMERGE --body false -R mohammad00alavi/forge-claude`
2. On every open agent-owned PR, comment that auto-merge was disarmed by the
   maintainer, so a later reader knows why it waited for a human.
3. Report the new state.

## status (no argument)

Print `gh variable get LOOP_AUTOMERGE -R mohammad00alavi/forge-claude` (unset
== off), the open PRs with their eligibility (what blocks each: threads / CI /
behind / labels / escalate paths), and where the contract lives.

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
