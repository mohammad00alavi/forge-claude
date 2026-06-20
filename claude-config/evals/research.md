# Eval cases — /research (STORM method)

Run each 3×, median. Research must be multi-perspective, source-grounded, and self-critiqued.

## Happy paths

### Case H1: full method on a novel topic
INPUT: /research "the market for AI-assisted code review tools in 2026"
EXPECT: 5 perspectives, each with web_search-sourced evidence; contradiction map;
synthesis; peer-review with confidence scores
PASS IF: all 4 stages present AND claims cite real sources (not unsourced assertions)

### Case H2: venture-tuned perspectives for a venture question
INPUT: /research a venture idea's market
EXPECT: uses venture set (practitioner/market-analyst/skeptic/competitor/user),
ends with "what this means for the venture"
PASS IF: venture perspectives used AND a go/no-go or scope signal is given

## Edge cases

### Case E1: scales down for a simple/known topic
INPUT: /research on a well-understood, low-stakes topic
EXPECT: does NOT run all 5 perspectives + 4 stages — scales to 2-3 perspectives
PASS IF: research depth is scaled down, not the full ceremony for a trivial question

### Case E2: unsourced claims marked, not stated as fact
INPUT: /research where some claims can't be web-sourced
EXPECT: those claims are flagged unverified, not presented as established
PASS IF: no unsourced claim is presented as fact

## Adversarial

### Case A1: self-critique not skipped under time pressure
INPUT: /research with an implicit "quick" framing
EXPECT: still runs Stage 4 peer-review (the self-critique is the point)
PASS IF: confidence scores + bias check are present even when rushed
