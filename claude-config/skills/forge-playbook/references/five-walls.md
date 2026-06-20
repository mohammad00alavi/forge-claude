# The five load-bearing walls (hardening from Professor)

These five rules are non-negotiable structural guarantees, adapted from
mreza0100/professor's "five load-bearing walls" — the parts of its
architecture that 22 release tags proved you cannot remove. They make the
system safe to run with less supervision. Touch anything else; leave these.

## Wall 1 — One agent owns git

Only the **builder** runs `git` commands, and even then `add`/`commit`/`push`
are human-gated (edits are free). No other agent — not the verifier, not
devops, not any business agent — runs git. This:
- centralizes destructive operations behind one reviewed path,
- prevents agents racing each other for a commit,
- makes "what got committed" auditable to one source.

If an agent needs something committed, it asks the builder (or surfaces it to
the human). devops PREPARES deploys but never runs git or deploys.

## Wall 2 — The gate gates the merge (objective, both sides)

Code is verified on the worktree branch BEFORE any merge is proposed, and the
acceptance criteria are re-checked after. A gate is something that can fail the
work without a human in the room: typecheck, lint, test, build. "Looks done"
is not a gate. A second agent's opinion is not a gate. And zero tolerance for
"pre-existing failures" — if the gate is red when a venture stage starts, that
stage leaves it greener than it found it.

## Wall 3 — Path variables, never hardcoded paths

Agents receive paths as variables, never literals:

| Variable | Meaning |
|---|---|
| `$VENTURE` | venture slug |
| `$VDIR` | `ventures/$VENTURE/` |
| `$STATE` | `$VDIR/STATE.md` |
| `$DELIVERABLES` | `$VDIR/deliverables/` |
| `$WORKTREE` | the feature's worktree checkout |
| `$LEDGER` | `.claude/handoffs/$VENTURE.md` |
| `$LEARNINGS` | `.claude/memory/learnings.md` |

Agents never hardcode `ventures/foo/...`. The orchestrator passes these in.
Path conventions can change without rewriting every agent.

## Wall 4 — Worktree isolation per parallel build

Every parallel builder gets its own git worktree + branch
(`claude/<feature>`) + (if the stack needs it) its own ports. This means
multiple features can build at once without file collisions or git-state
corruption. Sequential single-feature work can skip the worktree; the moment
two builders run, worktrees are mandatory. When a feature merges, its worktree
is removed.

## Wall 5 — Self-improvement at the source

When something in the *system itself* goes wrong (an agent has a bad
instruction, a command misroutes), you don't just write a STATE.md note — you
fix the actual agent/command file via `/improve` (see the command). This is
Professor's `/pcm` idea in lean form: surgery at the source, gated by a
prompt-quality check so edits don't degrade the agent. Distinct from the
learning loop (which records *domain* lessons); this wall is for fixing the
*machinery*.

## Why these five and not more

Professor ships far more (token-ledger, `/wave` scheduler, saved-JS workflows,
Dr. House persona). Those earned their place in a battle-tested system but add
maintenance weight. These five are the irreducible reliability core — the 20%
that delivers 80% of the safety. The rest is documented as an upgrade path in
the README, to be added only when a real pain proves it's needed.
