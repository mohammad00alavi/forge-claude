# Releasing Forge

Forge is versioned with **git tags**, not zip snapshots. (Historically versions
were cut as `forge-vX.Y-dist` zips, which left provenance ambiguous — the audit
couldn't tell which version a project had installed. Tags fix that.)

## Cut a release

1. Land all changes for the release on the default branch (committed locally).
2. Update the version in `README.md` (badge), `install.sh` (echo line), and add a
   dated section to `CHANGELOG.md`.
3. Run the eval suite; update `claude-config/evals/BASELINE.md` if scores moved.
4. Tag it: `git tag -a vX.Y -m "Forge vX.Y"`
5. The **human** pushes the tag (`git push origin vX.Y`) — agents cannot push
   (Wall 1).

**Automated (recommended):** instead of steps 4–5, after pushing the bumped
markers to `main`, run the **Forge release** Action (Actions → Run workflow →
enter the version). It re-runs the release gate (`maintenance/release-gate.sh`),
then creates the tag and publishes the GitHub Release — and refuses if the gate
is red. You trigger it; the daily self-review never tags. See
`maintenance/forge-release.workflow.yml`.

## Versioning

- **MINOR** (vX.**Y**) — new agents/commands/skills, or behavior changes.
- **PATCH** — doc/consistency fixes, eval additions, hook hardening.

Keep the `README` badge, the `install.sh` echo, and the latest `CHANGELOG`
section in agreement — the audit flagged stale self-descriptions as a recurring
smell.

## Current

- **v3.9** — the maturity + P2 hardening + eval-coverage + self-maintenance work
  (2026-06-24 → 06-25, see `CHANGELOG.md`). Version markers bumped on the
  `release/v3.9` branch; tag with `git tag -a v3.9` after it merges to `main`.
- **v3.8** — tagged at the pre-maturity-pass commit (the released v3.8 state).

## History (pre-git versions)

The v2.1→v3.6 lineage predates this git repo (it was cut as zip snapshots). See
`VERSION-HISTORY.md` for the dated table, and run
`scripts/import-version-history.sh <snapshots-parent>` to reconstruct it as a
tagged `version-history` branch without touching `main`.
