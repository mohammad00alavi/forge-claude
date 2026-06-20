# Maintenance mode — always-running done safely

## The one distinction that makes this safe

Maintenance mode separates two things most people conflate:

- **Autonomy = WHEN the agent runs.** Manually, or triggered by CI failure, a
  schedule, or an error spike. This *can* be wide — unattended is fine.
- **Permissions = WHAT the agent can do without you.** This stays NARROW, in
  maintain mode even more than build mode. Edits and *local* git (add, commit,
  open a PR) are free; `git push`/merge/deploy are denied to agents — only you
  push, after reviewing locally. Always.

**These are independent axes.** You can have maximum autonomy (runs at 3am on a
CI failure) with minimum freedom (investigates, drafts, gates, then STOPS for
your approval). That combination is the *only* safe shape for unattended work —
and it's exactly what every battle-tested system does. Professor's `/jc` works
live on `main` yet refuses to push without explicit human request. Hermes runs
unattended kanban lanes behind a reviewer gate. Ruflo proposes PRs; humans
merge. None of them widen permissions for autonomy. Neither does Forge.

## Why widening permissions for autonomy is the dangerous move

The reason an unattended loop is safe is *precisely* that its permissions are
narrow. Local commits are reversible and stay on your machine; the dangerous
step is the *outward* one — push/deploy. So those are denied to agents: an
always-running loop can investigate, fix, commit locally, and open a PR, but a
hallucinated diff can never reach the remote at 3am because pushing requires
you. Autonomy multiplies whatever *outward* authority you grant by "and nobody's
watching" — so the outward step (push) is exactly the one to keep human-only.

## Triggers (the "always-running" you actually want)

Configure WHEN /fix fires, never WHAT it may do:

- **On CI failure** — CI red → fire /fix to investigate and draft a fix.
- **On schedule** — e.g. a nightly health check / dependency-drift scan.
- **On error spike** — an alert (Sentry-class) → fire /fix to triage.

Every trigger ends the same way: explore → diagnose → fix → run gates →
**commit locally + open a PR → STOP.** The trigger started it; only you push.
A trigger may commit locally (reversible) but can never `git push` or deploy —
those are denied to agents, on purpose. (Mechanically, triggers live outside Forge — your CI/cron/alerting
fires the Claude Code session; Forge governs what happens inside it.)

## Denied paths — OPTIONAL extra layer (the git-gate is the real protection)

First, the honest framing: **the deny-list is not the primary safety model — the
git-gate is.** Edits and local commits are free but reversible; nothing reaches
the remote without you pushing by hand. That commit/push gate is what keeps the
system safe, and it's the same model the battle-tested systems use (Professor
and Hermes gate git through agent instructions; Forge gates it mechanically in
config, which is stronger). **A project with a completely empty deny-list is
still fully safe, because the push gate holds.**

The deny-list is an *optional belt-and-suspenders layer* for the rare paths
where you want edits to be not just reviewable-before-push but *impossible* —
where even an accidental local edit is unacceptable. It's stronger than a prose
instruction ("never edit auth") because it's mechanical: `deny` overrides
`allow`, so the agent physically cannot edit the path, regardless of what any
instruction says. Most projects won't need much in it.

When you DO want it, the test is simple: *if a wrong change here is expensive,
irreversible, or unsafe, deny it.* Common categories:
- authentication / authorization / access-control logic
- payment, billing, and any fund-movement code
- secrets, API keys, credentials, `.env`
- any domain-specific high-risk logic (whatever, in this project, is the code
  you'd never let change without reviewing it yourself)

Add the paths to `.claude/settings.json` `deny` AND list them in STATE.md so
every agent knows. Example (adapt the globs to the project):
```json
"deny": [
  "Edit(**/auth/**)", "Edit(**/payments/**)", "Edit(**/billing/**)",
  "Edit(**/secrets/**)", "Edit(.env*)",
  "Edit(**/<your-high-risk-area>/**)"
]
```
The fixer/explorer will FLAG when an issue touches these and escalate to you —
they never work around a denied path.

## The maintain-mode loop (what runs, manually or triggered)

```
/fix "<bug or change>"
  explorer  → maps code (read-only): where, current behavior, test, blast radius
  fixer     → root-cause diagnosis → failing test → smallest diff → run gates
            → commit locally + open a PR
  verifier  → independent check (+ cross-provider if enabled); either FAIL blocks
  STOP      → show diagnosis + diff + gates + the local PR → YOU review and push
```

Edits and commits happened freely (reversible, on a branch, all local). The
push — the one outward, irreversible-ish step — waited for you. That's the
whole design.

## Build mode vs maintain mode

- **Build** (/assess /forge /gtm): greenfield, zero-to-sell. Difficulty
  routing, business lifecycle, architect picks the stack.
- **Maintain** (/maintain /fix): existing codebase. Explorer maps it, fixer
  makes the smallest correct change, full gates, local commit + PR, human-only
  push, optional triggers for unattended running.

Same security model in both. Maintain mode is *tighter* (production code,
possibly unattended), never looser.
