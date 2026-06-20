---
description: First-run orientation — explains Forge in 60 seconds and walks you into your first venture — $ARGUMENTS
---

Orient me to Forge and help me start. $ARGUMENTS

This is the first-run flow. Don't dump the whole system — give a tight
orientation, then move me toward action. Keep it conversational, not a manual.

## Step 1 — The 60-second explanation

Tell me, briefly:
- **What Forge does:** takes a product idea from zero to sellable, spending
  effort proportional to difficulty (a landing page ≠ a fintech app).
- **The one loop I need:** `/assess "my idea"` → you score difficulty (T0–T4),
  propose a roster + cost, and STOP for my approval → then `/forge <slug>`
  builds it. For a fuzzy idea, start with `/brainstorm`.
- **The one safety fact:** edits are free, but nothing gets committed, deployed,
  or spent without my explicit yes. I'm always the gate on irreversible things.

Don't list all 11 agents or 6 commands — mention they exist and that the right
ones engage automatically based on the project's tier.

## Step 2 — Check readiness (briefly)

- Confirm the workspace has `.claude/` installed (agents, commands, the
  forge-playbook skill). If not, point me to install.sh.
- Mention `.claude/memory/learnings.md` is empty now and fills as I ship — the
  system gets sharper with use, but starts capable.
- Note that the eval baseline is unrun; offer (optionally) to establish it later
  via the eval harness, but don't block my first venture on it.

## Step 3 — Recommend the right first venture

Strongly recommend starting **small (T0 or T1)** for a first run — a landing
page, a waitlist, a one-feature tool. The reason: a first run's value is
learning how Forge behaves on a real thing and seeding the learning loop, and a
small venture gets you through the whole lifecycle fast. A T3 SaaS as a first
venture is a bad idea — too much at once before I know how the system feels.

Then ask me ONE question: **do I have an idea to start with, or want you to
suggest a tiny realistic one to test with?**
- If I have one → run `/assess` on it.
- If not → suggest a genuinely small, realistic T0/T1 idea I could actually
  use or throw away, and offer to assess it.

## Tone

Encouraging and brief. The goal of `/start` is to get me from "I installed
this" to "I'm assessing my first real idea" in one short exchange — not to
teach me everything. Everything else I'll learn by doing.
