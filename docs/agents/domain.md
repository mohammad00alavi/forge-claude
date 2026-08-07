# Domain docs — where this repo's truth lives

Single-context repo; no CONTEXT-MAP. Read in this order:

- **`README.md`** — the VISION: what Forge is, the walls, tiers, commands.
- **`CHANGELOG.md`** — machinery history; every shipped machinery change lands
  here (never in `claude-config/memory/learnings.md`, which holds cross-venture
  domain facts only).
- **`maintenance/README.md`** — the self-maintenance surface (lint, gates,
  self-review, release, forge loop, automerge).
- **`docs/design/*`** — decision records (e.g. `docs/design/automerge/` for the
  merge-toggle decision). Add a design folder for any decision that outlives
  its PR; the queue lives in issues, decisions live here.
- **`claude-config/evals/`** — the behavioral contract: BASELINE.md is the
  regression reference; a machinery change that moves a suite re-baselines
  deliberately or reverts.

Vocabulary: use the repo's own terms — walls, tiers (T0–T4), maker/checker,
gate, venture, machinery vs domain learning — as defined in README and the
`forge-playbook` skill.
