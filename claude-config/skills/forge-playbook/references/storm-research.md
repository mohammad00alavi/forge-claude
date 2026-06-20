# STORM research method — multi-perspective, contradiction-mapped, self-critiqued

Adapted from Stanford's STORM (Synthesis of Topic Outlines through Retrieval and
Multi-perspective Question Asking, NAACL 2024). This is the discipline the
strategist and architect use when a venture needs real understanding instead of
a single-angle guess — and it's available standalone via `/research`.

## Why it beats a single research pass

Asking "tell me about X" gives the majority view — the surface. It misses the
practitioner who works with X daily, the skeptic who thinks the field is wrong,
the economist who follows the money. Different voices see different things, and
the *contradictions* between them are where real understanding lives. STORM also
adds a self-critique step that catches the bias and fact-misassociation a single
pass never notices.

## CRITICAL — ground it in real sources

Forge runs STORM with the actual `web_search` tool, NOT from the model's priors.
This is the key upgrade over a paste-only version: each perspective's claims must
be checked against real, current sources and cited. A perspective's "strongest
evidence" is a real source you found, not a plausible-sounding assertion. If a
claim can't be sourced, mark it as unverified — don't present it as fact.

## The four stages

### Stage 1 — Multi-perspective scan

Simulate distinct expert perspectives on the topic. For general research, use the
classic five; for VENTURE research, use the venture-tuned set (the strategist/
architect pick based on the question):

**General set:** Practitioner · Academic · Skeptic · Economist · Historian
**Venture set:** Practitioner (builds/operates this) · Market analyst (size,
demand, trends) · Skeptic (why it fails) · Competitor (who else is here, their
moats) · Target user (what they actually need vs. what's assumed)

For each perspective, search for real sources, then give:
- Core position in 2 sentences
- Strongest *sourced* evidence supporting their view (cite it)
- The one thing they'd say that no other perspective would

The perspectives are independent — they CAN be researched in parallel (each is a
self-contained search + synthesis). See parallelism note below.

### Stage 2 — Contradiction map

Now find where the voices fight:
1. Where do two+ perspectives directly contradict? List each clash with the
   specific claims.
2. Which perspective has the strongest evidence? The weakest? Why?
3. The one question that, if answered, resolves the biggest contradiction.
4. What does EVERY perspective agree on? (Likely true — even opponents confirm.)
5. What did NONE address? (The blind spot — often the most valuable finding.)

### Stage 3 — Synthesis

Pull it together into a briefing:
1. One-paragraph summary (brief a busy decision-maker — nuance, not headline)
2. Key findings ranked by reliability; for each, which perspectives support vs.
   challenge it
3. The hidden connection — a non-obvious link only visible across all perspectives
4. The actionable insight — what should be DONE differently, specifically (for a
   venture: what this means for scope, positioning, or go/no-go)
5. The frontier question — the one unknown that would change everything

### Stage 4 — Peer review (the self-critique — do NOT skip)

STORM's own researchers flagged that it doesn't self-critique by default — bias
and fact-misassociation sneak in. This stage fixes it, and it's the same
maker-doesn't-grade-itself principle Forge uses everywhere:
1. Confidence scores: rate each key finding 1-10 for reliability; explain each.
2. Weakest link: which claim are you least sure of? What would verify it?
3. Bias check: which perspective is overrepresented? Did one voice dominate?
4. Missing perspective: is there a 6th angle that would change the conclusions?
5. Overall grade: if an expert reviewed this briefing, what grade, and what would
   they say to fix?

## Scaling to the question (don't over-run it)

Not every research need wants all four stages. Match effort to the question:
- **Quick check** (a known area, low stakes) → Stage 1 with 2-3 perspectives, skip
  the rest. Don't burn tokens proving the obvious.
- **Standard venture research** → all four stages, venture-tuned perspectives.
- **High-stakes / novel / regulated** → all four, five+ perspectives, extra
  sourcing in Stage 4's weakest-link verification.

This mirrors Forge's difficulty routing: the strategist scales the research depth
the same way it scales build effort.

## Parallelism note

The Stage-1 perspectives are independent, so they can be dispatched as parallel
subagents (one per perspective), each doing its own web_search and returning its
sourced view, then Stage 2 joins them. This is DESIGNED for but verify on first
run — if parallel dispatch is awkward in practice, running them sequentially
produces the same content, just slower. Stages 2-4 are inherently sequential
(each consumes the previous).

## Output

A research briefing: the four stages above, every non-trivial claim cited to a
real source, reliability scored, contradictions named, blind spot flagged, and —
for venture research — a clear "what this means for the venture" (scope,
positioning, or go/no-go signal). Hand it to the strategist (assessment) or
architect (technical/design decisions), or return it standalone via `/research`.
