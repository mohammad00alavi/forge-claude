---
description: Deep multi-perspective research on a topic (STORM method) — 5 perspectives, contradiction map, synthesis, self-critique — grounded in real web search — $ARGUMENTS
---

Research deeply: $ARGUMENTS

Use the STORM method (references/storm-research.md) — multi-perspective research
with a contradiction map, synthesis, and a self-critique step, grounded in REAL
web sources (not the model's priors). Available standalone, and invoked by the
strategist/architect when a venture needs real understanding.

## Before starting — scale the depth

Match effort to the question (same instinct as difficulty routing):
- **Quick check** (known area, low stakes) → Stage 1 with 2-3 perspectives only.
- **Standard** → all four stages, 5 perspectives.
- **High-stakes/novel/regulated** → all four, 5+ perspectives, extra sourcing.

If the topic is a VENTURE question, use the venture-tuned perspectives
(practitioner / market analyst / skeptic / competitor / target user); otherwise
the general set (practitioner / academic / skeptic / economist / historian).

## The four stages (full method in references/storm-research.md)

1. **Multi-perspective scan** — for each perspective: `web_search` for real
   sources, then core position + strongest SOURCED evidence (cite it) + the one
   thing only they'd say. (These perspectives are independent — dispatch as
   parallel subagents if practical; sequential is fine otherwise.)
2. **Contradiction map** — where voices clash, who has the strongest/weakest
   evidence, the question that resolves the biggest clash, what ALL agree on
   (likely true), what NONE addressed (the blind spot).
3. **Synthesis** — one-paragraph summary, findings ranked by reliability, the
   hidden cross-perspective connection, the actionable insight, the frontier
   question.
4. **Peer review (do NOT skip)** — confidence-score each finding 1-10, name the
   weakest link + what would verify it, bias check (which voice dominated),
   missing 6th perspective, overall grade + what to fix.

## Bridge to a venture (close the research→build gap)

If the research was about WHETHER or WHAT to build (a venture/market question),
don't stop at findings — hand off, or it stalls:
1. Distill a one-paragraph **venture brief**: value prop (one line), target user,
   the single core feature, and the go/no-go + rough tier signal the research supports.
2. Write it to `ventures/<slug>/research-brief.md` so `/assess` can ingest it
   directly — no re-deriving, no cross-repo copy-paste.
3. End with the explicit next step: `/assess "<distilled one-liner>"` if it's a
   go, or "validate first: <the cheapest test that would de-risk it>" if the
   research flagged a real risk.

Research that ends in a brief + a named next command converts; research that ends
in a wall of findings stalls. (For non-venture/technical research, skip this — a
findings summary for the architect is the deliverable.)

## Rules

- EVERY non-trivial claim cites a real source from web_search. Unsourced claims
  are marked unverified — never presented as fact. (This is the upgrade over a
  paste-only STORM: Forge grounds it in retrieval.)
- Respect copyright: paraphrase sources, short quotes only, cite properly.
- For venture research, end with "what this means for the venture" — scope,
  positioning, or a go/no-go signal — so the strategist/architect can act on it.
- Don't over-run a simple question; scale the stages to the stakes.
