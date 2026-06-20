# The learning loop — how Forge gets smarter run over run

This is what separates Forge v2 from a static workflow. Most agent setups are
as useful on venture #20 as on venture #1 because they forget. Forge keeps a
plain-text ledger of what its estimates and decisions actually produced, and
reads it back before the next estimate. No vector DB, no neural net — just a
file the system appends to and consults. (Inspired by the compounding-memory
pattern and ReasoningBank's confidence idea, kept deliberately lightweight.)

## Where it lives

`.claude/memory/learnings.md` — global, spans all ventures. Committed to git
so it travels and compounds. This is procedural memory ("how estimation and
building actually go for me"), distinct from per-venture STATE.md (which dies
with the venture).

## The five-stage discipline (fail → investigate → verify → distill → consult)

A learning is only worth writing if it reaches stage 4. Don't log raw failures
or guesses — log distilled, reusable rules:

1. **Fail / surprise** — an estimate was wrong, a build hit an unexpected wall,
   a deliverable got rejected.
2. **Investigate** — why? (auth was underscoped; the chosen lib didn't support
   X; the pricing claim was unverifiable.)
3. **Verify** — confirm the cause, don't guess.
4. **Distill** — turn it into a rule that applies beyond this one venture.
5. **Consult** — the next `/assess` and `/architect` read these rules first.

## What gets logged, and the format

Each entry is one distilled rule with a confidence marker and a date. The
confidence marker is the ReasoningBank idea in plain form: a rule that keeps
proving true gets ↑, one that misfires gets ↓ or removed.

## Two rules that keep the ledger trustworthy (adopted from Hermes Agent)

Hermes' source enforces a sharp line that makes its memory reliable. Forge
adopts both, because a learning ledger that breaks them quietly corrupts future
estimates.

**Rule A — Declarative facts, NOT imperatives.** Write each learning as a
*fact about the world*, never as an instruction to yourself.
- `OAuth integrations are always ≥ +1 on the integration axis` ✓ (fact)
- `Always add +1 for OAuth` ✗ (imperative)
- `"Simple CRUD" with multi-user hides a permissions model` ✓
- `Score multi-user CRUD as data axis 2` ✗

Why this matters: an imperative learning gets re-read in a later venture as a
*directive* and can silently override that venture's actual requirements or
cause wrong scoring. A declarative fact informs judgment; an imperative
hijacks it. Procedures and step-by-step workflows do NOT belong in the ledger
at all — if you discover "how to set up X," that's a skill, not a learning.

**Rule B — Staleness test.** If a fact will be stale in a week, it is not a
learning. The ledger holds *durable, cross-venture* truths about estimation,
build traps, and routing — never venture-specific artifacts. Banned from the
ledger: PR/issue numbers, commit SHAs, "feature X done," "venture Y shipped,"
file counts, per-venture progress. Those live in the venture's STATE.md and die
with the venture. The ledger is procedural/estimation memory that travels.

A quick test before appending: "Will this still be true and useful three
ventures from now, for a *different* project?" If no, it belongs in STATE.md,
not learnings.md.

```markdown
# Forge learnings (read before every /assess and /architect)

## Estimation calibration
- [↑↑ 2026-06-17] Anything with third-party auth (OAuth, SSO) is +1 on the
  integration axis minimum — I have under-scoped this 3×. (T2→T3 twice.)
- [↑ 2026-06-15] "Simple CRUD" with multi-user always hides a permissions
  model → +1 data axis.
- [↓ 2026-06-10] Assumed Stripe always = T3; actually Checkout-only is fine at
  T2. Down-weighting.

## Build patterns that worked
- [↑ 2026-06-16] For T0/T1 landing pages, a single static file + a form
  service beat any framework on time-to-ship. Default to it.

## Build traps to avoid
- [↑↑ 2026-06-14] Never let the builder pick a date/timezone lib without the
  architect specifying one — caused 2 rework loops.

## Deliverable lessons
- [↑ 2026-06-12] Pricing numbers ALWAYS go to the human; agent-proposed
  numbers were rejected 4/4 times. Propose rationale, never a figure.

## Routing / cost lessons
- [↑ 2026-06-11] Running the verifier on Haiku caught the same defects as
  Sonnet at ~1/10 cost — keep verifier cheap.
```

## When the loop runs

- **Read** at the start of every `/assess` (calibrate the estimate) and
  `/architect` (avoid known traps). The strategist and architect must consult
  it before producing their verdicts.
- **Write** at the end of every venture (the `ship` stage) and whenever a
  re-tiering or a rejected deliverable reveals a reusable lesson. The manager
  (T2+) or strategist owns the write.

## Confidence updates (formalized — the cheap version of ReasoningBank)

Ruflo's ReasoningBank confirmed this Bayesian-confidence idea works at scale
(+20% confidence on success, −15% on failure). Here is the lean, exact rule —
no fuzzy "proven a few times":

- **New rule** → mark `↑` (one confirmation).
- **Confirmed again** → `↑` becomes `↑↑` only after **3 total confirmations**.
- **Misfired once** → drop one level (`↑↑` → `↑`, or `↑` → `↓`).
- **Misfired at `↓`** → drop to `↓↓` and **prune it** (it's doing harm).

This means by venture #20 the estimate is calibrated by 19 real outcomes with
unreliable rules already pruned out — not just the static rubric.

## Promotion to the rubric (the compounding mechanism)

When an estimation learning reaches **`↑↑` (3 confirmations)**, PROMOTE it:
copy it into `references/difficulty-rubric.md` as a permanent scoring rule, and
mark it `[promoted]` in the ledger (keep the line for history, stop
re-evaluating it). The ledger is the staging area; the rubric is settled law.

This is the difference between a file that merely *grows* and one that
*graduates* its best rules into permanent scoring. It is what makes the rubric
itself improve over time — the whole point of the loop.

The nudge hook (settings.json `Stop`) reminds the system to write a learning
when a stage surfaced one (a re-tier, a rejection, a failure) but nothing was
recorded — so the loop doesn't silently lapse under time pressure. This is the
lean version of Hermes Agent's self-prompt-to-persist mechanism.

## What this is NOT

- Not a vector database. A grep-able markdown file is enough at human venture
  volume. If you ever run hundreds of ventures and the file gets unwieldy,
  THAT is when you graduate to Ruflo's ReasoningBank (see README upgrade path).
- Not auto-applied without judgment. A confidently-wrong learning poisons
  every future estimate, so the human reviews the ledger periodically and
  prunes. Keep a person between "lesson" and "law."
```
