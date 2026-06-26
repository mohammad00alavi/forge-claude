# Cross-provider verification (optional, defeats representational collapse)

## Why this exists

Forge's default verifier runs on Haiku — cheap and independent of the *builder's
reasoning*, but it is still a Claude model, so it shares Claude's training blind
spots. The research is blunt about the limit: models review their own
submissions with near-perfect win rates (Claude ~1.00 in cross-play studies),
and same-model "committees" suffer *representational collapse* — three agents on
one model behave like ~2 independent voices (cosine similarity ~0.89). Consensus
among same-model agents reduces random error but does NOT correct systematic
error: if the bias is in the model, every Claude reviewer shares it.

The fix the evidence supports: have a model from a **different provider** review
Claude's code. Different training data and RLHF → non-overlapping blind spots →
the reviewer catches what a Claude verifier structurally cannot.

This is OPT-IN, not default, because of two real costs (below). The default
Haiku verifier stays fully functional on any plan with no extra setup.

## Two costs to accept before turning it on

1. **A different provider's model reads your code.** For client work (e.g.
   Frontkom / Norwegian public-sector code), this is a data-processing decision,
   not just a technical one. Clear it the same way you'd clear any third-party
   code-sharing. Do NOT enable for repos under a data-residency constraint.
2. **It needs a second tool + auth.** A GPT or Gemini CLI and its credentials.
   More setup, more cost per review.

## How to wire it (one of these)

- **OpenAI Codex** (official, installs inside Claude Code):
  `/plugin marketplace add openai/codex-plugin-cc`
  `/plugin install codex@openai-codex`
  `/codex:setup`
  Then the verifier's final gate calls `/codex:review` on the diff.
- **Gemini / Antigravity**: the gemini-plugin-cc / antigravity-plugin port.
  (Note: the Gemini CLI free tier was retired on June 18 2026 in favor of
  Antigravity `agy`; use the Antigravity path and verify current state before
  relying on it.)

After install, set in the venture STATE.md Snapshot:
`Cross-verify: codex` (or `gemini` / `none`). The verifier reads this.

## Graceful degradation (never hard-fail on a missing optional tool)

Cross-verify is strictly optional plumbing. If STATE.md sets `Cross-verify:
codex` (or `gemini`) but the plugin/CLI isn't actually installed, the verifier
does NOT error or block the build — it falls back to the Haiku verifier + the
maker/checker wall, notes "cross-verify requested but unavailable" in STATE.md,
and surfaces it to the human. The same rule applies to the rescue path below: if
the rescue command isn't installed, skip straight to human escalation. A missing
optional integration must never stall a run.

## When the verifier uses it

The verifier checks STATE.md `Cross-verify`:
- **`none`** (default) → Haiku verifier only. Unchanged v2 behavior.
- **`codex`/`gemini`** → run the Haiku gate first (catches the cheap stuff),
  then route the FINAL pre-merge review through the cross-provider model.
  Both must agree the work is done before the human-approval gate.

A FAIL from EITHER verifier blocks the merge. They are not a vote — either one
finding a real defect stops it. (This is intentional: the whole point is that
the cross-provider reviewer sees things the Claude one misses, so its veto
matters even when Claude's verifier passed.)

## The Wise-Agent escalation (cross-model rescue)

Separate from review: when the builder fails to turn a red gate green after the
3-round same-model cap, instead of escalating straight to the human, FIRST try
a cross-provider rescue (`/codex:rescue` or `/gemini:rescue` — these can read
the repo and propose a fix). The research showed a different foundation model
"resolves deadlocked cycles single-model retries cannot break" — an error
pattern that loops one model often lies outside another model's failure
distribution. Only escalate to the human if the cross-model rescue also fails.
If neither rescue command is installed, skip straight to human escalation — the
rescue is a best-effort optimization, never a hard dependency.

This is also opt-in (same `Cross-verify` setting gates it) and respects every
wall: the rescue's output is still reviewed, still gated, still human-approved
before commit.

## If you don't enable this

You lose nothing you had in v2 — the Haiku verifier and the maker/checker wall
work exactly as before. You're just declining the *extra* independence that a
different model family provides. For solo/non-client ventures where the code is
yours to share, turning it on is the single biggest reliability upgrade in v2.1.
For client code under data constraints, leave it off and rely on the Haiku
verifier plus your own review.
