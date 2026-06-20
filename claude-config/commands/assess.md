---
description: Score a venture idea's difficulty (T0–T4), propose roster + model/effort tiers + cost band, then stop for tier approval — $ARGUMENTS
---

Assess this venture idea: $ARGUMENTS

Hand off to the `strategist` agent. It must:

1. Read `.claude/memory/learnings.md` to calibrate from past outcomes, then
   `.claude/skills/forge-playbook/SKILL.md` + references.
2. Score the idea on the 5-axis difficulty rubric — show per-axis scores and
   the total, and pick a tier (T0–T4). Lean low when uncertain.
3. Propose: the agent roster, model + effort per agent, a rough token-cost
   band, and the lifecycle plan. Justify each agent by its distinct output.
4. **STOP and present the tier + cost band for my approval.** Do not create
   files or spawn other agents yet. I approve the effort/cost tier before any
   spend; after that you run automatically.

End with the strategist's Verdict block.
