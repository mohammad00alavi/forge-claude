# Lifecycle — zero to ship, stage by stage

Every venture lives in `ventures/<slug>/`. Each stage reads the venture state
file first and writes to it last (the system forgets; the file does not).

## Stage 0 — Assess (`/assess`)
1. strategist reads the idea, scores difficulty (5-axis rubric), picks a tier.
2. Proposes: roster, model/effort per agent, rough token-cost band, and the
   lifecycle plan.
3. **STOP — present the tier + cost band for approval.** (User approves the
   tier before any spend; after that the orchestrator runs automatically.)
4. On approval, create `ventures/<slug>/` with the state file and proceed
   (use the **lean STATE** at T0/T1, the full template at T2+ — references/state.md).

## Stage 1 — Brainstorm (`/brainstorm`, only if the idea is fuzzy)
- strategist + (T2+) pm sharpen the idea into: one-line value prop, target
  user, the single core thing it must do, explicit non-goals.
- Skip entirely if the idea is already crisp. Don't manufacture ceremony.

## Stage 2 — Architect (`/architect`)
- architect designs the solution: stack choice (justified), data model,
  key components, and at T2+ the product architecture (feature breakdown).
- **Finalizes the agent roster** — adds/drops agents vs. the tier default,
  justifying each by its distinct output.
- Re-tiers if reality differs from the assessment (up-tier needs re-approval).
- Output: an architecture doc + a delta/spec per feature for the builder.

## Stage 3 — Forge (`/forge`)
Engineering and business tracks run in parallel (manager keeps them synced at
T2+):
- **Engineering**: for each feature — builder implements in a worktree →
  verifier checks against spec + runs gates → fix loop (max 3 rounds) →
  commit locally + open PR (free); human reviews and pushes → next feature.
- **Business** (T2+): pm finalizes backlog → marketer drafts positioning +
  assets → sales (T3+) drafts pricing + outreach. Scaled to tier.
- Gates are objective for code (typecheck/lint/test/build) and rubric-based
  for deliverables (`business-quality.md`).

## Stage 4 — GTM (`/gtm`)
- marketer + sales assemble the launch package scaled to tier: landing copy,
  pricing, launch posts, outreach templates, demo script. Real files in
  `ventures/<slug>/deliverables/`.
- At T0/T1 this is just the landing copy; at T3/T4 it's a full GTM kit.

## Stage 5 — Ship
- Assemble a launch checklist. Surface everything that needs a human:
  deploys, domain/DNS, payment setup, publishing, legal review.
- Hand polished deliverables back for review. **Never auto-deploy, auto-
  publish, or spend money.**
- **WRITE the learning loop** (NEW): the manager appends distilled lessons to
  `.claude/memory/learnings.md` — was the difficulty estimate right? what build
  trap recurred? what routing worked? Bump confidence on rules that proved
  true again. This is what makes the next venture's estimate sharper. See
  references/learning-loop.md.

## Resume
Any stage can resume from the venture state file + handoff ledger. A dead
session re-reads state, never restarts. `/forge <slug>` continues where it
stopped.
