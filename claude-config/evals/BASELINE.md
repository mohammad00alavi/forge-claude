# Eval baseline — pin pass-rates here, judge changes against this

Record the median pass-rate per capability after a clean run. A change that
drops a capability 2+ cases below its baseline is a regression — investigate
before shipping. Update this file (commit it) only when scores genuinely
improve.

| Capability | Cases | Baseline pass | Last checked | Notes |
|-----------|-------|---------------|--------------|-------|
| /assess   | 6     | 6/6 (median)  | 2026-06-24   | provisional; A1/E1/H3 solid 3/3 after the instruction-gap fixes |
| verifier  | 6     | 6/6 (median)  | 2026-06-24   | provisional; A1 3/3 (forbidden-path = ESCALATE); PASS must cite criteria |
| /improve  | 8     | 8/8 (median)  | 2026-06-24   | provisional; BD/PS enforced by the command, not just the playbook |
| /fix      | 6     | 6/6           | 2026-06-24   | provisional, 1× |
| /research | 5     | 5/5           | 2026-06-24   | provisional, 1× |
| /architect | 4    | 4/4           | 2026-06-25   | provisional, 1× |
| /forge    | 6     | 6/6           | 2026-06-25   | provisional, 1× |
| /gtm      | 7     | 7/7           | 2026-06-25   | provisional, 1× (added H3 positioning quality, E2 T2 boundary) |
| /grill    | 5     | 5/5           | 2026-06-25   | provisional, 1× (added H3 decision-recording) |
| /maintain | 5     | 5/5           | 2026-06-25   | provisional, 1× (E2 tightened → surfaced + fixed a gates-field gap) |
| /brainstorm | 5   | 5/5           | 2026-06-25   | provisional, 1× (added H3 brief-persistence) |
| /improve-arch | 6 | 6/6           | 2026-06-25   | provisional, 1× (H1 now requires a specific shallowness diagnosis) |

**Coverage: 12 of 12 commands** (`/start` excluded — pure onboarding). **69 cases**
total (was 5 suites / 31 cases before 2026-06-25).

> **PROVISIONAL baseline.** Cases were executed against the machinery and graded
> strictly vs each PASS-IF — /assess, verifier and /improve at 3× (median of 3),
> everything else at 1×. Run in an evaluation harness, NOT the live Claude Code
> runtime, so treat it as a directional floor: re-run it in your own environment
> to make it authoritative. It still functions as the regression reference — a
> drop of 2+ cases in a capability is a regression.

## Resolved fragilities (2026-06-24 instruction-gap pass)

The six gaps baselining first surfaced were fixed via the /improve discipline
(eval-before fragile → surgical edit → eval-after solid, no regression).

- /assess A1 — tier-approval gate non-waivable (assess.md + strategist.md) → 3/3
- /assess E1 — rubric anchors multi-user / shared-write = data axis ≥ 2 → 3/3
- /assess H3 — tier tables roster compliance at T3 for regulated domains → 3/3
- verifier A1 — a touched forbidden path is ALWAYS ESCALATE → 3/3
- verifier H2 — a PASS must enumerate each acceptance criterion → enforced
- /improve BD/PS — command now references bash-discipline + project-scope → enforced

## Resolved case-quality notes (2026-06-25 tightening pass)

The four "known notes" from the coverage pass were addressed; one tightening
caught and fixed a real machinery gap.

- /gtm short (2H/1E/2A) → added H3 + E2 (now 3H/2E/2A = 7).
- /grill + /brainstorm didn't test the decision-recording / persistence half →
  added H3 to each (both validated against the machinery).
- /improve-arch H1 generous vocab bar → now requires a specific shallowness
  diagnosis (holds: the machinery already compels it).
- /maintain E2 passed on silence → tightened to require an explicit
  `Gates: MISSING` marker; this surfaced that the STATE template had no gates
  field. **Fixed the machinery** (added `Gates:` to both STATE templates +
  a maintain.md clause); E2 now passes legitimately.

Remaining trivial residual: the /gtm command gives T2 a "basic launch plan"
while the suite reserves "launch sequence" for T3+ — a latent wording ambiguity
(E2 still passes); tighten the command wording if it ever bites.

Add a new case whenever a real venture surfaces a machinery failure mode, then
re-baseline.
