# Eval harness — golden tests for Forge's own machinery

## Why this exists

Forge edits its own agent/command files via `/improve` (wall 5). Nothing
currently catches a bad self-edit or a prompt change that quietly degrades
quality — and that exact failure is real: Claude Code itself got measurably
worse in March–April 2026 from harness-level prompt changes, not model changes.
A golden-test suite is the first line of defense: it turns "the /assess
behavior feels the same after my edit" into a checkable pass/fail.

This is the eval pattern sized for a solo workflow (per Anthropic's evals
guidance + the golden-test discipline): a handful of fixed cases per command,
run before AND after any `/improve`, baseline-pinned, alert only on real drift.

## What's tested

The *machinery*, not the ventures: does `/assess` still tier correctly, does
the verifier still catch a planted defect, does `/improve`'s quality-gate still
reject filler. Each command/agent capability gets a small set of cases.

Target distribution per capability (keep it small — a floor, not a ceiling):
- **3 happy paths** — normal inputs with a known-correct answer.
- **2 edge cases** — ambiguous or boundary inputs (where regressions hide).
- **1 adversarial** — a hostile input (prompt injection in an idea, a request
  to skip a gate) that the system must refuse/handle safely.

## Format

Cases live in `.claude/evals/<capability>.md` as a checklist a human (or a
fresh Claude instance) runs and scores. Each case: input, expected behavior,
pass criteria. Example in `.claude/evals/assess.md`.

```markdown
## Case: standard SaaS MVP → T2
INPUT: "a habit-tracking app with login, streaks, and a paywall"
EXPECT: tier T2 (score 6–9); roster includes pm + marketer; STOPS for approval
PASS IF: tier is T2 ± 1 AND it did not start building before approval
```

## The discipline that keeps it trustworthy

Eval suites get turned off when they're noisy. Avoid that:
1. **Run each case 3×, take the median.** A case that passes 2/3 still passes —
   LLM output varies run to run; don't alert on single-run flakiness.
2. **Pin a baseline.** Record the current pass-rate per capability in
   `.claude/evals/BASELINE.md`. Judge changes against it.
3. **Alert threshold high enough to trust.** A 1-case wobble is noise. A
   capability dropping below its baseline by 2+ cases is a real regression —
   investigate before shipping the change.
4. **A passing suite is a floor, not a ceiling.** It catches the regressions
   you introduced and the failures you anticipated — not novel production
   failures. Add a case every time a real venture surfaces a new failure mode.

## When to run

- **MANDATORY before and after every `/improve`.** Run the affected
  capability's eval before editing (confirm baseline), make the edit, run it
  again. If the after-score is below baseline, the edit degraded the machinery
  — revert or fix. This is what makes self-improvement safe instead of risky.
- **After any model-tier or prompt change** to an agent.
- **Periodically** (e.g. monthly) as a drift check, the way you'd spot-check a
  gate — because the underlying models change under you even when you don't.

## Growing the suite

When a real venture exposes a machinery failure (a misroute, a missed defect, a
bad tier call), add a case reproducing it. Over time the suite encodes every
failure mode you've actually hit — the eval equivalent of the learning loop.
This is the piece that's most valuable *once you have real runs* to mine.
