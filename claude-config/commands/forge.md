---
description: Run the full build lifecycle for an assessed venture (architect → build + business tracks → gates) — $ARGUMENTS
---

Forge this venture: $ARGUMENTS

Precondition: a tier has been assessed and approved via /assess. If not, run
/assess first and stop for approval.

Hand off to the `strategist` to orchestrate `references/lifecycle.md`. The
strategist + architect READ `.claude/memory/learnings.md` first; the manager
WRITES distilled lessons back at ship.

1. **Resume check** — read `ventures/<slug>/STATE.md` and handoff ledger; if
   in progress, resume, don't restart.
2. **Architect** — spawn `architect` to design the solution, pick the stack,
   and FINALIZE the roster. Re-tier if reality differs (up-tier → re-approve).
3. **Forge** — run engineering and business tracks per the finalized roster:
   - Engineering: `builder` implements each feature in a worktree → `verifier`
     checks against spec + gates (cross-provider review too if STATE.md
     `Cross-verify` is set — see references/cross-verify.md) → fix loop (max 3).
     If the gate is still red after 3 rounds AND cross-verify is enabled AND the
     rescue plugin is actually installed, try a cross-model rescue
     (`/codex:rescue`) BEFORE escalating to me — a different model often breaks a
     deadlock the same model can't. If that plugin isn't installed, skip the
     rescue and escalate to me directly — never block a build on a missing
     optional tool. Then commit locally and open a PR (free). `git push`/deploy
     are denied — I review locally and push.
   - **Learning nudge at every feature boundary** (Hermes-style cadence): after
     EACH feature completes — not just at session end — if that feature
     surfaced a reusable lesson (a trap, a re-tier, a rejected approach, a
     routing surprise), the manager distills ONE declarative cross-venture fact
     into `.claude/memory/learnings.md` before starting the next feature. This
     catches lessons mid-work that a session-end-only nudge would lose. Facts
     not imperatives; skip anything stale in a week (learning-loop.md rules).
   - Business (T2+): `pm` → `marketer` → `sales` (T3+), each deliverable
     reviewed against business-quality.md. `manager` keeps tracks synced.
     `compliance` runs at T4.
4. Update STATE.md continuously. Surface everything needing a human in one
   place. Never merge, deploy, publish, or spend without my approval.

Report progress and stop at any human-decision gate.
