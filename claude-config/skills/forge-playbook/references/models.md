# Model pinning — alias → version map

## Why this exists

Forge's agents declare `model: opus` / `sonnet` / `haiku` as *aliases* so the
roster reads cleanly and survives model launches. But aliases float: "opus"
silently points at whatever the latest Opus is, and the research showed
Claude Code's own March 2026 quality regression came partly from silent version
drift under a stable-looking config. This file pins the aliases to specific
versions you've validated, so an upgrade is a deliberate choice you make and
re-baseline against — not something that happens to you mid-venture.

## The map (edit these to the versions you've validated)

| Alias (in agent frontmatter) | Pinned version | Role in Forge |
|------------------------------|----------------|---------------|
| `opus`   | claude-opus-4-8        | orchestrator/brain, architecture, T4 reasoning |
| `sonnet` | claude-sonnet-4-6      | bounded implementation, business deliverables |
| `haiku`  | claude-haiku-4-5       | independent verifier, mechanical/grading work |

> These are the current generation as of this build. Check Anthropic's model
> list for the exact API strings before relying on them; update this table when
> you intentionally move to a new version.

## How to use it

- **Default (recommended for stability):** leave agent frontmatter using the
  aliases (`model: opus`) and treat THIS file as the record of what each alias
  resolves to. When you upgrade, change the version here, run the eval harness
  to re-baseline (references/eval-harness.md), and note the change.
- **Hard pin (maximum reproducibility):** replace the alias in an agent's
  frontmatter with the exact version string from this table. Costs flexibility
  (you update each agent on upgrade) but guarantees no drift.

## The upgrade ritual (so a new model doesn't silently regress you)

1. Note the current eval baseline (`.claude/evals/BASELINE.md`).
2. Change the version here (or in agent frontmatter for a hard pin).
3. Re-run the eval harness for the affected capabilities.
4. If scores hold or improve → keep it, update the baseline. If they drop →
   the new model regressed *your* machinery; revert or adjust prompts.

This is the same before/after discipline `/improve` uses — because a model
swap is a change to the machinery just as much as a prompt edit is.

## What this is NOT

Not a routing change — the 70/20/10 logic and per-tier assignments are
unchanged (references/routing.md). This only fixes *which exact model* each
alias means, so "it got worse and I didn't change anything" has a place to be
caught.
