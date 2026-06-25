# Routing — model, effort, and agent-count logic

The principle (Anthropic's "decoupling brain from hands," Apr 2026, plus the
community-converged 70/20/10 routing pattern): match per-token cost to task
complexity. Documented cost reduction vs. all-frontier deployment is 40–60%.

## Model tiers (use aliases so the system stays current)

- **opus** — the "brain": architecture, adversarial review, holding two large
  artifacts in mind at once (e.g., comparing a spec to an implementation),
  ambiguous T4 reasoning. Expensive; reserve it.
- **sonnet** — bounded, well-scoped work: implementing a defined feature,
  writing tests, drafting marketing copy from a brief. The workhorse.
- **haiku** — mechanical and grading work: lint passes, format fixes, cheap
  independent verifier/grader sub-agents. An independent Haiku grader is the
  recommended verifier role (no skin in the maker's game, near-free).

## Effort ladder (Claude Code `effort:` frontmatter)

`low | medium | high | xhigh`. Opus 4.8 defaults to high, and its high does
roughly what the prior generation's xhigh did. So: **let high be the default**,
drop to medium/low to save cost on mechanical work, reach for xhigh only for
extended exploration or T4 adversarial review.

## The 70/20/10 target

Across a venture's total token spend, aim roughly: 70% Haiku/mechanical-Sonnet,
20% Sonnet/bounded, 10% Opus/brain. If Opus is more than ~10–15% of spend,
something cheap is being routed expensive — re-check the roster.

## Agent count vs. tier

The tier sets a *starting* agent count, but the binding constraint is the
human's review bandwidth, not the tool. Rules:

1. **Every agent must have a distinct, checkable output.** Two agents that
   produce overlapping opinions = one agent and wasted tokens.
2. **Maker/checker is always two agents minimum** (different models ideal):
   the one that writes is never the one that grades.
3. **Add an agent only when a real second discipline is needed** — a devops
   agent for deploy/infra, a compliance agent for a regulated domain. Don't
   add a "frontend agent" and "backend agent" if one builder can hold both;
   split only when parallelism in isolated worktrees actually helps.
4. **Parallelism needs worktrees.** N agents writing the same files collide;
   each parallel builder gets its own git worktree.

## Per-tier defaults (mirror of SKILL.md, with model aliases)

- **T0**: architect(sonnet/med) → builder(sonnet/low). No grader needed for a
  static page; a build that compiles is the gate.
- **T1**: architect(sonnet/high) → builder(sonnet/med) → verifier(haiku/low).
- **T2**: architect(opus/high) → builder(sonnet/med) ×(parallel if needed) →
  verifier(haiku/low) + pm(sonnet/med) + marketer(sonnet/med).
- **T3**: + devops(sonnet/high) + ui-ux(sonnet/high) + sales(sonnet/med);
  orchestrator reasoning on opus/high.
- **T4**: + compliance(opus/med) + a second independent verifier(sonnet/med);
  orchestrator on opus/xhigh for the ambiguous reasoning.

> Compliance is rostered by *domain*, not only by tier: a regulated domain
> (fintech/health/legal) pulls a compliance agent in at **T3** too — don't wait
> for T4 (rule 3 above).

These are defaults the architect can adjust per project. When in doubt, fewer
agents and a tighter loop beats a big swarm you can't review.

> The authoritative model for each agent is the `model:` line in its own
> frontmatter (`.claude/agents/<agent>.md`) — that's what actually runs and what
> the routing ledger reads. This table is the roster/tier guide; if the two ever
> disagree, the frontmatter wins.
