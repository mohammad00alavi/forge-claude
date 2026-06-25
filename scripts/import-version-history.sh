#!/usr/bin/env bash
# Reconstruct Forge's pre-git version lineage (v2.1 -> v3.8) as real git history
# on an ISOLATED orphan branch `version-history`, with one tag per version —
# WITHOUT touching main. The early versions were zip/dist snapshots, so their
# provenance never made it into git; this puts it there for anyone who wants the
# content history.
#
# Usage:  scripts/import-version-history.sh /path/to/snapshots-parent
#   where snapshots-parent contains "Forge v2.1/forge-v2.1-dist", "Forge v3/...".
# Run from inside the forge-claude repo, on a CLEAN working tree.
set -euo pipefail

SNAP_ROOT="${1:?usage: import-version-history.sh /path/to/snapshots-parent}"

git rev-parse --git-dir >/dev/null 2>&1 || { echo "Not inside a git repo."; exit 1; }
git diff --quiet && git diff --cached --quiet || {
  echo "Working tree not clean — commit or stash first (this won't touch main, but --orphan shares the index)."; exit 1; }

ORIG="$(git symbolic-ref --quiet --short HEAD || git rev-parse --short HEAD)"

# oldest -> newest:  tag|relative-path-under-SNAP_ROOT
SNAPS=(
  "v2.1|Forge v2.1/forge-v2.1-dist"
  "v2.2|Forge v2.1/forge-v2.2-dist"
  "v2.3|Forge v2.1/forge-v2.3-dist"
  "v3.2|Forge v2.1/forge-v3.2-dist"
  "v3.3|Forge v2.1/forge-v3.3-dist"
  "v3.6|Forge v3/forge-v3.6-dist"
  "v3.8|Forge v3/forge-v3.8-dist"
)

git checkout --orphan version-history
git rm -rf --quiet . >/dev/null 2>&1 || true

for entry in "${SNAPS[@]}"; do
  tag="${entry%%|*}"; rel="${entry#*|}"; src="$SNAP_ROOT/$rel"
  if git rev-parse -q --verify "refs/tags/$tag" >/dev/null; then
    echo "  abort — tag $tag already exists (refusing to overwrite)"; exit 1
  fi
  if [ ! -d "$src" ]; then echo "  skip $tag — missing: $src"; continue; fi
  find . -mindepth 1 -maxdepth 1 ! -name .git -exec rm -rf {} +
  cp -a "$src"/. .
  git add -A
  git commit -q -m "Forge $tag (reconstructed from dist snapshot)"
  git tag "$tag" >/dev/null
  echo "  committed + tagged $tag"
done

git checkout -q "$ORIG"
echo "Done — lineage on branch 'version-history'; your '$ORIG' is untouched."
echo "Inspect:  git log --oneline version-history    |    git tag -l"
