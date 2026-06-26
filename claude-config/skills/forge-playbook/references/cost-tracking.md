# Cost tracking — Effective Tokens (ET) + cost-per-accepted-change

## Why this exists

Forge's 70/20/10 routing is a *target*; this makes spend *measurable* so you
can tell whether a venture (or a routing change) actually cost what you
intended. Adapted from GitHub's agentic-CI cost work, which cut spend up to 62%
by measuring first. Lean: a normalized number you can eyeball, not a gateway or
dashboard.

## The Effective Tokens metric

Raw token counts mislead because a cached read is ~free and an Opus token costs
 ~20× a Haiku one. ET normalizes all of that into one comparable number:

```
ET = (input_tokens × 1)
   + (output_tokens × 4)        # output is the expensive part
   + (cache_read_tokens × 0.1)  # cache reads are near-free
   then × model_multiplier:
       Haiku  × 0.25
       Sonnet × 1.0
       Opus   × 5.0
```

A 10% drop in ET ≈ a 10% cost reduction, *regardless of which model ran*. That
model-independence is the point — it lets you compare a Haiku-heavy venture to
an Opus-heavy one on one axis.

## Cost per accepted change (the rollup that matters)

Total ET alone just creates anxiety. The number that drives decisions is **ET
per accepted change** — total ET for a feature divided by whether it was
accepted (merged after passing gates). Two features can have similar raw ET but
very different cost-per-acceptance when one fails gates and triggers rework
loops. A feature that took 3 verifier rounds cost far more per accepted change
than one that passed first time — and that's the signal to investigate (bad
spec? wrong model tier? a trap for the learning loop).

## How Forge tracks it (lean)

Per venture, the manager keeps a rough ET tally in STATE.md `Cost log`:
- Estimate ET per stage from the model used and rough token volume (you don't
  need exact counts — order-of-magnitude is enough to spot the 70/20/10 target
  slipping).
- Flag when Opus ET exceeds ~15% of total — that's the cheap-work-routed-
  expensive smell.
- At ship, record ET-per-accepted-feature. If a feature's cost-per-acceptance
  was an outlier, write a learning ("X-type features need tighter specs" or
  "route Y to Sonnet not Opus").

## Automatic routing ledger (measured, not estimated)

A PreToolUse hook on the Task tool (`.claude/hooks/log-agent-spawn.sh`) appends
one line per agent spawn to `ventures/<slug>/routing-ledger.tsv`:
`<timestamp>  <agent>  <model-tier>`. This makes the routing mix *measured by
invocation*, not just an ET estimate. Read it any time:

```
cut -f3 ventures/<slug>/routing-ledger.tsv | sort | uniq -c
```

That prints the Haiku/Sonnet/Opus spawn split directly — the 70/20/10 target you
can actually check. It counts invocations, not tokens, so pair it with the ET
tally above for the fuller picture. The model is read from each agent's own
frontmatter (`.claude/agents/<agent>.md`), so there is a single source of truth —
no map to keep in sync.

## What this is NOT

Not real-time metering, not a gateway, not exact accounting. Claude Code can
surface token usage; if you want exact numbers, read them there. This is the
*decision layer* — a normalized estimate that tells you whether routing is
working and which features bleed money, cheaply, without infrastructure. If you
ever need exact per-agent USD attribution, that's Professor's token-ledger or an
LLM gateway (documented upgrade path) — overkill until spend is a real line item.
