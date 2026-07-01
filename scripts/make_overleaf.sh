#!/usr/bin/env bash
# Assemble a self-contained Overleaf project from the paper sources plus the
# generated figures and tables, and zip it for upload.
# Usage:  bash scripts/make_overleaf.sh
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$ROOT/replication/overleaf"
rm -rf "$OUT"; mkdir -p "$OUT/sections" "$OUT/appendix" "$OUT/figures" "$OUT/tables"

# copy manuscript sources
cp "$ROOT/paper/main.tex"        "$OUT/main.tex"
cp "$ROOT/paper/references.bib"  "$OUT/references.bib"
cp "$ROOT/paper/sections/"*.tex  "$OUT/sections/"
cp "$ROOT/paper/appendix/"*.tex  "$OUT/appendix/"
cp "$ROOT/figures/"*.pdf         "$OUT/figures/"
cp "$ROOT/tables/"*.tex          "$OUT/tables/"

# make the project self-contained: figures live in ./figures, tables in ./tables
#   - graphicspath already includes {figures/}
#   - rewrite \input{../tables/...} to \input{tables/...}
for f in "$OUT/main.tex" "$OUT/sections/"*.tex "$OUT/appendix/"*.tex; do
  sed -i.bak 's#\.\./tables/#tables/#g; s#\.\./figures/#figures/#g' "$f" && rm -f "$f.bak"
done

# zip
( cd "$OUT/.." && rm -f overleaf_project.zip && zip -r -q overleaf_project.zip overleaf )
echo "Overleaf project assembled at $OUT and zipped to replication/overleaf_project.zip"
