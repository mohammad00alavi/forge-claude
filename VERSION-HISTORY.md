# Version history

Forge was prototyped 2026-06-17 → 06-18 as a rapid run of dist snapshots
(zip/folder), not git commits — which is exactly why the audit couldn't always
tell which version a given install had (some installs lagged at v3.6 while later
ones were on v3.8). This file records the lineage so provenance is unambiguous.
From v3.8 onward, releases are git tags (see RELEASING.md).

| Version | Cut (UTC) | Notes |
|---|---|---|
| v2.1 | 2026-06-17 22:21 | first packaged release: the five walls, the difficulty engine, the business lifecycle |
| v2.2 | 2026-06-17 22:28 | refinements (approx.) |
| v2.3 | 2026-06-17 22:52 | refinements; the bash-discipline lesson era |
| v3.2 | 2026-06-17 23:53 | routing / roster work (approx.) |
| v3.3 | 2026-06-18 08:02 | routing / roster + project-scope rule (approx.) |
| v3.6 | 2026-06-18 09:57 | a mid-cycle install snapshot (9 commands) |
| v3.8 | 2026-06-18 22:22 | last zip-era snapshot — adds /grill, /research (STORM), /improve-arch (12 commands) [verified delta] |

Notes marked "approx." are inferred from snapshot timing plus the machinery-fix
log in CHANGELOG.md; the v3.6→v3.8 delta is verified by content (9 vs 12
commands). Internal labels like "v3.4"/"v3.5" appear in some files (e.g.
settings.json says "MODEL (v3.5)") but were never cut as standalone snapshots.

## Reconstruct it as real git history (optional)

The snapshots live under `code/Forge v2.1/` and `code/Forge v3/`. To turn them
into real, tagged git history on an ISOLATED branch (without touching `main`):

```
scripts/import-version-history.sh /path/to/the/folder/holding/"Forge v2.1"/and/"Forge v3"
```

It builds a linear `version-history` branch with one commit + tag per version
and leaves `main` exactly as it is. Requires a clean working tree and your git
identity (so the commits are attributed to you, not a sandbox).
