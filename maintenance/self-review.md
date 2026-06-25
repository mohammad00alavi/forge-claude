# Forge self-review (maintainer-only — NOT shipped to installs)

The daily self-maintenance pass for the Forge repo itself. This is meta-tooling
for Forge's maintainer; it lives OUTSIDE `claude-config/`, so `install.sh` never
copies it into a user's project. (Users who clone Forge get `/improve` for fixing
their own local copy — they do NOT get this repo-wide self-review.)

**Principle (same as maintain-mode): wide autonomy on WHEN it looks, narrow
permissions on WHAT it changes. It proposes; the human ships.** It may edit
machinery, run the eval gate, and open a PR — it must NEVER push, merge, tag, or
cut a release. Releases are human-cut (see RELEASING.md).

## What it does, each run

1. **Deterministic health** — run `maintenance/forge-lint.sh`. Any FAIL is a
   regression (a contradiction crept back in); fix it first or flag it in the digest.
2. **Eval gate** — run the affected suites in `claude-config/evals/` and compare
   to `BASELINE.md`. A drop of 2+ cases in any capability is a regression (this is
   what catches silent model drift and a bad edit). If nothing changed since the
   last run, run a rotating subset so the whole suite is covered across the week.
3. **Mine the usage signal** (from the maintainer's active Forge installs):
   - `ventures/*/routing-ledger.tsv` — is the model mix near 70/20/10? Flag Opus > ~15%.
   - `learnings.md` — any rule at `↑↑` (proven 3×)? Promote it into the rubric.
   - STATE.md across ventures — recurring re-tiers, recorded dead ends, escalations,
     or 3-round fix-loop failures. A pattern in **≥2 ventures** is a real signal.
   - "Escalated to human" items piling up across ventures.
4. **Act only on CONFIRMED patterns** — a trap seen ≥2×, a learning at `↑↑`, or an
   eval regression. For each, run the `/improve` loop: diagnose → eval-before →
   smallest edit → eval-after; keep the change only if the score holds or rises.
   Budget: ≤2 machinery edits per run, one failure-class each. Don't re-touch a
   file edited in the last 3 days unless it regressed (a cool-down against thrash).
5. **Write the digest** to `maintenance/digests/<date>.md`: health + eval status,
   the model mix, learnings promoted, confirmed patterns and what you did (or why
   you held), and anything that needs the human.
6. **Open a PR** with the digest + any gated machinery edits — then STOP. The human
   reviews, merges, and (weekly or on demand) cuts a release.

## Hard rules
- Never weaken a safety / git / gate / wall rule to make something pass (sacred,
  same as `/improve` step 2). Editing `settings.json` stays human-gated.
- Never act on a single occurrence — only confirmed patterns. (Forge's own history
  was 8 versions in one day = thrash. Bias toward stability.)
- Never cut a release: prepare the candidate; the human tags and pushes.
