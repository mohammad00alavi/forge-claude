# Option C — Bondly-style ratified auto-merge (full port)

Port bondly-frontend's L3 machinery: merge happens only through a dedicated tool
(`tools/agentic/auto-merge.mjs` equivalent) that ratifies each PR through one of two paths,
with a serialized merge queue and rate-limit breakers around it.

## What porting means here

- **Path A** — a human applies a risk label (`risk:pure-deletion`, `risk:mechanical-refactor`)
  → the tool may squash-merge that PR when the gate is green.
- **Path B** — the tool itself classifies the PR as a verified-reversible class **and** every
  required reviewer (in bondly: boundary/gdpr/verifier agents; in forge it would be
  self-review-style reviewer passes) posted a SUCCESS verdict on the head SHA.
- Plus the shared kill-switches (`automerge:halt`, `human:*`), a merge queue
  (rebase → gate → merge → wait), and loop-guard rate limiting.
- The toggle: `LOOP_AUTOMERGE` gates whether the ratify tool runs at all — same variable,
  heaviest interpretation.

Bondly's implementation is ~10 Node scripts with tests (`auto-merge`, `merge-queue`,
`publish-verdict`, `verdict-carry`, `loop-scope`, `loop-guard`, …). Forge has no Node
toolchain, so a port is either a substantial shell rewrite or adopting Node into a repo that
is otherwise pure markdown + bash.

## Both modes, concretely

- OFF: ready PRs, human merges — same as A and B.
- ON: only PRs that pass ratification (label or verdict panel) merge; everything else remains
  human. The most granular ON of the three — per-PR risk classes, not a single global gate.

## Trade-offs

**For:** the richest safety semantics — per-class reversibility, independent reviewer verdicts
bound to the exact SHA, a queue that prevents mid-air collisions. Proven in production on
bondly-frontend.

**Against:** days of build plus ongoing upkeep, for a repo whose PRs are markdown/config
changes a `forge-lint` check already covers; verdict-panel reviewers cost API spend per PR;
most of the machinery (merge queue, loop-scope, breakers) exists to manage *volume and
concurrency* forge-claude doesn't have — one maintainer, a handful of PRs a week.

**Verdict:** not now. Adopt B; steal C's *ideas* cheaply as they become relevant — the
`risk:*` label vocabulary and the per-path escalate deny are already folded into Option B's
gate workflow. Revisit C only if Forge gains outside contributors or a real PR queue.
